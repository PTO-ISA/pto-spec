// PTO-TEST: {"id":"PTO-AVS-SCALAR-ORI-ALIASES-001","source":"asl/scalar/alu/ORI.asl","requirements":["PTO-INST-SCALAR-ORI"],"kind":"boundary","summary":"ORI accepts maximum simm12 with a non-consuming T source and U publication","pass_condition":"positive endpoint, source preservation, and U result match ORI","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x8000);
    var instruction: bits(48) = Zeros{48} + 0x00003015;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[31:20] = Zeros{12} + 2047;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x8000;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x87ff;
    return 0;
end;
