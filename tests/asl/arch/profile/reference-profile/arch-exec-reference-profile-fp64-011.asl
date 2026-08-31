// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-PROFILE-FP64-011","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"the reference profile computes finite FP64 arithmetic and unary results from IEEE carriers","pass_condition":"add, subtract, multiply, divide, square-root, and reciprocal carriers match independently fixed FP64 encodings","related_sources":["asl/arch/profile/reference-quantization.asl"]}
func main() => integer
begin
    let one_point_five = Zeros{PTO_XLEN} + 0x3ff8000000000000;
    let two_point_two_five = Zeros{PTO_XLEN} + 0x4002000000000000;
    let four = Zeros{PTO_XLEN} + 0x4010000000000000;

    let (sum, sum_flags) = ScalarFPBinaryProfile(
        FloatingBinary_ADD, NumericRound_RNE, Zeros{5},
        one_point_five, two_point_two_five);
    let (difference, difference_flags) = ScalarFPBinaryProfile(
        FloatingBinary_SUB, NumericRound_RNE, Zeros{5},
        one_point_five, two_point_two_five);
    let (product, product_flags) = ScalarFPBinaryProfile(
        FloatingBinary_MUL, NumericRound_RNE, Zeros{5},
        one_point_five, two_point_two_five);
    let (quotient, quotient_flags) = ScalarFPBinaryProfile(
        FloatingBinary_DIV, NumericRound_RNE, Zeros{5},
        one_point_five, two_point_two_five);
    let (root, root_flags) = ScalarFPUnaryProfile(
        FloatingUnary_SQRT, NumericRound_RNE, Zeros{5}, four);
    let (reciprocal, reciprocal_flags) = ScalarFPUnaryProfile(
        FloatingUnary_RECIP, NumericRound_RNE, Zeros{5}, four);

    assert sum == Zeros{PTO_XLEN} + 0x400e000000000000;
    assert difference == Zeros{PTO_XLEN} + 0xbfe8000000000000;
    assert product == Zeros{PTO_XLEN} + 0x400b000000000000;
    assert quotient == Zeros{PTO_XLEN} + 0x3fe5555555555555;
    assert root == Zeros{PTO_XLEN} + 0x4000000000000000;
    assert reciprocal == Zeros{PTO_XLEN} + 0x3fd0000000000000;
    assert sum_flags == Zeros{5};
    assert difference_flags == Zeros{5};
    assert product_flags == Zeros{5};
    assert quotient_flags == Zeros{5} + 0x10;
    assert root_flags == Zeros{5};
    assert reciprocal_flags == Zeros{5};
    return 0;
end;
