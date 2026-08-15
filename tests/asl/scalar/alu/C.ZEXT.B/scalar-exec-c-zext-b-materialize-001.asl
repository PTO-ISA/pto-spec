// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-ZEXT-B-MATERIALIZE-001","source":"asl/scalar/alu/C.ZEXT.B.asl","requirements":["PTO-INST-SCALAR-C-ZEXT-B"],"kind":"execution","summary":"C.ZEXT.B applies its assigned materialization or extension rule","pass_condition":"Decoded execution and the mnemonic result contract agree on the boundary value","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x80);
    var instruction: bits(48) = Zeros{48} + 0x581c;
    instruction[10:6] = Zeros{5} + 24;
    let execution = ExecuteScalarInstruction(instruction, 16);
    assert execution == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x80;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 0x80;
    assert InstructionContractResult_C_ZEXT_B(Zeros{PTO_XLEN} + 0x80) == Zeros{PTO_XLEN} + 0x80;
    return 0;
end;
