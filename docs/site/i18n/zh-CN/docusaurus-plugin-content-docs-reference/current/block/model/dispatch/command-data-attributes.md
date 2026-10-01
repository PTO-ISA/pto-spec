<!-- GENERATED FROM: asl/block/model/dispatch/command-data-attributes.asl -->
# Command Data Attributes

**Normative ASL source:** `asl/block/model/dispatch/command-data-attributes.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-command-data-attributes-purpose role=purpose-scope -->
## 用途与范围

本单元把 `B.DATR` 头部命令连接到指令束状态，并检查它的两个 ExecutionMask 控制。`B.DATR` 是指令束数据属性命令。它携带 `DataType`、`Layout`、`PadValueOrByteId`、`CMode`、`RMode`、`Sat`、`Canonicalize` 以及两个掩码控制 `PredInv` 和 `Zero`。

它定义两个函数：

- `SetBundleDataAttributesFromCommand` 解码一条 `B.DATR` 的字段并将其锁存。
- `BundleExecutionMaskDataAttributesLegal` 针对所选 Tile 操作判断 ExecutionMask 及其 `PredInv` 与 `Zero` 控制是否合法。

<!-- PTO-READER-BLOCK: block-model-dispatch-command-data-attributes-concepts role=concepts-state -->
## 概念与可见状态

ExecutionMask 是逐坐标的谓词，用于限制操作写入哪些目标坐标。它可以由 GPR 携带（`B.IOR` 记录上的 `execution_mask_present`），也可以由额外的 PredicateCell 源 Tile 携带。`PredInv` 对该谓词取反。`Zero` 让非活动目标坐标被清零而不是合并。

`SetBundleDataAttributesFromCommand` 把七个数据字段传给 `SetBundleDataAttributeState`。该辅助函数检查 `DataType` 和 `Layout` 编码，然后把字段写入 `_BundleDataAttributes` 并清除两个掩码控制。只有在没有引发故障时，本单元才写入 `execution_mask_invert` 和 `execution_mask_zero`，并设置 `_BundleDataAttributesPresent`。

设计要点：`_BundleDataAttributesPresent` 最后设置，并且只在无故障解码之后设置。保留的 `DataType` 或未分配的 `Layout` 会引发 `Fault_TileLegality`，数据属性保持不变且不会被标记为存在。

<!-- PTO-READER-BLOCK: block-model-dispatch-command-data-attributes-rules role=rules-interactions -->
## 规则与交互

commands 所有者中的命令处理器只在指令束处于头部阶段且尚未锁存过 `B.DATR` 时才调用 `SetBundleDataAttributesFromCommand`。否则它引发 `Fault_BundleControl`。

`BundleExecutionMaskDataAttributesLegal` 是一个只读检查，在之后验证指令束时运行。它在两种情况下拒绝。

1. `PredInv` 或 `Zero` 非零，而任何载体中都没有 ExecutionMask。
2. 存在掩码，但操作不具备 ExecutionMask 资格，或 Local 布局不是 `CUBE_M16` 或 `CUBE_M32`，或者在没有 `destination0` 操作数的操作上设置了 `Zero`（`TCMP` 和 `TCMPS` 除外）。

Local 布局通常来自指令束的当前布局。CUBE 布局转换传输改用其 `B.DATR` 转换编码指定的 CUBE 布局。

设计要点：`TCMP`、`TCMPS`、`TSEL` 和 `TSELS` 让 `B.DATR` 的 `Layout` 字段保持为零，CUBE `TCVT` 让它保持为 `NORM`；对这五个操作，本检查从源 Tile 描述符推导 CUBE 域。`TCMP` 要求两个源处于同一 CUBE 布局。`TSEL` 要求其真源与假源处于同一 CUBE 布局，并且在 PredicateCell 形式与非 PredicateCell 形式中以不同方式选取这两个源。因此，即使 `B.DATR` 写的是 `NORM`，带掩码的 CUBE 比较仍被接受。

设计要点：没有掩码时的非零掩码控制会被拒绝，而不是被忽略。零值保持其定义的含义：正常极性和 MERGE。因此多余的 `PredInv=1` 或 `Zero=1` 不会悄无声息地不起作用。

<!-- PTO-READER-BLOCK: block-model-dispatch-command-data-attributes-boundaries role=boundaries -->
## 架构边界

`BundleExecutionMaskDataAttributesLegal` 返回布尔值；它自身不引发拒绝故障。它的调用者，例如 Tile schema 所有者、Tile 执行所有者和 CUBE 传输所有者，把假结果映射为 `Fault_TileLegality`。

它不判断其他 `B.DATR` 字段是否适用于该操作。`CMode`、`RMode`、`Sat`、`Canonicalize` 和填充的逐操作适用性由 Tile schema 所有者通过 `TileOperationDATRFieldsLegal` 检查。掩码的捕获与应用属于 ExecutionMask 所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-command-data-attributes-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

考虑一个 `B.DATR` 选择 `Layout` `CUBE_M16` 并设置 `Zero=1` 的 `TADD` 指令束。

- 若以第三个 PredicateCell 源 Tile 作为掩码，`TADD` 具备资格、布局是 CUBE，且 `TADD` 有目标。检查通过，非活动目标坐标被清零。
- 若没有任何掩码载体，适用情况 1，该指令束在产生效果之前以 `Fault_TileLegality` 被拒绝。
- 若有掩码但 `B.DATR` 的 `Layout` 为 `NORM`（RowMajor），适用情况 2，该指令束同样被拒绝。

<!-- PTO-READER-BLOCK: block-model-dispatch-command-data-attributes-related role=related-owners-navigation -->
## 相关所有者

- [命令分派](commands.md) 负责头部位置规则和单一 `B.DATR` 规则。
- [控制状态](../state/control-state.md) 拥有 `SetBundleDataAttributeState` 和当前布局。
- [ExecutionMask schema](execution-mask-schema.md) 检测掩码载体并捕获掩码。
- [Tile schema](tile-schema.md) 把本检查与逐字段适用性一起调用。
- [B.DATR](../../attributes/B.DATR.md) 是该命令的指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/command-data-attributes.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES","surface":"block","classification":["model","dispatch","command-data-attributes"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS"]}
readonly func BundleExecutionMaskDataAttributesLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded_operation = TileOperationOfIndex(operation);
    let mask_present = _BundleExecutionMask.valid ||
        _BundleScalarBindings[[0]].execution_mask_present ||
        _BundleScalarBindings[[1]].execution_mask_present ||
        BundleExecutionMaskTileCarrierPresent(operation);
    if (_BundleDataAttributes.execution_mask_invert ||
        _BundleDataAttributes.execution_mask_zero) && !mask_present then
        return FALSE;
    end;
    var local_cube_layout = FALSE;
    if BundleCubeTransportSelected() then
        let transport_layout = TileDataLayoutCubeLayout(
            _BundleDataAttributes.data_layout);
        local_cube_layout = transport_layout == TileLayout_CUBE_M16 ||
            transport_layout == TileLayout_CUBE_M32;
    else
        let current_layout = CurrentBundleTileLayout();
        local_cube_layout = current_layout == TileLayout_CUBE_M16 ||
            current_layout == TileLayout_CUBE_M32;
    end;
    // TCMP and TCMPS own a closed B.DATR schema that leaves Layout zero.
    // Their Local CUBE domain comes from the comparison source tiles,
    // while DATR Layout remains independently validated as zero by the
    // operation owner.
    if decoded_operation == TileOperation_TCMP then
        let binding = _BundleTileBindings[[0]];
        if binding.valid && binding.source0_valid && binding.source1_valid then
            let left = BundleTileSourceIndex(0, FALSE);
            let right = BundleTileSourceIndex(0, TRUE);
            local_cube_layout =
                (_Tiles[[left]].layout == TileLayout_CUBE_M16 ||
                 _Tiles[[left]].layout == TileLayout_CUBE_M32) &&
                _Tiles[[right]].layout == _Tiles[[left]].layout;
        else
            local_cube_layout = FALSE;
        end;
    elsif decoded_operation == TileOperation_TCMPS then
        let binding = _BundleTileBindings[[0]];
        if binding.valid && binding.source0_valid then
            let source = BundleTileSourceIndex(0, FALSE);
            local_cube_layout = _Tiles[[source]].layout == TileLayout_CUBE_M16 ||
                _Tiles[[source]].layout == TileLayout_CUBE_M32;
        else
            local_cube_layout = FALSE;
        end;
    // CUBE TCVT also keeps B.DATR Layout=NORM because the retained source
    // descriptor owns both the conversion layout and ExecutionMask domain.
    elsif decoded_operation == TileOperation_TCVT then
        let binding = _BundleTileBindings[[0]];
        if binding.valid && binding.source0_valid then
            let source = BundleTileSourceIndex(0, FALSE);
            local_cube_layout = _Tiles[[source]].layout == TileLayout_CUBE_M16 ||
                _Tiles[[source]].layout == TileLayout_CUBE_M32;
        else
            local_cube_layout = FALSE;
        end;
    // TSEL/TSELS also keep B.DATR Layout closed at zero.  For the
    // ExecutionMask intersection, derive the Local CUBE domain from the
    // operation's numeric input descriptors instead of DATR Layout.
    elsif decoded_operation == TileOperation_TSEL then
        let inputs = _BundleTileBindings[[0]];
        if inputs.valid && inputs.source0_valid then
            let first = BundleTileSourceIndex(0, FALSE);
            if _Tiles[[first]].storage_kind == TileStorage_PredicateCell then
                if inputs.source1_valid &&
                   _BundleTileBindings[[1]].valid &&
                   _BundleTileBindings[[1]].source0_valid then
                    let source_true = BundleTileSourceIndex(0, TRUE);
                    let source_false = BundleTileSourceIndex(1, FALSE);
                    local_cube_layout =
                        (_Tiles[[source_true]].layout == TileLayout_CUBE_M16 ||
                         _Tiles[[source_true]].layout == TileLayout_CUBE_M32) &&
                        _Tiles[[source_false]].layout ==
                            _Tiles[[source_true]].layout;
                else
                    local_cube_layout = FALSE;
                end;
            elsif inputs.source1_valid then
                let source_true = BundleTileSourceIndex(0, FALSE);
                let source_false = BundleTileSourceIndex(0, TRUE);
                local_cube_layout =
                    (_Tiles[[source_true]].layout == TileLayout_CUBE_M16 ||
                     _Tiles[[source_true]].layout == TileLayout_CUBE_M32) &&
                    _Tiles[[source_false]].layout ==
                        _Tiles[[source_true]].layout;
            else
                local_cube_layout = FALSE;
            end;
        else
            local_cube_layout = FALSE;
        end;
    elsif decoded_operation == TileOperation_TSELS then
        let inputs = _BundleTileBindings[[0]];
        if inputs.valid && inputs.source0_valid then
            let first = BundleTileSourceIndex(0, FALSE);
            if _Tiles[[first]].storage_kind == TileStorage_PredicateCell then
                if inputs.source1_valid then
                    let source_true = BundleTileSourceIndex(0, TRUE);
                    local_cube_layout =
                        _Tiles[[source_true]].layout == TileLayout_CUBE_M16 ||
                        _Tiles[[source_true]].layout == TileLayout_CUBE_M32;
                else
                    local_cube_layout = FALSE;
                end;
            else
                local_cube_layout =
                    _Tiles[[first]].layout == TileLayout_CUBE_M16 ||
                    _Tiles[[first]].layout == TileLayout_CUBE_M32;
            end;
        else
            local_cube_layout = FALSE;
        end;
    end;
    if mask_present &&
       (!TileOperationExecutionMaskEligible(operation) ||
        !local_cube_layout ||
        (_BundleDataAttributes.execution_mask_zero &&
         !TileOperandPresent(operation, TileOperand_destination0) &&
         TileOperationOfIndex(operation) != TileOperation_TCMP &&
         TileOperationOfIndex(operation) != TileOperation_TCMPS)) then
        return FALSE;
    end;
    return TRUE;
end;

func SetBundleDataAttributesFromCommand(
    instruction: bits(64), form: integer {0..PTO_COMMAND_FORM_COUNT-1})
begin
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
        CommandDecodedBool(instruction, form, CommandField_Canonicalize));
    if _LastFault == Fault_None then
        _BundleDataAttributes.execution_mask_invert =
            CommandDecodedBool(instruction, form, CommandField_PredInv);
        _BundleDataAttributes.execution_mask_zero =
            CommandDecodedBool(instruction, form, CommandField_Zero);
        _BundleDataAttributesPresent = TRUE;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
