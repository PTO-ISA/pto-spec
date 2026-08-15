// PTO-TEST: {"id":"PTO-AVS-TILE-TCI-SHAPE-001","source":"asl/tile/irregular-and-complex/initialization/TCI.asl","requirements":["PTO-INST-TILE-TCI"],"kind":"boundary","summary":"TCI accepts only one-row row-major S32 S16 U32 or U16 destinations","pass_condition":"one-row U16 is legal while two valid rows U8 and column-major descriptors are rejected","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        32,
        2,
        1,
        2,
        TileDataType_U16,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        32,
        2,
        2,
        2,
        TileDataType_U16,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        64,
        2,
        1,
        2,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        3,
        128,
        32,
        2,
        1,
        2,
        TileDataType_U16,
        TileLayout_ColumnMajor,
        TileLocation_Any);

    assert TileOperandsLegal_TCI(
        0,
        Zeros{PTO_XLEN},
        FALSE);
    assert !TileOperandsLegal_TCI(
        1,
        Zeros{PTO_XLEN},
        FALSE);
    assert !TileOperandsLegal_TCI(
        2,
        Zeros{PTO_XLEN},
        FALSE);
    assert !TileOperandsLegal_TCI(
        3,
        Zeros{PTO_XLEN},
        FALSE);
    return 0;
end;
