<!-- GENERATED FROM: asl/block/model/dispatch/tcvt-schema.asl -->
# Tcvt Schema

**Normative ASL source:** `asl/block/model/dispatch/tcvt-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the closed bundle schema for `TCVT`, the Tile type-conversion operation. A closed schema is the complete list of bindings, dimensions, types, and attributes that a bundle must carry for one operation. `SelectedBundleClosedTCVTSchemaLegal` returns true for every other operation, and for `TCVT` it returns true only when the whole bundle matches the schema.

The generic Tile path in the tile-execution owner calls it through `SelectedBundleClosedSchemasLegal`. A false result there raises `Fault_TileLegality` before any destination is allocated.

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-schema-concepts role=concepts-state -->
## Concepts and visible state

`TCVT` has two data types.

- The source operation type comes from the operation descriptor, through `CurrentBundleTileOperationDataTypeCode`.
- The destination type comes from `ResolveBundleEffectiveDataType`. It uses a concrete `B.DATR` data type when one is present, and otherwise the descriptor data type.

The schema reads the Tile bindings (`B.IOT`), the scalar bindings (`B.IOR`), the three bundle dimensions, the execution mask, the `B.DATR` rounding mode, canonicalize flag, and data layout, and the descriptor of the source Tile. It writes no state.

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-schema-rules role=rules-interactions -->
## Rules and interactions

The binding shape is one Tile binding and no Shared binding. That binding must name a destination with a legal size code, name `source0`, and be the last binding. `source1` is present only when the execution mask is a predicate Tile, and then that mask must be source ordinal 1. A scalar binding is present only when the execution mask is carried in a GPR, and then it must satisfy the GPR mask schema.

All three dimensions must be in `1..65535`. The source must hold valid encodings of the source type. The type pair must pass `HardwareTCVTTypePairSupported`, and the resolved rounding mode must pass `HardwareTCVTRoundingModeSupported`.

Design point: an encoded rounding field of zero means "use the operation default". The schema resolves that default to `NumericRound_RNE` here. The ASL comment explains why: `E6M2` and `RCPE6M2` accept only RNE and RNA, and resolving the mode during schema preflight stops an unsupported mode before destination allocation or any effect.

The shape rules depend on the source layout.

- For a `CUBE_M16` or `CUBE_M32` source, the requested valid columns and rows must equal the source's, dimension 2 must be 1, canonicalize must be off, the data layout must be `NORM`, and the destination type must be CUBE-capable. The destination keeps the same CUBE layout.
- Any other CUBE layout is rejected.
- For a non-CUBE source, the requested valid columns, valid rows, and physical columns must all equal the source's, canonicalize must be off, and the source layout must equal the bundle's source layout. The destination physical shape must also fit: normally its derived row count equals the source's rows, but when both types allow odd physical columns and the column count is not a power of two, the source rows must fit the destination capacity.

Design point: for CUBE sources the schema does not check the destination geometry against dimension 2. The ASL comment states that destination physical geometry is derived later from the destination type and the requested size code, which the TCVT destination unit does.

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-schema-boundaries role=boundaries -->
## Architectural boundaries

This unit only answers yes or no. It raises no fault itself, allocates nothing, and does not convert values. Destination allocation for CUBE sources belongs to the TCVT destination unit. The numeric conversion belongs to the Tile `TCVT` execution. Execution-mask capture belongs to the execution-mask schema owner, and the GPR mask binding rule `BundleExecutionMaskGPRBindingSchemaLegal` belongs to the scalar-schema owner.

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-schema-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A bundle converts a RowMajor FP32 source Tile with 16 valid rows, 32 valid columns, and 32 physical columns to FP16. The descriptor type is FP32 and `B.DATR` selects FP16. `B.DIM` sets dimension 0 to 32, dimension 1 to 16, and dimension 2 to 32. There is one `B.IOT` with a destination and `source0`, marked last, and no `B.IOR`. With no mask and rounding field zero, the mode resolves to RNE. The schema passes if the FP16 destination at the chosen size code derives 16 rows for 32 columns. Setting dimension 2 to 64 would fail, because it no longer equals the source's 32 physical columns.

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-schema-related role=related-owners-navigation -->
## Related owners

- [TCVT destination](tcvt-destination.md) allocates the destination for CUBE sources.
- [Tile execution](tile-execution.md) calls this schema before destination resolution.
- [Execution-mask schema](execution-mask-schema.md) owns the mask carrier rules.
- [TCVT](../../../tile/elementwise-tile-tile/format-conversion/TCVT.md) is the instruction page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tcvt-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA","surface":"block","classification":["model","dispatch","tcvt-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA"]}
pure func TileOperationUsesClosedTCVTSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TCVT;
end;

readonly func SelectedBundleClosedTCVTSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTCVTSchema(operation) then return TRUE; end;
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       (_BundleScalarBindings[[0]].valid != execution_mask_gpr) ||
       (execution_mask_gpr &&
        !BundleExecutionMaskGPRBindingSchemaLegal(operation)) then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       !binding.source0_valid ||
       (binding.source1_valid != execution_mask_tile) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal != 1) ||
       !binding.last then
        return FALSE;
    end;
    if UInt(_BundleDimensions[[0]]) < 1 ||
       UInt(_BundleDimensions[[0]]) > 65535 then
        return FALSE;
    end;
    for dimension = 1 to 2 looplimit 2 do
        if UInt(_BundleDimensions[[dimension]]) < 1 ||
           UInt(_BundleDimensions[[dimension]]) > 65535 then
            return FALSE;
        end;
    end;

    let source = BundleTileSourceIndex(0, FALSE);
    let source_operation_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !TileTCVTSourceEncodingsValidAs(source, source_operation_type) then
        return FALSE;
    end;
    let (destination_type_valid, destination_type) =
        ResolveBundleEffectiveDataType();
    if !destination_type_valid ||
       !HardwareTCVTTypePairSupported(
           source_operation_type, destination_type) then
        return FALSE;
    end;
    // E6M2 and RCPE6M2 have a closed RNE/RNA profile. Resolve the operation
    // default here, while the bundle is still in schema preflight, so an
    // unsupported mode cannot reach destination allocation or effects. The
    // operand legality check repeats this rule after decoded operands exist.
    let rounding_selection = DecodeBundleRoundingSelection(
        _BundleDataAttributes.rounding_mode);
    let resolved_rounding_mode = if
        rounding_selection.use_operation_default then NumericRound_RNE
        else rounding_selection.rounding_mode;
    if !HardwareTCVTRoundingModeSupported(
           source_operation_type, destination_type,
           resolved_rounding_mode) then
        return FALSE;
    end;

    let source_layout = _Tiles[[source]].layout;
    let requested_valid_columns = UInt(_BundleDimensions[[0]]);
    let requested_valid_rows = UInt(_BundleDimensions[[1]]);
    let source_cube_m_layout =
        source_layout == TileLayout_CUBE_M16 ||
        source_layout == TileLayout_CUBE_M32;
    if source_cube_m_layout then
        // CUBE_M16/M32 TCVT keeps the same CUBE layout and valid region.
        // Destination physical geometry is derived later from the selected
        // destination type and the requested TSize.
        return requested_valid_columns == _Tiles[[source]].valid_columns &&
               requested_valid_rows == _Tiles[[source]].valid_rows &&
               UInt(_BundleDimensions[[2]]) == 1 &&
               !CurrentBundleCanonicalize() &&
               CurrentBundleDataLayout() == TileDataLayout_NORM &&
               TileCubeDescriptorShapeLegal(
                   _Tiles[[source]].capacity_bytes,
                   _Tiles[[source]].valid_rows,
                   _Tiles[[source]].valid_columns,
                   source_operation_type, source_layout) &&
               TileCubeDataTypeSupported(destination_type);
    end;
    if TileLayoutIsCube(source_layout) then
        return FALSE;
    end;

    let requested_columns = UInt(_BundleDimensions[[2]]);
    let destination_capacity = BundleLocalDestinationAllocationBytes(0);
    let destination_rows = DerivedTileRows(
        destination_capacity,
        requested_columns as integer {1..65535},
        destination_type);
    let odd_physical_profile =
        !IsNonzeroPowerOfTwo(requested_columns as integer {1..65535}) &&
        TileDataTypeAllowsOddPhysicalColumns(source_operation_type) &&
        TileDataTypeAllowsOddPhysicalColumns(destination_type);
    let destination_physical_shape_legal = if odd_physical_profile then
        TileStorageFitsCapacity(
            _Tiles[[source]].rows,
            requested_columns as integer {1..65535},
            destination_type, destination_capacity)
    else destination_rows == _Tiles[[source]].rows;
    if requested_valid_columns != _Tiles[[source]].valid_columns ||
       requested_valid_rows != _Tiles[[source]].valid_rows ||
       requested_columns != _Tiles[[source]].columns ||
       !destination_physical_shape_legal then
        return FALSE;
    end;

    if CurrentBundleCanonicalize() then
        return FALSE;
    end;
    return source_layout == CurrentBundleTileSourceLayout();
end;
```
<!-- GENERATED-ASL-END: unit -->
