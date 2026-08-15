// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-SUBI-RESULT-001","source":"asl/scalar/alu/HL.SUBI.asl","requirements":["PTO-INST-SCALAR-HL-SUBI"],"kind":"execution","summary":"HL.SUBI executes the audited 24-bit sub contract","pass_condition":"split immediate reconstruction, aliased source snapshot, result, and six-byte retirement agree","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    let immediate: bits(24) = Zeros{24} + 1;
    WriteGPR(1, Zeros{PTO_XLEN});
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00001015000e;
    instruction[27:23] = Zeros{5} + 1;
    instruction[35:31] = Zeros{5} + 1;
    instruction[47:36] = immediate[11:0];
    instruction[15:4] = immediate[23:12];
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Ones{PTO_XLEN};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x46;
    assert InstructionContractImmediateWidth_HL_SUBI() == 24;
    assert InstructionContractImmediateIsUnsigned_HL_SUBI();
    assert !InstructionContractIsWordOperation_HL_SUBI();
    assert InstructionContractResult_HL_SUBI(Zeros{PTO_XLEN}, immediate) == Ones{PTO_XLEN};
    return 0;
end;
