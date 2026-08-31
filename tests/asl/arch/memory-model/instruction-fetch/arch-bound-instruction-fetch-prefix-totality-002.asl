// PTO-TEST: {"id":"PTO-AVS-ARCH-INSTRUCTION-FETCH-PREFIX-TOTALITY-002","source":"asl/arch/memory-model/instruction-fetch.asl","requirements":["PTO-REQ-INSTRUCTION-FETCH-001"],"kind":"boundary","summary":"Every low four-bit prefix selects exactly one PTO instruction length.","pass_condition":"All sixteen prefixes map to 16 or 32 bits except 0xe and 0xf, which map to 48 and 64 bits.","related_sources":[]}
func main() => integer
begin
    for prefix = 0 to 15 do
        let halfword = Zeros{16} + prefix;
        let length = DeterminePTOInstructionLength(halfword);
        if prefix == 14 then
            assert length == 48;
        elsif prefix == 15 then
            assert length == 64;
        elsif prefix MOD 2 == 0 then
            assert length == 16;
        else
            assert length == 32;
        end;
    end;
    return 0;
end;
