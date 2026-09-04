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
    return code <= 14 || (16 <= code && code <= 20) ||
           (24 <= code && code <= 28);
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

pure func BundleOperationDescriptorLegal(
    descriptor: BundleOperationDescriptor) => boolean
begin
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
        return TRUE;
    end;
    if decoded_operation == TileOperation_TGPR2T then
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
            if _BundleTileBindings[[binding]].destination_valid then
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
    let matrix = _BundleOperation.valid &&
        _BundleOperation.operation_class == BundleOperation_TileMatrix;
    let expected_destinations =
        (if TileOperandPresent(operation, TileOperand_destination0)
         then 1 else 0) +
        (if matrix && _BundleFixedPointAttributes.row_max_en
         then 1 else 0) +
        (if matrix && _BundleFixedPointAttributes.group_max_en
         then 1 else 0);
    let expected_sources =
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
    if matrix && (source_count > 9 || destination_count > 3) then
        return FALSE;
    end;
    if destination_count != expected_destinations ||
       source_count != expected_sources then return FALSE; end;
    if binding_count > 0 && !BundleTileBindingStreamTerminated() then
        return FALSE;
    end;
    if !BundleOperationScalarBindingSchemaLegal(operation) then return FALSE; end;
    return TRUE;
end;
