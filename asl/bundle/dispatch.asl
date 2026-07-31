// PTO-REQ-BUNDLE-DISPATCH-001: decoded bundle-command execution.

type CommandExecutionStatus of enumeration {
    CommandExecution_Executed,
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

pure func CommandHandlerSupportedPTOv0(handler: CommandSemanticHandler)
                                       => boolean
begin
    case handler of
        when CommandHandler_SaveExecutionContext,
             CommandHandler_RecoverExecutionContext,
             CommandHandler_ExecuteFrameEntry,
             CommandHandler_ExecuteFrameExit,
             CommandHandler_ExecuteFrameReturnAddress,
             CommandHandler_ExecuteFrameReturnStack,
             CommandHandler_ExecuteQueueMove,
             CommandHandler_ExecuteQueuePop,
             CommandHandler_ExecuteQueuePush,
             CommandHandler_ExecuteCrossBlockTransfer => return FALSE;
        otherwise => return TRUE;
    end;
end;

pure func CommandHandlerAdvancesSequentially(handler: CommandSemanticHandler)
                                             => boolean
begin
    return handler != CommandHandler_ExecuteBundleStart &&
           handler != CommandHandler_ExecuteBundleStop;
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

pure func CommandDecodedBundleDimension(instruction: bits(64),
                                       form: integer {0..PTO_COMMAND_FORM_COUNT-1})
                                       => BundleDimensionIndex
begin
    if CommandOperandPresent(form, CommandField_LoopNest) then
        return UInt(DecodeCommandOperandRaw(instruction, form,
            CommandField_LoopNest)[1:0]) as BundleDimensionIndex;
    end;
    case CommandOperationOfForm(form) of
        when CommandOperation_b_dim_32_27602ab68929 => return 0;
        when CommandOperation_b_dim_32_4191099a5f4d => return 1;
        otherwise => return 2;
    end;
end;

pure func DecodeBundleOperationDescriptor(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => BundleOperationDescriptor
begin
    var selector = Zeros{10};
    var selector_valid = FALSE;
    if CommandFormSelectsTileOperation(form) then
        selector = CommandTileCodeOfForm(instruction, form)[9:0];
        selector_valid = TRUE;
    elsif CommandOperandPresent(form, CommandField_Function) then
        selector[4:0] = DecodeCommandOperandRaw(instruction, form,
            CommandField_Function)[4:0];
        selector_valid = TRUE;
    elsif CommandBundleSelectorConstantPresent(form) then
        selector = CommandBundleSelectorConstantOfForm(form);
        selector_valid = TRUE;
    end;
    return BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7} + form,
        operation_class = CommandBundleOperationClassOfForm(form),
        selector_valid = selector_valid,
        selector = selector,
        data_type_valid = CommandFormSelectsTileOperation(form) ||
            CommandOperandPresent(form, CommandField_DataType),
        data_type = if CommandFormSelectsTileOperation(form) then
            CommandTileDataTypeOfForm(instruction, form)
            else if CommandOperandPresent(form, CommandField_DataType) then
            DecodeCommandOperandRaw(instruction, form, CommandField_DataType)[4:0]
            else Zeros{5},
        mode_valid = CommandOperandPresent(form, CommandField_Mode),
        mode = if CommandOperandPresent(form, CommandField_Mode) then
            DecodeCommandOperandRaw(instruction, form, CommandField_Mode)[1:0]
            else Zeros{2},
        branch_type_valid = CommandOperandPresent(form, CommandField_BrType),
        branch_type = if CommandOperandPresent(form, CommandField_BrType) then
            DecodeCommandOperandRaw(instruction, form, CommandField_BrType)[2:0]
            else Zeros{3}
    };
end;

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
    let code = UInt(data_type);
    return code <= 14 || (16 <= code && code <= 20) ||
           (24 <= code && code <= 28);
end;

