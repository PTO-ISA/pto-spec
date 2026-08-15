// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-MISUB-IMMEDIATE-001","source":"asl/scalar/alu/HL.MISUB.asl","requirements":["PTO-INST-SCALAR-HL-MISUB"],"kind":"execution","summary":"HL.MISUB applies its unsigned 19-bit immediate to the right source","pass_condition":"Decoded execution and the mnemonic result contract agree on the representative immediate result","related_sources":["asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let left: Word = Zeros{PTO_XLEN} + 5;
    let right: Word = Zeros{PTO_XLEN} + 3;
    let immediate: bits(19) = Zeros{19} + 4;
    WriteGPR(1, left);
    WriteGPR(2, right);
    var instruction: bits(48) = Zeros{48} + 0x0000104d000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 2;
    instruction[47:41] = immediate[6:0];
    instruction[15:4] = immediate[18:7];
    let execution = ExecuteScalarInstruction(instruction, 48);
    assert execution == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} - 7;
    assert InstructionContractResult_HL_MISUB(left, right, immediate) == Zeros{PTO_XLEN} - 7;
    return 0;
end;
