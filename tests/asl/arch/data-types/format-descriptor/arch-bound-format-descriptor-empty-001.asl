// PTO-TEST: {"id":"PTO-AVS-ARCH-FORMAT-DESCRIPTOR-EMPTY-001","source":"asl/arch/data-types/format-descriptor.asl","requirements":["PTO-NUMERIC-FORMAT-DESCRIPTOR-001"],"kind":"boundary","summary":"The unavailable numeric-format descriptor carries no accidental format semantics.","pass_condition":"Every capability and width field is zero or false and the kind is Unavailable.","related_sources":[]}
func main() => integer
begin
    let descriptor = UnavailableNumericFormatDescriptor();
    assert !descriptor.available;
    assert descriptor.kind == NumericFormatKind_Unavailable;
    assert descriptor.carrier_bits == 0;
    assert descriptor.lane_bits == 0;
    assert descriptor.lanes_per_carrier == 0;
    assert descriptor.sign_bits == 0;
    assert descriptor.exponent_bits_min == 0;
    assert descriptor.exponent_bits_max == 0;
    assert descriptor.fraction_bits_min == 0;
    assert descriptor.fraction_bits_max == 0;
    assert !descriptor.exponent_bias_available;
    assert descriptor.required_low_zero_bits == 0;
    assert descriptor.required_high_zero_bits == 0;
    assert !descriptor.has_zero;
    assert !descriptor.has_signed_zero;
    assert !descriptor.has_subnormal;
    assert !descriptor.has_infinity;
    assert !descriptor.has_quiet_nan;
    assert !descriptor.has_signaling_nan;
    return 0;
end;
