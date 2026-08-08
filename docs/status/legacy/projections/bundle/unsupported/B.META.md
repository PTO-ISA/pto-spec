---
{
  "schema_version": 1,
  "id": "header.unsupported-b-meta",
  "kind": "header",
  "title": "B.META",
  "status": "removed",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "family": "Unsupported Block/Header"
}
---
# B.META

> Historical, non-normative material. This page is excluded from the active PTO architecture and release closure.

> **NON-NORMATIVE / UNSUPPORTED**
> This document is not part of PTO ISA 0.58.0 and must not be used as assembler, decoder, ASL, encoding, or implementation input.

> Unused draft / historical reference. 当前 Linx-style active PE-local profile 不使用本 header；shape/dimension 使用 `B.DIM`。

## 汇编语法

```asm
B.META MetaGpr, meta_shape
B.META MetaGpr, meta_mask
```

## Bit-level Encoding

| Bits | Field | Width | 说明 |
| --- | --- | ---: | --- |
| `[31:20]` | reserved | 12 | 必须为 0 |
| `[19:15]` | `MetaGpr` | 5 | ordinary scalar GPR id |
| `[14:12]` | `func` | 3 | 固定 `3'b100` |
| `[11]` | `MetaMode` | 1 | `0`: `meta_shape`, `1`: `meta_mask` |
| `[10:7]` | reserved | 4 | 必须为 0 |
| `[6:4]` | group | 3 | 固定 `3'b100` |
| `[3:1]` | group | 3 | 固定 `3'b001` |
| `[0]` | length | 1 | 固定 `1` |

## `meta_shape` Payload

| Bits | Field | Width | 说明 |
| --- | --- | ---: | --- |
| `[3:0]` | `format` | 4 | dtype/format；必须与 `BSTART` 主 dtype 兼容 |
| `[7:4]` | `logR` | 4 | physical rows = `1 << logR` |
| `[11:8]` | `logC` | 4 | physical cols = `1 << logC` |
| `[13:12]` | `vmode` | 2 | `0`: FULL, `1`: RECT, `2`: TILE_MASK |
| `[27:14]` | `valid.R` | 14 | valid rows |
| `[41:28]` | `valid.C` | 14 | valid cols |
| `[45:42]` | `off.R` | 4 | valid rectangle row offset |
| `[49:46]` | `off.C` | 4 | valid rectangle col offset |
| `[57:50]` | `mask_tile` | 8 | mask TileReg architectural id |
| `[63:58]` | reserved | 6 | 必须为 0 |

## 约束

- `B.META meta_shape/meta_mask` 与 `B.MSHP/B.MRECTR/B.MRECTC` 互斥。
- `meta_mask` 的 payload 格式和 mask 粒度由 opcode/profile 定义；未定义时非法。
