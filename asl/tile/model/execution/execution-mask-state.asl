// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MASK-STATE","surface":"tile","classification":["model","execution","execution-mask-state"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-SHAPE-CUBE-CELL"]}
pure func TileCubePredicateGPRBit(
    low: Word, high: Word, layout: TileLayout,
    row: integer {0..65535}, column: integer {0..65535}) => boolean
begin
    let rows = if layout == TileLayout_CUBE_M32 then 32 else 16;
    assert row < rows && column * rows < 128;
    let packed_index = (row + column * rows) as integer {0..127};
    if packed_index < 64 then return low[packed_index] == '1'; end;
    return high[packed_index - 64] == '1';
end;
readonly func BundleExecutionMaskCoordinateBit(
    layout: TileLayout, row: integer {0..65535},
    column: integer {0..65535}) => boolean
begin
    assert _BundleExecutionMask.valid &&
           layout == _BundleExecutionMask.layout &&
           row < _BundleExecutionMask.valid_rows &&
           column < _BundleExecutionMask.valid_columns;
    if _BundleExecutionMask.carrier == BundleExecutionMask_GPR then
        assert _BundleExecutionMask.word_count == 1 ||
               _BundleExecutionMask.word_count == 2;
        return TileCubePredicateGPRBit(
            _BundleExecutionMask.low_word,
            _BundleExecutionMask.high_word, layout, row, column);
    end;
    assert _BundleExecutionMask.carrier ==
           BundleExecutionMask_PredicateTile;
    let logical_index =
        (row * _BundleExecutionMask.valid_columns + column)
            as integer {0..524287};
    return _BundleExecutionMask.predicate_tile_snapshot[logical_index] == '1';
end;
readonly func BundleExecutionMaskActiveAt(
    layout: TileLayout, row: integer {0..65535},
    column: integer {0..65535}) => boolean
begin
    if !_BundleExecutionMask.valid then return TRUE; end;
    return BundleExecutionMaskCoordinateBit(layout, row, column) !=
           _BundleExecutionMask.invert;
end;

readonly func BundleExecutionMaskDestinationValue(
    layout: TileLayout, row: integer {0..65535},
    column: integer {0..65535}, computed: Word) => Word
begin
    if !_BundleExecutionMask.valid ||
       BundleExecutionMaskActiveAt(layout, row, column) then
        return computed;
    end;
    if _BundleExecutionMask.zero_inactive then
        return Zeros{PTO_XLEN};
    end;
    assert _BundleExecutionMask.merge_base_valid;
    let base = _Tiles[[_BundleExecutionMask.merge_base]];
    let element = TileLogicalLinearIndex(base, row, column);
    return TileReadLogicalElement(base, element);
end;
