// PTO-TEST: {"id":"PTO-AVS-ARCH-MX-ENCODING-CLASSIFICATION-BOUND-002","source":"asl/arch/features/mx-formats.asl","requirements":[],"kind":"boundary","summary":"restricted encodings reject before value-class dispatch and integer classification remains exact","pass_condition":"TF32, HF32, E3M2, signed, and unsigned classification assertions hold","related_sources":["asl/arch/data-types/numeric-classification.asl"]}
func main() => integer
begin
    let invalid_tf32 = Zeros{PTO_XLEN} + 0x3f800001;
    assert !TileNumericEncodingValid(TileDataType_TF32, invalid_tf32);
    assert TileNumericValueClass(TileDataType_TF32, invalid_tf32) ==
        NumericValue_InvalidEncoding;
    assert TileNumericEncodingValid(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x3f800000);
    assert TileNumericValueClass(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x3f800000) == NumericValue_PositiveNormal;

    assert !TileNumericEncodingValid(TileDataType_HF32,
        Zeros{PTO_XLEN} + 1);
    assert TileNumericValueClass(TileDataType_HF32,
        Zeros{PTO_XLEN} + 1) == NumericValue_InvalidEncoding;
    assert !TileNumericEncodingValid(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x40);
    assert TileNumericValueClass(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x40) == NumericValue_InvalidEncoding;

    assert TileNumericValueClass(TileDataType_S8,
        Zeros{PTO_XLEN} + 0x80) == NumericValue_NegativeNormal;
    assert TileNumericValueClass(TileDataType_U8,
        Zeros{PTO_XLEN} + 0xff) == NumericValue_PositiveNormal;
    assert TileNumericValueClass(TileDataType_U8, Zeros{PTO_XLEN}) ==
        NumericValue_PositiveZero;
    return 0;
end;
