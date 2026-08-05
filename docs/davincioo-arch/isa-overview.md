---
{
  "schema_version": 1,
  "id": "overview.isa_overview",
  "kind": "overview",
  "title": "ISA Overview",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "ISA_OVERVIEW.md"
  }
}
---
# ISA Overview

## Profile and Scope

`davincioo-v5-superscalar` 定义一个恰含四个 PE 的 DavinciOO Core 上的 PTO Tile intrinsic 映射。Multi-Core、cluster 与 batch collective 不属于本 profile；无 scope 的 PTO `SYNCALL()` 只保留继承语义，backend 不映射。

## Execution Hierarchy

四个 PE 执行同一份 SPMD 程序映像，各自拥有独立 PC、ROB 状态和固定为 0–3 的 `thread_id`。该值由 DavinciOO v5 只读 [PEID SSR](../compatibility/scalar/register/ssr/PEID.md)（SSR ID `0x0802`）提供，`get_thread_id()` 固定降低为 `SSRGET PEID`，不新增 opcode。普通区域允许分歧；collective operation 只有在四个 PE 以相同动态顺序到达同一静态操作时才合法。

## Architectural Objects

| 对象 | 范围 | 说明 |
| --- | --- | --- |
| Local TReg | 单 PE | 普通 Tile payload；Matrix 的 C、D、Bias 与 auxiliary 均映射到此 |
| Logical Tile | 单 Core 编程模型 | 512 B–32 KB 对象，按 distribution 映射到四个 fragment |
| SharedTile | 单 Core | 带版本的 Core-local Shared storage；只供 cooperative TMATMUL 的 A/B side |
| Logical TileAcc role | PTO C++/SSA | AccType partial-sum 角色；backend 仍使用 ordinary physical Local TReg |
| GM | 系统内存 | 显式 TLOAD/TSTORE source 或 destination |

DavinciOO v5 不定义 architectural implicit ACC singleton。

## Logical Tile Model

logical Tile 的大小为 512 B–32 KB，始终包含四个等大的 128 B–8 KB Local fragment。`PE_MASK` 选择哪些 PE payload 参与 Local instruction；它不改变 logical size，也不隐含 rendezvous。Storage class 与 distribution 是两个独立维度：`Shared` 不是 distribution，`Replicated4` 也不是 distribution 类型。

## Execution Scope

- 普通 Local intrinsic 由 PE_MASK 选择独立 PE；1111 不隐含 barrier。
- cooperative TMATMUL 由 Shared B operand 选择，固定 PE0–PE3 且 PE_MASK=1111；A 可为 Local 或 MShard4 Shared。
- TGEMV 始终为 PE-local M=1 GEMV，不支持 Shared operand、C.B.IOS 或 core rendezvous。
- TSTORE<pe_scope> 与 SYNCALL<core_scope> 仍是显式改变语义的独立接口。

## Data Movement

v5 profile 保留 `TLOAD`、`TSTORE` 与 `TMOV` 名称：

- GM↔Local 使用普通 distributed logical-Tile 合同。
- GM→Shared 由 exactly-one issuer 发起，并创建 fully-defined Shared version。
- Shared→GM 默认为 exactly-one full/core store；`TSTORE<pe_scope>` 使用各 PE 不重叠的指针保存固定 region。
- Local↔Shared 使用 `TMOV<SharedMoveMode::{Insert,Publish,Broadcast,Extract}>`。
- PE 间 Local Tile 搬运使用固定 Core4 collective `GMOV(dst, peer_tid, src)`；`peer_tid` 为 `0..3`，不提供 scope 重载。
- v5 不提供 Shared→Shared copy、partition load、gather/scatter/prefetch-to-Shared 或直接 Shared ALU/layout/reduction。

## Computation

12 个 active Matrix operation 均计算显式 P，并在完整 K 累加后执行一次 PostProcess，结果写 ordinary Local D。base 从零开始，BIAS 加显式 Bias Tile，ACC 加显式 C Tile；MX 仅改变乘法规则。每个 operation 都携带一个 B.FPATR，canonical None 产生 AccType/TileAcc-role D。Function 9–14 的旧 FIXP family 已移除并视为 illegal。

## Synchronization

Shared register RAW wait 只建立该 Shared version 的 producer-to-consumer ready 关系，并不是 GM fence。`SYNCALL<core_scope>()` 降低为 `FENCE.D.CORE4 RW,RW`，合并较老 scalar/TLSU/MTE GM access 的 release、固定四 PE rendezvous，以及较新 GM access 的 acquire ordering。无 scope 的 `SYNCALL()` 保留 PTO cross-core/device 语义，本 backend 不支持映射。

## Instruction Families

| 族 | 说明 |
| --- | --- |
| Header | Block 选择、维度、Local/Shared operand 绑定与 dependency |
| TEPL | Distributed Local fragment 计算 |
| TLSU | GM↔Local、GM↔Shared 与 Local↔Shared 搬运 |
| CUBE | Local Matrix，以及仅 TMATMUL 支持的 Shared-operand cooperative form |
| SYS | coupled SYS body 与 Core collective fence |
| Scalar 附录 | 继承的 scalar/system micro-instruction 参考 |

## Compatibility Boundary

v5 重新定义了 v4 的 `B.IOT` 字段和旧 compressed `C.B.DIM RegSrc` pattern，因此 decode 前必须先确定 profile：v4 保留 `.reuse`、`imm4` 与 `C.B.DIM RegSrc`；v5 使用 `PE_MASK`、`TSize`、压缩后的 `DstTile` 与 `C.B.IOS`。禁止跨 profile 重解释 binary。
