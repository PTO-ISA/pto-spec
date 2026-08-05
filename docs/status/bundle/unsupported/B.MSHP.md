---
{
  "schema_version": 1,
  "id": "header.unsupported-b-mshp",
  "kind": "header",
  "title": "B.MSHP",
  "status": "removed",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "family": "Unsupported Block/Header"
}
---
# B.MSHP

> **NON-NORMATIVE / UNSUPPORTED**
> This document is not part of PTO ISA 0.58.0 and must not be used as assembler, decoder, ASL, encoding, or implementation input.

> Unused draft / historical reference. 当前 Linx-style active PE-local profile 不使用本 header；shape/dimension 使用 `B.DIM`。

## 汇编语法

```asm
B.MSHP FULL, LogR, LogC
B.MSHP TILE, LogR, LogC, MaskTile
```

`B.MSHP TILE` 表示静态 immediate mask-tile metadata，使用 `MaskTile` 指向 irregular mask TileReg。它不同于动态 `B.META MetaGpr, meta_mask`，同一 block 中不得混用。`MaskTile` 使用公共 8-bit TileReg namespace；`TZERO` 编码为 `0`。

## Bit-level Encoding

| Bits | Field | Width | 说明 |
| --- | --- | ---: | --- |
| `[31]` | `IShapeMode` | 1 | `0`: `FULL`; `1`: `TILE_MASK` |
| `[30:27]` | `LogR` | 4 | `shape.R = 1 << LogR` |
| `[26:23]` | `LogC` | 4 | `shape.C = 1 << LogC` |
| `[22:15]` | `MaskTile` | 8 | `FULL` 时必须为 `TZERO`; `TILE` 时为 mask TileReg id |
| `[14:12]` | `func` | 3 | 固定 `3'b101` |
| `[11:7]` | reserved | 5 | 必须为 0 |
| `[6:4]` | group | 3 | 固定 `3'b100` |
| `[3:1]` | group | 3 | 固定 `3'b001` |
| `[0]` | length | 1 | 固定 `1` |

## 约束

- `B.MSHP FULL` 的 `MaskTile` 必须编码为 `TZERO` (`0`)。
- `B.MSHP TILE` 的 `MaskTile=TZERO` 非法。
- `MaskTile` 是 8-bit architectural TileReg id；metadata mask tile 不默认允许 `ACC0..ACC3`。
