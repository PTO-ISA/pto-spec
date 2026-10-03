<!-- GENERATED FROM: asl/block/model/dispatch/lea-schema.asl -->
# Lea Schema

**Normative ASL source:** `asl/block/model/dispatch/lea-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-LEA-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-lea-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the closed bundle schema for `TLEA`. `SelectedBundleClosedLEASchemaLegal` recognizes only `TileOperation_TLEA` and verifies the source binding, destination request, required element-width GPR binding, dimensions, source type, source descriptor, layout, and source contents before execution is selected.

It is a dispatch preflight owner. It does not calculate byte offsets or publish the destination.

<!-- PTO-READER-BLOCK: block-model-dispatch-lea-schema-concepts role=concepts-state -->
## Concepts and visible state

The function reads the selected operation, Tile and Shared binding tables, scalar bindings, bundle dimensions, selected source `DataType`, selected layout, ExecutionMask carrier, and the already-bound source descriptor. It writes no architectural state.

The one `B.IOT` carries `source0` and a destination request and must terminate the Tile bindings. `B.IOR.RegSrc0` is required and supplies the per-PE `element_bits` value. A predicate-Tile mask occupies `source1`; a GPR mask uses the existing scalar-binding extension instead.

<!-- PTO-READER-BLOCK: block-model-dispatch-lea-schema-rules role=rules-interactions -->
## Rules and interactions

For `TLEA`, the function requires one Tile binding, no Shared binding, legal dimensions, one valid scalar binding, a valid `source0`, and a destination that has not already been allocated by the bundle. The binding must be last and its requested destination size must be legal.

Without a GPR ExecutionMask, unused scalar selectors and the scalar destination remain zero. With a GPR ExecutionMask, `BundleExecutionMaskGPRBindingSchemaLegal` owns the extra binding shape. Predicate-Tile masks must appear as source ordinal 1.

The `BSTART` source type must be exactly `S32`, `U32`, `S64`, or `U64` and must equal the source backing type. The source must be a legal Local numeric descriptor in `RowMajor` or `CUBE_M32`, have the bundle's exact logical dimensions, and have defined contents at every coordinate that execution will read. `CUBE_M16` rejects because TLEA's destination is always 64-bit. Finally, the selected scalar value must be exactly 8, 16, 32, or 64.

<!-- PTO-READER-BLOCK: block-model-dispatch-lea-schema-boundaries role=boundaries -->
## Architectural boundaries

This unit checks the incoming bundle shape and source-facing contract. Destination allocation and independent destination geometry are owned by destination resolution and Tile allocation; the resulting source-destination pair is checked again by `TileOperandsLegal_TLEA` before the handler runs.

The schema introduces no default width: omitting `B.IOR`, selecting the zero register, or supplying any value outside 8, 16, 32, and 64 makes an active `TLEA` bundle illegal. `PE_MASK=0000` is handled by the earlier strict-no-op boundary and therefore reaches none of these reads or faults.

<!-- PTO-READER-BLOCK: block-model-dispatch-lea-schema-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative rules.

An `S32` source with logical shape 1 x 3 uses `LB0=3`, omitted `LB1`, one terminating `B.IOT`, and `B.IOR.RegSrc0` selecting a GPR that contains 32. The schema accepts the scalar as a four-byte element width only after confirming that the source backing type is also `S32`, its descriptor uses the selected layout, and the three logical source elements that will be read are defined.

<!-- PTO-READER-BLOCK: block-model-dispatch-lea-schema-related role=related-owners-navigation -->
## Related owners

- [TLEA operand legality](../../../tile/model/legality/lea-operands.md) checks the allocated source-destination pair.
- [TLEA execution](../../../tile/model/execution/lea.md) owns extension and byte scaling.
- [Destination operation](destination-operation.md) derives the new `S64` or `U64` destination.
- [TLEA](../../../tile/tile-scalar-and-immediate/arithmetic/TLEA.md) is the instruction page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/lea-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-LEA-SCHEMA","surface":"block","classification":["model","dispatch","lea-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","PTO-TILE-MODEL-LEGALITY-LEA-OPERANDS"]}
readonly func SelectedBundleClosedLEASchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if TileOperationOfIndex(operation) != TileOperation_TLEA then
        return TRUE;
    end;
    if BundleTileBindingCount() != 1 || BundleSharedBindingCount() != 0 ||
       !SelectedBundleComparisonDimensionsLegal() ||
       !_BundleScalarBindings[[0]].valid then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.source0_valid ||
       (binding.source1_valid != mask_tile) ||
       (mask_tile && _BundleExecutionMask.predicate_source_ordinal != 1) ||
       !binding.destination_valid || binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) || !binding.last then
        return FALSE;
    end;
    let mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    if mask_gpr then
        if !BundleExecutionMaskGPRBindingSchemaLegal(operation) then
            return FALSE;
        end;
    else
        if _BundleScalarBindings[[1]].valid ||
           _BundleScalarBindings[[0]].source1 != 0 ||
           _BundleScalarBindings[[0]].source2 != 0 ||
           _BundleScalarBindings[[0]].destination != 0 then
            return FALSE;
        end;
    end;
    let source = BundleTileSourceIndex(0, FALSE);
    let source_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !TileLEAIndexDataTypeLegal(source_type) ||
       _Tiles[[source]].data_type != source_type ||
       !TileElementwiseDescriptorLegal(source) ||
       _Tiles[[source]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source]].layout != CurrentBundleTileLayout() ||
       (_Tiles[[source]].layout != TileLayout_RowMajor &&
        _Tiles[[source]].layout != TileLayout_CUBE_M32) ||
       !SelectedBundleComparisonSourceContentsDefined(source) ||
       _Tiles[[source]].valid_rows != UInt(_BundleDimensions[[1]]) ||
       _Tiles[[source]].valid_columns != UInt(_BundleDimensions[[0]]) then
        return FALSE;
    end;
    return TileLEAElementBitsLegal(SelectedBundleTileScalarRawValue());
end;
```
<!-- GENERATED-ASL-END: unit -->
