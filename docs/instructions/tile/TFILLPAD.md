---
{
  "schema_version": 1,
  "id": "intrinsic.tfillpad",
  "kind": "intrinsic",
  "title": "TFILLPAD Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "TFILLPAD.md",
    "pto": "tile/ops/layout-and-rearrangement/tfillpad.md"
  },
  "opcode": "TFILLPAD",
  "family": "layout-movement",
  "bundle": "BSTART.TEPL TFILLPAD, DataType\nB.DATR (optional)\nB.DIM LB0\nB.DIM (LB1/LB2 for 2D)\nB.IOT",
  "operands": {
    "output": "dst padded tile",
    "input0": "src tile",
    "input1": "PadValue attr via B.DATR",
    "input2": null
  },
  "dtypes": [
    "1/2/4-byte element types; src/dst same size (S/U8",
    "S/U16",
    "F16/BF16",
    "S/U32/F32)"
  ],
  "encoding": {
    "block": "TEPL",
    "mode": 3,
    "function": 5,
    "tile_op": "0x65"
  },
  "xlsx": {
    "include": true,
    "category": "Complex Layout Transformation\n复杂变换操作",
    "subcategory": "初始化操作",
    "order": 85,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TFILLPAD Intrinsic

> 状态：DavinciOO v5 superscalar 指令页。本文只描述 `TFILLPAD` 的 PTO 语义、DavinciOO block intrinsic 展开与合法性；公共 header 的 opcode/bitfield 编码见 [`header/`](../block/overview/block-header-model.md)。

## PTO 语义来源

- PTO 来源页：[`../pto/TFILLPAD.md`](../pto/TFILLPAD.md)
- PTO 指令名：`TFILLPAD`
- C++ intrinsic / RecordEvent 签名摘录：

```cpp
template <typename TileData, PadValue PadVal = PadValue::Zero, typename... WaitEvents>
PTO_INST RecordEvent TFILLPAD(TileData &dst, TileData &src, WaitEvents &... events);

template <typename DstTileData, typename SrcTileData, typename... WaitEvents>
PTO_INST RecordEvent TFILLPAD(DstTileData &dst, SrcTileData &src, WaitEvents &... events);
```

PTO/DavinciOO 语义摘要：复制 source valid region，并把 destination padding region 写成编译期/attribute 确定的 PadValue。

变体说明：

- `TFILLPAD_INPLACE` 和 `TFILLPAD_EXPAND` 作为 `TFILLPAD` opcode profile 变体描述，不单独分配 `BSTART.TEPL` function，也不新增 xlsx row。

## DavinciOO 汇编语法

DavinciOO v5 采用 Linx-style header-form intrinsic：

```asm
TFILLPAD <LB0:ValidCol, LB1:ValidRow, LB2:Col, DataType, PadValue>, SrcTile, ->DstTile<Size>
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
| `DstTile<Size>` | destination Tile queue 与 allocation size class，由 `B.IOT` 的 `DstTile/TSize` 表达。 |

## DavinciOO Block Intrinsic

DavinciOO v5 Local form 示例：

```asm
BSTART.TEPL TFILLPAD, FP16
B.DATR      PadValue.Null       # 可省略；省略时使用默认 data attribute
B.DIM       rValidCol, 0, ->LB0 # ValidCol；一维 TFILLPAD 可只保留这一维
B.DIM       rValidRow, 0, ->LB1 # ValidRow；二维 TFILLPAD 需要
B.DIM       rCol, 0, ->LB2      # Col / row stride；二维 TFILLPAD 需要
B.IOT       T#10, mask=1111, last, ->T<1KB>
```

说明：

- DavinciOO v5 Local form follows the Linx block/header contract and executes on the selected PE payloads.
- Tile operand binding 使用 `B.IOT`；多 source / 多 output intrinsic 使用多条 `B.IOT` 顺序表达，最后一条设置 `last`。
- `B.DIM LB0/LB1/LB2` 分别表达 `ValidCol/ValidRow/Col`。二维 `TFILLPAD` 需要 `LB2`，因为 `Col` 决定 row-major Tile 中下一行的起始 stride。
- `B.DATR` 只在需要非默认 data attribute 时发出；默认属性可省略。
- Output size uses `B.IOT.TSize=001..111` for a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).
- `B.DATR` 承载 PadValue/profile attribute；默认属性可省略。

## Header 展开说明

| Header | 本指令用途 | 公共定义 |
| --- | --- | --- |
| `BSTART.TEPL` | 选择 `TFILLPAD` opcode profile 与主 `DataType` | [`header/BSTART.TEPL.md`](../block/BSTART.TEPL.md) |
| `B.DATR` | 可选；描述 PadValue、dtype/profile、round/sat 或其它非默认数据属性 | [`header/B.DATR.md`](../block/B.DATR.md) |
| `B.DIM` | 描述 `ValidCol/ValidRow/Col`，即 `LB0/LB1/LB2` | [`header/B.DIM.md`](../block/B.DIM.md) |
| `B.IOT` | 绑定 source/destination Tile operand 并声明 output size class | [`header/B.IOT.md`](../block/B.IOT.md) |

## 约束与合法性

- Source/destination Tile operand 使用 Linx-style 6-bit / 64-entry TReg namespace：`T#1..T#16`、`U#1..U#16`、`M#1..M#16`、`N#1..N#16`。
- `B.IOT` 中表达的 operand 顺序必须与 intrinsic operand role 保持一致。
- 一个 block 中最后一条 `B.IOT` 必须设置 `last`；只有一条 `B.IOT` 时也必须设置 `last`。
- `B.IOT.TSize=001..111` encodes a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).
- 二维 `TFILLPAD` 的 `ValidCol/ValidRow/Col` 均为 16-bit dimension 值，并应满足 `ValidCol <= Col`。
- `TileDataDst::PadVal != PadValue::Null`。
- `sizeof(TileDataDst::DType) == sizeof(TileDataSrc::DType)`，且 element size 必须为 1、2 或 4 bytes。
- `TFILLPAD` 要求 dst/source Rows/Cols 匹配；`TFILLPAD_EXPAND` 允许 dst Rows/Cols 大于等于 source Rows/Cols。
- 本指令不隐含 memory ordering、cross-PE visibility 或 group-level barrier。

## Lowering 摘要

1. Frontend 从 PTO `TFILLPAD` intrinsic 取得 operand role、dtype、shape/valid 信息、row stride、profile/scalar 参数和 destination allocation size。
2. Lowering 生成 `BSTART.TEPL`、所需 `B.DIM` 与一条或多条 `B.IOT`；只有存在非默认 data attribute 时才生成 `B.DATR`，只有存在 scalar/GPR/address/index/profile operand 时才生成 `B.IOR`。
3. Decoder 收集 block header，建立内部 tile uop/profile，并绑定 source/destination Tile operand。
4. Issue 阶段读取相关 Tile rename/allocation metadata，检查 dtype、shape、stride、size 与 operand role 兼容性。
5. Execute 阶段按 PTO `TFILLPAD` 语义执行；retire 阶段提交 destination Tile 映射，source 生命周期由 reader/版本记账自动管理。
