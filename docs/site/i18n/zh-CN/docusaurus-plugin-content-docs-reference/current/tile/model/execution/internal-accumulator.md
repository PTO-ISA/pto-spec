<!-- GENERATED FROM: asl/tile/model/execution/internal-accumulator.asl -->
# Internal Accumulator

**Normative ASL source:** `asl/tile/model/execution/internal-accumulator.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-internal-accumulator-purpose role=purpose-scope -->
## 用途与范围

本单元规定 CUBE 内部累加器 InternalAcc 是一个透明的实现缓存。它包含一条 NDF 条款 `PTO-CUBE-INTERNAL-ACCUMULATOR-001` 和两个由实现定义的提示钩子。

本单元没有自己的可执行状态。两个钩子的函数体都为空（`pass`），因此可移植模型既不读取也不写入缓存载荷。

<!-- PTO-READER-BLOCK: tile-model-execution-internal-accumulator-concepts role=concepts-state -->
## 概念与可见状态

- InternalAcc 是实现可以保留的透明缓存。它不是架构状态。
- TileReg C 是 ACC 形式的显式累加器输入。TileReg D 是目标。
- CCTRL 是承载在 B.DATR PadValueOrByteId 字段中的两位矩阵控制。

两个钩子是 `TileProfileInternalAccumulatorPrefetchHint` 和 `TileProfileInternalAccumulatorReplacementHint`。每个钩子接收一个 Tile 索引和一个 0 到 262144 的字节数。

<!-- PTO-READER-BLOCK: tile-model-execution-internal-accumulator-rules role=rules-interactions -->
## 规则与交互

CUBE TMATMUL 分派中的 `ExecuteBundleTMATMULOperation` 是在 ASL 中找到的唯一调用者。当形式使用累加器且 CCTRL 位 1 置位时，它为 C 调用预取提示。该调用发生在操作数解析之后、乘积计算之前。

当 CCTRL 位 0 选择原始部分输出时，同一函数为 D 调用替换提示。该调用只在结果无故障发布之后发生。

NDF 条款要求 C 保持为架构累加器输入。它还要求每次成功操作都分配并发布 D。

设计要点：缓存命中、未命中、容量、驻留、替换和时序都不得改变结果、故障、分配、发布、源生命周期或顺序。因此无论实现是否采纳提示，程序得到的 D 都相同。

设计要点：即使实现在 InternalAcc 中保留副本，C 仍是显式 Tile 操作数。所用的值始终是 C 的架构值，CUBE 单元在写入 D 之前读取它。

<!-- PTO-READER-BLOCK: tile-model-execution-internal-accumulator-boundaries role=boundaries -->
## 架构边界

这些钩子是 `impdef` 函数。配置档可以为它们提供函数体，但条款禁止缓存行为改变结果、故障、分配、发布、源生命周期或顺序。

钩子不会跳过 D 的分配。原始部分输出仍以累加器类型分配并发布 D。

本单元不定义任何指令、字段或故障。

<!-- PTO-READER-BLOCK: tile-model-execution-internal-accumulator-example role=example-usage -->
## 非规范阅读示例

考虑两个累加到同一运行结果的 FP32 TMATMUL_ACC 操作。

1. 第一个操作把 CCTRL 设为 `01`。它发布原始部分 D1，随后模型为 D1 调用替换提示。
2. 第二个操作把 D1 指定为 C，并把 CCTRL 设为 `10`。模型在计算乘积之前为 D1 调用预取提示。
3. 第二个操作把 D1 作为 C 读取并发布新的 D2，与 CCTRL 为 `00` 时完全相同。

如果 D1 保存 21.0，新的乘积和为 8.0，则在任何情况下 D2 都保存 29.0。

<!-- PTO-READER-BLOCK: tile-model-execution-internal-accumulator-related role=related-owners-navigation -->
## 相关所有者

- [CUBE 执行](cube.md)拥有乘积、累加和原始部分提交。
- [矩阵缩放](matrix-scale.md)拥有从 C 读取的初始值。
- [CUBE TMATMUL 分派](../../../block/model/dispatch/cube-tmatmul.md)调用这两个钩子。
- [CUBE 累加器路由](../../../block/model/dispatch/cube-accumulator-routing.md)解码 CCTRL 位。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/internal-accumulator.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR","surface":"tile","classification":["model","execution","internal-accumulator"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE"]}

// NDF-BEGIN: PTO-CUBE-INTERNAL-ACCUMULATOR-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// InternalAcc MUST be a transparent implementation cache. Explicit TileReg C
// MUST remain the architectural accumulator input and explicit TileReg D MUST
// be allocated and published on every successful operation. CCTRL MAY provide
// non-binding input-prefetch and output-replacement hints, but cache hit, miss,
// capacity, residency, replacement, and timing MUST NOT change architectural
// results, faults, allocation, publication, source lifetime, or ordering.
// NDF-END: PTO-CUBE-INTERNAL-ACCUMULATOR-001

// These hooks are non-binding implementation hints. The portable model does
// not read or write cached payload and does not observe whether a hint is used.
impdef func TileProfileInternalAccumulatorPrefetchHint(
    source: TileIndex, required_bytes: integer {0..262144})
begin
    pass;
end;

impdef func TileProfileInternalAccumulatorReplacementHint(
    destination: TileIndex, required_bytes: integer {0..262144})
begin
    pass;
end;
```
<!-- GENERATED-ASL-END: unit -->
