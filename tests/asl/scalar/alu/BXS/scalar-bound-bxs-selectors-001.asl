// PTO-TEST: {"id":"PTO-AVS-SCALAR-BXS-SELECTORS-001","source":"asl/scalar/alu/BXS.asl","requirements":["PTO-INST-SCALAR-BXS"],"kind":"boundary","summary":"BXS assigns full Reg5 source and destination classes","pass_condition":"T#1 is read non-consumingly, sign extension is applied, and destination code 31 pushes T","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Ones{PTO_XLEN});
    var instruction: bits(48) = Zeros{48} + 0x00000067;
    instruction[11:7] = Zeros{5} + 31;
    instruction[19:15] = Zeros{5} + 24;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Ones{PTO_XLEN};
    assert ReadTemporaryQueue(TRUE, 1) == Ones{PTO_XLEN};
    return 0;
end;
