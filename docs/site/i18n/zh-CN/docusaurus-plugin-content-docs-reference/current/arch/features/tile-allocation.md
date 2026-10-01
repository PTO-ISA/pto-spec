<!-- GENERATED FROM: asl/arch/features/tile-allocation.asl -->
# Tile Allocation

**Normative ASL source:** `asl/arch/features/tile-allocation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-TILE-ALLOCATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-tile-allocation-purpose role=purpose-scope -->
## 用途与范围

本单元声明 Tile 分配所读取的容量模型。其 ASL 全文为 `11` 个 `constant` 声明与 `2` 个 `config` 声明，没有函数、没有状态变量、没有故障、也没有可执行的状态转换。

第 1 行记录归类 `features/tile-allocation` 与 `depends_on` `PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY`，它定义独立容量池所假设的每 PE 拓扑。

Design point: 池容量与单个对象上限是两个独立常量，所以“池已满”和“单个对象过大”是两种彼此独立的拒绝：`PTO_TILE_MAX_ALLOCATION_BYTES` 限制单个 Local 对象，而 `PTO_TILE_CAPACITY_BYTES` 限制 Local 池的总量。

<!-- PTO-READER-BLOCK: arch-tile-allocation-concepts role=concepts-state -->
## 常量与配置

- `PTO_TILE_CELL_BYTES` 为 `128`，`PTO_TILE_CELL_COUNT` 为 `2048`，因此 `PTO_TILE_CAPACITY_BYTES` 为 `262144` 字节。
- `PTO_TILE_MAX_ALLOCATION_BYTES` 把单个 Local 对象限制为 `65536` 字节，即 `512` 个单元；`PTO_SHARED_TILE_MAX_ALLOCATION_BYTES` 把单个 Shared 对象限制为 `262144` 字节，即整个 Shared 池；而 `PTO_MODEL_MAX_TILE_CAPACITY_BYTES` 定义为 `PTO_TILE_CAPACITY_BYTES`。
- `PTO_RESERVATION_GRANULE_BYTES` 为 `64`，即半个单元；计数类常量为 `PTO_BUNDLE_DIMENSION_COUNT` `3`、`PTO_BUNDLE_SCALAR_BINDING_COUNT` `32`、`PTO_BUNDLE_TILE_BINDING_COUNT` `16`、`PTO_TILE_BASE_COUNT` `6`。
- `PTO_MODEL_TILE_ELEMENTS` 是声明范围为 `1` 到 `32768`、默认为 `32768` 的 `config`；`PTO_MODEL_MEMORY_BYTES` 是声明范围为 `256` 到 `65536`、默认为 `4096` 的 `config`。

Design point: 这两个 `config` 值是模型边界，不是架构数值。注释从 `262144` 字节 Shared 边界的 `S63` 验证样例推导出 `32768` 默认值。

<!-- PTO-READER-BLOCK: arch-tile-allocation-rules role=rules-interactions -->
## 规则与交互

两者都不是合并预算：Local 池与 Shared 池保持彼此独立。

Design point: Local 对象上限正好是 Local 池的四分之一，因为 `65536` 乘以 `4` 等于 `262144`。四个最大 Local 对象正好填满一个 PE 的池；第五个会因总量预算被拒绝，即使它自身的容量合法。Shared 对象上限等于其池容量。

<!-- PTO-READER-BLOCK: arch-tile-allocation-boundaries role=boundaries -->
## 模型边界

Design point: 关于 `PTO_MODEL_TILE_ELEMENTS` 的注释说明：ASL 数组需要静态边界，该模型需要 `32768` 个元素槽来承载 `262144` 字节 Shared 边界的 `S63` 验证样例，并且这是模型边界，而不是声称每个载荷都使用这么多元素。超出该模型边界的载荷属于模型限制，而不是架构拒绝。

同一条注释还提示有界调用方为整 Tile 步骤设置合适的单步超时。本文件不含 `NDF-BEGIN` 子句；已接受的每 PE 容量子句 `PTO-TILE-CAPACITY-PER-PE` 位于 `asl/arch/overview/architecture.asl`：Local 分配是某个被选中 PE 在其独立 256 KiB 池中的份额，Shared 分配是独立 256 KiB Shared 池中的一次完整 Core 级分配，两者不得消耗同一个合并预算。

<!-- PTO-READER-BLOCK: arch-tile-allocation-example role=example-usage -->
## 非规范容量示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

处于 `65536` 字节上限的 Local 对象占用一个 PE `2048` 个单元中的 `512` 个。四个这样的对象正好填满总池；第五个被拒绝，因为 `5` 乘以 `65536` 超过 `262144`，而不是因为它自身的容量非法。

一个 Shared 对象可以占 `262144` 字节，同时两个 Local 对象各占 `65536` 字节：Local 合计为 `131072`，对应 Local 池；Shared 合计为 `262144`，对应 Shared 池，两个合计都不会计入另一个池。

Design point: 由于两个池彼此独立且大小相同，可以同时持有一个最大 Shared 对象和每个被选中 PE 的四个最大 Local 对象；在 Local 一侧，起约束作用的是单对象上限，而不是单元数量。

<!-- PTO-READER-BLOCK: arch-tile-allocation-related role=related-owners-navigation -->
## 相关归属单元

- `PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY` 是声明的依赖。
- Tile 状态所有者应用这些常量：例如 `asl/tile/model/state/descriptors.asl` 把 Local 容量限制为不超过 `PTO_TILE_MAX_ALLOCATION_BYTES` 的整数个 `128` 字节单元；`asl/tile/model/capacity/shared.asl` 返回 `PTO_SHARED_TILE_MAX_ALLOCATION_BYTES`。
- `asl/tile/model/capacity/local.asl` 用 `PTO_MODEL_MAX_TILE_CAPACITY_BYTES` 限制在用的 Local 预算，该值也是 `tile_capacity` 系统寄存器的上限；标量原子单元以 `PTO_RESERVATION_GRANULE_BYTES` 作为其保留粒度。
- `PTO-TILE-CAPACITY-PER-PE` 由 `asl/arch/overview/architecture.asl` 拥有，而不是本单元。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/tile-allocation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-TILE-ALLOCATION","surface":"arch","classification":["features","tile-allocation"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY"]}
// Every PE owns an independent 2048-cell Local pool; one Local object
// is capped at 64 KiB. Multiple Local objects may consume the aggregate pool.
// The Core also owns one
// independent 2048-cell Shared pool.  Local and Shared allocations do not
// compete for one combined capacity budget.
constant PTO_TILE_CELL_BYTES = 128;
constant PTO_TILE_CELL_COUNT = 2048;
constant PTO_TILE_CAPACITY_BYTES = 262144;
constant PTO_TILE_MAX_ALLOCATION_BYTES = 65536;
constant PTO_SHARED_TILE_MAX_ALLOCATION_BYTES = 262144;
constant PTO_MODEL_MAX_TILE_CAPACITY_BYTES = PTO_TILE_CAPACITY_BYTES;
constant PTO_RESERVATION_GRANULE_BYTES = 64;
constant PTO_BUNDLE_DIMENSION_COUNT = 3;
constant PTO_BUNDLE_SCALAR_BINDING_COUNT = 32;
constant PTO_BUNDLE_TILE_BINDING_COUNT = 16;
constant PTO_TILE_BASE_COUNT = 6;

// ASL arrays require static bounds. The executable model uses S63 witnesses
// for the 256 KiB Shared boundary, requiring 32,768 element slots. This is a
// model bound, not a claim that every payload uses that many architectural
// elements.
//
// Performance bound (issue #287): with the pinned ASLRef interpreter every
// whole-tile operation step moves the full 32,768-element payload and its
// definedness bitmap regardless of the valid region, measured at roughly
// 4 s per step (3.8-4.0 s per PE on a 4-PE BSTART.TSTORE, 2026-09). Callers
// running bounded ELF consistency checks should size per-step timeouts
// accordingly (for example --timeout-s 600 for 4-PE runs). Implementations
// may accelerate the payload path by sparse indexing, vectorization, or
// equivalent means provided observable semantics are unchanged.
config PTO_MODEL_TILE_ELEMENTS : integer {1..32768} = 32768;
config PTO_MODEL_MEMORY_BYTES : integer {256..65536} = 4096;
```
<!-- GENERATED-ASL-END: unit -->
