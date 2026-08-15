// PTO-TEST: {"id":"PTO-AVS-SCALAR-SUBIW-RESULT-001","source":"asl/scalar/alu/SUBIW.asl","requirements":["PTO-INST-SCALAR-SUBIW"],"kind":"execution","summary":"SUBIW wraps the low word then sign-extends its result","pass_condition":"word subtraction, sign extension, source-destination alias, and TPC match SUBIW","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x80000000);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00001035;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[31:20] = Zeros{12} + 1;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x7fffffff;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractImmediateWidth_SUBIW() == 12;
    assert InstructionContractImmediateIsUnsigned_SUBIW();
    assert InstructionContractIsWordOperation_SUBIW();
    return 0;
end;
