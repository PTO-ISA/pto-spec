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
| compressed `C.B.DIM RegSrc` | dynamic dimension | `C.B.IOS SharedTID` |

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

| TSize | Logical size |
| --- | ---: |
| `000` | implicit/no explicit size |
| `001` | 512 B |
| `010` | 1 KB |
| `011` | 2 KB |
| `100` | 4 KB |
| `101` | 8 KB |
| `110` | 16 KB |
| `111` | 32 KB |

仅当其他架构 metadata 能唯一确定 size 且没有 Local destination allocation 时，`000` 才合法，例如 source-only store。所有 Matrix D 与 Local↔Shared destination 都必须使用非零 size。

## C.B.IOS

C.B.IOS 是 cooperative TMATMUL 的一次性 Shared operand binder。non-MX 顺序为 Right 或 Left,Right；MX 顺序为 Right,ScaleRight 或 Left,ScaleLeft,Right,ScaleRight。所有 Shared ID 必须不同。TGEMV 不消费该 prefix。

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

仅对 GM→Shared，`[11:9]` 表示 `SharedTSize` 且 `[8:7]=00`；size `000` 非法。Shared full/partition store 要求 `[11:7]` 全为零。v5 中 `RegSrc0` 为 base，`RegSrc1` 为 row stride，`RegSrc2` 为零。

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
- TGEMV 不允许 C.B.IOS，因此不存在 group-GEMV 编码。
