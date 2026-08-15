// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-MADD-ACCUMULATE-001","source":"asl/scalar/alu/HL.MADD.asl","requirements":["PTO-INST-SCALAR-HL-MADD"],"kind":"execution","summary":"HL.MADD publishes low then high halves of its full accumulated product","pass_condition":"Decoded pair results match the mnemonic low and high accumulator contracts","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let addend: Word = Zeros{PTO_XLEN} + 5;
    let left: Word = Zeros{PTO_XLEN} + 3;
    let right: Word = Zeros{PTO_XLEN} + 4;
    WriteGPR(1, addend);
    WriteGPR(2, left);
    WriteGPR(3, right);
    var instruction: bits(48) = Zeros{48} + 0x00006047000e;
    instruction[27:23] = Zeros{5} + 4;
    instruction[15:11] = Zeros{5} + 5;
    instruction[47:43] = Zeros{5} + 1;
    instruction[35:31] = Zeros{5} + 2;
    instruction[40:36] = Zeros{5} + 3;
    let execution = ExecuteScalarInstruction(instruction, 48);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 17;
    assert ReadGPR(5) == Zeros{PTO_XLEN};
    assert InstructionContractLow_HL_MADD(addend, left, right) == Zeros{PTO_XLEN} + 17;
    assert InstructionContractHigh_HL_MADD(addend, left, right) == Zeros{PTO_XLEN};
    return 0;
end;
