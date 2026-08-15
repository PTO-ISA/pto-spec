// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARFPDISPATCHEFFECTS-EXECUTION-001","source":"asl/scalar/model/fsu/arithmetic.asl","requirements":[],"kind":"execution","summary":"Covers Scalar FP Dispatch Effects.","pass_condition":"TestScalarFPDispatchEffects completes without assertion failure","related_sources":[]}
func TestScalarFPDispatchEffects()
begin
    ClearFault();
    _SystemRegisters.core_state = Zeros{PTO_XLEN};
    _SystemRegisters.core_state[39:37] = '010';
    _SystemRegisters.core_state[36:32] = '10000';

    WriteGPR(2, Zeros{PTO_XLEN} + 0xbf800000);
    var absolute: bits(48) = Zeros{48} + 0x0000007b;
    absolute[11:7] = Zeros{5} + 5;
    absolute[19:15] = Zeros{5} + 2;
    absolute[26:25] = '01';
    let absolute_status = ExecuteScalarInstruction(absolute, 32);
    assert absolute_status == ScalarExecution_Executed;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x3f800000;
    assert ScalarFPFlags() == '10000';

    WriteGPR(2, Zeros{PTO_XLEN} + 0x80000000);
    WriteGPR(3, Zeros{PTO_XLEN});
    var maximum: bits(48) = Zeros{48} + 0x0000605b;
    maximum[11:7] = Zeros{5} + 6;
    maximum[19:15] = Zeros{5} + 2;
    maximum[24:20] = Zeros{5} + 3;
    maximum[26:25] = '01';
    let maximum_status = ExecuteScalarInstruction(maximum, 32);
    assert maximum_status == ScalarExecution_Executed;
    assert ReadGPR(6) == Zeros{PTO_XLEN};

    var minimum: bits(48) = Zeros{48} + 0x0000705b;
    minimum[11:7] = Zeros{5} + 7;
    minimum[19:15] = Zeros{5} + 2;
    minimum[24:20] = Zeros{5} + 3;
    minimum[26:25] = '01';
    let minimum_status = ExecuteScalarInstruction(minimum, 32);
    assert minimum_status == ScalarExecution_Executed;
    assert ReadGPR(7) == Zeros{PTO_XLEN} + 0x80000000;

    WriteGPR(3, Zeros{PTO_XLEN} + 0x80000000);
    let maximum_negative_zero_status = ExecuteScalarInstruction(maximum, 32);
    assert maximum_negative_zero_status == ScalarExecution_Executed;
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x80000000;

    WriteGPR(2, Zeros{PTO_XLEN});
    WriteGPR(3, Zeros{PTO_XLEN});
    let minimum_positive_zero_status = ExecuteScalarInstruction(minimum, 32);
    assert minimum_positive_zero_status == ScalarExecution_Executed;
    assert ReadGPR(7) == Zeros{PTO_XLEN};

    let negative_zero64 = Zeros{PTO_XLEN} + 0x8000000000000000;
    assert ScalarFPMinMax(FloatingBinary_MAX, negative_zero64,
        negative_zero64, '00') == negative_zero64;
    assert ScalarFPMinMax(FloatingBinary_MIN, Zeros{PTO_XLEN},
        Zeros{PTO_XLEN}, '00') == Zeros{PTO_XLEN};

    var equal_zero: bits(48) = Zeros{48} + 0x0000005b;
    equal_zero[11:7] = Zeros{5} + 8;
    equal_zero[19:15] = Zeros{5} + 2;
    equal_zero[24:20] = Zeros{5} + 3;
    equal_zero[26:25] = '01';
    let equal_zero_status = ExecuteScalarInstruction(equal_zero, 32);
    assert equal_zero_status == ScalarExecution_Executed;
    assert ReadGPR(8) == Zeros{PTO_XLEN} + 1;

    WriteGPR(2, Zeros{PTO_XLEN} + 0x7fc00000);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x3f800000);
    var not_equal_nan: bits(48) = Zeros{48} + 0x0000105b;
    not_equal_nan[11:7] = Zeros{5} + 9;
    not_equal_nan[19:15] = Zeros{5} + 2;
    not_equal_nan[24:20] = Zeros{5} + 3;
    not_equal_nan[26:25] = '01';
    let not_equal_nan_status = ExecuteScalarInstruction(not_equal_nan, 32);
    assert not_equal_nan_status == ScalarExecution_Executed;
    assert ReadGPR(9) == Zeros{PTO_XLEN};
    assert ScalarFPFlags() == '10000';

    var signaling_equal: bits(48) = Zeros{48} + 0x0800005b;
    signaling_equal[11:7] = Zeros{5} + 10;
    signaling_equal[19:15] = Zeros{5} + 2;
    signaling_equal[24:20] = Zeros{5} + 3;
    signaling_equal[26:25] = '01';
    let signaling_equal_status = ExecuteScalarInstruction(signaling_equal, 32);
    assert signaling_equal_status == ScalarExecution_Executed;
    assert ReadGPR(10) == Zeros{PTO_XLEN};
    assert ScalarFPFlags() == '10001';

    WriteGPR(2, Zeros{PTO_XLEN} + 0x1234567887654321);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x11111111);
    var binary_profile: bits(48) = Zeros{48} + 0x0000004b;
    binary_profile[11:7] = Zeros{5} + 11;
    binary_profile[19:15] = Zeros{5} + 2;
    binary_profile[24:20] = Zeros{5} + 3;
    binary_profile[26:25] = '01';
    let binary_profile_status = ExecuteScalarInstruction(binary_profile, 32);
    assert binary_profile_status == ScalarExecution_Executed;
    assert ReadGPR(11) == Zeros{PTO_XLEN} + 0x98765432;

    WriteGPR(4, Zeros{PTO_XLEN} + 0x76543210);
    var fused_profile: bits(48) = Zeros{48} + 0x0000404b;
    fused_profile[11:7] = Zeros{5} + 12;
    fused_profile[19:15] = Zeros{5} + 2;
    fused_profile[24:20] = Zeros{5} + 3;
    fused_profile[31:27] = Zeros{5} + 4;
    fused_profile[26:25] = '01';
    let fused_profile_status = ExecuteScalarInstruction(fused_profile, 32);
    assert fused_profile_status == ScalarExecution_Executed;
    assert ReadGPR(12) == Zeros{PTO_XLEN} + 0xd3b3d841;

    WriteGPR(2, Zeros{PTO_XLEN} + 0x1234567880000001);
    var signed_conversion: bits(48) = Zeros{48} + 0x0000506b;
    signed_conversion[11:7] = Zeros{5} + 13;
    signed_conversion[19:15] = Zeros{5} + 2;
    signed_conversion[31:27] = Zeros{5} + 9;
    let signed_conversion_status =
        ExecuteScalarInstruction(signed_conversion, 32);
    assert signed_conversion_status == ScalarExecution_Executed;
    assert ReadGPR(13) == Zeros{PTO_XLEN} + 0xffffffff80000001;

    ClearFault();
    WriteGPR(14, Zeros{PTO_XLEN} + 0x55);
    var illegal_source_type: bits(48) = Zeros{48} + 0x0000004b;
    illegal_source_type[11:7] = Zeros{5} + 14;
    illegal_source_type[19:15] = Zeros{5} + 2;
    illegal_source_type[24:20] = Zeros{5} + 3;
    illegal_source_type[26:25] = '10';
    let illegal_source_status =
        ExecuteScalarInstruction(illegal_source_type, 32);
    assert illegal_source_status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(14) == Zeros{PTO_XLEN} + 0x55;

    ClearFault();
    WriteGPR(15, Zeros{PTO_XLEN} + 0x66);
    var illegal_destination_type: bits(48) = Zeros{48} + 0x0000006b;
    illegal_destination_type[11:7] = Zeros{5} + 15;
    illegal_destination_type[19:15] = Zeros{5} + 2;
    illegal_destination_type[31:27] = Zeros{5} + 15;
    let illegal_destination_status =
        ExecuteScalarInstruction(illegal_destination_type, 32);
    assert illegal_destination_status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(15) == Zeros{PTO_XLEN} + 0x66;
    ClearFault();
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarFPDispatchEffects();
    return 0;
end;
