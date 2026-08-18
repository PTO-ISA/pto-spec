// PTO-TEST: {"id":"PTO-AVS-ARCH-FP19-ENC-001","source":"asl/arch/data-types/fp19.asl","requirements":["PTO-FP19-PARAMETER-CARRIER-001"],"kind":"boundary","summary":"FP19 classifies and decodes its assigned sign, exponent, and fraction fields","pass_condition":"zero, finite scales, infinity, NaN, and exact FP32 conversion use canonical FP19 encodings","related_sources":[]}
func main() => integer
begin
    let one = FP32ToFP19(Zeros{PTO_XLEN} + 0x3f800000);
    let half = FP32ToFP19(Zeros{PTO_XLEN} + 0x3f000000);
    assert one == '0011111110000000000';
    assert half == '0011111100000000000';
    assert FP19FiniteValue(one) == 1.0;
    assert FP19FiniteValue(half) == 0.5;
    assert FP19ScaleLegal(one);
    assert !FP19ScaleLegal(Zeros{19});
    assert !FP19ScaleLegal('1011111110000000000');
    assert FP19ValueClass('0111111110000000000') ==
        NumericValue_PositiveInfinity;
    assert FP19ValueClass('0111111111000000000') ==
        NumericValue_QuietNaN;
    return 0;
end;