pure func BundleTileDataType(data_type: bits(5)) => TileDataType
begin
    case data_type of
        when '00000' => return TileDataType_FP64;
        when '00001' => return TileDataType_FP32;
        when '00010' => return TileDataType_TF32;
        when '00011' => return TileDataType_HF32;
        when '00100' => return TileDataType_FP16;
        when '00101' => return TileDataType_BF16;
        when '00110' => return TileDataType_HiF8;
        when '00111' => return TileDataType_E4M3;
        when '01000' => return TileDataType_E5M2;
        when '01001' => return TileDataType_E3M2;
        when '01010' => return TileDataType_E2M3;
        when '01011' => return TileDataType_E2M1X2;
        when '01100' => return TileDataType_E1M2X2;
        when '01101' => return TileDataType_E8M0;
        when '01110' => return TileDataType_HiF4X2;
        when '10000' => return TileDataType_S64;
        when '10001' => return TileDataType_S32;
        when '10010' => return TileDataType_S16;
        when '10011' => return TileDataType_S8;
        when '10100' => return TileDataType_S4X2;
        when '11000' => return TileDataType_U64;
        when '11001' => return TileDataType_U32;
        when '11010' => return TileDataType_U16;
        when '11011' => return TileDataType_U8;
        when '11100' => return TileDataType_U4X2;
        otherwise => unreachable;
    end;
end;

pure func BundleTileDecodeFamily(operation_class: BundleOperationClass)
        => TileDecodeFamily
begin
    case operation_class of
        when BundleOperation_TileElement => return TileDecode_TEPL;
        when BundleOperation_TileMemory => return TileDecode_TMA;
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
               !BundleDataTypeSupported(descriptor.data_type) then
                return FALSE;
            end;
            let operation = DecodeTileOperation(
                BundleTileDecodeFamily(descriptor.operation_class),
                BundleSelectorCode(descriptor));
            return operation != PTO_TILE_OPERATION_COUNT;
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
                BundleSelectorCode(descriptor));
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
    var destination_count: integer = 0;
    var source_count: integer = 0;
    var binding_count: integer = 0;
    var last_seen = FALSE;
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
            if _BundleTileBindings[[binding]].last then last_seen = TRUE; end;
        end;
    end;
    let expected_destinations =
        (if TileOperandPresent(operation, TileOperand_destination0)
         then 1 else 0) +
        (if TileOperandPresent(operation, TileOperand_destination1)
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
         then 1 else 0);
    if destination_count != expected_destinations ||
       source_count != expected_sources then return FALSE; end;
    if binding_count > 0 && !last_seen then return FALSE; end;
    if (TileOperandPresent(operation, TileOperand_address) ||
        TileOperandPresent(operation, TileOperand_scalar0) ||
        TileOperandPresent(operation, TileOperand_scalar1)) &&
       !_BundleScalarBindings[[0]].valid then return FALSE; end;
    return TRUE;
end;

func BundleTileInstructionOperands() => TileInstructionOperands
begin
    var operands = DefaultTileInstructionOperands();
    var destination_count: integer = 0;
    var source_count: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].destination_valid then
                if destination_count == 0 then
                    operands.destination0 =
                        _BundleTileBindings[[binding]].destination;
                else
                    operands.destination1 =
                        _BundleTileBindings[[binding]].destination;
                end;
                destination_count = destination_count + 1;
            end;
            if _BundleTileBindings[[binding]].source0_valid then
                case source_count of
                    when 0 => operands.source0 =
                        _BundleTileBindings[[binding]].source0;
                    when 1 => operands.source1 =
                        _BundleTileBindings[[binding]].source0;
                    when 2 => operands.source2 =
                        _BundleTileBindings[[binding]].source0;
                    when 3 => operands.source3 =
                        _BundleTileBindings[[binding]].source0;
                    when 4 => operands.source4 =
                        _BundleTileBindings[[binding]].source0;
                    otherwise => unreachable;
                end;
                source_count = source_count + 1;
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                case source_count of
                    when 0 => operands.source0 =
                        _BundleTileBindings[[binding]].source1;
                    when 1 => operands.source1 =
                        _BundleTileBindings[[binding]].source1;
                    when 2 => operands.source2 =
                        _BundleTileBindings[[binding]].source1;
                    when 3 => operands.source3 =
                        _BundleTileBindings[[binding]].source1;
                    when 4 => operands.source4 =
                        _BundleTileBindings[[binding]].source1;
                    otherwise => unreachable;
                end;
                source_count = source_count + 1;
            end;
        end;
    end;
    if _BundleScalarBindings[[0]].valid then
        operands.address = ReadScalarRegisterOperand(
            _BundleScalarBindings[[0]].source0);
        operands.scalar0 = operands.address;
        operands.scalar1 = ReadScalarRegisterOperand(
            _BundleScalarBindings[[0]].source1);
    end;
    let dimension0 = UInt(_BundleDimensions[[0]]);
    let dimension1 = UInt(_BundleDimensions[[1]]);
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
    operands.selected_byte = UInt(_BundleDataAttributes.pad_value)
        as integer {0..3};
    case UInt(_BundleDataAttributes.conversion_mode) of
        when 0 => operands.comparison = TileComparison_EQ;
        when 1 => operands.comparison = TileComparison_NE;
        when 2 => operands.comparison = TileComparison_LT;
        when 3 => operands.comparison = TileComparison_GT;
        when 4 => operands.comparison = TileComparison_LE;
        when 5 => operands.comparison = TileComparison_GE;
        otherwise => operands.comparison = TileComparison_EQ;
    end;
    operands.flag0 = _BundleDataAttributes.saturating;
    return operands;
