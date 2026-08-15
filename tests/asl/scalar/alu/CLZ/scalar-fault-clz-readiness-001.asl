// PTO-TEST: {"id":"PTO-AVS-SCALAR-CLZ-READINESS-001","source":"asl/scalar/alu/CLZ.asl","requirements":["PTO-INST-SCALAR-CLZ"],"kind":"fault","summary":"CLZ rejects an unavailable relative source before destination and TPC effects","pass_condition":"T#4 after reset raises IllegalInstruction while the destination and TPC remain unchanged","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 0x55);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    var instruction: bits(48) = Zeros{48} + 0x00005067;
    instruction[11:7] = Zeros{5} + 2;
    instruction[19:15] = Zeros{5} + 27;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x55;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x200;
    return 0;
end;
