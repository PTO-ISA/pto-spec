// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-SRLI-READINESS-001","source":"asl/scalar/alu/C.SRLI.asl","requirements":["PTO-INST-SCALAR-C-SRLI"],"kind":"fault","summary":"C.SRLI rejects an unavailable fixed T#1 source before effects","pass_condition":"an empty T queue raises IllegalInstruction without a push, TPC advance, or unrelated state change","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x55);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);

    var instruction: bits(48) = Zeros{48} + 0x182c;
    instruction[10:6] = Zeros{5} + 1;

    let status = ExecuteScalarInstruction(instruction, 16);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !TemporaryQueueSourceAvailable(TRUE, 0);
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x55;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x200;
    return 0;
end;
