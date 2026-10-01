<!-- GENERATED FROM: asl/block/model/schema/dimensions.asl -->
# Dimensions

**Normative ASL source:** `asl/block/model/schema/dimensions.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-schema-dimensions-purpose role=purpose-scope -->
## 用途与范围

本单元定义 `SetBundleDimension`，即三个指令束局部维度寄存器 `LB0`、`LB1` 和 `LB2` 的写入器。`B.DIM` 和压缩形式 `C.B.DIMI` 都使用它。

其契约 `PTO-BUNDLE-DIMENSION-DEFAULT-001` 还定义了缺省维度的取值。

<!-- PTO-READER-BLOCK: block-model-schema-dimensions-concepts role=concepts-state -->
## 概念与可见状态

每个维度在 `_BundleDimensions` 中有一个值，在 `_BundleDimensionPresent` 中有一个存在位。每个指令束开始时，每个值都为 1，每个存在位都为 false。

`B.DIM` 写入 `GPR[RegSrc] + uimm17` 的低 16 位，并做零扩展。`C.B.DIMI` 写入其零扩展的 8 位立即数。

<!-- PTO-READER-BLOCK: block-model-schema-dimensions-rules role=rules-interactions -->
## 规则与交互

对存在位已置位的维度再次写入会引发 `Fault_BundleControl`，并保留第一个值。否则置位存在位并保存该值。

对于在活动指令束头部之外的维度写入，命令分派器也会引发 `Fault_BundleControl`。

设计要点：缺省维度的有效值为 1，显式写入（包括 0）会替换它。指令束可以不写未使用的维度，而写入 0 的程序得到的是 0，不是默认值。

设计要点：契约说明，存在位用于一次写入和恢复记录，操作消费的是有效值。当前的 Tile schema 在特定情况下也会读取存在位：缺省的 `LB2` 会选择有效列数作为物理列数，并且 `TCI` 和 `TEXPDIF` 拒绝缺省的 `LB0`。确切规则由操作 schema 单元给出。

设计要点：每个维度在每个指令束中只能写入一次。`B.DIM` 和 `C.B.DIMI` 为每个寄存器共用一个存在位，因此任一形式的第二次写入都会被拒绝，而不是静默覆盖第一次写入。

<!-- PTO-READER-BLOCK: block-model-schema-dimensions-boundaries role=boundaries -->
## 架构边界

本单元不赋予维度任何含义。由完成的操作 schema 决定 `LB0` 是行数、列数，还是 M、N 或 K 范围。

维度值在每次提交时被清除，不会带入下一个指令束。

<!-- PTO-READER-BLOCK: block-model-schema-dimensions-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0 = 0x10010` 时，`B.DIM a0, 16, ->LB0` 计算出 `0x10020` 并保留低 16 位，因此 `LB0` 变为 `0x0020`，即 32。`LB1` 和 `LB2` 保持为 1。同一头部中之后对 `LB0` 的 `C.B.DIMI` 会引发 `Fault_BundleControl`。

<!-- PTO-READER-BLOCK: block-model-schema-dimensions-related role=related-owners-navigation -->
## 相关所有者

- [B.DIM](../../attributes/B.DIM.md) 和 [C.B.DIMI](../../attributes/C.B.DIMI.md) 是指令页面。
- [描述符状态](../state/descriptor-state.md)设置默认值 1。
- [命令分派](../dispatch/commands.md)计算写入值并检查放置位置。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/schema/dimensions.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS","surface":"block","classification":["model","schema","dimensions"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-RESET"]}
// NDF-BEGIN: PTO-BUNDLE-DIMENSION-DEFAULT-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Each omitted bundle dimension MUST have effective value one. An explicit
// B.DIM or C.B.DIMI write, including zero, MUST replace that default value.
// Presence state MUST be used only for write-once and recovery bookkeeping;
// operation legality and execution MUST consume the effective dimension value.
// NDF-END: PTO-BUNDLE-DIMENSION-DEFAULT-001
func SetBundleDimension(index: BundleDimensionIndex, value: Word)
begin
    if _BundleDimensionPresent[[index]] then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        _BundleDimensionPresent[[index]] = TRUE;
        _BundleDimensions[[index]] = value;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
