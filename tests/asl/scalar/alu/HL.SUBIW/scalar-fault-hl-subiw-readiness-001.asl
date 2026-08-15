// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-SUBIW-READINESS-001","source":"asl/scalar/alu/HL.SUBIW.asl","requirements":["PTO-INST-SCALAR-HL-SUBIW"],"kind":"fault","summary":"HL.SUBIW rejects an unavailable relative source before effects","pass_condition":"unavailable T#4 preserves destination and TPC while reporting IllegalInstruction","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x80);
    var instruction: bits(48) = Zeros{48} + 0x00001035000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[35:31] = Zeros{5} + 27;
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(3) == Zeros{PTO_XLEN};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x80;
    return 0;
end;
