// PTO-TEST: {"id":"PTO-AVS-BLOCK-GMOV-PEER-001","source":"asl/block/execution/BSTART.GMOV.asl","requirements":["PTO-BSTART-GMOV-COLLECTIVE-001"],"kind":"boundary","summary":"Every PE supplies an absolute peer_tid in 0..3 and repeated peers are legal.","pass_condition":"One PE value 4 rejects the whole collective before allocation, while four repeated value-2 selectors succeed.","related_sources":["asl/block/model/dispatch/tlsu-gmov.asl"]}
pure func GMOVPeerStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00d11181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func GMOVPeerBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[11:9] = '001';
    instruction[18:15] = '1111';
    instruction[19] = '1';
    return instruction;
end;

pure func GMOVPeerIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func PrepareGMOVPeerBlock()
begin
    ConfigureTileForMask(0, 128, 1, 128, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any, '1111');
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    let started = ExecuteCommandInstruction(GMOVPeerStart(), 32);
    let tiles = ExecuteCommandInstruction(GMOVPeerBinding(), 32);
    let peers = ExecuteCommandInstruction(GMOVPeerIOR(), 32);
    assert started == CommandExecution_Executed;
    assert tiles == CommandExecution_Executed;
    assert peers == CommandExecution_Executed;
end;

func main() => integer
begin
    ResetProfileState();
    PrepareGMOVPeerBlock();
    for pe = 0 to 3 do
        WritePEGPR(pe as MemoryAgentId, 2, Zeros{PTO_XLEN} + 2);
    end;
    WritePEGPR(3, 2, Zeros{PTO_XLEN} + 4);
    let rejected = ExecuteBundleTileOperation();
    assert !rejected;
    assert _LastFault == Fault_TileLegality;
    assert CoreTileCapacityInUse() == 512;

    ClearFault();
    WritePEGPR(3, 2, Zeros{PTO_XLEN} + 2);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _TileAllocationMasks[[_BundleTileBindings[[0]].destination]] ==
        '1111';
    return 0;
end;
