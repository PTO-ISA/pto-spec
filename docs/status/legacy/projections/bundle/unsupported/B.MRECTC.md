---
{
  "schema_version": 1,
  "id": "header.unsupported-b-mrectc",
  "kind": "header",
  "title": "B.MRECTC",
  "status": "removed",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "family": "Unsupported Block/Header"
}
---
# B.MRECTC

> Historical, non-normative material. This page is excluded from the active PTO architecture and release closure.

> **NON-NORMATIVE / UNSUPPORTED**
> This document is not part of PTO ISA 0.58.0 and must not be used as assembler, decoder, ASL, encoding, or implementation input.

> Unused draft / historical reference. 当前 Linx-style active PE-local profile 不使用本 header；shape/dimension 使用 `B.DIM`。

## 汇编语法

```asm
B.MRECTC LogC, ValidC, OffC
```

## Bit-level Encoding

| Bits | Field | Width | 说明 |
| --- | --- | ---: | --- |
| `[31:28]` | `LogC` | 4 | `shape.C = 1 << LogC` |
| `[27:15]` | `ValidC[13:1]` | 13 | valid columns 高位 |
| `[14:12]` | `func` | 3 | 固定 `3'b111` |
| `[11]` | `ValidC[0]` | 1 | valid columns 低位 |
| `[10:7]` | `OffC` | 4 | valid rectangle column offset |
| `[6:4]` | group | 3 | 固定 `3'b100` |
| `[3:1]` | group | 3 | 固定 `3'b001` |
| `[0]` | length | 1 | 固定 `1` |

## 约束

- `B.MRECTC` 必须与 `B.MRECTR` 成对出现。
- `ValidC <= 1 << LogC`。
- `OffC + ValidC <= 1 << LogC`。
