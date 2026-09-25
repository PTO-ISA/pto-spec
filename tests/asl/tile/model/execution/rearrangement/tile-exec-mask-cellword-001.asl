// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-CELLWORD-001","source":"asl/tile/model/execution/rearrangement.asl","requirements":["PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-TILE-MODEL-EXECUTION-MASK-REARRANGEMENT-001"],"kind":"execution","summary":"TPACK and TUNPACK predicate complete destination CELL-word groups","pass_condition":"U8/U16/U32 destinations receive the active full word group; undefined inactive source words are not read; MERGE and ZERO apply to each whole inactive group; M16 GPR column 3, M32 two-word GPR column 2, and PredicateCell column 3 select the intended source words","related_sources":["asl/tile/model/legality/layout-rearrangement.asl","asl/tile/model/execution/execution-mask-state.asl"]}
func RunMaskedPackCellWord(data_type: TileDataType,
    group_width: integer {1..4}, expected0: Word, expected1: Word,
    expected2: Word, expected3: Word)
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        0, 4096, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    let right_ready = ConfigureCubeTile(
        1, 4096, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    let destination_columns = (4 * group_width) as integer {4..16};
    let destination_ready = ConfigureCubeTile(
        2, 4096, 1, destination_columns, data_type, TileLayout_CUBE_M16);
    let base_ready = ConfigureCubeTile(
        3, 4096, 1, destination_columns, data_type, TileLayout_CUBE_M16);
    assert left_ready && right_ready && destination_ready && base_ready;
    WriteTileElement(0, 0, 3, Zeros{PTO_XLEN} + 0x000000aa);
    WriteTileElement(1, 0, 3, Zeros{PTO_XLEN} + 0x00332211);
    for column = 0 to destination_columns - 1 looplimit 16 do
        WriteTileElement(3, 0, column as integer {0..65535},
            Zeros{PTO_XLEN} + 0x70 + column);
    end;
    var mask = Zeros{PTO_XLEN};
    mask[48] = '1';
    CaptureBundleExecutionMaskGPR(
        mask, Zeros{PTO_XLEN}, 1, TileLayout_CUBE_M16, 1, 4);
    _BundleExecutionMask.merge_base = 3;
    _BundleExecutionMask.merge_base_valid = TRUE;
    let control = Zeros{PTO_XLEN} + 0x00000301;
    assert TileOperandsLegal_TPACK(2, 0, 1, control);
    TPACK(2, 0, 1, control);
    for element = 0 to group_width - 1 looplimit 4 do
        let expected = if element == 0 then expected0
            else if element == 1 then expected1
            else if element == 2 then expected2 else expected3;
        let column = (3 * group_width + element) as integer {0..65535};
        assert ReadTileElement(2, 0, column) == expected;
    end;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x70;

    _BundleExecutionMask.zero_inactive = TRUE;
    _BundleExecutionMask.merge_base_valid = FALSE;
    assert TileOperandsLegal_TPACK(2, 0, 1, control);
    TPACK(2, 0, 1, control);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN};
    for element = 0 to group_width - 1 looplimit 4 do
        let expected = if element == 0 then expected0
            else if element == 1 then expected1
            else if element == 2 then expected2 else expected3;
        let column = (3 * group_width + element) as integer {0..65535};
        assert ReadTileElement(2, 0, column) == expected;
    end;
end;

func RunMaskedUnpackCellWord(data_type: TileDataType,
    group_width: integer {1..4}, expected0: Word, expected1: Word,
    expected2: Word, expected3: Word)
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        0, 4096, 32, 4, TileDataType_U32, TileLayout_CUBE_M32);
    let destination_columns = (4 * group_width) as integer {4..16};
    let destination_ready = ConfigureCubeTile(
        1, 4096, 32, destination_columns, data_type, TileLayout_CUBE_M32);
    let base_ready = ConfigureCubeTile(
        2, 4096, 32, destination_columns, data_type, TileLayout_CUBE_M32);
    assert source_ready && destination_ready && base_ready;
    WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 0x44332211);
    for row = 0 to 31 looplimit 32 do
        for column = 0 to destination_columns - 1 looplimit 16 do
            let value = 0x7000 + row * destination_columns + column;
            WriteTileElement(2, row as integer {0..65535},
                column as integer {0..65535}, Zeros{PTO_XLEN} + value);
        end;
    end;
    var high_mask = Zeros{PTO_XLEN};
    high_mask[0] = '1';
    CaptureBundleExecutionMaskGPR(
        Zeros{PTO_XLEN}, high_mask, 2, TileLayout_CUBE_M32, 32, 4);
    _BundleExecutionMask.merge_base = 2;
    _BundleExecutionMask.merge_base_valid = TRUE;
    let control = Zeros{PTO_XLEN} + 0x00000201;
    assert TileOperandsLegal_TUNPACK(1, 0, control);
    TUNPACK(1, 0, control);
    for element = 0 to group_width - 1 looplimit 4 do
        let expected = if element == 0 then expected0
            else if element == 1 then expected1
            else if element == 2 then expected2 else expected3;
        let column = (2 * group_width + element) as integer {0..65535};
        assert ReadTileElement(1, 0, column) == expected;
    end;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x7000;

    _BundleExecutionMask.zero_inactive = TRUE;
    _BundleExecutionMask.merge_base_valid = FALSE;
    assert TileOperandsLegal_TUNPACK(1, 0, control);
    TUNPACK(1, 0, control);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN};
    for element = 0 to group_width - 1 looplimit 4 do
        let expected = if element == 0 then expected0
            else if element == 1 then expected1
            else if element == 2 then expected2 else expected3;
        let column = (2 * group_width + element) as integer {0..65535};
        assert ReadTileElement(1, 0, column) == expected;
    end;
