<!-- GENERATED FROM: asl/block/model/dispatch/expansion-schema.asl -->
# Expansion Schema

**Normative ASL source:** `asl/block/model/dispatch/expansion-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-expansion-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit is the closed bundle schema for the sixteen row and column expansions. An expansion broadcasts one value per row (row forms) or one value per column (column forms) from a broadcast Tile across a full rectangle. A closed schema is the complete list of bindings, dimensions, types, and layouts that a bundle for the family may carry.

It defines these classifiers and one legality predicate:

- `TileOperationUsesClosedRowExpansionSchema` selects `TROWEXPAND` and the seven `TROWEXPAND*` forms (ADD, SUB, MUL, DIV, MAX, MIN, EXPDIF).
- `TileOperationUsesClosedColumnExpansionSchema` selects the eight matching `TCOLEXPAND` forms.
- `TileExpansionOperationIsCopy` selects the two plain copies, `TROWEXPAND` and `TCOLEXPAND`, which have no full-shape source.
- `TileExpansionOperationIsExponentialDifference` selects the two EXPDIF forms.
- `SelectedBundleClosedExpansionSchemaLegal` checks a complete bundle.

<!-- PTO-READER-BLOCK: block-model-dispatch-expansion-schema-concepts role=concepts-state -->
## Concepts and visible state

The unit only reads state and raises no fault by itself.

- `_BundleDimensions` gives `LB0` (valid columns), `LB1` (valid rows), and `LB2` (physical columns).
- `_BundleTileBindings` supplies the full-shape source (`source0` of the operation binding), the broadcast source, and the destination.
- `_BundleExecutionMask` tells whether an ExecutionMask is in force and whether its carrier is a GPR or a predicate Tile.
- `_BundleScalarBindings` index 0 must be present exactly when the mask carrier is a GPR.
- `_Tiles` supplies descriptors and element values of both sources.

The broadcast Tile is `source0` for a copy and `source1` of the operation binding otherwise.

<!-- PTO-READER-BLOCK: block-model-dispatch-expansion-schema-rules role=rules-interactions -->
## Rules and interactions

The binding stream depends on the operation and the mask carrier:

| Case | Bindings | Shape |
| --- | --- | --- |
| No mask or GPR mask | 1 | copy: `source0` and destination, no `source1`; others: `source0`, `source1`, destination, `last` |
| Predicate Tile mask, copy | 1 | `source0`, mask as `source1`, destination; mask ordinal 1 |
| Predicate Tile mask, other forms | 2 | binding 0: two sources, no destination, not `last`; binding 1: mask as `source0`, destination, `last`; mask ordinal 2 |

In every case the destination is not already allocated by the bundle and its size code is legal, no Shared binding exists, and all three dimensions are in 1 to 65535. A GPR mask must also pass `BundleExecutionMaskGPRBindingSchemaLegal`.

The type and layout rules are:

- The data type is in the vector-arithmetic set. EXPDIF forms instead take their source and destination types from `SelectedBundleExponentialDifferenceTypes`, which must report a legal pair.
- The layout is `RowMajor`, `CUBE_M16`, or `CUBE_M32`. The broadcast Tile, and for non-copy forms the full-shape source, use that same layout.
- A row broadcast has `valid_rows` equal to `LB1` and at least one valid column. A column broadcast has `valid_columns` equal to `LB0` and at least one valid row.
- For non-copy forms, the full-shape source must match `LB0`, `LB1`, and `LB2`, be defined at its active coordinates, and hold valid encodings of the source operation type at those coordinates.
- For `TROWEXPANDDIV` and `TCOLEXPANDDIV` with an integer type, every broadcast value read for a source coordinate must be defined and nonzero; under an ExecutionMask only active coordinates count.

Design point: a copy checks broadcast elements with encoding validation off and requires only a width-compatible carrier. The other forms validate each consumed broadcast encoding against the source operation type, because they compute with it.

Design point: the integer zero-divisor test is part of the schema. It runs before destination resolution, so a zero divisor raises `Fault_TileLegality` and leaves no new Tile allocated.

<!-- PTO-READER-BLOCK: block-model-dispatch-expansion-schema-boundaries role=boundaries -->
## Architectural boundaries

This unit does not compute the expansion or allocate the destination. Destination shaping is in [destination operation](destination-operation.md): every form takes the destination valid columns and valid rows from `LB0` and `LB1`, and EXPDIF forms also take the destination type from the EXPDIF type pair. The broadcast slot selection for CUBE layouts and the per-coordinate definedness tests are owned by Tile reduction and expansion legality.

<!-- PTO-READER-BLOCK: block-model-dispatch-expansion-schema-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Consider `TROWEXPANDADD <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>`. `T#1` is the full-shape source, with 8 valid rows and 64 valid and physical columns. `T#2` is the row broadcast source with 8 valid rows. In `RowMajor` the broadcast value for row r is column 0 of row r. One `B.IOT` carries both sources, the destination, and `last`.

