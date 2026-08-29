// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-LENGTH-16-001","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-FETCH-001"],"kind":"boundary","summary":"A non-escape prefix with bit zero clear selects a 16-bit instruction.","pass_condition":"DeterminePTOInstructionLength returns 16 for low halfword 0x0002.","related_sources":["asl/arch/dispatch/top-level.asl"]}
func main() => integer
begin
    assert DeterminePTOInstructionLength(Zeros{16} + 0x0002) == 16;
    return 0;
end;
