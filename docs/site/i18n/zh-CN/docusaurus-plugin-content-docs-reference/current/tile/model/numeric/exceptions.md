<!-- GENERATED FROM: asl/tile/model/numeric/exceptions.asl -->
# Exceptions

**Normative ASL source:** `asl/tile/model/numeric/exceptions.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-EXCEPTIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-exceptions-purpose role=purpose-scope -->
## 作用与范围

本单元不包含可执行 ASL。它唯一的内容是一条注释，说明 Tile 数值异常使用架构故障与数值分类契约。它依赖 Tile rounding 单元，而该单元同样只是一个指针。

请把本页当作一张地图阅读。它说明 Tile 操作的数值异常行为实际在何处定义。

<!-- PTO-READER-BLOCK: tile-model-numeric-exceptions-concepts role=concepts-state -->
## 概念与可见状态

在 PTO 中有两种不同的东西都被称为异常，必须把它们区分开。

- 数值状态标志记录发生过某个算术事件。五个标志是 NV（无效）、DZ（除以零）、OF（上溢）、UF（下溢）与 NX（不精确）。它们位于 `CORE_STATE[36:32]`，并且是粘滞的。
- 故障会停止一条指令。Tile 合法性问题产生 `Fault_TileLegality`；内存问题产生 `Fault_DataAlignment` 与 `Fault_DataPage` 等故障。

在 Tile 参考辅助函数中，标志集合是一个 `bits(5)` 值，使用的常量为 `0x01` NV、`0x02` DZ、`0x04` OF、`0x08` UF 与 `0x10` NX。

<!-- PTO-READER-BLOCK: tile-model-numeric-exceptions-rules role=rules-interactions -->
## 规则与交互

NaN 输入、上溢或除以零等数值特殊情况产生一个结果值和标志。在本目录的 Tile 数值辅助函数中，它们不产生故障；这些函数都不调用 `SetFault`。

`RecordNumericStatusFlags` 把一个标志集合按位或到粘滞状态中。例如，`TCVT` 在 `TileCommitConversionResult` 中、紧接发布之前调用它一次，传入所有元素标志的按位或。

设计要点：标志是粘滞位，而不是陷阱。`RecordNumericStatusFlags` 把新标志按位或到 `CORE_STATE[36:32]` 中，从不清除更早的标志（NDF `PTO-NUMERIC-STATUS-STICKY-001`），因此一个操作记录的标志在后续记录操作之后仍保持置位。

并非每个操作都记录其标志：例如，`ExecuteTileBinary` 丢弃数值标志，而 `ExecuteTileUnary` 会记录它们。请查看每个操作的归属单元。

<!-- PTO-READER-BLOCK: tile-model-numeric-exceptions-boundaries role=boundaries -->
## 架构边界

本单元不定义任何标志、故障或优先级规则。归属单元为：

- numeric status 单元拥有标志布局与粘滞更新。
- numeric classification 单元拥有 NaN、无穷、零、次正规数与无效编码类别。
- 每个数值辅助函数（例如 reference、TCVT、packed 与 E8M0 conversion 单元）拥有结果产生哪些标志。

<!-- PTO-READER-BLOCK: tile-model-numeric-exceptions-example role=example-usage -->
## 非规范阅读示例

以 RNE 且 `Sat` 为零执行从 FP32 到 FP16 的 `TCVT`，转换两个元素。

- 70000.0 大于 FP16 最大值 65504，因此该元素得到无穷 `0x7C00`，并带 OF 与 NX，标志为 `0x14`。
- 1.0 精确转换为 `0x3C00`，标志为 `0x00`。

TCVT 把它们按位或为 `0x14` 并记录一次。如果之前状态为 `0x01`，则变为 `0x15`。不会产生故障。

<!-- PTO-READER-BLOCK: tile-model-numeric-exceptions-related role=related-owners-navigation -->
## 相关归属

- [Numeric status](../../../arch/state/numeric-status.md) 拥有粘滞标志。
- [Numeric classification](../../../arch/data-types/numeric-classification.md) 拥有值类别。
- [Fault types](../../../arch/data-types/fault.md) 拥有故障码。
- [Rounding](rounding.md) 是舍入方面的配套指针。
- [Reference conversion](reference-conversion.md) 与 [formats](formats.md) 展示标志的产生与记录。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/exceptions.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-EXCEPTIONS","surface":"tile","classification":["model","numeric","exceptions"],"depends_on":["PTO-TILE-MODEL-NUMERIC-ROUNDING"]}
// Tile numeric exceptions use the architecture fault and numeric classification contracts.
```
<!-- GENERATED-ASL-END: unit -->
