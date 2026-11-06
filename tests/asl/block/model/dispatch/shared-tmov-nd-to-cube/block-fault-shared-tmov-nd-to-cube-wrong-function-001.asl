// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-ND-TO-CUBE-WRONG-FUNCTION-001","source":"asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","requirements":["PTO-TMOV-SHARED-ND-TO-CUBE-001","PTO-BSTART-TMOV-SHARED-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"fault","summary":"a TLOAD start encoding cannot select the Shared ND-to-CUBE TMOV route","pass_condition":"a decoded BSTART.TLOAD with Layout 21 and otherwise complete Shared-source/Local-destination bindings faults before allocating a Local destination or mutating the published Shared source","related_sources":["asl/block/execution/BSTART.TMOV.asl","asl/block/model/dispatch/shared-tmov-nd-to-cube.asl","asl/block/model/dispatch/tile-execution.asl"]}

pure func SharedNDToCubeWrongFunctionStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func SharedNDToCubeWrongFunctionDATR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func SharedNDToCubeWrongFunctionSource(shared_id: bits(6))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[11:9] = '001';
    return instruction;
end;

pure func SharedNDToCubeWrongFunctionDestination() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00006013;
    instruction[18:15] = Zeros{4} + 6;
    instruction[11:9] = '001';
    instruction[19] = '1';
    instruction[8:7] = '10';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN} + 0x700);
    assert launched == KernelLifecycle_Started;
    SelectExecutionContext(0 as PTOModelCoreIdentity, 0 as MemoryAgentId);
    WriteTPC(Zeros{PTO_XLEN} + 0x700);
    ConfigureTileForMask(10, 4096, 32, 128, 32, 128,
        TileDataType_U8, TileLayout_RowMajor, '1000');
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 127 looplimit 128 do
            WriteTileElement(10, row, column,
                Zeros{PTO_XLEN} + (row * 13 + column * 7) MOD 256);
        end;
    end;
    let shared_id = (Zeros{6} + 35) as SharedTileID;
    InstallSharedTile(shared_id, _Tiles[[10]], '1000');
    let source_before = SharedTileRecord(shared_id);
    assert SharedTilePublished(shared_id);

    // 0x00011181 decodes BSTART.TLOAD, not the required 0x00211181 TMOV.
    let start_status = ExecuteCommandInstruction(
        SharedNDToCubeWrongFunctionStart(), 32);
    assert start_status == CommandExecution_Executed &&
           !BundleTMOVSelected();
    let attributes_status = ExecuteCommandInstruction(
        SharedNDToCubeWrongFunctionDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 128);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let shared_status = ExecuteCommandInstruction(
        SharedNDToCubeWrongFunctionSource(shared_id as bits(6)), 32);
    let destination_status = ExecuteCommandInstruction(
        SharedNDToCubeWrongFunctionDestination(), 32);
    assert attributes_status == CommandExecution_Executed &&
           shared_status == CommandExecution_Executed &&
           destination_status == CommandExecution_Executed;
    let stop_status = ExecuteCommandInstruction(Zeros{64}, 16);
    let source_after = SharedTileRecord(shared_id);
    assert stop_status == CommandExecution_Rejected &&
           _LastFault == Fault_TileLegality &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle &&
           source_after.payload_generation == source_before.payload_generation &&
           source_after.payload_live == source_before.payload_live &&
           source_after.published == source_before.published;
    return 0;
end;
