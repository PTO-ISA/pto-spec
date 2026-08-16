// PTO-TEST: {"id":"PTO-AVS-ARCH-CONCRETE-VALUE-CLASSES-EXEC-003","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"reference-profile numeric encodings map to exact value classes","pass_condition":"encoding validity, value class, and canonical NaN assertions hold","related_sources":[]}
func TestConcreteValueClassProfile()
begin
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff8000000000000) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff0000000000001) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7ff0000000000000) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xfff0000000000000) == NumericValue_NegativeInfinity;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN}) == NumericValue_PositiveZero;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x8000000000000000) == NumericValue_NegativeZero;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x8000000000000001) == NumericValue_NegativeSubnormal;

    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7fc00000) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800001) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800000) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0xff800000) == NumericValue_NegativeInfinity;
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x80000000) == NumericValue_NegativeZero;

    assert TileNumericEncodingValid(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x7fc00000);
    assert !TileNumericEncodingValid(TileDataType_TF32,
        Zeros{PTO_XLEN} + 1);
    assert TileNumericValueClass(TileDataType_TF32,
        Zeros{PTO_XLEN} + 1) == NumericValue_InvalidEncoding;
    assert TileNumericValueClass(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x7f802000) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_TF32,
        Zeros{PTO_XLEN} + 0x00002000) == NumericValue_PositiveSubnormal;
    assert TileNumericEncodingValid(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x7fc00000);
    assert !TileNumericEncodingValid(TileDataType_HF32,
        Zeros{PTO_XLEN} + 1);
    assert TileNumericValueClass(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x7f801000) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_HF32,
        Zeros{PTO_XLEN} + 0x00001000) == NumericValue_PositiveSubnormal;

    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7e00) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7c01) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x7c00) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(TileDataType_FP16,
        Zeros{PTO_XLEN} + 0x8000) == NumericValue_NegativeZero;
    assert TileNumericValueClass(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7fc0) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7f81) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_BF16,
        Zeros{PTO_XLEN} + 0x7f80) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_BF16,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;

    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x80) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x6f) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0xef) == NumericValue_NegativeInfinity;
    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN}) == NumericValue_PositiveZero;
    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(TileDataType_HiF8,
        Zeros{PTO_XLEN} + 0x81) == NumericValue_NegativeSubnormal;

    assert TileNumericValueClass(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0x7f) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0xff) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(TileDataType_E4M3,
        Zeros{PTO_XLEN} + 0x80) == NumericValue_NegativeZero;
    assert TileNumericValueClass(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7e) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7d) == NumericValue_SignalingNaN;
    assert TileNumericValueClass(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 0x7c) == NumericValue_PositiveInfinity;
    assert TileNumericValueClass(TileDataType_E5M2,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;

    assert TileNumericEncodingValid(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x3f);
    assert !TileNumericEncodingValid(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x40);
    assert TileNumericValueClass(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x40) == NumericValue_InvalidEncoding;
    assert TileNumericValueClass(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;
    assert TileNumericValueClass(TileDataType_E3M2,
        Zeros{PTO_XLEN} + 0x20) == NumericValue_NegativeZero;
    assert !TileNumericEncodingValid(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 0x80);
    assert TileNumericValueClass(TileDataType_E2M3,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveSubnormal;

    assert TileNumericValueClass(TileDataType_E2M1X2,
        Zeros{PTO_XLEN}) == NumericValue_PositiveZero;
    assert TileNumericValueClass(TileDataType_E2M1X2,
        Zeros{PTO_XLEN} + 8) == NumericValue_NegativeZero;
    assert TileNumericValueClass(TileDataType_E1M2X2,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveNormal;
    assert TileNumericValueClass(TileDataType_HiF4X2,
        Zeros{PTO_XLEN} + 9) == NumericValue_NegativeNormal;
    assert TileNumericValueClass(TileDataType_E8M0,
        Zeros{PTO_XLEN}) == NumericValue_PositiveNormal;
    assert TileNumericValueClass(TileDataType_E8M0,
        Zeros{PTO_XLEN} + 0xff) == NumericValue_QuietNaN;

    assert TileNumericValueClass(TileDataType_S64,
        Ones{PTO_XLEN}) == NumericValue_NegativeNormal;
    assert TileNumericValueClass(TileDataType_S32,
        Zeros{PTO_XLEN} + 1) == NumericValue_PositiveNormal;
    assert TileNumericValueClass(TileDataType_S4X2,
        Zeros{PTO_XLEN} + 0xaf) == NumericValue_NegativeNormal;
    assert TileNumericValueClass(TileDataType_U4X2,
        Zeros{PTO_XLEN} + 0xf0) == NumericValue_PositiveZero;

    let (fp64_nan_available, fp64_nan) =
        TileNumericCanonicalNaN(TileDataType_FP64);
    let (e5m2_nan_available, e5m2_nan) =
        TileNumericCanonicalNaN(TileDataType_E5M2);
    let (e8m0_nan_available, e8m0_nan) =
        TileNumericCanonicalNaN(TileDataType_E8M0);
    let (integer_nan_available, integer_nan) =
        TileNumericCanonicalNaN(TileDataType_S32);
    assert fp64_nan_available && fp64_nan ==
        Zeros{PTO_XLEN} + 0x7ff8000000000000;
    assert e5m2_nan_available && e5m2_nan == Zeros{PTO_XLEN} + 0x7e;
    assert e8m0_nan_available && e8m0_nan == Zeros{PTO_XLEN} + 0xff;
    assert !integer_nan_available && integer_nan == Zeros{PTO_XLEN};

    // Shared FP32/FP64 classification agrees with the scalar execution path.
    assert ScalarFP64IsNaN(Zeros{PTO_XLEN} + 0x7ff8000000000001);
    assert ScalarFP64IsSignalingNaN(Zeros{PTO_XLEN} + 0x7ff0000000000001);
    assert ScalarFP32IsNaN(Zeros{32} + 0x7fc00001);
    assert ScalarFP32IsSignalingNaN(Zeros{32} + 0x7f800001);
end;
func main() => integer
begin
    ResetProfileState();
    TestConcreteValueClassProfile();
    return 0;
end;
