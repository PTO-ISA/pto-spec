// PTO-TEST: {"id":"PTO-AVS-ARCH-CONCRETE-TILE-EXEC-006","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"reference-profile Tile arithmetic and trap recovery are exact","pass_condition":"Tile profile and trap recovery assertions hold","related_sources":[]}
func TestConcreteTileProfile()
begin
    let tile_binary = TileProfileBinary(TileBinary_ADD, TileDataType_U64,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3);
    let (tile_unary, tile_unary_flags) = TileProfileUnary(
        TileUnary_NEG,
        TileDataType_S64,
        Zeros{PTO_XLEN} + 2);
    let tile_compare = TileProfileCompare(TileComparison_LT, TileDataType_S64,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3);
    let reduction_initial = TileProfileReductionInitial(
        TileReduction_SUM, TileDataType_U64, Zeros{PTO_XLEN} + 9);
    assert tile_binary == Zeros{PTO_XLEN} + 5;
    assert tile_unary == Zeros{PTO_XLEN} - 2;
    assert tile_unary_flags == Zeros{5};
    assert tile_compare == Zeros{PTO_XLEN} + 1;
    assert reduction_initial == Zeros{PTO_XLEN};
    let (reduction_sum, reduction_selected) = TileProfileReductionStep(
        TileReduction_SUM, TileDataType_U64,
        Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3);
    assert reduction_sum == Zeros{PTO_XLEN} + 5;
    assert !reduction_selected;
    let tile_expand = TileProfileExpand(TileExpand_ADD, TileDataType_U64,
        Zeros{PTO_XLEN} + 4, Zeros{PTO_XLEN} + 5);
    let (tile_partial, tile_partial_flags) =
        TileProfilePartialValueWithFlags(
            TilePartial_MUL,
            TileDataType_U64,
            Zeros{PTO_XLEN} + 4,
            Zeros{PTO_XLEN} + 5);
    let tile_order_left = TileProfileOrderLeft(Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 5, FALSE, TileDataType_S64);
    let raw_profile_nan = TileProfileValueIsNaN(
        Zeros{PTO_XLEN} + 0x7ff8000000000000, TileDataType_FP64);
    let matrix_accumulate = TileProfileMatrixAccumulate(
        Zeros{PTO_XLEN} + 1, Zeros{PTO_XLEN} + 2, Zeros{PTO_XLEN} + 3,
        TileDataType_U64, TileDataType_U64, TileDataType_U64,
        DefaultNumericExecutionControl());
    let matrix_bias = TileProfileMatrixBias(Zeros{PTO_XLEN} + 7,
        Zeros{PTO_XLEN} + 2, TileDataType_U64, TileDataType_U64);
    let matrix_scaled_accumulate = TileProfileMatrixScaledAccumulate(
        Zeros{PTO_XLEN} + 5, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 3, Zeros{PTO_XLEN} + 4,
        Zeros{PTO_XLEN} + 6, TRUE, TRUE, TileDataType_FP32,
        TileDataType_E4M3, TileDataType_E5M2,
        TileDataType_E8M0, TileDataType_E8M0);
    assert tile_expand == Zeros{PTO_XLEN} + 9;
    assert tile_partial == Zeros{PTO_XLEN} + 20;
    assert tile_partial_flags == Zeros{5};
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
end;
func main() => integer
begin
    ResetProfileState();
    TestConcreteTileProfile();
    return 0;
end;
