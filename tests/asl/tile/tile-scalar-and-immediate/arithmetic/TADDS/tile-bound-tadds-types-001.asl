// PTO-TEST: {"id":"PTO-AVS-TILE-TADDS-TYPES-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TADDS.asl","requirements":["PTO-INST-TILE-TADDS"],"kind":"boundary","summary":"TADDS accepts its sixteen numeric element types and rejects non-profile carriers","pass_condition":"FP32 and U8 operands pass while HiF8 operands reject before destination effects","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func ConfigureTADDSOperands(data_type: TileDataType)
begin
    ConfigureTile(
        0,
        128,
        8,
        2,
        1,
        2,
        data_type,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        8,
        2,
        1,
        2,
        data_type,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTADDSOperands(TileDataType_FP32);
    assert TileOperandsLegal_ExecuteTileScalar(
        TileBinary_ADD,
        1,
        0,
        Zeros{PTO_XLEN});

    ResetProfileState();
    ConfigureTADDSOperands(TileDataType_U8);
    assert TileOperandsLegal_ExecuteTileScalar(
        TileBinary_ADD,
        1,
        0,
        Zeros{PTO_XLEN});

    ResetProfileState();
    ConfigureTADDSOperands(TileDataType_HiF8);
    assert !TileOperandsLegal_ExecuteTileScalar(
        TileBinary_ADD,
        1,
        0,
        Zeros{PTO_XLEN});
    assert !_Tiles[[1]].contents_defined;
    return 0;
end;
