<!-- GENERATED FROM: asl/block/model/dispatch/tile-scalar-schema.asl -->
# Tile Scalar Schema

**Normative ASL source:** `asl/block/model/dispatch/tile-scalar-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tile-scalar-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the closed bundle schemas for the Tile-scalar operations of TEPL Mode 1. A Tile-scalar operation combines each element of one Tile with one scalar value read from a register. A closed schema is the exact set of bindings, dimensions, and types a bundle must carry for one operation.

It covers four groups:

- the binary group `TADDS`, `TSUBS`, `TMULS`, `TDIVS`, `TREMS`, `TANDS`, `TORS`, `TXORS`, `TSHLS`, `TSHRS`, `TMAXS`, and `TMINS`;
- the compare `TCMPS`;
- the select `TSELS`;
- the fill `TEXPANDS`.

Each `SelectedBundleClosed...SchemaLegal` function returns true for operations outside its group. The tile-execution owner calls them through `SelectedBundleClosedSchemasLegal`, and a false result raises `Fault_TileLegality` before destination allocation.

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-scalar-schema-concepts role=concepts-state -->
## Concepts and visible state

- The scalar comes from the first scalar binding's `source0` register through `SelectedBundleTileScalarRawValue`. With no scalar binding it is zero.
- A raw carrier operation treats elements as bit patterns. In the binary group these are `TANDS`, `TORS`, `TXORS`, `TSHLS`, and `TSHRS`.
- An active coordinate is an element position the execution mask enables. With no mask every position is active.

The schemas read Tile bindings, scalar bindings, dimensions, data attributes, the execution mask, the source Tile descriptors, and the scalar register. They write no state.

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-scalar-schema-rules role=rules-interactions -->
## Rules and interactions

The binary schema requires one Tile binding, no Shared binding, and dimensions in `1..65535`. The binding names a destination with a legal size code, a `source0`, and is last. `source1` appears only as a predicate-Tile execution mask at source ordinal 1. The data type must be supported for that binary operation, the layout must be elementwise, and the source must match the dimensions and be defined. For non-raw operations the source elements and the scalar must be valid encodings of the data type.

Design point: for integer `TDIVS` and `TREMS`, the schema rejects a zero scalar when at least one coordinate is active. The division is then rejected before any destination is allocated. When the execution mask has no active coordinate, a zero divisor is accepted, because no element would be divided.

`TCMPS` requires one binding, legal dimensions, and a comparison mode of at most 5. The rest depends on the source layout.

- A RowMajor source writes a Tile destination. The scalar binding is optional; when present it has destination 0 and one source, or follows the GPR mask schema.
- A CUBE source with a destination writes a U8 predicate Tile. Saturating and canonicalize must be off.
- A CUBE source without a destination writes a GPR. The scalar binding is required and names the destination register. Canonicalize must be off, and saturating is allowed only for 8-bit types.

`TSELS` depends on whether the first source is a PredicateCell, which is a predicate stored in a CUBE cell, and on whether the true source uses a CUBE layout. A PredicateCell select with a predicate-Tile mask uses two bindings. A select whose first source is not a CUBE Tile requires `source1`, no execution-mask Tile, and a legacy Predicate Tile as `source0`. A CUBE select without a PredicateCell reads its predicate from GPRs: two sources for one mask word, three for two words.

`TEXPANDS` requires one binding with a destination and no sources, except the mask at ordinal 0. It needs a supported arithmetic type and a layout supported for reduction and expansion.

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-scalar-schema-boundaries role=boundaries -->
## Architectural boundaries

These schemas return booleans and raise no fault themselves. Destination allocation belongs to the destination owners, and the arithmetic belongs to the Tile model. Comparison dimension and shape helpers come from the comparison-schema owner. `SelectedBundleTileScalarSourceLegal`, defined here, has no caller in the current ASL; the binary schema uses the elementwise variant.

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-scalar-schema-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A `TDIVS` bundle uses `S32`. The source Tile has 8 valid rows and 16 valid columns, and the dimensions are 16, 8, and 16. One `B.IOT` names the destination and source and is last. One `B.IOR` names GPR 9 as `source0`, and GPR 9 holds 0. With no execution mask every element is active, so the schema fails and the bundle faults with `Fault_TileLegality` before allocation. If GPR 9 held 3, the schema would pass.

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-scalar-schema-related role=related-owners-navigation -->
## Related owners

- [Comparison schema](comparison-schema.md) defines the shared comparison helpers.
- [Tile schema](tile-schema.md) holds the Tile-Tile closed schemas.
- [Tile execution](tile-execution.md) calls these schemas.
- [TADDS](../../../tile/tile-scalar-and-immediate/arithmetic/TADDS.md) is one of the instruction pages.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tile-scalar-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","surface":"block","classification":["model","dispatch","tile-scalar-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}
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
           SelectedBundleComparisonSourceContentsDefined(source) &&
           TileSourceEncodingsValid(source) &&
           SelectedBundleComparisonShapeMatches(source);
end;

readonly func SelectedBundleTileScalarElementwiseSourceLegal(
    source: TileIndex,
    data_type: TileDataType) => boolean
begin
    return TileElementwiseDescriptorLegal(source) &&
           _Tiles[[source]].storage_kind == TileStorage_Numeric &&
           TileCarrierWidthCompatible(_Tiles[[source]].data_type, data_type) &&
           TileElementwiseLayoutSupported(_Tiles[[source]].layout) &&
           SelectedBundleComparisonSourceContentsDefined(source) &&
           TileElementwiseSourceEncodingsValid(source) &&
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

    let binary = TileScalarBinaryOperation(operation);
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    let raw_carrier = binary == TileBinary_AND ||
                      binary == TileBinary_OR ||
                      binary == TileBinary_XOR ||
                      binary == TileBinary_SHL ||
                      binary == TileBinary_SHR;
    if !TileBinaryDataTypeSupported(binary, data_type) ||
       !TileElementwiseLayoutSupported(CurrentBundleTileLayout()) ||
       !SelectedBundleTileScalarElementwiseSourceLegal(
           binding.source0,
           data_type) then
        return FALSE;
    end;
    if !raw_carrier &&
       !TileElementwiseSourceEncodingsValidAs(binding.source0, data_type) then
        return FALSE;
    end;

    let scalar = TileRawElementValue(
        SelectedBundleTileScalarRawValue(),
        data_type);
    if !raw_carrier && !TileNumericEncodingValid(data_type, scalar) then
        return FALSE;
    end;
    if (binary == TileBinary_DIV || binary == TileBinary_REM) &&
       TileDataTypeIsInteger(data_type) &&
       BundleExecutionMaskHasActiveCoordinate() then
        return !IsZero(TileIntegerOperandValue(scalar, data_type));
    end;
    return TRUE;
end;

readonly func SelectedBundleClosedTCMPSSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTCMPSSchema(operation) then return TRUE; end;
    if BundleTileBindingCount() != 1 || BundleSharedBindingCount() != 0 ||
       !SelectedBundleComparisonDimensionsLegal() then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.source0_valid ||
       (binding.source1_valid != execution_mask_tile) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal != 1) ||
       !binding.last ||
       UInt(_BundleDataAttributes.comparison_mode) > 5 then return FALSE; end;
    let source = BundleTileSourceIndex(0, FALSE);
    let (operation_type_valid, data_type) = ResolveBundleEffectiveDataType();
    let scalar_present = _BundleScalarBindings[[0]].valid;
    let cube = SelectedBundleComparisonCUBE(source);
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    if !operation_type_valid ||
       !TileCompareDataTypeSupported(data_type) ||
       _Tiles[[source]].storage_kind != TileStorage_Numeric ||
       !TileRowMajorOrCUBENumericCarrierLegal(source, data_type) ||
       !SelectedBundleComparisonSourceContentsDefined(source) ||
       !SelectedBundleComparisonShapeMatches(source) then return FALSE; end;
    if cube && !TileCubePredicateDataTypeSupported(data_type) then
        return FALSE;
    end;
    if cube && !TileCubeNumericSourceLegalAs(source, data_type) then
        return FALSE;
    end;
    if !cube && !TileElementwiseSourceEncodingsValidAs(source, data_type) then
        return FALSE;
    end;
    if !cube then
        return binding.destination_valid &&
               !binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(0) &&
               !_BundleScalarBindings[[1]].valid &&
               (!scalar_present ||
                (_BundleScalarBindings[[0]].destination == 0 &&
                 (if execution_mask_gpr then
                      BundleExecutionMaskGPRBindingSchemaLegal(operation)
                  else
                      BundleComparisonBindingUsesOneSource(
                          _BundleScalarBindings[[0]]))));
    end;
    if binding.destination_valid then
        let capacity_bytes = BundleLocalDestinationAllocationBytes(0);
        return !binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(0) &&
               TileCubeDescriptorShapeLegal(
                   capacity_bytes, _Tiles[[source]].valid_rows,
                   _Tiles[[source]].valid_columns, TileDataType_U8,
                   _Tiles[[source]].layout) &&
               !_BundleDataAttributes.saturating &&
               !_BundleDataAttributes.canonicalize &&
               (!scalar_present ||
                (_BundleScalarBindings[[0]].destination == 0 &&
                 (if execution_mask_gpr then
                      BundleExecutionMaskGPRBindingSchemaLegal(operation)
                  else
                      BundleComparisonBindingUsesOneSource(
                          _BundleScalarBindings[[0]])))) &&
               !_BundleScalarBindings[[1]].valid;
    end;
    // GPR form consumes the scalar compare source and writes one B.IOR dst.
    return scalar_present &&
           (if execution_mask_gpr then
                BundleExecutionMaskGPRBindingSchemaLegal(operation)
            else
                BundleComparisonBindingUsesOneSource(
                    _BundleScalarBindings[[0]])) &&
           BundleComparisonGPRSelectorLegal(
               _BundleScalarBindings[[0]].destination) &&
           !_BundleDataAttributes.canonicalize &&
           (TileElementBits(data_type) == 8 ||
            !_BundleDataAttributes.saturating) &&
           TileOperandsLegal_ExecuteTileCompareCUBEScalarGPRAs(
               source, SelectedBundleTileScalarRawValue(), data_type) &&
           !_BundleScalarBindings[[1]].valid;
end;

readonly func SelectedBundleClosedTSELSSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTSELSSchema(operation) then return TRUE; end;
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
    let split_final_binding = cell_select && execution_mask_tile;
    if BundleTileBindingCount() != (if split_final_binding then 2 else 1) then
        return FALSE;
    end;
    let result = if split_final_binding then
        _BundleTileBindings[[1]] else inputs;
    if !inputs.source0_valid ||
       (if cell_select then
            !inputs.source1_valid
        else
            inputs.source1_valid != execution_mask_tile) ||
       (if split_final_binding then
            inputs.destination_valid || inputs.last ||
            !result.source0_valid || result.source1_valid || !result.last
        else
            !inputs.destination_valid || !inputs.last) ||
       !result.destination_valid || result.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(
           if split_final_binding then 1 else 0) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal !=
            (if cell_select then 2 else 1)) then
        return FALSE;
    end;
    let first = BundleTileSourceIndex(0, FALSE);
    let source_true = if cell_select then BundleTileSourceIndex(0, TRUE)
        else first;
    let cube = SelectedBundleComparisonCUBE(source_true);
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        if split_final_binding then 1 else 0);
    if cell_select then
        return cube && TileCubePredicateDataTypeSupported(data_type) &&
               (!execution_mask_gpr ||
                (_BundleScalarBindings[[0]].valid &&
                 _BundleScalarBindings[[0]].destination == 0 &&
                 BundleExecutionMaskGPRBindingSchemaLegal(operation))) &&
               (execution_mask_gpr ||
                (!_BundleScalarBindings[[1]].valid &&
                 (!_BundleScalarBindings[[0]].valid ||
                  (_BundleScalarBindings[[0]].destination == 0 &&
                   BundleComparisonBindingUsesOneSource(
                       _BundleScalarBindings[[0]]))))) &&
               TilePredicateCellOperationValuesLegal(first) &&
               TilePredicateCellShapeMatchesNumericAs(
                   first, source_true, data_type) &&
               _Tiles[[source_true]].storage_kind == TileStorage_Numeric &&
               TileRowMajorOrCUBENumericCarrierLegal(source_true, data_type) &&
               SelectedBundleComparisonSourceContentsDefined(source_true) &&
               TileCubeDescriptorShapeLegal(
                   capacity_bytes, _Tiles[[source_true]].valid_rows,
                   _Tiles[[source_true]].valid_columns, data_type,
                   _Tiles[[source_true]].layout);
    end;

    if !cube then
        return inputs.source1_valid && !execution_mask_tile &&
               (!_BundleScalarBindings[[1]].valid) &&
               (!_BundleScalarBindings[[0]].valid ||
                (_BundleScalarBindings[[0]].destination == 0 &&
                 BundleComparisonBindingUsesOneSource(
                     _BundleScalarBindings[[0]]))) &&
               TilePredicateValuesLegal(first) &&
               TileRowMajorNumericCarrierLegal(source_true, data_type) &&
               TileElementwiseSourceContentsDefined(source_true) &&
               TileLogicalShapeMatch(first, source_true);
    end;

    // The GPR selection predicate stays operation-owned; any ExecutionMask
    // GPR words follow it, while a PredicateCell ExecutionMask is the final
    // B.IOT source and is filtered from the arithmetic operand list.
    let mask_words = if TileCubePredicateGPRDataTypeSupported(data_type) then
        SelectedBundleComparisonGPRMaskWordCount(data_type) else 1;
    return TileCubePredicateGPRDataTypeSupported(data_type) &&
           _BundleScalarBindings[[0]].valid &&
           _BundleScalarBindings[[0]].destination == 0 &&
           (if execution_mask_gpr then
                BundleExecutionMaskGPRBindingSchemaLegal(operation)
            else if mask_words == 2 then
                BundleComparisonBindingUsesThreeSources(
                    _BundleScalarBindings[[0]])
            else
                BundleComparisonBindingUsesTwoSources(
                    _BundleScalarBindings[[0]])) &&
           _Tiles[[source_true]].storage_kind == TileStorage_Numeric &&
           TileRowMajorOrCUBENumericCarrierLegal(source_true, data_type) &&
           TileCubePredicateGPRShapeLegalAs(source_true, data_type) &&
           SelectedBundleComparisonSourceContentsDefined(source_true) &&
           TileCubeDescriptorShapeLegal(
               capacity_bytes, _Tiles[[source_true]].valid_rows,
               _Tiles[[source_true]].valid_columns, data_type,
               _Tiles[[source_true]].layout) &&
           (execution_mask_gpr || !_BundleScalarBindings[[1]].valid);
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
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       (binding.source0_valid != execution_mask_tile) ||
       binding.source1_valid ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal != 0) ||
       !binding.last then
        return FALSE;
    end;

    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    return TileVecArithmeticDataTypeSupported(data_type) &&
           TileReductionAndExpansionLayoutSupported(
               CurrentBundleTileLayout());
end;
```
<!-- GENERATED-ASL-END: unit -->
