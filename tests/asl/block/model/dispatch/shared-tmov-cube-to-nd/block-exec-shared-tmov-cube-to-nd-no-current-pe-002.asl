// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-CUBE-TO-ND-NO-CURRENT-PE-002","source":"asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","requirements":["PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-TMOV-CUBE-TO-SHARED-ND-001"],"kind":"execution","summary":"model-only submissions place normalized Local CUBE fragments by explicit B.ASSEMBLE offsets","pass_condition":"Four no-current-PE M32 fragments use INIT/MIDDLE/LAST and explicit permuted offsets to atomically publish the same 128x128 ND raw golden as actual-PE submissions without GM events","related_sources":["asl/block/model/operands/shared-generation.asl","asl/block/model/operands/shared-generation-pe-requests.asl","asl/tile/model/memory/shared-cube-to-nd.asl"]}
pure func NoPECubeToSharedNDGolden(source: integer {0..3}, row: integer {0..31},
    column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} +
        (((17 + source * 47 + row * 13 + column * 3 +
            ((row * column) MOD 101)) MOD 255) + 1);
end;

pure func NoPECubeToSharedNDShared(size_code: bits(4),
    shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = '111';
    return instruction;
end;

pure func NoPECubeToSharedNDAssemble(init: boolean, last: boolean,
    writer_size: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[19:15] = Zeros{5} + 1;
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = writer_size;
    return instruction;
end;

pure func NoPECubeToSharedNDTileBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

func ConfigureNoPECubeSource(source: integer {0..3})
begin
    let configured = ConfigureCubeTileForMask(0, 4096, 32, 128,
        TileDataType_E4M3, TileLayout_CUBE_M32, '1111');
    assert configured;
    InstallRelativeTileFixture(0, 0);
    var tile = _Tiles[[0]];
    for row = 0 to 31 do
        for column = 0 to 127 do
            let element = TileStorageIndex(tile, row, column);
            tile.payload[[element]] = NoPECubeToSharedNDGolden(source,
                row as integer {0..31}, column as integer {0..127});
            tile.defined_elements[element] = '1';
        end;
    end;
    tile.defined_valid_elements = 4096 as integer {0..524288};
    tile.contents_defined = TRUE;
    _Tiles[[0]] = tile;
end;

func SubmitNoPECubeFragment(source: integer {0..3}, offset_slot: integer {0..3},
    first: boolean, last: boolean)
begin
    ConfigureNoPECubeSource(source);
    WriteGPR(1, Zeros{PTO_XLEN} + offset_slot * 32);
    let start_status = ExecuteCommandInstruction(Zeros{64} + 0x38211181, 32);
    let datr_status = ExecuteCommandInstruction(Zeros{64} + 0x01f01c23, 32);
    let shared_status = ExecuteCommandInstruction(NoPECubeToSharedNDShared(
        if first then Zeros{4} + 8 else Zeros{4}, Zeros{6} + 19), 32);
    let assemble_status = ExecuteCommandInstruction(NoPECubeToSharedNDAssemble(
        first, last, Zeros{4} + 6), 32);
    let tile_status = ExecuteCommandInstruction(
        NoPECubeToSharedNDTileBinding(), 32);
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           assemble_status == CommandExecution_Executed &&
           tile_status == CommandExecution_Executed;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    assert _LastFault == Fault_None;
    assert stop_status == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    let shared_id = (Zeros{6} + 19) as SharedTileID;
    assert !_CurrentPEContextValid;
    StartMemoryEventCapture(0);
    // Source identities are deliberately placed at different offsets:
    // output row bands are determined by B.ASSEMBLE's GPR-derived range.
    SubmitNoPECubeFragment(0, 2, TRUE, FALSE);
    assert BundleSharedGenerationOpen(shared_id) &&
           !SharedTilePublished(shared_id);
    SubmitNoPECubeFragment(1, 0, FALSE, FALSE);
    SubmitNoPECubeFragment(2, 3, FALSE, FALSE);
    SubmitNoPECubeFragment(3, 1, FALSE, TRUE);
    StopMemoryEventCapture();
    assert SharedTilePublished(shared_id) && _MemoryEventCount == 0;
    let parent = SharedTileRecord(shared_id).tile;
    assert parent.layout == TileLayout_RowMajor &&
           parent.capacity_bytes == 16384 && parent.rows == 128 &&
           parent.columns == 128 && parent.valid_rows == 128 &&
           parent.valid_columns == 128;
    for row = 0 to 127 do
        let band = row DIVRM 32;
        let source = if band == 0 then 1 else if band == 1 then 3
            else if band == 2 then 0 else 2;
        let source_row = row MOD 32;
        for column = 0 to 127 do
            let element = TileLogicalLinearIndex(parent,
                row as integer {0..65535}, column as integer {0..65535});
            assert TileLogicalElementDefined(parent, element) &&
                   TileReadLogicalElement(parent, element) ==
                       NoPECubeToSharedNDGolden(source as integer {0..3},
                           source_row as integer {0..31},
                           column as integer {0..127});
        end;
    end;
    return 0;
end;
