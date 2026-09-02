// PTO-UNIT: {"id":"PTO-TEST-SCALAR-PRF-MODIFIER-001","surface":"scalar","classification":["agu","PRF","scalar-bound-prf-modifier-001"],"depends_on":["PTO-SCALAR-PRF"]}
// PTO-TEST: {"id":"PTO-AVS-SCALAR-PRF-MODIFIER-001","source":"asl/scalar/agu/PRF.asl","requirements":["PTO-INST-SCALAR-PRF"],"kind":"boundary","summary":"PRF address formation interprets raw modifier codes as signed-word, unsigned-word, negated full-width, and unchanged full-width","pass_condition":"the address-specific modifier decoder matches ADR-0029 and NDF clause PTO-REQ-AGU-SRCRTYPE-001","related_sources":["asl/scalar/model/dispatch/decode.asl","asl/scalar/model/dispatch/agu.asl"]}

func main() => integer
begin
    assert DecodeScalarAddressRightModifier('00') == ScalarRight_SignedWord;
    assert DecodeScalarAddressRightModifier('01') == ScalarRight_UnsignedWord;
    assert DecodeScalarAddressRightModifier('10') == ScalarRight_NegateOrNot;
    assert DecodeScalarAddressRightModifier('11') == ScalarRight_None;
    return 0;
end;
