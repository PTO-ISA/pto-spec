// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-PACKED-TAIL-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"state-transition","summary":"TCVT handles odd packed tails without reading or flagging the padding lane","pass_condition":"ValidCol 1, 3, and 5 narrow into packed rows with explicit Zero, Max, and Min padding, while widening ignores an undefined tail nibble and preserves zero numeric status","related_sources":["asl/tile/model/definedness/elements.asl","asl/tile/model/definedness/packed-boundary.asl","asl/arch/profile/tcvt-conversion.asl"]}
func ConfigureTailPair(valid_columns: integer {1,3,5},
                       source_type: TileDataType,
                       destination_type: TileDataType)
begin
    // Choose capacities that give both sides the same physical row count
    // under the ordinary TCVT shape contract despite their different widths.
    ConfigureTile(0,
        if source_type == TileDataType_FP32 then 4096 else 512,
        32, 8, 1, valid_columns, source_type, TileLayout_RowMajor);
    ConfigureTile(1,
        if destination_type == TileDataType_FP32 then 4096 else 512,
        32, 8, 1, valid_columns, destination_type, TileLayout_RowMajor);
end;

func SetTailPad(pad_value: bits(2))
begin
    SetBundleDataAttributeState(DTYPE_NONE, Zeros{5}, pad_value,
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
end;

func RunNarrowTail(valid_columns: integer {1,3,5}, pad: TilePadValue,
                   expected_pad: Word)
begin
    ResetProfileState();
    ConfigureTailPair(valid_columns, TileDataType_FP32,
        TileDataType_E2M1X2);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f000000);
    if valid_columns >= 3 then
        WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x3f800000);
        WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 0x3fc00000);
    end;
    if valid_columns == 5 then
        WriteTileElement(0, 0, 3, Zeros{PTO_XLEN} + 0x40000000);
        WriteTileElement(0, 0, 4, Zeros{PTO_XLEN} + 0x40400000);
    end;
    let pad_code = if pad == TilePad_Zero then '00'
        else if pad == TilePad_Max then '01' else '10';
    SetTailPad(pad_code);
    let control = DefaultNumericExecutionControl();
    assert TileOperandsLegal_TCVT(1, 0, control);
    InstructionContractExecute_TCVT(1, 0, control);
    assert NumericStatusFlags() == Zeros{5};
    if valid_columns >= 1 then
        assert ReadTileElement(1, 0, 0) ==
            Zeros{PTO_XLEN} + 1;
    end;
    if valid_columns >= 3 then
        assert ReadTileElement(1, 0, 1) ==
            Zeros{PTO_XLEN} + 2;
        assert ReadTileElement(1, 0, 2) ==
            Zeros{PTO_XLEN} + 3;
    end;
    if valid_columns == 5 then
        assert ReadTileElement(1, 0, 3) ==
            Zeros{PTO_XLEN} + 4;
        assert ReadTileElement(1, 0, 4) ==
            Zeros{PTO_XLEN} + 5;
    end;
    assert TileElementDefined(1, 0, valid_columns);
    assert ReadTileElement(1, 0, valid_columns) == expected_pad;
end;

func RunNullNarrowTail(valid_columns: integer {1,3,5})
begin
    ResetProfileState();
    ConfigureTailPair(valid_columns, TileDataType_FP32,
        TileDataType_E2M1X2);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3f000000);
    if valid_columns >= 3 then
        WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x3f800000);
        WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 0x3fc00000);
    end;
    if valid_columns == 5 then
        WriteTileElement(0, 0, 3, Zeros{PTO_XLEN} + 0x40000000);
        WriteTileElement(0, 0, 4, Zeros{PTO_XLEN} + 0x40400000);
    end;
    SetTailPad('11');
    let control = DefaultNumericExecutionControl();
    assert TileOperandsLegal_TCVT(1, 0, control);
    InstructionContractExecute_TCVT(1, 0, control);
    assert NumericStatusFlags() == Zeros{5};
    assert !TileElementDefined(1, 0, valid_columns);
end;

func RunWideningTail()
begin
    ResetProfileState();
    ConfigureTailPair(5, TileDataType_E2M1X2, TileDataType_FP32);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 3);
    WriteTileElement(0, 0, 3, Zeros{PTO_XLEN} + 4);
    WriteTileElement(0, 0, 4, Zeros{PTO_XLEN} + 5);
    // The physical tail lane is neither valid nor defined. Its payload is
    // deliberately a nonzero nibble to prove widening does not inspect it.
    let tail = TileLogicalLinearIndex(_Tiles[[0]], 0, 5);
    _Tiles[[0]] = TileInfoWithLogicalElementAndDefined(
        _Tiles[[0]], tail, Zeros{PTO_XLEN} + 0xf, FALSE);
    SetTailPad('11');
    let control = DefaultNumericExecutionControl();
    assert TileOperandsLegal_TCVT(1, 0, control);
    InstructionContractExecute_TCVT(1, 0, control);
    assert NumericStatusFlags() == Zeros{5};
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x3f000000;
    assert ReadTileElement(1, 0, 4) == Zeros{PTO_XLEN} + 0x40a00000;
    assert !TileElementDefined(1, 0, 5);
end;

func main() => integer
begin
    RunNarrowTail(1, TilePad_Zero, Zeros{PTO_XLEN});
    RunNarrowTail(3, TilePad_Max, Zeros{PTO_XLEN} + 0x7);
    RunNarrowTail(5, TilePad_Min, Zeros{PTO_XLEN} + 0xf);
    RunNullNarrowTail(1);
    RunNullNarrowTail(3);
    RunNullNarrowTail(5);
    RunWideningTail();
    return 0;
end;
