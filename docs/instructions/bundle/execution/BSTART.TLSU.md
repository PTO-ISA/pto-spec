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

`BSTART.TLSU` 选择数据搬运 Function 与主 dtype。普通 Local operand 使用 `B.IOT`；Shared form 使用一次性 `C.B.IOS`，随后紧跟表中规定的 companion header。

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
| 0 | `TLOAD`; Shared form is GM2S full | Local: `B.IOT(dst)+B.IOR`; Shared: `C.B.IOS+B.IOR` |
| 1 | `TSTORE`; Shared form is S2GM full | Local: `B.IOT(src)+B.IOR`; Shared: `C.B.IOS+B.IOR` |
| 2 | Local `TMOV` | `B.IOT(src,dst)` |
| 3 | `TPREFETCH` | existing Local/cache schema |
| 4 | `MGATHER` | existing Local schema |
| 5 | `MSCATTER` | existing Local schema |
| 6 | `MGATHER.MASK` | existing Local masked-gather schema |
| 7 | `MSCATTER.MASK` | existing Local masked-scatter schema |
| 8 | `MGATHER.CAS` | existing Local atomic gather-CAS schema |
| 9 | `TMOV.L2S.INSERT` | `C.B.IOS+B.IOT(Local src)` |
| 10 | `TMOV.L2S.PUBLISH` | `C.B.IOS+B.IOT(Local src)` |
| 11 | `TMOV.S2L.BROADCAST` | `C.B.IOS+B.IOT(Local dst)` |
| 12 | `TMOV.S2L.EXTRACT` | `C.B.IOS+B.IOT(Local dst)` |
| 13 | `GMOV` | `B.IOT(Local src,dst,PE_MASK,TSize)+B.IOR(peer_tid,0,0)` |
| 14 | `TSTORE.SPART` | `C.B.IOS+B.IOR` |
| 15–31 | reserved | illegal |

Function 9–12 由公开 `SharedMoveMode` 选择。Function 14 只由 Shared source 的 `TSTORE<pe_scope>` 选择；即使 source 已完整定义，full store 与 partition store 仍使用不同 Function。Function 13 是固定 Core4 collective `GMOV`，没有 scope 重载。

## Size 与 Mask

GM→Shared size 编码在 `B.IOR.SharedTSize`。Local↔Shared size 编码在非零 `B.IOT.TSize`；Broadcast 可按规定的 size relation 使用更大的 Local logical size。`PE_MASK` 不改变 group participant 或 source-ready 要求。`GMOV` 的 `TSize` 表示完整逻辑 Tile，每个 PE 传输固定四分之一 fragment。

## DataType

DataType 沿用 5-bit TLSU 表。支持的 dtype/layout 组合仍由各 opcode 决定，并必须同时满足 PTO source 与目标 profile；`GMOV` 只允许完全一致的 source/destination descriptor。
