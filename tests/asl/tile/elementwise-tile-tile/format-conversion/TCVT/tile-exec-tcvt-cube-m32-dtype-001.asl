// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-CUBE-M32-DTYPE-001","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"execution","summary":"TCVT preserves CUBE_M32 geometry while narrowing FP16 to packed E1M2X2","pass_condition":"a CUBE_M32 FP16 source with five valid columns converts to packed E1M2X2 with distinct adjacent per-column values, unchanged valid shape/layout, and undefined non-participating tail","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/tile/model/numeric/formats.asl","asl/arch/data-types/formats/e1m2x2.asl"]}
func main() => integer
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        0, 1024, 17, 5, TileDataType_FP16,
        TileLayout_CUBE_M32);
    let destination_ready = ConfigureCubeTile(
        1, 128, 17, 5, TileDataType_E1M2X2,
        TileLayout_CUBE_M32);
    assert source_ready && destination_ready;
    for row = 0 to 16 looplimit 17 do
        for column = 0 to 4 looplimit 5 do
            let source_value = if column == 0 then 0x3400
                else if column == 1 then 0x3800
                else if column == 2 then 0x3a00
                else if column == 3 then 0x3c00 else 0x3d00;
            WriteTileElement(0, row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN} + source_value);
        end;
    end;

    assert _Tiles[[0]].rows == 32;
    // CUBE_M32 FP16 stores two elements per cell column, so five valid columns
    // align to six physical columns; E1M2X2's cell quantum is eight.
    assert _Tiles[[0]].columns == 6;
    assert _Tiles[[1]].rows == 32;
    assert _Tiles[[1]].columns == 8;
    assert _Tiles[[0]].valid_rows == _Tiles[[1]].valid_rows;
    assert _Tiles[[0]].valid_columns == _Tiles[[1]].valid_columns;
    assert TileOperandsLegal_TCVT(
        1, 0, DefaultNumericExecutionControl());

    InstructionContractExecute_TCVT(
        1, 0, DefaultNumericExecutionControl());
    assert _LastFault == Fault_None;
    assert _Tiles[[1]].layout == TileLayout_CUBE_M32;
    for row = 0 to 16 looplimit 17 do
        for column = 0 to 4 looplimit 5 do
            let source_value = if column == 0 then 0x3400
                else if column == 1 then 0x3800
                else if column == 2 then 0x3a00
                else if column == 3 then 0x3c00 else 0x3d00;
            let (expected, expected_flags) = ReferenceTCVTConvert(
                Zeros{PTO_XLEN} + source_value,
                TileDataType_FP16, TileDataType_E1M2X2,
                DefaultNumericExecutionControl());
            assert expected_flags == Zeros{5};
            assert ReadTileElement(1, row as integer {0..65535},
                column as integer {0..65535}) == expected;
        end;
    end;
    assert !TileElementDefined(1, 0, 5);
    assert !TileElementDefined(1, 16, 5);
    assert NumericStatusFlags() == Zeros{5};
    assert _Tiles[[1]].contents_defined;
    return 0;
end;
