// PTO-TEST: {"id":"PTO-AVS-SCALAR-ANDI-RESULT-001","source":"asl/scalar/alu/ANDI.asl","requirements":["PTO-INST-SCALAR-ANDI"],"kind":"execution","summary":"ANDI sign-extends simm12 before the XLEN conjunction","pass_condition":"negative immediate extension, source-destination alias, TPC, and contract match ANDI","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Ones{PTO_XLEN});
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00002015;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[31:20] = Zeros{12} + 0x800;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == '1111111111111111111111111111111111111111111111111111100000000000';
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractImmediateWidth_ANDI() == 12;
    assert InstructionContractImmediateIsSigned_ANDI();
    assert !InstructionContractIsWordOperation_ANDI();
    return 0;
end;
