// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-MOVI-MATERIALIZE-001","source":"asl/scalar/alu/C.MOVI.asl","requirements":["PTO-INST-SCALAR-C-MOVI"],"kind":"execution","summary":"C.MOVI applies its assigned materialization or extension rule","pass_condition":"Decoded execution and the mnemonic result contract agree on the boundary value","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();

    var instruction: bits(48) = Zeros{48} + 0x0016;
    instruction[15:11] = Zeros{5} + 2;
    instruction[10:6] = Zeros{5} + 16;
    let execution = ExecuteScalarInstruction(instruction, 16);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xfffffffffffffff0;
    assert InstructionContractResult_C_MOVI(Zeros{5} + 16) == Zeros{PTO_XLEN} + 0xfffffffffffffff0;
    return 0;
end;
