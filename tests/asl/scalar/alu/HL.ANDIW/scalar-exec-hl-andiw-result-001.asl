// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-ANDIW-RESULT-001","source":"asl/scalar/alu/HL.ANDIW.asl","requirements":["PTO-INST-SCALAR-HL-ANDIW"],"kind":"execution","summary":"HL.ANDIW executes the audited 24-bit word and contract","pass_condition":"split immediate reconstruction, aliased source snapshot, result, and six-byte retirement agree","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let immediate: bits(24) = Ones{24};
    WriteGPR(1, Zeros{PTO_XLEN} + 0x80000001);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00002035000e;
    instruction[27:23] = Zeros{5} + 1;
    instruction[35:31] = Zeros{5} + 1;
    instruction[47:36] = immediate[11:0];
    instruction[15:4] = immediate[23:12];
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0xffffffff80000001;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x46;
    assert InstructionContractImmediateWidth_HL_ANDIW() == 24;
    assert InstructionContractImmediateIsSigned_HL_ANDIW();
    assert InstructionContractIsWordOperation_HL_ANDIW();
    assert InstructionContractResult_HL_ANDIW(Zeros{PTO_XLEN} + 0x80000001, immediate) == Zeros{PTO_XLEN} + 0xffffffff80000001;
    return 0;
end;
