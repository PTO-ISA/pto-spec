// PTO-REQ-BLOCK-DISPATCH-001: decoded block-command execution.

type CommandExecutionStatus of enumeration {
    CommandExecution_Executed,
    CommandExecution_Unsupported,
    CommandExecution_Rejected
};

pure func CommandDecodedWord(instruction: bits(64),
                             form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                             field: CommandOperandField) => Word
begin
    let raw = DecodeCommandOperandRaw(instruction, form, field);
    if CommandOperandSignedness(form, field) == ScalarField_Signed then
        case CommandOperandWidth(form, field) of
            when 8  => return SignExtend{PTO_XLEN}(raw[7:0]);
            when 12 => return SignExtend{PTO_XLEN}(raw[11:0]);
            when 15 => return SignExtend{PTO_XLEN}(raw[14:0]);
            when 17 => return SignExtend{PTO_XLEN}(raw[16:0]);
            when 25 => return SignExtend{PTO_XLEN}(raw[24:0]);
            when 30 => return SignExtend{PTO_XLEN}(raw[29:0]);
            when 42 => return SignExtend{PTO_XLEN}(raw[41:0]);
            otherwise => unreachable;
        end;
    end;
    return ZeroExtend{PTO_XLEN}(raw);
end;

pure func CommandDecodedReg5(instruction: bits(64),
                             form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                             field: CommandOperandField) => Reg5Selector
begin
    return UInt(DecodeCommandOperandRaw(instruction, form, field)[4:0])
        as Reg5Selector;
end;

pure func CommandDecodedTile(instruction: bits(64),
                             form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                             field: CommandOperandField) => TileIndex
begin
    return UInt(DecodeCommandOperandRaw(instruction, form, field)[5:0])
        as TileIndex;
end;

pure func CommandDecodedBool(instruction: bits(64),
                             form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                             field: CommandOperandField) => boolean
begin
    return DecodeCommandOperandRaw(instruction, form, field)[0] == '1';
end;

pure func CommandDecodedSmall(instruction: bits(64),
                              form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                              field: CommandOperandField) => integer {0..15}
begin
    return UInt(DecodeCommandOperandRaw(instruction, form, field)[3:0])
        as integer {0..15};
end;

