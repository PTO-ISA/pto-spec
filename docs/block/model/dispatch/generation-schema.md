<!-- GENERATED FROM: asl/block/model/dispatch/generation-schema.asl -->
# Generation Schema

**Normative ASL source:** `asl/block/model/dispatch/generation-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-GENERATION-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-generation-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit is the closed bundle schema for the two generation operations, `TCI` and `TTRI`. A generation operation writes a new Tile from scalar parameters alone: `TCI` writes an index sequence, and `TTRI` writes a triangular pattern of ones and zeros. Neither reads a numeric source Tile.

It defines three functions:

- `TileOperationUsesClosedGenerationSchema` selects `TCI` and `TTRI`.
- `SelectedBundleGenerationDimensionsLegal` checks the `B.DIM` values for the selected operation.
- `SelectedBundleClosedGenerationSchemaLegal` checks the whole bundle.

<!-- PTO-READER-BLOCK: block-model-dispatch-generation-schema-concepts role=concepts-state -->
## Concepts and visible state

The unit only reads state and raises no fault by itself.

- `_BundleDimensions` and `_BundleDimensionPresent` give `LB0` (valid columns), `LB1` (valid rows), and `LB2` (physical columns), and whether each was encoded. A dimension that is not encoded keeps the value 1 written when the bundle header state is cleared.
- `_BundleTileBindings` binding 0 carries the destination, its size code, an optional mask source, and the `last` flag.
- `_BundleExecutionMask` tells whether a predicate-Tile ExecutionMask is in force.
- The operation `DataType` and layout come from the `BSTART` encoding and `B.DATR`.

<!-- PTO-READER-BLOCK: block-model-dispatch-generation-schema-rules role=rules-interactions -->
## Rules and interactions

For both operations the bundle must have exactly one Local Tile binding and no Shared binding. That binding has a destination not already allocated by the bundle, a legal size code, no `source1`, and the `last` flag. It carries `source0` exactly when a predicate-Tile ExecutionMask is in force, and the mask ordinal must then be 0.

Design point: a generation operation has no data source, so the only possible Tile input is the mask. The schema therefore places the mask in `source0` of the single binding, instead of requiring a second binding.

`TCI` accepts `S32`, `S16`, `U32`, and `U16`, with these shape rules:

- `LB0` must be encoded and in 1 to 65535.
- Omitted `LB2` selects `Col` equal to valid columns in `RowMajor`. In `CUBE_M16` and `CUBE_M32` it selects valid columns rounded up to the cell-column count for the type.
- `LB1` and the resulting `Col` must be in range, and `Col` must be at least valid columns.
- `RowMajor` requires exactly 1 valid row.
- `CUBE_M16` allows at most 16 valid rows. Both CUBE layouts require `Col` to be a multiple of the cell-column count, and a type with no cell-column count is rejected.

`TTRI` accepts `FP32`, `FP16`, `S32`, `S16`, `U32`, and `U16` in `RowMajor` only. `LB0` must be in 1 to 65535, `LB1` in 1 to 65535, and `Col` (from `LB2`, or valid columns when omitted) must be at least valid columns and at most 65535.

Design point: the schema returns false rather than faulting. The local Tile execution path evaluates it through `SelectedBundleClosedSchemasLegal`, raises `Fault_TileLegality` on failure, and resolves the destination only afterwards. A rejected generation bundle therefore allocates nothing.

<!-- PTO-READER-BLOCK: block-model-dispatch-generation-schema-boundaries role=boundaries -->
## Architectural boundaries

This unit does not check the scalar parameters. The `B.IOR` field layout is checked by [scalar schema](scalar-schema.md), which for CUBE `TCI` also rejects a Step2D row or column step outside -1, 0, and 1. The generated values and the triangle rule are owned by the Tile generation execution model.

<!-- PTO-READER-BLOCK: block-model-dispatch-generation-schema-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Consider `TCI <Row=1, Col=64, U32>, ->T<256B>` in `RowMajor`, with Start and Direction left at their defaults. `Row` is printed because TCI derives it from the encoded `ValidRow`. The bundle carries `LB0=64` for `ValidCol`; `LB1` and `LB2` are either omitted or encoded as 1 and 64, and in both cases the schema reads 1 valid row and `Col` = 64. The 256B destination holds 64 `U32` elements.

With `B.DATR` selecting `CUBE_M16` and `LB0=3`, `LB1=2`, and `LB2` omitted for `U16`, the cell-column count is 4, so `Col` is 3 rounded up to 4. An explicit `LB2=6` would fail, because 6 is not a multiple of 4.

<!-- PTO-READER-BLOCK: block-model-dispatch-generation-schema-related role=related-owners-navigation -->
## Related owners

- [Tile execution dispatch](tile-execution.md) combines this predicate with the other closed schemas before destination resolution.
- [Destination operation](destination-operation.md) shapes the generation destination from the bundle dimensions.
- [Tile generation execution](../../../tile/model/execution/generation.md) owns the supported type sets and the generated values.
- [TCI](../../../tile/irregular-and-complex/initialization/TCI.md) and [TTRI](../../../tile/irregular-and-complex/initialization/TTRI.md) are the instruction pages.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/generation-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-GENERATION-SCHEMA","surface":"block","classification":["model","dispatch","generation-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-TILE-MODEL-EXECUTION-GENERATION"]}
pure func TileOperationUsesClosedGenerationSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TCI ||
           decoded == TileOperation_TTRI;
end;

readonly func SelectedBundleGenerationDimensionsLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TCI then
        if !_BundleDimensionPresent[[0]] ||
           UInt(_BundleDimensions[[0]]) < 1 ||
           UInt(_BundleDimensions[[0]]) > 65535 then
            return FALSE;
        end;
        let data_type = TileDataTypeFromEncoding(
            CurrentBundleTileOperationDataTypeCode()
                as TileDataTypeEncoding);
        if !TileTCIDataTypeSupported(data_type) then return FALSE; end;
        let layout = CurrentBundleTileLayout();
        let valid_columns = UInt(_BundleDimensions[[0]])
            as integer {1..65535};
        let valid_rows = UInt(_BundleDimensions[[1]]);
        let columns = if _BundleDimensionPresent[[2]] then
            UInt(_BundleDimensions[[2]])
        else if layout == TileLayout_CUBE_M16 ||
              layout == TileLayout_CUBE_M32 then
            TileCubeAlignedExtent(valid_columns,
                TileCubeCellColumns(layout, data_type) as integer {1..65535})
        else
            valid_columns;
        if valid_rows < 1 || valid_rows > 65535 ||
           columns < valid_columns || columns > 65535 then
            return FALSE;
        end;
        if layout == TileLayout_CUBE_M16 then
            if valid_rows > 16 then return FALSE; end;
            let cell_columns = TileCubeCellColumns(layout, data_type);
            if cell_columns == 0 then return FALSE; end;
            return columns MOD (cell_columns as integer {1..65535}) == 0;
        elsif layout == TileLayout_CUBE_M32 then
            let cell_columns = TileCubeCellColumns(layout, data_type);
            if cell_columns == 0 then return FALSE; end;
            return columns MOD (cell_columns as integer {1..65535}) == 0;
        end;
        return layout == TileLayout_RowMajor && valid_rows == 1;
    end;
    if decoded != TileOperation_TTRI then
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]);
    let columns = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]])
    else
        valid_columns;
    if valid_columns < 1 || valid_columns > 65535 ||
       columns < valid_columns || columns > 65535 then
        return FALSE;
    end;
    return UInt(_BundleDimensions[[1]]) >= 1 &&
           UInt(_BundleDimensions[[1]]) <= 65535;
end;

readonly func SelectedBundleClosedGenerationSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedGenerationSchema(operation) then
        return TRUE;
    end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       (binding.source0_valid != execution_mask_tile) ||
       binding.source1_valid ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal != 0) ||
       !binding.last then
        return FALSE;
    end;
    if !SelectedBundleGenerationDimensionsLegal(operation) then
        return FALSE;
    end;

    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    let decoded = TileOperationOfIndex(operation);
    let data_type_legal = if decoded == TileOperation_TCI then
        TileTCIDataTypeSupported(data_type)
    else
        TileTTRIDataTypeSupported(data_type);
    let layout = CurrentBundleTileLayout();
    return data_type_legal &&
           (layout == TileLayout_RowMajor ||
            (decoded == TileOperation_TCI &&
             (layout == TileLayout_CUBE_M16 ||
              layout == TileLayout_CUBE_M32)));
end;
```
<!-- GENERATED-ASL-END: unit -->
