// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-HIF4-SCALE","surface":"arch","classification":["data-types","formats","hif4-scale"],"depends_on":["PTO-ARCH-DATA-TYPES-FP19"]}

// NDF-BEGIN: PTO-CUBE-HIF4-SCALE-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// A HiF4 Matrix scale MUST be one raw U32 word containing E6M2 in bits 7:0,
// eight E1_8 exponents in bits 15:8, and sixteen E1_16 exponents in bits
// 31:16. E6M2 values 00..FE MUST be finite with bias 48 and two fraction
// bits; FF MUST be a legal quiet NaN scale. One word scales 64 logical HiF4
// lanes through the selected E1_8 plus E1_16 exponent bits.
// NDF-END: PTO-CUBE-HIF4-SCALE-001

pure func HiF4E6M2ValueClass(value: bits(8)) => NumericValueClass
begin
    if value == Ones{8} then return NumericValue_QuietNaN; end;
    return NumericValue_PositiveNormal;
end;

pure func HiF4E6M2FiniteValue(value: bits(8)) => real
begin
    assert value != Ones{8};
    let exponent = (UInt(value[7:2]) - 48) as integer {-48..15};
    let mantissa_quarters = 4 + UInt(value[1:0]);
    return (Real(mantissa_quarters) / 4.0) * FP19PowerOfTwo(exponent);
end;

pure func HiF4ScaleExponentIncrement(
    scale_word: bits(32), q: integer {0..63}) => integer {0..2}
begin
    let e1_8_index = 8 + (q DIVRM 8);
    let e1_16_index = 16 + (q DIVRM 4);
    return UInt(scale_word[e1_8_index]) +
           UInt(scale_word[e1_16_index]);
end;

pure func HiF4ScaleFiniteValue(
    scale_word: bits(32), q: integer {0..63}) => real
begin
    assert HiF4E6M2ValueClass(scale_word[7:0]) ==
        NumericValue_PositiveNormal;
    return HiF4E6M2FiniteValue(scale_word[7:0]) *
        FP19PowerOfTwo(HiF4ScaleExponentIncrement(scale_word, q));
end;
