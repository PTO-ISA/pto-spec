---
{
  "schema_version": 1,
  "id": "header.unsupported-b-mrectr",
  "kind": "header",
  "title": "B.MRECTR",
  "status": "removed",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "family": "Unsupported Block/Header"
}
---
# B.MRECTR

> **NON-NORMATIVE / UNSUPPORTED**
> This document is not part of PTO ISA 0.58.0 and must not be used as assembler, decoder, ASL, encoding, or implementation input.

> Unused draft / historical reference. 当前 Linx-style active PE-local profile 不使用本 header；shape/dimension 使用 `B.DIM`。

## 汇编语法

```asm
B.MRECTR LogR, ValidR, OffR
```

## Bit-level Encoding

| Bits | Field | Width | 说明 |
| --- | --- | ---: | --- |
| `[31:28]` | `LogR` | 4 | `shape.R = 1 << LogR` |
| `[27:15]` | `ValidR[13:1]` | 13 | valid rows 高位 |
| `[14:12]` | `func` | 3 | 固定 `3'b110` |
| `[11]` | `ValidR[0]` | 1 | valid rows 低位 |
| `[10:7]` | `OffR` | 4 | valid rectangle row offset |
| `[6:4]` | group | 3 | 固定 `3'b100` |
| `[3:1]` | group | 3 | 固定 `3'b001` |
| `[0]` | length | 1 | 固定 `1` |

## 约束

- `B.MRECTR` 必须与 `B.MRECTC` 成对出现。
- `ValidR <= 1 << LogR`。
- `OffR + ValidR <= 1 << LogR`。
