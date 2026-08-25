<!-- GENERATED FROM: asl/arch/overview/architecture.asl -->
# Architecture

**Normative ASL source:** `asl/arch/overview/architecture.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-OVERVIEW-ARCHITECTURE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-overview-purpose-scope role=purpose-scope -->
## 用途与范围

PTO 在这里被定义为一种 64 位架构：`PTO_XLEN` 为 `64`，当前架构标识的版本为 `0`。

这个入口刻意保持精简。它建立顶层所有权、状态闭包、完成与事件、Tile 容量以及发布验证契约，同时把具体指令行为留给可达的 ASL 所有者。

<!-- PTO-READER-BLOCK: arch-overview-concepts-state role=concepts-state -->
## 概念与可见状态

架构可见状态恰好由下面列出的具名状态所有者组成一个封闭集合。

- 标量与控制状态包括 `PTO-STATE-ARCH-GPR`、`PTO-STATE-ARCH-TEMPORARY-QUEUES`、`PTO-STATE-ARCH-PROGRAM-CONTROL` 和 `PTO-STATE-ARCH-FAULT`。
- 系统状态包括 `PTO-STATE-ARCH-MEMORY`、`PTO-STATE-ARCH-MAINTENANCE`、`PTO-STATE-ARCH-SYSTEM-REGISTERS`、`PTO-STATE-ARCH-EXTENDED-SYSTEM-REGISTERS`、`PTO-STATE-ARCH-TRAP-CONTEXT` 和 `PTO-STATE-ARCH-GQM`。
- Tile 与指令束执行在这个封闭集合中加入 `PTO-STATE-TILE-LOCAL`、`PTO-STATE-TILE-SHARED` 和 `PTO-STATE-BLOCK-CONTROL`。

<!-- PTO-READER-BLOCK: arch-overview-rules-interactions role=rules-interactions -->
## 规则与交互

当前架构语意由指令助记符 ASL 或架构 ASL 拥有。目录和 Markdown 只是确定性的投影或证据，并不是替代性的语意所有者。

被接受的指令完成行为和架构可见内存事件，由可达的分派、完成和内存事件 ASL 所有者决定。

封闭状态集合中的每个成员，只能通过相应状态单元所拥有且已被接受的 ASL 状态转换发生变化。

<!-- PTO-READER-BLOCK: arch-overview-boundaries role=boundaries -->
## 架构边界

Local 与 Shared Tile 分配使用彼此独立的容量池。`B.IOT` 从某个 PE 自己的 `256 KiB` 池中选择该 PE 的一项 Local 分配，而 `B.IOS` 表示来自另一个 `256 KiB` 池、覆盖整个 Core 的一项 Shared 分配。

只有当候选版本对应的确切提交通过固定版本的 ASL 模型、全部独立 AVS 结果、覆盖率、投影和发布证据检查时，该候选版本才有效。

<!-- PTO-READER-BLOCK: arch-overview-example-usage role=example-usage -->
## 非规范阅读示例

面对状态变化问题时，先在上面的封闭列表中找到状态 ID，再沿该 ID 定位其 ASL 所有者以及写入该状态的状态转换。使用生成页面阅读所有者，并且只用 AVS 确认建模的状态转换已经被执行。

面对发布问题时，应把所有结果与同一个不可变提交对比。来自其他提交的通过结果不能证明 `PTO-RELEASE-VERIFICATION` 所描述的候选版本。

<!-- PTO-READER-BLOCK: arch-overview-related-owners role=related-owners-navigation -->
## 相关所有者

- [执行上下文](../programming-model/execution-context.md)列出主要架构状态和临时队列操作。
- [内存排序](../memory-model/ordering.md)定义用于接受或拒绝 PTO-TSO 候选执行的事件关系。
- [参考配置档](../profile/reference-profile.md)为配置档定义的钩子提供确定性实现。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/overview/architecture.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-OVERVIEW-ARCHITECTURE","surface":"arch","classification":["overview","architecture"],"depends_on":[]}
// PTO Instruction Set Architecture ASL1 entry point.
//
// The Makefile assembles the normative sources in dependency order. This file
// intentionally contains only the architecture identity and top-level contract.

// NDF-BEGIN: PTO-SOURCE-HIERARCHY
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Current architecture contracts MUST be owned by mnemonic or architecture ASL;
// catalogs and Markdown MUST remain deterministic projections or evidence.
// NDF-END: PTO-SOURCE-HIERARCHY

// NDF-BEGIN: PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Accepted instruction completion and its architecture-visible memory events
// MUST be defined by the reachable ASL dispatch, completion, and memory-event owners.
// NDF-END: PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001

// NDF-BEGIN: PTO-ARCH-STATE-CLOSURE-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Architecture-visible state MUST be exactly [[PTO-STATE-ARCH-GPR]],
// [[PTO-STATE-ARCH-TEMPORARY-QUEUES]], [[PTO-STATE-ARCH-PROGRAM-CONTROL]],
// [[PTO-STATE-ARCH-FAULT]], [[PTO-STATE-ARCH-MEMORY]],
// [[PTO-STATE-ARCH-MAINTENANCE]], [[PTO-STATE-ARCH-SYSTEM-REGISTERS]],
// [[PTO-STATE-ARCH-EXTENDED-SYSTEM-REGISTERS]],
// [[PTO-STATE-ARCH-TRAP-CONTEXT]], [[PTO-STATE-TILE-LOCAL]],
// [[PTO-STATE-TILE-SHARED]], [[PTO-STATE-ARCH-GQM]], and
// [[PTO-STATE-BLOCK-CONTROL]], and MUST change only through the accepted ASL
// transitions owned by those state units.
// NDF-END: PTO-ARCH-STATE-CLOSURE-001

// NDF-BEGIN: PTO-TILE-CAPACITY-PER-PE
// ndf: kind=contract level=L1 layer=tile status=accepted
// B.IOT SizeCode MUST denote one selected PE's Local allocation in that PE's
// independent 256 KiB pool. B.IOS SizeCode MUST denote one complete Core-wide
// Shared allocation in the independent 256 KiB Shared pool. Local and Shared
// allocations MUST NOT consume one combined budget.
// NDF-END: PTO-TILE-CAPACITY-PER-PE

// NDF-BEGIN: PTO-RELEASE-VERIFICATION
// ndf: kind=mechanism level=L2 layer=architecture status=accepted
// A release candidate MUST be the exact commit that passes the pinned ASL model,
// every independent AVS result, coverage, projections, and release-evidence checks.
// NDF-END: PTO-RELEASE-VERIFICATION

constant PTO_ARCHITECTURE_VERSION = 0;
constant PTO_XLEN = 64;
```
<!-- GENERATED-ASL-END: unit -->
