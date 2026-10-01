<!-- GENERATED FROM: asl/tile/model/ordering/sorting.asl -->
# Sorting

**Normative ASL source:** `asl/tile/model/ordering/sorting.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-ORDERING-SORTING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-ordering-sorting-purpose role=purpose-scope -->
## Purpose and scope

This unit defines an ordering relation on floating-point Tile values and a few predicates built on it. The relation says when a left value may stay before a right value in a sorted sequence.

In the current ASL no other unit calls these helpers. The `TSORT` and `TMRGSORT` operations were retired by ADR-TILE-0013, and their names now appear in the tile catalog's `deleted_names` list. Read this page as the definition of the helpers only, not of an active instruction.

<!-- PTO-READER-BLOCK: tile-model-ordering-sorting-concepts role=concepts-state -->
## Concepts and visible state

The unit declares no state. It defines six helpers:

- `TileSortDataTypeSupported` is TRUE only for FP32 and FP16.
- `TileSortValueIsSignalingNaN` is TRUE when the value's numeric class is `NumericValue_SignalingNaN`.
- `TileSortLeftBefore(left, right, descending, data_type)` is the ordering relation.
- `TileSortSourceValuesLegal` requires the source Tile to be defined and all its encodings valid.
- `TileSortSourceHasSignalingNaN` scans the valid region for a signaling NaN.
- `TileSortSequenceOrdered` checks that row 0 of a Tile is ordered.

<!-- PTO-READER-BLOCK: tile-model-ordering-sorting-rules role=rules-interactions -->
## Rules and interactions

`TileSortLeftBefore` decides in this order:

1. If `left` is a NaN, the result is TRUE only when `right` is also a NaN.
2. If only `right` is a NaN, the result is TRUE.
3. If both values are zeros, or the two words are identical, the result is TRUE.
4. Otherwise both values are mapped through `TileFloatingOrderKey` and compared as unsigned integers: `<` for ascending, `>` for descending.

`TileFloatingOrderKey` inverts all bits of a negative value and sets the sign bit of a non-negative one. The unsigned order of the keys follows the numeric order of the non-NaN values, including infinities, and places `-0` just below `+0`; rule 3 handles the zero pair before the keys are compared.

Design point: NaNs sort after every number in both directions. The descending flag changes only step 4, so NaN placement does not flip. The ASL comment states that two NaNs retain their incoming order.

Design point: equal values and signed zeros return TRUE. A pair that compares equal is never reported as out of order, so `-0` and `+0` may appear in either order.

Step 1 and step 2 use `NumericValueClassIsNaN`, which is TRUE for both quiet and signaling NaNs. The comment in the ASL speaks of quiet NaNs; `TileSortSourceHasSignalingNaN` is the separate helper that finds signaling NaNs.

<!-- PTO-READER-BLOCK: tile-model-ordering-sorting-boundaries role=boundaries -->
## Architectural boundaries

`TileSortSequenceOrdered` returns TRUE when the valid column count is at most 1. Otherwise it checks each adjacent pair of row 0 and does not look at other rows. The helpers perform no allocation, write no Tile, and raise no fault.

This unit does not define a sort instruction, its operands, its stability, or its index output. Those belonged to the retired `TSORT` owner.

<!-- PTO-READER-BLOCK: tile-model-ordering-sorting-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Take FP32 row 0 as `-2.0`, `-0.0`, `+0.0`, `3.0`, `NaN`. In ascending order every adjacent pair satisfies the relation: `-2.0` before `-0.0` by key, the two zeros by rule 3, `+0.0` before `3.0` by key, and `3.0` before `NaN` by rule 2. `TileSortSequenceOrdered` returns TRUE. With `descending` set, the same row fails at its first pair, because the key of `-2.0` is below the key of `-0.0`.

<!-- PTO-READER-BLOCK: tile-model-ordering-sorting-related role=related-owners-navigation -->
## Related owners

- [Comparison](../execution/comparison.md) owns `TileFloatingOrderKey`.
- [Numeric formats](../numeric/formats.md) owns numeric value classification.
- [Top-level dispatch](../dispatch/top-level.md) records `TSORT` and `TMRGSORT` as deleted names.
- [Element definedness](../definedness/elements.md) owns the source encoding checks.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/ordering/sorting.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-ORDERING-SORTING","surface":"tile","classification":["model","ordering","sorting"],"depends_on":["PTO-TILE-MODEL-EXECUTION-COMPARISON"]}

pure func TileSortDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16;
end;

pure func TileSortValueIsSignalingNaN(
    data_type: TileDataType,
    value: Word) => boolean
begin
    return TileNumericValueClass(data_type, value) ==
        NumericValue_SignalingNaN;
end;

pure func TileSortLeftBefore(
    left: Word,
    right: Word,
    descending: boolean,
    data_type: TileDataType) => boolean
begin
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    let left_nan = NumericValueClassIsNaN(left_class);
    let right_nan = NumericValueClassIsNaN(right_class);

    // Every numeric value precedes every quiet NaN in both directions.
    // Two NaNs retain their incoming order.
    if left_nan then
        return right_nan;
    elsif right_nan then
        return TRUE;
    end;

    let both_zero =
        NumericValueClassIsZero(left_class) &&
        NumericValueClassIsZero(right_class);
    if both_zero || left == right then
        return TRUE;
    end;

    let left_key = TileFloatingOrderKey(data_type, left);
    let right_key = TileFloatingOrderKey(data_type, right);
    if descending then
        return UInt(left_key) > UInt(right_key);
    end;
    return UInt(left_key) < UInt(right_key);
end;

readonly func TileSortSourceValuesLegal(
    source: TileIndex) => boolean
begin
    return TileSourceContentsDefined(source) &&
           TileSourceEncodingsValid(source);
end;

readonly func TileSortSourceHasSignalingNaN(
    source: TileIndex) => boolean
begin
    let source_tile = _Tiles[[source]];
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                source_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if TileSortValueIsSignalingNaN(
                   source_tile.data_type,
                   TileReadLogicalElement(source_tile, element)) then
                return TRUE;
            end;
        end;
    end;
    return FALSE;
end;

readonly func TileSortSequenceOrdered(
    source: TileIndex,
    descending: boolean) => boolean
begin
    let source_tile = _Tiles[[source]];
    if source_tile.valid_columns <= 1 then
        return TRUE;
    end;

    for column = 0 to source_tile.valid_columns - 2 looplimit 65536 do
        let left_element = TileLogicalLinearIndex(
            source_tile,
            0,
            column as integer {0..65535});
        let right_element = TileLogicalLinearIndex(
            source_tile,
            0,
            (column + 1) as integer {0..65535});
        if !TileSortLeftBefore(
               TileReadLogicalElement(source_tile, left_element),
               TileReadLogicalElement(source_tile, right_element),
               descending,
               source_tile.data_type) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
