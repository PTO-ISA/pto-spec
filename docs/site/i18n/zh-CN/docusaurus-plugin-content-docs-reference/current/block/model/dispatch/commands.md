<!-- GENERATED FROM: asl/block/model/dispatch/commands.asl -->
# Commands

**Normative ASL source:** `asl/block/model/dispatch/commands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-COMMANDS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-commands-purpose role=purpose-scope -->
## 用途与范围

本单元是块命令的中心分派开关。顶层所有者解码命令形式并检查其操作数后，调用 `ExecuteDecodedBundleCommand`。该函数选择该形式的语义处理器，运行处理器特定的检查，更新指令束或架构状态，并在处理器按顺序执行时推进 `TPC`。

它路由的命令包括头部命令 `B.CATR`、`B.DATR`、`B.FPATR`、`B.DIM`、`B.IOR`、`B.IOT`、`B.IOS`、`B.SUBVIEW` 和 `B.ASSEMBLE`，生命周期命令 `BSTART`、`BSTOP` 和 `B.HINT`，帧命令，`HL.Q*` 队列命令，以及 `MCOPY` 和 `MSET`。

本单元还定义了 `BundleFixedPointAttributesCanBePlaced`，即 `B.FPATR` 的位置规则。

<!-- PTO-READER-BLOCK: block-model-dispatch-commands-concepts role=concepts-state -->
## 概念与可见状态

指令束有头部阶段和主体阶段。头部命令只在 `_BundleActive` 为真且 `_BundleBodyActive` 为假时合法。大多数头部处理器还会拒绝第二份副本：例如第二条 `B.CATR` 或 `B.DATR` 会引发 `Fault_BundleControl`。

处理器写入的头部状态包括 `_BundleControlAttributes`、`_BundleDataAttributes`、`_BundleFixedPointAttributes`、`_BundleDimensions`、标量、Tile 和 Shared 绑定表、`B.SUBVIEW` 与 `B.ASSEMBLE` 使用的范围组，以及 `_BundleHint`。

范围组是一个打开的窗口，使后续的 `B.SUBVIEW` 或 `B.ASSEMBLE` 能附加到前面的 `B.IOT` 或 `B.IOS` 上。除这两个范围修饰命令之外，每条命令都会先关闭它。

<!-- PTO-READER-BLOCK: block-model-dispatch-commands-rules role=rules-interactions -->
## 规则与交互

在任何处理器效果之前，该函数按固定顺序检查：

1. `ESAVE`、`ERCOV` 和跨块转移的处理器不受支持，引发 `Fault_IllegalInstruction`。
2. 打断已打开的 `TGPR2T` 或 `TIMG2COL` 命令流的命令引发 `Fault_BundleControl`。
3. 对 `HL.QMT`、`HL.QPUSH` 和 `HL.QPOP`，保留的标志组合或非法 GPR 选择器引发 `Fault_IllegalInstruction`。
4. 处理器运行它自己的位置与字段检查。

只要记录了任何故障，该函数就返回 `CommandExecution_Rejected`，且不推进 `TPC`。

`B.FPATR` 的位置规则更严格。它必须出现在头部、至多一次、位于任何 `B.IOR`、`B.IOT` 或 `B.IOS` 之前，并且只在所选操作是 Tile 矩阵操作或尚未安装操作描述符时出现。

寄存器形式的 `B.DIM` 把一个 GPR 值与可选的 `uimm17` 相加，并保留低 16 位。立即数形式使用 `imm8`。对同一维度给出第二个值会引发 `Fault_BundleControl`。

设计要点：`PEMode` 为 `000` 的 `B.IOT` 或 `B.IOS` 不指定任何 PE。在其尺寸编码检查之后，处理器（若处于头部）记录零参与，打开一个零模式范围组，推进 `TPC` 并返回。处理器的位置、绑定和分配检查被跳过。因此没有任何 PE 使用的绑定不会因这些规则而故障，但之前的步骤 1 和 2 仍然适用。

设计要点：`B.SUBVIEW` 和 `B.ASSEMBLE` 在读取任何 GPR 之前检查 GPR 选择器和尺寸编码。对 `B.SUBVIEW`，ASL 注释说明，保留的选择器或编码不会改变载体和范围状态。在零模式范围组中，它们不记录任何内容，也不读取 GPR。

<!-- PTO-READER-BLOCK: block-model-dispatch-commands-boundaries role=boundaries -->
## 架构边界

`BSTART`、`BSTOP`、`FRET.RA` 和 `FRET.STK` 自己设置 `TPC`，因此本函数在它们之后不推进 `TPC`。在 `B.HINT` 跟踪形式之后它同样不推进 `TPC`；该处理器内部的提交或开始转换会设置它。

`B.HINT` 跟踪形式先在提示地址提交任何活动的指令束。如果该提交选择了另一个地址，提示直接返回而不开始指令束。否则它清除头部状态，并开始一个新的标准顺序执行指令束。

操作级验证与提交不在这里执行。`BSTOP` 委托给 `CompleteBundleAt`，`BSTART` 委托给 start 所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-commands-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设指令束头部在地址 `0x2010` 处有一条 4 字节 `B.IOT`，其 `PEMode` 为 `000`，尺寸编码合法。`PEMaskOfPEMode` 返回 `0000`。处理器设置 `_BundleZeroParticipationSeen`，打开一个零模式范围组，并把 `TPC` 写为 `0x2014`。不会添加 Tile 绑定。

如果同一条 `B.IOT` 的 `PEMode` 为 `111`、掩码为 `1111`，并且出现在 `BSTOP` 关闭指令束之后，位置检查会引发 `Fault_BundleControl`，`TPC` 保持为 `0x2010`。

<!-- PTO-READER-BLOCK: block-model-dispatch-commands-related role=related-owners-navigation -->
## 相关所有者

- [顶层分派](top-level.md) 解码形式、检查操作数并调用本单元。
- [命令解码](decode.md) 定义操作数解码和受支持处理器规则。
- [命令数据属性](command-data-attributes.md) 锁存 `B.DATR`。
- [指令束开始分派](start.md) 处理 `BSTART` 形式。
- [提交验证](../commit/validation.md) 拥有 `CompleteBundleAt`。
- [B.IOT](../../operands/B.IOT.md) 是 Tile 绑定命令的指令页面。
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
