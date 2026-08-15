<!-- GENERATED FROM: asl/block/model/dispatch/tile-scalar-schema.asl -->
# Tile Scalar Schema

**Normative ASL source:** `asl/block/model/dispatch/tile-scalar-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tile-scalar-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","surface":"block","classification":["model","dispatch","tile-scalar-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA"]}
// Closed complete-bundle schemas for TEPL Mode 1 Tile-scalar operations.

pure func TileOperationUsesClosedTileScalarBinarySchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TADDS ||
           decoded == TileOperation_TSUBS ||
           decoded == TileOperation_TMULS ||
           decoded == TileOperation_TDIVS ||
           decoded == TileOperation_TREMS ||
           decoded == TileOperation_TANDS ||
           decoded == TileOperation_TORS ||
           decoded == TileOperation_TXORS ||
           decoded == TileOperation_TSHLS ||
           decoded == TileOperation_TSHRS ||
           decoded == TileOperation_TMAXS ||
           decoded == TileOperation_TMINS;
end;

pure func TileOperationUsesClosedTCMPSSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TCMPS;
end;

pure func TileOperationUsesClosedTSELSSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TSELS;
end;

pure func TileOperationUsesClosedTEXPANDSSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TEXPANDS;
end;

pure func TileOperationUsesClosedTileScalarSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationUsesClosedTileScalarBinarySchema(operation) ||
           TileOperationUsesClosedTCMPSSchema(operation) ||
           TileOperationUsesClosedTSELSSchema(operation) ||
           TileOperationUsesClosedTEXPANDSSchema(operation);
end;

pure func TileScalarBinaryOperation(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => TileBinaryOperation
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TADDS then return TileBinary_ADD;
    elsif decoded == TileOperation_TSUBS then return TileBinary_SUB;
    elsif decoded == TileOperation_TMULS then return TileBinary_MUL;
    elsif decoded == TileOperation_TDIVS then return TileBinary_DIV;
    elsif decoded == TileOperation_TREMS then return TileBinary_REM;
    elsif decoded == TileOperation_TANDS then return TileBinary_AND;
    elsif decoded == TileOperation_TORS then return TileBinary_OR;
    elsif decoded == TileOperation_TXORS then return TileBinary_XOR;
    elsif decoded == TileOperation_TSHLS then return TileBinary_SHL;
    elsif decoded == TileOperation_TSHRS then return TileBinary_SHR;
    elsif decoded == TileOperation_TMAXS then return TileBinary_MAX;
    elsif decoded == TileOperation_TMINS then return TileBinary_MIN;
    else unreachable;
    end;
end;

readonly func SelectedBundleTileScalarRawValue() => Word
begin
    if !_BundleScalarBindings[[0]].valid then
        return Zeros{PTO_XLEN};
    end;
    return ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source0);
end;

readonly func SelectedBundleTileScalarSourceLegal(
    source: TileIndex,
    data_type: TileDataType) => boolean
begin
    return TileDescriptorLegal(source) &&
           _Tiles[[source]].storage_kind == TileStorage_Numeric &&
           _Tiles[[source]].data_type == data_type &&
           _Tiles[[source]].layout == TileLayout_RowMajor &&
           TileSourceContentsDefined(source) &&
           TileSourceEncodingsValid(source) &&
           SelectedBundleComparisonShapeMatches(source);
end;

readonly func SelectedBundleClosedTileScalarBinarySchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTileScalarBinarySchema(operation) then
        return TRUE;
    end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
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

    let binary = TileScalarBinaryOperation(operation);
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    if !TileBinaryDataTypeSupported(binary, data_type) ||
       CurrentBundleTileLayout() != TileLayout_RowMajor ||
       !SelectedBundleTileScalarSourceLegal(
           binding.source0,
           data_type) then
        return FALSE;
    end;

    let scalar = TileRawElementValue(
        SelectedBundleTileScalarRawValue(),
        data_type);
    if !TileNumericEncodingValid(data_type, scalar) then
        return FALSE;
    end;
    if (binary == TileBinary_DIV || binary == TileBinary_REM) &&
       TileDataTypeIsInteger(data_type) then
        return !IsZero(TileIntegerOperandValue(scalar, data_type));
    end;
    return TRUE;
end;

readonly func SelectedBundleClosedTCMPSSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTCMPSSchema(operation) then return TRUE; end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       !binding.source0_valid ||
       binding.source1_valid ||
       !binding.last ||
       UInt(_BundleDataAttributes.comparison_mode) > 5 then
        return FALSE;
    end;

    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    if !TileCompareDataTypeSupported(data_type) ||
       !SelectedBundleTileScalarSourceLegal(
           binding.source0,
           data_type) then
        return FALSE;
    end;
    return TileNumericEncodingValid(
        data_type,
        TileRawElementValue(
            SelectedBundleTileScalarRawValue(),
            data_type));
end;

readonly func SelectedBundleClosedTSELSSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTSELSSchema(operation) then return TRUE; end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       !SelectedBundleComparisonDimensionsLegal() then
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

    let mask = binding.source0;
    let source_true = binding.source1;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    return TileSelectDataTypeSupported(data_type) &&
           TilePredicateValuesLegal(mask) &&
           SelectedBundleTileScalarSourceLegal(source_true, data_type) &&
           TileLogicalShapeMatch(mask, source_true);
end;

readonly func SelectedBundleClosedTEXPANDSSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTEXPANDSSchema(operation) then return TRUE; end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       binding.source0_valid ||
       binding.source1_valid ||
       !binding.last then
        return FALSE;
    end;

    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    return TileVecArithmeticDataTypeSupported(data_type) &&
           CurrentBundleTileLayout() == TileLayout_RowMajor;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
