// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-UNDEF-020","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-B-SHARED-WHOLE-PARENT-READY-001","PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"boundary","summary":"Cooperative TMATMUL waits for an unallocated Shared primary without fault or effects","pass_condition":"the undefined-register fallback remains legal generally while Matrix readiness waits without allocation consumption Shared mutation numeric status or fault","related_sources":["asl/tile/model/state/shared-registers.asl","asl/block/model/dispatch/tile-execution.asl"]}
pure func MatrixSharedUndefinedStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = '00100';
    return instruction;
end;

pure func MatrixSharedUndefinedFPATR() => bits(64)
begin
    return Zeros{64} + 0x00002023;
end;

pure func MatrixSharedUndefinedSource(shared_tile_id: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = '0000';
    instruction[11:9] = '111';
    return instruction;
end;

pure func MatrixSharedUndefinedLocal() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = '0001';
    instruction[11:9] = '111';
    instruction[25:20] = Zeros{6};
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    let shared_tile_id = (Zeros{6} + 13) as SharedTileID;
    ResetProfileState();
    let status_before = NumericStatusFlags();
    let left_ready = ConfigureCubeTileForMask(0, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert left_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);

    let started = ExecuteCommandInstruction(
        MatrixSharedUndefinedStart(), 32);
    let attributes = ExecuteCommandInstruction(
        MatrixSharedUndefinedFPATR(), 32);
    let shared = ExecuteCommandInstruction(
        MatrixSharedUndefinedSource(shared_tile_id), 32);
    let local = ExecuteCommandInstruction(
        MatrixSharedUndefinedLocal(), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert shared == CommandExecution_Executed;
    assert local == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_None;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !SharedTileRecord(shared_tile_id).descriptor_valid;
    assert !_BundleSharedBindings[[0]].consumed;
    assert NumericStatusFlags() == status_before;
    return 0;
end;
