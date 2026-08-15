// PTO-TEST: {"id":"PTO-AVS-SCALAR-MUL-PRODUCT-001","source":"asl/scalar/alu/MUL.asl","requirements":["PTO-INST-SCALAR-MUL"],"kind":"execution","summary":"MUL publishes its assigned fixed-width scalar product","pass_condition":"Decoded execution and the mnemonic result contract agree on the representative product","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left: Word = Zeros{PTO_XLEN} - 2;
    let right: Word = Zeros{PTO_XLEN} + 3;
    WriteGPR(1, left);
    WriteGPR(2, right);
    var instruction: bits(48) = Zeros{48} + 0x00000047;
    instruction[11:7] = Zeros{5} + 3;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;
    let execution = ExecuteScalarInstruction(instruction, 32);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} - 6;
    assert InstructionContractResult_MUL(left, right) == Zeros{PTO_XLEN} - 6;
    return 0;
end;
