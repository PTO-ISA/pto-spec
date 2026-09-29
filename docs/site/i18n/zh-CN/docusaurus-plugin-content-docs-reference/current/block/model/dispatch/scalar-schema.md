<!-- GENERATED FROM: asl/block/model/dispatch/scalar-schema.asl -->
# Scalar Schema

**Normative ASL source:** `asl/block/model/dispatch/scalar-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-scalar-schema-purpose role=purpose-scope -->
## 用途与范围

本单元负责 `B.IOR` 的规则。`B.IOR` 是把通用寄存器（GPR）绑定到 Tile 操作的指令束命令。一个 `B.IOR` 携带一个目标选择子 `RegDst` 和至多三个源选择子 `RegSrc0`、`RegSrc1` 和 `RegSrc2`。选择子编码 0 表示架构零寄存器。

本单元在指令束生命周期的三个时刻起作用：

- 头命令译码期间，它决定 `B.IOR` 可以放在哪里，以及是否需要第二个 `B.IOR`。
- 检查指令束完整性时，它检查选择子结构，但不读取任何 GPR。
- 分配目标之前，它读取 GPR 值并检查其范围。

<!-- PTO-READER-BLOCK: block-model-dispatch-scalar-schema-concepts role=concepts-state -->
## 概念与可见状态

`_BundleScalarBindings` 有两个条目。索引 0 保存第一个 `B.IOR`。索引 1 仅在 `BundleMultiIORSelected` 为真时使用，这适用于 `TGPR2T`、`TIMG2COL` 以及可使用 ExecutionMask 的操作。每个条目记录其选择子、一个 `source_count` 以及一个 `execution_mask_present` 标志。

操作输入按固定顺序紧密打包到源槽中：`address`、`scalar0`、`diagonal`，然后是 `flag0`；对于矩阵指令束，当 `B.FPATR` 选择标量参数时，后面再跟一个量化参数和一个 ReLU 参数。`BundleOperationGPRInputCount` 统计存在的输入，`BundleOperationGPRInputSlot` 给出 `address`、`scalar0`、`diagonal` 或 `flag0` 的槽位；值检查自行计算矩阵参数的槽位。

本单元只读取状态。它不写入任何内容，自身也不引发故障；故障由其调用方引发。

<!-- PTO-READER-BLOCK: block-model-dispatch-scalar-schema-rules role=rules-interactions -->
## 规则与交互

放置规则由命令译码器求值。对于 `TGPR2T`，`RegDst` 为 0，且两个 `B.IOR` 命令都位于任何参与的 `B.IOT` 之前。对于 `TIMG2COL`，`B.IOR` 位于所有 Tile 和 Shared 绑定之前，`RegDst` 为 0，且第一个 `B.IOR` 的 `RegSrc1` 和 `RegSrc2` 为零。对于 ExecutionMask 流，第二个 `B.IOR` 的 `RegDst` 为 0，并跟在一个不带掩码标志的第一个 `B.IOR` 之后。当 `TGPR2T` 或 `TIMG2COL` 只收到第一个 `B.IOR` 时，下一条命令必须是第二个 `B.IOR`。`TGPR2T` 还接受零参与的 `B.IOT`，并且在见到零参与之后接受任何命令。违反这些规则会引发 `Fault_BundleControl`。

`BundleOperationScalarBindingSchemaLegal` 只检查结构：

- 在普通情形下，超出输入数量的每个源槽都必须是选择子 0，且 `RegDst` 必须为 0。
- 没有 ExecutionMask 的 `TEXPDIF` 不接受任何 `B.IOR`。
- CUBE `TCI` 需要恰好一个 `B.IOR`，其中两个选择子小于 `PTO_ABSOLUTE_GPR_COUNT`（24），`RegSrc2` 为零，`RegDst` 为零。
- GPR ExecutionMask 交由 `BundleExecutionMaskGPRBindingSchemaLegal` 检查。它要求掩码布局为 `CUBE_M16` 或 `CUBE_M32`，最多允许 6 个槽位，先放操作输入，再放 1 或 2 个掩码字。恰好在需要超过 3 个槽位时使用第二个 `B.IOR`，掩码标志标记所使用的最后一个 `B.IOR`。

`BundleOperationGPRBindingValuesLegal` 读取值。`flag0` 必须为 0 或 1。`diagonal` 必须在 -65535 到 65535 之间。矩阵标量参数必须是合法的参数字。对于 CUBE `TCI`，每个参与 PE 的 Step2D 行步长和列步长都必须是 -1、0 或 1。没有掩码的 `TGPR2T` 需要两个 `B.IOR` 命令：第一个有 3 个源，第二个有 1 个源，所有选择子都小于 24，且 `RegDst` 为 0。没有 ExecutionMask 时，普通操作不接受第二个 `B.IOR`，且最多有 3 个输入。

设计要点：结构检查和值检查是分开的。在零参与退出之后，本地 Tile 路径先检查完整性（失败引发 `Fault_BundleControl`），再检查值（失败引发 `Fault_TileLegality`），然后才分配目标。ASL 注释说明了其结果：无效值永远不会进入受约束的 `TileInstructionOperands` 字段或 Tile 状态。在这条路径上，`PE_MASK` 为 0000 的指令束不读取任何 GPR。

设计要点：未使用的选择子必须为 0，而不是被忽略。`B.IOR` 的源槽没有单独的省略编码；编码 0 表示零寄存器。因此普通检查只接受超出输入数量的槽位中的编码 0，在本地 Tile 路径上，多余的非零选择子会在完整性检查中失败并引发 `Fault_BundleControl`。

<!-- PTO-READER-BLOCK: block-model-dispatch-scalar-schema-boundaries role=boundaries -->
## 架构边界

本单元不为执行读取标量。[Tile 指令操作数](tile-instruction-operands.md)使用相同的槽位函数填充操作数，ExecutionMask 所有者负责解释掩码字。比较和选择操作在这里跳过普通值检查；它们的 `B.IOR` 布局由[比较 schema](comparison-schema.md)检查。

<!-- PTO-READER-BLOCK: block-model-dispatch-scalar-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

`TADDS <Row=8, Col=64, FP32>, T#1, a2, ->T<2KB>` 只有一个输入 `scalar0`，因此其 `B.IOR` 为 `a2, zero, zero, ->zero`。`RegSrc1` 非零的 `B.IOR` 无法通过结构检查。

