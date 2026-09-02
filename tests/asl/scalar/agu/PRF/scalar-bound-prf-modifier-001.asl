// PTO-UNIT: {"id":"PTO-TEST-SCALAR-PRF-MODIFIER-001","surface":"scalar","classification":["agu","PRF","scalar-bound-prf-modifier-001"],"depends_on":["PTO-SCALAR-PRF"]}
// PTO-TEST: {"id":"PTO-AVS-SCALAR-PRF-MODIFIER-001","source":"asl/scalar/agu/PRF.asl","requirements":["PTO-INST-SCALAR-PRF"],"kind":"boundary","summary":"PRF address formation preserves raw 00, sign-extends raw 01, zero-extends raw 10, and reserves raw 11","pass_condition":"the address-specific modifier decoder and PRF form legality match ADR-0029 and NDF clause PTO-REQ-AGU-SRCRTYPE-001","related_sources":["asl/scalar/model/dispatch/decode.asl","asl/scalar/model/dispatch/agu.asl"]}

func main() => integer
begin
    assert DecodeScalarAddressRightModifier('00') == ScalarRight_None;
    assert DecodeScalarAddressRightModifier('01') == ScalarRight_SignedWord;
    assert DecodeScalarAddressRightModifier('10') == ScalarRight_UnsignedWord;
    assert ScalarFormOperandsLegal(Zeros{48} + 0x00007009, 370);
    assert ScalarFormOperandsLegal(Zeros{48} + 0x02007009, 370);
    assert ScalarFormOperandsLegal(Zeros{48} + 0x04007009, 370);
    assert !ScalarFormOperandsLegal(Zeros{48} + 0x06007009, 370);
    return 0;
end;
