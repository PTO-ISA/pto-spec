// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPDIF-PIPELINE-001","source":"asl/tile/model/execution/expdif.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001"],"kind":"execution","summary":"TEXPDIF uses typed SUB then natural EXP and exact widening before FP32 SUB for mixed pairs","pass_condition":"all five typed pairs produce profile results and mixed discriminators equal widen-first vectors, distinct from source-precision subtraction vectors","related_sources":["asl/tile/model/execution/expansion.asl","asl/tile/model/execution/unary.asl","asl/tile/model/execution/elementwise.asl"]}
func ExpectedTexdifSameType(data_type: TileDataType,
                            left: Word, right: Word) => (Word, bits(5))
begin
    let (difference, subtract_flags) = TileProfileBinaryWithFlags(
        TileBinary_SUB, data_type, left, right);
    let (handled, special_result, special_flags) =
        TileSFUUnarySpecialValue(TileUnary_EXP, data_type, difference);
    if handled then
        return (special_result, subtract_flags OR special_flags);
    end;
    let (result, exp_flags) = TileProfileUnary(
        TileUnary_EXP, data_type, difference);
    return (result, subtract_flags OR exp_flags);
end;

func main() => integer
begin
    ResetProfileState();
    let (fp16_same, fp16_same_flags) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP16, TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x3c00, Zeros{PTO_XLEN});
    let (fp16_expected, fp16_flags) = ExpectedTexdifSameType(
        TileDataType_FP16, Zeros{PTO_XLEN} + 0x3c00, Zeros{PTO_XLEN});
    assert fp16_same == fp16_expected;
    assert fp16_same_flags == fp16_flags;

    let (bf16_same, bf16_same_flags) = TileExpdifValueWithTypesAndFlags(
        TileDataType_BF16, TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x3f80, Zeros{PTO_XLEN});
    let (bf16_expected, bf16_flags) = ExpectedTexdifSameType(
        TileDataType_BF16, Zeros{PTO_XLEN} + 0x3f80, Zeros{PTO_XLEN});
    assert bf16_same == bf16_expected;
    assert bf16_same_flags == bf16_flags;

    let (fp32_same, fp32_same_flags) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP32, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3f800000, Zeros{PTO_XLEN});
    let (fp32_expected, fp32_flags) = ExpectedTexdifSameType(
        TileDataType_FP32, Zeros{PTO_XLEN} + 0x3f800000, Zeros{PTO_XLEN});
    assert fp32_same == fp32_expected;
    assert fp32_same_flags == fp32_flags;

    let (fp16_mixed, fp16_mixed_flags) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP16, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x2000, Zeros{PTO_XLEN} + 0x0001);
    assert fp16_mixed == Zeros{PTO_XLEN} + 0x3f810100;
    assert fp16_mixed != Zeros{PTO_XLEN} + 0x3f810101;

    let (bf16_mixed, bf16_mixed_flags) = TileExpdifValueWithTypesAndFlags(
        TileDataType_BF16, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3f80, Zeros{PTO_XLEN} + 0x3b00);
    assert bf16_mixed == Zeros{PTO_XLEN} + 0x402da16e;
    assert bf16_mixed != Zeros{PTO_XLEN} + 0x402df854;
    assert fp16_mixed_flags == Zeros{5};
    assert bf16_mixed_flags == Zeros{5};
    return 0;
end;
