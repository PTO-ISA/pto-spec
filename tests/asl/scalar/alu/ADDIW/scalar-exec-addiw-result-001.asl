// PTO-TEST: {"id":"PTO-AVS-SCALAR-ADDIW-RESULT-001","source":"asl/scalar/alu/ADDIW.asl","requirements":["PTO-INST-SCALAR-ADDIW"],"kind":"execution","summary":"ADDIW wraps the low word then sign-extends its result","pass_condition":"word overflow, sign extension, source-destination alias, and TPC match ADDIW","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x7fffffff);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00000035;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[31:20] = Zeros{12} + 1;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == '1111111111111111111111111111111110000000000000000000000000000000';
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractImmediateWidth_ADDIW() == 12;
    assert InstructionContractImmediateIsUnsigned_ADDIW();
    assert InstructionContractIsWordOperation_ADDIW();
    return 0;
end;
