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

func BlockTileInstructionOperands() => TileInstructionOperands
begin
    var operands = DefaultTileInstructionOperands();
    var destination_count: integer = 0;
    var source_count: integer = 0;
    for binding = 0 to PTO_BLOCK_TILE_BINDING_COUNT - 1 do
        if _BlockTileBindings[[binding]].valid then
            if _BlockTileBindings[[binding]].destination_valid then
                if destination_count == 0 then
                    operands.destination0 = _BlockTileBindings[[binding]].destination;
                elsif destination_count == 1 then
                    operands.destination1 = _BlockTileBindings[[binding]].destination;
                else
                    SetFault(Fault_TileLegality, ReadTPC());
                    return operands;
                end;
                destination_count = destination_count + 1;
            end;
            if _BlockTileBindings[[binding]].source0_valid then
                case source_count of
                    when 0 => operands.source0 = _BlockTileBindings[[binding]].source0;
                    when 1 => operands.source1 = _BlockTileBindings[[binding]].source0;
                    when 2 => operands.source2 = _BlockTileBindings[[binding]].source0;
                    when 3 => operands.source3 = _BlockTileBindings[[binding]].source0;
                    when 4 => operands.source4 = _BlockTileBindings[[binding]].source0;
                    otherwise =>
                        SetFault(Fault_TileLegality, ReadTPC());
                        return operands;
                end;
                source_count = source_count + 1;
            end;
            if _BlockTileBindings[[binding]].source1_valid then
                case source_count of
                    when 0 => operands.source0 = _BlockTileBindings[[binding]].source1;
                    when 1 => operands.source1 = _BlockTileBindings[[binding]].source1;
                    when 2 => operands.source2 = _BlockTileBindings[[binding]].source1;
                    when 3 => operands.source3 = _BlockTileBindings[[binding]].source1;
                    when 4 => operands.source4 = _BlockTileBindings[[binding]].source1;
                    otherwise =>
                        SetFault(Fault_TileLegality, ReadTPC());
                        return operands;
                end;
                source_count = source_count + 1;
            end;
        end;
    end;
    if _BlockScalarBindings[[0]].valid then
        operands.address = ReadScalarRegisterOperand(
            _BlockScalarBindings[[0]].source0);
        operands.scalar0 = operands.address;
        operands.scalar1 = ReadScalarRegisterOperand(
            _BlockScalarBindings[[0]].source1);
    end;
    let dimension0 = UInt(_BlockDimensions[[0]]);
    let dimension1 = UInt(_BlockDimensions[[1]]);
    if dimension0 <= 65535 then
        operands.natural0 = dimension0 as integer {0..65535};
        if dimension0 != 0 then
            operands.positive0 = dimension0 as integer {1..65535};
        end;
    end;
    if dimension1 <= 65535 then
        operands.natural1 = dimension1 as integer {0..65535};
        if dimension1 != 0 then
            operands.positive1 = dimension1 as integer {1..65535};
        end;
    end;
    if dimension0 <= 262144 then
        operands.byte_count = dimension0 as integer {0..262144};
    end;
    operands.selected_byte = UInt(_BlockDataAttributes.pad_value)
        as integer {0..3};
    case UInt(_BlockDataAttributes.conversion_mode) of
        when 0 => operands.comparison = TileComparison_EQ;
        when 1 => operands.comparison = TileComparison_NE;
        when 2 => operands.comparison = TileComparison_LT;
        when 3 => operands.comparison = TileComparison_GT;
        when 4 => operands.comparison = TileComparison_LE;
        when 5 => operands.comparison = TileComparison_GE;
        otherwise => operands.comparison = TileComparison_EQ;
    end;
    operands.flag0 = _BlockDataAttributes.saturating;
    return operands;
end;

