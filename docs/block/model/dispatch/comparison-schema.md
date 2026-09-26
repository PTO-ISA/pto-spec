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
    return TRUE;
end;

readonly func SelectedBundleComparisonShapeMatches(
    source: TileIndex) => boolean
begin
    let tile = _Tiles[[source]];
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if tile.valid_rows != valid_rows ||
       tile.valid_columns != valid_columns then
        return FALSE;
    end;
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile) &&
               tile.valid_rows == valid_rows &&
               tile.valid_columns == valid_columns &&
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
        // Keep the CUBE descriptor check, but let the shared elementwise
        // definedness rule inspect only ExecutionMask-active coordinates.
        // With no ExecutionMask that rule remains equivalent to the original
        // full-source contents_defined requirement.
        return TileCubeDescriptorLegal(tile) &&
               TileElementwiseSourceContentsDefined(source);
    end;
    return TileSourceContentsDefined(source);
end;

readonly func SelectedBundleComparisonShapeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    if TileLayoutIsCube(_Tiles[[left]].layout) ||
       TileLayoutIsCube(_Tiles[[right]].layout) then
        return TileCubeNumericShapeMatch(left, right);
    end;
    return TileLogicalShapeMatch(left, right) &&
           _Tiles[[left]].storage_kind == _Tiles[[right]].storage_kind;
end;

