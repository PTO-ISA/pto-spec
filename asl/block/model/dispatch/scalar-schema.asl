// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","surface":"block","classification":["model","dispatch","scalar-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-TILE-MODEL-NUMERIC-FORMATS"]}
pure func BundleOperationConsumesScalarSource0(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperandPresent(operation, TileOperand_address) ||
           TileOperandPresent(operation, TileOperand_scalar0);
end;

pure func BundleOperationConsumesScalarSource1(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return (TileOperandPresent(operation, TileOperand_address) &&
            (TileOperandPresent(operation, TileOperand_scalar0) ||
             TileOperandPresent(operation, TileOperand_scalar1))) ||
           (TileOperandPresent(operation, TileOperand_scalar0) &&
            TileOperandPresent(operation, TileOperand_scalar1));
end;

// Complete-bundle GPR inputs are packed in the architectural order
// address, scalar0, scalar1, diagonal, flag0.  Tile operands that are not
// present in the selected operation do not consume a B.IOR source slot.
readonly func BundleOperationGPRInputCount(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => integer {0..7}
begin
    var count: integer {0..7} = 0;
    if TileOperandPresent(operation, TileOperand_address) then
        count = (count + 1) as integer {0..7};
    end;
    if TileOperandPresent(operation, TileOperand_scalar0) then
        count = (count + 1) as integer {0..7};
    end;
    if TileOperandPresent(operation, TileOperand_scalar1) then
        count = (count + 1) as integer {0..7};
    end;
    if TileOperandPresent(operation, TileOperand_diagonal) then
        count = (count + 1) as integer {0..7};
    end;
    if TileOperandPresent(operation, TileOperand_flag0) then
        count = (count + 1) as integer {0..7};
    end;
    if _BundleOperation.valid &&
       _BundleOperation.operation_class == BundleOperation_TileMatrix &&
       _BundleFixedPointAttributes.valid then
        if BundleFPATRModeUsesScalarParameter(
               _BundleFixedPointAttributes.pre_quant_mode) then
            count = (count + 1) as integer {0..7};
        end;
        if BundleFPATRReluModeUsesScalarParameter(
               _BundleFixedPointAttributes.relu_mode) then
            count = (count + 1) as integer {0..7};
        end;
    end;
    return count;
end;

pure func BundleOperationGPRInputSlot(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    field: TileOperandField) => integer {0..5}
begin
    var slot: integer {0..5} = 0;
    if TileOperandPresent(operation, TileOperand_address) then
        if field == TileOperand_address then return slot; end;
        slot = (slot + 1) as integer {0..5};
    end;
    if TileOperandPresent(operation, TileOperand_scalar0) then
        if field == TileOperand_scalar0 then return slot; end;
        slot = (slot + 1) as integer {0..5};
    end;
    if TileOperandPresent(operation, TileOperand_scalar1) then
        if field == TileOperand_scalar1 then return slot; end;
        slot = (slot + 1) as integer {0..5};
    end;
    if TileOperandPresent(operation, TileOperand_diagonal) then
        if field == TileOperand_diagonal then return slot; end;
        slot = (slot + 1) as integer {0..5};
    end;
    if TileOperandPresent(operation, TileOperand_flag0) then
        if field == TileOperand_flag0 then return slot; end;
        slot = (slot + 1) as integer {0..5};
    end;
    return 3;
end;

readonly func BundleOperationGPRInputSelector(
    slot: integer {0..2}) => Reg5Selector
begin
    if !_BundleScalarBindings[[0]].valid then return 0; end;
    case slot of
        when 0 => return _BundleScalarBindings[[0]].source0;
        when 1 => return _BundleScalarBindings[[0]].source1;
        when 2 => return _BundleScalarBindings[[0]].source2;
    end;
    unreachable;
end;

readonly func BundleOperationGPRBindingValuesLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !_BundleScalarBindings[[0]].valid then return TRUE; end;
    let input_count = BundleOperationGPRInputCount(operation);
    if input_count > 3 then return FALSE; end;
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TQUANT ||
       decoded == TileOperation_TDEQUANT then
        let scale = ReadScalarRegisterOperand(
            BundleOperationGPRInputSelector(0));
        let zero_point = ReadScalarRegisterOperand(
            BundleOperationGPRInputSelector(1));
        if !TileQuantizationScaleLegal(scale) then return FALSE; end;
        let zero_point_type = if decoded == TileOperation_TQUANT then
            if _BundleDataAttributes.data_type_present &&
               BundleDataTypeConcrete(_BundleDataAttributes.data_type) then
                BundleTileDataType(_BundleDataAttributes.data_type)
            else TileDataType_FP64
        else if _BundleOperation.data_type_valid &&
                BundleDataTypeConcrete(_BundleOperation.data_type) then
            BundleTileDataType(_BundleOperation.data_type)
        else TileDataType_FP64;
        if !TileQuantizationZeroPointLegal(
               zero_point,
               zero_point_type) then
            return FALSE;
        end;
    end;
    if TileOperandPresent(operation, TileOperand_flag0) then
        let slot = BundleOperationGPRInputSlot(operation, TileOperand_flag0);
        let raw = ReadScalarRegisterOperand(
            BundleOperationGPRInputSelector(slot as integer {0..2}));
        let value = UInt(raw);
        if value != 0 && value != 1 then return FALSE; end;
    end;
    if TileOperandPresent(operation, TileOperand_diagonal) then
        let slot = BundleOperationGPRInputSlot(operation, TileOperand_diagonal);
        let raw = ReadScalarRegisterOperand(
            BundleOperationGPRInputSelector(slot as integer {0..2}));
        let value = SInt(raw);
        if value < -65535 || value > 65535 then return FALSE; end;
    end;
    if _BundleOperation.valid &&
       _BundleOperation.operation_class == BundleOperation_TileMatrix &&
       _BundleFixedPointAttributes.valid then
        var post_slot: integer {0..5} = 0;
        if TileOperandPresent(operation, TileOperand_address) then
            post_slot = (post_slot + 1) as integer {0..5};
        end;
        if TileOperandPresent(operation, TileOperand_scalar0) then
            post_slot = (post_slot + 1) as integer {0..5};
        end;
        if TileOperandPresent(operation, TileOperand_scalar1) then
            post_slot = (post_slot + 1) as integer {0..5};
        end;
        if TileOperandPresent(operation, TileOperand_diagonal) then
            post_slot = (post_slot + 1) as integer {0..5};
        end;
        if TileOperandPresent(operation, TileOperand_flag0) then
            post_slot = (post_slot + 1) as integer {0..5};
        end;

        if BundleFPATRModeUsesScalarParameter(
               _BundleFixedPointAttributes.pre_quant_mode) then
            let raw = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(
                    post_slot as integer {0..2}));
            if !BundleFPATRQuantParameterWordLegal(
                   _BundleFixedPointAttributes.pre_quant_mode, raw) then
                return FALSE;
            end;
            post_slot = (post_slot + 1) as integer {0..5};
        end;
        if BundleFPATRReluModeUsesScalarParameter(
               _BundleFixedPointAttributes.relu_mode) then
            let raw = ReadScalarRegisterOperand(
                BundleOperationGPRInputSelector(
                    post_slot as integer {0..2}));
            if !BundleFPATRReluParameterWordLegal(raw) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func BundleOperationScalarBindingSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !_BundleScalarBindings[[0]].valid then return TRUE; end;
    let input_count = BundleOperationGPRInputCount(operation);
    if input_count < 3 && _BundleScalarBindings[[0]].source2 != 0 then
        return FALSE;
    end;
    if input_count < 2 && _BundleScalarBindings[[0]].source1 != 0 then
        return FALSE;
    end;
    if input_count < 1 && _BundleScalarBindings[[0]].source0 != 0 then
        return FALSE;
    end;
    return _BundleScalarBindings[[0]].destination == 0;
end;
