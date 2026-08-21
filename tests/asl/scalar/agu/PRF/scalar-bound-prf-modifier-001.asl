// PTO-UNIT: {"id":"PTO-TEST-SCALAR-PRF-MODIFIER-001","surface":"scalar","classification":["agu","PRF","scalar-bound-prf-modifier-001"],"depends_on":["PTO-SCALAR-PRF"]}
// PTO-TEST: {"id":"PTO-AVS-SCALAR-PRF-MODIFIER-001","source":"asl/scalar/agu/PRF.asl","requirements":["PTO-INST-SCALAR-PRF"],"kind":"boundary","summary":"PRF address formation interprets raw modifier codes as full-width, signed-word, unsigned-word, and negated full-width","pass_condition":"the address-specific modifier decoder matches ADR 0029, ADR-0084, and NDF clause PTO-PRF-NONFAULTING-HINT-001","related_sources":["asl/scalar/model/dispatch/decode.asl","asl/scalar/model/dispatch/agu.asl"]}

func main() => integer
begin
    assert DecodeScalarAddressRightModifier('00') == ScalarRight_None;
    assert DecodeScalarAddressRightModifier('01') == ScalarRight_SignedWord;
    assert DecodeScalarAddressRightModifier('10') == ScalarRight_UnsignedWord;
    assert DecodeScalarAddressRightModifier('11') == ScalarRight_NegateOrNot;
    return 0;
end;
