<!-- GENERATED FROM: asl/block/model/dispatch/decode.asl -->
# Decode

**Normative ASL source:** `asl/block/model/dispatch/decode.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-DECODE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-decode-purpose role=purpose-scope -->
## Purpose and scope

This unit turns the raw bits of a bundle command into typed values. A bundle command is a block-surface command instruction handled by command dispatch, for example `BSTART`, `B.DIM`, `B.IOT`, `B.DATR`, or `BSTOP`. A form is one concrete encoding of such a command in the frozen command catalog.

The unit defines the field extractors that command handlers call, the two handler classification predicates, and `DecodeBundleOperationDescriptor`, which builds the operation descriptor that a `BSTART` form carries. It also defines `CommandExecutionStatus`, the `Executed` or `Rejected` result that command dispatch returns.

<!-- PTO-READER-BLOCK: block-model-dispatch-decode-concepts role=concepts-state -->
## Concepts and visible state

Every function in this unit except the enumeration is `pure`. The unit reads no architectural state and writes none.

- `CommandDecodedWord` widens a field to `PTO_XLEN` bits. A field that the catalog marks signed is sign-extended from its width, which must be 8, 12, 15, 17, 25, 30, or 42 bits. Any other field is zero-extended.
- `CommandDecodedReg5` keeps the low 5 bits as a GPR selector. `CommandDecodedTile` keeps the low 6 bits as a `TileIndex`. `CommandDecodedSmall` keeps the low 4 bits. `CommandDecodedBool` tests bit 0.
- The queue flag helpers pack single-bit fields into a 4-bit value. Move places `i`, `e`, `s`, `r` in bits 3 to 0. Pop places `e` in bit 1 and `r` in bit 0. Push places `h` in bit 3, `e` in bit 2, and `r` in bit 0.
- `CommandDecodedBundleDimension` picks the dimension slot. A form with a `LoopNest` field uses its low 2 bits. Otherwise the `B.DIM` form itself names the slot: `->LB0` gives 0, `->LB1` gives 1, and any other form gives 2.

The operation descriptor records `form_identity`, `operation_class`, and four optional fields: `selector`, `data_type`, `mode`, and `branch_type`. Each optional field has its own valid flag.

<!-- PTO-READER-BLOCK: block-model-dispatch-decode-rules role=rules-interactions -->
## Rules and interactions

The selector is taken from the first source that applies, in this order: an encoding-variant constant, the 10-bit Tile operation code of a form that selects a Tile operation, the 5-bit `Function` field, and a catalog selector constant. If none applies, `selector_valid` is false.

`data_type_valid` is true when the form selects a Tile operation or has a `DataType` field. `mode` is the low 2 bits of the `Mode` field and `branch_type` is the low 3 bits of the `BrType` field, each only when that field exists.

Design point: an absent field and an encoded zero stay distinct. Each optional field carries a valid flag, and an absent field is stored as zeros with its flag false. Later checks test the flag. For example, `BundleSelectorCode` places `mode` above the selector only when `mode_valid` is true.

`CommandHandlerSupported` returns false for three handlers: `SaveExecutionContext`, `RecoverExecutionContext`, and `ExecuteCrossBlockTransfer`, which serve `ESAVE`, `ERCOV`, and `XB`. Command dispatch checks it before calling any handler and raises `Fault_IllegalInstruction` for these handlers.

Design point: these forms still decode to a known form, but no handler runs for them. The `XB` contract states the reason: the decoded identity is kept for collision inventory and fail-closed dispatch.

`CommandHandlerAdvancesSequentially` is false for the bundle start, bundle stop, `FRET.RA`, and `FRET.STK` handlers. For other handlers, command dispatch normally adds the command length in bytes to `TPC` after a fault-free execution, except for a `B.HINT` trace form.

Design point: those four handlers choose the next `TPC` themselves. The start and stop handlers can commit a bundle, and a commit writes `TPC` from `BARG`. A fixed sequential step after them would overwrite that choice.

<!-- PTO-READER-BLOCK: block-model-dispatch-decode-boundaries role=boundaries -->
## Architectural boundaries

This unit does not match raw bits to a form. `ExecuteCommandInstruction` does that and checks operand legality before `ExecuteDecodedBundleCommand` runs. This unit also does not judge whether a descriptor is legal. `ExecuteDecodedBundleStart` decodes the descriptor, then checks it with `BundleOperationDescriptorLegal` before it commits any predecessor bundle. It installs the descriptor only after a fault-free `BeginBundleAt`.

<!-- PTO-READER-BLOCK: block-model-dispatch-decode-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A 32-bit `B.DIM RegSrc, uimm, ->LB1` has no `LoopNest` field, so `CommandDecodedBundleDimension` returns 1. Its handler is not one of the four non-sequential handlers, so a fault-free execution at `TPC` 0x1004 leaves `TPC` at 0x1008.

A `BSTART.STD DIRECT, <label>` has a signed 17-bit `simm17` field. If `CommandDecodedWord` were applied to that field holding `0x1FFFF`, it would sign-extend it to -1 across `PTO_XLEN` bits, while the same raw bits in an unsigned 17-bit field such as `B.DIM` `uimm17` give 131071. The bundle start path itself reads this offset through the generated `CommandSignedOffsetOfForm`, which also sign-extends it.

<!-- PTO-READER-BLOCK: block-model-dispatch-decode-related role=related-owners-navigation -->
## Related owners

- [Top-level dispatch](top-level.md) matches the form and checks operands before any handler runs.
- [Commands](commands.md) calls the extractors and advances `TPC` for sequential handlers.
- [Bundle start dispatch](start.md) decodes, checks, and installs the operation descriptor.
- [Descriptor legality](descriptor-legality.md) decides which decoded descriptors may be installed.
- [XB](../../encoding/XB.md) is a reserved form that decodes but is always rejected.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/decode.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-DECODE","surface":"block","classification":["model","dispatch","decode"],"depends_on":["PTO-BLOCK-B-CATR","PTO-BLOCK-B-DATR","PTO-BLOCK-B-DIM","PTO-BLOCK-B-HINT","PTO-BLOCK-B-IOR","PTO-BLOCK-B-IOS","PTO-BLOCK-B-IOT","PTO-BLOCK-BSTART","PTO-BLOCK-BSTART-ICALL","PTO-BLOCK-BSTART-FP","PTO-BLOCK-BSTART-GMOV","PTO-BLOCK-BSTART-MGATHER","PTO-BLOCK-BSTART-MGATHER-CAS","PTO-BLOCK-BSTART-MGATHER-MASK","PTO-BLOCK-BSTART-MSCATTER","PTO-BLOCK-BSTART-MSCATTER-MASK","PTO-BLOCK-BSTART-STD","PTO-BLOCK-BSTART-SYS","PTO-BLOCK-BSTART-TEPL","PTO-BLOCK-BSTART-TGEMV","PTO-BLOCK-BSTART-TGEMV-ACC","PTO-BLOCK-BSTART-TGEMV-BIAS","PTO-BLOCK-BSTART-TGEMVMX","PTO-BLOCK-BSTART-TGEMVMX-ACC","PTO-BLOCK-BSTART-TGEMVMX-BIAS","PTO-BLOCK-BSTART-TLOAD","PTO-BLOCK-BSTART-TMATMUL","PTO-BLOCK-BSTART-TMATMUL-ACC","PTO-BLOCK-BSTART-TMATMUL-BIAS","PTO-BLOCK-BSTART-TMATMULMX","PTO-BLOCK-BSTART-TMATMULMX-ACC","PTO-BLOCK-BSTART-TMATMULMX-BIAS","PTO-BLOCK-BSTART-TMOV","PTO-BLOCK-BSTART-TPREFETCH","PTO-BLOCK-BSTART-TSTORE","PTO-BLOCK-BSTOP","PTO-BLOCK-C-B-DIMI","PTO-BLOCK-C-BSTART","PTO-BLOCK-C-BSTART-FP","PTO-BLOCK-C-BSTART-STD","PTO-BLOCK-C-BSTART-SYS","PTO-BLOCK-C-BSTOP","PTO-BLOCK-ERCOV","PTO-BLOCK-ESAVE","PTO-BLOCK-FENTRY","PTO-BLOCK-FEXIT","PTO-BLOCK-FRET-RA","PTO-BLOCK-FRET-STK","PTO-BLOCK-HL-QMT","PTO-BLOCK-HL-QPOP","PTO-BLOCK-HL-QPUSH","PTO-BLOCK-MCOPY","PTO-BLOCK-MSET","PTO-BLOCK-XB"]}
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

pure func CommandHandlerSupported(handler: CommandSemanticHandler)
                                       => boolean
begin
    case handler of
        when CommandHandler_SaveExecutionContext,
             CommandHandler_RecoverExecutionContext,
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
