---
{
  "schema_version": 1,
  "id": "overview.encoding",
  "kind": "overview",
  "title": "Encoding Conventions",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": { "davincioo": "ENCODING.md" }
}
---
# Encoding Conventions

## Profile Isolation

decoder 在解释重叠字段前必须先确定 binary profile。`davincioo-v4-pe-local` 与 `davincioo-v5-superscalar` 不能把同一 binary 相互重解释。

| 编码面 | v4 | v5 |
| --- | --- | --- |
| `B.IOT[18:15]` | `imm4` | `PE_MASK` |
| `B.IOT[11:10]` | source reuse | part of `TSize` |
| `B.IOT[9:7]` | 3-bit DstTile | `[11:9] TSize`, `[8:7]` 2-bit DstTile |
| compressed `C.B.DIM RegSrc` | dynamic dimension | retired/reserved; B.IOS is 32-bit |

v4 binary 保持原有含义。v5 的 dynamic register dimension 使用 32-bit `B.DIM`；immediate dimension 继续使用 `C.B.DIMI`。

## v5 B.IOT

```text
[31:26] SrcTile1
[25:20] SrcTile0
[19]    last
[18:15] PE_MASK
[14:12] Func
[11:9]  TSize
[8:7]   DstTile
[6:0]   Opcode
```

`Func=100/101/110` 分别保留 two-source/one-source/no-source 含义。同一
operation 使用相同 mask；`0000` 是 strict no-op，cooperative CUBE 的 nonzero
执行必须使用 `1111`。`DstTile=00/01/10/11` 分别选择 T/U/M/N。

| TSize | Per-PE size |
| --- | ---: |
| `000` | implicit/no explicit size |
| `001` | 128 B |
| `010` | 256 B |
| `011` | 512 B |
| `100` | 1 KB |
| `101` | 2 KB |
| `110` | 4 KB |
| `111` | 8 KB |

`000` 只用于 source-only Local binding；所有 Local destination 必须使用
nonzero size。Core allocation 是 `popcount(PE_MASK)` 倍的 per-PE size。

## B.IOS

B.IOS 是 32-bit Shared operand binder，match/mask 为
`0x00001013/0xf00871ff`，编码 `SharedTID[27:20]`、`PE_MASK[18:15]` 和
`TSize[11:9]`。`TSize=0` 为 source，1..7 为 destination per-PE size。
non-MX CUBE 顺序为 Right 或 Left,Right；MX 顺序为 Right,ScaleRight 或
Left,ScaleLeft,Right,ScaleRight。所有 Shared ID 必须不同，TGEMV 拒绝 binder。

## TLSU Function

Function 0–8 保留 TLOAD/TSTORE/TMOV/PREFETCH/GATHER/SCATTER、masked 与 CAS 含义。v5 新增：

| Function | 操作 |
| ---: | --- |
| 9 | `TMOV.L2S.INSERT` |
| 10 | `TMOV.L2S.PUBLISH` |
| 11 | `TMOV.S2L.BROADCAST` |
| 12 | `TMOV.S2L.EXTRACT` |
| 13 | `GMOV` |
| 14 | `TSTORE.SPART` |

## B.IOR for Shared GM

Shared GM schema 消费 `B.IOR.RegSrc0` 作为 base，消费 `RegSrc1` 作为
以 element 为单位的 row stride；它们保持原 TLOAD/TSTORE 编码位置。B.IOR
缺省时 base 为 `zero`，stride 为 `LB2/Col` 或 persistent Shared descriptor
的 column count。若 B.IOR 已编码，`RegDst=RegSrc2=0`。Shared size/mask
完全来自 `B.IOS` 或 persistent descriptor。

## CUBE Shared Schema

Shared B 选择固定 PE4 cooperative TMATMUL，PE_MASK 必须为 1111。A 可由 Local B.IOT 提供，或由 MShard4 Shared Left binder 提供；Shared A 不能与 Local B 组合。C、Bias、D、max 与 PostProcess parameter 始终 Local。

## FENCE.D.CORE4

`FENCE.D` 保留 mask `0xf00fffff`、match `0x0000202b` 与 `FenceMode=[19:15]=00000`。v5 分配 `FenceMode=00001`：

| Mnemonic | Mask | Match |
| --- | --- | --- |
| `FENCE.D pred,succ` | `0xf00fffff` | `0x0000202b` |
| `FENCE.D.CORE4 pred,succ` | `0xf00fffff` | `0x0000a02b` |

`DSB.CORE4` 是 alias。`SYNCALL<core_scope>()` 固定使用 `pred=RW`、`succ=RW`。

## Encoding Conflict Resolutions

- CUBE Function 0–2、4–6、16–18、20–22 为 12 个 active Matrix operation。
- CUBE Function 8 保持 legacy removed selector，不重分配。
- CUBE Function 9–14 为 reserved/illegal，不再表示 FIXP；TLSU Function 9–12、14 的 Shared TMOV/TSTORE variants 属于独立 encoding namespace。
- B.FPATR 对 12 个 active operation 都必需，包括 canonical None。
- TGEMV 不允许 B.IOS，因此不存在 group-GEMV 编码。
