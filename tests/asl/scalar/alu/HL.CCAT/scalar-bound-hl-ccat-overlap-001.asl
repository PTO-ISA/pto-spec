// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-CCAT-OVERLAP-001","source":"asl/scalar/alu/HL.CCAT.asl","requirements":["PTO-INST-SCALAR-HL-CCAT"],"kind":"boundary","summary":"HL.CCAT snapshots relative sources and orders overlapping destinations","pass_condition":"T and U sources persist and the second destination write determines the final alias value","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x1122);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x3344);
    var instruction: bits(48) = Zeros{48} + 0x0000105d000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[15:11] = Zeros{5} + 3;
    instruction[35:31] = Zeros{5} + 24;
    instruction[40:36] = Zeros{5} + 28;
    instruction[47:41] = Zeros{7} + 0;
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x1122;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x1122;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x3344;
    return 0;
end;
