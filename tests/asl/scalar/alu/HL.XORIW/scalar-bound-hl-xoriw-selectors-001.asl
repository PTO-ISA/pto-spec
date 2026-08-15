// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-XORIW-SELECTORS-001","source":"asl/scalar/alu/HL.XORIW.asl","requirements":["PTO-INST-SCALAR-HL-XORIW"],"kind":"boundary","summary":"HL.XORIW accepts its 24-bit endpoint with a non-consuming T source and U destination","pass_condition":"endpoint execution preserves the T source and publishes the audited result to U","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    let immediate: bits(24) = Ones{24};
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x7fffffff);
    var instruction: bits(48) = Zeros{48} + 0x00004035000e;
    instruction[27:23] = Zeros{5} + 30;
    instruction[35:31] = Zeros{5} + 24;
    instruction[47:36] = immediate[11:0];
    instruction[15:4] = immediate[23:12];
    let status = ExecuteScalarInstruction(instruction, 48);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x7fffffff;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0xffffffff80000000;
    return 0;
end;
