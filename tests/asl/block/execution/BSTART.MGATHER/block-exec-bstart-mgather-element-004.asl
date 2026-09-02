// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-ELEMENT-004","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-B-DATR-FIELDS-001","PTO-INDEXED-TLSU-STRIDE-001","PTO-BSTART-MGATHER-SCHEMA-001","PTO-MGATHER-BYTE-DISPLACEMENT-001"],"kind":"execution","summary":"Decoded MGATHER uses B.DATR CMode=Elem for coordinate-wise relative element displacements.","pass_condition":"A 1x2 U32 IndexTile swaps two U8 GM elements with RegSrc1 encoded zero.","related_sources":["asl/block/model/dispatch/tlsu-mgather.asl","asl/tile/model/memory/addressing.asl"]}
pure func ElementGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func ElementGatherAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[31:29] = '001';
    instruction[28:27] = '11';
    instruction[24:20] = DTYPE_NONE;
    return instruction;
end;

pure func ElementGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func ElementGatherIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 0x380, 1, Zeros{PTO_XLEN} + 0x41);
    Store(Zeros{PTO_XLEN} + 0x381, 1, Zeros{PTO_XLEN} + 0x52);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x380);

    let started = ExecuteCommandInstruction(ElementGatherStart(), 32);
    assert started == CommandExecution_Executed;
    let attributed = ExecuteCommandInstruction(ElementGatherAttributes(), 32);
    assert attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    let bound = ExecuteCommandInstruction(ElementGatherBinding(), 32);
    assert bound == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(ElementGatherIOR(), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x52;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0x41;
    assert _MemoryEventCount == 2;
    StopMemoryEventCapture();
    return 0;
end;
