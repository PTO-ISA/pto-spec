// PTO-TEST: {"id":"PTO-AVS-SCALAR-ORIW-ALIASES-001","source":"asl/scalar/alu/ORIW.asl","requirements":["PTO-INST-SCALAR-ORIW"],"kind":"boundary","summary":"ORIW ignores source high bits and publishes a positive word result through T","pass_condition":"maximum immediate, U source preservation, and T publication match ORIW","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(FALSE, '0001001000110100010101100111100000000000000000000000000000000001');
    var instruction: bits(48) = Zeros{48} + 0x00003035;
    instruction[11:7] = Zeros{5} + 31;
    instruction[19:15] = Zeros{5} + 28;
    instruction[31:20] = Zeros{12} + 2047;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) == '0001001000110100010101100111100000000000000000000000000000000001';
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x7ff;
    return 0;
end;
