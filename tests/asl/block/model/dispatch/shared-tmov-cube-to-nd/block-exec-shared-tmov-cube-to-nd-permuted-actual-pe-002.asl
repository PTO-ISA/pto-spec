// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-CUBE-TO-ND-PERMUTED-ACTUAL-PE-002","source":"asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-BSTART-TMOV-SHARED-001","PTO-TMOV-CUBE-TO-SHARED-ND-001"],"kind":"execution","summary":"actual PEs arrive as 2,0,3,1 and map M32/M16 fragments through permuted explicit ranges","pass_condition":"four actual PEs arrive as 2,0,3,1, each source maps to a distinct permuted GPR-derived 128B range, and the complete M32/M16 RowMajor parents match raw coordinate goldens derived from encoded ranges, publish without GM events, and release parked requests","related_sources":["asl/block/model/dispatch/shared-tlsu.asl","asl/block/model/operands/shared-generation.asl","asl/block/model/operands/shared-generation-pe-requests.asl","asl/tile/model/memory/shared-cube-to-nd.asl"]}
pure func PermutedCubeToSharedNDGolden(pe: integer {0..3}, row: integer {0..31},
    column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} +
        (((17 + pe * 47 + row * 13 + column * 3 +
            ((row * column) MOD 101)) MOD 255) + 1);
end;

