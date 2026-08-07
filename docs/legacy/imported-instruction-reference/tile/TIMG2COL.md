---
{
  "schema_version": 1,
  "id": "intrinsic.timg2col",
  "kind": "intrinsic",
  "title": "TIMG2COL Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "TIMG2COL.md",
    "pto": "tile/ops/layout-and-rearrangement/timg2col.md"
  },
  "opcode": "TIMG2COL",
  "family": "layout-movement",
  "bundle": "BSTART.TEPL TIMG2COL, DataType\nB.DATR (optional)\nB.DIM LB0\nB.DIM (LB1/LB2 for 2D)\nB.IOT\nB.IOR",
  "operands": {
    "output": "dst im2col/Left tile",
    "input0": "src ConvTile/feature tile",
    "input1": "posM/posK attrs via B.IOR",
    "input2": null
  },
  "dtypes": [
    "S8",
    "U8",
    "S16",
    "U16",
    "S32",
    "U32",
    "F16",
    "BF16",
    "F32"
  ],
  "encoding": {
    "block": "TEPL",
    "mode": 3,
    "function": 4,
    "tile_op": "0x64"
  },
  "xlsx": {
    "include": true,
    "category": "Complex Layout Transformation\n复杂变换操作",
    "subcategory": "Layout变换",
    "order": 95,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TIMG2COL Intrinsic

> 状态：DavinciOO v5 superscalar 指令页。本文只描述 `TIMG2COL` 的 PTO 语义、DavinciOO block intrinsic 展开与合法性；公共 header 的 opcode/bitfield 编码见 [`header/`](../block/overview/block-header-model.md)。

## PTO 语义来源

- PTO 来源页：[`../pto/TIMG2COL.md`](../pto/TIMG2COL.md)
- PTO 指令名：`TIMG2COL`
- C++ intrinsic / RecordEvent 签名摘录：

```cpp
template <typename TileData, typename ConvTileData, typename... WaitEvents>
PTO_INST RecordEvent TIMG2COL(TileData &dst, ConvTileData &src, uint16_t posM = 0, uint16_t posK = 0, WaitEvents &... events);
```

PTO/DavinciOO 语义摘要：把 feature-map/ConvTile 数据重排成 im2col-style matrix tile，连接卷积样式输入与后续 matrix path。

## DavinciOO 汇编语法

DavinciOO v5 采用 Linx-style header-form intrinsic：

```asm
TIMG2COL <LB0:ValidCol, LB1:ValidRow, LB2:Col, DataType>, SrcConvTile, posM, posK, ->DstTile<Size>
```

参数说明：

| 参数 | 说明 |
| --- | --- |
| `ValidCol` | 有效列数，写入 `LB0`；一维场景可只声明 `LB0`。 |
| `ValidRow` | 有效行数，写入 `LB1`；二维场景需要声明。 |
| `Col` | Tile 总列数，写入 `LB2`；二维 row-major 访问中也是第二行起始 stride，单位为 element。 |
| `DataType` | 主数据类型，编码在 `BSTART.TEPL`。 |
| `Data attributes` | 由 `B.DATR` 表达 PadValue、round/sat、quant profile 或其它非默认属性；省略时使用 profile 默认值。 |
| `Tile operands` | Linx-style 6-bit TReg namespace 中的 source/destination Tile operand，顺序必须与 intrinsic operand role 一致。 |
| `Scalar/GPR operands` | `B.IOR` 绑定本指令需要的标量、地址、index、key/counter 或 profile 参数。 |
| `DstTile<Size>` | destination Tile queue 与 allocation size class，由 `B.IOT` 的 `DstTile/TSize` 表达。 |

## DavinciOO Block Intrinsic

DavinciOO v5 Local form 示例：

```asm
BSTART.TEPL TIMG2COL, FP16
B.DATR      PadValue.Null       # 可省略；省略时使用默认 data attribute
B.DIM       rValidCol, 0, ->LB0 # ValidCol；一维 TIMG2COL 可只保留这一维
B.DIM       rValidRow, 0, ->LB1 # ValidRow；二维 TIMG2COL 需要
B.DIM       rCol, 0, ->LB2      # Col / row stride；二维 TIMG2COL 需要
B.IOT       T#10, mask=1111, last, ->T<1KB>
B.IOR       rPosM, rPosK, -, ->-
```

说明：

- DavinciOO v5 Local form follows the Linx block/header contract and executes on the selected PE payloads.
- Tile operand binding 使用 `B.IOT`；多 source / 多 output intrinsic 使用多条 `B.IOT` 顺序表达，最后一条设置 `last`。
- `B.DIM LB0/LB1/LB2` 分别表达 `ValidCol/ValidRow/Col`。二维 `TIMG2COL` 需要 `LB2`，因为 `Col` 决定 row-major Tile 中下一行的起始 stride。
- `B.DATR` 只在需要非默认 data attribute 时发出；默认属性可省略。
- Output size uses `B.IOT.TSize=001..111` for a `128 B..8 KB` per-PE Tile; Core allocation is `popcount(PE_MASK)` times that size.
- `B.IOR` 绑定 `posM/posK`；padding/repeat/config state 属于 opcode profile。
- `TSETFMATRIX`、`TSET_IMG2COL_RPT`、`TSET_IMG2COL_PADDING` 是相关配置面，不在本 xlsx row 展开为独立 operand。

## Header 展开说明

| Header | 本指令用途 | 公共定义 |
| --- | --- | --- |
| `BSTART.TEPL` | 选择 `TIMG2COL` opcode profile 与主 `DataType` | [`header/BSTART.TEPL.md`](../block/BSTART.TEPL.md) |
| `B.DATR` | 可选；描述 PadValue、dtype/profile、round/sat 或其它非默认数据属性 | [`header/B.DATR.md`](../block/B.DATR.md) |
| `B.DIM` | 描述 `ValidCol/ValidRow/Col`，即 `LB0/LB1/LB2` | [`header/B.DIM.md`](../block/B.DIM.md) |
| `B.IOT` | 绑定 source/destination Tile operand 并声明 output size class | [`header/B.IOT.md`](../block/B.IOT.md) |
| `B.IOR` | 绑定 scalar/GPR/address/index/profile operand | [`header/B.IOR.md`](../block/B.IOR.md) |

## 约束与合法性

- Source/destination Tile operand 使用 Linx-style 6-bit / 64-entry TReg namespace：`T#1..T#16`、`U#1..U#16`、`M#1..M#16`、`N#1..N#16`。
- `B.IOT` 中表达的 operand 顺序必须与 intrinsic operand role 保持一致。
- 一个 block 中最后一条 `B.IOT` 必须设置 `last`；只有一条 `B.IOT` 时也必须设置 `last`。
- `B.IOT.TSize=001..111` encodes a `128 B..8 KB` per-PE Tile; Core allocation is `popcount(PE_MASK)` times that size.
- 二维 `TIMG2COL` 的 `ValidCol/ValidRow/Col` 均为 16-bit dimension 值，并应满足 `ValidCol <= Col`。
- 支持的 ConvTile/Left tile 类型、padding、repeat 与 config fields 均为 target/implementation-defined。
- A2/A3 与 A5 的 img2col repeat/padding state 配置方式存在差异；本页只定义 `TIMG2COL` tile op 的 active block 展开。
- 本指令不隐含 memory ordering、cross-PE visibility 或 group-level barrier。

## Lowering 摘要

1. Frontend 从 PTO `TIMG2COL` intrinsic 取得 operand role、dtype、shape/valid 信息、row stride、profile/scalar 参数和 destination allocation size。
2. Lowering 生成 `BSTART.TEPL`、所需 `B.DIM` 与一条或多条 `B.IOT`；只有存在非默认 data attribute 时才生成 `B.DATR`，只有存在 scalar/GPR/address/index/profile operand 时才生成 `B.IOR`。
3. Decoder 收集 block header，建立内部 tile uop/profile，并绑定 source/destination Tile operand。
4. Issue 阶段读取相关 Tile rename/allocation metadata，检查 dtype、shape、stride、size 与 operand role 兼容性。
5. Execute 阶段按 PTO `TIMG2COL` 语义执行；retire 阶段提交 destination Tile 映射，source 生命周期由 reader/版本记账自动管理。
