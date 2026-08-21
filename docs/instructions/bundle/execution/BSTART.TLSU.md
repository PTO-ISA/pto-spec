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
| 0 | `TLOAD`; Shared form is GM2S full | Local: `B.IOT(dst)+B.IOR`; Shared: `B.IOS+B.IOR` |
| 1 | `TSTORE`; Shared form is S2GM full | Local: `B.IOT(src)+B.IOR`; Shared: `B.IOS+B.IOR` |
| 2 | Local `TMOV` | `B.IOT(src,dst)` |
| 3 | `TPREFETCH` | Local/cache schema |
| 4 | `MGATHER` | Local schema |
| 5 | `MSCATTER` | Local schema |
| 6 | `MGATHER.MASK` | Local schema |
| 7 | `MSCATTER.MASK` | Local schema |
| 8 | `MGATHER.CAS` | Local schema |
| 9–12 | reserved in PTO | illegal; Linx-only space is not available for PTO allocation |
| 13 | `GMOV` | `B.IOT(Local src,dst,PE_MASK,TSize)+B.IOR(peer_tid,0,0)` |
| 14 | reserved in PTO | Linx-only `TSTORE.SPART`; illegal in PTO |
| 15–31 | reserved | illegal |

PTO 不定义 Shared TMOV 或 `TSTORE.SPART`。Function 13 是固定 Core4
collective `GMOV`，没有 scope 重载。Linx 已分配的 TLSU Function 必须在 PTO
保持 reserved，PTO 不得在相同编码空间增加冲突定义。

## Size 与 Mask

Local destination size 编码在 `B.IOT.TSize`，Shared destination size 编码在
`B.IOS.TSize`。两者都使用 `001..111 = 128 B..8 KiB` 的 per-PE 含义。
Shared source 的 `B.IOS.TSize=000`，大小来自 descriptor。`PE_MASK` 是 PE
predicate；总物理容量为 per-PE size 乘以参与 PE 数。`GMOV` 采用同一 per-PE
`TSize` 解释。

## DataType

DataType 沿用 5-bit TLSU 表。支持的 dtype/layout 组合仍由各 opcode 决定，并必须同时满足 PTO source 与目标 profile；`GMOV` 只允许完全一致的 source/destination descriptor。
