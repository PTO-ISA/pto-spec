// PTO-TEST: {"id":"PTO-AVS-SCALAR-ADDI-ALIASES-001","source":"asl/scalar/alu/ADDI.asl","requirements":["PTO-INST-SCALAR-ADDI"],"kind":"boundary","summary":"ADDI accepts the maximum immediate and non-consuming T source with U publication","pass_condition":"uimm12 maximum, queue source preservation, and U destination match ADDI","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 5);
    var instruction: bits(48) = Zeros{48} + 0x00000015;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[31:20] = Ones{12};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 4100;
    return 0;
end;