end;

readonly func BundleDestinationRows(shape_source_valid: boolean,
                                    shape_source: TileIndex)
                                    => integer {0..65535}
begin
    if UInt(_BundleDimensions[[0]]) >= 1 &&
       UInt(_BundleDimensions[[0]]) <= 65535 then
        return UInt(_BundleDimensions[[0]]) as integer {1..65535};
    elsif shape_source_valid && TileDescriptorConfigured(shape_source) then
        return _Tiles[[shape_source]].valid_rows;
    elsif _Accumulator.live then
        return _Accumulator.info.valid_rows;
    else
        return 1;
    end;
end;

readonly func BundleDestinationColumns(shape_source_valid: boolean,
                                       shape_source: TileIndex)
                                       => integer {0..65535}
begin
    if UInt(_BundleDimensions[[1]]) >= 1 &&
       UInt(_BundleDimensions[[1]]) <= 65535 then
        return UInt(_BundleDimensions[[1]]) as integer {1..65535};
    elsif shape_source_valid && TileDescriptorConfigured(shape_source) then
        return _Tiles[[shape_source]].valid_columns;
    elsif _Accumulator.live then
        return _Accumulator.info.valid_columns;
    else
        return 1;
    end;
end;

func ResolveBundleTileDestinations() => boolean
begin
    var reserved: array [[PTO_TILE_REGISTER_COUNT]] of boolean;
    var resolved: array [[PTO_BUNDLE_TILE_BINDING_COUNT]] of TileIndex;
    var required_capacity: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        reserved[[index]] = FALSE;
    end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        resolved[[binding]] = 0;
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            required_capacity = required_capacity +
                BundleTileDestinationSizeBytes(
                    binding as BundleTileBindingIndex);
            let hand =
                UInt(_BundleTileBindings[[binding]].destination_hand);
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
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    var shape_source_valid = FALSE;
    var shape_source: TileIndex = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if !shape_source_valid && _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                shape_source = _BundleTileBindings[[binding]].source0;
                shape_source_valid = TRUE;
            elsif _BundleTileBindings[[binding]].source1_valid then
                shape_source = _BundleTileBindings[[binding]].source1;
                shape_source_valid = TRUE;
            end;
        end;
    end;

    // Validate every derived descriptor before allocating any destination.
    // This preserves precise all-or-nothing B.IOT allocation when a size code
    // is too small for its logical shape.
    var destination_ordinal: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            let rows = BundleDestinationRows(
                shape_source_valid, shape_source);
            let columns = BundleDestinationColumns(
                shape_source_valid, shape_source);
            let destination_type = if destination_ordinal == 0 then
                selected_type else TileDataType_U32;
            if rows == 0 || columns == 0 ||
               rows * columns > PTO_MODEL_TILE_ELEMENTS ||
               !TileStorageFitsCapacity(rows, columns, destination_type,
                   BundleTileDestinationSizeBytes(
                       binding as BundleTileBindingIndex)) then
                SetFault(Fault_TileAllocation, ReadTPC());
                return FALSE;
            end;
            destination_ordinal = destination_ordinal + 1;
        end;
    end;

    destination_ordinal = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            let rows = BundleDestinationRows(
                shape_source_valid, shape_source);
            let columns = BundleDestinationColumns(
                shape_source_valid, shape_source);
            let destination_type = if destination_ordinal == 0 then
                selected_type else TileDataType_U32;
            ConfigureTile(resolved[[binding]],
                BundleTileDestinationSizeBytes(
                    binding as BundleTileBindingIndex),
                rows, columns, rows, columns, destination_type,
                CurrentBundleTileLayout(), TileLocation_Any);
            _BundleTileBindings[[binding]].destination = resolved[[binding]];
            _BundleTileBindings[[binding]].destination_allocated_by_bundle =
                TRUE;
            destination_ordinal = destination_ordinal + 1;
        end;
    end;
    return TRUE;
