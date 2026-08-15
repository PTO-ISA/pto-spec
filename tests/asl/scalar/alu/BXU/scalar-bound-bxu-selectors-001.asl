// PTO-TEST: {"id":"PTO-AVS-SCALAR-BXU-SELECTORS-001","source":"asl/scalar/alu/BXU.asl","requirements":["PTO-INST-SCALAR-BXU"],"kind":"boundary","summary":"BXU assigns full-width extraction and queue publication","pass_condition":"U#1 all ones extracts all 64 bits and destination code 30 pushes U without consuming the source","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(FALSE, Ones{PTO_XLEN});
    var instruction: bits(48) = Zeros{48} + 0x00001067;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 28;
    instruction[25:20] = Ones{6};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) == Ones{PTO_XLEN};
    assert ReadTemporaryQueue(FALSE, 1) == Ones{PTO_XLEN};
    return 0;
end;
