// PTO-TEST: {"id":"PTO-AVS-SCALAR-MULU-PRODUCT-001","source":"asl/scalar/alu/MULU.asl","requirements":["PTO-INST-SCALAR-MULU"],"kind":"execution","summary":"MULU publishes its assigned fixed-width scalar product","pass_condition":"Decoded execution and the mnemonic result contract agree on the representative product","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left: Word = Ones{PTO_XLEN};
    let right: Word = Zeros{PTO_XLEN} + 2;
    WriteGPR(1, left);
    WriteGPR(2, right);
    var instruction: bits(48) = Zeros{48} + 0x00001047;
    instruction[11:7] = Zeros{5} + 3;
    instruction[19:15] = Zeros{5} + 1;
    instruction[24:20] = Zeros{5} + 2;
    let execution = ExecuteScalarInstruction(instruction, 32);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0xfffffffffffffffe;
    assert InstructionContractResult_MULU(left, right) == Zeros{PTO_XLEN} + 0xfffffffffffffffe;
    return 0;
end;
