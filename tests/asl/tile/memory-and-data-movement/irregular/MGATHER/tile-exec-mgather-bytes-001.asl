// PTO-TEST: {"id":"PTO-AVS-TILE-MGATHER-BYTES-001","source":"asl/tile/memory-and-data-movement/irregular/MGATHER.asl","requirements":["PTO-INDEXED-TLSU-STRIDE-001","PTO-INST-TILE-MGATHER"],"kind":"execution","summary":"MGATHER applies a padded row stride to logical linear element indices and pads the physical destination outside its valid rectangle.","pass_condition":"Indices zero and three with ValidCol two and stride three load base plus zero and base plus four while the non-valid physical row receives Max padding.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 2, 2, 1, 2, TileDataType_S32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 3);
    Store(Zeros{PTO_XLEN} + 0x200, 1, Zeros{PTO_XLEN} + 0x11);
    Store(Zeros{PTO_XLEN} + 0x204, 1, Zeros{PTO_XLEN} + 0x44);

    StartMemoryEventCapture(0);
    MGATHER(0, Zeros{PTO_XLEN} + 0x200,
        Zeros{PTO_XLEN} + 3, 1, TilePad_Max);

    assert _MemoryEventCount == 2;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x44;
    assert ReadTileElement(0, 1, 0) == Zeros{PTO_XLEN} + 0xff;
    assert ReadTileElement(0, 1, 1) == Zeros{PTO_XLEN} + 0xff;
    StopMemoryEventCapture();
    return 0;
end;
