// PTO-TEST: {"id":"PTO-AVS-TILE-TDEQUANT-TYPES-001","source":"asl/tile/irregular-and-complex/format-conversion/TDEQUANT.asl","requirements":["PTO-INST-TILE-TDEQUANT"],"kind":"boundary","summary":"TDEQUANT accepts only a defined row-major S8 or U8 source and an FP32 destination","pass_condition":"S8 to FP32 is legal while FP32 input, U64 output, and a zero multiplier are rejected","related_sources":["asl/tile/model/legality/operand-schema.asl","asl/tile/model/numeric/formats.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 32, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 128, 1, 1, 1, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 32, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(3, 128, 16, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);

    let control = DefaultNumericExecutionControl();
    let scale = Zeros{PTO_XLEN} + 0x3f800000;
    assert TileOperandsLegal_TDEQUANT(0, 1, scale, Zeros{PTO_XLEN}, control);
    assert !TileOperandsLegal_TDEQUANT(0, 2, scale, Zeros{PTO_XLEN}, control);
    assert !TileOperandsLegal_TDEQUANT(3, 1, scale, Zeros{PTO_XLEN}, control);
    assert !TileOperandsLegal_TDEQUANT(
        0, 1, Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, control);
    var saturating = control;
    saturating.saturating = TRUE;
    assert !TileOperandsLegal_TDEQUANT(
        0, 1, scale, Zeros{PTO_XLEN}, saturating);
    return 0;
end;
