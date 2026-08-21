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
| Local TReg | 单 PE | 普通 Tile payload；每个 PE 拥有自己的 descriptor 与 GPR address base |
| Logical Tile | 单 PE 编程模型 | 128 B–8 KiB 对象；`TSize` 始终表示单个参与 PE 的容量 |
| Shared TReg | 单 Core | S0–S255；四个 PE 都可见，赋值时分配新的 Shared register/version |
| Logical TileAcc role | PTO C++/SSA | AccType partial-sum 角色；backend 仍使用 ordinary physical Local TReg |
| GM | 系统内存 | 显式 TLOAD/TSTORE source 或 destination |

DavinciOO v5 不定义 architectural implicit ACC singleton。

## Logical Tile Model

`TSize` 的编码 1–7 分别表示每个参与 PE 的 128 B、256 B、512 B、
1 KiB、2 KiB、4 KiB 和 8 KiB 容量。`PE_MASK` 选择参与的 PE；总分配量是
单 PE 容量乘以置位数量，因此 `0001/0011/1111` 在 `TSize=001` 时分别
分配 128/256/512 B。每个 PE 使用自己的 GPR base 与 offset；架构不保证
跨 PE 的访问顺序，程序必须避免相互冲突的地址。`PE_MASK=0000` 是严格
NOP，不读取寄存器、不分配、不访问内存也不更新 descriptor。

## Execution Scope

- 普通 Local intrinsic 由 PE_MASK 选择独立 PE；1111 不隐含 barrier。
- Shared S0–S255 是单 Core 私有、四 PE 可见的绝对索引寄存器；读取未初始化
  Sx 与读取未定义普通寄存器相同，结果未定义但不是单独的架构异常。
- `B.IOS Sx` 绑定 Shared source，`B.IOS -> Sx` 绑定 Shared destination；
  destination 的 read-modify-write 更新是原子的，但不同 PE/指令之间不保证顺序。
- TGEMV 与 TMATMUL 的合法 Local/Shared operand 组合由各 mnemonic 页面和
  CUBE legality 定义；Shared 可见性本身不隐含 core rendezvous。

## Data Movement

v5 profile 保留 `TLOAD`、`TSTORE` 与 `TMOV` 名称：

- GM↔Local 使用 `B.IOT` 绑定的 Local TReg；`B.IOT` 不绑定 Shared storage。
- GM↔Shared 使用 `B.IOS` 的绝对 Shared ID、`PE_MASK` 和 `TSize`。每个参与
  PE 使用自己的 GPR base/offset；硬件仅保证单次 Shared destination 更新的
  原子性，不保证跨 PE 顺序。
- `TMOV` 仅支持 Local TReg；不存在 Local↔Shared TMOV 或 Shared SPART 模式。
- PE 间 Local Tile 搬运使用固定 Core4 collective `GMOV(dst, peer_tid, src)`；`peer_tid` 为 `0..3`，不提供 scope 重载。
- v5 不提供 Shared→Shared copy、partition load、gather/scatter/prefetch-to-Shared 或直接 Shared ALU/layout/reduction。

## Computation

12 个 active Matrix operation 均计算显式 P，并在完整 K 累加后执行一次 PostProcess，结果写 ordinary Local D。base 从零开始，BIAS 加显式 Bias Tile，ACC 加显式 C Tile；MX 仅改变乘法规则。每个 operation 都携带一个 B.FPATR，canonical None 产生 AccType/TileAcc-role D。Function 9–14 的旧 FIXP family 已移除并视为 illegal。

## Synchronization

Shared register RAW wait 只建立该 register 的 producer-to-consumer ready 关系，并不是 GM fence。`SYNCALL<core_scope>()` 降低为 `FENCE.D.CORE4 RW,RW`，合并较老 scalar/TLSU/MTE GM access 的 release、固定四 PE rendezvous，以及较新 GM access 的 acquire ordering。无 scope 的 `SYNCALL()` 保留 PTO cross-core/device 语义，本 backend 不支持映射。

## Instruction Families

| 族 | 说明 |
| --- | --- |
| Header | Block 选择、维度、Local/Shared operand 绑定与 dependency |
| VEC | Element-wise 运算；使用不变的 TEPL mode/function 编码载体 |
| SFU | 需要复杂硬件的数据变换、归约、转换、排序等运算；同样使用 TEPL 编码载体 |
| TLSU | TLOAD/TSTORE、Local TMOV、prefetch、indexed memory、GMOV；PTO 保留 Linx-only TLSU function 空间 |
| CUBE | Matrix/GEMV 运算及其合法 Local/Shared operand 组合 |
| SYS | coupled SYS body 与 Core collective fence |
| Scalar 附录 | 继承的 scalar/system micro-instruction 参考 |

## Compatibility Boundary

v5 重新定义了 v4 的 `B.IOT` 字段和旧 compressed `C.B.DIM RegSrc` pattern，因此 decode 前必须先确定 profile：v4 保留 `.reuse`、`imm4` 与 `C.B.DIM RegSrc`；v5 使用 `PE_MASK`、`TSize`、压缩后的 `DstTile` 与 `B.IOS`。禁止跨 profile 重解释 binary。