end;

func RollBackBundleTileDestinations()
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_allocated_by_bundle then
            ReleaseTile(_BundleTileBindings[[binding]].destination);
            _BundleTileBindings[[binding]].destination =
                UInt(_BundleTileBindings[[binding]].destination_hand)
                    as TileIndex;
            _BundleTileBindings[[binding]].destination_allocated_by_bundle =
                FALSE;
        end;
    end;
end;

func SelectedBundleTileDataAttributesLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationDATRFieldsLegal(
        operation, _BundleDataAttributes.conversion_mode,
        _BundleDataAttributes.pad_value, _BundleDataAttributes.saturating,
        _BundleDataAttributes.canonicalize, _BundleDataAttributes.data_type,
        _BundleDataAttributes.rounding_mode,
        _BundleDataAttributes.data_layout) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if _BundleDataAttributes.pad_value != Zeros{2} &&
       TileOperationDATRPadUnion(operation) ==
           TileDATRPadUnion_MustZero then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    return TRUE;
end;

readonly func BundleTileTypesMatch(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    operands: TileInstructionOperands,
    expected: TileDataType) => boolean
begin
    if TileOperandPresent(operation, TileOperand_destination0) &&
       _Tiles[[operands.destination0]].allocated &&
       _Tiles[[operands.destination0]].data_type != expected then return FALSE; end;
    if TileOperandPresent(operation, TileOperand_source0) &&
       _Tiles[[operands.source0]].allocated &&
       _Tiles[[operands.source0]].data_type != expected then return FALSE; end;
    if TileOperandPresent(operation, TileOperand_source1) &&
       _Tiles[[operands.source1]].allocated &&
       _Tiles[[operands.source1]].data_type != expected then return FALSE; end;
    return TRUE;
end;

func ExecuteBundleTileOperationWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet) => boolean
begin
    let family = BundleTileDecodeFamily(_BundleOperation.operation_class);
    let code = BundleSelectorCode(_BundleOperation);
    let decoded = DecodeTileOperation(family, code);
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if !BundleOperationBindingsComplete(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then
        return FALSE;
    end;
    if !ResolveBundleTileDestinations() then return FALSE; end;
    let operands = BundleTileInstructionOperands();
    let (status, -) =
        ExecuteTileInstructionWithoutTimeWithAcceptedApplicabilityRules(
            rules, family, code, operands);
    if _LastFault != Fault_None || status != TileExecution_Executed then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    FinalizeBundleTileAttempt(status);
    return TRUE;
end;

func ExecuteBundleTileOperation() => boolean
begin
    return ExecuteBundleTileOperationWithAcceptedApplicabilityRules(
        NumericApplicabilityRules_None);
end;

func CompleteBundleAtWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet, continuation: Word) => boolean
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if _BundleOperation.valid then
        if _BundleOperation.operation_class == BundleOperation_TileElement ||
           _BundleOperation.operation_class == BundleOperation_TileMemory ||
           _BundleOperation.operation_class == BundleOperation_TileMatrix then
            if !ExecuteBundleTileOperationWithAcceptedApplicabilityRules(
                rules) then
                return FALSE;
            end;
        elsif _BundleOperation.operation_class == BundleOperation_FixedPoint then
            SetFault(Fault_IllegalInstruction, ReadTPC());
            return FALSE;
        end;
    end;
    StopBundleAt(continuation);
    return _LastFault == Fault_None;
