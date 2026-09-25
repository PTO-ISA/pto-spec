// PTO-TEST: {"id":"PTO-AVS-TILE-EXPANSION-OPERATION-VIEW-R4-001","source":"asl/tile/model/legality/reduction-and-expansion.asl","requirements":["PTO-TROWEXPANDMUL-CONTRACT-001","PTO-TCOLEXPANDMUL-CONTRACT-001","PTO-TROWEXPAND-CONTRACT-001","PTO-TCOLEXPAND-CONTRACT-001"],"kind":"execution","summary":"Row and column expansion consume equal-width source carriers through the selected operation view and only the selected broadcast axis.","pass_condition":"Cross-backing BF16 arithmetic succeeds for RowMajor and CUBE layouts, raw COPY preserves bits without status, TF32 ignored broadcast extras may contain invalid encodings, and selected invalid values or wrong-width views reject.","related_sources":["asl/tile/model/execution/expansion.asl","asl/tile/model/legality/dtype-layout.asl"]}
func main() => integer
begin
    ResetProfileState();

    // Row operation view: BF16 source bits may be backed by BF16 and U16
    // independently.  The row broadcast has extra columns with distinct
    // values; only column zero supplies each result.
    ConfigureTile(1, 128, 16, 4, 2, 2,
        TileDataType_BF16, TileLayout_RowMajor);
    ConfigureTile(2, 128, 16, 4, 2, 3,
        TileDataType_U16, TileLayout_RowMajor);
    ConfigureTile(3, 128, 16, 4, 2, 2,
        TileDataType_BF16, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(1, 1, 1, Zeros{PTO_XLEN} + 0x4080);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0x4110);
    WriteTileElement(2, 0, 2, Zeros{PTO_XLEN} + 0x4140);
    WriteTileElement(2, 1, 0, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(2, 1, 1, Zeros{PTO_XLEN} + 0x4180);
    WriteTileElement(2, 1, 2, Zeros{PTO_XLEN} + 0x41a0);
    ExecuteTileExpand(TileExpand_MUL, TileAxis_Row, 3, 1, 2);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(3, 0, 1) == Zeros{PTO_XLEN} + 0x4080;
    assert ReadTileElement(3, 1, 0) == Zeros{PTO_XLEN} + 0x4110;
    assert ReadTileElement(3, 1, 1) == Zeros{PTO_XLEN} + 0x4140;

    // Symmetric backing types in CUBE_M16.
    let row_source_u16 = ConfigureCubeTile(4, 128, 2, 2,
        TileDataType_U16, TileLayout_CUBE_M16);
    let row_broadcast_bf16 = ConfigureCubeTile(5, 128, 2, 3,
        TileDataType_BF16, TileLayout_CUBE_M16);
    let row_destination_m16 = ConfigureCubeTile(6, 128, 2, 2,
        TileDataType_BF16, TileLayout_CUBE_M16);
    assert row_source_u16 && row_broadcast_bf16 && row_destination_m16;
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(4, 1, 0, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(4, 1, 1, Zeros{PTO_XLEN} + 0x4080);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 0x4110);
    WriteTileElement(5, 0, 2, Zeros{PTO_XLEN} + 0x4140);
    WriteTileElement(5, 1, 0, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(5, 1, 1, Zeros{PTO_XLEN} + 0x4180);
    WriteTileElement(5, 1, 2, Zeros{PTO_XLEN} + 0x41a0);
    ExecuteTileExpand(TileExpand_MUL, TileAxis_Row, 6, 4, 5);
    assert ReadTileElement(6, 0, 0) == Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(6, 1, 1) == Zeros{PTO_XLEN} + 0x4140;

    // Column operation view is symmetric and selects row zero only.
    let column_source_u16 = ConfigureCubeTile(7, 128, 2, 2,
        TileDataType_U16, TileLayout_CUBE_M32);
    let column_broadcast_bf16 = ConfigureCubeTile(8, 128, 2, 2,
        TileDataType_BF16, TileLayout_CUBE_M32);
    let column_destination_bf16 = ConfigureCubeTile(9, 128, 2, 2,
        TileDataType_BF16, TileLayout_CUBE_M32);
    assert column_source_u16 && column_broadcast_bf16 &&
           column_destination_bf16;
    WriteTileElement(7, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(7, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(7, 1, 0, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(7, 1, 1, Zeros{PTO_XLEN} + 0x4080);
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(8, 1, 0, Zeros{PTO_XLEN} + 0x4110);
    WriteTileElement(8, 1, 1, Zeros{PTO_XLEN} + 0x4140);
    ExecuteTileExpand(TileExpand_MUL, TileAxis_Column, 9, 7, 8);
    assert ReadTileElement(9, 0, 0) == Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(9, 0, 1) == Zeros{PTO_XLEN} + 0x40c0;
    assert ReadTileElement(9, 1, 0) == Zeros{PTO_XLEN} + 0x40c0;
    assert ReadTileElement(9, 1, 1) == Zeros{PTO_XLEN} + 0x4140;

    // TF32 ignored broadcast elements stay fully defined but are not
    // validated as operation-view numbers.  Their noncanonical sentinel
    // values do not affect row or column results.
    let tf32_row_source = ConfigureCubeTile(10, 256, 2, 2,
        TileDataType_U32, TileLayout_CUBE_M32);
    let tf32_row_broadcast = ConfigureCubeTile(11, 256, 2, 2,
        TileDataType_U32, TileLayout_CUBE_M32);
    let tf32_row_destination = ConfigureCubeTile(12, 256, 2, 2,
        TileDataType_TF32, TileLayout_CUBE_M32);
    assert tf32_row_source && tf32_row_broadcast && tf32_row_destination;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(10, row, column, Zeros{PTO_XLEN} + 0x3f800000);
        end;
    end;
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 0x3f800001);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(11, 1, 1, Zeros{PTO_XLEN} + 0x3f800001);
    assert _Tiles[[11]].contents_defined;
    assert !TileNumericEncodingValid(
        TileDataType_TF32, Zeros{PTO_XLEN} + 0x3f800001);
    assert TileOperandsLegal_ExecuteTileExpand(
        TileExpand_MUL, TileAxis_Row, 12, 10, 11);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 0x3f800001);
    assert !TileOperandsLegal_ExecuteTileExpand(
        TileExpand_MUL, TileAxis_Row, 12, 10, 11);

    let tf32_column_source = ConfigureCubeTile(13, 256, 2, 2,
        TileDataType_U32, TileLayout_CUBE_M32);
    let tf32_column_broadcast = ConfigureCubeTile(14, 256, 2, 2,
        TileDataType_U32, TileLayout_CUBE_M32);
    let tf32_column_destination = ConfigureCubeTile(15, 256, 2, 2,
        TileDataType_TF32, TileLayout_CUBE_M32);
    assert tf32_column_source && tf32_column_broadcast &&
           tf32_column_destination;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(13, row, column,
                Zeros{PTO_XLEN} + 0x3f800000);
        end;
    end;
    WriteTileElement(14, 0, 0, Zeros{PTO_XLEN} + 0x40000000);
    WriteTileElement(14, 0, 1, Zeros{PTO_XLEN} + 0x40400000);
    WriteTileElement(14, 1, 0, Zeros{PTO_XLEN} + 0x3f800001);
    WriteTileElement(14, 1, 1, Zeros{PTO_XLEN} + 0x3f800001);
    assert !TileNumericEncodingValid(
        TileDataType_TF32, Zeros{PTO_XLEN} + 0x3f800001);
    assert TileOperandsLegal_ExecuteTileExpand(
        TileExpand_MUL, TileAxis_Column, 15, 13, 14);
    WriteTileElement(14, 0, 1, Zeros{PTO_XLEN} + 0x3f800001);
    assert !TileOperandsLegal_ExecuteTileExpand(
        TileExpand_MUL, TileAxis_Column, 15, 13, 14);

    // Raw row COPY accepts an equal-width backing view, copies unchanged
    // payload bits, and does not change numeric status.
    let copy_source = ConfigureCubeTile(16, 256, 2, 3,
        TileDataType_U16, TileLayout_CUBE_M32);
    let copy_destination = ConfigureCubeTile(17, 128, 2, 2,
        TileDataType_BF16, TileLayout_CUBE_M32);
    assert copy_source && copy_destination;
    for row = 0 to 1 looplimit 2 do
        WriteTileElement(16, row, 0,
            if row == 0 then Zeros{PTO_XLEN} + 0xffff
            else Zeros{PTO_XLEN} + 0xdead);
        WriteTileElement(16, row, 1, Zeros{PTO_XLEN} + 0x1234);
        WriteTileElement(16, row, 2, Zeros{PTO_XLEN} + 0x5678);
    end;
    assert NumericStatusFlags() == Zeros{5};
    ExecuteTileExpand(TileExpand_COPY, TileAxis_Row,
        17, 16, 16);
    assert ReadTileElement(17, 0, 0) == Zeros{PTO_XLEN} + 0xffff;
    assert ReadTileElement(17, 1, 1) == Zeros{PTO_XLEN} + 0xdead;
    assert NumericStatusFlags() == Zeros{5};

    // Column COPY has the same raw cross-backing rule and consumes row zero
    // even when the fully defined source contains additional rows.
    let column_copy_source = ConfigureCubeTile(21, 256, 2, 2,
        TileDataType_U16, TileLayout_CUBE_M32);
    let column_copy_destination = ConfigureCubeTile(22, 128, 2, 2,
        TileDataType_BF16, TileLayout_CUBE_M32);
    assert column_copy_source && column_copy_destination;
    WriteTileElement(21, 0, 0, Zeros{PTO_XLEN} + 0xffff);
    WriteTileElement(21, 0, 1, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(21, 1, 0, Zeros{PTO_XLEN} + 0x1234);
    WriteTileElement(21, 1, 1, Zeros{PTO_XLEN} + 0x5678);
    ExecuteTileExpand(TileExpand_COPY, TileAxis_Column,
        22, 21, 21);
    assert ReadTileElement(22, 0, 0) == Zeros{PTO_XLEN} + 0xffff;
    assert ReadTileElement(22, 1, 0) == Zeros{PTO_XLEN} + 0xffff;
    assert ReadTileElement(22, 0, 1) == Zeros{PTO_XLEN} + 0x3f80;
    assert ReadTileElement(22, 1, 1) == Zeros{PTO_XLEN} + 0x3f80;
    assert NumericStatusFlags() == Zeros{5};

    // A mismatched carrier width and a wrong row-axis geometry are rejected.
    let wrong_width_source = ConfigureCubeTile(18, 256, 2, 2,
        TileDataType_U32, TileLayout_CUBE_M32);
    let wrong_width_broadcast = ConfigureCubeTile(19, 128, 2, 2,
        TileDataType_U16, TileLayout_CUBE_M32);
    let wrong_width_destination = ConfigureCubeTile(20, 128, 2, 2,
        TileDataType_BF16, TileLayout_CUBE_M32);
    assert wrong_width_source && wrong_width_broadcast &&
           wrong_width_destination;
    WriteTileElement(18, 0, 0, Zeros{PTO_XLEN} + 0x3f800000);
    WriteTileElement(19, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    assert !TileOperandsLegal_ExecuteTileExpand(
        TileExpand_MUL, TileAxis_Row, 20, 18, 19);
    assert !TileOperandsLegal_ExecuteTileExpand(
        TileExpand_MUL, TileAxis_Row, 3, 1, 8);
    return 0;
end;
