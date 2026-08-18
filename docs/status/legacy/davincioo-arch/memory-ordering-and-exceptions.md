---
{
  "schema_version": 1,
  "id": "overview.memory_and_exceptions",
  "kind": "overview",
  "title": "Memory, Ordering and Exceptions",
  "status": "historical",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": { "davincioo": "MEMORY_AND_EXCEPTIONS.md" }
}
---
# Memory, Ordering and Exceptions

> Historical, non-normative material. This page is excluded from the active PTO architecture and release closure.

## Memory Paths

> Superseded Shared-memory description: The exactly-one/full-object rows below
> are preserved only as historical context and are not current PTO behavior.
> Use the ASL-derived [BSTART.TLOAD](../../../block/execution/BSTART.TLOAD.md),
> [TLOAD](../../../tile/memory-and-data-movement/regular/TLOAD.md), and
> [B.IOS](../../../block/operands/B.IOS.md) pages for the active contract.

| 源 | 目的 | 公开 intrinsic | Issuer/scope |
| --- | --- | --- | --- |
| GM | Local Tile | `TLOAD` | Distributed logical Tile；编译器推导 fragment 地址 |
| Local Tile | GM | `TSTORE` | Distributed logical Tile |
| GM | SharedTile | `TLOAD` overload | Exactly-one issuer；`B.IOS` 选择 PE；每个 selected PE 使用 128 B–8 KiB per-PE size |
| SharedTile | GM | `TSTORE` | Exactly-one issuer；full/core store |
| SharedTile | GM | `TSTORE<pe_scope>` | Defined-mask partition；各 PE 指针独立且不重叠 |
| Local Tile | SharedTile | `TMOV<Insert/Publish>` | 静态 producer mask 或 single owner |
| SharedTile | Local Tile | `TMOV<Broadcast/Extract>` | Full broadcast 或 fixed-region extract |

## Address Interpretation

> Superseded Shared-memory description: The Shared full-load/store issuer model
> below is historical and must not be used to implement the active ISA. Use the
> ASL-derived instruction pages linked above.

普通 logical-Tile `TLOAD/TSTORE` 接收完整 `GlobalTensor` descriptor。编译器结合静态 distribution 与 `thread_id` 推导各 PE fragment 地址。Shared full load/store 则使用选定 issuer 的指针表示整个对象。Partition store 是例外：每个 PE 提供自己的指针，且各地址区间不得重叠。

## Completion and Visibility

operation event 根据对应 intrinsic 合同表示 issue/completion。对 Shared→GM，完成表示请求已经接受且 Shared source 已被捕获或 pin 住；它本身不保证另一个 PE 的后续 GM load 能观察到该数据。

Shared RAW 只建立 Shared register producer-to-consumer readiness；`B.IOD` 只建立 block scheduling dependency。两者都不是 GM memory fence。

## Core-scope GM Ordering

`SYNCALL<core_scope>()` 降低为 `FENCE.D.CORE4 RW,RW`。对每个 PE，该指令：

1. 使较老的 scalar LSU 与 TLSU/MTE GM read/write 到达 release point；
2. 为当前唯一的隐式 Core generation 登记 arrival；
3. 等待 PE0–PE3 到达同一 dynamic barrier；
4. 同时释放四个 PE；
5. 在 acquire release 前阻止较新的 GM read/write 到达可观察点。

`RW,RW` 不隐含 MMIO。无 scope 的 PTO `SYNCALL()` 保留 cross-core/device 含义，本 backend 不映射。

## Collective Mismatch and Forward Progress

编译器必须证明 collective convergence。若任一 PE 缺席、到达不同静态 barrier，或以不同顺序执行 collective，则程序非法且不保证 forward progress。调试硬件可以 timeout/trap；生产实现不暴露固定 timeout 合同。

Flush/replay 不得重复登记 arrival。Exception、kill、debug termination 与 Core reset 必须清除或终止 in-flight generation。这些 recovery mechanism 是实现义务，不新增 C++ operand。

## SYS Privilege and Precise Exceptions

可编程 coupled SYS body 完整开放，但每条 SYS instruction 仍遵守既有 privilege 与 legality 规则。权限不足产生既有 precise illegal/privilege trap。包含 `FENCE.D.CORE4` 的 SYS block 只能在 non-speculative precise point 执行，必须为 straight-line，并把 fence 放在最后，避免 arrival 后的 faulting instruction 使其他 PE 永久等待。

## Required Diagnostics

编译期诊断必须覆盖：非法 Shared role、partial compute source、不支持的 Shared operation/scope、非法 size/mode、无法证明 exactly-one issuer、partition store 重叠、MX storage 混用、MX Shared ID 重复、binder 顺序非法、cooperative mask 非 `1111`，以及静态分歧的 collective 控制流。reserved `FenceMode` 与畸形 machine-header 组合按非法编码 trap。
