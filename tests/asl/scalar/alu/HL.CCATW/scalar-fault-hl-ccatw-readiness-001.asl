// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-CCATW-READINESS-001","source":"asl/scalar/alu/HL.CCATW.asl","requirements":["PTO-INST-SCALAR-HL-CCATW"],"kind":"fault","summary":"HL.CCATW rejects an unavailable source before either destination write","pass_condition":"unavailable T#4 preserves both destinations and TPC while reporting IllegalInstruction","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x90);
    var instruction: bits(48) = Zeros{48} + 0x0000205d000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[15:11] = Zeros{5} + 4;
    instruction[35:31] = Zeros{5} + 27;
    instruction[40:36] = Zeros{5} + 1;
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(3) == Zeros{PTO_XLEN};
    assert ReadGPR(4) == Zeros{PTO_XLEN};
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x90;
    return 0;
end;
