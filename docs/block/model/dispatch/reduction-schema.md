<!-- GENERATED FROM: asl/block/model/dispatch/reduction-schema.asl -->
# Reduction Schema

**Normative ASL source:** `asl/block/model/dispatch/reduction-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-reduction-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit is the closed bundle schema for the twelve Tile reductions. A closed schema is a complete list of the operand bindings, dimensions, types, and layouts that a bundle for one operation family may carry; anything outside it is rejected.

It defines three classifiers and one legality predicate:

- `TileOperationUsesClosedRowReductionSchema` selects `TROWSUM`, `TROWPROD`, `TROWMIN`, `TROWMAX`, `TROWARGMIN`, and `TROWARGMAX`.
- `TileOperationUsesClosedColumnReductionSchema` selects the six matching `TCOL*` operations.
- `TileReductionOperationReturnsIndex` selects the four arg forms, which return a column or row index instead of a value.
- `SelectedBundleClosedReductionSchemaLegal` checks a complete bundle against the reduction schema.

<!-- PTO-READER-BLOCK: block-model-dispatch-reduction-schema-concepts role=concepts-state -->
## Concepts and visible state

The unit only reads state. It writes nothing and raises no fault by itself.

- `_BundleTileBindings` holds the `B.IOT` bindings. The predicate reads binding 0: its source, destination, destination size code, and `last` flag.
- `_BundleDimensions` holds `LB0` (valid columns), `LB1` (valid rows), and `LB2` (physical columns).
- `_BundleExecutionMask`, `_BundleScalarBindings`, and the Shared binding count are read only to confirm that they are absent.
- The operation `DataType` comes from the `BSTART` encoding through `CurrentBundleTileOperationDataTypeCode`, and the layout from `CurrentBundleTileLayout`.
- `_Tiles` supplies the source descriptor and its element values.

<!-- PTO-READER-BLOCK: block-model-dispatch-reduction-schema-rules role=rules-interactions -->
## Rules and interactions

For a reduction, the predicate returns true only when all of these hold:

- No ExecutionMask is in force.
- There is exactly one Local Tile binding, no Shared binding, and no scalar binding at index 0.
- All three dimensions are in 1 to 65535.
- Binding 0 has source 0, no source 1, a destination that is not already allocated by the bundle, a legal destination size code, and the `last` flag.
- The data type is in the arg-reduction set for arg forms (`S32`, `U32`, `FP32`, `S16`, `U16`, `FP16`, `BF16`, `S8`, `U8`) and in the vector-arithmetic set otherwise.
- The layout is `RowMajor`, `CUBE_M16`, or `CUBE_M32`, and the source uses that same layout.
- The source passes `TileReductionSourceLegalAs`: numeric storage, a width-compatible carrier, not `RCPE6M2`, and a defined, valid encoding at every valid coordinate.
- The source valid rows and columns are nonzero and match `LB1` and `LB0`, and its physical columns match `LB2` (for CUBE layouts, the CUBE storage columns derived from `LB2`).

For any other operation the predicate returns true, so it can be combined with the other closed-schema predicates.

Design point: a reduction reads every valid coordinate, and the ASL comment in `TileReductionSourceLegalAs` states that reductions do not support the ExecutionMask validation state. The schema therefore rejects any ExecutionMask outright instead of reducing over a subset of elements.

Design point: this check runs before any destination is allocated. The local Tile execution path calls it through `SelectedBundleClosedSchemasLegal` and raises `Fault_TileLegality` on failure, and only afterwards calls `ResolveBundleTileDestinationsForOperation`. A rejected reduction bundle therefore leaves no new Tile allocated.

<!-- PTO-READER-BLOCK: block-model-dispatch-reduction-schema-boundaries role=boundaries -->
## Architectural boundaries

This unit does not compute the reduction and does not allocate the destination. Destination shaping for reductions is in [destination operation](destination-operation.md): a row reduction gets the source valid rows and one column, a column reduction gets one row and the source valid columns, and an arg form gets a `U32` destination. The reduction arithmetic is owned by the Tile execution model.

A bundle whose `PE_MASK` selects no PE exits the local execution path before this predicate is evaluated.

<!-- PTO-READER-BLOCK: block-model-dispatch-reduction-schema-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Consider `TROWSUM <Row=8, Col=64, FP32>, T#1, ->T<2KB>`. The bundle carries `LB0=64`, `LB1=8`, and `LB2=64`, and one `B.IOT` with source `T#1`, a new destination, and the `last` flag. If `T#1` is a defined `RowMajor` `FP32` Tile with 8 valid rows, 64 valid columns, and 64 physical columns, the schema passes. The destination then receives 8 valid rows and 1 valid column.

