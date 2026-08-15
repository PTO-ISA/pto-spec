// PTO-TEST: {"id":"PTO-AVS-TILE-TTRI-SHAPE-001","source":"asl/tile/irregular-and-complex/initialization/TTRI.asl","requirements":["PTO-INST-TILE-TTRI"],"kind":"boundary","summary":"TTRI accepts only supported numeric row-major destination descriptors","pass_condition":"FP16 row-major is legal while U8 and column-major descriptors are rejected","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        16,
        4,
        2,
        3,
        TileDataType_FP16,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        32,
        4,
        2,
        3,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        16,
        4,
        2,
        3,
        TileDataType_FP16,
        TileLayout_ColumnMajor,
        TileLocation_Any);

    assert TileOperandsLegal_TTRI(0, FALSE, 0);
    assert !TileOperandsLegal_TTRI(1, FALSE, 0);
    assert !TileOperandsLegal_TTRI(2, FALSE, 0);
    return 0;
end;
