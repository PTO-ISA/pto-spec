// PTO-TEST: {"id":"PTO-AVS-SCALAR-ANDI-ALIASES-001","source":"asl/scalar/alu/ANDI.asl","requirements":["PTO-INST-SCALAR-ANDI"],"kind":"boundary","summary":"ANDI accepts maximum simm12 with a non-consuming T source and U publication","pass_condition":"positive endpoint, queue preservation, and U result match ANDI","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x1234);
    var instruction: bits(48) = Zeros{48} + 0x00002015;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[31:20] = Zeros{12} + 2047;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x1234;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x234;
    return 0;
end;
