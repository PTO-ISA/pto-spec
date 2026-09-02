// PTO-TEST: {"id":"PTO-AVS-SCALAR-AGU-SRCRTYPE-MAP-002","source":"asl/scalar/model/dispatch/decode.asl","requirements":["PTO-REQ-AGU-SRCRTYPE-001"],"kind":"execution","summary":"AGU SrcRType keeps its address-specific modifier mapping and rejects raw code 11.","pass_condition":"00 preserves the complete offset, 01 sign-extends, 10 zero-extends, and 11 rejects before effects.","related_sources":["asl/scalar/model/dispatch/agu.asl","asl/scalar/model/dispatch/top-level.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    let word_value = Zeros{PTO_XLEN} + 0x80000000;
    let full_value = Zeros{PTO_XLEN} + 0x100000001;

    assert DecodeScalarAddressRightModifier('00') == ScalarRight_None;
    assert DecodeScalarAddressRightModifier('01') ==
        ScalarRight_SignedWord;
    assert DecodeScalarAddressRightModifier('10') ==
        ScalarRight_UnsignedWord;

    assert ApplyScalarRightModifier(
        full_value, DecodeScalarAddressRightModifier('00'), FALSE) ==
        full_value;
    assert ApplyScalarRightModifier(
        word_value, DecodeScalarAddressRightModifier('01'), FALSE) ==
        Zeros{PTO_XLEN} + 0xffffffff80000000;
    assert ApplyScalarRightModifier(
        word_value, DecodeScalarAddressRightModifier('10'), FALSE) ==
        Zeros{PTO_XLEN} + 0x80000000;

    let reserved_instruction = Zeros{48} + 0x06007009;
    assert DecodeScalarForm(reserved_instruction, 32) == 370;
    assert !ScalarFormOperandsLegal(reserved_instruction, 370);
    ResetProfileState();
    let status = ExecuteScalarInstruction(reserved_instruction, 32);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    return 0;
end;
