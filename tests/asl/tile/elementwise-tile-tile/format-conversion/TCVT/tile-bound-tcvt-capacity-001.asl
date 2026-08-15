// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-CAPACITY-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-INST-TILE-TCVT"],"kind":"boundary","summary":"TCVT model state represents the complete 8 KiB packed-X2 logical region","pass_condition":"an 8 KiB U4X2 Tile can mark all 16384 logical nibbles defined without truncating the defined-element count","related_sources":["asl/tile/model/state/types.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        8192,
        128,
        128,
        128,
        128,
        TileDataType_U4X2,
        TileLayout_RowMajor,
        TileLocation_Any);
    MarkTileValidRegionDefined(0);
    assert _Tiles[[0]].defined_valid_elements == 16384;
    assert TileElementDefined(0, 127, 127);
    return 0;
end;
