// PTO-TEST: {"id":"PTO-AVS-SCALAR-SRAIW-ZERO-001","source":"asl/scalar/alu/SRAIW.asl","requirements":["PTO-INST-SCALAR-SRAIW"],"kind":"boundary","summary":"SRAIW shamt zero ignores source high bits and sign-extends the word","pass_condition":"identity word shift, U source preservation, and T publication match SRAIW","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(FALSE, '0001001000110100010101100111100010000000000000000000000000000001');
    var instruction: bits(48) = Zeros{48} + 0x00006035;
    instruction[11:7] = Zeros{5} + 31;
    instruction[19:15] = Zeros{5} + 28;
    instruction[24:20] = Zeros{5};
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) == '0001001000110100010101100111100010000000000000000000000000000001';
    assert ReadTemporaryQueue(TRUE, 0) == '1111111111111111111111111111111110000000000000000000000000000001';
    return 0;
end;
