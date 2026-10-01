<!-- GENERATED FROM: asl/block/model/dispatch/descriptor-legality.asl -->
# Descriptor Legality

**Normative ASL source:** `asl/block/model/dispatch/descriptor-legality.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-descriptor-legality-purpose role=purpose-scope -->
## Purpose and scope

This unit decides whether the operation descriptor decoded from a `BSTART` form may be installed, and how later dispatch reads it. The operation descriptor is the record of `operation_class`, `selector`, `data_type`, `mode`, and `branch_type` that names the bundle's operation.

It also owns three bundle-wide checks used during execution: the effective data type, the assemble output structure, and the operand count check `BundleOperationBindingsComplete`.

<!-- PTO-READER-BLOCK: block-model-dispatch-descriptor-legality-concepts role=concepts-state -->
## Concepts and visible state

The unit writes no state. It reads the installed descriptor `_BundleOperation`, the `B.DATR` state `_BundleDataAttributes`, the Tile and Shared bindings, `_BundleExecutionMask`, and `_BundleFixedPointAttributes`.

- A concrete data type code is 0 to 21 or 24 to 28. Code 31 is `DTYPE_NONE`, a field-level sentinel with no element width. `BundleDataTypeFieldValid` accepts a concrete code or `DTYPE_NONE`.
- `BundleSelectorCode` forms the 12-bit decode code. With a valid `mode`, the mode fills bits 6 to 5 and selector bits 4 to 0 fill bits 4 to 0. Otherwise the 10-bit selector fills bits 9 to 0.
- `BundleTileDecodeFamily` maps the Tile element, Tile memory, and Tile matrix classes to the `TEPL`, `TLSU`, and `CUBE` decode families.
- A legal branch type is `001`, `101`, `110`, or `111`, meaning fallthrough, indirect, indirect call, and return.

<!-- PTO-READER-BLOCK: block-model-dispatch-descriptor-legality-rules role=rules-interactions -->
## Rules and interactions

`BundleOperationDescriptorLegal` applies these rules in order.

1. A descriptor with the `BSTART.TIMG2COL` form identity (form 94) is legal only as the exact `TIMG2COL` descriptor: Tile memory class, selector 28, a data type, no mode, no branch type, and a data type code in the supported `TIMG2COL` set.
2. A present branch type must be legal.
3. A Tile class descriptor needs a selector and a valid data type field, and its decode code must name an operation in its family. The data type must then be concrete, unless the descriptor selects `TMOV` (Tile memory code 2).
4. A fixed-point class descriptor is always illegal. Any other class is legal.

`ExecuteDecodedBundleStart` calls this check, and then the profile's applicability rules, before it commits a predecessor bundle. Either failure raises `Fault_IllegalInstruction` at the `BSTART`.

Design point: the check runs before the predecessor commits. A `BSTART` with an illegal descriptor therefore faults without first committing the bundle before it.

Design point: `DTYPE_NONE` is accepted only for `TMOV`. For that operation `ResolveBundleEffectiveDataType` can infer a type from the first bound Local source with a configured descriptor, or from an unconsumed Shared source binding with a legal descriptor. Other operations have no source inference in `ResolveBundleEffectiveDataType`, so the descriptor check requires their concrete type at `BSTART`.

`ResolveBundleEffectiveDataType` returns the first of: a concrete `B.DATR` type, a concrete descriptor type, and the `TMOV` inference. If none applies it returns false. The ASL comment states that its FP64 companion value is then unobservable and is not a meaning for `DTYPE_NONE`.

`BundleOperationBindingsComplete` compares the bound Tile operand counts with the counts the operation expects. For a matrix operation, `B.FPATR` adds RowMax, GroupMax, CScale, and parameter operands. A predicate-Tile execution mask adds one source. `TCMP`, `TCMPS`, `TSEL`, and `TSELS` own their own schemas, and `TGPR2T` has a fixed shape. Matrix destinations must have distinct Tile IDs. Local sources plus parent references may not exceed 8 for any operation, and a matrix operation also may not exceed 9 sources or 3 destinations, so the limit of 8 is the one that binds sources.

<!-- PTO-READER-BLOCK: block-model-dispatch-descriptor-legality-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decode fields; the decode unit builds the descriptor. It does not raise faults itself. Callers choose the fault: the start path uses `Fault_IllegalInstruction`, and the Tile execution path raises `Fault_BundleControl` when `BundleAssembleOutputStructureLegal` or `BundleOperationBindingsComplete` fails. Several specialized handlers, for example `GMOV` and `MGATHER`, also call `BundleOperationBindingsComplete`.

<!-- PTO-READER-BLOCK: block-model-dispatch-descriptor-legality-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`BSTART.TMOV` with `DataType` 31 decodes to a Tile memory descriptor with selector 2 and data type `DTYPE_NONE`. Rule 3 finds `TMOV`, so the descriptor is legal. If the only `B.IOT` source is a configured Tile of type `FP16`, and no `B.DATR` supplies a concrete type, the effective type is `FP16`.

The same code 31 on a `BSTART.VEC` form that selects `TADD` never reaches this check: the `BSTART.TEPL` encoding behind `BSTART.VEC` accepts only concrete `DataType` codes, so `CommandFormOperandsLegal` rejects it first and the `BSTART` raises `Fault_IllegalInstruction`. Rule 3 is the descriptor-level guard for the same restriction.

<!-- PTO-READER-BLOCK: block-model-dispatch-descriptor-legality-related role=related-owners-navigation -->
## Related owners

- [Decode](decode.md) builds the descriptor that this unit checks.
- [Bundle start dispatch](start.md) calls the descriptor check before committing a predecessor.
- [Tile execution dispatch](tile-execution.md) calls the structure and operand count checks.
- [TMOV](../../../tile/layout-and-rearrangement/layout/TMOV.md) is the operation that may carry `DTYPE_NONE`.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/descriptor-legality.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","surface":"block","classification":["model","dispatch","descriptor-legality"],"depends_on":["PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES","PTO-BLOCK-MODEL-DISPATCH-DECODE"]}
pure func BundleBranchTypeLegal(branch_type: bits(3)) => boolean
begin
    return branch_type == '001' || branch_type == '101' ||
           branch_type == '110' || branch_type == '111';
end;

pure func BundleTransferOfBranchType(branch_type: bits(3)) => BundleTransfer
begin
    case branch_type of
        when '001' => return BundleTransfer_Fallthrough;
        when '101' => return BundleTransfer_Indirect;
        when '110' => return BundleTransfer_IndirectCall;
        when '111' => return BundleTransfer_Return;
        otherwise => unreachable;
    end;
end;

pure func BundleDataTypeSupported(data_type: bits(5)) => boolean
begin
    return BundleDataTypeConcrete(data_type);
end;

pure func BundleDataTypeConcrete(data_type: bits(5)) => boolean
begin
    let code = UInt(data_type);
    return code <= 21 || (24 <= code && code <= 28);
end;

pure func BundleDataTypeFieldValid(data_type: bits(5)) => boolean
begin
    return BundleDataTypeConcrete(data_type) || data_type == DTYPE_NONE;
end;

readonly func BundleDATRDataTypeApplicabilityCode() => bits(5)
begin
    if !_BundleDataAttributesPresent ||
       _BundleDataAttributes.data_type == DTYPE_NONE then
        return Zeros{5};
    end;
    return _BundleDataAttributes.data_type;
end;

pure func BundleTileDataType(data_type: bits(5)) => TileDataType
begin
    return TileDataTypeFromEncoding(data_type as TileDataTypeEncoding);
end;

pure func BundleDescriptorSelectsTMOV(
    descriptor: BundleOperationDescriptor) => boolean
begin
    if descriptor.operation_class != BundleOperation_TileMemory ||
       !descriptor.selector_valid then return FALSE; end;
    return BundleOperationDecodeCode(descriptor) == Zeros{12} + 2;
end;

readonly func BundleTMOVSelected() => boolean
begin
    return _BundleOperation.valid &&
           BundleDescriptorSelectsTMOV(_BundleOperation);
end;

readonly func ResolveBundleEffectiveDataType() => (boolean, TileDataType)
begin
    if _BundleDataAttributes.data_type_present &&
       BundleDataTypeConcrete(_BundleDataAttributes.data_type) then
        return (TRUE, BundleTileDataType(_BundleDataAttributes.data_type));
    end;
    if _BundleOperation.data_type_valid &&
       BundleDataTypeConcrete(_BundleOperation.data_type) then
        return (TRUE, BundleTileDataType(_BundleOperation.data_type));
    end;
    if BundleTMOVSelected() then
        for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
            if _BundleTileBindings[[binding]].valid then
                if _BundleTileBindings[[binding]].source0_valid &&
                   TileDescriptorConfigured(
                       _BundleTileBindings[[binding]].source0) then
                    return (TRUE, _Tiles[[
                        _BundleTileBindings[[binding]].source0]].data_type);
                elsif _BundleTileBindings[[binding]].source1_valid &&
                      TileDescriptorConfigured(
                          _BundleTileBindings[[binding]].source1) then
                    return (TRUE, _Tiles[[
                        _BundleTileBindings[[binding]].source1]].data_type);
                end;
            end;
        end;
        for binding = 0 to 3 do
            if _BundleSharedBindings[[binding]].valid &&
               !_BundleSharedBindings[[binding]].consumed &&
               !BundleSharedBindingIsReusedDestination(binding) &&
               !BundleSharedBindingIsDestination(binding) then
                let shared_tile_id = BundleSharedBindingId(binding);
                if SharedTileDescriptorLegal(shared_tile_id) then
                    return (TRUE, SharedTileRecord(shared_tile_id).tile.data_type);
                end;
            end;
        end;
    end;
    // This value is unobservable when the valid member is FALSE. FP64 is a
    // total ASL return value, never a default interpretation of DTYPE_NONE.
    return (FALSE, TileDataType_FP64);
end;

pure func BundleTileDecodeFamily(operation_class: BundleOperationClass)
        => TileDecodeFamily
begin
    case operation_class of
        when BundleOperation_TileElement => return TileDecode_TEPL;
        when BundleOperation_TileMemory => return TileDecode_TLSU;
        when BundleOperation_TileMatrix => return TileDecode_CUBE;
        otherwise => unreachable;
    end;
end;

pure func BundleSelectorCode(descriptor: BundleOperationDescriptor) => bits(12)
begin
    var code = Zeros{12};
    if descriptor.mode_valid then
        code[6:5] = descriptor.mode;
        code[4:0] = descriptor.selector[4:0];
    else
        code[9:0] = descriptor.selector;
    end;
    return code;
end;

pure func BundleOperationDecodeCode(
    descriptor: BundleOperationDescriptor) => bits(12)
begin
    return BundleSelectorCode(descriptor);
end;

pure func BundleDescriptorHasTIMG2COLFormIdentity(
    descriptor: BundleOperationDescriptor) => boolean
begin
    // BSTART.TIMG2COL is the final command form in the current frozen catalog.
    // Check its exact form as well as Function 28 so no other TLSU carrier can
    // acquire the command-only semantics.
    return descriptor.form_identity == Zeros{7} + 94;
end;

pure func BundleDescriptorSelectsTIMG2COL(
    descriptor: BundleOperationDescriptor) => boolean
begin
    return descriptor.valid &&
           BundleDescriptorHasTIMG2COLFormIdentity(descriptor) &&
           descriptor.operation_class == BundleOperation_TileMemory &&
           descriptor.selector_valid && descriptor.selector == Zeros{10} + 28 &&
           descriptor.data_type_valid && !descriptor.mode_valid &&
           !descriptor.branch_type_valid;
end;

pure func BundleDescriptorTIMG2COLDataTypeSupported(
    data_type: bits(5)) => boolean
begin
    let code = UInt(data_type);
    return code == 1 || code == 2 || code == 3 || code == 4 || code == 5 ||
           code == 6 || code == 7 || code == 8 || code == 13 ||
           code == 17 || code == 18 || code == 19 || code == 25 ||
           code == 26 || code == 27;
end;

pure func BundleOperationDescriptorLegal(
    descriptor: BundleOperationDescriptor) => boolean
begin
    if BundleDescriptorHasTIMG2COLFormIdentity(descriptor) then
        return BundleDescriptorSelectsTIMG2COL(descriptor) &&
               BundleDescriptorTIMG2COLDataTypeSupported(
                   descriptor.data_type);
    end;
    if descriptor.branch_type_valid &&
       !BundleBranchTypeLegal(descriptor.branch_type) then
        return FALSE;
    end;
    case descriptor.operation_class of
        when BundleOperation_TileElement,
             BundleOperation_TileMemory,
             BundleOperation_TileMatrix =>
            if !descriptor.selector_valid || !descriptor.data_type_valid ||
               !BundleDataTypeFieldValid(descriptor.data_type) then
                return FALSE;
            end;
            let operation = DecodeTileOperation(
                BundleTileDecodeFamily(descriptor.operation_class),
                BundleOperationDecodeCode(descriptor));
            if operation == PTO_TILE_OPERATION_COUNT then return FALSE; end;
            return BundleDataTypeConcrete(descriptor.data_type) ||
                   BundleDescriptorSelectsTMOV(descriptor);
        when BundleOperation_FixedPoint =>
            // PTO v0 has no direct FIXP selector family. The accepted spelling
            // remains decodable but cannot install an executable descriptor.
            return FALSE;
        otherwise => return TRUE;
    end;
end;

pure func BundleOperationDescriptorRejectedByAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet,
    descriptor: BundleOperationDescriptor) => boolean
begin
    case descriptor.operation_class of
        when BundleOperation_TileElement,
             BundleOperation_TileMemory,
             BundleOperation_TileMatrix =>
            if !descriptor.selector_valid then return FALSE; end;
            let decoded = DecodeTileOperation(
                BundleTileDecodeFamily(descriptor.operation_class),
                BundleOperationDecodeCode(descriptor));
            if decoded == PTO_TILE_OPERATION_COUNT then return FALSE; end;
            let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
            return TileOperationRejectedByAcceptedApplicabilityRules(
                rules, operation);
        otherwise => return FALSE;
    end;
end;

readonly func BundleAssembleOutputStructureLegal() => boolean
begin
    var destination_count: integer = 0;
    var source_count: integer = 0;
    var local_continuations: integer = 0;
    var shared_continuations: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].destination_valid &&
               !_BundleTileBindings[[binding]].destination_reused_by_generation then
                destination_count = destination_count + 1;
            end;
            if _BundleTileBindings[[binding]].source0_valid then
                source_count = source_count + 1;
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                source_count = source_count + 1;
            end;
            if _BundleTileBindings[[binding]].destination_assemble.valid &&
               !_BundleTileBindings[[binding]].destination_assemble.init then
                local_continuations = local_continuations + 1;
            end;
        end;
    end;
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid &&
           !_BundleSharedBindings[[binding]].destination_assemble.init then
            shared_continuations = shared_continuations + 1;
        end;
    end;
    let local_parent_refs = BundleLocalTileParentRefCount();
    let shared_destinations = BundleSharedPhysicalDestinationCount();
    let shared_reused_destinations = BundleSharedReusedDestinationCount();
    if local_parent_refs > 1 then return FALSE; end;
    if local_continuations != 0 && local_parent_refs != 1 then
        return FALSE;
    end;
    if shared_continuations != 0 then
        if shared_reused_destinations != 1 ||
           !BundleSharedReusedDestinationIsFinal() ||
           BundleSharedBindingCount() > 3 || local_parent_refs != 0 then
            return FALSE;
        end;
    end;
    if local_parent_refs == 1 then
        if !BundleLocalTileParentRefIsFinal() || destination_count != 0 ||
           source_count > 7 || shared_destinations != 0 then
            return FALSE;
        end;
    end;
    if shared_reused_destinations != 0 && shared_continuations == 0 then
        return FALSE;
    end;
    if shared_reused_destinations > 1 then return FALSE; end;
    if shared_reused_destinations == 1 then
        if destination_count != 0 || shared_destinations != 0 ||
           local_parent_refs != 0 then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func BundleOperationBindingsComplete(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded_operation = TileOperationOfIndex(operation);
    if decoded_operation == TileOperation_TCMP ||
       decoded_operation == TileOperation_TCMPS ||
       decoded_operation == TileOperation_TSEL ||
       decoded_operation == TileOperation_TSELS then
        // Comparison/select carriers own their complete mutually-exclusive
        // binding schemas; the generic tile operand arity is not applicable.
        if _BundleExecutionMask.valid &&
           _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile then
            return BundleLocalTileSourceCount() ==
                _BundleExecutionMask.predicate_source_ordinal + 1;
        end;
        return TRUE;
    end;
    if decoded_operation == TileOperation_TGPR2T then
        if _BundleExecutionMask.valid &&
           _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile then
            return BundleTileBindingCount() == 1 &&
                   _BundleTileBindings[[0]].valid &&
                   _BundleTileBindings[[0]].destination_valid &&
                   _BundleTileBindings[[0]].source0_valid &&
                   !_BundleTileBindings[[0]].source1_valid &&
                   _BundleTileBindings[[0]].last &&
                   BundleLocalTileSourceCount() == 1;
        end;
        if BundleTileBindingCount() != 1 ||
           !_BundleTileBindings[[0]].valid ||
           !_BundleTileBindings[[0]].destination_valid ||
           _BundleTileBindings[[0]].source0_valid ||
           _BundleTileBindings[[0]].source1_valid ||
           !_BundleTileBindings[[0]].last then
            return FALSE;
        end;
        return TRUE;
    end;
    var destination_count: integer = 0;
    var source_count: integer = 0;
    var binding_count: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            binding_count = binding_count + 1;
            if _BundleTileBindings[[binding]].destination_valid &&
               !_BundleTileBindings[[binding]].destination_reused_by_generation then
                destination_count = destination_count + 1;
            end;
            if _BundleTileBindings[[binding]].source0_valid then
                source_count = source_count + 1;
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                source_count = source_count + 1;
            end;
        end;
    end;
    if !BundleAssembleOutputStructureLegal() then return FALSE; end;
    let local_parent_refs = BundleLocalTileParentRefCount();
    let matrix = _BundleOperation.valid &&
        _BundleOperation.operation_class == BundleOperation_TileMatrix;
    let expected_destinations =
        (if TileOperandPresent(operation, TileOperand_destination0)
         then 1 else 0) +
        (if matrix && _BundleFixedPointAttributes.row_max_en
         then 1 else 0) +
        (if matrix && _BundleFixedPointAttributes.group_max_en
         then 1 else 0);
    var expected_sources =
        (if TileOperandPresent(operation, TileOperand_source0)
         then 1 else 0) +
        (if TileOperandPresent(operation, TileOperand_source1)
         then 1 else 0) +
        (if TileOperandPresent(operation, TileOperand_source2)
         then 1 else 0) +
        (if TileOperandPresent(operation, TileOperand_source3)
         then 1 else 0) +
        (if TileOperandPresent(operation, TileOperand_source4)
         then 1 else 0) +
        (if matrix && _BundleFixedPointAttributes.c_scale_en
         then 1 else 0) +
        (if matrix && _BundleFixedPointAttributes.row_max_en &&
            _BundleFixedPointAttributes.row_max_init
         then 1 else 0) +
        (if matrix && BundleFPATRModeUsesVectorParameter(
               _BundleFixedPointAttributes.pre_quant_mode)
         then 1 else 0) +
        (if matrix && BundleFPATRReluModeUsesVectorParameter(
               _BundleFixedPointAttributes.relu_mode)
         then 1 else 0);
    if _BundleExecutionMask.valid &&
       _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile then
        expected_sources = (expected_sources + 1) as integer {0..9};
    end;
    // Matrix post-processing is a complete-bundle schema contribution.  The
    // static catalog carries mathematical operands; B.FPATR contributes
    // optional RowMax/parameter streams and compact auxiliary destinations.
    if matrix then
        if !_BundleFixedPointAttributes.valid then return FALSE; end;
    elsif _BundleFixedPointAttributes.valid then
        return FALSE;
    end;
    if matrix && destination_count > 1 then
        // D, RowMaxOut and GroupMaxOut are one atomic output group.  Their
        // architectural Tile IDs must be distinct; source/destination alias
        // checks remain operation-specific (RowMaxIn may equal RowMaxOut).
        for first = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
            if _BundleTileBindings[[first]].valid &&
               _BundleTileBindings[[first]].destination_valid then
                for second = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
                    if first != second &&
                       _BundleTileBindings[[second]].valid &&
                       _BundleTileBindings[[second]].destination_valid &&
                       _BundleTileBindings[[first]].destination ==
                       _BundleTileBindings[[second]].destination then
                        return FALSE;
                    end;
                end;
            end;
        end;
    end;
    // The complete-bundle B.FPATR carrier has nine compact Local source
    // ordinals and three compact destination ordinals. Reject surplus
    // streams before descriptor allocation or operand consumption.
    if (source_count + local_parent_refs > 8) ||
       (matrix && (source_count > 9 || destination_count > 3)) then
        return FALSE;
    end;
    let effective_destination_count = destination_count + local_parent_refs +
        BundleSharedPhysicalDestinationCount() +
        BundleSharedReusedDestinationCount();
    if effective_destination_count != expected_destinations ||
       source_count != expected_sources then return FALSE; end;
    if binding_count > 0 && !BundleTileBindingStreamTerminated() then
        return FALSE;
    end;
    if !BundleOperationScalarBindingSchemaLegal(operation) then return FALSE; end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
