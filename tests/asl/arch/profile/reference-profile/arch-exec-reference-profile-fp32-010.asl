// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-PROFILE-FP32-010","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"the reference profile computes finite FP32 arithmetic and unary results from IEEE carriers","pass_condition":"add, subtract, multiply, divide, square-root, and reciprocal carriers match independently fixed FP32 encodings","related_sources":["asl/arch/profile/reference-quantization.asl"]}
func main() => integer
begin
    let one_point_five = Zeros{PTO_XLEN} + 0x3fc00000;
    let two_point_two_five = Zeros{PTO_XLEN} + 0x40100000;
    let four = Zeros{PTO_XLEN} + 0x40800000;

    let (sum, sum_flags) = ScalarFPBinaryProfile(
        FloatingBinary_ADD, NumericRound_RNE, Zeros{5} + 1,
        one_point_five, two_point_two_five);
    let (difference, difference_flags) = ScalarFPBinaryProfile(
        FloatingBinary_SUB, NumericRound_RNE, Zeros{5} + 1,
        one_point_five, two_point_two_five);
    let (product, product_flags) = ScalarFPBinaryProfile(
        FloatingBinary_MUL, NumericRound_RNE, Zeros{5} + 1,
        one_point_five, two_point_two_five);
    let (quotient, quotient_flags) = ScalarFPBinaryProfile(
        FloatingBinary_DIV, NumericRound_RNE, Zeros{5} + 1,
        one_point_five, two_point_two_five);
    let (root, root_flags) = ScalarFPUnaryProfile(
        FloatingUnary_SQRT, NumericRound_RNE, Zeros{5} + 1, four);
    let (reciprocal, reciprocal_flags) = ScalarFPUnaryProfile(
        FloatingUnary_RECIP, NumericRound_RNE, Zeros{5} + 1, four);

    assert sum == Zeros{PTO_XLEN} + 0x40700000;
    assert difference == Zeros{PTO_XLEN} + 0xbf400000;
    assert product == Zeros{PTO_XLEN} + 0x40580000;
    assert quotient == Zeros{PTO_XLEN} + 0x3f2aaaab;
    assert root == Zeros{PTO_XLEN} + 0x40000000;
    assert reciprocal == Zeros{PTO_XLEN} + 0x3e800000;
    assert sum_flags == Zeros{5};
    assert difference_flags == Zeros{5};
    assert product_flags == Zeros{5};
    assert quotient_flags == Zeros{5} + 0x10;
    assert root_flags == Zeros{5};
    assert reciprocal_flags == Zeros{5};
    return 0;
end;
