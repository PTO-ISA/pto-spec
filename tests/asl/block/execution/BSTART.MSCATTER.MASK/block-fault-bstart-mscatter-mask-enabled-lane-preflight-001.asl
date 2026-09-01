// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-MASK-FAULT-001","source":"asl/block/execution/BSTART.MSCATTER.MASK.asl","requirements":["PTO-MSCATTER-MASK-PREDICATE-001","PTO-INST-TILE-MSCATTER-MASK"],"kind":"fault","summary":"MSCATTER.MASK preflights all enabled lanes and never checks disabled addresses.","pass_condition":"A disabled invalid lane is ignored, but a later enabled fault leaves an earlier enabled address unchanged and records no event.","related_sources":["asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 4, 1, 3, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 1, 4, 1, 3, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigurePredicateTile(3, 128, 1, 4, 1, 3);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x1111);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x2222);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 0x3333);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 5000);
    WriteTileElement(2, 0, 2, Zeros{PTO_XLEN} + 2);
    WriteTilePredicateBit(3, 0, 0, TRUE);
    WriteTilePredicateBit(3, 0, 1, FALSE);
    WriteTilePredicateBit(3, 0, 2, TRUE);
    Store(Zeros{PTO_XLEN} + 4094, 2, Zeros{PTO_XLEN} + 0xaaaa);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 4094);
    var start: bits(64) = Zeros{64} + 0x00711181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, FALSE, 3, 0, TRUE);
    SetBundleScalarBinding(0, 0, 2, 4, 0, 2);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    let observed = LoadUnsigned(Zeros{PTO_XLEN} + 4094, 2);
    assert observed == Zeros{PTO_XLEN} + 0xaaaa;
    return 0;
end;
