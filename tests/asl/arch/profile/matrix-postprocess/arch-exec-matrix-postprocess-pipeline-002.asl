// PTO-TEST: {"id":"PTO-AVS-ARCH-MATRIX-POSTPROCESS-PIPELINE-002","source":"asl/arch/profile/matrix-postprocess.asl","requirements":["PTO-MATRIX-POSTPROCESS-BITEXACT-001"],"kind":"execution","summary":"Matrix activation selects the negative-path multiplier before destination conversion","pass_condition":"an FP32 value at a double-rounding boundary produces the single-round FP16 result and exact flags","related_sources":["asl/arch/profile/matrix-quantization.asl","asl/block/attributes/B.FPATR.asl"]}
func main() => integer
begin
    let scale_one = MatrixQuantParameter(
        FP32ToFP19(Zeros{PTO_XLEN} + 0x3f800000),
        Zeros{PTO_XLEN}, 0);
    let alpha_three_quarters = ZeroExtend{PTO_XLEN}(
        FP32ToFP19(Zeros{PTO_XLEN} + 0x3f400000));
    let (result, flags) = TileProfileMatrixPostProcessWithFlags(
        Zeros{PTO_XLEN} + 0xbf000bb0,
        '100000', '010', Zeros{4}, TileDataType_FP16,
        scale_one, alpha_three_quarters,
        DefaultNumericExecutionControl());
    assert result == Zeros{PTO_XLEN} + 0xb601;
    assert flags == Zeros{5} + 0x10;
    return 0;
end;
