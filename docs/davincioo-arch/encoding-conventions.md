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
| compressed `C.B.DIM RegSrc` | dynamic dimension | `B.IOS SharedTID` |

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

`Func=100/101/110` 分别保留 two-source/one-source/no-source 含义。每个 block 使用同一个非零 mask；cooperative CUBE 必须使用 `1111`。`DstTile=00/01/10/11` 分别选择 T/U/M/N。

| TSize | Per-PE size |
| --- | ---: |
| `000` | implicit/no explicit size |
| `001` | 128 B |
| `010` | 256 B |
| `011` | 512 B |
| `100` | 1 KiB |
| `101` | 2 KiB |
| `110` | 4 KiB |
| `111` | 8 KiB |

仅当没有 destination allocation 时，`000` 才合法，例如 source-only store。
所有 Local destination 都必须使用非零 size。总物理容量是 per-PE size 乘以
`popcount(PE_MASK)`。

## B.IOS

B.IOS 是 absolute `S0..S255` 的一次性 Shared operand binder，并携带
`PE_MASK` 和 destination 的 per-PE `TSize`。source form 使用 `TSize=000`，
从现有 descriptor 取得大小；destination form 使用与 B.IOT 相同的
`001..111` size 表。cooperative TMATMUL 的 non-MX 顺序为 Right 或
Left,Right；MX 顺序为 Right,ScaleRight 或 Left,ScaleLeft,Right,ScaleRight。
所有 Shared ID 必须不同。TGEMV 不消费该 prefix。

## TLSU Function

Function 0–8 和 13 的 PTO 分配如下：

| Function | 操作 |
| ---: | --- |
| 0 | `TLOAD` |
| 1 | `TSTORE` |
| 2 | `TMOV` (Local-only) |
| 3 | `TPREFETCH` |
| 4 | `MGATHER` |
| 5 | `MSCATTER` |
| 6 | `MGATHER.MASK` |
| 7 | `MSCATTER.MASK` |
| 8 | `MGATHER.CAS` |
| 13 | `GMOV` |

Functions 9–12 are reserved in PTO. Function 14 is the Linx-only
`TSTORE.SPART` slot and is also reserved/illegal in PTO. Functions 15–31 are
reserved. PTO does not define Shared TMOV encodings.

## B.IOR for Shared GM

Shared GM form 不重解释 `B.IOR.RegDst`。`RegSrc0` 是每个 PE 私有的 base
GPR，`RegSrc1` 是以 logical elements 为单位的 row stride，`RegSrc2` 和
`RegDst` 为 zero register。Shared identity、mask 和 destination size 全部由
`B.IOS` 表达。

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
- CUBE Function 9–14 为 reserved/illegal，不再表示 FIXP。
- TLSU Function 8 是 `MGATHER.CAS`；Functions 9–12 和 14 在 PTO 中保持
  reserved，以避免与 Linx-only 分配冲突。
- B.FPATR 对 12 个 active operation 都必需，包括 canonical None。
- TGEMV 不允许 B.IOS，因此不存在 group-GEMV 编码。
