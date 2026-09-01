// PTO-TEST: {"id":"PTO-AVS-SCALAR-FCVTZ-DSTTYPE-MAP-002","source":"asl/scalar/fsu/FCVTZ.asl","requirements":["PTO-INST-SCALAR-FCVTZ","PTO-FCVTZ-DECISION-BINDING-001"],"kind":"boundary","summary":"FCVTZ raw destination types map to the eight original unsigned and signed integer carriers","pass_condition":"raw zero through three map to canonical unsigned codes zero through three, raw four through seven map to signed codes eight through eleven, and every larger raw value is illegal","related_sources":["asl/scalar/model/fsu/profile.asl"]}
func main() => integer
begin
    for raw = 0 to 7 do
        let encoded = Zeros{5} + raw;
        let expected = if raw <= 3 then encoded
            else Zeros{5} + raw + 4;
        assert InstructionContractDestinationTypeLegal_FCVTZ(encoded);
        assert InstructionContractDestinationCarrier_FCVTZ(encoded) ==
            expected;
    end;
    for raw = 8 to 31 do
        assert !InstructionContractDestinationTypeLegal_FCVTZ(
            Zeros{5} + raw);
    end;
    return 0;
end;