The schema passes when both Tiles are defined `RowMajor` `FP32` Tiles with those shapes. The 2KB destination holds 8 x 64 = 512 `FP32` elements. If `T#2` had 7 valid rows, the broadcast shape check would fail and the bundle would raise `Fault_TileLegality`.

<!-- PTO-READER-BLOCK: block-model-dispatch-expansion-schema-related role=related-owners-navigation -->
## Related owners

- [Tile execution dispatch](tile-execution.md) evaluates this predicate with the other closed schemas before destination resolution.
- [EXPDIF schema](expdif-schema.md) selects the EXPDIF source and destination types.
- [Scalar schema](scalar-schema.md) defines the GPR ExecutionMask binding check.
- [Reduction and expansion legality](../../../tile/model/legality/reduction-and-expansion.md) owns broadcast and source legality.
- [TROWEXPANDADD](../../../tile/reduce-and-expand/row-expansion/TROWEXPANDADD.md) is one instruction page that uses this schema.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/expansion-schema.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","expansion-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-EXPDIF-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"],"id":"PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","surface":"block"}

pure func TileOperationUsesClosedRowExpansionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWEXPAND ||
           decoded == TileOperation_TROWEXPANDADD ||
           decoded == TileOperation_TROWEXPANDSUB ||
           decoded == TileOperation_TROWEXPANDMUL ||
           decoded == TileOperation_TROWEXPANDDIV ||
           decoded == TileOperation_TROWEXPANDMAX ||
           decoded == TileOperation_TROWEXPANDMIN ||
           decoded == TileOperation_TROWEXPANDEXPDIF;
end;

pure func TileOperationUsesClosedColumnExpansionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TCOLEXPAND ||
           decoded == TileOperation_TCOLEXPANDADD ||
           decoded == TileOperation_TCOLEXPANDSUB ||
           decoded == TileOperation_TCOLEXPANDMUL ||
           decoded == TileOperation_TCOLEXPANDDIV ||
           decoded == TileOperation_TCOLEXPANDMAX ||
           decoded == TileOperation_TCOLEXPANDMIN ||
           decoded == TileOperation_TCOLEXPANDEXPDIF;
end;

pure func TileOperationUsesClosedExpansionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationUsesClosedRowExpansionSchema(operation) ||
           TileOperationUsesClosedColumnExpansionSchema(operation);
end;

