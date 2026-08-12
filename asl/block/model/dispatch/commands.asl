// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-COMMANDS","surface":"block","classification":["model","dispatch","commands"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-START"]}
func ExecuteDecodedBundleCommand(instruction: bits(64),
                                form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                                length_bits: integer {16,32,48,64})
                                => CommandExecutionStatus
begin
    let handler = CommandHandlerOfForm(form);
    if !CommandHandlerSupportedPTOv0(handler) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    case handler of
        when CommandHandler_SetBundleControlAttributes =>
            SetBundleControlAttributeState(
                CommandDecodedBool(instruction, form, CommandField_trap),
                CommandDecodedBool(instruction, form, CommandField_atom),
                CommandDecodedBool(instruction, form, CommandField_aq),
                CommandDecodedBool(instruction, form, CommandField_rl),
                CommandDecodedBool(instruction, form, CommandField_far),
                CommandDecodedBool(instruction, form, CommandField_DR));
        when CommandHandler_SetBundleDataAttributes =>
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
        when CommandHandler_SetBundleFixedPointAttributes =>
            if _BundleFixedPointAttributes.valid ||
               (_BundleOperation.valid &&
                _BundleOperation.operation_class != BundleOperation_TileMatrix) then
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
            if CommandOperandPresent(form, CommandField_RegSrc) then
                SetBundleDimension(CommandDecodedBundleDimension(instruction, form),
                    ReadScalarRegisterOperand(CommandDecodedReg5(instruction,
                        form, CommandField_RegSrc)) +
                    if CommandOperandPresent(form, CommandField_uimm17) then
                        CommandDecodedWord(instruction, form, CommandField_uimm17)
                    else Zeros{PTO_XLEN});
            else
                SetBundleDimension(CommandDecodedBundleDimension(instruction, form),
                    CommandDecodedWord(instruction, form, CommandField_imm8));
            end;
        when CommandHandler_BindBundleSharedIO =>
            BindBundleSharedIO(
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_SharedTID)[7:0],
                CommandDecodedSmall(instruction, form, CommandField_TSize)
                    as integer {0..7},
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_PE_MASK)[3:0]);
        when CommandHandler_SetBundleBodyAddress =>
            SetBundleBodyAddress(CommandDecodedBundleTarget(instruction, form));
        when CommandHandler_BindBundleScalarIO =>
            if _BundleScalarBindings[[0]].valid then
                SetFault(Fault_BundleControl, ReadTPC());
                return CommandExecution_Rejected;
            end;
            SetBundleScalarBinding(0,
                CommandDecodedReg5(instruction, form, CommandField_RegDst),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc0),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc1),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc2), 3);
        when CommandHandler_BindBundleTileIO =>
            let tile_size = if CommandOperandPresent(form, CommandField_TSize) then
                CommandDecodedSmall(instruction, form, CommandField_TSize)
                else 0;
            let pe_mask = DecodeCommandOperandRaw(
                instruction, form, CommandField_PE_MASK)[3:0];
            let local_to_shared =
                _BundleOperation.valid &&
                _BundleOperation.operation_class == BundleOperation_TileMemory &&
                _BundleOperation.selector_valid &&
                (_BundleOperation.selector[4:0] == '01001' ||
                 _BundleOperation.selector[4:0] == '01010');
            let local_destination =
                CommandOperandPresent(form, CommandField_TSize);
            if pe_mask != Zeros{4} &&
               (!BundleTileMaskCanAppend(pe_mask) ||
                (local_destination && tile_size == 0) ||
                (local_to_shared &&
                 (CommandOperandPresent(form, CommandField_TSize) ||
                  CommandOperandPresent(form, CommandField_DstTile))) ||
                (_BundleOperation.valid &&
                 _BundleOperation.operation_class == BundleOperation_TileMemory &&
                 _BundleOperation.selector_valid &&
                 _BundleOperation.selector[4:0] == '01101' &&
                 pe_mask != '1111')) then
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
        when CommandHandler_ExecuteBundleStart =>
            ExecuteDecodedBundleStart(instruction, form, length_bits);
        when CommandHandler_ExecuteBundleStop =>
            let completed = CompleteBundleAt(ReadTPC() +
                (Zeros{PTO_XLEN} + (length_bits DIV 8)));
        when CommandHandler_SetBundleHint =>
            _LastBundleHintPayload = instruction;
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
            EnterFrame(
                CommandDecodedReg5(instruction, form, CommandField_SrcBegin),
                CommandDecodedReg5(instruction, form, CommandField_SrcEnd),
                CommandDecodedWord(instruction, form, CommandField_uimm));
        when CommandHandler_ExecuteFrameExit =>
            ExitFrame(
                CommandDecodedReg5(instruction, form, CommandField_DstBegin),
                CommandDecodedReg5(instruction, form, CommandField_DstEnd),
                CommandDecodedWord(instruction, form, CommandField_uimm));
        when CommandHandler_ExecuteFrameReturnAddress =>
            ReturnFromFrame(
                CommandDecodedReg5(instruction, form, CommandField_DstBegin),
                CommandDecodedReg5(instruction, form, CommandField_DstEnd),
                CommandDecodedWord(instruction, form, CommandField_uimm), TRUE);
        when CommandHandler_ExecuteFrameReturnStack =>
            ReturnFromFrame(
                CommandDecodedReg5(instruction, form, CommandField_DstBegin),
                CommandDecodedReg5(instruction, form, CommandField_DstEnd),
                CommandDecodedWord(instruction, form, CommandField_uimm), FALSE);
        when CommandHandler_ExecuteQueueMove =>
            ExecuteQueueManagerMove(
                CommandDecodedReg5(instruction, form, CommandField_RegDst),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_SrcL)),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_SrcR)),
                CommandDecodedQueueMoveFlags(instruction, form));
        when CommandHandler_ExecuteQueuePop =>
            ExecuteQueueManagerPop(
                CommandDecodedReg5(instruction, form, CommandField_RegDst0),
                CommandDecodedReg5(instruction, form, CommandField_RegDst1),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_SrcL)),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_SrcR)),
                CommandDecodedQueuePopFlags(instruction, form));
        when CommandHandler_ExecuteQueuePush =>
            ExecuteQueueManagerPush(
                CommandDecodedReg5(instruction, form, CommandField_RegDst),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_SrcL)),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_SrcR)),
                CommandDecodedQueuePushFlags(instruction, form));
        when CommandHandler_ExecuteMemoryCopy =>
            ExecuteBoundedMemoryCopy(
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_RegSrc0)),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_RegSrc1)),
                ReadScalarRegisterOperand(CommandDecodedReg5(instruction, form,
                    CommandField_RegSrc2)));
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
    if CommandHandlerAdvancesSequentially(handler) then
        WriteTPC(ReadTPC() + (Zeros{PTO_XLEN} + (length_bits DIV 8)));
    end;
    return CommandExecution_Executed;
end;
