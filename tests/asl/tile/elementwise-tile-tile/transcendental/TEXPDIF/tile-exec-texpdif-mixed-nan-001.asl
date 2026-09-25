// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPDIF-MIXED-NAN-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001"],"kind":"execution","summary":"Mixed FP16-to-FP32 TEXPDIF preserves signaling NaN status through exact widening","pass_condition":"A signaling NaN in either source sets invalid while a quiet NaN does not; all produce the canonical FP32 quiet NaN","related_sources":["asl/tile/model/execution/expdif.asl","asl/scalar/model/fsu/reference-quantization.asl"]}
func main() => integer
begin
    let (left_signaling, left_flags) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP16, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7c01, Zeros{PTO_XLEN} + 0x3c00);
    let (right_signaling, right_flags) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP16, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3c00, Zeros{PTO_XLEN} + 0x7c01);
    let (quiet, quiet_flags) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP16, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7e01, Zeros{PTO_XLEN} + 0x3c00);
    assert left_signaling[31:0] == Zeros{32} + 0x7fc00000;
    assert right_signaling[31:0] == Zeros{32} + 0x7fc00000;
    assert quiet[31:0] == Zeros{32} + 0x7fc00000;
    assert left_flags == Zeros{5} + 1;
    assert right_flags == Zeros{5} + 1;
    assert quiet_flags == Zeros{5};
    return 0;
end;
