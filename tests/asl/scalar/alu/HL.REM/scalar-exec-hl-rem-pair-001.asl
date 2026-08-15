// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-REM-PAIR-001","source":"asl/scalar/alu/HL.REM.asl","requirements":["PTO-INST-SCALAR-HL-REM"],"kind":"execution","summary":"HL.REM publishes quotient then remainder from source snapshots","pass_condition":"Decoded pair results match the mnemonic quotient and remainder contracts in destination order","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let dividend: Word = Zeros{PTO_XLEN} - 7;
    let divisor: Word = Zeros{PTO_XLEN} + 3;
    WriteGPR(1, dividend);
    WriteGPR(2, divisor);
    var instruction: bits(48) = Zeros{48} + 0x00004057000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[15:11] = Zeros{5} + 4;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 2;
    let execution = ExecuteScalarInstruction(instruction, 48);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} - 2;
    assert ReadGPR(4) == Ones{PTO_XLEN};
    assert InstructionContractQuotient_HL_REM(dividend, divisor) == Zeros{PTO_XLEN} - 2;
    assert InstructionContractRemainder_HL_REM(dividend, divisor) == Ones{PTO_XLEN};
    return 0;
end;
