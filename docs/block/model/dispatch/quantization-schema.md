<!-- GENERATED FROM: asl/block/model/dispatch/quantization-schema.asl -->
# Quantization Schema

**Normative ASL source:** `asl/block/model/dispatch/quantization-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-QUANTIZATION-SCHEMA}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/quantization-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-QUANTIZATION-SCHEMA","surface":"block","classification":["model","dispatch","quantization-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA"]}
pure func TileOperationUsesClosedQuantizationSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TQUANT ||
           decoded == TileOperation_TDEQUANT;
end;

readonly func SelectedBundleClosedQuantizationSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedQuantizationSchema(operation) then
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
       binding.source1_valid ||
       !binding.last then
        return FALSE;
    end;
    if !_BundleDimensionPresent[[0]] ||
       UInt(_BundleDimensions[[0]]) < 1 ||
       UInt(_BundleDimensions[[0]]) > 65535 then
        return FALSE;
    end;
    for dimension = 1 to 2 looplimit 2 do
        if _BundleDimensionPresent[[dimension]] &&
           (UInt(_BundleDimensions[[dimension]]) < 1 ||
            UInt(_BundleDimensions[[dimension]]) > 65535) then
            return FALSE;
        end;
    end;

    if !_BundleDataAttributesPresent ||
       !_BundleDataAttributes.data_type_present ||
       !BundleDataTypeConcrete(_BundleDataAttributes.data_type) ||
       _BundleDataAttributes.comparison_mode != Zeros{3} ||
       _BundleDataAttributes.pad_value != Zeros{2} ||
       _BundleDataAttributes.canonicalize ||
       _BundleDataAttributes.data_layout != Zeros{5} then
        return FALSE;
    end;

    let decoded = TileOperationOfIndex(operation);
    let source_type = BundleTileDataType(_BundleOperation.data_type);
    let destination_type = BundleTileDataType(
        _BundleDataAttributes.data_type);
    if decoded == TileOperation_TQUANT then
        if source_type != TileDataType_FP32 ||
           (destination_type != TileDataType_S8 &&
            destination_type != TileDataType_U8) then
            return FALSE;
        end;
    else
        if (source_type != TileDataType_S8 &&
            source_type != TileDataType_U8) ||
           destination_type != TileDataType_FP32 ||
           _BundleDataAttributes.saturating then
            return FALSE;
        end;
    end;

    let source = BundleTileSourceIndex(0, FALSE);
    if !TileDescriptorLegal(source) ||
       _Tiles[[source]].data_type != source_type ||
       _Tiles[[source]].layout != TileLayout_RowMajor ||
       !TileSourceContentsDefined(source) ||
       !TileSourceEncodingsValid(source) then
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]);
    let valid_rows = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) else 1;
    let columns = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]]) else valid_columns;
    return _Tiles[[source]].valid_rows == valid_rows &&
           _Tiles[[source]].valid_columns == valid_columns &&
           _Tiles[[source]].columns == columns;
end;
```
<!-- GENERATED-ASL-END: unit -->
