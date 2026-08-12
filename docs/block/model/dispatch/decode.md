<!-- GENERATED FROM: asl/block/model/dispatch/decode.asl -->
# Decode

**Normative ASL source:** `asl/block/model/dispatch/decode.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-DECODE}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/decode.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-DECODE","surface":"block","classification":["model","dispatch","decode"],"depends_on":["PTO-BLOCK-B-CATR","PTO-BLOCK-B-DATR","PTO-BLOCK-B-DIM","PTO-BLOCK-B-HINT","PTO-BLOCK-B-IOR","PTO-BLOCK-B-IOS","PTO-BLOCK-B-IOT","PTO-BLOCK-B-TEXT","PTO-BLOCK-BSTART","PTO-BLOCK-BSTART-CALL","PTO-BLOCK-BSTART-FP","PTO-BLOCK-BSTART-GMOV","PTO-BLOCK-BSTART-MGATHER","PTO-BLOCK-BSTART-MGATHER-CAS","PTO-BLOCK-BSTART-MGATHER-MASK","PTO-BLOCK-BSTART-MPAR","PTO-BLOCK-BSTART-MSCATTER","PTO-BLOCK-BSTART-MSCATTER-MASK","PTO-BLOCK-BSTART-MSEQ","PTO-BLOCK-BSTART-STD","PTO-BLOCK-BSTART-SYS","PTO-BLOCK-BSTART-TEPL","PTO-BLOCK-BSTART-TGEMV","PTO-BLOCK-BSTART-TGEMV-ACC","PTO-BLOCK-BSTART-TGEMV-BIAS","PTO-BLOCK-BSTART-TGEMVMX","PTO-BLOCK-BSTART-TGEMVMX-ACC","PTO-BLOCK-BSTART-TGEMVMX-BIAS","PTO-BLOCK-BSTART-TLOAD","PTO-BLOCK-BSTART-TMATMUL","PTO-BLOCK-BSTART-TMATMUL-ACC","PTO-BLOCK-BSTART-TMATMUL-BIAS","PTO-BLOCK-BSTART-TMATMULMX","PTO-BLOCK-BSTART-TMATMULMX-ACC","PTO-BLOCK-BSTART-TMATMULMX-BIAS","PTO-BLOCK-BSTART-TMOV","PTO-BLOCK-BSTART-TPREFETCH","PTO-BLOCK-BSTART-TSTORE","PTO-BLOCK-BSTOP","PTO-BLOCK-C-B-DIMI","PTO-BLOCK-C-BSTART","PTO-BLOCK-C-BSTART-FP","PTO-BLOCK-C-BSTART-MPAR","PTO-BLOCK-C-BSTART-MSEQ","PTO-BLOCK-C-BSTART-STD","PTO-BLOCK-C-BSTART-SYS","PTO-BLOCK-C-BSTOP","PTO-BLOCK-ERCOV","PTO-BLOCK-ESAVE","PTO-BLOCK-FENTRY","PTO-BLOCK-FEXIT","PTO-BLOCK-FRET-RA","PTO-BLOCK-FRET-STK","PTO-BLOCK-HL-BSTART-CALL","PTO-BLOCK-HL-BSTART-FP","PTO-BLOCK-HL-BSTART-STD","PTO-BLOCK-HL-BSTART-SYS","PTO-BLOCK-HL-QMT","PTO-BLOCK-HL-QPOP","PTO-BLOCK-HL-QPUSH","PTO-BLOCK-L-BSTART-FP","PTO-BLOCK-L-BSTART-STD","PTO-BLOCK-L-BSTART-SYS","PTO-BLOCK-MCOPY","PTO-BLOCK-MSET","PTO-BLOCK-XB"]}
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
           handler != CommandHandler_ExecuteBundleStop &&
           handler != CommandHandler_ExecuteFrameReturnAddress &&
           handler != CommandHandler_ExecuteFrameReturnStack;
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
    if CommandBundleSelectorUsesEncodingVariant(form) then
        selector = CommandBundleSelectorConstantOfForm(instruction, form);
        selector_valid = TRUE;
    elsif CommandFormSelectsTileOperation(form) then
        selector = CommandTileCodeOfForm(instruction, form)[9:0];
        selector_valid = TRUE;
    elsif CommandOperandPresent(form, CommandField_Function) then
        selector[4:0] = DecodeCommandOperandRaw(instruction, form,
            CommandField_Function)[4:0];
        selector_valid = TRUE;
    elsif CommandBundleSelectorConstantPresent(form) then
        selector = CommandBundleSelectorConstantOfForm(instruction, form);
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
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
