<!-- GENERATED FROM: asl/block/model/dispatch/scalar-schema.asl -->
# Scalar Schema

**Normative ASL source:** `asl/block/model/dispatch/scalar-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/scalar-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","surface":"block","classification":["model","dispatch","scalar-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-TILE-MODEL-NUMERIC-FORMATS"]}
readonly func DecodedBundleCommandKeepsTGPR2TStreamLegal(
    instruction: bits(64), form: integer {0..PTO_COMMAND_FORM_COUNT-1})
    => boolean
begin
    let handler = CommandHandlerOfForm(form);
    let zero_participation = handler == CommandHandler_BindBundleTileIO &&
        PTOv0PEMaskOfPEMode(DecodeCommandOperandRaw(
            instruction, form, CommandField_PEMode)[2:0]) == Zeros{4};
    return _BundleZeroParticipationSeen ||
           !BundleTGPR2TSelected() ||
           !_BundleScalarBindings[[0]].valid ||
           _BundleScalarBindings[[1]].valid ||
           handler == CommandHandler_BindBundleScalarIO ||
           zero_participation;
end;

readonly func BundleTIMG2COLIORSecondExpected() => boolean
begin
    return BundleDescriptorSelectsTIMG2COL(_BundleOperation) &&
           _BundleScalarBindings[[0]].valid &&
           !_BundleScalarBindings[[1]].valid;
end;

readonly func DecodedBundleCommandKeepsTIMG2COLStreamLegal(
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => boolean
begin
    return !BundleTIMG2COLIORSecondExpected() ||
           CommandHandlerOfForm(form) == CommandHandler_BindBundleScalarIO;
end;

readonly func BundleTIMG2COLScalarCommandCanBePlaced(
    binding_index: integer {0..1}, instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => boolean
begin
    if !BundleDescriptorSelectsTIMG2COL(_BundleOperation) then return TRUE; end;
    if BundleTileBindingCount() != 0 || BundleSharedBindingCount() != 0 ||
       CommandDecodedReg5(instruction, form, CommandField_RegDst) != 0 then
        return FALSE;
    end;
    if binding_index == 0 then
        return CommandDecodedReg5(instruction, form, CommandField_RegSrc1) == 0 &&
               CommandDecodedReg5(instruction, form, CommandField_RegSrc2) == 0;
    end;
    return TRUE;
end;

readonly func BundleTGPR2TScalarCommandCanBePlaced(
    binding_index: integer {0..1}, instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => boolean
begin
    return !BundleTGPR2TSelected() ||
           ((binding_index != 0 || BundleTileBindingCount() == 0) &&
            CommandDecodedReg5(instruction, form, CommandField_RegDst) == 0);
end;

readonly func BundleTGPR2TScalarBindingsComplete() => boolean
begin
    return _BundleScalarBindings[[0]].valid &&
           _BundleScalarBindings[[1]].valid;
end;

readonly func BundleTGPR2TSelected() => boolean
begin
    if !_BundleOperation.valid ||
       (_BundleOperation.operation_class != BundleOperation_TileElement &&
        _BundleOperation.operation_class != BundleOperation_TileMemory &&
        _BundleOperation.operation_class != BundleOperation_TileMatrix) then
        return FALSE;
    end;
    let decoded = DecodeTileOperation(
        BundleTileDecodeFamily(_BundleOperation.operation_class),
        BundleOperationDecodeCode(_BundleOperation));
    return decoded != PTO_TILE_OPERATION_COUNT &&
           TileOperationOfIndex(
               decoded as integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
               TileOperation_TGPR2T;
end;

readonly func BundleMultiIORSelected() => boolean
begin
    return BundleTGPR2TSelected() ||
           BundleDescriptorSelectsTIMG2COL(_BundleOperation);
end;

readonly func BundleMultiIORBindingIndex() => integer {0..1}
begin
    if BundleMultiIORSelected() && _BundleScalarBindings[[0]].valid then
        return 1;
    end;
    return 0;
end;

readonly func BundleMultiIORScalarCommandCanBePlaced(
    binding_index: integer {0..1}, instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => boolean
begin
    return BundleTGPR2TScalarCommandCanBePlaced(
               binding_index, instruction, form) &&
           BundleTIMG2COLScalarCommandCanBePlaced(
               binding_index, instruction, form);
end;

pure func BundleOperationConsumesScalarSource0(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperandPresent(operation, TileOperand_address) ||
           TileOperandPresent(operation, TileOperand_scalar0);
end;

pure func BundleOperationConsumesScalarSource1(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperandPresent(operation, TileOperand_address) &&
           TileOperandPresent(operation, TileOperand_scalar0);
end;

// Complete-bundle GPR inputs are packed in the architectural order
// address, scalar0, diagonal, flag0.  Tile operands that are not
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
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TCMP ||
       decoded == TileOperation_TCMPS ||
       decoded == TileOperation_TSEL ||
       decoded == TileOperation_TSELS then
        // These operations have operation-specific carrier arity and roles.
        return TRUE;
    end;
    if decoded == TileOperation_TGPR2T then
        if !_BundleScalarBindings[[0]].valid ||
           !_BundleScalarBindings[[1]].valid ||
           _BundleScalarBindings[[0]].destination != 0 ||
           _BundleScalarBindings[[1]].destination != 0 ||
           _BundleScalarBindings[[0]].source_count != 3 ||
           _BundleScalarBindings[[1]].source_count != 1 ||
           _BundleScalarBindings[[1]].source1 != 0 ||
           _BundleScalarBindings[[1]].source2 != 0 ||
           _BundleScalarBindings[[0]].source0 >= PTO_ABSOLUTE_GPR_COUNT ||
           _BundleScalarBindings[[0]].source1 >= PTO_ABSOLUTE_GPR_COUNT ||
           _BundleScalarBindings[[0]].source2 >= PTO_ABSOLUTE_GPR_COUNT ||
           _BundleScalarBindings[[1]].source0 >= PTO_ABSOLUTE_GPR_COUNT then
            return FALSE;
        end;
        return TRUE;
    end;
    if _BundleScalarBindings[[1]].valid then return FALSE; end;
    if !_BundleScalarBindings[[0]].valid then return TRUE; end;
    let input_count = BundleOperationGPRInputCount(operation);
    if input_count > 3 then return FALSE; end;
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
```
<!-- GENERATED-ASL-END: unit -->
