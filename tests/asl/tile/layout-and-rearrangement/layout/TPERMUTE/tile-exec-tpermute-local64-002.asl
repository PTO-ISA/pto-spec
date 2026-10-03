// PTO-TEST: {"id":"PTO-AVS-TILE-TPERMUTE-LOCAL64-002","source":"asl/tile/layout-and-rearrangement/layout/TPERMUTE.asl","requirements":["PTO-TPERMUTE-CONTRACT-001","PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"M32 64-bit TPERMUTE preserves independent low and high 32-bit byte groups.","pass_condition":"The low group reverses source0 bytes while the high group reverses source1 bytes without crossing the CELL-group boundary.","related_sources":["asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/layout-rearrangement.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        0, 256, 1, 1, TileDataType_U64, TileLayout_CUBE_M32);
    let right_ready = ConfigureCubeTile(
        1, 256, 1, 1, TileDataType_U64, TileLayout_CUBE_M32);
    let indices_ready = ConfigureCubeTile(
        2, 256, 1, 8, TileDataType_U8, TileLayout_CUBE_M32);
    let destination_ready = ConfigureCubeTile(
        3, 256, 1, 1, TileDataType_U64, TileLayout_CUBE_M32);
    assert left_ready && right_ready && indices_ready && destination_ready;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x8877665544332211);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0xffeeddccbbaa0099);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 2, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 3, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 4, Zeros{PTO_XLEN} + 7);
    WriteTileElement(2, 0, 5, Zeros{PTO_XLEN} + 6);
    WriteTileElement(2, 0, 6, Zeros{PTO_XLEN} + 5);
    WriteTileElement(2, 0, 7, Zeros{PTO_XLEN} + 4);
    assert TileOperandsLegal_TPERMUTE(3, 0, 1, 2);
    TPERMUTE(3, 0, 1, 2);
    assert ReadTileElement(3, 0, 0) ==
        Zeros{PTO_XLEN} + 0xccddeeff11223344;
    return 0;
end;
