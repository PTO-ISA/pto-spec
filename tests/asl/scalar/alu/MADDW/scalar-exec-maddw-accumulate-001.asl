// PTO-TEST: {"id":"PTO-AVS-SCALAR-MADDW-ACCUMULATE-001","source":"asl/scalar/alu/MADDW.asl","requirements":["PTO-INST-SCALAR-MADDW"],"kind":"execution","summary":"MADDW snapshots three sources and publishes its assigned multiply-add result","pass_condition":"Decoded execution and the mnemonic result contract agree on the representative accumulated product","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let addend: Word = Zeros{PTO_XLEN} + 0x7fffffff;
    let left: Word = Zeros{PTO_XLEN} + 1;
    let right: Word = Zeros{PTO_XLEN} + 1;
    WriteGPR(1, addend);
    WriteGPR(2, left);
    WriteGPR(3, right);
    var instruction: bits(48) = Zeros{48} + 0x00007047;
    instruction[11:7] = Zeros{5} + 4;
    instruction[31:27] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    let execution = ExecuteScalarInstruction(instruction, 32);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0xffffffff80000000;
    assert InstructionContractResult_MADDW(addend, left, right) == Zeros{PTO_XLEN} + 0xffffffff80000000;
    return 0;
end;
