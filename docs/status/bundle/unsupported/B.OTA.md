---
{
  "schema_version": 1,
  "id": "header.unsupported-b-ota",
  "kind": "header",
  "title": "B.OTA",
  "status": "removed",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "family": "Unsupported Block/Header"
}
---
# B.OTA

> **NON-NORMATIVE / UNSUPPORTED**  
> This document is not part of PTO ISA 0.58.0 and must not be used as assembler, decoder, ASL, encoding, or implementation input.

> Unused draft / historical reference. 当前 Linx-style active PE-local profile 不使用本 header；Tile output binding 和 size class 使用 `B.IOT`。

## 说明

`B.OTA` 声明一个 PE-local destination TileReg，并用 `tile_size_m1` 指定 output Tile size。v4 PE 内部以 128 B CELL 作为最小寄存器、rename 和数据通路基本粒度；因此 `tile_size_m1` 直接以 128 B CELL 为编码单位，`Tile bytes = (tile_size_m1 + 1) * 128 B`。8-bit `tile_size_m1` 合法范围为 `0..255`，对应 `128 B..32 KB`。这里的 `tile_size_m1` 不是 core-level/group-level operand 编码。

## 汇编语法

```asm
B.OTA ->DstTile<tile_size_m1>, <last>, dst_slot
```

## Bit-level Encoding

| Bits | Field | Width | 说明 |
| --- | --- | ---: | --- |
| `[31:24]` | `DstTile` | 8 | destination TileReg id |
| `[23:16]` | `tile_size_m1` | 8 | PE-local output Tile size，编码单位为 128 B CELL |
| `[15]` | `L` | 1 | `last` descriptor 标记 |
| `[14:12]` | `func` | 3 | 固定 `3'b011` |
| `[11:10]` | `dst_slot` | 2 | `00`: dst0, `01`: dst1, `10`: dst2, `11`: dst3 |
| `[9:7]` | reserved | 3 | 必须为 0 |
| `[6:4]` | group | 3 | 固定 `3'b001` |
| `[3:1]` | group | 3 | 固定 `3'b001` |
| `[0]` | length | 1 | 固定 `1` |

## Size Encoding

| Tile bytes | `tile_size_m1` |
| ---: | ---: |
| 128 B | 0 |
| 256 B | 1 |
| 512 B | 3 |
| 1 KB | 7 |
| 2 KB | 15 |
| 4 KB | 31 |
| 8 KB | 63 |
| 16 KB | 127 |
| 32 KB | 255 |

## 约束

- `DstTile=TZERO` 非法。
- `DstTile` 使用公共 8-bit TileReg namespace：`0=TZERO`，`1..251=ordinary TileReg`，`252..255=ACC0..ACC3`。
- `ACC0..ACC3` 仅在 matrix/CUBE accumulator destination role 合法；普通 tile output 默认使用 ordinary TileReg。
- `dst_slot` 必须与 opcode profile 中的 output ordinal 对齐。
- 对同形 elementwise op，`B.OTA.tile_size_m1` 应与 source TileReg size 一致。
