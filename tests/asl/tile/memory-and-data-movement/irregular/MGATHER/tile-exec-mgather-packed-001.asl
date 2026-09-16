// PTO-TEST: {"id":"PTO-AVS-TILE-MGATHER-PACKED-001","source":"asl/tile/memory-and-data-movement/irregular/MGATHER.asl","requirements":["PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-INST-TILE-MGATHER"],"kind":"execution","summary":"MGATHER maps one signed byte displacement to one packed byte and pads the physical destination.","pass_condition":"Signed displacement four loads one packed byte at Base plus four; its low and high nibbles become adjacent logical values.","related_sources":["asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U4X2,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_S32,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 4);
    Store(Zeros{PTO_XLEN} + 0x204, 1, Zeros{PTO_XLEN} + 0xa5);

    StartMemoryEventCapture(0);
    MGATHER(0, Zeros{PTO_XLEN} + 0x200,
        1, TilePad_Max);

    assert _MemoryEventCount == 1;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x5;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0xa;
    StopMemoryEventCapture();
    return 0;
end;