pure func TileExpansionOperationIsCopy(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWEXPAND ||
           decoded == TileOperation_TCOLEXPAND;
end;

pure func TileExpansionOperationIsExponentialDifference(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWEXPANDEXPDIF ||
           decoded == TileOperation_TCOLEXPANDEXPDIF;
end;

readonly func SelectedBundleExpansionBroadcastShapeMatches(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    broadcast: TileIndex) => boolean
begin
    let valid_columns = UInt(_BundleDimensions[[0]]);
    let valid_rows = UInt(_BundleDimensions[[1]]);
    if TileOperationUsesClosedRowExpansionSchema(operation) then
        return _Tiles[[broadcast]].valid_rows == valid_rows &&
               _Tiles[[broadcast]].valid_columns >= 1;
    end;
    return _Tiles[[broadcast]].valid_rows >= 1 &&
           _Tiles[[broadcast]].valid_columns == valid_columns;
end;

readonly func SelectedBundleClosedExpansionSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedExpansionSchema(operation) then
        return TRUE;
    end;
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let copy = TileExpansionOperationIsCopy(operation);
    let split_final_binding = execution_mask_tile && !copy;
    if BundleTileBindingCount() != (if split_final_binding then 2 else 1) ||
       BundleSharedBindingCount() != 0 ||
       (_BundleScalarBindings[[0]].valid != execution_mask_gpr) ||
       (execution_mask_gpr &&
        !BundleExecutionMaskGPRBindingSchemaLegal(operation)) ||
       !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    let final_binding = if split_final_binding then
        _BundleTileBindings[[1]] else binding;
    if BundleTileBindingCount() != (if split_final_binding then 2 else 1) ||
       !final_binding.destination_valid ||
       final_binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(
           if split_final_binding then 1 else 0) ||
       !binding.source0_valid ||
       (if copy then
            binding.source1_valid != execution_mask_tile
        else if split_final_binding then
            !binding.source1_valid || binding.destination_valid || binding.last ||
            final_binding.source0_valid != execution_mask_tile ||
            final_binding.source1_valid || !final_binding.last
        else
            !binding.source1_valid || !binding.last) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal !=
            (if copy then 1 else 2)) then
        return FALSE;
    end;

    let operation_sources = if split_final_binding then
        binding else final_binding;
    let broadcast = if copy then
        binding.source0 else operation_sources.source1;
    let axis = if TileOperationUsesClosedRowExpansionSchema(operation) then
        TileAxis_Row else TileAxis_Column;
    var data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    let expdif = TileExpansionOperationIsExponentialDifference(operation);
    var source_data_type = data_type;
    if expdif then
        let (types_legal, selected_source_type, selected_destination_type) =
            SelectedBundleExponentialDifferenceTypes();
        if !types_legal then
            return FALSE;
        end;
        source_data_type = selected_source_type;
        data_type = selected_destination_type;
    end;
    if (!expdif && !TileVecArithmeticDataTypeSupported(data_type)) ||
       !TileReductionAndExpansionLayoutSupported(
           CurrentBundleTileLayout()) ||
       _Tiles[[broadcast]].layout != CurrentBundleTileLayout() ||
       !(if copy then
             TileExpansionBroadcastElementsLegalAs(
                 broadcast, axis, source_data_type, FALSE) &&
             TileCarrierWidthCompatible(
                 _Tiles[[broadcast]].data_type, source_data_type)
         else TileExpansionBroadcastLegalAs(
             broadcast, axis, source_data_type)) ||
       !SelectedBundleExpansionBroadcastShapeMatches(
           operation, broadcast) then
        return FALSE;
    end;

    if copy then
        return TRUE;
    end;
    return _Tiles[[operation_sources.source0]].layout == CurrentBundleTileLayout() &&
           TileReductionAndExpansionSourceLegalAs(
               operation_sources.source0, source_data_type) &&
           SelectedBundleComparisonShapeMatches(operation_sources.source0) &&
           ((TileOperationOfIndex(operation) != TileOperation_TROWEXPANDDIV &&
             TileOperationOfIndex(operation) != TileOperation_TCOLEXPANDDIV) ||
            !TileDataTypeIsInteger(data_type) ||
            TileExpansionBroadcastNonzero(
                axis,
                operation_sources.source0,
                operation_sources.source1,
                source_data_type));
end;
```
<!-- GENERATED-ASL-END: unit -->
