// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-CCATW-OVERLAP-001","source":"asl/scalar/alu/HL.CCATW.asl","requirements":["PTO-INST-SCALAR-HL-CCATW"],"kind":"boundary","summary":"HL.CCATW snapshots relative sources and orders overlapping destinations","pass_condition":"T and U sources persist and the second destination write determines the final alias value","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/alu/semantics.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x80000001);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x7fffffff);
    var instruction: bits(48) = Zeros{48} + 0x0000205d000e;
    instruction[27:23] = Zeros{5} + 3;
    instruction[15:11] = Zeros{5} + 3;
    instruction[35:31] = Zeros{5} + 24;
    instruction[40:36] = Zeros{5} + 28;
    instruction[47:41] = Zeros{7} + 0;
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0xffffffff80000001;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x80000001;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x7fffffff;
    return 0;
end;
