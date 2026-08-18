// PTO-TEST: {"id":"PTO-AVS-TILE-TCOLMAX-U16-001","source":"asl/tile/reduce-and-expand/column-reduction/TCOLMAX.asl","requirements":["PTO-INST-TILE-TCOLMAX"],"kind":"execution","summary":"TCOLMAX compares U16 elements as unsigned values.","pass_condition":"The all-ones U16 value wins in each column regardless of row.","related_sources":["asl/tile/model/execution/reduction.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0, 128, 2, 2, 2, 2,
        TileDataType_U16,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1, 128, 1, 2, 1, 2,
        TileDataType_U16,
        TileLayout_RowMajor,
        TileLocation_Any);
    let u16_all_ones = Zeros{PTO_XLEN} + 0xffff;
    WriteTileElement(0, 0, 0, u16_all_ones);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 1, 1, u16_all_ones);

    ExecuteTileReduction(
        TileReduction_MAX,
        TileAxis_Column,
        1,
        0);

    assert ReadTileElement(1, 0, 0) == u16_all_ones;
    assert ReadTileElement(1, 0, 1) == u16_all_ones;
    return 0;
end;