`TTRI` 的 `diagonal` 位于槽位 0，`flag0` 位于槽位 1。如果方向寄存器的值为 2，值检查失败，指令束会在分配任何目标之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-scalar-schema-related role=related-owners-navigation -->
## 相关所有者

- [命令](commands.md)在译码 `B.IOR` 时应用放置规则和流规则。
- [描述符合法性](descriptor-legality.md)在绑定完整性检查中调用结构检查。
- [Tile 执行分派](tile-execution.md)把值检查排在目标解析之前。
- [执行掩码 schema](execution-mask-schema.md)解释 GPR 掩码字。
- [标量绑定](../operands/scalar-bindings.md)保存 `B.IOR` 记录。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/scalar-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","surface":"block","classification":["model","dispatch","scalar-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-DISPATCH-WEIGHT-TO-SHARED-SCHEMA","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS","PTO-TILE-MODEL-NUMERIC-FORMATS"]}
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

// Complete-bundle GPR inputs pack present address, scalar0, diagonal, and flag0 operands densely.
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
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TPACK ||
       decoded == TileOperation_TUNPACK then
        let binding = _BundleTileBindings[[0]];
        let tile_index = if binding.source0_subview.materialized then binding.source0_subview.materialized_index else binding.source0;
        let tile = _Tiles[[tile_index]];
        let bytes_per_element = (TileElementBits(tile.data_type) DIVRM 8) as integer {0..4};
        let valid_bytes = (tile.valid_columns * bytes_per_element) as integer {0..262140};
        let words_per_row = ((valid_bytes + 3) DIVRM 4) as integer {0..65535};
        if tile.valid_rows == 0 || words_per_row == 0 then return 1; end;
        let row_bits = if tile.layout == TileLayout_CUBE_M32 then 32 else 16;
        let final_bit = ((words_per_row - 1) * row_bits + tile.valid_rows) as integer {0..2097120};
        return if final_bit <= 64 then 1 else 2;
    end;
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
        return if BundleTileBindingCount() == 1 then
            BundleExecutionMaskGPRWordCount(operation) else 0;
    end;
    if decoded == TileOperation_TSELS then
        // Scalar-false precedes the GPR mask; PredicateCell form has no GPR select mask.
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
    let decoded = TileOperationOfIndex(operation);
    let source_layout_owns_domain = BundleCubeTransportSelected() || decoded == TileOperation_TCMP || decoded == TileOperation_TCMPS || decoded == TileOperation_TCVT || decoded == TileOperation_TSEL || decoded == TileOperation_TSELS;
    let execution_mask_layout = if source_layout_owns_domain then BundleExecutionMaskCoordinateLayout(operation) else CurrentBundleTileLayout();
    if !TileOperationExecutionMaskEligible(operation) || (execution_mask_layout != TileLayout_CUBE_M16 && execution_mask_layout != TileLayout_CUBE_M32) then return FALSE; end;
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
        // CUBE TCI uses source1 as packed raw Step2D, not RowMajor direction.
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
        // CUBE TCI has two absolute selectors and explicit zero source2/destination.
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
```
<!-- GENERATED-ASL-END: unit -->
