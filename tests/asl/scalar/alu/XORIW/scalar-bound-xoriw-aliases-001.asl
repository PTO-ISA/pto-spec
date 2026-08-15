// PTO-TEST: {"id":"PTO-AVS-SCALAR-XORIW-ALIASES-001","source":"asl/scalar/alu/XORIW.asl","requirements":["PTO-INST-SCALAR-XORIW"],"kind":"boundary","summary":"XORIW ignores source high bits and can clear the low word with the minimum immediate","pass_condition":"minimum immediate, U source preservation, and zero T publication match XORIW","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(FALSE, '0001001000110100010101100111100011111111111111111111100000000000');
    var instruction: bits(48) = Zeros{48} + 0x00004035;
    instruction[11:7] = Zeros{5} + 31;
    instruction[19:15] = Zeros{5} + 28;
    instruction[31:20] = Zeros{12} + 0x800;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) == '0001001000110100010101100111100011111111111111111111100000000000';
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN};
    return 0;
end;
