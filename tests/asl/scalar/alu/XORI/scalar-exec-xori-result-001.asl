// PTO-TEST: {"id":"PTO-AVS-SCALAR-XORI-RESULT-001","source":"asl/scalar/alu/XORI.asl","requirements":["PTO-INST-SCALAR-XORI"],"kind":"execution","summary":"XORI sign-extends negative one before the XLEN exclusive-or","pass_condition":"negative immediate extension, alias snapshot, TPC, and contract match XORI","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Ones{PTO_XLEN});
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00004015;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[31:20] = Ones{12};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == Zeros{PTO_XLEN};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractImmediateWidth_XORI() == 12;
    assert InstructionContractImmediateIsSigned_XORI();
    assert !InstructionContractIsWordOperation_XORI();
    return 0;
end;
