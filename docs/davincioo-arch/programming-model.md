---
{
  "schema_version": 1,
  "id": "overview.programming_model",
  "kind": "overview",
  "title": "Programming Model",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "PROGRAMMING_MODEL.md"
  }
}
---
# Programming Model

## Program Instance and Execution

一个程序实例覆盖一个 Core 内的 PE0–PE3。四个 PE 执行同一份程序映像，各自拥有独立 PC 和固定 `thread_id`。`thread_id` 等于只读 [PEID SSR](../instructions/scalar/register/ssr/PEID.md) 的低 2 bit，PE0–PE3 分别读取到 `0..3`；高位恒为零。普通独立区域允许分歧；collective 区域必须能静态证明收敛，并以相同动态顺序执行 collective 指令。

编译器提供以下源级接口，并固定降低为现有 32-bit `SSRGET`，不新增独立 opcode：

```cpp
uint32_t get_thread_id();
// ssrget 0x0802, ->Rd
```

`PEID` 在一个程序实例期间不可变。编译器可以将其取值范围视为 `[0,3]`，但同一份 SPMD binary 中不能把它全局常量折叠成某一个 PE 的编号。

## Tiles, Fragments, and Distribution

Storage 与 distribution 独立。Local/Shared 描述存储位置；LinearShard4、AxisShard4、MShard4 等描述 logical coordinate 到 PE fragment 的映射。cooperative TMATMUL 的 A/C/D 与 max result 使用 MShard4；Shared A 不是 broadcast，PE p 读取 A[p]。

## Scope and Control Flow

大多数 API 不暴露 scope template。Local Matrix 由 PE_MASK 选择独立执行；Shared B 通过 operand type 选择 cooperative TMATMUL。TGEMV 虽归类为 PE-scope，但 API 仍写作 TGEMV(...)，PE_MASK=1111 表示四个独立 GEMV。

## Storage Classes

### Local Tile

Local T/U/M/N 是四个相互独立、深度为 16 的 producer-age window。目的操作提交时追加新的 `Q#1`，旧名称依次向 `Q#16` 老化。源绑定不会弹出或压缩窗口。v5 不提供源 `.reuse` 修饰符；即使架构名称已老化出窗口，只要已有 reader 尚未完成，对应物理存储仍保持存活。

### SharedTile

公开 C++ 类型为：

```cpp
SharedTile<BaseTile>
```

`SharedTile` 保留 BaseTile 的 shape/layout/role 描述符，但表示 Core-local Shared 存储。每个 Core 有一组 `S0..S255`，由该 Core 的四个 PE 共享；不同 Core 的 bank 相互独立。C++ 不暴露 Shared architectural ID。编译器分配绝对 S register 并管理其 liveness；PTO-AS、汇编、反汇编和调试界面使用 `S0` 到 `S255`。

每个 S register 持久保存 per-PE descriptor、payload、immutable
`allocation_mask` 和四位 initialization mask，直到 overwrite 或 Core reset。
第一次 nonzero destination write 固定 allocation mask；后续只允许 subset
atomic read-modify-write，扩展必须使用新的 S register。`0000` 是 strict
no-op。读取 unallocated/uninitialized lane 合法，行为与读取 undefined
register 相同且不修改 descriptor。

CUBE 中 `Right` 和 `ScaleRight` 可以使用 Shared storage；cooperative TMATMUL 的 `Left`/`ScaleLeft` 也可以 Shared，但只能与 Shared `Right`/`ScaleRight` 成对使用。`Bias`、`Acc` 以及所有 output role 必须为 Local。

## Shared Data Movement

v5 在既有 intrinsic family 上扩展以下公开 API：

```cpp
enum class SharedMoveMode { Insert, Publish, Broadcast, Extract };

TMOV<SharedMoveMode::Insert>(sharedDst, localSrc);
TMOV<SharedMoveMode::Publish>(sharedDst, localSrc);
TMOV<SharedMoveMode::Broadcast>(localDst, sharedSrc);
TMOV<SharedMoveMode::Extract>(localDst, sharedSrc);
```

- `Insert`/`Publish` 把 `PE_MASK` 选中的 Local quarter 原子写入 Shared register。
- `Broadcast`/`Extract` 把 `PE_MASK` 选中的固定 Shared quarter 复制到 Local destination；未选 quarter 保持不变。
- 多个 mask bit 可以同时为 1；selected quarter 不 pack，`0000` 不读写任何 payload。

