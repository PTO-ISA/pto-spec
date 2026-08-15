// PTO-UNIT: {"id":"PTO-TEST-SCALAR-CMP-EQ-MODIFIER-001","surface":"scalar","classification":["bru","CMP.EQ","scalar-bound-cmp-eq-modifier-001"],"depends_on":["PTO-SCALAR-CMP-EQ"]}
// PTO-TEST: {"id":"PTO-AVS-SCALAR-CMP-EQ-MODIFIER-001","source":"asl/scalar/bru/CMP.EQ.asl","requirements":["PTO-INST-SCALAR-CMP-EQ"],"kind":"boundary","summary":"CMP.EQ interprets raw modifier codes as unmodified, signed-word, unsigned-word, and an unmodified relational alias","pass_condition":"the comparison-specific decoder and restricted comparison transformation match ADR 0027","related_sources":["asl/scalar/model/dispatch/decode.asl","asl/scalar/model/alu/semantics.asl"]}

func main() => integer
begin
    let value: Word = Ones{PTO_XLEN};

    assert DecodeScalarComparisonRightModifier('00') == ScalarRight_None;
    assert DecodeScalarComparisonRightModifier('01') == ScalarRight_SignedWord;
    assert DecodeScalarComparisonRightModifier('10') == ScalarRight_UnsignedWord;
    assert DecodeScalarComparisonRightModifier('11') == ScalarRight_NegateOrNot;

    assert ApplyRestrictedCompareModifier(
        value,
        DecodeScalarComparisonRightModifier('11')) == value;
    return 0;
end;
