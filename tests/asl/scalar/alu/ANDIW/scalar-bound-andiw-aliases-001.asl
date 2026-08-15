// PTO-TEST: {"id":"PTO-AVS-SCALAR-ANDIW-ALIASES-001","source":"asl/scalar/alu/ANDIW.asl","requirements":["PTO-INST-SCALAR-ANDIW"],"kind":"boundary","summary":"ANDIW ignores source high bits and publishes a positive word result through T","pass_condition":"negative-one mask, U source preservation, and T publication match ANDIW","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(FALSE, '0001001000110100010101100111100001111111111111111111111111111111');
    var instruction: bits(48) = Zeros{48} + 0x00002035;
    instruction[11:7] = Zeros{5} + 31;
    instruction[19:15] = Zeros{5} + 28;
    instruction[31:20] = Ones{12};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) == '0001001000110100010101100111100001111111111111111111111111111111';
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x7fffffff;
    return 0;
end;
