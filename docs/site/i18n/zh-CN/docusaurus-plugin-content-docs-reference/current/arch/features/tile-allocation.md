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

本单元固定 PTO 推理 Local 与 Shared Tile 分配时使用的容量和模型参数，并把架构容量常量与 ASL 验证边界区分开。

<!-- PTO-READER-BLOCK: arch-tile-allocation-concepts role=concepts-state -->
## 容量模型

- 一个 Tile 单元为 `128` 字节，每个池包含 `2048` 个单元，因此容量为 `262144` 字节。
- 每个 PE 都有独立的 Local 池；Core 另有一个独立的 Shared 池。
- `PTO_RESERVATION_GRANULE_BYTES` 为 `64`，而指令束提供 `3` 个维度、`32` 个标量绑定和 `16` 个 Tile 绑定。

<!-- PTO-READER-BLOCK: arch-tile-allocation-rules role=rules-interactions -->
## 规则与交互

Local 与 Shared 分配消耗不同的预算。`PTO_TILE_MAX_ALLOCATION_BYTES` 把单个 Local 对象限制为 `65536` 字节，`PTO_SHARED_TILE_MAX_ALLOCATION_BYTES` 则允许单个 Shared 对象达到 `262144` 字节。独立的 `PTO_TILE_CAPACITY_BYTES` 仍把每个 PE 的 Local 总池容量保持为 `262144` 字节。

<!-- PTO-READER-BLOCK: arch-tile-allocation-boundaries role=boundaries -->
## 模型边界

`PTO_MODEL_TILE_ELEMENTS` 默认是 `32768`，使可执行模型能够承载所需的最大规模验证样例。`PTO_MODEL_MEMORY_BYTES` 在声明的 `256` 到 `65536` 范围内默认取 `4096`。这些静态 ASL 边界属于验证配置，不是通用载荷、配置档或实现限制。

<!-- PTO-READER-BLOCK: arch-tile-allocation-example role=example-usage -->
## 非规范容量示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-tile-allocation-related role=related-owners-navigation -->
## 相关所有者

- `PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY` 定义独立容量池所假设的拓扑。
- 分配指令和 Tile 状态所有者把这些常量应用到具体状态转换。
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
// NDF-BEGIN: PTO-ARCH-LOCAL-VTAG-LIFETIME-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// A Local virtual generation identity, its descriptor, epoch, hand, and
// relative-order entry MUST remain valid when selected-PE payload capacity is
// consumed. Consumption MUST make later payload use by those PEs fault
// TileLegality without skipping to another generation or rehydrating backing.
// Physical CELL reclamation MAY occur only after every reader, alias owner,
// and replay or checkpoint pin that can require the payload has completed;
// reclamation latency is not architecturally observable.
// NDF-END: PTO-ARCH-LOCAL-VTAG-LIFETIME-001
// NDF-BEGIN: PTO-ARCH-SHARED-VTAG-LIFETIME-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// A successful B.IOS last-use source MUST consume the complete Core-wide
// payload of the exact Sx generation it read, while retaining Sx identity,
// generation, and descriptor. Consumed payload capacity MUST cease to count
// against the independent 256 KiB Shared pool. A later source of that
// generation MUST fault TileLegality before payload access; no physical
// backing may be rehydrated or confused with a newer generation. Fault,
// retry, squash, and zero-participation attempts MUST preserve lifetime.
// Physical reclamation MAY wait for readers, writers, aliases, and replay
// or checkpoint pins; its timing is not architecturally observable.
// An open Shared B.ASSEMBLE generation MUST hold its complete parent capacity
// until publication or abort. The per-Sx charge is the greater of its old
// live payload and open-generation reservation, not their sum, so same-size
// replacement remains legal at a full pool while last-use cannot let a
// competing Sx steal the pending generation's capacity.
// NDF-END: PTO-ARCH-SHARED-VTAG-LIFETIME-001
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
