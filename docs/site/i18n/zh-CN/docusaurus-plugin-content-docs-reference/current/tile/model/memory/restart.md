<!-- GENERATED FROM: asl/tile/model/memory/restart.asl -->
# Restart

**Normative ASL source:** `asl/tile/model/memory/restart.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-RESTART}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-restart-purpose role=purpose-scope -->
## 作用与范围

本单元不包含可执行 ASL。它唯一的内容是一条注释，说明重启与精确故障行为由内存操作以及架构故障模型拥有。

它作为导航点存在。其依赖项指明了两个真正的归属单元：Tile atomics 单元，以及架构故障精确性单元 `PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION`。

<!-- PTO-READER-BLOCK: tile-model-memory-restart-concepts role=concepts-state -->
## 概念与可见状态

本单元不声明任何状态。与重启相关的状态位于其他地方：

- 故障精确性单元中的 `_MemoryReplayState` 记录重放窗口是否活动、它所属的请求，以及已提交的内存事件数量。
- `SetFault` 把故障码记录在 `_LastFault` 中，把故障地址记录在 `_FaultAddress` 中，并为目标 ring 保存陷阱上下文。

精确故障是指：较早的效果保留，发生故障的请求是重启点，较晚的工作没有架构效果。

<!-- PTO-READER-BLOCK: tile-model-memory-restart-rules role=rules-interactions -->
## 规则与交互

Tile 内存执行体遵循两种重启模式。

- 首故障即停：Local `TLOAD` 与 `TSTORE`，以及 Shared 转移辅助函数，逐元素访问，并在第一次探测失败时停止。已经完成的效果保持可见。
- 先全部探测：`MGATHER`、`MSCATTER` 及其 MASK 形式、`MGATHER_CAS`、GM atom/red 族以及 `TPREFETCHCore`，在第一次内存访问或事件之前探测每个活动地址。该阶段的故障使 GM 与内存事件保持不变。

设计要点：故障精确性契约规定，重试发生故障的 Tile 内存请求会重新执行整个逻辑请求，并且从不把内部通道或游标暴露为架构状态。对软件而言，其结果是处理程序修复原因（例如映射页面）后返回同一请求；它不能从中间继续。

设计要点：重放冲刷从不回滚已提交的 GM 写入或 Tile 载荷元素。因此对首故障即停的操作，重试可能第二次写入相同的 GM 位置。对先全部探测的操作，故障尝试中没有发生任何访问，因此重试从未改变的内存开始。

<!-- PTO-READER-BLOCK: tile-model-memory-restart-boundaries role=boundaries -->
## 架构边界

本单元不增加任何自己的规则。如果此处的表述与归属单元不一致，以归属单元为准：

- 故障精确性单元拥有重放记录与冲刷规则。
- 每个内存执行体拥有它在何处探测、在何处停止。
- 块故障与回滚单元拥有故障后对指令束所分配目标的释放。

<!-- PTO-READER-BLOCK: tile-model-memory-restart-example role=example-usage -->
## 非规范阅读示例

对 2 x 4 有效区域的 U32 `TSTORE` 按行主序写入 8 个元素。假设元素 `(1, 2)`（第七个元素）位于未映射页面上。

- 元素 `(0, 0)` 到 `(1, 1)` 被写入，共 6 x 4 = 24 字节，其事件已提交。
- `(1, 2)` 的探测以 `Fault_DataPage` 失败，`(1, 3)` 不会被尝试。
- 页面映射之后，重试会再次写入全部 8 个元素。

同样的故障在 U32 `MSCATTER` 中会在探测阶段被发现，因此在故障之前其 8 个通道都没有被写入。

<!-- PTO-READER-BLOCK: tile-model-memory-restart-related role=related-owners-navigation -->
## 相关归属

- [Fault precision](../../../arch/memory-model/fault-precision.md) 拥有重放记录与重启契约。
- [Load and store](load-store.md) 展示首故障即停模式。
- [Gather and scatter](gather-scatter.md) 与 [Atomics](atomics.md) 展示先全部探测模式。
- [Block fault rollback](../../../block/model/faults/rollback.md) 拥有故障后的目标释放。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/restart.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-RESTART","surface":"tile","classification":["model","memory","restart"],"depends_on":["PTO-TILE-MODEL-MEMORY-ATOMICS","PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION"]}
// Restart and precise-fault behavior is owned by the memory operations and architecture fault model.
```
<!-- GENERATED-ASL-END: unit -->
