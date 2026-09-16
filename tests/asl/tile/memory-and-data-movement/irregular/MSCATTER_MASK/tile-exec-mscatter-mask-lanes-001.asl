// PTO-TEST: {"id":"PTO-AVS-TILE-MSCATTER-MASK-LANES-001","source":"asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl","requirements":["PTO-INST-TILE-MSCATTER-MASK"],"kind":"execution","summary":"MSCATTER_MASK stores only exact-one predicate lanes and leaves disabled addresses untouched.","pass_condition":"One enabled lane writes its byte, the disabled lane preserves memory, and exactly one store event is recorded.","related_sources":["asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor);
    ConfigureTile(2, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x35353535);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x46464646);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 4);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 0x2c0, 4, Zeros{PTO_XLEN} + 0xaaaaaaaa);
    Store(Zeros{PTO_XLEN} + 0x2c4, 4, Zeros{PTO_XLEN} + 0xbbbbbbbb);

    StartMemoryEventCapture(0);
    MSCATTER_MASK(Zeros{PTO_XLEN} + 0x2c0,
        0, 1, 2);

    assert _MemoryEventCount == 1;
    let enabled = LoadUnsigned(Zeros{PTO_XLEN} + 0x2c0, 4);
    let disabled = LoadUnsigned(Zeros{PTO_XLEN} + 0x2c4, 4);
    assert enabled == Zeros{PTO_XLEN} + 0x35353535;
    assert disabled == Zeros{PTO_XLEN} + 0xbbbbbbbb;
    StopMemoryEventCapture();
    return 0;
end;
