---
{
  "schema_version": 1,
  "id": "header.unsupported-b-itp",
  "kind": "header",
  "title": "B.ITP",
  "status": "removed",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "family": "Unsupported Block/Header"
}
---
# B.ITP

> **NON-NORMATIVE / UNSUPPORTED**  
> This document is not part of PTO ISA 0.58.0 and must not be used as assembler, decoder, ASL, encoding, or implementation input.

> Unused draft / historical reference. 当前 Linx-style active PE-local profile 不使用本 header；Tile operand binding 使用 `B.IOT`。

## 说明

`B.ITP` 用于声明最多两个 source TileReg，并携带 `.reuse` lifetime hint 与 source pair slot。它是 consumer-side tile binding，不携带 source tile size；source size 由硬件从 producer/rename/allocation metadata 读取。`SrcTile0/SrcTile1` 使用公共 8-bit TileReg namespace，其中 `0=TZERO`，`252..255=ACC0..ACC3`。

## 汇编语法

```asm
B.ITP SrcTile0<.reuse>, SrcTile1<.reuse>, <last>, src_pair
```

## Bit-level Encoding

| Bits | Field | Width | 说明 |
| --- | --- | ---: | --- |
| `[31:24]` | `SrcTile1` | 8 | 第二个 source TileReg id |
| `[23:16]` | `SrcTile0` | 8 | 第一个 source TileReg id |
| `[15]` | `L` | 1 | `last` descriptor 标记 |
| `[14:12]` | `func` | 3 | 固定 `3'b010` |
| `[11:10]` | `src_pair` | 2 | `00`: src0/1, `01`: src2/3, `10`: src4/5, `11`: src6/7 |
| `[9]` | `S1R` | 1 | `SrcTile1` reuse |
| `[8]` | `S0R` | 1 | `SrcTile0` reuse |
| `[7]` | reserved | 1 | 必须为 0 |
| `[6:4]` | group | 3 | 固定 `3'b001` |
| `[3:1]` | group | 3 | 固定 `3'b001` |
| `[0]` | length | 1 | 固定 `1` |

## 约束

- `src_pair` 必须与 opcode profile 中的 operand ordinal 对齐。
- 未使用 source slot 必须编码为 `TZERO` (`0`)，对应 reuse bit 为 0。
- 对普通 tile op，`.reuse` 表示 source lifetime hint；对 matrix/CUBE profile 的 B operand，`.reuse` 可作为 weight buffer reuse/preload hint。
- `ACC0..ACC3` 仅在 matrix/CUBE accumulator source role 合法；普通 tile source 默认使用 ordinary TileReg 或 `TZERO`。
- 如果 block 没有 output tile，最后一条 `B.ITP` 必须设置 `last=1`。
