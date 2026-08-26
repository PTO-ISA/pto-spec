// PTO-TEST: {"id":"PTO-AVS-TILE-TUNPACK-FIELD-001","source":"asl/tile/layout-and-rearrangement/layout/TUNPACK.asl","requirements":["PTO-TUNPACK-CONTRACT-001","PTO-INST-TILE-TUNPACK"],"kind":"execution","summary":"TUNPACK extracts and zero-extends one contiguous byte field.","pass_condition":"Each destination word contains the selected source byte field and no other bits.","related_sources":["asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/layout-rearrangement.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured_1 = ConfigureCubeTile(1, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_2 = ConfigureCubeTile(2, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x44332211);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x88776655);
    TUNPACK(2, 1, Zeros{PTO_XLEN} + 0x00000201);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x00003322;
    assert ReadTileElement(2, 1, 0) == Zeros{PTO_XLEN} + 0x00007766;
    TUNPACK(2, 1, Zeros{PTO_XLEN} + 0x00000103);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x00000044;
    assert !TileOperandsLegal_TUNPACK(2, 1, Zeros{PTO_XLEN} + 0x00000500);
    let configured_3 = ConfigureCubeTile(3, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let configured_4 = ConfigureCubeTile(4, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x44332211);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 0x88776655);
    WriteTileElement(3, 1, 0, Zeros{PTO_XLEN} + 0x44332211);
    WriteTileElement(3, 1, 1, Zeros{PTO_XLEN} + 0x88776655);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN});
    TUNPACK(4, 3, Zeros{PTO_XLEN} + 0x00000201);
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 0x00003322;
    assert ReadTileElement(4, 0, 1) == Zeros{PTO_XLEN} + 0x00007766;
    return 0;
end;
