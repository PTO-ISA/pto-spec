// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-FIXED-BINARY-LOCAL64-001","source":"asl/tile/model/numeric/reference-fixed-binary.asl","requirements":["PTO-COMMON-CONVERSION-001","PTO-TCVT-CONTRACT-001"],"kind":"execution","summary":"the common conversion profile routes Local64 values through reduced floating formats","pass_condition":"exact FP64 and U64 value three converts to BF16, TF32, HF32, and E5M2 and each floating carrier converts back to exact FP64","related_sources":["asl/tile/model/numeric/reference-conversion.asl","asl/tile/model/numeric/formats.asl"]}
func main() => integer
begin
    let control = DefaultNumericExecutionControl();
    let fp64_three = Zeros{PTO_XLEN} + 0x4008000000000000;
    let (bf16, bf16_flags) = ReferenceCommonConvert(
        fp64_three, TileDataType_FP64, TileDataType_BF16, control);
    let (tf32, tf32_flags) = ReferenceCommonConvert(
        fp64_three, TileDataType_FP64, TileDataType_TF32, control);
    let (hf32, hf32_flags) = ReferenceCommonConvert(
        fp64_three, TileDataType_FP64, TileDataType_HF32, control);
    let (e5m2, e5m2_flags) = ReferenceCommonConvert(
        Zeros{PTO_XLEN} + 3,
        TileDataType_U64, TileDataType_E5M2, control);
    assert bf16 == Zeros{PTO_XLEN} + 0x4040;
    assert tf32 == Zeros{PTO_XLEN} + 0x40400000;
    assert hf32 == Zeros{PTO_XLEN} + 0x40400000;
    assert e5m2 == Zeros{PTO_XLEN} + 0x42;
    assert bf16_flags == Zeros{5};
    assert tf32_flags == Zeros{5};
    assert hf32_flags == Zeros{5};
    assert e5m2_flags == Zeros{5};

    let (from_bf16, -) = ReferenceCommonConvert(
        bf16, TileDataType_BF16, TileDataType_FP64, control);
    let (from_tf32, -) = ReferenceCommonConvert(
        tf32, TileDataType_TF32, TileDataType_FP64, control);
    let (from_hf32, -) = ReferenceCommonConvert(
        hf32, TileDataType_HF32, TileDataType_FP64, control);
    let (from_e5m2, -) = ReferenceCommonConvert(
        e5m2, TileDataType_E5M2, TileDataType_FP64, control);
    assert from_bf16 == fp64_three;
    assert from_tf32 == fp64_three;
    assert from_hf32 == fp64_three;
    assert from_e5m2 == fp64_three;
    return 0;
end;
