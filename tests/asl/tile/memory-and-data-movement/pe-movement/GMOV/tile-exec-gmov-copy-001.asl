// PTO-TEST: {"id":"PTO-AVS-TILE-GMOV-COPY-001","source":"asl/tile/memory-and-data-movement/pe-movement/GMOV.asl","requirements":["PTO-INST-TILE-GMOV"],"kind":"execution","summary":"GMOV copies one resolved peer fragment without changing the source or memory state.","pass_condition":"The destination receives the read-old payload, the source remains defined, and no memory event is emitted.","related_sources":["asl/tile/model/memory/shared-movement.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x31);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x42);

    StartMemoryEventCapture(0);
    GMOV(1, 0, Zeros{PTO_XLEN} + 2);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x31;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 0x42;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x31;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    return 0;
end;
