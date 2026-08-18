// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-MADDW-ACCUMULATE-001","source":"asl/scalar/alu/HL.MADDW.asl","requirements":["PTO-INST-SCALAR-HL-MADDW"],"kind":"execution","summary":"HL.MADDW publishes sign-extended low and high word halves from its 64-bit result","pass_condition":"Decoded Dst0 and Dst1 match the mnemonic low-word and high-word contracts","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let addend: Word = Zeros{PTO_XLEN} + 0xffffffff;
    let left: Word = Zeros{PTO_XLEN} + 0xfffffffe;
    let right: Word = Zeros{PTO_XLEN} + 3;
    WriteGPR(1, addend);
    WriteGPR(2, left);
    WriteGPR(3, right);
    var instruction: bits(48) = Zeros{48} + 0x00007047000e;
    instruction[27:23] = Zeros{5} + 4;
    instruction[15:11] = Zeros{5} + 5;
    instruction[47:43] = Zeros{5} + 1;
    instruction[35:31] = Zeros{5} + 2;
    instruction[40:36] = Zeros{5} + 3;
    let execution = ExecuteScalarInstruction(instruction, 48);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0xfffffffffffffff9;
    assert ReadGPR(5) == Ones{PTO_XLEN};
    assert InstructionContractLow_HL_MADDW(addend, left, right) == Zeros{PTO_XLEN} + 0xfffffffffffffff9;
    assert InstructionContractHigh_HL_MADDW(addend, left, right) == Ones{PTO_XLEN};
    return 0;
end;
