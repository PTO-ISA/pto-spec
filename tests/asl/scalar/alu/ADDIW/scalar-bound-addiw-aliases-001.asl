// PTO-TEST: {"id":"PTO-AVS-SCALAR-ADDIW-ALIASES-001","source":"asl/scalar/alu/ADDIW.asl","requirements":["PTO-INST-SCALAR-ADDIW"],"kind":"boundary","summary":"ADDIW ignores high source bits and publishes through U","pass_condition":"low-word-only arithmetic, maximum queue-preserving source, and U publication match ADDIW","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, '0001001000110100010101100111100001111111111111111111000000000001');
    var instruction: bits(48) = Zeros{48} + 0x00000035;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[31:20] = Ones{12};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == '0001001000110100010101100111100001111111111111111111000000000001';
    assert ReadTemporaryQueue(FALSE, 0) == '1111111111111111111111111111111110000000000000000000000000000000';
    return 0;
end;
