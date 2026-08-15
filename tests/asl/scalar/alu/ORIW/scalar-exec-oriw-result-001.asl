// PTO-TEST: {"id":"PTO-AVS-SCALAR-ORIW-RESULT-001","source":"asl/scalar/alu/ORIW.asl","requirements":["PTO-INST-SCALAR-ORIW"],"kind":"execution","summary":"ORIW applies signed simm12 to the low word and sign-extends the result","pass_condition":"negative endpoint, word result, alias snapshot, TPC, and contract match ORIW","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x123);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00003035;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[31:20] = Zeros{12} + 0x800;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == '1111111111111111111111111111111111111111111111111111100100100011';
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractImmediateWidth_ORIW() == 12;
    assert InstructionContractImmediateIsSigned_ORIW();
    assert InstructionContractIsWordOperation_ORIW();
    return 0;
end;
