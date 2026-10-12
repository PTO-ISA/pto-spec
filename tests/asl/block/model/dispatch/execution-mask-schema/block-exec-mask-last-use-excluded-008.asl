// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXECUTION-MASK-LAST-USE-EXCLUDED-008","source":"asl/block/model/dispatch/execution-mask-schema.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-TADD-CONTRACT-001","PTO-B-IOT-STREAM-001","PTO-ARCH-LOCAL-VTAG-LIFETIME-001"],"kind":"execution","summary":"An encoded PredicateCell ExecutionMask remains outside ordinary B.IOT last-use handling.","pass_condition":"TADD consumes two encoded ordinary last-use sources but preserves the final encoded PredicateCell carrier while using it to gate the result.","related_sources":["asl/block/model/operands/tile-bindings.asl","asl/block/model/dispatch/tile-instruction-operands.asl"]}
pure func LastUseExecutionMaskTADDStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = Zeros{2};
    instruction[24:20] = Zeros{5};
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U16);
    return instruction;
end;

pure func LastUseExecutionMaskAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    instruction[13] = '1';
    return instruction;
end;

pure func TwoLastUseSources(source0: bits(6), source1: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00002013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[11:9] = '001';
    return instruction;
end;

pure func LastUseMaskAndDestination(source: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x04005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 1;
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTileForMask(
        1, 128, 1, 1, TileDataType_U16, TileLayout_CUBE_M16, '1000');
    let right_ready = ConfigureCubeTileForMask(
        2, 128, 1, 1, TileDataType_U16, TileLayout_CUBE_M16, '1000');
    let predicate_ready = ConfigurePredicateCellForMask(
        3, 128, 1, 1, TileDataType_FP32, TileLayout_CUBE_M16, '1000');
    assert left_ready && right_ready && predicate_ready;
    InstallRelativeTileFixture(1, 1);
    InstallRelativeTileFixture(2, 2);
    InstallRelativeTileFixture(3, 3);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 1);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);
    _Tiles[[3]].contents_defined = TRUE;

    let started = ExecuteCommandInstruction(LastUseExecutionMaskTADDStart(), 32);
    let attributes = ExecuteCommandInstruction(
        LastUseExecutionMaskAttributes(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let inputs = ExecuteCommandInstruction(
        TwoLastUseSources(Zeros{6} + 1, Zeros{6} + 2), 32);
    let result = ExecuteCommandInstruction(
        LastUseMaskAndDestination(Zeros{6} + 3), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert inputs == CommandExecution_Executed;
    assert result == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let mask_bit = PTOPEMaskBitOfPEIdentity(0);
    assert _TilePayloadLiveMasks[[1]][mask_bit] == '0';
    assert _TilePayloadLiveMasks[[2]][mask_bit] == '0';
    assert _TilePayloadLiveMasks[[3]][mask_bit] == '1';
    return 0;
end;
