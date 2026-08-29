// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-LENGTH-TOTALITY-002","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-FETCH-001"],"kind":"boundary","summary":"Every low four-bit prefix selects exactly one PTO instruction length.","pass_condition":"All sixteen prefixes map to 16/32 bits, with 0xe and 0xf selecting the 48/64-bit escape forms.","related_sources":["asl/arch/dispatch/top-level.asl"]}
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
