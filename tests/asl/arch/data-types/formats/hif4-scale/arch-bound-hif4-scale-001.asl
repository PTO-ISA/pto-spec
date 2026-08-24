// PTO-TEST: {"id":"PTO-AVS-ARCH-HIF4-SCALE-001","source":"asl/arch/data-types/formats/hif4-scale.asl","requirements":["PTO-CUBE-HIF4-SCALE-001"],"kind":"boundary","summary":"HiF4 E6M2 and exponent-bit scale boundaries are exact.","pass_condition":"00 is 2^-48, FE is 1.5*2^15, FF is legal quiet NaN, and q selects its exact E1_8 plus E1_16 increment.","related_sources":[]}

func main() => integer
begin
    assert HiF4E6M2FiniteValue('00000000') == FP19PowerOfTwo(-48);
    assert HiF4E6M2FiniteValue('11111110') ==
        1.5 * FP19PowerOfTwo(15);
    assert HiF4E6M2ValueClass('11111111') == NumericValue_QuietNaN;

    var scale = Zeros{32};
    scale[7:0] = '00000000';
    scale[8] = '1';
    scale[16] = '1';
    assert HiF4ScaleExponentIncrement(scale, 0) == 2;
    assert HiF4ScaleFiniteValue(scale, 0) == FP19PowerOfTwo(-46);
    assert HiF4ScaleExponentIncrement(scale, 8) == 0;
    return 0;
end;
