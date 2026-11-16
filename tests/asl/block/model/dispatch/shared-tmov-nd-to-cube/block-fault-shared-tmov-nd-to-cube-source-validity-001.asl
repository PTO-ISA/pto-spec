// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-SOURCE-VALIDITY-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"fault","summary":"reverse TMOV rejects an undefined valid source coordinate before Local CUBE allocation","pass_condition":"a published RowMajor Shared parent with one undefined valid element is rejected by the decoded Function-2 request with Fault_TileLegality, no Local CUBE destination, and unchanged Shared generation/publication state","related_sources":["asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/tile/model/memory/shared-nd-to-cube.asl","asl/tile/model/definedness/packed-boundary.asl"]}

pure func SharedNDToCubeValidityStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func SharedNDToCubeValidityDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func SharedNDToCubeValidityShared(shared_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[11:9] = '001';
    return instruction;
end;

pure func SharedNDToCubeValidityDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 6;
    instruction[8:7] = '10';
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func SharedNDToCubeValidityGolden(
    row: integer {0..31}, column: integer {0..127}) => Word
begin
    return Zeros{PTO_XLEN} + 3 + row * 73 + column * 19;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x740);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x740);
    ConfigureTileForMask(10, 4096, 32, 128, 32, 128,
        TileDataType_U8, TileLayout_RowMajor, '1000');
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            WriteTileElement(10, row as integer {0..65535},
                column as integer {0..65535},
                SharedNDToCubeValidityGolden(
                    row as integer {0..31},
                    column as integer {0..127}));
        end;
    end;
    let shared_id = (Zeros{6} + 45) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    let shared_index = SharedTileArrayIndex(shared_id);
    let source_tile = _SharedTiles[[shared_index]].tile;
    let undefined_element = TileStorageIndex(source_tile, 0, 0);
    _SharedTiles[[shared_index]].tile.defined_elements[undefined_element] = '0';
    _SharedTiles[[shared_index]].tile.defined_valid_elements = 4095;
    let source_before = SharedTileRecord(shared_id);
    assert SharedTilePublished(shared_id) && source_tile.contents_defined &&
           !TileLogicalElementDefined(
               _SharedTiles[[shared_index]].tile,
               undefined_element as PackedTileElementIndex);

    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeValidityStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        SharedNDToCubeValidityDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeValidityShared(shared_id as bits(6)), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeValidityDestination(), 32);
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    let source_after = SharedTileRecord(shared_id);
    var cube_allocated = FALSE;
    for tile = 0 to 63 looplimit 64 do
        if _Tiles[[tile]].allocated &&
           _Tiles[[tile]].layout == TileLayout_CUBE_M32 then
            cube_allocated = TRUE;
        end;
    end;
    assert start_status == CommandExecution_Executed &&
           datr_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed &&
           stop_status == CommandExecution_Rejected &&
           _LastFault == Fault_TileLegality && !cube_allocated;
    assert source_after.payload_generation == source_before.payload_generation &&
           source_after.payload_live == source_before.payload_live &&
           source_after.published == source_before.published;
    return 0;
end;