func ResolveBlockTileDestinations() => boolean
begin
    var reserved: array [[PTO_TILE_REGISTER_COUNT]] of boolean;
    var resolved: array [[PTO_BLOCK_TILE_BINDING_COUNT]] of TileIndex;
    var required_capacity: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        reserved[[index]] = FALSE;
    end;
    for binding = 0 to PTO_BLOCK_TILE_BINDING_COUNT - 1 do
        resolved[[binding]] = 0;
        if _BlockTileBindings[[binding]].valid &&
           _BlockTileBindings[[binding]].destination_valid &&
           !_BlockTileBindings[[binding]].destination_allocated_by_block then
            required_capacity = required_capacity +
                BlockTileDestinationSizeBytes(
                    binding as BlockTileBindingIndex);
            let hand = UInt(_BlockTileBindings[[binding]].destination_hand);
            var found = FALSE;
            for offset = 0 to 15 do
                let raw_index: integer = hand * 16 + offset;
                if !found && !_Tiles[[raw_index]].allocated &&
                   !reserved[[raw_index]] then
                    resolved[[binding]] = raw_index as TileIndex;
                    reserved[[raw_index]] = TRUE;
                    found = TRUE;
                end;
            end;
            if !found then
                SetFault(Fault_TileAllocation, ReadTPC());
                return FALSE;
            end;
        end;
    end;
    if TileCapacityInUse() + required_capacity > TileCapacityLimitBytes() then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;

    let selected_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBlockTileOperationDataTypeCode()));
    var destination_ordinal: integer = 0;
    var shape_source_valid = FALSE;
    var shape_source: TileIndex = 0;
    for binding = 0 to PTO_BLOCK_TILE_BINDING_COUNT - 1 do
        if !shape_source_valid && _BlockTileBindings[[binding]].valid then
            if _BlockTileBindings[[binding]].source0_valid then
                shape_source = _BlockTileBindings[[binding]].source0;
                shape_source_valid = TRUE;
            elsif _BlockTileBindings[[binding]].source1_valid then
                shape_source = _BlockTileBindings[[binding]].source1;
                shape_source_valid = TRUE;
            end;
        end;
    end;
    for binding = 0 to PTO_BLOCK_TILE_BINDING_COUNT - 1 do
        if _BlockTileBindings[[binding]].valid &&
           _BlockTileBindings[[binding]].destination_valid &&
           !_BlockTileBindings[[binding]].destination_allocated_by_block then
            var rows: integer {0..65535} = 1;
            var columns: integer {0..65535} = 1;
            if UInt(_BlockDimensions[[0]]) >= 1 &&
               UInt(_BlockDimensions[[0]]) <= 65535 then
                rows = UInt(_BlockDimensions[[0]]) as integer {1..65535};
            elsif shape_source_valid &&
                  TileDescriptorConfigured(shape_source) then
                rows = _Tiles[[shape_source]].valid_rows;
            elsif _Accumulator.live then
                rows = _Accumulator.info.valid_rows;
            end;
            if UInt(_BlockDimensions[[1]]) >= 1 &&
               UInt(_BlockDimensions[[1]]) <= 65535 then
                columns = UInt(_BlockDimensions[[1]]) as integer {1..65535};
            elsif shape_source_valid &&
                  TileDescriptorConfigured(shape_source) then
                columns = _Tiles[[shape_source]].valid_columns;
            elsif _Accumulator.live then
                columns = _Accumulator.info.valid_columns;
            end;
            let destination_type = if destination_ordinal == 0 then
                selected_type else TileDataType_U32;
            ConfigureTile(resolved[[binding]],
                BlockTileDestinationSizeBytes(
                    binding as BlockTileBindingIndex),
                rows, columns, rows, columns, destination_type,
                TileLayout_RowMajor, TileLocation_Any);
            _BlockTileBindings[[binding]].destination = resolved[[binding]];
            _BlockTileBindings[[binding]].destination_allocated_by_block = TRUE;
            destination_ordinal = destination_ordinal + 1;
        end;
    end;
    return TRUE;
end;

func RollBackBlockTileDestinations()
begin
    for binding = 0 to PTO_BLOCK_TILE_BINDING_COUNT - 1 do
        if _BlockTileBindings[[binding]].valid &&
           _BlockTileBindings[[binding]].destination_allocated_by_block then
            ReleaseTile(_BlockTileBindings[[binding]].destination);
            _BlockTileBindings[[binding]].destination =
                UInt(_BlockTileBindings[[binding]].destination_hand)
                    as TileIndex;
            _BlockTileBindings[[binding]].destination_allocated_by_block = FALSE;
        end;
    end;
end;

// B.DATR fields are instruction attributes, not free-standing mode bits.  A
// non-zero field is legal only when the selected tile operation consumes it.
// Perform this check before resolving a hand destination so a rejected BSTART
// cannot allocate a tile or otherwise begin the selected operation.
func SelectedBlockTileDataAttributesLegal() => boolean
begin
    var operation: TileOperationIndex = PTO_TILE_OPERATION_COUNT;
    case _BlockTileOperation.family of
        when '00' =>
            operation = DecodeTileOperation(
                TileDecode_TEPL, _BlockTileOperation.code);
        when '01' =>
            operation = DecodeTileOperation(
                TileDecode_TMA, _BlockTileOperation.code);
        when '10' =>
            operation = DecodeTileOperation(
                TileDecode_CUBE, _BlockTileOperation.code);
        otherwise =>
            SetFault(Fault_IllegalInstruction, ReadTPC());
            return FALSE;
    end;
    // Preserve the generated dispatcher behavior for an unknown selector: it
    // remains rejected by ExecuteTileInstruction rather than being treated as
    // a DATR applicability violation.
    if operation == PTO_TILE_OPERATION_COUNT then return TRUE; end;
    let accepted_operation = operation as
        integer {0..PTO_TILE_OPERATION_COUNT-1};
    if !TileOperationDATRFieldsLegal(
        accepted_operation,
        _BlockDataAttributes.conversion_mode,
        _BlockDataAttributes.pad_value,
        _BlockDataAttributes.saturating,
        _BlockDataAttributes.canonicalize,
        _BlockDataAttributes.data_type,
        _BlockDataAttributes.rounding_mode,
        _BlockDataAttributes.data_layout) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    // The shared PadValueOrByteId encoding has three operation-specific
    // interpretations.  The generated union makes the must-zero case explicit
    // at the handwritten execution boundary.
    if _BlockDataAttributes.pad_value != Zeros{2} &&
       TileOperationDATRPadUnion(accepted_operation) ==
           TileDATRPadUnion_MustZero then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    return TRUE;
