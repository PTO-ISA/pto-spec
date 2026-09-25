// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","surface":"block","classification":["model","dispatch","scalar-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-TILE-MODEL-NUMERIC-FORMATS","PTO-BLOCK-MODEL-DISPATCH-WEIGHT-TO-SHARED-SCHEMA","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS"]}
readonly func DecodedBundleCommandKeepsTGPR2TStreamLegal(
    instruction: bits(64), form: integer {0..PTO_COMMAND_FORM_COUNT-1})
    => boolean
begin
    let handler = CommandHandlerOfForm(form);
    let zero_participation = handler == CommandHandler_BindBundleTileIO &&
        PEMaskOfPEMode(DecodeCommandOperandRaw(
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


readonly func BundleExecutionMaskGPRStreamSelected() => boolean
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
           TileOperationExecutionMaskEligible(
               decoded as integer {0..PTO_TILE_OPERATION_COUNT-1});
end;

readonly func BundleMultiIORSelected() => boolean
begin
    return BundleTGPR2TSelected() ||
           BundleDescriptorSelectsTIMG2COL(_BundleOperation) ||
           BundleExecutionMaskGPRStreamSelected();
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
    if !BundleTGPR2TScalarCommandCanBePlaced(
           binding_index, instruction, form) ||
       !BundleTIMG2COLScalarCommandCanBePlaced(
           binding_index, instruction, form) then
        return FALSE;
    end;
    if BundleExecutionMaskGPRStreamSelected() && binding_index == 1 then
        return CommandDecodedReg5(instruction, form, CommandField_RegDst) == 0 &&
               !_BundleScalarBindings[[0]].execution_mask_present;
    end;
    return TRUE;
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

readonly func BundleExecutionMaskGPRWordCount(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => integer {1..2}
begin
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    return if TileOperationExecutionMaskEligible(operation) &&
        TileElementBits(data_type) == 8 then 2 else 1;
end;

readonly func BundleExecutionMaskOperationGPRSourceCount(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => integer {0..5}
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TCMP then return 0; end;
    if decoded == TileOperation_TCMPS then return 1; end;
    if decoded == TileOperation_TSEL then
        // One B.IOT carries the GPR-selection form; two carry the
        // PredicateCell-selection form. The operation-owned select mask is
        // therefore present only in the former.
        return if BundleTileBindingCount() == 1 then
            BundleExecutionMaskGPRWordCount(operation) else 0;
    end;
    if decoded == TileOperation_TSELS then
        // The scalar-false role remains before ExecutionMask. A GPR select
        // carrier contributes one/two more operation-owned source words;
        // the PredicateCell form contributes only scalar-false.
        return (1 + (if _BundleTileBindings[[0]].source1_valid then 0
                    else BundleExecutionMaskGPRWordCount(operation)))
            as integer {0..5};
    end;
    if decoded == TileOperation_TGPR2T then return 4; end;
    return BundleOperationGPRInputCount(operation) as integer {0..5};
end;

readonly func BundleExecutionMaskGPRSourceSelector(
    slot: integer {0..5}) => Reg5Selector
begin
    if slot < 3 then
        case slot of
            when 0 => return _BundleScalarBindings[[0]].source0;
            when 1 => return _BundleScalarBindings[[0]].source1;
            when 2 => return _BundleScalarBindings[[0]].source2;
        end;
    end;
    case slot - 3 of
        when 0 => return _BundleScalarBindings[[1]].source0;
        when 1 => return _BundleScalarBindings[[1]].source1;
        when 2 => return _BundleScalarBindings[[1]].source2;
    end;
    unreachable;
end;

readonly func BundleExecutionMaskGPRBindingSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationExecutionMaskEligible(operation) ||
       (CurrentBundleTileLayout() != TileLayout_CUBE_M16 &&
        CurrentBundleTileLayout() != TileLayout_CUBE_M32) then
        return FALSE;
    end;
    let operation_sources = BundleExecutionMaskOperationGPRSourceCount(operation);
    let mask_words = BundleExecutionMaskGPRWordCount(operation);
    let total_sources = operation_sources + mask_words;
    if total_sources > 6 || !_BundleScalarBindings[[0]].valid then
        return FALSE;
    end;
    let uses_second = total_sources > 3;
    if _BundleScalarBindings[[1]].valid != uses_second ||
       _BundleScalarBindings[[0]].execution_mask_present == uses_second ||
       (uses_second &&
        !_BundleScalarBindings[[1]].execution_mask_present) then
        return FALSE;
    end;
    if (TileOperationOfIndex(operation) == TileOperation_TCMP ||
        TileOperationOfIndex(operation) == TileOperation_TCMPS) then
        if _BundleScalarBindings[[0]].destination >= PTO_ABSOLUTE_GPR_COUNT ||
           (uses_second && _BundleScalarBindings[[1]].destination != 0) then
            return FALSE;
        end;
    elsif _BundleScalarBindings[[0]].destination != 0 ||
          (uses_second && _BundleScalarBindings[[1]].destination != 0) then
        return FALSE;
    end;
    for slot = 0 to 5 looplimit 6 do
        let selector = BundleExecutionMaskGPRSourceSelector(slot);
        if slot < total_sources then
            if selector >= PTO_ABSOLUTE_GPR_COUNT then return FALSE; end;
        elsif selector != 0 then
            return FALSE;
        end;
    end;
    return TRUE;
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
    if _BundleScalarBindings[[0]].execution_mask_present ||
       _BundleScalarBindings[[1]].execution_mask_present then
        if !BundleExecutionMaskGPRBindingSchemaLegal(operation) then
            return FALSE;
        end;
    end;
    if decoded == TileOperation_TCMP ||
       decoded == TileOperation_TCMPS ||
       decoded == TileOperation_TSEL ||
       decoded == TileOperation_TSELS then
        // These operations have operation-specific carrier arity and roles.
        return TRUE;
    end;
    if decoded == TileOperation_TGPR2T then
        if _BundleScalarBindings[[0]].execution_mask_present ||
           _BundleScalarBindings[[1]].execution_mask_present then
            return TRUE;
        end;
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
    if decoded == TileOperation_TCI &&
       (CurrentBundleTileLayout() == TileLayout_CUBE_M16 ||
        CurrentBundleTileLayout() == TileLayout_CUBE_M32) then
        // CUBE TCI uses the second physical B.IOR source as a packed raw
        // Step2D word rather than as the RowMajor boolean direction.
        if !_BundleScalarBindings[[0]].valid ||
           _BundleScalarBindings[[0]].source0 >= PTO_ABSOLUTE_GPR_COUNT ||
           _BundleScalarBindings[[0]].source1 >= PTO_ABSOLUTE_GPR_COUNT then
            return FALSE;
        end;
        let participation_mask = _BundleTileBindings[[0]].pe_mask;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            if participation_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                let step2d = ReadPEAbsoluteGPROperand(
                    pe as MemoryAgentId, _BundleScalarBindings[[0]].source1);
                let row_step = SInt(step2d[63:32]);
                let column_step = SInt(step2d[31:0]);
                if (row_step != -1 && row_step != 0 && row_step != 1) ||
                   (column_step != -1 && column_step != 0 && column_step != 1) then
                    return FALSE;
                end;
            end;
        end;
        return TRUE;
    end;
    if TileOperationExecutionMaskEligible(operation) &&
       (_BundleScalarBindings[[0]].execution_mask_present ||
        _BundleScalarBindings[[1]].execution_mask_present) then
        // The complete ExecutionMask schema already checked every consumed
        // selector and every unused field. Validate only the operation-owned
        // raw boolean and diagonal values here; appended mask words must not
        // be mistaken for unused ordinary scalar selectors.
        if TileOperandPresent(operation, TileOperand_flag0) then
            let slot = BundleOperationGPRInputSlot(
                operation, TileOperand_flag0);
            let raw = ReadScalarRegisterOperand(
                BundleExecutionMaskGPRSourceSelector(
                    slot as integer {0..5}));
            let value = UInt(raw);
            if value != 0 && value != 1 then return FALSE; end;
        end;
        if TileOperandPresent(operation, TileOperand_diagonal) then
            let slot = BundleOperationGPRInputSlot(
                operation, TileOperand_diagonal);
            let raw = ReadScalarRegisterOperand(
                BundleExecutionMaskGPRSourceSelector(
                    slot as integer {0..5}));
            let value = SInt(raw);
            if value < -65535 || value > 65535 then return FALSE; end;
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
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TEXPDIF &&
       !_BundleScalarBindings[[0]].execution_mask_present &&
       !_BundleScalarBindings[[1]].execution_mask_present then
        return !_BundleScalarBindings[[0]].valid &&
               !_BundleScalarBindings[[1]].valid;
    end;
    if _BundleScalarBindings[[0]].execution_mask_present ||
       _BundleScalarBindings[[1]].execution_mask_present then
        return BundleExecutionMaskGPRBindingSchemaLegal(operation);
    end;
    if decoded == TileOperation_TCI &&
       (CurrentBundleTileLayout() == TileLayout_CUBE_M16 ||
        CurrentBundleTileLayout() == TileLayout_CUBE_M32) then
        // CUBE TCI has exactly one canonical B.IOR: two absolute GPR
        // selectors, an explicit zero source2, and an explicit zero dst.
        return _BundleScalarBindings[[0]].valid &&
               !_BundleScalarBindings[[1]].valid &&
               _BundleScalarBindings[[0]].source_count == 3 &&
               _BundleScalarBindings[[0]].destination == 0 &&
               _BundleScalarBindings[[0]].source0 < PTO_ABSOLUTE_GPR_COUNT &&
               _BundleScalarBindings[[0]].source1 < PTO_ABSOLUTE_GPR_COUNT &&
               _BundleScalarBindings[[0]].source2 == 0;
    end;
    if !_BundleScalarBindings[[0]].valid then return TRUE; end;
    if BundleWeightTLOADSelected() then
        return !_BundleScalarBindings[[1]].valid &&
               _BundleScalarBindings[[0]].source_count == 3 &&
               _BundleScalarBindings[[0]].destination == 0;
    end;
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
