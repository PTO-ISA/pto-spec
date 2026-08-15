// PTO-TEST: {"id":"PTO-AVS-SCALAR-SUBI-ALIASES-001","source":"asl/scalar/alu/SUBI.asl","requirements":["PTO-INST-SCALAR-SUBI"],"kind":"boundary","summary":"SUBI accepts the maximum immediate and non-consuming U source with T publication","pass_condition":"uimm12 maximum, fourth U source preservation, and T destination match SUBI","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 5000);
    var instruction: bits(48) = Zeros{48} + 0x00001015;
    instruction[11:7] = Zeros{5} + 31;
    instruction[19:15] = Zeros{5} + 28;
    instruction[31:20] = Ones{12};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 5000;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 905;
    return 0;
end;
