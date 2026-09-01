// PTO-TEST: {"id":"PTO-AVS-TILE-MSCATTER-MASK-LANES-001","source":"asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl","requirements":["PTO-INST-TILE-MSCATTER-MASK"],"kind":"execution","summary":"MSCATTER_MASK stores only exact-one predicate lanes and leaves disabled addresses untouched.","pass_condition":"One enabled lane writes its byte, the disabled lane preserves memory, and exactly one store event is recorded.","related_sources":["asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigurePredicateTile(2, 128, 1, 2, 1, 2);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x35);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x46);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTilePredicateBit(2, 0, 0, TRUE);
    WriteTilePredicateBit(2, 0, 1, FALSE);
    Store(Zeros{PTO_XLEN} + 0x2c0, 1, Zeros{PTO_XLEN} + 0xaa);
    Store(Zeros{PTO_XLEN} + 0x2c1, 1, Zeros{PTO_XLEN} + 0xbb);

    StartMemoryEventCapture(0);
    MSCATTER_MASK(Zeros{PTO_XLEN} + 0x2c0,
        Zeros{PTO_XLEN} + 2, 0, 1, 2);

    assert _MemoryEventCount == 1;
    let enabled = LoadUnsigned(Zeros{PTO_XLEN} + 0x2c0, 1);
    let disabled = LoadUnsigned(Zeros{PTO_XLEN} + 0x2c1, 1);
    assert enabled == Zeros{PTO_XLEN} + 0x35;
    assert disabled == Zeros{PTO_XLEN} + 0xbb;
    StopMemoryEventCapture();
    return 0;
end;
