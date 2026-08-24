<!-- GENERATED FROM: asl/block/model/dispatch/reduction-schema.asl -->
# Reduction Schema

**Normative ASL source:** `asl/block/model/dispatch/reduction-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA}

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
    return TileVecArithmeticDataTypeSupported(data_type) &&
           TileDescriptorLegal(source) &&
           _Tiles[[source]].storage_kind == TileStorage_Numeric &&
           _Tiles[[source]].data_type == data_type &&
           _Tiles[[source]].layout == TileLayout_RowMajor &&
           _Tiles[[source]].valid_rows > 0 &&
           _Tiles[[source]].valid_columns > 0 &&
           SelectedBundleComparisonShapeMatches(source) &&
           TileSourceContentsDefined(source) &&
           TileSourceEncodingsValid(source);
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
