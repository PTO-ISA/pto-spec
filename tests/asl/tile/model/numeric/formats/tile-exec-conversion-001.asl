// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILECONVERSION-EXECUTION-001","source":"asl/tile/model/numeric/formats.asl","requirements":[],"kind":"execution","summary":"Covers Tile Conversion.","pass_condition":"TestTileConversion completes without assertion failure","related_sources":[]}
func TestTileConversion()
begin
    // PTO-REQ-TEPL-CONVERT-001: public integer conversion rules interpret
    // source signedness before destination truncation or extension.
    let (signed_widen, signed_widen_flags) = TileConvertValue(
        Zeros{PTO_XLEN} + 0x80,
        TileDataType_S8, TileDataType_S16, DefaultNumericExecutionControl());
    let (unsigned_widen, unsigned_widen_flags) = TileConvertValue(
        Zeros{PTO_XLEN} + 0xff,
        TileDataType_U8, TileDataType_U16, DefaultNumericExecutionControl());
    let (signed_narrow, signed_narrow_flags) = TileConvertValue(
        Zeros{PTO_XLEN} + 0x01ff,
        TileDataType_S16, TileDataType_U8, DefaultNumericExecutionControl());
    let (unsigned_to_signed, unsigned_to_signed_flags) = TileConvertValue(
        Zeros{PTO_XLEN} + 0xffff,
        TileDataType_U16, TileDataType_S8, DefaultNumericExecutionControl());
    let (wide_narrow, wide_narrow_flags) = TileConvertValue(Ones{PTO_XLEN},
        TileDataType_S64, TileDataType_U8, DefaultNumericExecutionControl());
    assert signed_widen == Ones{PTO_XLEN} - 127;
    assert unsigned_widen == Zeros{PTO_XLEN} + 0xff;
    assert signed_narrow == Zeros{PTO_XLEN} + 0xff;
    assert unsigned_to_signed == Ones{PTO_XLEN};
    assert wide_narrow == Zeros{PTO_XLEN} + 0xff;
    assert signed_widen_flags == Zeros{5};
    assert unsigned_widen_flags == Zeros{5};
    assert signed_narrow_flags == Zeros{5};
    assert unsigned_to_signed_flags == Zeros{5};
    assert wide_narrow_flags == Zeros{5};

    let conversion_operation = DecodeTileOperation(TileDecode_TEPL, '000000011011')
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    ConfigureTile(38, 256, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Vector);
    ConfigureTile(39, 256, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Vector);
    var numeric_operands = DefaultTileInstructionOperands();
    numeric_operands.destination0 = 39;
    numeric_operands.source0 = 38;
    let default_fp_to_integer = ResolveTileNumericExecutionControl(
        conversion_operation, numeric_operands);
    assert default_fp_to_integer.rounding_mode == NumericRound_RTZ;
    assert !default_fp_to_integer.saturating;
    numeric_operands.numeric_control = DecodeBundleRoundingSelection('101');
    numeric_operands.numeric_control.saturating = TRUE;
    let explicit_rna = ResolveTileNumericExecutionControl(
        conversion_operation, numeric_operands);
    assert explicit_rna.rounding_mode == NumericRound_RNA;
    assert explicit_rna.saturating;

    ConfigureTile(40, 2048, 128, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Vector);
    ConfigureTile(41, 256, 128, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Vector);
    WriteTileElement(40, 0, 0, Zeros{PTO_XLEN} + 257);
    WriteTileElement(40, 0, 1, Zeros{PTO_XLEN} + 100);
    TCVT(41, 40, DefaultNumericExecutionControl());
    assert ReadTileElement(41, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(41, 0, 1) == Zeros{PTO_XLEN} + 100;

    ConfigureTile(40, 256, 128, 2, 1, 2, TileDataType_S8,
        TileLayout_RowMajor, TileLocation_Vector);
    ConfigureTile(41, 512, 128, 2, 1, 2, TileDataType_S16,
        TileLayout_RowMajor, TileLocation_Vector);
    WriteTileElement(40, 0, 0, Zeros{PTO_XLEN} + 0x80);
    WriteTileElement(40, 0, 1, Zeros{PTO_XLEN} + 0x7f);
    TCVT(41, 40, DefaultNumericExecutionControl());
    assert ReadTileElement(41, 0, 0) == Ones{PTO_XLEN} - 127;
    assert ReadTileElement(41, 0, 1) == Zeros{PTO_XLEN} + 0x7f;

    ConfigureTile(40, 256, 32, 2, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Vector);
    ConfigureTile(41, 256, 128, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Vector);
    ConfigureTile(42, 256, 32, 2, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Vector);
    WriteTileElement(40, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(40, 0, 1, Zeros{PTO_XLEN} + 0x40000000);
    assert ReadTileElement(41, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(42, 0, 1) ==
        Zeros{PTO_XLEN} + 0x40000000;
end;
func main() => integer
begin
    ResetProfileState();
    TestTileConversion();
    return 0;
end;