end;

func CompleteBundleAt(continuation: Word) => boolean
begin
    return CompleteBundleAtWithAcceptedApplicabilityRules(
        NumericApplicabilityRules_None, continuation);
end;

readonly func CommandDecodedBundleTarget(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => Word
begin
    let offset = CommandSignedOffsetOfForm(instruction, form);
    return ReadTPC() + LSL(offset, 1);
end;

func ExecuteDecodedBundleStartWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet,
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1},
    length_bits: integer {16,32,48,64})
begin
    let kind = CommandBundleKindOfForm(form);
    let descriptor = DecodeBundleOperationDescriptor(instruction, form);
    if !BundleOperationDescriptorLegal(descriptor) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    if BundleOperationDescriptorRejectedByAcceptedApplicabilityRules(
        rules, descriptor) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    let transfer = if descriptor.branch_type_valid then
        BundleTransferOfBranchType(descriptor.branch_type)
        else CommandBundleTransferOfForm(form);
    let fallthrough = ReadTPC() + (Zeros{PTO_XLEN} + (length_bits DIV 8));
    let target = if transfer == BundleTransfer_Return then _ReturnAddress
        else if transfer == BundleTransfer_Indirect ||
                transfer == BundleTransfer_IndirectCall then _CommitArgument
        else if transfer == BundleTransfer_Fallthrough then fallthrough
        else if CommandHasSignedOffset(form) then
            CommandDecodedBundleTarget(instruction, form)
        else if _BundleBodyAddress != Zeros{PTO_XLEN} then _BundleBodyAddress
        else fallthrough;
    let return_target = if CommandOperandPresent(form, CommandField_uimm5) then
        ReadTPC() + (Zeros{PTO_XLEN} + ((length_bits DIV 8) - 2)) +
        LSL(CommandDecodedWord(instruction, form, CommandField_uimm5), 1)
        else fallthrough;
    let condition = if transfer == BundleTransfer_Conditional then
        !IsZero(ReadBranchPredicate()) else TRUE;
    if target[0] == '1' then
        SetFault(Fault_InstructionPC, target);
        return;
    end;
    if _BundleActive && !CompleteBundleAtWithAcceptedApplicabilityRules(
        rules, ReadTPC()) then
        return;
    end;
    ClearBundleHeaderState();
    BeginBundle(kind, transfer, target, fallthrough, return_target, condition);
    if _LastFault == Fault_None then
        InstallBundleOperationDescriptor(descriptor);
    end;
end;

func ExecuteDecodedBundleStart(instruction: bits(64),
                              form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                              length_bits: integer {16,32,48,64})
begin
    ExecuteDecodedBundleStartWithAcceptedApplicabilityRules(
        NumericApplicabilityRules_None, instruction, form, length_bits);
end;

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
            SetBundleDataAttributeState0571(
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
        when CommandHandler_SetBundleBodyAddress =>
            SetBundleBodyAddress(CommandDecodedBundleTarget(instruction, form));
        when CommandHandler_BindBundleScalarIO =>
            SetBundleScalarBinding(0,
                CommandDecodedReg5(instruction, form, CommandField_RegDst),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc0),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc1),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc2), 3);
        when CommandHandler_BindBundleTileIO =>
            AddBundleTileBinding(
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

func ExecuteCommandInstruction(instruction: bits(64),
                               length_bits: integer {16,32,48,64})
                               => CommandExecutionStatus
begin
    BeginArchitecturalInstructionAttempt();
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
    return ExecuteDecodedBundleCommand(instruction, form, length_bits);
end;
