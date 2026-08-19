// PTO-TEST: {"id":"PTO-AVS-ARCH-FP19-PARAMETER-DOMAIN-002","source":"asl/arch/data-types/fp19.asl","requirements":["PTO-FP19-PARAMETER-CARRIER-001"],"kind":"boundary","summary":"FP19 scale and activation carriers reject subnormal and non-finite encodings","pass_condition":"only positive normal scales and positive zero or normal activation parameters are legal","related_sources":["asl/block/attributes/B.FPATR.asl"]}
func main() => integer
begin
    let positive_zero = Zeros{19};
    let minimum_positive_subnormal = Zeros{19} + 0x1;
    let minimum_positive_normal = Zeros{19} + 0x400;
    let maximum_positive_normal = Zeros{19} + 0x3fbff;
    let negative_zero = Zeros{19} + 0x40000;
    let minimum_negative_normal = Zeros{19} + 0x40400;
    let positive_infinity = Zeros{19} + 0x3fc00;
    let quiet_nan = Zeros{19} + 0x3fe00;
    let signaling_nan = Zeros{19} + 0x3fc01;

    assert !FP19ScaleLegal(positive_zero);
    assert !FP19ScaleLegal(minimum_positive_subnormal);
    assert FP19ScaleLegal(minimum_positive_normal);
    assert FP19ScaleLegal(maximum_positive_normal);
    assert !FP19ScaleLegal(negative_zero);
    assert !FP19ScaleLegal(minimum_negative_normal);
    assert !FP19ScaleLegal(positive_infinity);
    assert !FP19ScaleLegal(quiet_nan);
    assert !FP19ScaleLegal(signaling_nan);

    assert FP19ActivationParameterLegal(positive_zero);
    assert !FP19ActivationParameterLegal(minimum_positive_subnormal);
    assert FP19ActivationParameterLegal(minimum_positive_normal);
    assert FP19ActivationParameterLegal(maximum_positive_normal);
    assert !FP19ActivationParameterLegal(negative_zero);
    assert !FP19ActivationParameterLegal(minimum_negative_normal);
    assert !FP19ActivationParameterLegal(positive_infinity);
    assert !FP19ActivationParameterLegal(quiet_nan);
    assert !FP19ActivationParameterLegal(signaling_nan);
    return 0;
end;
