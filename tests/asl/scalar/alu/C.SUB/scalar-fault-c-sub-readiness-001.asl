// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-SUB-READINESS-001","source":"asl/scalar/alu/C.SUB.asl","requirements":["PTO-INST-SCALAR-C-SUB"],"kind":"fault","summary":"C.SUB rejects an unavailable relative source before the implicit T destination","pass_condition":"T#4 after reset raises IllegalInstruction without a queue push, TPC advance, or unrelated state change","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x55);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);

    var instruction: bits(48) = Zeros{48} + 0x0018;
    instruction[10:6] = Zeros{5} + 27;
    instruction[15:11] = Zeros{5} + 1;

    let status = ExecuteScalarInstruction(instruction, 16);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !TemporaryQueueSourceAvailable(TRUE, 0);
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0x55;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x200;
    return 0;
end;
