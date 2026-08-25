<!-- GENERATED FROM: asl/block/model/dispatch/histogram-schema.asl -->
# Histogram Schema

**Normative ASL source:** `asl/block/model/dispatch/histogram-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-HISTOGRAM-SCHEMA}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/histogram-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-HISTOGRAM-SCHEMA","surface":"block","classification":["model","dispatch","histogram-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT"]}
pure func TileOperationUsesClosedHistogramSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_THISTOGRAM;
end;

readonly func SelectedBundleClosedHistogramSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedHistogramSchema(operation) then
        return TRUE;
    end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       !binding.source0_valid ||
       !binding.source1_valid ||
       !binding.last then
        return FALSE;
    end;
    if _BundleDimensionPresent[[0]] ||
       _BundleDimensionPresent[[1]] ||
       _BundleDimensionPresent[[2]] then
        return FALSE;
    end;
    if !_BundleDataAttributesPresent ||
       !_BundleDataAttributes.data_type_present ||
       BundleTileDataType(_BundleDataAttributes.data_type) !=
           TileDataType_U32 then
        return FALSE;
    end;

    let source_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    if source_type != TileDataType_U16 &&
       source_type != TileDataType_U32 then
        return FALSE;
    end;
    let selected_byte = UInt(_BundleDataAttributes.pad_value)
        as integer {0..3};
    return CurrentBundleTileLayout() == TileLayout_RowMajor &&
           TileHistogramInputsLegal(
               binding.source0,
               binding.source1,
               selected_byte);
end;
```
<!-- GENERATED-ASL-END: unit -->
