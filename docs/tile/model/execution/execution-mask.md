<!-- GENERATED FROM: asl/tile/model/execution/execution-mask.asl -->
# Execution Mask

**Normative ASL source:** `asl/tile/model/execution/execution-mask.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MASK}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/execution-mask.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MASK","surface":"tile","classification":["model","execution","execution-mask"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS","PTO-TILE-MODEL-STATE-ALLOCATION"]}
func CaptureBundleExecutionMaskGPR(
    low: Word, high: Word, word_count: integer {1..2},
    layout: TileLayout, valid_rows: integer {1..65535},
    valid_columns: integer {1..65535})
begin
    assert layout == TileLayout_CUBE_M16 || layout == TileLayout_CUBE_M32;
    _BundleExecutionMask.valid = TRUE;
    _BundleExecutionMask.carrier = BundleExecutionMask_GPR;
    _BundleExecutionMask.predicate_tile = 0;
    _BundleExecutionMask.predicate_source_ordinal = 0;
    _BundleExecutionMask.low_word = low;
    _BundleExecutionMask.high_word =
        if word_count == 2 then high else Zeros{PTO_XLEN};
    _BundleExecutionMask.word_count = word_count;
    _BundleExecutionMask.layout = layout;
    _BundleExecutionMask.valid_rows = valid_rows;
    _BundleExecutionMask.valid_columns = valid_columns;
    _BundleExecutionMask.invert =
        _BundleDataAttributes.execution_mask_invert;
    _BundleExecutionMask.zero_inactive =
        _BundleDataAttributes.execution_mask_zero;
    _BundleExecutionMask.merge_base_valid = FALSE;
end;
func CaptureBundleExecutionMaskPredicateTile(
    predicate: TileIndex, layout: TileLayout,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535})
begin
    assert TileExecutionMaskPredicateCellShapeLegal(
        predicate, layout, valid_rows, valid_columns);
    let source = _Tiles[[predicate]];
    var snapshot = Zeros{524288};
    for row = 0 to valid_rows - 1 looplimit 65536 do
        for column = 0 to valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                source, row as integer {0..65535},
                column as integer {0..65535});
            let logical_index = (row * valid_columns + column)
                as integer {0..524287};
            snapshot[logical_index] = source.payload[[element]][0];
        end;
    end;
    _BundleExecutionMask.valid = TRUE;
    _BundleExecutionMask.carrier = BundleExecutionMask_PredicateTile;
    _BundleExecutionMask.predicate_tile = predicate;
    _BundleExecutionMask.predicate_source_ordinal = 0;
    _BundleExecutionMask.low_word = Zeros{PTO_XLEN};
    _BundleExecutionMask.high_word = Zeros{PTO_XLEN};
    _BundleExecutionMask.word_count = 0;
    _BundleExecutionMask.layout = layout;
    _BundleExecutionMask.valid_rows = valid_rows;
    _BundleExecutionMask.valid_columns = valid_columns;
    _BundleExecutionMask.invert =
        _BundleDataAttributes.execution_mask_invert;
    _BundleExecutionMask.zero_inactive =
        _BundleDataAttributes.execution_mask_zero;
    _BundleExecutionMask.merge_base_valid = FALSE;
    _BundleExecutionMask.predicate_tile_snapshot = snapshot;
end;
```
<!-- GENERATED-ASL-END: unit -->
