// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-MUL-PRODUCT-001","source":"asl/scalar/alu/HL.MUL.asl","requirements":["PTO-INST-SCALAR-HL-MUL"],"kind":"execution","summary":"HL.MUL publishes low then high halves of its full product","pass_condition":"Decoded pair results match the mnemonic low and high product contracts","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left: Word = Zeros{PTO_XLEN} - 2;
    let right: Word = Zeros{PTO_XLEN} + 3;
    WriteGPR(1, left);
    WriteGPR(2, right);
    var instruction: bits(48) = Zeros{48} + 0x00000047000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[15:11] = Zeros{5} + 4;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 2;
    let execution = ExecuteScalarInstruction(instruction, 48);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} - 6;
    assert ReadGPR(4) == Ones{PTO_XLEN};
    assert InstructionContractLow_HL_MUL(left, right) == Zeros{PTO_XLEN} - 6;
    assert InstructionContractHigh_HL_MUL(left, right) == Ones{PTO_XLEN};
    return 0;
end;
