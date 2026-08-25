// PTO-TEST: {"id":"PTO-AVS-ARCH-MX-SPECIAL-AVAILABILITY-EXEC-003","source":"asl/arch/features/mx-formats.asl","requirements":[],"kind":"execution","summary":"canonical NaN and signed-zero helpers expose exact availability and carriers","pass_condition":"supported and unsupported canonical-NaN and signed-zero assertions hold","related_sources":["asl/arch/data-types/numeric-classification.asl"]}
func main() => integer
begin
    let (nan_available, canonical_nan) =
        HardwareNumericCanonicalNaNResult(TileDataType_FP32);
    assert nan_available;
    assert canonical_nan == Zeros{PTO_XLEN} + 0x7fc00000;
    let (integer_nan_available, integer_nan) =
        HardwareNumericCanonicalNaNResult(TileDataType_S32);
    assert !integer_nan_available;
    assert integer_nan == Zeros{PTO_XLEN};

    let (zero_available, positive_zero, negative_zero) =
        HardwareNumericSignedZeroEncodings(TileDataType_FP32);
    assert zero_available;
    assert positive_zero == Zeros{PTO_XLEN};
    assert negative_zero == Zeros{PTO_XLEN} + 0x80000000;
    let (hif8_zero_available, hif8_positive_zero, hif8_negative_zero) =
        HardwareNumericSignedZeroEncodings(TileDataType_HiF8);
    assert !hif8_zero_available;
    assert hif8_positive_zero == Zeros{PTO_XLEN};
    assert hif8_negative_zero == Zeros{PTO_XLEN};
    return 0;
end;
