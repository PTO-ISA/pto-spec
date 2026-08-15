// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-CCATW-SHIFT-001","source":"asl/scalar/alu/HL.CCATW.asl","requirements":["PTO-INST-SCALAR-HL-CCATW"],"kind":"execution","summary":"HL.CCATW applies the audited logical-right concatenation shift","pass_condition":"both ordered results and mnemonic pure contracts match the selected boundary shift","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x80000001);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x7fffffff);
    var instruction: bits(48) = Zeros{48} + 0x0000205d000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[15:11] = Zeros{5} + 4;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 2;
    instruction[47:41] = Zeros{7} + 0;
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x7fffffff;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0xffffffff80000001;
    assert InstructionContractLowResult_HL_CCATW(Zeros{PTO_XLEN} + 0x80000001, Zeros{PTO_XLEN} + 0x7fffffff, 0) == Zeros{PTO_XLEN} + 0x7fffffff;
    assert InstructionContractHighResult_HL_CCATW(Zeros{PTO_XLEN} + 0x80000001, Zeros{PTO_XLEN} + 0x7fffffff, 0) == Zeros{PTO_XLEN} + 0xffffffff80000001;
    return 0;
end;
