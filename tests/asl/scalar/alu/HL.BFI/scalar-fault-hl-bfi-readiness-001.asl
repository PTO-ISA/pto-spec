// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-BFI-READINESS-001","source":"asl/scalar/alu/HL.BFI.asl","requirements":["PTO-INST-SCALAR-HL-BFI"],"kind":"fault","summary":"HL.BFI rejects either unavailable relative source before effects","pass_condition":"Unavailable SrcR U#4 raises IllegalInstruction before destination publication","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Ones{PTO_XLEN});
    var instruction: bits(48) = Zeros{48} + 0x0000204d000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[35:31] = Zeros{5} + 1;
    instruction[40:36] = Zeros{5} + 31;
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(3) == Zeros{PTO_XLEN};
    return 0;
end;
