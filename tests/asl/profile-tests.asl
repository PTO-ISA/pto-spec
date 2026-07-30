// PTO-REQ-PROFILE-001: direct conformance witnesses for every PTO v0
// implementation-profile boundary.

func TestConcreteProfile()
begin
    ResetProfileState();
    assert CurrentACR() == 0;
    let reset_time = ReadMonotonicTime();
    assert reset_time == Zeros{PTO_XLEN};
    AdvanceArchitecturalTime();
    let advanced_time = ReadMonotonicTime();
    assert advanced_time == Zeros{PTO_XLEN} + 1;

    let exponential_zero = FloatingExponential(0.0);
    assert exponential_zero == 1.0;
    let rounded_even_low = FloatingRoundNearest(2.5);
    let rounded_even_high = FloatingRoundNearest(3.5);
    assert rounded_even_low == 2;
    assert rounded_even_high == 4;

    let (fp_binary, fp_binary_flags) = ScalarFPBinaryProfile(
        FloatingBinary_ADD, Zeros{3}, Zeros{5},
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3);
    assert fp_binary == Zeros{PTO_XLEN} + 5;
    assert fp_binary_flags == Zeros{5};
    let (fp_unary, fp_unary_flags) = ScalarFPUnaryProfile(
        FloatingUnary_EXP, Zeros{3}, Zeros{5}, Zeros{PTO_XLEN} + 4);
    assert fp_unary == Zeros{PTO_XLEN} + 5;
    assert fp_unary_flags == Zeros{5};
    let (fp_fused, fp_fused_flags) = ScalarFPFusedProfile(
        FloatingFused_MADD, Zeros{3}, Zeros{5}, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3);
    assert fp_fused == Zeros{PTO_XLEN} + 7;
    assert fp_fused_flags == Zeros{5};
    let (fp_integer, fp_integer_flags) = ScalarFPToIntegerProfile(
        Zeros{3}, Zeros{5}, Zeros{5}, Zeros{PTO_XLEN} + 9);
    assert fp_integer == Zeros{PTO_XLEN} + 9;
    assert fp_integer_flags == Zeros{5};
    let (fp_convert, fp_convert_flags) = ScalarFPConvertProfile(
        Zeros{3}, Zeros{5} + 1, Zeros{5}, Zeros{PTO_XLEN} + 10);
    assert fp_convert == Zeros{PTO_XLEN} + 10;
    assert fp_convert_flags == Zeros{5};
    let (integer_fp, integer_fp_flags) = ScalarIntegerToFPProfile(
        Zeros{3}, Zeros{5}, Zeros{5} + 1, Zeros{PTO_XLEN} + 11);
    assert integer_fp == Zeros{PTO_XLEN} + 11;
    assert integer_fp_flags == Zeros{5};

    let tile_square_root = TileSquareRoot(Zeros{PTO_XLEN} + 9);
    let tile_logarithm = TileLogarithm(Zeros{PTO_XLEN} + 9);
    assert tile_square_root == Zeros{PTO_XLEN} + 9;
    assert tile_logarithm == Zeros{PTO_XLEN} + 9;
    let reciprocal_three = TileReciprocal(Zeros{PTO_XLEN} + 3);
    assert reciprocal_three == DivideWordUnsigned(
        Ones{PTO_XLEN}, Zeros{PTO_XLEN} + 3);
    let tile_exponential = TileExponential(Zeros{PTO_XLEN} + 4);
    let tile_exp_difference = TileExpDifference(Zeros{PTO_XLEN} + 9,
        Zeros{PTO_XLEN} + 4);
    assert tile_exponential == Zeros{PTO_XLEN} + 5;
    assert tile_exp_difference == Zeros{PTO_XLEN} + 5;

    let converted_tile = TileProfileConvert(Zeros{PTO_XLEN} + 0x123,
        TileDataType_U64, TileDataType_U8);
    assert converted_tile == Zeros{PTO_XLEN} + 0x23;
    let quantized_tile = TileProfileQuantize(Zeros{PTO_XLEN} + 20,
        Zeros{PTO_XLEN} + 4, Zeros{PTO_XLEN} + 1,
        TileDataType_U64, TileDataType_U8);
    assert quantized_tile == Zeros{PTO_XLEN} + 6;
    let dequantized_tile = TileProfileDequantize(Zeros{PTO_XLEN} + 7,
        Zeros{PTO_XLEN} + 3, Zeros{PTO_XLEN} + 1,
        TileDataType_U8, TileDataType_U64);
    assert dequantized_tile == Zeros{PTO_XLEN} + 18;

    assert AtomicAddress(Zeros{PTO_XLEN} + 128, FALSE) ==
        Zeros{PTO_XLEN} + 128;
    assert AtomicAddress(Zeros{PTO_XLEN} + 128, TRUE) ==
        Zeros{PTO_XLEN} + 128;
    let translated_address = TranslateDataAddress(
        Zeros{PTO_XLEN} + 256, 8, FALSE);
    assert translated_address == Zeros{PTO_XLEN} + 256;
    SetCurrentACR(2);
    let application_data_permitted = DataAccessPermitted(
        Zeros{PTO_XLEN} + 3064, 8, FALSE);
    let application_data_denied = DataAccessPermitted(
        Zeros{PTO_XLEN} + 3072, 8, FALSE);
    assert application_data_permitted;
    assert !application_data_denied;
    assert SystemRegisterAccessPermitted(
        Zeros{24} + 0x0000, FALSE, CurrentACR());
    assert !SystemRegisterAccessPermitted(
        Zeros{24} + 0x0f00, FALSE, CurrentACR());
    ClearFault();
    - = ReadSystemRegisterAddress(Zeros{24} + 0x0f00);
    assert _LastFault == Fault_IllegalInstruction;
    SetCurrentACR(0);
    let root_data_permitted = DataAccessPermitted(
        Zeros{PTO_XLEN} + 3072, 8, TRUE);
    assert root_data_permitted;
    assert SystemRegisterAccessPermitted(
        Zeros{24} + 0x0f00, TRUE, CurrentACR());

    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    WriteBPC(Zeros{PTO_XLEN} + 0x600);
    _BlockArgument = Zeros{PTO_XLEN} + 0x77;
    SaveTrapContext(1, CurrentACR());
    WriteTPC(Zeros{PTO_XLEN} + 0x700);
    WriteBPC(Zeros{PTO_XLEN} + 0x800);
    _BlockArgument = Zeros{PTO_XLEN};
    let recovered_context = RecoverTrapContext(1);
    assert recovered_context;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x500;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x600;
    assert _BlockArgument == Zeros{PTO_XLEN} + 0x77;

    let tile_binary = TileProfileBinary(TileBinary_ADD, TileDataType_U64,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3);
    let tile_unary = TileProfileUnary(TileUnary_NEG, TileDataType_S64,
        Zeros{PTO_XLEN} + 2);
    let tile_axpy = TileProfileAxpy(Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3, TileDataType_U64);
    let tile_prelu = TileProfilePReLU(Zeros{PTO_XLEN} - 3,
        Zeros{PTO_XLEN} + 2, TileDataType_S64);
    let tile_compare = TileProfileCompare(TileComparison_LT, TileDataType_S64,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3);
    let reduction_initial = TileProfileReductionInitial(
        TileReduction_SUM, TileDataType_U64, Zeros{PTO_XLEN} + 9);
    assert tile_binary == Zeros{PTO_XLEN} + 5;
    assert tile_unary == Zeros{PTO_XLEN} - 2;
    assert tile_axpy == Zeros{PTO_XLEN} + 7;
    assert tile_prelu == Zeros{PTO_XLEN} - 6;
    assert tile_compare == Zeros{PTO_XLEN} + 1;
    assert reduction_initial == Zeros{PTO_XLEN};
    let (reduction_sum, reduction_selected) = TileProfileReductionStep(
        TileReduction_SUM, TileDataType_U64,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3);
    assert reduction_sum == Zeros{PTO_XLEN} + 5;
    assert !reduction_selected;
    let tile_expand = TileProfileExpand(TileExpand_ADD, TileDataType_U64,
        Zeros{PTO_XLEN} + 4, Zeros{PTO_XLEN} + 5);
    let tile_partial = TileProfilePartialValue(TilePartial_MUL,
        TileDataType_U64, Zeros{PTO_XLEN} + 4, Zeros{PTO_XLEN} + 5);
    let tile_order_left = TileProfileOrderLeft(Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 5, FALSE, TileDataType_S64);
    let raw_profile_nan = TileProfileValueIsNaN(
        Zeros{PTO_XLEN} + 0x7ff8000000000000, TileDataType_FP64);
    let matrix_accumulate = TileProfileMatrixAccumulate(
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3,
        TileDataType_U64, TileDataType_U64, TileDataType_U64);
    let matrix_bias = TileProfileMatrixBias(Zeros{PTO_XLEN} + 7,
        Zeros{PTO_XLEN} + 2, TileDataType_U64, TileDataType_U64);
    let matrix_scaled_accumulate = TileProfileMatrixScaledAccumulate(
        Zeros{PTO_XLEN} + 5, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 3, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 6, TileDataType_FP32,
        TileDataType_E4M3, TileDataType_E5M2,
        TileDataType_E8M0, TileDataType_E8M0);
    assert tile_expand == Zeros{PTO_XLEN} + 9;
    assert tile_partial == Zeros{PTO_XLEN} + 20;
    assert tile_order_left;
    assert !raw_profile_nan;
    assert matrix_accumulate == Zeros{PTO_XLEN} + 7;
    assert matrix_bias == Zeros{PTO_XLEN} + 9;
    assert matrix_scaled_accumulate == Zeros{PTO_XLEN} + 149;

    WriteTPC(Zeros{PTO_XLEN} + 0x120);
    WriteBPC(Zeros{PTO_XLEN} + 0x100);
    SetCurrentACR(2);
    SaveTrapContext(1, CurrentACR());
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    WriteBPC(Zeros{PTO_XLEN} + 0x208);
    SetCurrentACR(0);
    let recovered_trap_context = RecoverTrapContext(1);
    assert recovered_trap_context;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x120;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x100;
    assert CurrentACR() == 2;

    WriteGPR(1, Zeros{PTO_XLEN} + 0x55);
    Store(Zeros{PTO_XLEN}, 8, Zeros{PTO_XLEN} + 0xaa);
    - = AddInitialWriteEvent(Zeros{PTO_XLEN} + 2048, 8,
        Zeros{PTO_XLEN});
    SetCurrentACR(2);
    ResetProfileState();
    assert CurrentACR() == 0;
    assert ReadGPR(1) == Zeros{PTO_XLEN};
    assert _MemoryEventCount == 0;
    let reset_memory = LoadUnsigned(Zeros{PTO_XLEN}, 8);
    assert reset_memory == Zeros{PTO_XLEN};
    let final_reset_time = ReadMonotonicTime();
    assert final_reset_time == Zeros{PTO_XLEN};
    assert _SystemRegisters.version == Zeros{PTO_XLEN} + 1;
    assert _SystemRegisters.tile_capacity ==
        Zeros{PTO_XLEN} + PTO_MODEL_MAX_TILE_CAPACITY_BYTES;
    assert _SystemRegisters.thread_id == Zeros{PTO_XLEN};
end;
