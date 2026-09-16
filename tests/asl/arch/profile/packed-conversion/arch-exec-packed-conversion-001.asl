// PTO-TEST: {"id":"PTO-AVS-ARCH-PACKED-CONVERSION-EXECUTION-001","source":"asl/arch/profile/packed-conversion.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"execution","summary":"Reference encoders implement packed FP4 and E6M2 rounding boundaries","pass_condition":"FP4 midpoint, underflow, overflow, and E6M2 exact, underflow, and positive-overflow cases return the frozen encodings and flags","related_sources":["asl/arch/data-types/formats/e2m1x2.asl","asl/arch/data-types/formats/e6m2.asl"]}
func main() => integer
begin
    let control = DefaultNumericExecutionControl();
    let (e2_midpoint, e2_midpoint_flags) = ReferencePacked4Encoding(
        0.25, TileDataType_E2M1X2, control);
    assert e2_midpoint == Zeros{PTO_XLEN};
    assert e2_midpoint_flags == Zeros{5} + 0x18;

    let (e2_overflow, e2_overflow_flags) = ReferencePacked4Encoding(
        7.0, TileDataType_E2M1X2, control);
    assert e2_overflow == Zeros{PTO_XLEN} + 6;
    assert e2_overflow_flags == Zeros{5} + 0x14;

    let (e1_midpoint, e1_midpoint_flags) = ReferencePacked4Encoding(
        0.375, TileDataType_E1M2X2, control);
    assert e1_midpoint == Zeros{PTO_XLEN} + 2;
    assert e1_midpoint_flags == Zeros{5} + 0x10;

    let (e6_exact, e6_exact_flags) = ReferenceE6M2Encoding(
        1.25, control);
    assert e6_exact == Zeros{PTO_XLEN} + 0xc1;
    assert e6_exact_flags == Zeros{5};

    let (e6_minimum, e6_minimum_flags) = ReferenceE6M2Encoding(
        FP19PowerOfTwo(-48), control);
    assert e6_minimum == Zeros{PTO_XLEN};
    assert e6_minimum_flags == Zeros{5};

    let (e6_tiny, e6_tiny_flags) = ReferenceE6M2Encoding(
        0.5 * FP19PowerOfTwo(-48), control);
    assert e6_tiny == Zeros{PTO_XLEN};
    assert e6_tiny_flags == Zeros{5} + 0x18;

    let (e6_overflow, e6_overflow_flags) = ReferenceE6M2Encoding(
        49153.0, control);
    assert e6_overflow == Zeros{PTO_XLEN} + 0xff;
    assert e6_overflow_flags == Zeros{5} + 0x14;
    return 0;
end;
