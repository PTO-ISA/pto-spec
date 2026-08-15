// PTO-TEST: {"id":"PTO-AVS-SCALAR-LUI-MATERIALIZE-001","source":"asl/scalar/alu/LUI.asl","requirements":["PTO-INST-SCALAR-LUI"],"kind":"execution","summary":"LUI applies its assigned materialization or extension rule","pass_condition":"Decoded execution and the mnemonic result contract agree on the boundary value","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();

    var instruction: bits(48) = Zeros{48} + 0x00000017;
    instruction[11:7] = Zeros{5} + 2;
    instruction[31:12] = Zeros{20} + 0x80000;
    let execution = ExecuteScalarInstruction(instruction, 32);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xffffffff80000000;
    assert InstructionContractResult_LUI(Zeros{20} + 0x80000) == Zeros{PTO_XLEN} + 0xffffffff80000000;
    return 0;
end;
