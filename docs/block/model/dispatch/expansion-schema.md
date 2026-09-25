<!-- GENERATED FROM: asl/block/model/dispatch/expansion-schema.asl -->
# Expansion Schema

**Normative ASL source:** `asl/block/model/dispatch/expansion-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/expansion-schema.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","expansion-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-EXPDIF-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"],"id":"PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","surface":"block"}

pure func TileOperationUsesClosedRowExpansionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWEXPAND ||
           decoded == TileOperation_TROWEXPANDADD ||
           decoded == TileOperation_TROWEXPANDSUB ||
           decoded == TileOperation_TROWEXPANDMUL ||
           decoded == TileOperation_TROWEXPANDDIV ||
           decoded == TileOperation_TROWEXPANDMAX ||
           decoded == TileOperation_TROWEXPANDMIN ||
           decoded == TileOperation_TROWEXPANDEXPDIF;
end;

pure func TileOperationUsesClosedColumnExpansionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TCOLEXPAND ||
           decoded == TileOperation_TCOLEXPANDADD ||
           decoded == TileOperation_TCOLEXPANDSUB ||
           decoded == TileOperation_TCOLEXPANDMUL ||
           decoded == TileOperation_TCOLEXPANDDIV ||
           decoded == TileOperation_TCOLEXPANDMAX ||
           decoded == TileOperation_TCOLEXPANDMIN ||
           decoded == TileOperation_TCOLEXPANDEXPDIF;
end;

pure func TileOperationUsesClosedExpansionSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationUsesClosedRowExpansionSchema(operation) ||
           TileOperationUsesClosedColumnExpansionSchema(operation);
end;

pure func TileExpansionOperationIsCopy(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWEXPAND ||
           decoded == TileOperation_TCOLEXPAND;
end;

pure func TileExpansionOperationIsExponentialDifference(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TROWEXPANDEXPDIF ||
           decoded == TileOperation_TCOLEXPANDEXPDIF;
end;

readonly func SelectedBundleExpansionBroadcastShapeMatches(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    broadcast: TileIndex) => boolean
begin
    let valid_columns = UInt(_BundleDimensions[[0]]);
    let valid_rows = UInt(_BundleDimensions[[1]]);
    if TileOperationUsesClosedRowExpansionSchema(operation) then
        return _Tiles[[broadcast]].valid_rows == valid_rows &&
               _Tiles[[broadcast]].valid_columns >= 1;
    end;
    return _Tiles[[broadcast]].valid_rows >= 1 &&
           _Tiles[[broadcast]].valid_columns == valid_columns;
end;

readonly func SelectedBundleClosedExpansionSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedExpansionSchema(operation) then
        return TRUE;
    end;
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let copy = TileExpansionOperationIsCopy(operation);
    let split_final_binding = execution_mask_tile && !copy;
    if BundleTileBindingCount() != (if split_final_binding then 2 else 1) ||
       BundleSharedBindingCount() != 0 ||
       (_BundleScalarBindings[[0]].valid != execution_mask_gpr) ||
       (execution_mask_gpr &&
        !BundleExecutionMaskGPRBindingSchemaLegal(operation)) ||
       !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    let final_binding = if split_final_binding then
        _BundleTileBindings[[1]] else binding;
    if BundleTileBindingCount() != (if split_final_binding then 2 else 1) ||
       !final_binding.destination_valid ||
       final_binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(
           if split_final_binding then 1 else 0) ||
       !binding.source0_valid ||
       (if copy then
            binding.source1_valid != execution_mask_tile
        else if split_final_binding then
            !binding.source1_valid || binding.destination_valid || binding.last ||
            final_binding.source0_valid != execution_mask_tile ||
            final_binding.source1_valid || !final_binding.last
        else
            !binding.source1_valid || !binding.last) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal !=
            (if copy then 1 else 2)) then
        return FALSE;
    end;

    let operation_sources = if split_final_binding then
        binding else final_binding;
    let broadcast = if copy then
        binding.source0 else operation_sources.source1;
    var data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    let expdif = TileExpansionOperationIsExponentialDifference(operation);
    var source_data_type = data_type;
    if expdif then
        let (types_legal, selected_source_type, selected_destination_type) =
            SelectedBundleExponentialDifferenceTypes();
        if !types_legal then
            return FALSE;
        end;
        source_data_type = selected_source_type;
        data_type = selected_destination_type;
    end;
    if (!expdif && !TileVecArithmeticDataTypeSupported(data_type)) ||
       !TileReductionAndExpansionLayoutSupported(
           CurrentBundleTileLayout()) ||
       _Tiles[[broadcast]].layout != CurrentBundleTileLayout() ||
       !(if copy then
             TileReductionAndExpansionSourceContentsDefined(broadcast) &&
             TileCarrierWidthCompatible(
                 _Tiles[[broadcast]].data_type, source_data_type)
         else TileExpansionBroadcastLegalAs(
             broadcast,
             if TileOperationUsesClosedRowExpansionSchema(operation) then
                 TileAxis_Row
             else TileAxis_Column,
             source_data_type)) ||
       !SelectedBundleExpansionBroadcastShapeMatches(
           operation, broadcast) then
        return FALSE;
    end;

    if copy then
        return TRUE;
    end;
    return _Tiles[[operation_sources.source0]].layout == CurrentBundleTileLayout() &&
           TileReductionAndExpansionSourceLegalAs(
               operation_sources.source0, source_data_type) &&
           SelectedBundleComparisonShapeMatches(operation_sources.source0) &&
           ((TileOperationOfIndex(operation) != TileOperation_TROWEXPANDDIV &&
             TileOperationOfIndex(operation) != TileOperation_TCOLEXPANDDIV) ||
            !TileDataTypeIsInteger(data_type) ||
            TileBroadcastPayloadNonzero(
                if TileOperationUsesClosedRowExpansionSchema(operation) then
                    TileAxis_Row
                else
                    TileAxis_Column,
                operation_sources.source0,
                operation_sources.source1));
end;
```
<!-- GENERATED-ASL-END: unit -->