end;

func RunPredicateCellPackCellWord()
begin
    ResetProfileState();
    let left_ready = ConfigureCubeTile(
        0, 4096, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    let right_ready = ConfigureCubeTile(
        1, 4096, 1, 4, TileDataType_U32, TileLayout_CUBE_M16);
    let destination_ready = ConfigureCubeTile(
        2, 4096, 1, 8, TileDataType_U16, TileLayout_CUBE_M16);
    let base_ready = ConfigureCubeTile(
        3, 4096, 1, 8, TileDataType_U16, TileLayout_CUBE_M16);
    let predicate_ready = ConfigurePredicateCell(
        4, 256, 1, 4, TileDataType_U16, TileLayout_CUBE_M16);
    assert left_ready && right_ready && destination_ready && base_ready &&
           predicate_ready;
    WriteTileElement(0, 0, 3, Zeros{PTO_XLEN} + 0x000000aa);
    WriteTileElement(1, 0, 3, Zeros{PTO_XLEN} + 0x00332211);
    for column = 0 to 7 looplimit 8 do
        WriteTileElement(3, 0, column as integer {0..65535},
            Zeros{PTO_XLEN} + 0x70 + column);
    end;
    WriteTileElement(4, 0, 3, Zeros{PTO_XLEN} + 1);
    MarkTileValidRegionDefined(4);
    CaptureBundleExecutionMaskPredicateTile(
        4, TileLayout_CUBE_M16, 1, 4);
    _BundleExecutionMask.merge_base = 3;
    _BundleExecutionMask.merge_base_valid = TRUE;
    let control = Zeros{PTO_XLEN} + 0x00000301;
    assert TileOperandsLegal_TPACK(2, 0, 1, control);
    TPACK(2, 0, 1, control);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x70;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 0x71;
    assert ReadTileElement(2, 0, 6) == Zeros{PTO_XLEN} + 0x11aa;
    assert ReadTileElement(2, 0, 7) == Zeros{PTO_XLEN} + 0x3322;

    _BundleExecutionMask.zero_inactive = TRUE;
    _BundleExecutionMask.merge_base_valid = FALSE;
    assert TileOperandsLegal_TPACK(2, 0, 1, control);
    TPACK(2, 0, 1, control);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(2, 0, 6) == Zeros{PTO_XLEN} + 0x11aa;
    assert ReadTileElement(2, 0, 7) == Zeros{PTO_XLEN} + 0x3322;
end;

func main() => integer
begin
    RunMaskedPackCellWord(TileDataType_U8, 4,
        Zeros{PTO_XLEN} + 0xaa, Zeros{PTO_XLEN} + 0x11,
        Zeros{PTO_XLEN} + 0x22, Zeros{PTO_XLEN} + 0x33);
    RunMaskedPackCellWord(TileDataType_U16, 2,
        Zeros{PTO_XLEN} + 0x11aa, Zeros{PTO_XLEN} + 0x3322,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    RunMaskedPackCellWord(TileDataType_U32, 1,
        Zeros{PTO_XLEN} + 0x332211aa, Zeros{PTO_XLEN},
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    RunMaskedUnpackCellWord(TileDataType_U8, 4,
        Zeros{PTO_XLEN} + 0x22, Zeros{PTO_XLEN} + 0x33,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    RunMaskedUnpackCellWord(TileDataType_U16, 2,
        Zeros{PTO_XLEN} + 0x3322, Zeros{PTO_XLEN},
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    RunMaskedUnpackCellWord(TileDataType_U32, 1,
        Zeros{PTO_XLEN} + 0x3322, Zeros{PTO_XLEN},
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    RunPredicateCellPackCellWord();
    return 0;
end;
