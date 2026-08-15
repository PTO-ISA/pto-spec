// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-MULU-PRODUCT-001","source":"asl/scalar/alu/HL.MULU.asl","requirements":["PTO-INST-SCALAR-HL-MULU"],"kind":"execution","summary":"HL.MULU publishes low then high halves of its full product","pass_condition":"Decoded pair results match the mnemonic low and high product contracts","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left: Word = Ones{PTO_XLEN};
    let right: Word = Zeros{PTO_XLEN} + 2;
    WriteGPR(1, left);
    WriteGPR(2, right);
    var instruction: bits(48) = Zeros{48} + 0x00001047000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[15:11] = Zeros{5} + 4;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 2;
    let execution = ExecuteScalarInstruction(instruction, 48);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0xfffffffffffffffe;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 1;
    assert InstructionContractLow_HL_MULU(left, right) == Zeros{PTO_XLEN} + 0xfffffffffffffffe;
    assert InstructionContractHigh_HL_MULU(left, right) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
