---
{
  "schema_version": 1,
  "id": "header.header-b.iot",
  "kind": "header",
  "title": "B.IOT",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Operand Bindings",
  "sources": { "davincioo": "header/B.IOT.md" }
}
---
# B.IOT

## 用途

`B.IOT` 只绑定 Local Tile source/destination。它编码 per-PE destination
`TSize`、本次 operation 的 `PE_MASK` 与 source last-use；Shared metadata
全部由 [`B.IOS`](./B.IOS.md) 表达。

## 汇编语法

```asm
B.IOT SrcTile0, SrcTile1, mask=PE_MASK <,last>, ->DstTile<SIZE>
B.IOT SrcTile0, mask=PE_MASK <,last>
B.IOT mask=PE_MASK, last, ->DstTile<SIZE>
```

Local-to-Shared TMOV 使用第二种 source-only form，Shared destination 的
size/mask 来自 `B.IOS`。`B.IOT` 不存在 mask-only Shared companion，也不在
source-only form 中携带 Shared size。v5 不存在 `.reuse` modifier。

## v5 Bit-level 编码

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:26]` | `SrcTile1` | 6 | |
| `[25:20]` | `SrcTile0` | 6 | |
| `[19]` | `last` | 1 | |
| `[18:15]` | `PE_MASK` | 4 | |
| `[14:12]` | `Func` | 3 | |
| `[11:9]` | `TSize` | 3 | |
| `[8:7]` | `DstTile` | 2 | |
| `[6:0]` | opcode group | 7 | `0x13` |

## TSize 与 PE_MASK

Destination `TSize=001..111` 表示每个 selected PE 的 128 B、256 B、
512 B、1 KiB、2 KiB、4 KiB、8 KiB。Core allocation 为
`popcount(PE_MASK) * per_pe_size`。source-only form 使用 `TSize=000`，size
来自已经 rename-resolved 的 source descriptor。

Mask bit 固定为 `1000=PE0`、`0100=PE1`、`0010=PE2`、`0001=PE3`。多位
可以同时为 1，selected PE 不 pack。`0000` 是 strict no-op，不产生任何
allocation、rename、read/write、lifetime、consume 或 fault effect。

## 合法性

- 最后一条 `B.IOT` 必须设置 `last`。
- Destination form 必须使用 nonzero `TSize`；source-only form 为 `TSize=000`。
- Mixed Local/Shared operation 的 `B.IOT.PE_MASK` 必须与 `B.IOS.PE_MASK` 相同。
- D 和 auxiliary output 必须是 Local TReg destination。
- config 未启用的 Tile parameter/output 不得出现。
- TGEMV 的所有 operand 都必须留在 Local `B.IOT` stream。
- Cooperative TMATMUL 不得重复编码已由 `B.IOS` 提供的 source。

## 示例

```asm
/* 每个 selected PE 分配 1 KiB；Core 总量为 popcount(mask) * 1 KiB */
B.IOT T#1, U#2, mask=1111, last, ->T<1KB>

/* Local-to-Shared：B.IOT 只绑定 Local source */
B.IOS mask=1100, ->S17<100>
B.IOT T#1, mask=1100, last

/* Cooperative Shared-B CUBE */
B.IOS S17, mask=1111
B.IOT T#1, mask=1111, last, ->T<1KB>
```
