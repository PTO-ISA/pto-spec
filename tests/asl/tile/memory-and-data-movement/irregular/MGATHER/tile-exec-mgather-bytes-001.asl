// PTO-TEST: {"id":"PTO-AVS-TILE-MGATHER-BYTES-001","source":"asl/tile/memory-and-data-movement/irregular/MGATHER.asl","requirements":["PTO-INST-TILE-MGATHER"],"kind":"execution","summary":"MGATHER treats integer index elements as byte displacements and pads the physical destination outside its valid rectangle.","pass_condition":"Two indexed bytes load from base plus displacement while both elements in the non-valid physical row receive Max padding.","related_sources":["asl/tile/model/memory/gather-scatter.asl"]}
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
    Store(Zeros{PTO_XLEN} + 0x203, 1, Zeros{PTO_XLEN} + 0x44);

    StartMemoryEventCapture(0);
    MGATHER(0, Zeros{PTO_XLEN} + 0x200, 1, TilePad_Max);

    assert _MemoryEventCount == 2;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0x44;
    assert ReadTileElement(0, 1, 0) == Zeros{PTO_XLEN} + 0xff;
    assert ReadTileElement(0, 1, 1) == Zeros{PTO_XLEN} + 0xff;
    StopMemoryEventCapture();
    return 0;
end;
