<!-- GENERATED FROM: asl/block/model/dispatch/commands.asl -->
# Commands

**Normative ASL source:** `asl/block/model/dispatch/commands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-COMMANDS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/commands.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-COMMANDS","surface":"block","classification":["model","dispatch","commands"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-START","PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS"]}
readonly func BundleFixedPointAttributesCanBePlaced() => boolean
begin
    if !_BundleActive ||
       _BundleBodyActive ||
       _BundleFixedPointAttributes.valid then
        return FALSE;
    end;

    if _BundleOperation.valid &&
       _BundleOperation.operation_class != BundleOperation_TileMatrix then
        return FALSE;
    end;

    return !_BundleScalarBindings[[0]].valid &&
           BundleTileBindingCount() == 0 &&
           BundleSharedBindingCount() == 0;
end;

func ExecuteDecodedBundleCommand(instruction: bits(64),
                                form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                                length_bits: integer {16,32,48,64})
                                => CommandExecutionStatus
begin
    let handler = CommandHandlerOfForm(form);
    let hint_trace = handler == CommandHandler_SetBundleHint &&
        CommandOperandPresent(form, CommandField_B_E);
    if !CommandHandlerSupportedPTOv0(handler) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    let range_modifier = handler == CommandHandler_ApplyBundleSubview ||
        handler == CommandHandler_ApplyBundleAssemble;
    if !range_modifier then
        // Any non-modifier command terminates the immediately preceding
        // binder/modifier group.  The association is never retroactive.
        CloseBundleRangeGroup();
    end;
    if handler == CommandHandler_ExecuteQueueMove then
        let flags = CommandDecodedQueueMoveFlags(instruction, form);
        if flags[1:0] == '11' then
            SetFault(Fault_IllegalInstruction, ReadTPC());
            return CommandExecution_Rejected;
        end;
        let source_left = CommandDecodedReg5(
            instruction,
            form,
            CommandField_SrcL);
        if !ScalarSourceSelectorLegal(source_left) then
            SetFault(Fault_IllegalInstruction, ReadTPC());
            return CommandExecution_Rejected;
        end;
        if flags[3] == '1' then
            let source_right = CommandDecodedReg5(
                instruction,
                form,
                CommandField_SrcR);
            if !ScalarSourceSelectorLegal(source_right) then
                SetFault(Fault_IllegalInstruction, ReadTPC());
                return CommandExecution_Rejected;
            end;
        end;
    elsif handler == CommandHandler_ExecuteQueuePush then
        let source_left = CommandDecodedReg5(
            instruction,
            form,
            CommandField_SrcL);
        let source_right = CommandDecodedReg5(
            instruction,
            form,
            CommandField_SrcR);
        if !ScalarSourceSelectorLegal(source_left) ||
           !ScalarSourceSelectorLegal(source_right) then
            SetFault(Fault_IllegalInstruction, ReadTPC());
            return CommandExecution_Rejected;
        end;
    elsif handler == CommandHandler_ExecuteQueuePop then
        let source_left = CommandDecodedReg5(
            instruction,
            form,
            CommandField_SrcL);
        if !ScalarSourceSelectorLegal(source_left) then
            SetFault(Fault_IllegalInstruction, ReadTPC());
            return CommandExecution_Rejected;
        end;
    end;
    case handler of
        when CommandHandler_SetBundleControlAttributes =>
            if !_BundleActive || _BundleBodyActive ||
               _BundleControlAttributes.present then
                SetFault(Fault_BundleControl, ReadTPC());
                return CommandExecution_Rejected;
            end;
            SetBundleControlAttributeState(
                CommandDecodedBool(instruction, form, CommandField_trap),
                CommandDecodedBool(instruction, form, CommandField_atom),
                CommandDecodedBool(instruction, form, CommandField_aq),
                CommandDecodedBool(instruction, form, CommandField_rl),
                CommandDecodedBool(instruction, form, CommandField_far),
                CommandDecodedBool(instruction, form, CommandField_DR));
        when CommandHandler_SetBundleDataAttributes =>
            if !_BundleActive || _BundleBodyActive ||
               _BundleDataAttributesPresent then
                SetFault(Fault_BundleControl, ReadTPC());
                return CommandExecution_Rejected;
            end;
            SetBundleDataAttributeState(
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_DataType)[4:0],
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_Layout)[4:0],
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_PadValueOrByteId)[1:0],
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_CMode)[2:0],
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_RMode)[2:0],
                CommandDecodedBool(instruction, form, CommandField_Sat),
                CommandDecodedBool(
                    instruction, form, CommandField_Canonicalize));
            if _LastFault == Fault_None then
                _BundleDataAttributesPresent = TRUE;
            end;
        when CommandHandler_SetBundleFixedPointAttributes =>
            if !BundleFixedPointAttributesCanBePlaced() then
                SetFault(Fault_BundleControl, ReadTPC());
                return CommandExecution_Rejected;
            end;
            SetBundleFixedPointAttributeState(
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_PreQuantMode)[5:0],
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_ReluMode)[2:0],
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_GroupNCode)[3:0],
                CommandDecodedBool(instruction, form, CommandField_RowMaxEn),
                CommandDecodedBool(instruction, form, CommandField_GroupMaxEn),
                CommandDecodedBool(instruction, form, CommandField_RowMaxInit),
                CommandDecodedBool(instruction, form, CommandField_MaxAbsEn),
                CommandDecodedBool(instruction, form, CommandField_TransA),
                CommandDecodedBool(instruction, form, CommandField_TransB));
        when CommandHandler_SetBundleDimension =>
            if !_BundleActive || _BundleBodyActive then
                SetFault(Fault_BundleControl, ReadTPC());
                return CommandExecution_Rejected;
            elsif CommandOperandPresent(form, CommandField_RegSrc) then
                let sum = ReadScalarRegisterOperand(CommandDecodedReg5(instruction,
                        form, CommandField_RegSrc)) +
                    if CommandOperandPresent(form, CommandField_uimm17) then
                        CommandDecodedWord(instruction, form, CommandField_uimm17)
                    else Zeros{PTO_XLEN};
                SetBundleDimension(CommandDecodedBundleDimension(instruction, form),
                    ZeroExtend{PTO_XLEN}(sum[15:0]));
            else
                SetBundleDimension(CommandDecodedBundleDimension(instruction, form),
                    CommandDecodedWord(instruction, form, CommandField_imm8));
            end;
        when CommandHandler_BindBundleSharedIO =>
            let pe_mode = DecodeCommandOperandRaw(instruction, form,
                CommandField_PEMode)[2:0];
            let shared_size = CommandDecodedSmall(
                instruction, form, CommandField_SizeCode)
                as integer {0..12};
            if !TileSizeCodeIsLegal(shared_size) && shared_size != 0 then
                SetFault(Fault_IllegalInstruction, ReadTPC());
                return CommandExecution_Rejected;
            end;
            let shared_mask = PTOv0PEMaskOfPEMode(pe_mode);
            if shared_mask == Zeros{4} then
                // Strict no-op before placement, duplicate, stream, schema,
                // allocation, descriptor, and operation-specific checks.
                if _BundleActive && !_BundleBodyActive then
                    _BundleZeroParticipationSeen = TRUE;
                    OpenBundleRangeSharedGroup(TRUE, shared_size == 0,
                        shared_size != 0);
                end;
                WriteTPC(ReadTPC() + (Zeros{PTO_XLEN} + (length_bits DIV 8)));
                return CommandExecution_Executed;
            end;
            if !_BundleActive || _BundleBodyActive then
                SetFault(Fault_BundleControl, ReadTPC());
                return CommandExecution_Rejected;
            end;
            BindBundleSharedIO(
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_SharedTileID)[5:0] as SharedTileID,
                shared_size,
                shared_mask);
            if _LastFault == Fault_None then
                OpenBundleRangeSharedGroup(FALSE, shared_size == 0,
                    shared_size != 0);
            end;
        when CommandHandler_BindBundleScalarIO =>
            if !_BundleActive || _BundleBodyActive ||
               _BundleScalarBindings[[0]].valid then
                SetFault(Fault_BundleControl, ReadTPC());
                return CommandExecution_Rejected;
            end;
            SetBundleScalarBinding(0,
                CommandDecodedReg5(instruction, form, CommandField_RegDst),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc0),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc1),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc2), 3);
        when CommandHandler_BindBundleTileIO =>
            let pe_mode = DecodeCommandOperandRaw(
                instruction, form, CommandField_PEMode)[2:0];
            let local_destination =
                CommandOperandPresent(form, CommandField_DstTile);
            let encoded_tile_size = CommandDecodedSmall(
                instruction, form, CommandField_SizeCode);
            if !local_destination && encoded_tile_size != 0 then
                SetFault(Fault_IllegalInstruction, ReadTPC());
                return CommandExecution_Rejected;
            end;
            let tile_size = if local_destination then encoded_tile_size else 0;
            if local_destination && !LocalTileSizeCodeIsLegal(tile_size) then
                SetFault(Fault_IllegalInstruction, ReadTPC());
                return CommandExecution_Rejected;
            end;
            let pe_mask = PTOv0PEMaskOfPEMode(pe_mode);
            if pe_mask == Zeros{4} then
                // Strict no-op: zero participation suppresses every later
                // placement, stream, schema, allocation, and descriptor check.
                if _BundleActive && !_BundleBodyActive then
                    _BundleZeroParticipationSeen = TRUE;
                    OpenBundleRangeTileGroup(TRUE,
                        CommandOperandPresent(form, CommandField_SrcTile0),
                        CommandOperandPresent(form, CommandField_SrcTile1),
                        CommandOperandPresent(form, CommandField_DstTile));
                end;
                WriteTPC(ReadTPC() + (Zeros{PTO_XLEN} + (length_bits DIV 8)));
                return CommandExecution_Executed;
            end;
            if !_BundleActive || _BundleBodyActive ||
               BundleTileBindingSequenceClosed() then
                SetFault(Fault_BundleControl, ReadTPC());
                return CommandExecution_Rejected;
            end;
            let local_to_shared =
                _BundleOperation.valid &&
                _BundleOperation.operation_class == BundleOperation_TileMemory &&
                _BundleOperation.selector_valid &&
                (_BundleOperation.selector[4:0] == '01001' ||
                 _BundleOperation.selector[4:0] == '01010');
            if !BundleTileMaskCanAppend(pe_mask) ||
                (local_destination && tile_size == 0) ||
                (local_to_shared &&
                 CommandOperandPresent(form, CommandField_DstTile)) then
                SetFault(Fault_TileLegality, ReadTPC());
                return CommandExecution_Rejected;
            end;
            AddBundleTileBinding(
                local_destination,
                if CommandOperandPresent(form, CommandField_DstTile) then
                    CommandDecodedTile(instruction, form, CommandField_DstTile)
                else 0,
                tile_size,
                pe_mask,
                CommandOperandPresent(form, CommandField_SrcTile0),
                CommandOperandPresent(form, CommandField_SrcTile1),
                if CommandOperandPresent(form, CommandField_SrcTile0) then
                    CommandDecodedTile(instruction, form, CommandField_SrcTile0)
                else 0,
                if CommandOperandPresent(form, CommandField_SrcTile1) then
                    CommandDecodedTile(instruction, form, CommandField_SrcTile1)
                else 0,
                CommandOperandPresent(form, CommandField_L) &&
                    CommandDecodedBool(instruction, form, CommandField_L));
            if _LastFault == Fault_None then
                OpenBundleRangeTileGroup(FALSE,
                    CommandOperandPresent(form, CommandField_SrcTile0),
                    CommandOperandPresent(form, CommandField_SrcTile1),
                    CommandOperandPresent(form, CommandField_DstTile));
            end;
        when CommandHandler_ApplyBundleSubview =>
            let reg_src = CommandDecodedReg5(instruction, form,
                CommandField_RegSrc);
            let size_code = CommandDecodedSmall(instruction, form,
                CommandField_SubviewSizeCode);
            let source_select = CommandDecodedBool(instruction, form,
                CommandField_SrcSelect);
            let uimm11 = DecodeCommandOperandRaw(instruction, form,
                CommandField_uimm11)[10:0];
            // Decode legality is checked before PEMode suppression and before
            // any GPR read.  Reserved selectors/codes therefore leave all
            // carriers and the range-group state unchanged.
            if !ScalarSourceSelectorLegal(reg_src) ||
               !BundleRangeSubviewRawLegal(size_code) then
                SetFault(Fault_IllegalInstruction, ReadTPC());
                return CommandExecution_Rejected;
            end;
            if !BundleRangeSubviewLegal(source_select, size_code) then
                if !_BundleRangeGroup.zero_mode &&
                   _BundleRangeGroup.kind == BundleRangeGroup_Local &&
                   (size_code == 11 || size_code == 12) then
                    SetFault(Fault_TileLegality, ReadTPC());
                else
                    SetFault(Fault_BundleControl, ReadTPC());
                end;
                return CommandExecution_Rejected;
            end;
            if !_BundleRangeGroup.zero_mode then
                let offset = ReadScalarRegisterOperand(reg_src) +
                    ZeroExtend{PTO_XLEN}(uimm11);
                RecordBundleRangeSubview(source_select, reg_src, uimm11,
                    size_code as integer {1..12}, offset);
            end;
        when CommandHandler_ApplyBundleAssemble =>
            let reg_src = CommandDecodedReg5(instruction, form,
                CommandField_RegSrc);
            let size_code = CommandDecodedSmall(instruction, form,
                CommandField_ParentSizeCode);
            let init = CommandDecodedBool(instruction, form,
                CommandField_INIT);
            let last = CommandDecodedBool(instruction, form,
                CommandField_LAST);
            let uimm11 = DecodeCommandOperandRaw(instruction, form,
                CommandField_uimm11)[10:0];
            if !ScalarSourceSelectorLegal(reg_src) || size_code > 12 then
                SetFault(Fault_IllegalInstruction, ReadTPC());
                return CommandExecution_Rejected;
            end;
            if !BundleRangeAssembleLegal(init, size_code) then
                if !_BundleRangeGroup.zero_mode &&
                   _BundleRangeGroup.kind == BundleRangeGroup_Local &&
                   (size_code == 11 || size_code == 12) then
                    SetFault(Fault_TileLegality, ReadTPC());
                else
                    SetFault(Fault_BundleControl, ReadTPC());
                end;
                return CommandExecution_Rejected;
            end;
            if !_BundleRangeGroup.zero_mode then
                let offset = ReadScalarRegisterOperand(reg_src) +
                    ZeroExtend{PTO_XLEN}(uimm11);
                RecordBundleRangeAssemble(init, last, reg_src, uimm11,
                    size_code as integer {0..12}, offset);
            end;
        when CommandHandler_ExecuteBundleStart =>
            ExecuteDecodedBundleStart(instruction, form, length_bits);
        when CommandHandler_ExecuteBundleStop =>
            let completed = CompleteBundleAt(ReadTPC() +
                (Zeros{PTO_XLEN} + (length_bits DIV 8)));
        when CommandHandler_SetBundleHint =>
            if hint_trace then
                let instruction_pc = ReadTPC();
                if _BundleActive && !CompleteBundleAt(instruction_pc) then
                    return CommandExecution_Rejected;
                end;
                ClearBundleHeaderState();
                let sequential = instruction_pc +
                    (Zeros{PTO_XLEN} + (length_bits DIV 8));
                BeginBundle(BundleKind_Standard,
                    BundleTransfer_Fallthrough, sequential, sequential,
                    sequential, TRUE);
                if _LastFault != Fault_None then
                    return CommandExecution_Rejected;
                end;
            elsif !_BundleActive || _BundleBodyActive ||
                  _BundleHint.present then
                SetFault(Fault_BundleControl, ReadTPC());
                return CommandExecution_Rejected;
            end;
            _LastBundleHintPayload = instruction;
            _BundleHint.present = TRUE;
            _BundleHint.trace = hint_trace;
            _BundleHint.trace_end = hint_trace &&
                CommandDecodedBool(instruction, form, CommandField_B_E);
            _BundleHint.branch_valid = !hint_trace &&
                CommandDecodedBool(instruction, form, CommandField_V);
            _BundleHint.branch_likely = !hint_trace &&
                CommandDecodedBool(instruction, form, CommandField_L_UL);
            _BundleHint.temperature = if hint_trace then Zeros{2}
                else DecodeCommandOperandRaw(instruction, form,
                    CommandField_temp)[1:0];
            _BundleHint.prefetch_size = if hint_trace then Zeros{12}
                else DecodeCommandOperandRaw(instruction, form,
                    CommandField_prefetch_size)[11:0];
            BundleTransformHint();
        when CommandHandler_SaveExecutionContext =>
            SaveExecutionContextState(
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_RegSrc0)),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_RegSrc1)),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_RegSrc2)));
        when CommandHandler_RecoverExecutionContext =>
            RecoverExecutionContextState(
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_RegSrc0)),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_RegSrc1)),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_RegSrc2)));
        when CommandHandler_ExecuteFrameEntry =>
            ExecuteFENTRY(
                CommandDecodedReg5(instruction, form, CommandField_SrcBegin),
                CommandDecodedReg5(instruction, form, CommandField_SrcEnd),
                CommandDecodedWord(instruction, form, CommandField_uimm));
        when CommandHandler_ExecuteFrameExit =>
            ExecuteFEXIT(
                CommandDecodedReg5(instruction, form, CommandField_DstBegin),
                CommandDecodedReg5(instruction, form, CommandField_DstEnd),
                CommandDecodedWord(instruction, form, CommandField_uimm));
        when CommandHandler_ExecuteFrameReturnAddress =>
            ExecuteFRETRA(
                CommandDecodedReg5(instruction, form, CommandField_DstBegin),
                CommandDecodedReg5(instruction, form, CommandField_DstEnd),
                CommandDecodedWord(instruction, form, CommandField_uimm));
        when CommandHandler_ExecuteFrameReturnStack =>
            ExecuteFRETSTK(
                CommandDecodedReg5(instruction, form, CommandField_DstBegin),
                CommandDecodedReg5(instruction, form, CommandField_DstEnd),
                CommandDecodedWord(instruction, form, CommandField_uimm));
        when CommandHandler_ExecuteQueueMove =>
            let flags = CommandDecodedQueueMoveFlags(instruction, form);
            let capacity_source = if flags[3] == '1' then
                ReadScalarRegisterOperand(CommandDecodedReg5(
                    instruction,
                    form,
                    CommandField_SrcR))
            else
                Zeros{PTO_XLEN};
            ExecuteHLQMT(
                CommandDecodedReg5(instruction, form, CommandField_RegDst),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_SrcL)),
                capacity_source,
                flags);
        when CommandHandler_ExecuteQueuePop =>
            ExecuteHLQPOP(
                CommandDecodedReg5(instruction, form, CommandField_RegDst0),
                CommandDecodedReg5(instruction, form, CommandField_RegDst1),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_SrcL)),
                CommandDecodedQueuePopFlags(instruction, form));
        when CommandHandler_ExecuteQueuePush =>
            ExecuteHLQPUSH(
                CommandDecodedReg5(instruction, form, CommandField_RegDst),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_SrcL)),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_SrcR)),
                CommandDecodedQueuePushFlags(instruction, form));
        when CommandHandler_ExecuteMemoryCopy =>
            if _MemoryCopyTemplate.active then
                ExecuteMemoryCopyTemplate(
                    _MemoryCopyTemplate.destination,
                    _MemoryCopyTemplate.source,
                    _MemoryCopyTemplate.length);
            else
                let destination = ReadGPR(
                    CommandDecodedReg5(
                        instruction,
                        form,
                        CommandField_RegSrc0) as GPRIndex);
                let source = ReadGPR(
                    CommandDecodedReg5(
                        instruction,
                        form,
                        CommandField_RegSrc1) as GPRIndex);
                let length = ReadGPR(
                    CommandDecodedReg5(
                        instruction,
                        form,
                        CommandField_RegSrc2) as GPRIndex);
                ExecuteMemoryCopyTemplate(destination, source, length);
            end;
        when CommandHandler_ExecuteMemorySet =>
            ExecuteBoundedMemorySet(
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_RegSrc0)),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_RegSrc1)),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_RegSrc2)));
        when CommandHandler_ExecuteCrossBlockTransfer =>
            ExecuteCrossBlockTransferState(
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_ACR_ID)[9:0],
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_CROSS_BID)[6:0]);
        otherwise =>
            unreachable;
    end;
    if _LastFault != Fault_None then
        return CommandExecution_Rejected;
    end;
    if CommandHandlerAdvancesSequentially(handler) && !hint_trace then
        WriteTPC(ReadTPC() + (Zeros{PTO_XLEN} + (length_bits DIV 8)));
    end;
    return CommandExecution_Executed;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
