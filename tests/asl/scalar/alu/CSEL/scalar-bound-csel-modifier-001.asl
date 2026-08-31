// PTO-UNIT: {"id":"PTO-TEST-SCALAR-CSEL-MODIFIER-001","surface":"scalar","classification":["alu","CSEL","scalar-bound-csel-modifier-001"],"depends_on":["PTO-SCALAR-CSEL"]}
// PTO-TEST: {"id":"PTO-AVS-SCALAR-CSEL-MODIFIER-001","source":"asl/scalar/alu/CSEL.asl","requirements":["PTO-INST-SCALAR-CSEL"],"kind":"boundary","summary":"CSEL keeps raw modifier codes 00, 01, and 11 as unmodified aliases and negates only raw code 10","pass_condition":"the CSEL-specific modifier decoder and selected-right transformation match ADR-0118","related_sources":["asl/scalar/model/dispatch/decode.asl","asl/scalar/model/alu/semantics.asl"]}

func main() => integer
begin
    let value: Word = Zeros{PTO_XLEN} + 7;

    assert InstructionContractRightModifier_CSEL('00') == ScalarRight_None;
    assert InstructionContractRightModifier_CSEL('01') == ScalarRight_None;
    assert InstructionContractRightModifier_CSEL('10') == ScalarRight_NegateOrNot;
    assert InstructionContractRightModifier_CSEL('11') == ScalarRight_None;

    assert ApplySelectModifier(
        value,
        InstructionContractRightModifier_CSEL('11')) == value;
    assert ApplySelectModifier(
        value,
        InstructionContractRightModifier_CSEL('10')) == Zeros{PTO_XLEN} - value;
    return 0;
end;
