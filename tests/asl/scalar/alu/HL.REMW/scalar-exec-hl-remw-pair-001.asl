// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-REMW-PAIR-001","source":"asl/scalar/alu/HL.REMW.asl","requirements":["PTO-INST-SCALAR-HL-REMW"],"kind":"execution","summary":"HL.REMW publishes quotient then remainder from source snapshots","pass_condition":"Decoded pair results match the mnemonic quotient and remainder contracts in destination order","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let dividend: Word = Zeros{PTO_XLEN} + 0xfffffff9;
    let divisor: Word = Zeros{PTO_XLEN} + 3;
    WriteGPR(1, dividend);
    WriteGPR(2, divisor);
    var instruction: bits(48) = Zeros{48} + 0x00006057000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[15:11] = Zeros{5} + 4;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 2;
    let execution = ExecuteScalarInstruction(instruction, 48);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} - 2;
    assert ReadGPR(4) == Ones{PTO_XLEN};
    assert InstructionContractQuotient_HL_REMW(dividend, divisor) == Zeros{PTO_XLEN} - 2;
    assert InstructionContractRemainder_HL_REMW(dividend, divisor) == Ones{PTO_XLEN};
    return 0;
end;