mode 必须在编译期给出。公开 API 不新增 `_SHARED` intrinsic family，也不提供 Shared→Shared TMOV。

## GM Data Movement

普通 `TLOAD/TSTORE` 接收完整 logical `GlobalTensor` 描述符；编译器结合 distribution 与 `thread_id` 推导各 PE fragment 地址。

`TLOAD(shared, gm)` 的 destination size 与 mask 直接来自 destination
`B.IOS`，并以一次 atomic RMW 更新 selected Shared lanes。

`TSTORE(gm, shared)` 的 mask 来自 source `B.IOS`，capacity 来自 persistent
Shared descriptor。selected uninitialized lane 产生 undefined-register value。
不同 PE 可提供不同 tile offset，但程序必须保证并发区间不冲突。Shared
store 完成只表示请求已接受且源已捕获或 pin 住，并不表示其他 PE 已能观察到
GM 内容。

## Inter-PE Local Movement

```cpp
GMOV(dst, peer_tid, src);
```

`GMOV` 在同一 Core 的 PE0–PE3 之间搬运已经 rename-resolved 的 per-PE
Local Tile。它是固定 Core4 collective，不提供 `pe_scope/full_scope` 重载；
`PE_MASK` 只控制 request/write，不缩小 participant 或 source-ready 集合。
`peer_tid` 必须位于 `0..3`，`TSize` 描述该 per-PE fragment，并保持 bytes、
dtype、layout 与 descriptor 不变。

## TMATMUL and TGEMV

统一语义：

```text
base: P = A*B
BIAS: P = A*B + Bias
ACC:  P = A*B + C
D = PostProcess(P)
```

MX 以 MXMatMul(A,ScaleA,B,ScaleB) 代替 A*B。PostProcess 可为 canonical None，此时 D 为 AccType/逻辑 TileAcc role；不存在 architectural implicit ACC。K blocking 通过显式 _ACC(D,C,...) 链表达。

TMATMUL 可为全 Local，或以 Shared B 选择 four-PE cooperative form；cooperative A 可为 Local 或 Shared。TGEMV 只允许全部 Local、M=1、每 PE 独立执行。

## Synchronization and GM Ordering

`RecordEvent`/wait 仍是操作完成事件机制，不新增 `SharedEvent`。Shared RAW wait 不建立跨 PE 的 GM 可见性。

```cpp
SYNCALL<core_scope>();
```

该 v5 native form 同步固定参与者 PE0–PE3，并为 scalar LSU 与 TLSU/MTE 提供完整 GM `RW→RW` 顺序。它降低为一条 `FENCE.D.CORE4 RW,RW`。架构只提供一个隐式 barrier slot/generation，不提供 barrier ID。无 scope 的 `SYNCALL()` 保留 PTO cross-core/device 语义，但本 backend 不映射。

## Programmable SYS Body

Linx coupled SYS body 在 v5 中完全开放，并保持 FALL-only。PTO-AS/assembly 可以使用所有合法 SYS/GGPR 操作，同时遵守既有 privilege 与 legality 规则。C++ 不直接命名物理 GGPR；编译器负责管理 live-in、live-out 与 clobber。SYS body 不新增架构长度限制，在下一条 `BSTART` 或 `BSTOP` 处结束；coupled body 不使用 `B.TEXT`。

包含 `FENCE.D.CORE4` 的 body 必须是 straight-line、静态收敛并独立 non-speculative，且该 fence 必须是 body 的最后一条可执行指令。

## Legality and Diagnostics

- Shared A + Local B 非法；cooperative TMATMUL 的 B 必须 Shared。
- MX 的 data/scale pair 必须同为 Local 或同为 Shared。
- TGEMV 的任何 SharedTile 或 B.IOS 均非法。
- C、Bias、D、max output 必须为 Local；cooperative vector parameter 由每 PE 提供相同完整 N-vector，scalar GPR 值也必须相等。
- nondefault AccPhase、旧 *_FIXP opcode、隐式 ACC form 和 _ACC(d,a,b) shorthand 均产生确定诊断。

## Boundaries

Multi-Core/cluster/batch collective、Shared ALU/layout/reduction、Shared→Shared copy、partition load 与 Shared output 不属于 v5。除非另行暴露为程序员可见限制，端口数量、物理容量、仲裁、RAT/Freelist 组织、IQ 结构、replay 策略与 cost model 均属于实现细节。
