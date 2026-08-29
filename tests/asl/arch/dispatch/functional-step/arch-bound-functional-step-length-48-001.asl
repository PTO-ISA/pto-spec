// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-LENGTH-48-001","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-FETCH-001"],"kind":"boundary","summary":"The escape prefix with bit zero clear selects a 48-bit instruction.","pass_condition":"DeterminePTOInstructionLength returns 48 for low halfword 0x000e.","related_sources":["asl/arch/dispatch/top-level.asl"]}
func main() => integer
begin
    assert DeterminePTOInstructionLength(Zeros{16} + 0x000e) == 48;
    return 0;
end;
