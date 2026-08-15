// PTO-TEST: {"id":"PTO-AVS-SCALAR-MADD-ACCUMULATE-001","source":"asl/scalar/alu/MADD.asl","requirements":["PTO-INST-SCALAR-MADD"],"kind":"execution","summary":"MADD snapshots three sources and publishes its assigned multiply-add result","pass_condition":"Decoded execution and the mnemonic result contract agree on the representative accumulated product","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let addend: Word = Zeros{PTO_XLEN} + 5;
    let left: Word = Zeros{PTO_XLEN} + 3;
    let right: Word = Zeros{PTO_XLEN} + 4;
    WriteGPR(1, addend);
    WriteGPR(2, left);
    WriteGPR(3, right);
    var instruction: bits(48) = Zeros{48} + 0x00006047;
    instruction[11:7] = Zeros{5} + 4;
    instruction[31:27] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    let execution = ExecuteScalarInstruction(instruction, 32);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 17;
    assert InstructionContractResult_MADD(addend, left, right) == Zeros{PTO_XLEN} + 17;
    return 0;
end;
