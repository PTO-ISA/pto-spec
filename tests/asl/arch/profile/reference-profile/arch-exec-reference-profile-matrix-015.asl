// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-PROFILE-MATRIX-015","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"the reference profile performs ordinary floating Matrix accumulation and bias on numeric values rather than raw carrier integers","pass_condition":"FP32, FP16, and BF16 inputs accumulate into FP32 with per-operation rounding while integer inputs retain integer arithmetic","related_sources":["asl/tile/model/execution/cube.asl"]}
func main() => integer
begin
    let control = DefaultNumericExecutionControl();
    let fp32_one = Zeros{PTO_XLEN} + 0x3f800000;
    let fp32_one_point_five = Zeros{PTO_XLEN} + 0x3fc00000;
    let fp32_two = Zeros{PTO_XLEN} + 0x40000000;
    let fp32_four = Zeros{PTO_XLEN} + 0x40800000;
    let fp32_four_point_five = Zeros{PTO_XLEN} + 0x40900000;
    let fp16_one_point_five = Zeros{PTO_XLEN} + 0x3e00;
    let fp16_two = Zeros{PTO_XLEN} + 0x4000;
    let bf16_one_point_five = Zeros{PTO_XLEN} + 0x3fc0;
    let bf16_two = Zeros{PTO_XLEN} + 0x4000;

    let fp32_accumulate = TileProfileMatrixAccumulate(
        fp32_one, fp32_one_point_five, fp32_two,
        TileDataType_FP32, TileDataType_FP32, TileDataType_FP32,
        control);
    let fp16_accumulate = TileProfileMatrixAccumulate(
        fp32_one, fp16_one_point_five, fp16_two,
        TileDataType_FP32, TileDataType_FP16, TileDataType_FP16,
        control);
    let bf16_accumulate = TileProfileMatrixAccumulate(
        fp32_one, bf16_one_point_five, bf16_two,
        TileDataType_FP32, TileDataType_BF16, TileDataType_BF16,
        control);
    let matrix_bias = TileProfileMatrixBias(
        fp32_four, Zeros{PTO_XLEN} + 0x3f000000,
        TileDataType_FP32, TileDataType_FP32);
    let unscaled_mx = TileProfileMatrixScaledAccumulate(
        fp32_one, fp16_one_point_five, fp16_two,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, FALSE, FALSE,
        TileDataType_FP32, TileDataType_FP16, TileDataType_FP16,
        TileDataType_E8M0, TileDataType_E8M0);
    let integer_accumulate = TileProfileMatrixAccumulate(
        Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 3,
        TileDataType_S32, TileDataType_S8, TileDataType_S8,
        control);
    assert fp32_accumulate == fp32_four;
    assert fp16_accumulate == fp32_four;
    assert bf16_accumulate == fp32_four;
    assert matrix_bias == fp32_four_point_five;
    assert unscaled_mx == fp32_four;
    assert integer_accumulate == Zeros{PTO_XLEN} + 7;
    return 0;
end;
