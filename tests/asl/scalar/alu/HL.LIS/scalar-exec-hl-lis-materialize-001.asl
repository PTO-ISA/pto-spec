// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-LIS-MATERIALIZE-001","source":"asl/scalar/alu/HL.LIS.asl","requirements":["PTO-INST-SCALAR-HL-LIS"],"kind":"execution","summary":"HL.LIS applies its assigned materialization or extension rule","pass_condition":"Decoded execution and the mnemonic result contract agree on the boundary value","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();

    var instruction: bits(48) = Zeros{48} + 0x0000000d000e;
    instruction[27:23] = Zeros{5} + 2;
    instruction[47:28] = Zeros{20};
    instruction[15:4] = Zeros{12} + 0x800;
    let execution = ExecuteScalarInstruction(instruction, 48);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xffffffff80000000;
    assert InstructionContractResult_HL_LIS(Zeros{32} + 0x80000000) == Zeros{PTO_XLEN} + 0xffffffff80000000;
    return 0;
end;
