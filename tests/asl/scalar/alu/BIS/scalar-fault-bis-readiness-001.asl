// PTO-TEST: {"id":"PTO-AVS-SCALAR-BIS-READINESS-001","source":"asl/scalar/alu/BIS.asl","requirements":["PTO-INST-SCALAR-BIS"],"kind":"fault","summary":"BIS rejects an unavailable relative source before effects","pass_condition":"Unavailable T#3 raises IllegalInstruction before destination publication","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    var instruction: bits(48) = Zeros{48} + 0x00003067;
    instruction[11:7] = Zeros{5} + 1;
    instruction[19:15] = Zeros{5} + 26;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(1) == Zeros{PTO_XLEN};
    return 0;
end;
