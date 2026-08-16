// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-MASK-GATHER-001","source":"asl/block/execution/BSTART.MGATHER.MASK.asl","requirements":["PTO-BSTART-MGATHER-MASK-SCHEMA-001","PTO-MGATHER-MASK-PREDICATE-001","PTO-MGATHER-MASK-PUBLICATION-001","PTO-INST-TILE-MGATHER-MASK","PTO-INST-BLOCK-BSTART-MGATHER-MASK"],"kind":"execution","summary":"MGATHER.MASK loads only exact-one lanes and pads every other physical destination element.","pass_condition":"Signed byte displacements load two U8 elements, a disabled invalid displacement produces no event or fault, and Max fills both the disabled valid lane and the complete non-valid physical region.","related_sources":["asl/block/model/dispatch/tlsu-mgather-mask.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func MaskGatherStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00611181;
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

pure func MaskGatherBinding(mask: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = mask;
    instruction[11:9] = '001';
    return instruction;
end;

pure func MaskGatherIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

pure func MaskGatherMaxPad() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[28:27] = '01';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 4, 1, 3, TileDataType_S16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigurePredicateTile(1, 128, 1, 4, 1, 3);
    WriteTileElement(0, 0, 0, Ones{PTO_XLEN} - 7);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x7fff);
    WriteTileElement(0, 0, 2, Ones{PTO_XLEN});
    WriteTilePredicateBit(1, 0, 0, TRUE);
    WriteTilePredicateBit(1, 0, 1, FALSE);
    WriteTilePredicateBit(1, 0, 2, TRUE);
    Store(Zeros{PTO_XLEN} + 0x100, 1, Zeros{PTO_XLEN} + 11);
    Store(Zeros{PTO_XLEN} + 0x107, 1, Zeros{PTO_XLEN} + 33);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x108);
    let started = ExecuteCommandInstruction(MaskGatherStart(), 32);
    assert started == CommandExecution_Executed;
    let padded = ExecuteCommandInstruction(MaskGatherMaxPad(), 32);
    assert padded == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let bound = ExecuteCommandInstruction(MaskGatherBinding('0001'), 32);
    assert bound == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(MaskGatherIOR(), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0xff;
    assert ReadTileElement(destination, 0, 2) == Zeros{PTO_XLEN} + 33;
    assert ReadTileElement(destination, 0, 3) == Zeros{PTO_XLEN} + 0xff;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 0xff;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x100;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x107;
    StopMemoryEventCapture();
    return 0;
end;
