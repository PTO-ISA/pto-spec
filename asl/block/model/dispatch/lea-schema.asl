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
