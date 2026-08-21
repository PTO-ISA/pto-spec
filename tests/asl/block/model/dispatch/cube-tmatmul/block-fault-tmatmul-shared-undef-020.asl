// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-UNDEF-020","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001"],"kind":"fault","summary":"Cooperative TMATMUL rejects an unallocated Shared primary before effects","pass_condition":"the undefined-register fallback remains legal generally but Matrix readiness rejects it without allocation consumption or Shared mutation","related_sources":["asl/tile/model/state/shared-registers.asl"]}
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

pure func MatrixSharedUndefinedSource(shared_id: bits(8)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[27:20] = shared_id;
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
    let shared_id = Zeros{8} + 77;
    ResetProfileState();
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
        MatrixSharedUndefinedSource(shared_id), 32);
    let local = ExecuteCommandInstruction(
        MatrixSharedUndefinedLocal(), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert shared == CommandExecution_Executed;
    assert local == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !SharedTileRecord(shared_id).descriptor_valid;
    assert !_BundleSharedBindings[[0]].consumed;
    return 0;
end;
