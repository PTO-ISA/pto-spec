// PTO-TEST: {"id":"PTO-AVS-TILE-MGATHER-ELEMENT-002","source":"asl/tile/memory-and-data-movement/irregular/MGATHER.asl","requirements":["PTO-INDEXED-TLSU-STRIDE-001","PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-INST-TILE-MGATHER"],"kind":"execution","summary":"MGATHER CMode=Elem uses one relative element displacement per destination coordinate.","pass_condition":"A 2x2 U32 IndexTile permutes four U8 GM elements while B.IOR stride is zero.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 2, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 2, 2, 2, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 1);
    Store(Zeros{PTO_XLEN} + 0x340, 1, Zeros{PTO_XLEN} + 0x10);
    Store(Zeros{PTO_XLEN} + 0x341, 1, Zeros{PTO_XLEN} + 0x11);
    Store(Zeros{PTO_XLEN} + 0x342, 1, Zeros{PTO_XLEN} + 0x12);
    Store(Zeros{PTO_XLEN} + 0x343, 1, Zeros{PTO_XLEN} + 0x13);
    SetBundleDataAttributeState(DTYPE_NONE, Zeros{5}, '11', '001',
        Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;

    StartMemoryEventCapture(0);
    MGATHER(0, Zeros{PTO_XLEN} + 0x340, Zeros{PTO_XLEN}, 1,
        TilePad_Null);

    assert _MemoryEventCount == 4;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x13;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x10;
    assert ReadTileElement(0, 1, 0) == Zeros{PTO_XLEN} + 0x12;
    assert ReadTileElement(0, 1, 1) == Zeros{PTO_XLEN} + 0x11;
    StopMemoryEventCapture();
    return 0;
end;
