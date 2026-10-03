// PTO-TEST: {"id":"PTO-AVS-TILE-TUNPACK-LOCAL64-002","source":"asl/tile/layout-and-rearrangement/layout/TUNPACK.asl","requirements":["PTO-TUNPACK-CONTRACT-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"TUNPACK joins two raw result words into one M32 U64 destination element.","pass_condition":"Distinct low and high source planes survive a four-byte extraction and publish as one coherent logical U64 element.","related_sources":["asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/layout-rearrangement.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        0, 256, 1, 1, TileDataType_U64, TileLayout_CUBE_M32);
    let destination_ready = ConfigureCubeTile(
        1, 256, 1, 1, TileDataType_U64, TileLayout_CUBE_M32);
    assert source_ready && destination_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x8877665544332211);
    assert TileOperandsLegal_TUNPACK(
        1, 0, Zeros{PTO_XLEN} + 0x00000400);
    TUNPACK(1, 0, Zeros{PTO_XLEN} + 0x00000400);
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x8877665544332211;
    return 0;
end;