pure func PermutedCubeToSharedNDSharedBinding(shared_id: bits(6),
    parent_size: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = parent_size;
    instruction[11:9] = '111';
    return instruction;
end;

pure func PermutedCubeToSharedNDAssemble(writer_size: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[19:15] = Zeros{5} + 1;
    instruction[11] = '1';
    instruction[10:7] = writer_size;
    return instruction;
end;

pure func PermutedCubeToSharedNDTileBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

func ConfigurePermutedCubeToSharedNDSource(pe: integer {0..3},
    capacity_bytes: integer {128..262144}, rows: integer {16,32},
    columns: integer {1..65535}, layout: TileLayout)
begin
    let configured = ConfigureCubeTileForMask(0, capacity_bytes, rows,
        columns, TileDataType_E4M3, layout, '1111');
    assert configured;
    InstallRelativeTileFixture(0, 0);
    var tile = _Tiles[[0]];
    for row = 0 to rows - 1 looplimit 65536 do
        for column = 0 to columns - 1 looplimit 65536 do
            let element = TileStorageIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            tile.payload[[element]] = PermutedCubeToSharedNDGolden(pe,
                row as integer {0..31}, column as integer {0..127});
            tile.defined_elements[element] = '1';
        end;
    end;
    tile.defined_valid_elements = (rows * columns)
        as integer {0..524288};
    tile.contents_defined = TRUE;
    _Tiles[[0]] = tile;
end;

func RunActualPermutedCubeToSharedND(layout: TileLayout,
    source_rows: integer {16,32}, writer_size: integer {5,6},
    parent_size: integer {7,8}, offset_stride: integer {16,32},
    datr_word: bits(32), shared_id: SharedTileID)
begin
    let source_capacity = TileSizeCodeBytes(writer_size);
    let source_columns = 128;
    let parent_rows = TileSizeCodeBytes(parent_size) DIVRM source_columns;
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launched == KernelLifecycle_Started;
    var parked_tpcs: array [[PTO_MODEL_MEMORY_AGENTS]] of Word;
    StartMemoryEventCapture(0);
    for arrival = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = (if arrival == 0 then 2 else if arrival == 1 then 0
            else if arrival == 2 then 3 else 1) as integer {0..3};
        let agent = pe as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        if ReadTPC() == Zeros{PTO_XLEN} then
            WriteTPC(Zeros{PTO_XLEN} + 0x100);
        end;
        ConfigurePermutedCubeToSharedNDSource(pe, source_capacity, source_rows,
            source_columns, layout);
        let offset_slot = if pe == 0 then 2 else if pe == 1 then 0
            else if pe == 2 then 3 else 1;
        WriteGPR(1, Zeros{PTO_XLEN} + offset_slot * offset_stride);
        let start_status = ExecuteCommandInstruction(
            Zeros{64} + 0x38211181, 32);
        assert start_status == CommandExecution_Executed;
        let datr_status = ExecuteCommandInstruction(
            Zeros{PTO_XLEN} + UInt(datr_word), 32);
        assert datr_status == CommandExecution_Executed;
        let shared_status = ExecuteCommandInstruction(
            PermutedCubeToSharedNDSharedBinding(shared_id as bits(6),
                (Zeros{4} + parent_size) as bits(4)), 32);
        assert shared_status == CommandExecution_Executed;
        let assemble_status = ExecuteCommandInstruction(
            PermutedCubeToSharedNDAssemble((Zeros{4} + writer_size) as bits(4)), 32);
        assert assemble_status == CommandExecution_Executed;
        let binding_status = ExecuteCommandInstruction(
            PermutedCubeToSharedNDTileBinding(), 32);
        assert binding_status == CommandExecution_Executed;
        parked_tpcs[[agent]] = ReadTPC();
        let stopped = ExecuteCommandInstruction(Zeros{64}, 16);
        assert stopped == CommandExecution_Executed && _LastFault == Fault_None;
        if arrival < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert !SharedTilePublished(shared_id) &&
                   BundleSharedGenerationOpen(shared_id) &&
                   ReadTPC() == parked_tpcs[[agent]] &&
                   BundleSharedGenerationRequestWaiting(0);
        end;
    end;
    StopMemoryEventCapture();
    assert _MemoryEventCount == 0 && SharedTilePublished(shared_id);
    let published = SharedTileRecord(shared_id);
    assert published.tile.layout == TileLayout_RowMajor &&
           published.tile.data_type == TileDataType_E4M3 &&
           published.tile.capacity_bytes == TileSizeCodeBytes(parent_size) &&
           published.tile.rows == parent_rows &&
           published.tile.columns == source_columns &&
           published.tile.valid_rows == parent_rows &&
           published.tile.valid_columns == source_columns;
    for row = 0 to parent_rows - 1 looplimit 65536 do
        let band = row DIVRM source_rows;
        let source_pe = (if band == 0 then 1 else if band == 1 then 3
            else if band == 2 then 0 else 2) as integer {0..3};
        let source_row = (row MOD source_rows) as integer {0..31};
        for column = 0 to source_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(published.tile,
                row as integer {0..65535}, column as integer {0..65535});
            assert TileLogicalElementDefined(published.tile, element) &&
                TileReadLogicalElement(published.tile, element) ==
                    PermutedCubeToSharedNDGolden(source_pe, source_row, column);
        end;
    end;
    for release = 0 to PTO_MODEL_MEMORY_AGENTS - 2 do
        let pe = (if release == 0 then 2 else if release == 1 then 0
            else 3) as integer {0..3};
        let agent = pe as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        assert ReadTPC() == parked_tpcs[[agent]] && _BundleActive &&
               BundleSharedGenerationRequestWaiting(0);
        let drain_status = ExecuteCommandInstruction(Zeros{64}, 16);
        assert drain_status == CommandExecution_Executed;
        assert _LastFault == Fault_None && !_BundleActive &&
               !BundleSharedGenerationRequestWaiting(0);
    end;
    assert _MemoryEventCount == 0;
end;

func main() => integer
begin
    ResetProfileState();
    RunActualPermutedCubeToSharedND(TileLayout_CUBE_M32, 32, 6, 8, 32,
        Zeros{32} + 0x01f01c23, (Zeros{6} + 19) as SharedTileID);
    ResetProfileState();
    RunActualPermutedCubeToSharedND(TileLayout_CUBE_M16, 16, 5, 7, 16,
        Zeros{32} + 0x01f01ca3, (Zeros{6} + 20) as SharedTileID);
    return 0;
end;
