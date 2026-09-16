// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-MASK-PACKED-001","source":"asl/block/execution/BSTART.MGATHER.MASK.asl","requirements":["PTO-MGATHER-MASK-PREDICATE-001","PTO-BSTART-MGATHER-MASK-SCHEMA-001","PTO-MGATHER-BYTE-DISPLACEMENT-001"],"kind":"execution","summary":"MGATHER.MASK uses one ordinary predicate for one complete packed byte.","pass_condition":"An exact-one U8 predicate enables one S32 byte displacement and both nibbles from the loaded byte populate the U4X2 destination.","related_sources":["asl/block/model/dispatch/tlsu-mgather-mask.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func PackedMaskGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00611181;
    instruction[31:27] = Zeros{5} + 28;
    return instruction;
end;

pure func PackedMaskGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func PackedMaskGatherIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5};
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    Store(Zeros{PTO_XLEN} + 0x204, 1, Zeros{PTO_XLEN} + 0xa5);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x200);
    let started = ExecuteCommandInstruction(PackedMaskGatherStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 2);
    let bound = ExecuteCommandInstruction(PackedMaskGatherBinding(), 32);
    assert bound == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(PackedMaskGatherIOR(), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x204;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 10;
    StopMemoryEventCapture();
    return 0;
end;
