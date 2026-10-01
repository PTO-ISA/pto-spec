<!-- GENERATED FROM: asl/block/model/dispatch/numeric-control.asl -->
# Numeric Control

**Normative ASL source:** `asl/block/model/dispatch/numeric-control.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-NUMERIC-CONTROL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-numeric-control-purpose role=purpose-scope -->
## 用途与范围

本单元把指令束的舍入与饱和请求转换为数值操作实际使用的具体控制。请求来自 `B.DATR` 的 `RMode` 和 `Sat` 字段。结果是一个 `NumericExecutionControl` 记录，含两个字段：`rounding_mode` 和 `saturating`。

本单元只有一个函数 `ResolveTileNumericExecutionControl`。它接收已解码的操作索引和已解码的 `TileInstructionOperands`。

<!-- PTO-READER-BLOCK: block-model-dispatch-numeric-control-concepts role=concepts-state -->
## 概念与可见状态

输入是 `operands.numeric_control`，这是由 `BundleTileInstructionOperands` 构造的 `TileNumericSelection`。该构造函数对三位 `RMode` 字段调用 `DecodeBundleRoundingSelection`，并把 `Sat` 复制到 `saturating`。

`RMode` 代码的映射如下。

| `RMode` | 含义 |
| --- | --- |
| `000` | 操作默认值；`use_operation_default` 为 true |
| `001` | `RNE`，就近舍入，平局取偶 |
| `010` 至 `111` | `RTZ`、`RTM`、`RTP`、`RNA`、`RTO` 和 `RHB` |

该函数只读取状态。在 `TCVT` 情形下，它读取 `_Tiles` 中源 Tile 和目标 Tile 的 `data_type`。它不写任何内容，也不引发故障。

<!-- PTO-READER-BLOCK: block-model-dispatch-numeric-control-rules role=rules-interactions -->
## 规则与交互

该函数从选择中复制 `rounding_mode` 和 `saturating`。然后，如果 `use_operation_default` 为 true，就替换舍入模式。

- 对于源为浮点、目标为非浮点的 `TCVT`，默认值为 `RTZ`。
- 其他所有情形的默认值为 `RNE`。

饱和从不被改变。它恰好就是 `Sat` 位，`B.DATR` 缺省时为 false。

当前 ASL 中有两个调用者。生成的 Tile 分派函数 `ExecuteTileInstructionWithoutTimeWithAcceptedApplicabilityRules` 为每个已解码的 Tile 操作解析一次该控制，并把它传给接收 `numeric_control` 的处理函数，例如 `TCVT`；`MatrixPostProcessResult` 为 CUBE 矩阵操作解析该控制，并传给每个结果元素的后处理。两者都在执行期间运行，即预检成功且目标已解析之后。

设计要点：`RMode` 为零表示“使用本操作的默认值”，而不是某个特定舍入模式。代码 `001` 显式指定 `RNE`。因此程序可以为一个自身默认值为 `RTZ` 的转换选择 `RNE`。省略 `B.DATR` 时该字段保持为零，所以省略与显式 `000` 结果相同。

设计要点：浮点值转换为整数类型时，`TCVT` 的默认值向零截断，其他情形则就近舍入、平局取偶；`TCVT` 所有者中的 `InstructionContractDefaultRounding_TCVT` 也给出同一规则。在当前类型枚举中，每种类型要么是浮点要么是整数，因此“非浮点目标”与“整数目标”选中的类型对相同。

<!-- PTO-READER-BLOCK: block-model-dispatch-numeric-control-boundaries role=boundaries -->
## 架构边界

本单元不解码 `B.DATR`，不检查某个舍入模式对某类型对是否受支持，也不执行任何舍入。`TCVT` schema 所有者在预检期间按硬件配置档检查解析后的模式，并使用它自己的一份 `RNE` 默认规则。数值参考所有者负责应用该模式。

并非每个 `B.DATR` 字段在每个操作中都有数值含义。例如，行扩展页面说明，对 CUBE 布局上的 `TROWEXPANDEXPDIF`，`RMode` 表示 `BroadcastByteOffset`。

<!-- PTO-READER-BLOCK: block-model-dispatch-numeric-control-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个输入为 FP16 的 `BSTART.TMATMUL` 指令束携带 `RMode` 为 `000`、`Sat` 为 `1` 的 `B.DATR`，以及 `PreQuantMode` 非零且不是移位模式的 `B.FPATR`，因此 `Sat` `1` 合法。选择中的 `use_operation_default` 为 true，因此函数返回 `rounding_mode` `RNE` 和 `saturating` true。随后后处理把该控制交给 `MatrixFPATREffectiveControl`，它对大多数代码保持 `RNE`，但对 `PreQuantMode` 25 和 28 改用 `RHB`。

如果 `RMode` 改为 `010`，函数不查看操作，直接返回 `RTZ`。只有当 `PreQuantMode` 不是固定舍入代码时该指令束才合法，因为 `BundleFPATRDATRFieldsLegal` 对这些代码要求 `RMode` 为 `000`。

<!-- PTO-READER-BLOCK: block-model-dispatch-numeric-control-related role=related-owners-navigation -->
## 相关所有者

- [Tile 指令操作数](tile-instruction-operands.md) 从 `B.DATR` 构造该选择。
- [矩阵后处理执行](../../../tile/model/execution/postprocess.md) 调用该函数。
- [舍入](../../../arch/data-types/rounding.md) 定义 `NumericExecutionControl` 与各舍入模式。
- [TCVT](../../../tile/elementwise-tile-tile/format-conversion/TCVT.md) 说明转换的默认值。
- [B.DATR](../../attributes/B.DATR.md) 承载 `RMode` 和 `Sat`。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/numeric-control.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-NUMERIC-CONTROL","surface":"block","classification":["model","dispatch","numeric-control"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA"]}
readonly func ResolveTileNumericExecutionControl(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    operands: TileInstructionOperands) => NumericExecutionControl
begin
    var result = NumericExecutionControl {
        rounding_mode = operands.numeric_control.rounding_mode,
        saturating = operands.numeric_control.saturating
    };
    if operands.numeric_control.use_operation_default then
        result.rounding_mode = NumericRound_RNE;
        if TileOperationOfIndex(operation) == TileOperation_TCVT &&
           TileDataTypeIsFloating(_Tiles[[operands.source0]].data_type) &&
           !TileDataTypeIsFloating(_Tiles[[operands.destination0]].data_type) then
            result.rounding_mode = NumericRound_RTZ;
        end;
    end;
    return result;
end;
```
<!-- GENERATED-ASL-END: unit -->
