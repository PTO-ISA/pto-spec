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

PTO 是一种 64 位指令集架构：常量 `PTO_XLEN` 为 `64`，因此每个标量寄存器和每个 `Word` 都是 64 位宽。PTO 组合了三类指令表面：标量指令、块（指令束）指令和直接 Tile 操作，它们全部更新同一组架构可见状态。

本页是入口页。它固定五项顶层契约：谁拥有架构语义、哪些状态可见、完成与内存事件如何定义、Tile 容量如何划分，以及什么使一个发布候选有效。指令行为本身由各指令的 ASL 所有者定义。

架构版本不写在 ASL 中。它是记录在 `specification.toml` 的 `[release].architecture_version` 下的发布版本，因此规范 ASL 保持与版本无关。

<!-- PTO-READER-BLOCK: arch-overview-concepts-state role=concepts-state -->
## 概念与可见状态

架构可见状态恰好是下面列出的十三个具名状态所有者组成的封闭集合。每个 ID 指向一个 ASL 状态单元及其拥有的变量。

- 标量与控制状态包括 `PTO-STATE-ARCH-GPR`、`PTO-STATE-ARCH-TEMPORARY-QUEUES`、`PTO-STATE-ARCH-PROGRAM-CONTROL` 和 `PTO-STATE-ARCH-FAULT`。
- 系统状态包括 `PTO-STATE-ARCH-MEMORY`、`PTO-STATE-ARCH-MAINTENANCE`、`PTO-STATE-ARCH-SYSTEM-REGISTERS`、`PTO-STATE-ARCH-EXTENDED-SYSTEM-REGISTERS`、`PTO-STATE-ARCH-TRAP-CONTEXT` 和 `PTO-STATE-ARCH-GQM`。
- Tile 与指令束执行在这个封闭集合中加入 `PTO-STATE-TILE-LOCAL`、`PTO-STATE-TILE-SHARED` 和 `PTO-STATE-BLOCK-CONTROL`。

设计要点：这个集合是封闭的，每个成员只能通过其状态单元拥有的、已接受的 ASL 状态转换发生变化。实现使用的任何其他存储，例如流水线缓冲或实现缓存，都不是架构可见的，因此正确的程序无法观察或依赖它们。

<!-- PTO-READER-BLOCK: arch-overview-rules-interactions role=rules-interactions -->
## 规则与交互

当前架构语义由指令助记符 ASL 或架构 ASL 拥有。目录和 Markdown 页面（包括本阅读指南）只是确定性的投影或证据，并不是替代性的语义所有者。

设计要点：每项事实只有一个语义所有者。如果某个目录行或某句 Markdown 与 ASL 不一致，以 ASL 为准，需要修正的是投影。这可以防止生成的表格和页面漂移成第二套相互冲突的定义。

被接受的指令完成以及架构可见内存事件，由可达的 ASL 分派、完成和内存事件所有者定义。想知道一条指令何时完成、产生了哪些内存事件的读者，应沿这些所有者查找，而不是依赖指令页面的摘要。

<!-- PTO-READER-BLOCK: arch-overview-boundaries role=boundaries -->
## 架构边界

Tile 存储有两个相互独立的容量池。每个 PE 各有自己的 `256 KiB` Local 池，Core 另有一个独立的 `256 KiB` Shared 池。一个 `B.IOT` SizeCode 描述一个被选中 PE 的 Local 分配，只能选择 `128 B..64 KiB`；同一 PE 上的多个 Local 对象可以共同使用该 PE 的池。一个 `B.IOS` SizeCode 描述一项完整的、覆盖整个 Core 的 Shared 分配。

设计要点：Local 与 Shared 分配不得消耗同一个合并预算。因此 Shared 分配永远不会减少任何 PE 上可用的 Local 容量，Local 分配也不会减少 Shared 池。程序可以分别规划其 Local 工作集和 Shared 数据的大小。

只有作为一个确切提交、并通过固定版本的 ASL 模型、每一个独立 AVS 结果、覆盖率、投影和发布证据检查时，发布候选才有效。

<!-- PTO-READER-BLOCK: arch-overview-example-usage role=example-usage -->
## 非规范阅读示例

面对状态变化问题时，先在上面的封闭列表中找到状态 ID，再沿该 ID 定位其 ASL 所有者以及写入该状态的状态转换。使用生成页面阅读所有者，并且只用 AVS 确认建模的状态转换已经被执行。

面对容量问题时，一个 SizeCode 为 `10`（`64 KiB`）且选中全部四个 PE 的 `B.IOT` 目标，会在每个被选中 PE 的 Local 池中使用 `64 KiB`。它不使用 Shared 池的任何容量。

面对发布问题时，应把所有结果与同一个不可变提交对比。来自其他提交的通过结果不能证明 `PTO-RELEASE-VERIFICATION` 所描述的候选版本。

<!-- PTO-READER-BLOCK: arch-overview-related-owners role=related-owners-navigation -->
## 相关所有者

- [执行上下文](../programming-model/execution-context.md)列出主要架构状态和临时队列操作。
- [Tile 分配](../features/tile-allocation.md)声明容量契约背后的单元大小、池大小和单对象上限。
- [内存排序](../memory-model/ordering.md)定义用于接受或拒绝保留 Store-to-Store 顺序的 PTO-RC 候选执行的事件关系。
- [陷阱上下文](../state/trap-context.md)与[标量浮点](../../scalar/model/fsu/scalar-fp.md)提供确定性的钩子实现。
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

// The architecture identity is the release architecture version owned by
// specification.toml ([release].architecture_version). Normative ASL remains
// release-version neutral, so this unit declares no version literal.
constant PTO_XLEN = 64;
```
<!-- GENERATED-ASL-END: unit -->
