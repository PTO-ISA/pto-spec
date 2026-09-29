<!-- GENERATED FROM: asl/block/model/dispatch/commands.asl -->
# Commands

**Normative ASL source:** `asl/block/model/dispatch/commands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-COMMANDS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-commands-purpose role=purpose-scope -->
## Purpose and scope

This unit is the central switch for block commands. After the top-level owner decodes a command form and checks its operands, it calls `ExecuteDecodedBundleCommand`. That function selects the semantic handler of the form, runs the handler-specific checks, updates bundle or architectural state, and advances `TPC` when the handler is sequential.

The commands it routes include the header commands `B.CATR`, `B.DATR`, `B.FPATR`, `B.DIM`, `B.IOR`, `B.IOT`, `B.IOS`, `B.SUBVIEW`, and `B.ASSEMBLE`, the lifecycle commands `BSTART`, `BSTOP`, and `B.HINT`, the frame commands, the `HL.Q*` queue commands, and `MCOPY` and `MSET`.

The unit also defines `BundleFixedPointAttributesCanBePlaced`, the placement rule for `B.FPATR`.

<!-- PTO-READER-BLOCK: block-model-dispatch-commands-concepts role=concepts-state -->
## Concepts and visible state

A bundle has a header phase and a body phase. Header commands are legal only while `_BundleActive` is true and `_BundleBodyActive` is false. Most header handlers also reject a second copy: for example, a second `B.CATR` or `B.DATR` raises `Fault_BundleControl`.

The handlers write header state such as `_BundleControlAttributes`, `_BundleDataAttributes`, `_BundleFixedPointAttributes`, `_BundleDimensions`, the scalar, Tile, and Shared binding tables, the range group used by `B.SUBVIEW` and `B.ASSEMBLE`, and `_BundleHint`.

A range group is the open window that lets a following `B.SUBVIEW` or `B.ASSEMBLE` attach to the preceding `B.IOT` or `B.IOS`. Every command other than these two range modifiers closes it first.

<!-- PTO-READER-BLOCK: block-model-dispatch-commands-rules role=rules-interactions -->
## Rules and interactions

The function checks in a fixed order before any handler effect:

1. Handlers for `ESAVE`, `ERCOV`, and cross-block transfer are unsupported and raise `Fault_IllegalInstruction`.
2. A command that breaks an open `TGPR2T` or `TIMG2COL` command stream raises `Fault_BundleControl`.
3. For `HL.QMT`, `HL.QPUSH`, and `HL.QPOP`, reserved flag combinations or illegal GPR selectors raise `Fault_IllegalInstruction`.
4. The handler runs its own placement and field checks.

If any fault is recorded, the function returns `CommandExecution_Rejected` and does not advance `TPC`.

`B.FPATR` has a stricter placement rule. It must appear in the header, at most once, before any `B.IOR`, `B.IOT`, or `B.IOS`, and only when the selected operation is a Tile matrix operation or no operation descriptor is installed.

`B.DIM` in register form adds a GPR value and an optional `uimm17` and keeps the low 16 bits. The immediate form uses `imm8`. A second value for the same dimension raises `Fault_BundleControl`.

Design point: a `B.IOT` or `B.IOS` whose `PEMode` is `000` names no PE. After its size-code encoding check, the handler records zero participation when in a header, opens a zero-mode range group, advances `TPC`, and returns. The handler's placement, binding, and allocation checks are skipped. A binding that no PE uses therefore cannot fault on those rules, although the earlier steps 1 and 2 still apply.

Design point: `B.SUBVIEW` and `B.ASSEMBLE` check the GPR selector and size code before reading any GPR. For `B.SUBVIEW`, the ASL comment states that reserved selectors or codes leave carriers and range state unchanged. In a zero-mode range group they record nothing and read no GPR.

<!-- PTO-READER-BLOCK: block-model-dispatch-commands-boundaries role=boundaries -->
## Architectural boundaries

`BSTART`, `BSTOP`, `FRET.RA`, and `FRET.STK` set `TPC` themselves, so this function does not advance it after them. It also does not advance `TPC` after a `B.HINT` trace form; the commit or the begin transition inside that handler sets it.

A `B.HINT` trace form first commits any active bundle at the hint address. If that commit selected another address, the hint returns without starting a bundle. Otherwise it clears header state and begins a new standard fallthrough bundle.

Operation-level validation and commit are not performed here. `BSTOP` delegates to `CompleteBundleAt`, and `BSTART` delegates to the start owner.

<!-- PTO-READER-BLOCK: block-model-dispatch-commands-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose a bundle header contains a 4-byte `B.IOT` at address `0x2010` with `PEMode` `000` and a legal size code. `PEMaskOfPEMode` returns `0000`. The handler sets `_BundleZeroParticipationSeen`, opens a zero-mode range group, and writes `TPC` as `0x2014`. No Tile binding is added.

If the same `B.IOT` had `PEMode` `111`, mask `1111`, and appeared after `BSTOP` had closed the bundle, the placement check would raise `Fault_BundleControl`, and `TPC` would stay at `0x2010`.

<!-- PTO-READER-BLOCK: block-model-dispatch-commands-related role=related-owners-navigation -->
## Related owners

- [Top-level dispatch](top-level.md) decodes the form, checks operands, and calls this unit.
- [Command decode](decode.md) defines operand decoding and the supported-handler rules.
- [Command data attributes](command-data-attributes.md) latches `B.DATR`.
- [Bundle start dispatch](start.md) handles `BSTART` forms.
- [Commit validation](../commit/validation.md) owns `CompleteBundleAt`.
- [B.IOT](../../operands/B.IOT.md) is the instruction page for the Tile binding command.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/commands.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-COMMANDS","surface":"block","classification":["model","dispatch","commands"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES","PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-START","PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS"]}
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
func ExecuteDecodedBundleCommand(
    instruction: bits(64), form: integer {0..PTO_COMMAND_FORM_COUNT-1},
    length_bits: integer {16,32,48,64}) => CommandExecutionStatus
begin
    let handler = CommandHandlerOfForm(form);
    let hint_trace = handler == CommandHandler_SetBundleHint &&
        CommandOperandPresent(form, CommandField_B_E);
    if !CommandHandlerSupported(handler) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    if !DecodedBundleCommandKeepsTGPR2TStreamLegal(instruction, form) ||
       !DecodedBundleCommandKeepsTIMG2COLStreamLegal(form) then
        SetFault(Fault_BundleControl, ReadTPC());
        return CommandExecution_Rejected;
    end;
    let range_modifier = handler == CommandHandler_ApplyBundleSubview ||
        handler == CommandHandler_ApplyBundleAssemble;
    if !range_modifier then
        // A non-modifier closes the preceding non-retroactive range group.
        CloseBundleRangeGroup();
    end;
    if handler == CommandHandler_ExecuteQueueMove then
        let flags = CommandDecodedQueueMoveFlags(instruction, form);
        if flags[1:0] == '11' then
            SetFault(Fault_IllegalInstruction, ReadTPC());
            return CommandExecution_Rejected;
        end;
        let source_left = CommandDecodedReg5(instruction, form,
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
        let source_left = CommandDecodedReg5(instruction, form,
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
            SetBundleDataAttributesFromCommand(instruction, form);
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
                CommandDecodedBool(instruction, form, CommandField_TransB),
                CommandDecodedBool(instruction, form, CommandField_CScaleEn));
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
            let shared_mask = PEMaskOfPEMode(pe_mode);
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
            let selected_tgpr2t = BundleTGPR2TSelected();
            let selected_multi_ior = BundleMultiIORSelected();
            let binding_index = BundleMultiIORBindingIndex();
            let execution_mask_present =
                DecodeCommandOperandRaw(instruction, form,
                    CommandField_ExecMaskPresent)[0] == '1';
            if !_BundleActive || _BundleBodyActive ||
               _BundleScalarBindings[[binding_index]].valid ||
               (!selected_multi_ior && _BundleScalarBindings[[0]].valid) ||
               !BundleMultiIORScalarCommandCanBePlaced(
                   binding_index, instruction, form) then
                SetFault(Fault_BundleControl, ReadTPC());
                return CommandExecution_Rejected;
            end;
            SetBundleScalarBindingWithExecutionMask(binding_index,
                CommandDecodedReg5(instruction, form, CommandField_RegDst),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc0),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc1),
                CommandDecodedReg5(instruction, form, CommandField_RegSrc2),
                if selected_tgpr2t && binding_index == 1 &&
                   !execution_mask_present then 1 else 3,
                execution_mask_present);
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
            let pe_mask = PEMaskOfPEMode(pe_mode);
            if pe_mask == Zeros{4} then
                // Strict no-op: zero participation suppresses placement, stream,
                // schema, allocation, and descriptor checks.
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
            if BundleTGPR2TSelected() && !BundleTGPR2TScalarBindingsComplete() then
                SetFault(Fault_BundleControl, ReadTPC());
                return CommandExecution_Rejected;
            end;
            if !_BundleActive || _BundleBodyActive ||
               BundleTileBindingSequenceClosed() then
                SetFault(Fault_BundleControl, ReadTPC());
                return CommandExecution_Rejected;
            end;
            if !BundleTileMaskCanAppend(pe_mask) ||
                (local_destination && tile_size == 0) then
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
                MarkBundleTileBindingSourcesRelative(BundleTileBindingLastIndex() as BundleTileBindingIndex);
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
            // Decode legality precedes PEMode suppression and every GPR read;
            // reserved selectors/codes leave carriers and range state unchanged.
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
                CommandField_WriterSizeCode);
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
                    size_code as integer {0..15}, offset);
            end;
        when CommandHandler_ExecuteBundleStart =>
            ExecuteDecodedBundleStart(instruction, form, length_bits);
        when CommandHandler_ExecuteBundleStop =>
            let completed = CompleteBundleAt(ReadTPC() +
                (Zeros{PTO_XLEN} + (length_bits DIV 8)));
        when CommandHandler_SetBundleHint =>
            if LinxTraceBoundaryHintApplies(hint_trace, instruction, form) then return ExecuteLinxTraceBoundaryHint(instruction, form); end;
            if hint_trace then
                let instruction_pc = ReadTPC();
                if _BundleActive then
                    if !CompleteBundleAt(instruction_pc) then
                        return CommandExecution_Rejected;
                    end;
                    if ReadTPC() != instruction_pc then
                        return CommandExecution_Executed;
                    end;
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
                LSL(CommandDecodedWord(instruction, form, CommandField_uimm), 3));
        when CommandHandler_ExecuteFrameExit =>
            ExecuteFEXIT(
                CommandDecodedReg5(instruction, form, CommandField_DstBegin),
                CommandDecodedReg5(instruction, form, CommandField_DstEnd),
                LSL(CommandDecodedWord(instruction, form, CommandField_uimm), 3));
        when CommandHandler_ExecuteFrameReturnAddress =>
            ExecuteFRETRA(
                CommandDecodedReg5(instruction, form, CommandField_DstBegin),
                CommandDecodedReg5(instruction, form, CommandField_DstEnd),
                LSL(CommandDecodedWord(instruction, form, CommandField_uimm), 3));
        when CommandHandler_ExecuteFrameReturnStack =>
            ExecuteFRETSTK(
                CommandDecodedReg5(instruction, form, CommandField_DstBegin),
                CommandDecodedReg5(instruction, form, CommandField_DstEnd),
                LSL(CommandDecodedWord(instruction, form, CommandField_uimm), 3));
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
            ExecuteMemorySet(
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
