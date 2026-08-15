// PTO-TEST: {"id":"PTO-AVS-BLOCK-GMOV-READINESS-001","source":"asl/block/execution/BSTART.GMOV.asl","requirements":["PTO-BSTART-GMOV-COLLECTIVE-001","PTO-INST-TILE-GMOV"],"kind":"fault","summary":"A partial destination mask does not reduce GMOV Core4 source readiness.","pass_condition":"A three-PE source allocation rejects a one-PE destination request before destination allocation or events.","related_sources":["asl/block/model/dispatch/tlsu-gmov.asl"]}
pure func GMOVReadinessStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00d11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func GMOVReadinessBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '001';
    instruction[18:15] = '0001';
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(0, 128, 1, 128, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any, '0111');
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 9);
    let started = ExecuteCommandInstruction(GMOVReadinessStart(), 32);
    let tiles = ExecuteCommandInstruction(GMOVReadinessBinding(), 32);
    assert started == CommandExecution_Executed;
    assert tiles == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert CoreTileCapacityInUse() == 384;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    return 0;
end;
