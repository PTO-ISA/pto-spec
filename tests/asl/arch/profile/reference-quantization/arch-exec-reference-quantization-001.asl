// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-QUANTIZATION-001","source":"asl/arch/profile/reference-quantization.asl","requirements":[],"kind":"execution","summary":"The reference quantization profile converts representative FP32 and integer values without changing their encodings","pass_condition":"FP32 one and two decode exactly, FP32 one re-encodes exactly with no flags, and signed integer normalization preserves minus one","related_sources":["asl/arch/profile/reference-profile.asl","asl/tile/model/numeric/formats.asl"]}
func main() => integer
begin
    assert ReferenceFP32FiniteValue(Zeros{32} + 0x3f800000) == 1.0;
    assert ReferenceFP32FiniteValue(Zeros{32} + 0x40000000) == 2.0;
    assert ReferenceIntegerValue(
        Zeros{PTO_XLEN} + 0xff,
        TileDataType_S8) == -1;

    let (encoded_one, flags) = ReferenceFP32FiniteEncoding(
        1.0,
        NumericRound_RNE);
    assert encoded_one == Zeros{PTO_XLEN} + 0x3f800000;
    assert flags == Zeros{5};
    return 0;
end;
