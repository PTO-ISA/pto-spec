// PTO-TEST: {"id":"PTO-AVS-BLOCK-MSCATTER-MASK-PACKED-001","source":"asl/block/execution/BSTART.MSCATTER.MASK.asl","requirements":["PTO-MSCATTER-MASK-PREDICATE-001","PTO-MSCATTER-BYTE-DISPLACEMENT-001","PTO-BSTART-MSCATTER-MASK-SCHEMA-001"],"kind":"execution","summary":"MSCATTER.MASK uses one ordinary predicate for one complete packed byte.","pass_condition":"An exact-one U8 predicate enables one S32 byte displacement and both U4X2 source nibbles are stored as one byte.","related_sources":["asl/block/model/dispatch/tlsu-mscatter-mask.asl","asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U4X2,
        TileLayout_RowMajor);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor);
    ConfigureTile(3, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 10);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 1);
    Store(Zeros{PTO_XLEN} + 0x204, 1, Zeros{PTO_XLEN});
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x200);
    var start: bits(64) = Zeros{64} + 0x00711181;
    start[31:27] = Zeros{5} + 28;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 2);
    WritePEGPR(0, 4, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(FALSE, 0, 0, '0001', TRUE, FALSE, 3, 0, TRUE);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 2);
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x204;
    let stored = LoadUnsigned(Zeros{PTO_XLEN} + 0x204, 1);
    assert stored == Zeros{PTO_XLEN} + 0xa5;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 10;
    StopMemoryEventCapture();
    return 0;
end;
