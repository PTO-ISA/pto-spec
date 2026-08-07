---
{
  "schema_version": 1,
  "id": "header.header-bstart.tlsu",
  "kind": "header",
  "title": "BSTART.TLSU",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Execution Classes",
  "sources": { "davincioo": "header/BSTART.TLSU.md" }
}
---
# BSTART.TLSU

## 用途

`BSTART.TLSU` 选择数据搬运 Function 与主 dtype。普通 Local operand 使用 `B.IOT`；Shared form 使用一次性 `B.IOS`，随后紧跟表中规定的 companion header。

## 编码

| Bits | Field | Width | 固定值 |
| --- | --- | ---: | --- |
| `[31:27]` | `DataType` | 5 | |
| `[26:25]` | zero | 2 | `0` |
| `[24:20]` | `Function` | 5 | |
| `[19:15]` | block family | 5 | `2` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | fixed | 5 | `3` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

## Function 表

| Function | Operation | v5 operand schema |
| ---: | --- | --- |
| 0 | `TLOAD`; Shared form is GM2S full | Local: `B.IOT(dst)+B.IOR(base,row_stride)`; Shared: `B.IOS+B.IOR(base,row_stride)` |
| 1 | `TSTORE`; Shared form is S2GM full | Local: `B.IOT(src)+B.IOR(base,row_stride)`; Shared: `B.IOS+B.IOR(base,row_stride)` |
| 2 | Local `TMOV` | `B.IOT(src,dst)` |
| 3 | `TPREFETCH` | existing Local/cache schema |
| 4 | `MGATHER` | existing Local schema |
| 5 | `MSCATTER` | existing Local schema |
| 6 | `MGATHER.MASK` | existing Local masked-gather schema |
| 7 | `MSCATTER.MASK` | existing Local masked-scatter schema |
| 8 | `MGATHER.CAS` | existing Local atomic gather-CAS schema |
| 9 | `TMOV.L2S.INSERT` | `B.IOS+B.IOT(Local src)` |
| 10 | `TMOV.L2S.PUBLISH` | `B.IOS+B.IOT(Local src)` |
| 11 | `TMOV.S2L.BROADCAST` | `B.IOS+B.IOT(Local dst)` |
| 12 | `TMOV.S2L.EXTRACT` | `B.IOS+B.IOT(Local dst)` |
| 13 | `GMOV` | `B.IOT(Local src,dst,PE_MASK,TSize)+B.IOR(a0)`; B.IOR may be omitted for `zero` |
| 14 | `TSTORE.SPART` | `B.IOS+B.IOR(base,row_stride)` |
| 15–31 | reserved | illegal |

Function 9–12 由公开 `SharedMoveMode` 选择。Function 14 只由 Shared source 的 `TSTORE<pe_scope>` 选择；即使 source 已完整定义，full store 与 partition store 仍使用不同 Function。Function 13 是固定 Core4 collective `GMOV`，没有 scope 重载。

## Size 与 Mask

Local operand 的 per-PE size 编码在 `B.IOT.TSize`；Shared operand 的
per-PE size 与 `PE_MASK` 编码在 `B.IOS`。Local→Shared 的 destination size
来自 `B.IOS`，Shared→Local 的 Local destination capacity 来自 `B.IOT`。
`B.IOR` 不承载 Shared size，且不存在 mask-only `B.IOT` companion。
`TSize=001..111` 表示每个 selected PE 的 128 B–8 KiB，core allocation 为
`popcount(PE_MASK)` 倍。`PE_MASK=0000` 是 strict no-op。`GMOV` 也使用该
per-PE size 规则。

TLOAD/TSTORE 的 B.IOR 编码不变：`RegSrc0` 是 base，`RegSrc1` 是以
element 为单位的 row stride。B.IOR 缺省时使用 `zero` base 和
`LB2/Col` 密集 stride；显式 `RegSrc1=zero` 仍是真实的零 stride。

## DataType

DataType 沿用 5-bit TLSU 表。支持的 dtype/layout 组合仍由各 opcode 决定，并必须同时满足 PTO source 与目标 profile；`GMOV` 只允许完全一致的 source/destination descriptor。
