// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-PROFILE-DIVZERO-009","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"the reference scalar FP division branch returns the assigned zero-divisor result and five-bit status field","pass_condition":"a zero right carrier returns all-one result bits and status Zeros{5}+2","related_sources":[]}
func main() => integer
begin
    let (result, status) = ScalarFPBinaryProfile(
        FloatingBinary_DIV,
        NumericRound_RNE,
        Zeros{5},
        Zeros{PTO_XLEN} + 7,
        Zeros{PTO_XLEN});

    assert result == Ones{PTO_XLEN};
    assert status == Zeros{5} + 2;
    return 0;
end;
