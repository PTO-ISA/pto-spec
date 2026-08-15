// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-SEXT-W-MATERIALIZE-001","source":"asl/scalar/alu/C.SEXT.W.asl","requirements":["PTO-INST-SCALAR-C-SEXT-W"],"kind":"execution","summary":"C.SEXT.W applies its assigned materialization or extension rule","pass_condition":"Decoded execution and the mnemonic result contract agree on the boundary value","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x80000000);
    var instruction: bits(48) = Zeros{48} + 0x501c;
    instruction[10:6] = Zeros{5} + 24;
    let execution = ExecuteScalarInstruction(instruction, 16);
    assert execution == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0xffffffff80000000;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 0x80000000;
    assert InstructionContractResult_C_SEXT_W(Zeros{PTO_XLEN} + 0x80000000) == Zeros{PTO_XLEN} + 0xffffffff80000000;
    return 0;
end;
