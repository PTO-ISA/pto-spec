// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-SIGNED-001","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-INDEXED-TLSU-STRIDE-001","PTO-MGATHER-BYTE-DISPLACEMENT-001"],"kind":"boundary","summary":"A signed S32 relative row index selects a GM row before the base.","pass_condition":"With ValidCol and stride two, row index -1 addresses the two U16 elements immediately before the base.","related_sources":["asl/tile/model/memory/addressing.asl"]}
pure func SignedGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

pure func SignedGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func SignedGatherIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Ones{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 0x100, 2, Zeros{PTO_XLEN} + 0x2211);
    Store(Zeros{PTO_XLEN} + 0x102, 2, Zeros{PTO_XLEN} + 0x4433);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x104);
    let started = ExecuteCommandInstruction(SignedGatherStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 2);
    let tiles = ExecuteCommandInstruction(SignedGatherBinding(), 32);
    assert tiles == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(SignedGatherIOR(), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x100;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x102;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x2211;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0x4433;
    StopMemoryEventCapture();
    return 0;
end;
