// PTO-TEST: {"id":"PTO-AVS-SCALAR-SUBIW-ALIASES-001","source":"asl/scalar/alu/SUBIW.asl","requirements":["PTO-INST-SCALAR-SUBIW"],"kind":"boundary","summary":"SUBIW ignores high source bits and sign-extends a maximum-immediate result","pass_condition":"low-word-only arithmetic, U source preservation, and T publication match SUBIW","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(FALSE, '0001001000110100010101100111100000000000000000000000000000000000');
    var instruction: bits(48) = Zeros{48} + 0x00001035;
    instruction[11:7] = Zeros{5} + 31;
    instruction[19:15] = Zeros{5} + 28;
    instruction[31:20] = Ones{12};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) == '0001001000110100010101100111100000000000000000000000000000000000';
    assert ReadTemporaryQueue(TRUE, 0) == '1111111111111111111111111111111111111111111111111111000000000001';
    return 0;
end;
