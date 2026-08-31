// PTO-TEST: {"id":"PTO-AVS-ARCH-INSTRUCTION-FETCH-LENGTH-32-001","source":"asl/arch/memory-model/instruction-fetch.asl","requirements":["PTO-REQ-INSTRUCTION-FETCH-001"],"kind":"boundary","summary":"A non-escape prefix with bit zero set selects a 32-bit instruction.","pass_condition":"DeterminePTOInstructionLength returns 32 for low halfword 0x0005.","related_sources":[]}
func main() => integer
begin
    assert DeterminePTOInstructionLength(Zeros{16} + 0x0005) == 32;
    return 0;
end;
