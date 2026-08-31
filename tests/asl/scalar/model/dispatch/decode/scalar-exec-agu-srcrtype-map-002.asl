// PTO-TEST: {"id":"PTO-AVS-SCALAR-AGU-SRCRTYPE-MAP-002","source":"asl/scalar/model/dispatch/decode.asl","requirements":["PTO-REQ-AGU-SRCRTYPE-001"],"kind":"execution","summary":"AGU SrcRType uses the LinxISA arithmetic modifier encoding.","pass_condition":"00 sign-extends, 01 zero-extends, 10 negates, and 11 preserves the complete register offset.","related_sources":["asl/scalar/model/dispatch/agu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    let word_value = Zeros{PTO_XLEN} + 0x80000000;
    let full_value = Zeros{PTO_XLEN} + 0x100000001;

    assert DecodeScalarAddressRightModifier('00') ==
        ScalarRight_SignedWord;
    assert DecodeScalarAddressRightModifier('01') ==
        ScalarRight_UnsignedWord;
    assert DecodeScalarAddressRightModifier('10') ==
        ScalarRight_NegateOrNot;
    assert DecodeScalarAddressRightModifier('11') == ScalarRight_None;

    assert ApplyScalarRightModifier(
        word_value, DecodeScalarAddressRightModifier('00'), FALSE) ==
        Zeros{PTO_XLEN} + 0xffffffff80000000;
    assert ApplyScalarRightModifier(
        word_value, DecodeScalarAddressRightModifier('01'), FALSE) ==
        Zeros{PTO_XLEN} + 0x80000000;
    assert ApplyScalarRightModifier(
        Zeros{PTO_XLEN} + 5,
        DecodeScalarAddressRightModifier('10'), FALSE) ==
        Ones{PTO_XLEN} - 4;
    assert ApplyScalarRightModifier(
        full_value, DecodeScalarAddressRightModifier('11'), FALSE) ==
        full_value;
    return 0;
end;
