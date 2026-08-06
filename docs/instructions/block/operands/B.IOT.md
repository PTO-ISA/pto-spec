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

B.IOT 绑定 Matrix 的 Local source、显式 C/Bias、PostProcess Tile parameter，以及 D/RowMaxOut/GroupMaxOut。它不再表示 implicit ACC destination。

## 汇编语法

```asm
B.IOT SrcTile0, SrcTile1, mask=PE_MASK <,last>, ->DstTile<SIZE>
B.IOT SrcTile0, mask=PE_MASK, TSize=SIZE <,last>
B.IOT mask=PE_MASK, last
```

第一种是普通 Local destination form；destination allocation size 只由
`->DstTile<SIZE>` 表达，不再重复书写 `TSize=SIZE`。第二种是 TMOV
Local-to-Shared 的 source-only form：它没有 Local destination TReg，使用
`TSize=SIZE` 声明 Shared destination size。第三种是 Shared TLOAD/TSTORE 的
optional mask-only companion；省略时 effective mask 为 `1111`。mask-only
form 的 source、destination 和 TSize 编码必须全零。其他 one-source 与
no-source form 省略无效 source operand。v5 不存在 `.reuse` modifier。

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
| `[6:4]` | `Opc1` | 3 | `1` |
| `[3:1]` | `Opcode` | 3 | `1` |
| `[0]` | `W` | 1 | `1` |

## 字段

Matrix logical operand 顺序由 Function 与 PostProcessConfig 固定。Local
stream 移除所有已由 C.B.IOS 绑定的 Shared role；destination 顺序固定为
D、RowMaxOut、GroupMaxOut。Shared form 中 PE_MASK 是四位 quarter predicate：
允许多位，`0000` 是 no-op，selected quarter 保持固定 offset 而不 pack。

## 示例

```asm
/* two Local inputs, one 4 KB logical output */
B.IOT T#1, U#2, mask=1111, last, ->T<4KB>

/* source-only store; size comes from source descriptor */
B.IOT T#1, mask=1111, last

/* TMOV Local-to-Shared; no Local destination TReg */
B.IOT T#1, mask=1100, TSize=4KB, last

/* Shared-B CUBE: Shared prefix removes Right from Local stream */
C.B.IOS S17
B.IOT T#1, mask=1111, last

/* Shared TLOAD/TSTORE quarter predicate; all non-mask fields are zero */
B.IOT mask=0101, last
```

## 合法性

- 最后一条 B.IOT 必须设置 last。
- D 和 auxiliary output 必须是 Local TReg destination。
- 普通 Local destination form 必须把 size 写在 `->DstTile<SIZE>` 中，不得同时书写 `TSize=SIZE`。
- 仅 TMOV Local-to-Shared source-only form 使用无 destination TReg 的 `TSize=SIZE` 语法。
- source-only store 不显式书写 size；编码中的 `TSize=000` 表示 size 来自 source descriptor。
- config 未启用的 Tile parameter/output 不得出现。
- TGEMV 的所有 operand 都必须留在 Local B.IOT stream。
- cooperative TMATMUL 不得重复编码已由 C.B.IOS 提供的 source。
- Shared TLOAD/TSTORE 最多一个 mask-only companion；没有 companion 等价于
  `mask=1111`，而 `mask=0000` 不访问 Shared 或 memory state。
