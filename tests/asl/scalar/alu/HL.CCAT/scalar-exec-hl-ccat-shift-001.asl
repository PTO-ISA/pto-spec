// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-CCAT-SHIFT-001","source":"asl/scalar/alu/HL.CCAT.asl","requirements":["PTO-INST-SCALAR-HL-CCAT"],"kind":"execution","summary":"HL.CCAT applies the audited logical-right concatenation shift","pass_condition":"both ordered results and mnemonic pure contracts match the selected boundary shift","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x0123456789abcdef);
    WriteGPR(2, Zeros{PTO_XLEN} + 0xfedcba9876543210);
    var instruction: bits(48) = Zeros{48} + 0x0000105d000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[15:11] = Zeros{5} + 4;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 2;
    instruction[47:41] = Zeros{7} + 64;
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x0123456789abcdef;
    assert ReadGPR(4) == Zeros{PTO_XLEN};
    assert InstructionContractLowResult_HL_CCAT(Zeros{PTO_XLEN} + 0x0123456789abcdef, Zeros{PTO_XLEN} + 0xfedcba9876543210, 64) == Zeros{PTO_XLEN} + 0x0123456789abcdef;
    assert InstructionContractHighResult_HL_CCAT(Zeros{PTO_XLEN} + 0x0123456789abcdef, Zeros{PTO_XLEN} + 0xfedcba9876543210, 64) == Zeros{PTO_XLEN};
    return 0;
end;
