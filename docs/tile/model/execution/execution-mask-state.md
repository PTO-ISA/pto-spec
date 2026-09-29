<!-- GENERATED FROM: asl/tile/model/execution/execution-mask-state.asl -->
# Execution Mask State

**Normative ASL source:** `asl/tile/model/execution/execution-mask-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MASK-STATE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-state-purpose role=purpose-scope -->
## Purpose and scope

This unit answers one question for each mask-aware Tile executor: is this result coordinate active under the current ExecutionMask? An ExecutionMask is an explicit per-coordinate predicate that a bundle may bind to an eligible Local CUBE_M16 or CUBE_M32 operation.

It also answers the follow-up question: what value does an inactive coordinate receive? The unit owns five readonly or pure helpers and no state of its own. The state they read, `_BundleExecutionMask`, is captured by the [ExecutionMask capture](execution-mask.md) unit.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-state-concepts role=concepts-state -->
## Concepts and visible state

`_BundleExecutionMask` records whether a mask is in force (`valid`), which carrier supplied it (GPR words or a PredicateCell snapshot), the coordinate layout and valid shape, and two B.DATR controls. `invert` comes from PredInv. `zero_inactive` comes from Zero. When MERGE is selected, `merge_base` names the Tile whose old values inactive coordinates keep.

A GPR carrier packs one bit per coordinate. `TileCubePredicateGPRBit` computes `row + column x rows`, where rows is 32 for CUBE_M32 and 16 otherwise. Indices 0 to 63 come from the low word and 64 to 127 from the high word.

A PredicateCell carrier is read from a private snapshot indexed `row x valid_columns + column`, not from the live Tile.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-state-rules role=rules-interactions -->
## Rules and interactions

`BundleExecutionMaskActiveAt` returns TRUE when no mask is in force. Otherwise it returns the coordinate bit XOR `invert`.

`BundleExecutionMaskCoordinateBit` asserts that the mask is valid, that the requested layout equals the captured layout, and that the coordinate lies inside the captured valid shape.

`BundleExecutionMaskDestinationValue` returns the computed value for an active coordinate or when no mask is in force. For an inactive coordinate it returns zero when `zero_inactive` is TRUE. Otherwise it asserts `merge_base_valid` and returns the old element of the merge base at the same row and column.

`BundleExecutionMaskHasActiveCoordinate` returns TRUE when no mask is in force; otherwise it scans the captured valid shape and reports whether any coordinate is active. Legality uses it, for example, so that an integer TDIVS or TREMS zero-divisor check applies only when some coordinate is active.

Design point: the mask is read through a snapshot, not the live predicate Tile. A later write in the same operation, including a destination that reuses the predicate register, cannot change which coordinates are active.

Design point: inversion is applied once, in `BundleExecutionMaskActiveAt`. Every executor that calls this helper sees the same polarity, so PredInv never needs per-operation handling.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-state-boundaries role=boundaries -->
## Architectural boundaries

These helpers do not decide whether an operation may take a mask. That decision is `TileOperationExecutionMaskEligible` in [predicate carriers](predicate-carriers.md) together with the block dispatch schema.

MERGE requires `merge_base_valid`. The block dispatch helper `PrepareSelectedBundleExecutionMaskMerge` sets it only after checking that the merge base is allocated, fully defined, and matches the expected layout, shape, and type. Otherwise dispatch rejects with a fault before effects.

The GPR carrier covers at most 128 bits, because `TileCubePredicateGPRBit` asserts `column x rows < 128`.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-state-example role=example-usage -->
## Non-normative reading example

Take an FP16 CUBE_M16 operation with a one-word GPR mask whose low word is `0x0000000800000000` (only bit 35 set).

1. For row 3, column 2, the packed index is 3 + 2 x 16 = 35. Bit 35 is 1, so the coordinate is active.
2. For row 4, column 2, the index is 36. That bit is 0, so the coordinate is inactive.
3. With PredInv set, `invert` is TRUE and the two answers swap.
4. With Zero clear and a valid merge base, the inactive coordinate at row 4, column 2 keeps the merge base's old element there.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-state-related role=related-owners-navigation -->
## Related owners

- [ExecutionMask capture](execution-mask.md) fills `_BundleExecutionMask` from a GPR pair or a PredicateCell.
- [Predicate carriers](predicate-carriers.md) lists the eligible operations and the GPR predicate producers.
- [ExecutionMask schema](../../../block/model/dispatch/execution-mask-schema.md) selects the carrier and prepares the merge base.
- [Elementwise execution](elementwise.md) is one of many executors that call these helpers.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/execution-mask-state.asl -->
```asl
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

readonly func BundleExecutionMaskHasActiveCoordinate() => boolean
begin
    if !_BundleExecutionMask.valid then return TRUE; end;
    for row = 0 to _BundleExecutionMask.valid_rows - 1 looplimit 65536 do
        for column = 0 to _BundleExecutionMask.valid_columns - 1
            looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   _BundleExecutionMask.layout,
                   row as integer {0..65535},
                   column as integer {0..65535}) then
                return TRUE;
            end;
        end;
    end;
    return FALSE;
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
```
<!-- GENERATED-ASL-END: unit -->
