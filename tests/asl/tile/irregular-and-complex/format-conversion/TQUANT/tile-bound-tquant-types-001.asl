// PTO-TEST: {"id":"PTO-AVS-TILE-TQUANT-TYPES-001","source":"asl/tile/irregular-and-complex/format-conversion/TQUANT.asl","requirements":["PTO-INST-TILE-TQUANT"],"kind":"boundary","summary":"TQUANT accepts only a defined row-major FP32 source and an S8 or U8 destination","pass_condition":"FP32 to S8 is legal while U64 input and U16 output are rejected","related_sources":["asl/tile/model/legality/operand-schema.asl","asl/tile/model/numeric/formats.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 128, 1, 1, 1, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 32, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 16, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 128, 64, 1, 1, 1, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);

    let control = DefaultNumericExecutionControl();
    let scale = Zeros{PTO_XLEN} + 0x3f800000;
    assert TileOperandsLegal_TQUANT(0, 1, scale, Zeros{PTO_XLEN}, control);
    assert !TileOperandsLegal_TQUANT(0, 2, scale, Zeros{PTO_XLEN}, control);
    assert !TileOperandsLegal_TQUANT(3, 1, scale, Zeros{PTO_XLEN}, control);
    return 0;
end;
