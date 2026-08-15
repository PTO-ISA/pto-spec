// PTO-TEST: {"id":"PTO-AVS-SCALAR-BXS-READINESS-001","source":"asl/scalar/alu/BXS.asl","requirements":["PTO-INST-SCALAR-BXS"],"kind":"fault","summary":"BXS rejects an unavailable relative source before effects","pass_condition":"Unavailable U#4 raises IllegalInstruction without destination or TPC effects","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    var instruction: bits(48) = Zeros{48} + 0x00000067;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 31;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(1) == Zeros{PTO_XLEN};
    assert ReadTPC() == Zeros{PTO_XLEN};
    return 0;
end;
