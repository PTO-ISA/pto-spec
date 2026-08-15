// PTO-TEST: {"id":"PTO-AVS-SCALAR-REM-TOTALITY-001","source":"asl/scalar/alu/REM.asl","requirements":["PTO-INST-SCALAR-REM"],"kind":"execution","summary":"REM executes its assigned fixed-width division totality rules","pass_condition":"Decoded execution and the mnemonic result contract agree on a representative result","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let dividend: Word = Zeros{PTO_XLEN} - 7;
    let divisor: Word = Zeros{PTO_XLEN} + 3;
    WriteGPR(1, dividend);
    WriteGPR(2, divisor);
    var instruction: bits(48) = Zeros{48} + 0x00004057;
    instruction[11:7] = Zeros{5} + 3;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;
    let execution = ExecuteScalarInstruction(instruction, 32);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(3) == Ones{PTO_XLEN};
    assert InstructionContractResult_REM(dividend, divisor) == Ones{PTO_XLEN};
    return 0;
end;
