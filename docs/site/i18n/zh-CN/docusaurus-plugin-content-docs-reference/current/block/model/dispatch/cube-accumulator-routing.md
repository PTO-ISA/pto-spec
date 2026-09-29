<!-- GENERATED FROM: asl/block/model/dispatch/cube-accumulator-routing.asl -->
# CUBE Accumulator Routing

**Normative ASL source:** `asl/block/model/dispatch/cube-accumulator-routing.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-CUBE-ACCUMULATOR-ROUTING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-cube-accumulator-routing-purpose role=purpose-scope -->
## 用途与范围

本单元读取并检查 `CCTRL`，即 CUBE 矩阵指令束（`TMATMUL` 与 `TGEMV` 族）的两位累加器控制。`CCTRL` 不是独立字段。它由数据属性命令 `B.DATR` 的 `PadValueOrByteId` 字段承载，矩阵与 CUBE 操作 schema 将该字段读作 `CCTRL`。

本单元有五个小函数。一个读取该字段，两个将其拆分为各个位，另外两个判断所选位对该指令束是否合法。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-accumulator-routing-concepts role=concepts-state -->
## 概念与可见状态

- `B.DATR` 存在时，`BundleTMATMULCCTRL` 返回 `_BundleDataAttributes.pad_value`；不存在时返回 `00`。
- `BundleTMATMULRawPartialOutput` 返回第 0 位。该位置位时，结果 `D` 是原始的累加器类型乘积，而不是经过后处理的最终输出。
- `BundleTMATMULAccumulatorPrefetchHint` 返回第 1 位。该位置位时，它请求实现预取或复用显式累加器源 `C`。

累加函数是 CUBE Function 2、6、18 和 22 之一（`TMATMUL_ACC`、`TMATMUL_MX_ACC`、`TGEMV_ACC` 和 `TGEMV_MX_ACC`），由 `TileMatrixFunctionUsesAccumulator` 定义。

这五个函数都只读取状态。它们都不写状态，也不引发故障。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-accumulator-routing-rules role=rules-interactions -->
## 规则与交互

对累加函数，`BundleTMATMULAccumulatorControlLegal` 允许任意 `CCTRL`。对其他所有函数，它要求第 1 位为零，因为不存在可预取的 `C` 源。

第 0 位清零时，`BundleTMATMULPartialPostProcessLegal` 允许任意取值。第 0 位置位时，`B.FPATR` 字段 `pre_quant_mode`、`relu_mode` 和 `group_n_code` 必须为零，`row_max_en`、`group_max_en` 和 `max_abs_en` 必须为 false。这里不检查 `c_scale_en`。

调用者是 `ExecuteBundleTMATMULOperation`。它在一次组合检查中同时计算这两个合法性谓词，以及类型、绑定、数据属性、维度和掩码检查。失败时引发 `Fault_TileLegality`。该检查在处理程序为操作转换 M、N、K 之前、等待 Shared 源之前，也在分配任何目标或快照任何源之前运行。

设计要点：省略不同于编码值。`B.DATR` 缺省时，存储的 `pad_value` 仍保持复位默认值 `11`，该值对其他操作选择 Null 填充。此时 `BundleTMATMULCCTRL` 不读取它，而是返回 `00`：最终输出且无提示。因此没有 `B.DATR` 的矩阵指令束永远不会意外请求原始部分输出。

设计要点：原始部分结果不得经过后处理。第 0 位置位时，结果由 `CommitMatrixRawPartial` 发布，它跳过 `MatrixPostProcessResult` 和所有辅助输出。合法性检查在任何效果之前拒绝量化、ReLU 以及行、组和 max-abs 归约，因此指令束无法请求一个会被静默忽略的后处理。

设计要点：这两个位所请求的缓存行为不能改变结果。调用者把它们传给 `TileProfileInternalAccumulatorPrefetchHint` 和 `TileProfileInternalAccumulatorReplacementHint`，这两个钩子由实现定义，在可移植模型中不做任何事。NDF 条款 `PTO-CUBE-INTERNAL-ACCUMULATOR-001` 要求缓存行为永远不改变结果、故障、分配或发布。第 0 位确实改变发布的类型；只有缓存使用是提示。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-accumulator-routing-boundaries role=boundaries -->
## 架构边界

本单元不解码 `B.DATR` 或 `B.FPATR`，不执行乘积，也不调用提示钩子。它不检查 `CScale`；该检查由矩阵缩放和 TMATMUL 所有者完成。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-accumulator-routing-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个 `BSTART.TMATMUL.ACC` 指令束（Function 2）的 A、B 为 FP16，携带一个 `PadValueOrByteId` 字段为 `11` 的 `B.DATR`，以及全零的 `B.FPATR`。两个位都合法：Function 2 执行累加，且未启用后处理。预检之后，模型可以提示预取 `C`。`D` 以原始 FP32 累加器结果发布，随后可以给出替换提示。

同样的 `CCTRL` 用在普通 `BSTART.TMATMUL` 指令束（Function 0）上会失败，因为第 1 位在没有累加器的函数上置位。该指令束引发 `Fault_TileLegality`，且不分配目标。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-accumulator-routing-related role=related-owners-navigation -->
## 相关所有者

- [CUBE TMATMUL](cube-tmatmul.md) 调用这些谓词和提示钩子。
- [内部累加器](../../../tile/model/execution/internal-accumulator.md) 定义提示钩子及其非约束性契约。
- [矩阵函数](../../../tile/model/legality/matrix-functions.md) 定义哪些函数执行累加。
- [B.DATR](../../attributes/B.DATR.md) 与 [B.FPATR](../../attributes/B.FPATR.md) 承载本单元读取的字段。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/cube-accumulator-routing.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-CUBE-ACCUMULATOR-ROUTING","surface":"block","classification":["model","dispatch","cube-accumulator-routing"],"depends_on":["PTO-BLOCK-B-DATR","PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS"]}

readonly func BundleTMATMULCCTRL() => bits(2)
begin
    if !_BundleDataAttributesPresent then return Zeros{2}; end;
    return _BundleDataAttributes.pad_value;
end;

pure func BundleTMATMULRawPartialOutput(cctrl: bits(2)) => boolean
begin
    return cctrl[0:0] != Zeros{1};
end;

pure func BundleTMATMULAccumulatorPrefetchHint(cctrl: bits(2)) => boolean
begin
    return cctrl[1:1] != Zeros{1};
end;

readonly func BundleTMATMULAccumulatorControlLegal(
    function: integer {0..31}, cctrl: bits(2)) => boolean
begin
    if TileMatrixFunctionUsesAccumulator(function) then return TRUE; end;
    return !BundleTMATMULAccumulatorPrefetchHint(cctrl);
end;

readonly func BundleTMATMULPartialPostProcessLegal(
    cctrl: bits(2)) => boolean
begin
    if !BundleTMATMULRawPartialOutput(cctrl) then return TRUE; end;
    return UInt(_BundleFixedPointAttributes.pre_quant_mode) == 0 &&
           UInt(_BundleFixedPointAttributes.relu_mode) == 0 &&
           UInt(_BundleFixedPointAttributes.group_n_code) == 0 &&
           !_BundleFixedPointAttributes.row_max_en &&
           !_BundleFixedPointAttributes.group_max_en &&
           !_BundleFixedPointAttributes.max_abs_en;
end;
```
<!-- GENERATED-ASL-END: unit -->
