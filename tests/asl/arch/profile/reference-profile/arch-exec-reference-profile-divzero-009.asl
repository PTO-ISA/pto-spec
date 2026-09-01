// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-PROFILE-DIVZERO-009","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"the reference scalar FP division branch returns signed infinity and divide-by-zero status","pass_condition":"a finite nonzero FP64 dividend divided by positive zero returns positive infinity with DZ","related_sources":["asl/scalar/fsu/FDIV.asl"]}
func main() => integer
begin
    let (result, status) = ScalarFPBinaryProfile(
        FloatingBinary_DIV,
        NumericRound_RNE,
        Zeros{5},
        Zeros{PTO_XLEN} + 7,
        Zeros{PTO_XLEN});

    assert result == Zeros{PTO_XLEN} + 0x7ff0000000000000;
    assert status == Zeros{5} + 2;
    return 0;
end;
