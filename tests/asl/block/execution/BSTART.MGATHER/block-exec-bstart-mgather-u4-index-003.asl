// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-U4-INDEX-003","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-MGATHER-BYTE-DISPLACEMENT-001"],"kind":"execution","summary":"MGATHER zero-extends a U32 byte displacement in an ordinary packed transfer.","pass_condition":"A U32 displacement of fifteen addresses Base plus fifteen and transfers both nibbles from one byte.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/definedness/elements.asl"]}

pure func PackedUnsignedGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = Zeros{5} + 28;
    return instruction;
end;

pure func PackedUnsignedGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func PackedUnsignedGatherIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5};
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 15);
    Store(Zeros{PTO_XLEN} + 0x10f, 1, Zeros{PTO_XLEN} + 0xa5);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x100);

    let started = ExecuteCommandInstruction(PackedUnsignedGatherStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(PackedUnsignedGatherBinding(), 32);
    assert bound == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(PackedUnsignedGatherIOR(), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x10f;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x5 &&
    ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0xa;
    StopMemoryEventCapture();
    return 0;
end;
