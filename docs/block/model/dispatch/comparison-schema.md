<!-- GENERATED FROM: asl/block/model/dispatch/comparison-schema.asl -->
# Comparison Schema

**Normative ASL source:** `asl/block/model/dispatch/comparison-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/comparison-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","surface":"block","classification":["model","dispatch","comparison-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA"]}
pure func TileOperationUsesClosedTCMPSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TCMP;
end;

pure func TileOperationUsesClosedTSELSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TSEL;
end;

pure func TileOperationUsesClosedComparisonSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationUsesClosedTCMPSchema(operation) ||
           TileOperationUsesClosedTSELSchema(operation);
end;

readonly func SelectedBundleComparisonDimensionsLegal() => boolean
begin
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
    return TRUE;
end;

readonly func SelectedBundleComparisonShapeMatches(
    source: TileIndex) => boolean
begin
    let tile = _Tiles[[source]];
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = (if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) else 1) as integer {1..65535};
    let columns = (if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]]) else valid_columns) as integer {1..65535};
    if tile.valid_rows != valid_rows ||
       tile.valid_columns != valid_columns then
        return FALSE;
    end;
    if TileLayoutIsCube(tile.layout) then
        return tile.rows == TileCubeStorageRows(
                   tile.layout, valid_rows, tile.data_type) &&
               tile.columns == TileCubeStorageColumns(
                   tile.layout, columns, tile.data_type);
    end;
    return tile.columns == columns;
end;

readonly func SelectedBundleComparisonSourceContentsDefined(
    source: TileIndex) => boolean
begin
    let tile = _Tiles[[source]];
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile) && tile.contents_defined;
    end;
    return TileSourceContentsDefined(source);
end;

readonly func SelectedBundleComparisonShapeAndTypeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    if TileLayoutIsCube(_Tiles[[left]].layout) ||
       TileLayoutIsCube(_Tiles[[right]].layout) then
        return TileElementwiseShapeAndTypeMatch(left, right);
    end;
    return TileShapeAndTypeMatch(left, right);
end;

readonly func SelectedBundleComparisonCUBE(source: TileIndex) => boolean
begin
    return _Tiles[[source]].layout == TileLayout_CUBE_M16 ||
           _Tiles[[source]].layout == TileLayout_CUBE_M32;
end;

readonly func SelectedBundleComparisonGPRMaskWordCount(source: TileIndex) => integer {1..2}
begin
    let tile = _Tiles[[source]];
    // GPR masks are target-shape complete: U32/U16/BF16 fit one 64-bit
    // carrier (a one-cell U32 form uses only low32), while every CUBE U8
    // shape consumes the two complete 64-bit words covering its Low/High
    // predicate halves.
    return if tile.data_type == TileDataType_U8 then 2 else 1;
end;

pure func BundleComparisonGPRSelectorLegal(selector: Reg5Selector) => boolean
begin
    return selector < PTO_ABSOLUTE_GPR_COUNT;
end;

pure func BundleComparisonBindingUsesNoSources(
    binding: BundleScalarBinding) => boolean
begin
    return binding.source0 == 0 &&
           binding.source1 == 0 &&
           binding.source2 == 0;
end;

pure func BundleComparisonBindingUsesOneSource(
    binding: BundleScalarBinding) => boolean
begin
    return BundleComparisonGPRSelectorLegal(binding.source0) &&
           binding.source1 == 0 &&
           binding.source2 == 0;
end;

pure func BundleComparisonBindingUsesTwoSources(
    binding: BundleScalarBinding) => boolean
begin
    return BundleComparisonGPRSelectorLegal(binding.source0) &&
           BundleComparisonGPRSelectorLegal(binding.source1) &&
           binding.source2 == 0;
end;

pure func BundleComparisonBindingUsesThreeSources(
    binding: BundleScalarBinding) => boolean
begin
    return BundleComparisonGPRSelectorLegal(binding.source0) &&
           BundleComparisonGPRSelectorLegal(binding.source1) &&
           BundleComparisonGPRSelectorLegal(binding.source2);
end;

readonly func BundleComparisonCodeAsTileComparison() => TileComparison
begin
    case UInt(_BundleDataAttributes.comparison_mode) of
        when 0 => return TileComparison_EQ;
        when 1 => return TileComparison_NE;
        when 2 => return TileComparison_LT;
        when 3 => return TileComparison_GT;
        when 4 => return TileComparison_LE;
        when 5 => return TileComparison_GE;
        otherwise => return TileComparison_EQ;
    end;
end;

readonly func SelectedBundleComparisonUsesGPRCarrier(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TCMP || decoded == TileOperation_TCMPS then
        return _BundleScalarBindings[[0]].valid &&
               !_BundleTileBindings[[0]].destination_valid;
    end;
    if decoded == TileOperation_TSEL then
        return BundleTileBindingCount() == 1 &&
               _BundleScalarBindings[[0]].valid;
    end;
    if decoded == TileOperation_TSELS then
        return BundleTileBindingCount() == 1 &&
               !_BundleTileBindings[[0]].source1_valid &&
               _BundleScalarBindings[[0]].valid;
    end;
    return FALSE;
end;

readonly func SelectedBundleComparisonProducesGPR(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return SelectedBundleComparisonUsesGPRCarrier(operation) &&
           (decoded == TileOperation_TCMP ||
            decoded == TileOperation_TCMPS);
end;

readonly func SelectedBundleComparisonConsumesGPR(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return SelectedBundleComparisonUsesGPRCarrier(operation) &&
           (decoded == TileOperation_TSEL ||
            decoded == TileOperation_TSELS);
end;

readonly func SelectedBundleClosedTCMPSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTCMPSchema(operation) then return TRUE; end;
    if BundleSharedBindingCount() != 0 || !SelectedBundleComparisonDimensionsLegal() ||
       BundleTileBindingCount() != 1 then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    if !binding.source0_valid || !binding.source1_valid || !binding.last then
        return FALSE;
    end;
    let source_left = BundleTileSourceIndex(0, FALSE);
    let source_right = BundleTileSourceIndex(0, TRUE);
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if UInt(_BundleDataAttributes.comparison_mode) > 5 ||
       !TileCompareDataTypeSupported(data_type) ||
       !SelectedBundleComparisonShapeAndTypeMatch(source_left, source_right) ||
       _Tiles[[source_left]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source_left]].data_type != data_type ||
       !SelectedBundleComparisonSourceContentsDefined(source_left) ||
       !SelectedBundleComparisonSourceContentsDefined(source_right) ||
       ((!TileLayoutIsCube(_Tiles[[source_left]].layout) &&
         !TileSourceEncodingsValid(source_left)) ||
        (!TileLayoutIsCube(_Tiles[[source_right]].layout) &&
         !TileSourceEncodingsValid(source_right))) ||
       !SelectedBundleComparisonShapeMatches(source_left) then return FALSE; end;
    let cube = SelectedBundleComparisonCUBE(source_left);
    if cube && !TileCubePredicateDataTypeSupported(data_type) then
        return FALSE;
    end;
    if cube && (!TileCubeNumericSourceLegal(source_left) ||
                !TileCubeNumericSourceLegal(source_right)) then
        return FALSE;
    end;
    if !cube then
        return binding.destination_valid &&
               !binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(0) &&
               !_BundleScalarBindings[[0]].valid &&
               _Tiles[[source_left]].layout == TileLayout_RowMajor;
    end;
    // CUBE CellReg form has a Local PredicateCell destination and no B.IOR.
    if binding.destination_valid then
        let capacity_bytes = BundleLocalDestinationAllocationBytes(0);
        return !_BundleScalarBindings[[0]].valid &&
               !_BundleDataAttributes.saturating &&
               !_BundleDataAttributes.canonicalize &&
               !binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(0) &&
               TileCubeDescriptorShapeLegal(
                   capacity_bytes, _Tiles[[source_left]].valid_rows,
                   _Tiles[[source_left]].valid_columns, TileDataType_U8,
                   _Tiles[[source_left]].layout);
    end;
    // CUBE GPR form has no tile destination and exactly one destination-only
    // B.IOR record.  Encoded zero is still architectural GPR0.
    return _BundleScalarBindings[[0]].valid &&
           BundleComparisonBindingUsesNoSources(
               _BundleScalarBindings[[0]]) &&
           BundleComparisonGPRSelectorLegal(
               _BundleScalarBindings[[0]].destination) &&
           !binding.destination_valid &&
           (!_BundleDataAttributes.canonicalize) &&
           (data_type == TileDataType_U8 ||
            !_BundleDataAttributes.saturating) &&
           TileOperandsLegal_ExecuteTileCompareGPR(
               source_left, source_right,
               _BundleDataAttributes.saturating) &&
           !_BundleScalarBindings[[1]].valid;
end;

readonly func SelectedBundleClosedTSELSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTSELSchema(operation) then return TRUE; end;
    if BundleSharedBindingCount() != 0 || !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !TileSelectDataTypeSupported(data_type) then return FALSE; end;
    // CellReg mask form retains the two-record legacy source arrangement.
    if BundleTileBindingCount() == 2 then
        let inputs = _BundleTileBindings[[0]];
        let result = _BundleTileBindings[[1]];
        if inputs.destination_valid || !inputs.source0_valid ||
           !inputs.source1_valid || inputs.last ||
           !result.destination_valid || result.destination_allocated_by_bundle ||
           !BundleTileDestinationSizeLegal(1) || !result.source0_valid ||
           result.source1_valid || !result.last then return FALSE; end;
        let mask = BundleTileSourceIndex(0, FALSE);
        let source_true = BundleTileSourceIndex(0, TRUE);
        let source_false = BundleTileSourceIndex(1, FALSE);
        return !_BundleScalarBindings[[0]].valid &&
               (!SelectedBundleComparisonCUBE(source_true) ||
                TileCubePredicateDataTypeSupported(data_type)) &&
               (if SelectedBundleComparisonCUBE(source_true) then
                   TilePredicateCellValuesLegal(mask) &&
                   TilePredicateCellShapeMatchesNumeric(mask, source_true)
                else
                   TilePredicateValuesLegal(mask)) &&
               SelectedBundleComparisonShapeAndTypeMatch(source_true, source_false) &&
               _Tiles[[source_true]].storage_kind == TileStorage_Numeric &&
               _Tiles[[source_true]].data_type == data_type &&
               SelectedBundleComparisonSourceContentsDefined(source_true) &&
               SelectedBundleComparisonSourceContentsDefined(source_false) &&
               SelectedBundleComparisonShapeMatches(source_true);
    end;
    // GPR mask form has one B.IOT for true/false/destination and a
    // predicate-specific source-only B.IOR.  No CellReg mask is present.
    if BundleTileBindingCount() != 1 then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    if !binding.destination_valid || binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) || !binding.source0_valid ||
       !binding.source1_valid || !binding.last ||
       !_BundleScalarBindings[[0]].valid ||
       _BundleScalarBindings[[0]].destination != 0 ||
       (if SelectedBundleComparisonGPRMaskWordCount(binding.source0) == 2 then
            !BundleComparisonBindingUsesTwoSources(
                _BundleScalarBindings[[0]])
        else
            !BundleComparisonBindingUsesOneSource(
                _BundleScalarBindings[[0]])) then
        return FALSE;
    end;
    let source_true = BundleTileSourceIndex(0, FALSE);
    let source_false = BundleTileSourceIndex(0, TRUE);
    return TileCubePredicateGPRDataTypeSupported(data_type) &&
           TileCubePredicateGPRShapeLegal(source_true) &&
           SelectedBundleComparisonShapeAndTypeMatch(source_true, source_false) &&
           _Tiles[[source_true]].storage_kind == TileStorage_Numeric &&
           _Tiles[[source_true]].data_type == data_type &&
           SelectedBundleComparisonCUBE(source_true) &&
           SelectedBundleComparisonSourceContentsDefined(source_true) &&
           SelectedBundleComparisonSourceContentsDefined(source_false) &&
           SelectedBundleComparisonShapeMatches(source_true);
end;
```
<!-- GENERATED-ASL-END: unit -->
