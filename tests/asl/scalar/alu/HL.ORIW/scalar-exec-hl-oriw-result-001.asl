// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-ORIW-RESULT-001","source":"asl/scalar/alu/HL.ORIW.asl","requirements":["PTO-INST-SCALAR-HL-ORIW"],"kind":"execution","summary":"HL.ORIW executes the audited 24-bit word or contract","pass_condition":"split immediate reconstruction, aliased source snapshot, result, and six-byte retirement agree","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let immediate: bits(24) = Zeros{24} + 0x800000;
    WriteGPR(1, Zeros{PTO_XLEN});
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00003035000e;
    instruction[27:23] = Zeros{5} + 1;
    instruction[35:31] = Zeros{5} + 1;
    instruction[47:36] = immediate[11:0];
    instruction[15:4] = immediate[23:12];
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0xffffffffff800000;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x46;
    assert InstructionContractImmediateWidth_HL_ORIW() == 24;
    assert InstructionContractImmediateIsSigned_HL_ORIW();
    assert InstructionContractIsWordOperation_HL_ORIW();
    assert InstructionContractResult_HL_ORIW(Zeros{PTO_XLEN}, immediate) == Zeros{PTO_XLEN} + 0xffffffffff800000;
    return 0;
end;
