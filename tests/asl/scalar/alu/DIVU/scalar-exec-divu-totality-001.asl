// PTO-TEST: {"id":"PTO-AVS-SCALAR-DIVU-TOTALITY-001","source":"asl/scalar/alu/DIVU.asl","requirements":["PTO-INST-SCALAR-DIVU"],"kind":"execution","summary":"DIVU executes its assigned fixed-width division totality rules","pass_condition":"Decoded execution and the mnemonic result contract agree on a representative result","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let dividend: Word = Zeros{PTO_XLEN} + 7;
    let divisor: Word = Zeros{PTO_XLEN} + 3;
    WriteGPR(1, dividend);
    WriteGPR(2, divisor);
    var instruction: bits(48) = Zeros{48} + 0x00001057;
    instruction[11:7] = Zeros{5} + 3;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;
    let execution = ExecuteScalarInstruction(instruction, 32);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 2;
    assert InstructionContractResult_DIVU(dividend, divisor) == Zeros{PTO_XLEN} + 2;
    return 0;
end;
