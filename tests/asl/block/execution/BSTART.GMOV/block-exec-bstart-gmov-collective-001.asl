// PTO-TEST: {"id":"PTO-AVS-BLOCK-GMOV-COLLECTIVE-001","source":"asl/block/execution/BSTART.GMOV.asl","requirements":["PTO-BSTART-GMOV-COLLECTIVE-001","PTO-INST-TILE-GMOV","PTO-INST-BLOCK-BSTART-GMOV"],"kind":"execution","summary":"GMOV preflights a full Core4 source while a partial mask selects only Local destination fragments.","pass_condition":"A mask 0011 transfer with repeated legal peers copies the read-old snapshot, allocates only two PE fragments, and emits no memory event.","related_sources":["asl/block/model/dispatch/tlsu-gmov.asl","asl/tile/model/memory/shared-movement.asl"]}
pure func GMOVCollectiveStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00d11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func GMOVCollectiveBinding(mask: bits(4), size: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = size;
    instruction[8:7] = '00';
    instruction[18:15] = mask;
    instruction[19] = '1';
    instruction[25:20] = Zeros{6};
    return instruction;
end;

pure func GMOVCollectiveIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func ConfigureGMOVCore4Source(mask: bits(4))
begin
    ConfigureTileForMask(0, 128, 1, 128, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any, mask);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x5a);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureGMOVCore4Source('1111');
    WritePEGPR(0, 2, Zeros{PTO_XLEN});
    WritePEGPR(1, 2, Zeros{PTO_XLEN} + 1);
    WritePEGPR(2, 2, Zeros{PTO_XLEN} + 1);
    WritePEGPR(3, 2, Zeros{PTO_XLEN} + 3);
    let started = ExecuteCommandInstruction(GMOVCollectiveStart(), 32);
    let tiles = ExecuteCommandInstruction(
        GMOVCollectiveBinding('0011', '001'), 32);
    let peers = ExecuteCommandInstruction(GMOVCollectiveIOR(), 32);
    assert started == CommandExecution_Executed;
    assert tiles == CommandExecution_Executed;
    assert peers == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert destination == 1;
    assert _TileAllocationMasks[[destination]] == '0011';
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x5a;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    return 0;
end;
