// PTO-TEST: {"id":"PTO-AVS-SCALAR-BIS-SELECTORS-001","source":"asl/scalar/alu/BIS.asl","requirements":["PTO-INST-SCALAR-BIS"],"kind":"boundary","summary":"BIS assigns full-width setting and queue destinations","pass_condition":"Full-width BIS from U#1 produces all ones in T and does not consume U","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN});
    var instruction: bits(48) = Zeros{48} + 0x00003067;
    instruction[11:7] = Zeros{5} + 31;
    instruction[19:15] = Zeros{5} + 28;
    instruction[25:20] = Ones{6};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Ones{PTO_XLEN};
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN};
    return 0;
end;
