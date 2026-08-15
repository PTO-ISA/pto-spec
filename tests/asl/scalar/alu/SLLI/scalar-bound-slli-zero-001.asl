// PTO-TEST: {"id":"PTO-AVS-SCALAR-SLLI-ZERO-001","source":"asl/scalar/alu/SLLI.asl","requirements":["PTO-INST-SCALAR-SLLI"],"kind":"boundary","summary":"SLLI shamt zero preserves a non-consuming T source and publishes through U","pass_condition":"identity shift, source preservation, and U publication match SLLI","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x80000001);
    var instruction: bits(48) = Zeros{48} + 0x00007015;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[25:20] = Zeros{6};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x80000001;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x80000001;
    return 0;
end;
