// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-TILE-UNARY-005","source":"asl/arch/profile/reference-conversion.asl","requirements":[],"kind":"execution","summary":"the reference Tile SFU profile computes deterministic FP32 and FP16 finite unary results","pass_condition":"EXP, LOG, RECIP, SQRT, and RSQRT match independent host encodings for 0.1","related_sources":["asl/arch/profile/reference-profile.asl","asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    let fp32_tenth = Zeros{PTO_XLEN} + 0x3dcccccd;
    let fp16_tenth = Zeros{PTO_XLEN} + 0x2e66;

    let (fp32_exp, -) = ReferenceTileUnaryFinite(
        TileUnary_EXP, TileDataType_FP32, fp32_tenth);
    let (fp32_log, -) = ReferenceTileUnaryFinite(
        TileUnary_LOG, TileDataType_FP32, fp32_tenth);
    let (fp32_recip, -) = ReferenceTileUnaryFinite(
        TileUnary_RECIP, TileDataType_FP32, fp32_tenth);
    let (fp32_sqrt, -) = ReferenceTileUnaryFinite(
        TileUnary_SQRT, TileDataType_FP32, fp32_tenth);
    let (fp32_rsqrt, -) = ReferenceTileUnaryFinite(
        TileUnary_RSQRT, TileDataType_FP32, fp32_tenth);
    assert fp32_exp == Zeros{PTO_XLEN} + 0x3f8d763e;
    assert fp32_log == Zeros{PTO_XLEN} + 0xc0135d8e;
    assert fp32_recip == Zeros{PTO_XLEN} + 0x41200000;
    assert fp32_sqrt == Zeros{PTO_XLEN} + 0x3ea1e89b;
    assert fp32_rsqrt == Zeros{PTO_XLEN} + 0x404a62c2;

    let (fp16_exp, -) = ReferenceTileUnaryFinite(
        TileUnary_EXP, TileDataType_FP16, fp16_tenth);
    let (fp16_log, -) = ReferenceTileUnaryFinite(
        TileUnary_LOG, TileDataType_FP16, fp16_tenth);
    let (fp16_recip, -) = ReferenceTileUnaryFinite(
        TileUnary_RECIP, TileDataType_FP16, fp16_tenth);
    let (fp16_sqrt, -) = ReferenceTileUnaryFinite(
        TileUnary_SQRT, TileDataType_FP16, fp16_tenth);
    let (fp16_rsqrt, -) = ReferenceTileUnaryFinite(
        TileUnary_RSQRT, TileDataType_FP16, fp16_tenth);
    assert fp16_exp == Zeros{PTO_XLEN} + 0x3c6c;
    assert fp16_log == Zeros{PTO_XLEN} + 0xc09b;
    assert fp16_recip == Zeros{PTO_XLEN} + 0x4900;
    assert fp16_sqrt == Zeros{PTO_XLEN} + 0x350f;
    assert fp16_rsqrt == Zeros{PTO_XLEN} + 0x4253;
    return 0;
end;
