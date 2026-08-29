// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-LENGTH-64-001","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-FETCH-001"],"kind":"boundary","summary":"The escape prefix with bit zero set selects a 64-bit instruction.","pass_condition":"DeterminePTOInstructionLength returns 64 for low halfword 0x000f.","related_sources":["asl/arch/dispatch/top-level.asl"]}
func main() => integer
begin
    assert DeterminePTOInstructionLength(Zeros{16} + 0x000f) == 64;
    return 0;
end;
