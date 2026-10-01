<!-- GENERATED FROM: asl/tile/model/execution/execution-mask.asl -->
# Execution Mask

**Normative ASL source:** `asl/tile/model/execution/execution-mask.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MASK}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-purpose role=purpose-scope -->
## Purpose and scope

This unit captures an ExecutionMask into the bundle-scoped record `_BundleExecutionMask`. An ExecutionMask is an explicit per-coordinate predicate for an eligible Local CUBE_M16 or CUBE_M32 Tile operation.

It has two capture functions, one per carrier. `CaptureBundleExecutionMaskGPR` takes one or two scalar words. `CaptureBundleExecutionMaskPredicateTile` takes a PredicateCell, which is U8 CUBE storage holding `0x00` or `0x01` per coordinate. Both are called by `CaptureSelectedBundleExecutionMask` in the block dispatch layer, after the carrier has been selected and checked.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-concepts role=concepts-state -->
## Concepts and visible state

Both functions set `valid` to TRUE, record the carrier kind, the coordinate layout, and the coordinate valid shape. Both copy two B.DATR controls: `execution_mask_invert` (PredInv) into `invert` and `execution_mask_zero` (Zero) into `zero_inactive`. Both clear `merge_base_valid`; a separate dispatch step prepares the MERGE base.

The GPR form stores `low` in `low_word`. It stores `high` in `high_word` only when `word_count` is 2, and zero otherwise.

The PredicateCell form builds `predicate_tile_snapshot`, a 524288-bit vector. For each valid row and column it stores bit 0 of the predicate element at index `row x valid_columns + column`. It also records `predicate_tile` and zeroes both GPR words and `word_count`.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-rules role=rules-interactions -->
## Rules and interactions

`CaptureBundleExecutionMaskGPR` asserts that the layout is CUBE_M16 or CUBE_M32.

`CaptureBundleExecutionMaskPredicateTile` asserts `TileExecutionMaskPredicateCellShapeLegal`. That check requires a legal PredicateCell descriptor, a CUBE_M16 or CUBE_M32 layout equal to the `layout` argument, the same valid rows and columns, defined contents, and every valid value equal to `0x00` or `0x01`. Dispatch has already compared the PredicateCell layout with the consumer layout in the ExecutionMask schema.

Dispatch captures the mask before it resolves and allocates the operation's destinations. Every later call to `BundleExecutionMaskActiveAt` reads the captured record, not the live carrier.

Design point: the PredicateCell is copied into a snapshot at capture time. If the operation's destination is later allocated over the same register, the predicate values used for the whole operation remain the pre-operation values.

Design point: capture clears `merge_base_valid` even when Zero is 0. MERGE only becomes usable after `PrepareSelectedBundleExecutionMaskMerge` has checked the merge base, so an unchecked base can never feed inactive coordinates.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-boundaries role=boundaries -->
## Architectural boundaries

These functions do not check operation eligibility, GPR word counts against shape, or B.DATR legality. Dispatch checks eligibility with `TileOperationExecutionMaskEligible` from [predicate carriers](predicate-carriers.md); the [ExecutionMask schema](../../../block/model/dispatch/execution-mask-schema.md) checks the carrier and GPR shape before capture; and `BundleExecutionMaskDataAttributesLegal` in [command data attributes](../../../block/model/dispatch/command-data-attributes.md) checks B.DATR just after capture. Any failure raises Fault_TileLegality before the operation executes.

The mask is bundle state, not architectural register state. Bundle reset and descriptor-state reset set `valid` to FALSE, so a mask never carries from one bundle into the next.

Only bit 0 of each PredicateCell element is captured; the shape check has already required the full byte to be `0x00` or `0x01`.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-example role=example-usage -->
## Non-normative reading example

A PredicateCell has CUBE_M32 layout with valid shape 2 rows by 3 columns. Its values are row 0: `0x01 0x00 0x01` and row 1: `0x00 0x01 0x01`.

1. The snapshot indices are `row x 3 + column`. Row 0 fills indices 0, 1, 2 with 1, 0, 1. Row 1 fills indices 3, 4, 5 with 0, 1, 1.
2. With PredInv clear, 4 of the 6 coordinates are active.
3. With PredInv set, `invert` is TRUE and the 2 others, row 0 column 1 and row 1 column 0, are active instead.
4. If the operation then publishes a destination in the same register, these answers do not change.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-related role=related-owners-navigation -->
## Related owners

- [ExecutionMask state](execution-mask-state.md) reads the captured record to decide activity and inactive values.
- [ExecutionMask schema](../../../block/model/dispatch/execution-mask-schema.md) selects the carrier, calls these functions, and prepares the merge base.
- [Predicate carrier legality](../legality/predicate-carriers.md) defines `TileExecutionMaskPredicateCellShapeLegal`.
- [Predicate carriers](predicate-carriers.md) states the carrier rules in its requirement comment.
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
