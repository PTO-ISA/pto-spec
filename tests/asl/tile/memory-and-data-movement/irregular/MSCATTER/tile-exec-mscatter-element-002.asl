// PTO-TEST: {"id":"PTO-AVS-TILE-MSCATTER-ELEMENT-002","source":"asl/tile/memory-and-data-movement/irregular/MSCATTER.asl","requirements":["PTO-INDEXED-TLSU-STRIDE-001","PTO-MSCATTER-BYTE-DISPLACEMENT-001","PTO-INST-TILE-MSCATTER"],"kind":"execution","summary":"MSCATTER CMode=Elem uses one relative element displacement per source coordinate.","pass_condition":"A 2x2 U32 IndexTile permutes four U8 source elements into GM while B.IOR stride is zero.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 2, 2, 2, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x20);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x21);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 0x22);
    WriteTileElement(0, 1, 1, Zeros{PTO_XLEN} + 0x23);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 1);
    SetBundleDataAttributeState(DTYPE_NONE, Zeros{5}, '11', '001',
        Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;

    StartMemoryEventCapture(0);
    MSCATTER(Zeros{PTO_XLEN} + 0x360, Zeros{PTO_XLEN}, 0, 1);

    assert _MemoryEventCount == 4;
    let memory0 = LoadUnsigned(Zeros{PTO_XLEN} + 0x360, 1);
    let memory1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x361, 1);
    let memory2 = LoadUnsigned(Zeros{PTO_XLEN} + 0x362, 1);
    let memory3 = LoadUnsigned(Zeros{PTO_XLEN} + 0x363, 1);
    assert memory0 == Zeros{PTO_XLEN} + 0x21;
    assert memory1 == Zeros{PTO_XLEN} + 0x23;
    assert memory2 == Zeros{PTO_XLEN} + 0x22;
    assert memory3 == Zeros{PTO_XLEN} + 0x20;
    StopMemoryEventCapture();
    return 0;
end;