If the same bundle also carried a `B.IOR` whose selectors are all zero, or if `T#1` had only 7 valid rows, the predicate would return false and the bundle would raise `Fault_TileLegality` before any destination exists. A `B.IOR` with a nonzero selector is rejected earlier by the completeness check with `Fault_BundleControl`.

<!-- PTO-READER-BLOCK: block-model-dispatch-reduction-schema-related role=related-owners-navigation -->
## Related owners

- [Tile execution dispatch](tile-execution.md) combines this predicate with the other closed schemas and orders it before destination resolution.
- [Comparison schema](comparison-schema.md) supplies the shared dimension and source-shape checks.
- [Destination operation](destination-operation.md) shapes the reduction destination.
- [Reduction and expansion legality](../../../tile/model/legality/reduction-and-expansion.md) owns the source legality helpers.
- [TROWSUM](../../../tile/reduce-and-expand/row-reduction/TROWSUM.md) is one instruction page that uses this schema.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/reduction-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA","surface":"block","classification":["model","dispatch","reduction-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA"]}

pure func TileOperationUsesClosedRowReductionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWSUM ||
           decoded == TileOperation_TROWPROD ||
           decoded == TileOperation_TROWMIN ||
           decoded == TileOperation_TROWMAX ||
           decoded == TileOperation_TROWARGMIN ||
           decoded == TileOperation_TROWARGMAX;
end;

pure func TileOperationUsesClosedColumnReductionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TCOLSUM ||
           decoded == TileOperation_TCOLPROD ||
           decoded == TileOperation_TCOLMIN ||
           decoded == TileOperation_TCOLMAX ||
           decoded == TileOperation_TCOLARGMIN ||
           decoded == TileOperation_TCOLARGMAX;
end;

pure func TileOperationUsesClosedReductionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationUsesClosedRowReductionSchema(operation) ||
           TileOperationUsesClosedColumnReductionSchema(operation);
end;

pure func TileReductionOperationReturnsIndex(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWARGMIN ||
           decoded == TileOperation_TROWARGMAX ||
           decoded == TileOperation_TCOLARGMIN ||
           decoded == TileOperation_TCOLARGMAX;
end;

readonly func SelectedBundleClosedReductionSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedReductionSchema(operation) then
        return TRUE;
    end;
    if _BundleExecutionMask.valid then return FALSE; end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       _BundleScalarBindings[[0]].valid ||
       !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       !binding.source0_valid ||
       binding.source1_valid ||
       !binding.last then
        return FALSE;
    end;

    let source = BundleTileSourceIndex(0, FALSE);
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    let source_tile = _Tiles[[source]];
    let source_type_legal = if TileReductionOperationReturnsIndex(operation) then
        TileArgReductionSourceDataTypeSupported(data_type)
    else
        TileVecArithmeticDataTypeSupported(data_type);
    return source_type_legal &&
           TileReductionAndExpansionLayoutSupported(
               CurrentBundleTileLayout()) &&
           source_tile.layout == CurrentBundleTileLayout() &&
           TileReductionSourceLegalAs(source, data_type) &&
           source_tile.valid_rows > 0 &&
           source_tile.valid_columns > 0 &&
           SelectedBundleComparisonShapeMatches(source);
end;
```
<!-- GENERATED-ASL-END: unit -->
