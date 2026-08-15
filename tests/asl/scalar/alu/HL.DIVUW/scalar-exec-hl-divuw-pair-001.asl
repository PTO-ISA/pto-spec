// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-DIVUW-PAIR-001","source":"asl/scalar/alu/HL.DIVUW.asl","requirements":["PTO-INST-SCALAR-HL-DIVUW"],"kind":"execution","summary":"HL.DIVUW publishes quotient then remainder from source snapshots","pass_condition":"Decoded pair results match the mnemonic quotient and remainder contracts in destination order","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let dividend: Word = Zeros{PTO_XLEN} + 0xffffffff;
    let divisor: Word = Zeros{PTO_XLEN} + 2;
    WriteGPR(1, dividend);
    WriteGPR(2, divisor);
    var instruction: bits(48) = Zeros{48} + 0x00003057000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[15:11] = Zeros{5} + 4;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 2;
    let execution = ExecuteScalarInstruction(instruction, 48);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x7fffffff;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 1;
    assert InstructionContractQuotient_HL_DIVUW(dividend, divisor) == Zeros{PTO_XLEN} + 0x7fffffff;
    assert InstructionContractRemainder_HL_DIVUW(dividend, divisor) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
