// PTO-TEST: {"id":"PTO-AVS-TILE-TROWPROD-ONE-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWPROD.asl","requirements":["PTO-INST-TILE-TROWPROD"],"kind":"execution","summary":"TROWPROD uses the exact typed multiplicative identity.","pass_condition":"FP16 uses encoding 0x3c00 and U8 uses integer one.","related_sources":["asl/tile/model/execution/reduction.asl"]}
func main() => integer
begin
    let fp_one = TileProfileReductionInitial(
        TileReduction_PRODUCT,
        TileDataType_FP16,
        Zeros{PTO_XLEN});
    let integer_one = TileProfileReductionInitial(
        TileReduction_PRODUCT,
        TileDataType_U8,
        Zeros{PTO_XLEN});
    assert fp_one == Zeros{PTO_XLEN} + 0x3c00;
    assert integer_one == Zeros{PTO_XLEN} + 1;

    ResetProfileState();
    ConfigureTile(
        0,
        128,
        1,
        2,
        1,
        2,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        1,
        1,
        1,
        1,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 20);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 20);
    ExecuteTileReduction(
        TileReduction_PRODUCT,
        TileAxis_Row,
        1,
        0);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 144;
    return 0;
end;
