// PTO-TEST: {"id":"PTO-AVS-SCALAR-ANDIW-RESULT-001","source":"asl/scalar/alu/ANDIW.asl","requirements":["PTO-INST-SCALAR-ANDIW"],"kind":"execution","summary":"ANDIW applies signed simm12 to the low word and sign-extends the result","pass_condition":"word mask, result sign extension, alias, TPC, and contract match ANDIW","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x80000fff);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00002035;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[31:20] = Zeros{12} + 0x800;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == '1111111111111111111111111111111110000000000000000000100000000000';
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractImmediateWidth_ANDIW() == 12;
    assert InstructionContractImmediateIsSigned_ANDIW();
    assert InstructionContractIsWordOperation_ANDIW();
    return 0;
end;
