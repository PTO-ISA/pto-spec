// PTO-TEST: {"id":"PTO-AVS-SCALAR-ORI-RESULT-001","source":"asl/scalar/alu/ORI.asl","requirements":["PTO-INST-SCALAR-ORI"],"kind":"execution","summary":"ORI sign-extends simm12 before the XLEN disjunction","pass_condition":"negative endpoint, alias snapshot, TPC, and contract match ORI","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x123);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00003015;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[31:20] = Zeros{12} + 0x800;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == '1111111111111111111111111111111111111111111111111111100100100011';
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractImmediateWidth_ORI() == 12;
    assert InstructionContractImmediateIsSigned_ORI();
    assert !InstructionContractIsWordOperation_ORI();
    return 0;
end;