pure func CommandDecodedQueueMoveFlags(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => bits(4)
begin
    var flags: bits(4) = Zeros{4};
    flags[3] = DecodeCommandOperandRaw(instruction, form, CommandField_i)[0];
    flags[2] = DecodeCommandOperandRaw(instruction, form, CommandField_e)[0];
    flags[1] = DecodeCommandOperandRaw(instruction, form, CommandField_s)[0];
    flags[0] = DecodeCommandOperandRaw(instruction, form, CommandField_r)[0];
    return flags;
end;

pure func CommandDecodedQueuePopFlags(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => bits(4)
begin
    var flags: bits(4) = Zeros{4};
    flags[1] = DecodeCommandOperandRaw(instruction, form, CommandField_e)[0];
    flags[0] = DecodeCommandOperandRaw(instruction, form, CommandField_r)[0];
    return flags;
end;

pure func CommandDecodedQueuePushFlags(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => bits(4)
begin
    var flags: bits(4) = Zeros{4};
    flags[3] = DecodeCommandOperandRaw(instruction, form, CommandField_h)[0];
    flags[2] = DecodeCommandOperandRaw(instruction, form, CommandField_e)[0];
    flags[0] = DecodeCommandOperandRaw(instruction, form, CommandField_r)[0];
    return flags;
end;

pure func CommandDecodedBlockDimension(instruction: bits(64),
                                       form: integer {0..PTO_COMMAND_FORM_COUNT-1})
                                       => BlockDimensionIndex
begin
    if CommandOperandPresent(form, CommandField_LoopNest) then
        return UInt(DecodeCommandOperandRaw(instruction, form,
            CommandField_LoopNest)[1:0]) as BlockDimensionIndex;
    end;
    case CommandOperationOfForm(form) of
        when CommandOperation_b_dim_32_27602ab68929 => return 0;
        when CommandOperation_b_dim_32_4191099a5f4d => return 1;
        otherwise => return 2;
    end;
end;

readonly func CommandDecodedBlockTarget(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => Word
begin
    let offset = CommandSignedOffsetOfForm(instruction, form);
    return ReadTPC() + LSL(offset, 1);
end;

func ExecuteDecodedBlockStart(instruction: bits(64),
                              form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                              length_bits: integer {16,32,48,64})
begin
    let kind = CommandBlockKindOfForm(form);
    let transfer = CommandBlockTransferOfForm(form);
    let fallthrough = ReadTPC() + (Zeros{PTO_XLEN} + (length_bits DIV 8));
    let target = if CommandHasSignedOffset(form) then
        CommandDecodedBlockTarget(instruction, form) else
        if _BlockBodyAddress != Zeros{PTO_XLEN} then _BlockBodyAddress
        else fallthrough;
    let return_target = if CommandOperandPresent(form, CommandField_uimm5) then
        CommandDecodedWord(instruction, form, CommandField_uimm5)
        else fallthrough;
    let condition = if transfer == BlockTransfer_Conditional then
        !IsZero(ReadBranchPredicate()) else TRUE;
    BeginBlock(kind, transfer, target, fallthrough, return_target, condition);
end;

func ExecuteDecodedBlockCommand(instruction: bits(64),
                                form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                                length_bits: integer {16,32,48,64})
                                => CommandExecutionStatus
begin
    case CommandHandlerOfForm(form) of
        when CommandHandler_SetBlockArgument =>
            if CommandOperandPresent(form, CommandField_format) then
                SetBlockArgument(CommandDecodedWord(instruction, form,
                    CommandField_format));
            else
                SetBlockArgument(Zeros{PTO_XLEN});
            end;
        when CommandHandler_SetBlockControlAttributes =>
            SetBlockControlAttributeState(
                CommandDecodedBool(instruction, form, CommandField_trap),
                CommandDecodedBool(instruction, form, CommandField_atom),
                CommandDecodedBool(instruction, form, CommandField_aq),
                CommandDecodedBool(instruction, form, CommandField_rl),
                CommandDecodedBool(instruction, form, CommandField_far),
                CommandDecodedBool(instruction, form, CommandField_DR));
        when CommandHandler_SetBlockDataAttributes =>
            SetBlockDataAttributeState(
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_DataType)[4:0],
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_DataLayout)[4:0],
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_PadValue)[4:0],
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_CMode)[2:0],
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_RMode)[2:0],
                CommandDecodedBool(instruction, form, CommandField_Sat));
        when CommandHandler_SetBlockDimension =>
            if CommandOperandPresent(form, CommandField_RegSrc) then
                SetBlockDimension(CommandDecodedBlockDimension(instruction, form),
                    ReadScalarRegisterOperand(CommandDecodedReg5(instruction,
                        form, CommandField_RegSrc)) +
                    if CommandOperandPresent(form, CommandField_uimm17) then
                        CommandDecodedWord(instruction, form, CommandField_uimm17)
                    else Zeros{PTO_XLEN});
            else
                SetBlockDimension(CommandDecodedBlockDimension(instruction, form),
                    CommandDecodedWord(instruction, form, CommandField_imm8));
            end;
        when CommandHandler_SetBlockBodyAddress =>
            SetBlockBodyAddress(CommandDecodedBlockTarget(instruction, form));
        when CommandHandler_BindBlockScalarIO =>
            SetBlockScalarBinding(0,
                CommandDecodedReg5(instruction, form, CommandField_RegDst),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc0),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc1),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc2), 3);
        when CommandHandler_BindBlockTileIO =>
            SetBlockTileBinding(0,
                CommandOperandPresent(form, CommandField_DstTile),
                if CommandOperandPresent(form, CommandField_DstTile) then
                    CommandDecodedTile(instruction, form, CommandField_DstTile)
                else 0,
                if CommandOperandPresent(form, CommandField_imm4) then
                    CommandDecodedSmall(instruction, form, CommandField_imm4)
                else 0,
                CommandOperandPresent(form, CommandField_SrcTile0),
                CommandOperandPresent(form, CommandField_SrcTile1),
                if CommandOperandPresent(form, CommandField_SrcTile0) then
                    CommandDecodedTile(instruction, form, CommandField_SrcTile0)
                else 0,
                if CommandOperandPresent(form, CommandField_SrcTile1) then
                    CommandDecodedTile(instruction, form, CommandField_SrcTile1)
                else 0,
                CommandOperandPresent(form, CommandField_S0R) &&
                    CommandDecodedBool(instruction, form, CommandField_S0R),
                CommandOperandPresent(form, CommandField_S1R) &&
                    CommandDecodedBool(instruction, form, CommandField_S1R),
                CommandOperandPresent(form, CommandField_L) &&
                    CommandDecodedBool(instruction, form, CommandField_L));
        when CommandHandler_ExecuteBlockStart =>
            ExecuteDecodedBlockStart(instruction, form, length_bits);
        when CommandHandler_ExecuteBlockStop =>
            StopBlock();
        when CommandHandler_SetBlockHint =>
            BlockTransformHint();
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
    return CommandExecution_Executed;
end;

func ExecuteCommandInstruction(instruction: bits(64),
                               length_bits: integer {16,32,48,64})
                               => CommandExecutionStatus
begin
    AdvanceArchitecturalTime();
    let decoded = DecodeCommandForm(instruction, length_bits);
    if decoded == PTO_COMMAND_FORM_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    let form = decoded as integer {0..PTO_COMMAND_FORM_COUNT-1};
    if !CommandFormOperandsLegal(instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    return ExecuteDecodedBlockCommand(instruction, form, length_bits);
end;
