// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-ORDER-001","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-INST-TILE-TCMP"],"kind":"execution","summary":"TCMP distinguishes signed and unsigned ordering and reports signaling NaN","pass_condition":"the same high-bit byte orders differently for S8 and U8, signed zero compares equal, and signaling NaN returns false with NV","related_sources":["asl/tile/model/execution/comparison.asl","asl/arch/features/mx-formats.asl"]}
func main() => integer
begin
    let (signed_less, signed_flags) = TileCompareElement(
        TileComparison_LT,
        TileDataType_S8,
        Zeros{PTO_XLEN} + 0xff,
        Zeros{PTO_XLEN} + 1);
    let (unsigned_less, unsigned_flags) = TileCompareElement(
        TileComparison_LT,
        TileDataType_U8,
        Zeros{PTO_XLEN} + 0xff,
        Zeros{PTO_XLEN} + 1);
    let (zero_equal, zero_flags) = TileCompareElement(
        TileComparison_EQ,
        TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x80000000,
        Zeros{PTO_XLEN});
    let (nan_equal, nan_flags) = TileCompareElement(
        TileComparison_EQ,
        TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800001,
        Zeros{PTO_XLEN} + 0x3f800000);
    assert signed_less && signed_flags == Zeros{5};
    assert !unsigned_less && unsigned_flags == Zeros{5};
    assert zero_equal && zero_flags == Zeros{5};
    assert !nan_equal && nan_flags == Zeros{5} + 1;
    return 0;
end;
