// PTO-REQ-PROFILE-001, PTO-REQ-HARDWARE-NUMERIC-001:
// common exact numeric-format API evidence.

func AssertNumericFormatCapabilityConsistency(data_type: TileDataType)
begin
    let descriptor = TileNumericFormatDescriptor(data_type);
    assert descriptor.has_subnormal ==
        HardwareNumericTypeHasSubnormals(data_type);
    let (signed_zero_available, positive_zero, negative_zero) =
        HardwareNumericSignedZeroEncodings(data_type);
    assert descriptor.has_signed_zero == signed_zero_available;
    let (nan_available, canonical_nan) = TileNumericCanonicalNaN(data_type);
    assert descriptor.has_quiet_nan == nan_available;
end;

func TestNumericFormatCommon()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_S32);
    assert !descriptor.available;
    assert descriptor.kind == NumericFormatKind_Unavailable;
    assert descriptor.carrier_bits == 0;
    let (available, negative, significand, exponent) =
        TileNumericFiniteDecomposition(TileDataType_S32,
            Zeros{PTO_XLEN} + 1);
    assert !available;
    assert !negative;
    assert significand == Zeros{PTO_XLEN};
    assert exponent == 0;

    assert TileNumericFormatDescriptor(TileDataType_FP64).available;
    assert TileNumericFormatDescriptor(TileDataType_FP32).available;
    assert TileNumericFormatDescriptor(TileDataType_TF32).available;
    assert TileNumericFormatDescriptor(TileDataType_HF32).available;
    assert TileNumericFormatDescriptor(TileDataType_FP16).available;
    assert TileNumericFormatDescriptor(TileDataType_BF16).available;
    assert TileNumericFormatDescriptor(TileDataType_HiF8).available;
    assert TileNumericFormatDescriptor(TileDataType_E4M3).available;
    assert TileNumericFormatDescriptor(TileDataType_E5M2).available;
    assert TileNumericFormatDescriptor(TileDataType_E3M2).available;
    assert TileNumericFormatDescriptor(TileDataType_E2M3).available;
    assert TileNumericFormatDescriptor(TileDataType_E2M1X2).available;
    assert TileNumericFormatDescriptor(TileDataType_E1M2X2).available;
    assert TileNumericFormatDescriptor(TileDataType_E8M0).available;
    assert TileNumericFormatDescriptor(TileDataType_HiF4X2).available;

    assert !TileNumericFormatDescriptor(TileDataType_S64).available;
    assert !TileNumericFormatDescriptor(TileDataType_S32).available;
    assert !TileNumericFormatDescriptor(TileDataType_S16).available;
    assert !TileNumericFormatDescriptor(TileDataType_S8).available;
    assert !TileNumericFormatDescriptor(TileDataType_S4X2).available;
    assert !TileNumericFormatDescriptor(TileDataType_U64).available;
    assert !TileNumericFormatDescriptor(TileDataType_U32).available;
    assert !TileNumericFormatDescriptor(TileDataType_U16).available;
    assert !TileNumericFormatDescriptor(TileDataType_U8).available;
    assert !TileNumericFormatDescriptor(TileDataType_U4X2).available;

    AssertNumericFormatCapabilityConsistency(TileDataType_FP64);
    AssertNumericFormatCapabilityConsistency(TileDataType_FP32);
    AssertNumericFormatCapabilityConsistency(TileDataType_TF32);
    AssertNumericFormatCapabilityConsistency(TileDataType_HF32);
    AssertNumericFormatCapabilityConsistency(TileDataType_FP16);
    AssertNumericFormatCapabilityConsistency(TileDataType_BF16);
    AssertNumericFormatCapabilityConsistency(TileDataType_HiF8);
    AssertNumericFormatCapabilityConsistency(TileDataType_E4M3);
    AssertNumericFormatCapabilityConsistency(TileDataType_E5M2);
    AssertNumericFormatCapabilityConsistency(TileDataType_E3M2);
    AssertNumericFormatCapabilityConsistency(TileDataType_E2M3);
    AssertNumericFormatCapabilityConsistency(TileDataType_E2M1X2);
    AssertNumericFormatCapabilityConsistency(TileDataType_E1M2X2);
    AssertNumericFormatCapabilityConsistency(TileDataType_E8M0);
    AssertNumericFormatCapabilityConsistency(TileDataType_HiF4X2);
    AssertNumericFormatCapabilityConsistency(TileDataType_S64);
    AssertNumericFormatCapabilityConsistency(TileDataType_S32);
    AssertNumericFormatCapabilityConsistency(TileDataType_S16);
    AssertNumericFormatCapabilityConsistency(TileDataType_S8);
    AssertNumericFormatCapabilityConsistency(TileDataType_S4X2);
    AssertNumericFormatCapabilityConsistency(TileDataType_U64);
    AssertNumericFormatCapabilityConsistency(TileDataType_U32);
    AssertNumericFormatCapabilityConsistency(TileDataType_U16);
    AssertNumericFormatCapabilityConsistency(TileDataType_U8);
    AssertNumericFormatCapabilityConsistency(TileDataType_U4X2);
end;

func AssertNumericFiniteDecomposition(data_type: TileDataType, value: Word,
                                       expected_negative: boolean,
                                       expected_significand: Word,
                                       expected_exponent: integer {-1074..1023})
begin
    let (available, negative, significand, exponent) =
        TileNumericFiniteDecomposition(data_type, value);
    assert available;
    assert negative == expected_negative;
    assert significand == expected_significand;
    assert exponent == expected_exponent;
end;

func AssertNumericFiniteDecompositionUnavailable(data_type: TileDataType,
                                                  value: Word)
begin
    let (available, negative, significand, exponent) =
        TileNumericFiniteDecomposition(data_type, value);
    assert !available;
    assert !negative;
    assert significand == Zeros{PTO_XLEN};
    assert exponent == 0;
end;
