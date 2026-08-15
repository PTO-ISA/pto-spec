// PTO-TEST: {"id":"PTO-AVS-SCALAR-BCNT-WRAP-001","source":"asl/scalar/alu/BCNT.asl","requirements":["PTO-INST-SCALAR-BCNT"],"kind":"execution","summary":"BCNT counts set bits in a wrapping selected field","pass_condition":"M=60 and N=8 select field 0x32 across bit 63, produce population three, write the GPR destination, and advance TPC once","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x2000000000000003);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    var instruction: bits(48) = Zeros{48} + 0x00006067;
    instruction[11:7] = Zeros{5} + 2;
    instruction[19:15] = Zeros{5} + 1;
    instruction[25:20] = Zeros{6} + 7;
    instruction[31:26] = Zeros{6} + 60;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 3;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    assert InstructionContractResult_BCNT(
        Zeros{PTO_XLEN} + 0x2000000000000003,
        8,
        60) == Zeros{PTO_XLEN} + 3;
    return 0;
end;