readonly func TileRowMajorOrCUBENumericCarrierLegal(
    source: TileIndex, operation_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    if TileLayoutIsCube(tile.layout) then
        return TileCubePredicateDataTypeSupported(tile.data_type) &&
               TileCarrierWidthCompatible(tile.data_type, operation_type);
    end;
    return TileRowMajorNumericCarrierLegal(source, operation_type);
end;

readonly func SelectedBundleComparisonCUBE(source: TileIndex) => boolean
begin
    return _Tiles[[source]].layout == TileLayout_CUBE_M16 ||
           _Tiles[[source]].layout == TileLayout_CUBE_M32;
end;

readonly func SelectedBundleComparisonGPRMaskWordCount(
    operation_type: TileDataType) => integer {1..2}
begin
    // 8-bit operation types consume the two complete 64-bit words covering
    // the CUBE Low/High predicate halves. Wider 16/32-bit types use one word.
    return if TileElementBits(operation_type) == 8 then 2 else 1;
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
       BundleTileBindingCount() != (if _BundleExecutionMask.valid &&
           _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile
           then 2 else 1) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    let output_binding = if execution_mask_tile then
        _BundleTileBindings[[1]] else binding;
    if !binding.source0_valid || !binding.source1_valid ||
       (if execution_mask_tile then
            binding.destination_valid || binding.last ||
            !output_binding.source0_valid || output_binding.source1_valid ||
            !output_binding.last ||
            _BundleExecutionMask.predicate_source_ordinal != 2
        else
            !binding.last) then
        return FALSE;
    end;
    let source_left = BundleTileSourceIndex(0, FALSE);
    let source_right = BundleTileSourceIndex(0, TRUE);
    let (operation_type_valid, data_type) = ResolveBundleEffectiveDataType();
    if UInt(_BundleDataAttributes.comparison_mode) > 5 ||
       !operation_type_valid ||
       !TileCompareDataTypeSupported(data_type) ||
       !SelectedBundleComparisonShapeMatch(source_left, source_right) ||
       _Tiles[[source_left]].storage_kind != TileStorage_Numeric ||
       !TileRowMajorOrCUBENumericCarrierLegal(source_left, data_type) ||
       !TileRowMajorOrCUBENumericCarrierLegal(source_right, data_type) ||
       !SelectedBundleComparisonSourceContentsDefined(source_left) ||
       !SelectedBundleComparisonSourceContentsDefined(source_right) ||
       !SelectedBundleComparisonShapeMatches(source_left) then return FALSE; end;
    let cube = SelectedBundleComparisonCUBE(source_left);
    if cube && !TileCubePredicateDataTypeSupported(data_type) then
        return FALSE;
    end;
    if cube && (!TileCubeNumericSourceLegalAs(source_left, data_type) ||
                !TileCubeNumericSourceLegalAs(source_right, data_type)) then
        return FALSE;
    end;
    if !cube && (!TileElementwiseSourceEncodingsValidAs(source_left, data_type) ||
                 !TileElementwiseSourceEncodingsValidAs(source_right, data_type)) then
        return FALSE;
    end;
    if !cube then
        return output_binding.destination_valid &&
               !output_binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(
                   if execution_mask_tile then 1 else 0) &&
               (!execution_mask_gpr ||
                (_BundleScalarBindings[[0]].valid &&
                 _BundleScalarBindings[[0]].destination == 0)) &&
               (execution_mask_gpr || !_BundleScalarBindings[[0]].valid) &&
               _Tiles[[source_left]].layout == TileLayout_RowMajor;
    end;
    // CUBE CellReg form has a Local PredicateCell destination and no B.IOR.
    if output_binding.destination_valid then
        let capacity_bytes = BundleLocalDestinationAllocationBytes(
            if execution_mask_tile then 1 else 0);
        return (!execution_mask_gpr ||
                (_BundleScalarBindings[[0]].valid &&
                 _BundleScalarBindings[[0]].destination == 0)) &&
               (execution_mask_gpr || !_BundleScalarBindings[[0]].valid) &&
               !_BundleDataAttributes.saturating &&
               !_BundleDataAttributes.canonicalize &&
               !output_binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(
                   if execution_mask_tile then 1 else 0) &&
               TileCubeDescriptorShapeLegal(
                   capacity_bytes, _Tiles[[source_left]].valid_rows,
                   _Tiles[[source_left]].valid_columns, TileDataType_U8,
                   _Tiles[[source_left]].layout);
    end;
    // CUBE GPR form has no tile destination and exactly one destination-only
    // B.IOR record.  Encoded zero is still architectural GPR0.
    return _BundleScalarBindings[[0]].valid &&
           (if execution_mask_gpr then
                BundleExecutionMaskGPRBindingSchemaLegal(operation)
            else
                BundleComparisonBindingUsesNoSources(
                    _BundleScalarBindings[[0]])) &&
           BundleComparisonGPRSelectorLegal(
               _BundleScalarBindings[[0]].destination) &&
           !output_binding.destination_valid &&
           (!_BundleDataAttributes.canonicalize) &&
           (TileElementBits(data_type) == 8 ||
            !_BundleDataAttributes.saturating) &&
           TileOperandsLegal_ExecuteTileCompareGPRAs(
               source_left, source_right,
               _BundleDataAttributes.saturating, data_type) &&
           !_BundleScalarBindings[[1]].valid;
end;

readonly func SelectedBundleClosedTSELSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTSELSchema(operation) then return TRUE; end;
    if BundleSharedBindingCount() != 0 || !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;
    let (operation_type_valid, data_type) = ResolveBundleEffectiveDataType();
    if !operation_type_valid || !TileSelectDataTypeSupported(data_type) then
        return FALSE;
    end;
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    let inputs = _BundleTileBindings[[0]];
    let cell_select = inputs.source0_valid &&
        _Tiles[[BundleTileSourceIndex(0, FALSE)]].storage_kind ==
            TileStorage_PredicateCell;
    if BundleTileBindingCount() !=
       (if cell_select || execution_mask_tile then 2 else 1) then
        return FALSE;
    end;
    let result = if BundleTileBindingCount() == 2 then
        _BundleTileBindings[[1]] else inputs;
    let split_gpr_select = !cell_select && execution_mask_tile;
    let binding_shape_invalid = if cell_select then
        inputs.destination_valid || !inputs.source0_valid ||
        !inputs.source1_valid || inputs.last ||
        !result.destination_valid || !result.source0_valid ||
        (result.source1_valid != execution_mask_tile) || !result.last
    else if split_gpr_select then
        inputs.destination_valid || !inputs.source0_valid ||
        !inputs.source1_valid || inputs.last ||
        !result.destination_valid || !result.source0_valid ||
        result.source1_valid || !result.last
    else
        !inputs.destination_valid || !inputs.source0_valid ||
        !inputs.source1_valid || !inputs.last;
    if binding_shape_invalid ||
       result.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(
           if BundleTileBindingCount() == 2 then 1 else 0) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal !=
            (if cell_select then 3 else 2)) then
        return FALSE;
    end;
    let source_true = if cell_select then
        BundleTileSourceIndex(0, TRUE) else BundleTileSourceIndex(0, FALSE);
    let source_false = if cell_select then
        BundleTileSourceIndex(1, FALSE) else BundleTileSourceIndex(0, TRUE);
    if cell_select then
        let mask = BundleTileSourceIndex(0, FALSE);
        return (!execution_mask_gpr ||
                (_BundleScalarBindings[[0]].valid &&
                 _BundleScalarBindings[[0]].destination == 0 &&
                 BundleExecutionMaskGPRBindingSchemaLegal(operation))) &&
               (execution_mask_gpr || !_BundleScalarBindings[[0]].valid) &&
               (!SelectedBundleComparisonCUBE(source_true) ||
                TileCubePredicateDataTypeSupported(data_type)) &&
               (if SelectedBundleComparisonCUBE(source_true) then
                   TilePredicateCellValuesLegal(mask) &&
                   TilePredicateCellShapeMatchesNumericAs(
                       mask, source_true, data_type)
                else
                   TilePredicateValuesLegal(mask)) &&
               SelectedBundleComparisonShapeMatch(source_true, source_false) &&
               _Tiles[[source_true]].storage_kind == TileStorage_Numeric &&
               TileRowMajorOrCUBENumericCarrierLegal(source_true, data_type) &&
               TileRowMajorOrCUBENumericCarrierLegal(source_false, data_type) &&
               SelectedBundleComparisonSourceContentsDefined(source_true) &&
               SelectedBundleComparisonSourceContentsDefined(source_false) &&
               SelectedBundleComparisonShapeMatches(source_true);
    end;
    if !SelectedBundleComparisonCUBE(source_true) then
        return !_BundleScalarBindings[[1]].valid &&
               (!_BundleScalarBindings[[0]].valid ||
                (_BundleScalarBindings[[0]].destination == 0 &&
                 BundleComparisonBindingUsesOneSource(
                     _BundleScalarBindings[[0]]))) &&
               TilePredicateValuesLegal(source_true) &&
               SelectedBundleComparisonShapeMatch(source_true, source_false) &&
               TileRowMajorNumericCarrierLegal(source_false, data_type) &&
               TileElementwiseSourceContentsDefined(source_false) &&
               TileLogicalShapeMatch(source_true, source_false);
    end;
    let mask_words = SelectedBundleComparisonGPRMaskWordCount(data_type);
    return TileCubePredicateGPRDataTypeSupported(data_type) &&
           TileCubePredicateGPRShapeLegalAs(source_true, data_type) &&
           SelectedBundleComparisonShapeMatch(source_true, source_false) &&
           _Tiles[[source_true]].storage_kind == TileStorage_Numeric &&
           TileRowMajorOrCUBENumericCarrierLegal(source_true, data_type) &&
           TileRowMajorOrCUBENumericCarrierLegal(source_false, data_type) &&
           SelectedBundleComparisonSourceContentsDefined(source_true) &&
           SelectedBundleComparisonSourceContentsDefined(source_false) &&
           SelectedBundleComparisonShapeMatches(source_true) &&
           _BundleScalarBindings[[0]].valid &&
           _BundleScalarBindings[[0]].destination == 0 &&
           (if execution_mask_gpr then
                BundleExecutionMaskGPRBindingSchemaLegal(operation)
            else if mask_words == 2 then
                BundleComparisonBindingUsesTwoSources(
                    _BundleScalarBindings[[0]])
            else
                BundleComparisonBindingUsesOneSource(
                    _BundleScalarBindings[[0]])) &&
           !_BundleScalarBindings[[1]].valid;
end;
```
<!-- GENERATED-ASL-END: unit -->
