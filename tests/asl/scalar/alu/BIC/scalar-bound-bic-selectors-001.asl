// PTO-TEST: {"id":"PTO-AVS-SCALAR-BIC-SELECTORS-001","source":"asl/scalar/alu/BIC.asl","requirements":["PTO-INST-SCALAR-BIC"],"kind":"boundary","summary":"BIC assigns one-bit width and discard destinations","pass_condition":"Encoded imml zero clears one selected bit and destination code 24 discards without queue effects","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Ones{PTO_XLEN});
    var instruction: bits(48) = Zeros{48} + 0x00002067;
    instruction[11:7] = Zeros{5} + 24;
    instruction[19:15] = Zeros{5} + 24;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Ones{PTO_XLEN};
    return 0;
end;
