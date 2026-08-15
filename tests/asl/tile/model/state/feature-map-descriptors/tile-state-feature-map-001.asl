// PTO-TEST: {"id":"PTO-AVS-TILE-FEATURE-MAP-STATE-001","source":"asl/tile/model/state/feature-map-descriptors.asl","requirements":["PTO-TIMG2COL-CONTRACT-001"],"kind":"state-transition","summary":"Feature-map descriptor configuration is core Tile state and reallocation invalidates it.","pass_condition":"The configured descriptor is readable until the Local Tile is configured again.","related_sources":["asl/tile/model/state/allocation.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTileFeatureMapDescriptor(
        1, TileFeatureMapLayout_NC1HWC0,
        1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1,
        0, 0, 0, 0,
        1, Zeros{PTO_XLEN}, FALSE);
    assert ReadTileFeatureMapDescriptor(1).valid;

    ConfigureTile(
        1, 128, 1, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Matrix);
    assert !ReadTileFeatureMapDescriptor(1).valid;
    return 0;
end;
