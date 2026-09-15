// PTO-TEST: {"id":"PTO-AVS-TILE-MGATHER-BYTES-001","source":"asl/tile/memory-and-data-movement/irregular/MGATHER.asl","requirements":["PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-INST-TILE-MGATHER"],"kind":"execution","summary":"MGATHER uses signed byte displacements and pads the physical destination outside its valid rectangle.","pass_condition":"Signed displacements zero and four load two U32 values at Base plus zero and Base plus four while the non-valid physical row receives Max padding.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 2, 2, 1, 2, TileDataType_S32,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 4);
    Store(Zeros{PTO_XLEN} + 0x200, 4, Zeros{PTO_XLEN} + 0x11111111);
    Store(Zeros{PTO_XLEN} + 0x204, 4, Zeros{PTO_XLEN} + 0x44444444);

    StartMemoryEventCapture(0);
    MGATHER(0, Zeros{PTO_XLEN} + 0x200,
        1, TilePad_Max);

    assert _MemoryEventCount == 2;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x11111111;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x44444444;
    assert ReadTileElement(0, 1, 0) == Zeros{PTO_XLEN} + 0xffffffff;
    assert ReadTileElement(0, 1, 1) == Zeros{PTO_XLEN} + 0xffffffff;
    StopMemoryEventCapture();
    return 0;
end;
