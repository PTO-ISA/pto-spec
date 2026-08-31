// PTO-TEST: {"id":"PTO-AVS-ARCH-INSTRUCTION-FETCH-LENGTH-48-001","source":"asl/arch/memory-model/instruction-fetch.asl","requirements":["PTO-REQ-INSTRUCTION-FETCH-001"],"kind":"boundary","summary":"The escape prefix with bit zero clear selects a 48-bit instruction.","pass_condition":"DeterminePTOInstructionLength returns 48 for low halfword 0x000e.","related_sources":[]}
func main() => integer
begin
    assert DeterminePTOInstructionLength(Zeros{16} + 0x000e) == 48;
    return 0;
end;