end;

func ExecuteSelectedBlockTileOperation() => TileExecutionStatus
begin
    if !BlockTileOperationSelected() then return TileExecution_Rejected; end;
    if !SelectedBlockTileDataAttributesLegal() then
        return TileExecution_Faulted;
    end;
    if !ResolveBlockTileDestinations() then return TileExecution_Faulted; end;
    let operands = BlockTileInstructionOperands();
    if _LastFault != Fault_None then
        RollBackBlockTileDestinations();
        return TileExecution_Faulted;
    end;
    var status = TileExecution_Rejected;
    case _BlockTileOperation.family of
        when '00' =>
            let (result, -) = ExecuteTileInstruction(
                TileDecode_TEPL, _BlockTileOperation.code, operands);
            status = result;
        when '01' =>
            let (result, -) = ExecuteTileInstruction(
                TileDecode_TMA, _BlockTileOperation.code, operands);
            status = result;
        when '10' =>
            let (result, -) = ExecuteTileInstruction(
                TileDecode_CUBE, _BlockTileOperation.code, operands);
            status = result;
        otherwise =>
            SetFault(Fault_IllegalInstruction, ReadTPC());
    end;
    if _LastFault != Fault_None || status != TileExecution_Executed then
        RollBackBlockTileDestinations();
        if _LastFault != Fault_None || status == TileExecution_Faulted then
            return TileExecution_Faulted;
        end;
        return status;
    end;
    return status;
end;

func ExecuteDecodedBlockStart(instruction: bits(64),
                              form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                              length_bits: integer {16,32,48,64})
begin
    if CommandFormSelectsTileOperation(form) then
        case CommandTileFamilyOfForm(form) of
            when TileDecode_TEPL =>
                SetBlockTileOperationSelection('00',
                    CommandTileCodeOfForm(instruction, form),
                    CommandTileDataTypeOfForm(instruction, form));
            when TileDecode_TMA =>
                SetBlockTileOperationSelection('01',
                    CommandTileCodeOfForm(instruction, form),
                    CommandTileDataTypeOfForm(instruction, form));
            when TileDecode_CUBE =>
                SetBlockTileOperationSelection('10',
                    CommandTileCodeOfForm(instruction, form),
                    CommandTileDataTypeOfForm(instruction, form));
        end;
    else
        ClearBlockTileOperationSelection();
    end;
    let kind = CommandBlockKindOfForm(form);
    let transfer = CommandBlockTransferOfForm(form);
    let fallthrough = ReadTPC() + (Zeros{PTO_XLEN} + (length_bits DIV 8));
    let target = if transfer == BlockTransfer_Return then _ReturnAddress
        else if transfer == BlockTransfer_Indirect ||
                transfer == BlockTransfer_IndirectCall then _CommitArgument
        else if transfer == BlockTransfer_Fallthrough then fallthrough
        else if CommandHasSignedOffset(form) then
            CommandDecodedBlockTarget(instruction, form)
        else if _BlockBodyAddress != Zeros{PTO_XLEN} then _BlockBodyAddress
        else fallthrough;
    let return_target = if CommandOperandPresent(form, CommandField_uimm5) then
        ReadTPC() + (Zeros{PTO_XLEN} + ((length_bits DIV 8) - 2)) +
        LSL(CommandDecodedWord(instruction, form, CommandField_uimm5), 1)
        else fallthrough;
    let condition = if transfer == BlockTransfer_Conditional then
        !IsZero(ReadBranchPredicate()) else TRUE;
    BeginBlock(kind, transfer, target, fallthrough, return_target, condition);
    if _LastFault == Fault_None && BlockIsActive() &&
       BlockTileOperationSelected() && BlockTileDescriptorReady() then
        let status = ExecuteSelectedBlockTileOperation();
        FinalizeBlockTileAttempt(status);
    end;
end;

func ExecuteDecodedBlockCommand(instruction: bits(64),
                                form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                                length_bits: integer {16,32,48,64})
                                => CommandExecutionStatus
begin
    case CommandHandlerOfForm(form) of
        when CommandHandler_SetBlockControlAttributes =>
            SetBlockControlAttributeState(
                CommandDecodedBool(instruction, form, CommandField_trap),
                CommandDecodedBool(instruction, form, CommandField_atom),
                CommandDecodedBool(instruction, form, CommandField_aq),
                CommandDecodedBool(instruction, form, CommandField_rl),
                CommandDecodedBool(instruction, form, CommandField_far),
                CommandDecodedBool(instruction, form, CommandField_DR));
        when CommandHandler_SetBlockDataAttributes =>
            SetBlockDataAttributeState0571(
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
                CommandDecodedBool(instruction, form,
                    CommandField_Canonicalize));
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
            AddBlockTileBinding(
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
