// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARFLOATING-EXECUTION-001","source":"asl/scalar/model/fsu/arithmetic.asl","requirements":[],"kind":"execution","summary":"Covers Scalar Floating.","pass_condition":"TestScalarFloating completes without assertion failure","related_sources":[]}
func TestScalarFloating()
begin
    assert ScalarFPSourceTypeCode('00') == '00000';
    assert ScalarFPSourceTypeCode('01') == '00001';
    assert ScalarFPSourceTypeCode('10') == '11111';
    assert ScalarFPSourceTypeCode('11') == '11111';
    assert ScalarSignedIntegerSourceTypeCode('00') == '01000';
    assert ScalarSignedIntegerSourceTypeCode('01') == '01001';
    assert ScalarUnsignedIntegerSourceTypeCode('00') == '00000';
    assert ScalarUnsignedIntegerSourceTypeCode('01') == '00001';
    assert ScalarFPTypeCodeSupported(Zeros{5});
    assert ScalarFPTypeCodeSupported(Zeros{5} + 1);
    assert !ScalarFPTypeCodeSupported(Zeros{5} + 15);
    assert !ScalarFPTypeCodeSupported(Ones{5});
    assert ScalarIntegerTypeCodeSupported(Zeros{5});
    assert ScalarIntegerTypeCodeSupported(Zeros{5} + 14);
    assert !ScalarIntegerTypeCodeSupported(Zeros{5} + 15);
    assert !ScalarIntegerTypeCodeSupported(Ones{5});

    assert FloatingBinary(FloatingBinary_ADD, 1.5, 2.25) == 3.75;
    assert FloatingBinary(FloatingBinary_MUL, -2.0, 4.0) == -8.0;
    assert FloatingCompare(FloatingCompare_LT, -1.0, 0.0);
    assert FloatingCompare(FloatingCompare_GE, 5.0, 5.0);
    assert FloatingFused(FloatingFused_MADD, 1.0, 2.0, 3.0) == 7.0;
    let square_root = FloatingUnary(FloatingUnary_SQRT, 9.0);
    assert square_root == 3.0;
    let rounded_down = FloatingToInteger(3.75, NumericRound_RTM);
    let rounded_zero = FloatingToInteger(-3.75, NumericRound_RTZ);
    assert rounded_down == 3;
    assert rounded_zero == -3;
    let converted_encoding = ConvertFloatingEncoding(
        Zeros{PTO_XLEN} + 0x3ff0000000000000,
        Zeros{5}, Zeros{5} + 1, Zeros{3});
    assert converted_encoding == Zeros{PTO_XLEN} + 0x3f800000;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarFloating();
    return 0;
end;
