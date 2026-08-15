// PTO-TEST: {"id":"PTO-AVS-SCALAR-XORIW-RESULT-001","source":"asl/scalar/alu/XORIW.asl","requirements":["PTO-INST-SCALAR-XORIW"],"kind":"execution","summary":"XORIW exclusive-ors the low word with negative one and sign-extends the result","pass_condition":"result bit 31, alias snapshot, TPC, and contract match XORIW","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x7fffffff);
    WriteTPC(Zeros{PTO_XLEN} + 0x40);
    var instruction: bits(48) = Zeros{48} + 0x00004035;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 1;
    instruction[31:20] = Ones{12};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(1) == '1111111111111111111111111111111110000000000000000000000000000000';
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x44;
    assert InstructionContractImmediateWidth_XORIW() == 12;
    assert InstructionContractImmediateIsSigned_XORIW();
    assert InstructionContractIsWordOperation_XORIW();
    return 0;
end;
