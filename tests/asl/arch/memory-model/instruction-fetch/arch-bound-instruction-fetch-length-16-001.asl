// PTO-TEST: {"id":"PTO-AVS-ARCH-INSTRUCTION-FETCH-LENGTH-16-001","source":"asl/arch/memory-model/instruction-fetch.asl","requirements":["PTO-REQ-INSTRUCTION-FETCH-001"],"kind":"boundary","summary":"A non-escape prefix with bit zero clear selects a 16-bit instruction.","pass_condition":"DeterminePTOInstructionLength returns 16 for low halfword 0x0002.","related_sources":[]}
func main() => integer
begin
    assert DeterminePTOInstructionLength(Zeros{16} + 0x0002) == 16;
    return 0;
end;
