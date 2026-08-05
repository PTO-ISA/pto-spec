---
{
  "schema_version": 1,
  "id": "intrinsic.tadds",
  "kind": "intrinsic",
  "title": "TADDS Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "TADDS.md",
    "pto": "tile/ops/tile-scalar-and-immediate/tadds.md"
  },
  "opcode": "TADDS",
  "family": "tile-scalar",
  "bundle": "BSTART.TEPL TADDS, DataType\nB.DATR (optional)\nB.DIM LB0\nB.DIM (LB1/LB2 for 2D)\nB.IOT\nB.IOR",
  "operands": {
    "output": "dst tile",
    "input0": "src tile",
    "input1": "scalar GPR/immediate (via B.IOR)",
    "input2": null
  },
  "dtypes": [
    "U8",
    "S8",
    "U16",
    "S16",
    "U32",
    "S32",
    "F16",
    "F32",
    "BF16"
  ],
  "encoding": {
    "block": "TEPL",
    "mode": 1,
    "function": 0,
    "tile_op": "0x20"
  },
  "xlsx": {
    "include": true,
    "category": "Tile Scalar Elementwise\n逐元素和单标量输入",
    "subcategory": "算数计算",
    "order": 26,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TADDS Intrinsic

> 状态：DavinciOO v5 superscalar 指令页。本文只描述 `TADDS` 的 PTO 语义、DavinciOO block intrinsic 展开与合法性；公共 header 的 opcode/bitfield 编码见 [`header/`](../bundle/overview/block-header-model.md)。

## PTO 语义来源

- PTO 来源页：[`../pto/TADDS.md`](../pto/TADDS.md)
- PTO 指令名：`TADDS`
- C++ intrinsic / RecordEvent 签名摘录：

```cpp
template <typename TileDataDst, typename TileDataSrc, typename... WaitEvents>
PTO_INST RecordEvent TADDS(TileDataDst &dst, TileDataSrc &src0, typename TileDataSrc::DType scalar, WaitEvents &... events);
```

PTO/DavinciOO 语义摘要：Tile 与 scalar 的逐元素加法。执行域由 destination tile 的 valid region 与 `LB0/LB1/LB2` 描述的 PE-local block dimension 共同约束；dtype、mask/index、round/sat 等高级语义以 PTO 来源页和当前 active profile 为准。

## DavinciOO 汇编语法

DavinciOO v5 采用 Linx-style header-form intrinsic：

```asm
TADDS <LB0:ValidCol, LB1:ValidRow, LB2:Col, DataType, PadValue>, SrcTile0, Scalar, ->DstTile<Size>
```

参数说明：

| 参数 | 说明 |
| --- | --- |
| `ValidCol` | 有效列数，写入 `LB0`；一维场景可只声明 `LB0`。 |
| `ValidRow` | 有效行数，写入 `LB1`；二维场景需要声明。 |
| `Col` | Tile 总列数，写入 `LB2`；二维 row-major 访问中也是第二行起始 stride，单位为 element。 |
| `DataType` | 主计算数据类型，编码在 `BSTART.TEPL`。 |
| `PadValue` | destination valid-region 外的填充值策略，由 `B.DATR` 表达；省略 `B.DATR` 时使用默认 `PadValue=Zero`。 |
| `SrcTile*` | Linx-style 6-bit TReg namespace 中的 source Tile operand，顺序必须与 intrinsic operand role 一致。 |
| `Scalar` | scalar/GPR operand，通过 `B.IOR` 绑定；也可由前序 scalar 指令或立即数 lowering 准备。 |
| `DstTile<Size>` | destination Tile queue 与 allocation size class，由 `B.IOT` 的 `DstTile/TSize` 表达。 |

## DavinciOO Block Intrinsic

DavinciOO v5 Local form 示例：

```asm
BSTART.TEPL TADDS, FP16
B.DATR      PadValue.Null       # 可省略；省略时使用默认 data attribute，包括 PadValue=Zero
B.DIM       rValidCol, 0, ->LB0 # ValidCol；一维 TADDS 可只保留这一维
B.DIM       rValidRow, 0, ->LB1 # ValidRow；二维 TADDS 需要
B.DIM       rCol, 0, ->LB2      # Col / row stride；二维 TADDS 需要，用于计算第二行起始位置
B.IOT       T#10, mask=1111, last, ->T<1KB>
B.IOR       s0                       # Scalar operand；由 scalar/GPR 或立即数 lowering 准备
```

说明：

- DavinciOO v5 Local form follows the Linx block/header contract and executes on the selected PE payloads.
- Tile operand binding 使用 `B.IOT`；多 source / 多 output intrinsic 使用多条 `B.IOT` 顺序表达，最后一条设置 `last`。
- `B.DIM LB0/LB1/LB2` 分别表达 `ValidCol/ValidRow/Col`。二维 `TADDS` 需要 `LB2`，因为 `Col` 决定 row-major Tile 中下一行的起始 stride。
- `B.DATR` 只在需要非默认 data attribute 时发出；默认填零时可以省略。
- Output size uses `B.IOT.TSize=001..111` for a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).

## Header 展开说明

| Header | 本指令用途 | 公共定义 |
| --- | --- | --- |
| `BSTART.TEPL` | 选择 `TADDS` opcode profile 与主 `DataType` | [`header/BSTART.TEPL.md`](../bundle/BSTART.TEPL.md) |
| `B.DATR` | 可选；描述 `PadValue`、dtype 扩展、round/sat/compare 等非默认数据属性 | [`header/B.DATR.md`](../bundle/B.DATR.md) |
| `B.DIM` | 描述 `ValidCol/ValidRow/Col`，即 `LB0/LB1/LB2` | [`header/B.DIM.md`](../bundle/B.DIM.md) |
| `B.IOT` | 绑定 source/destination Tile operand 并声明 output size class | [`header/B.IOT.md`](../bundle/B.IOT.md) |
| `B.IOR` | 绑定 scalar GPR operand | [`header/B.IOR.md`](../bundle/B.IOR.md) |

## 约束与合法性

- Source/destination Tile operand 使用 Linx-style 6-bit / 64-entry TReg namespace：`T#1..T#16`、`U#1..U#16`、`M#1..M#16`、`N#1..N#16`。
- `B.IOT` 中表达的 operand 顺序必须与 intrinsic operand role 保持一致。
- 一个 block 中最后一条 `B.IOT` 必须设置 `last`；只有一条 `B.IOT` 时也必须设置 `last`。
- `B.IOT.TSize=001..111` encodes a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).
- 二维 `TADDS` 的 `ValidCol/ValidRow/Col` 均为 16-bit dimension 值，并应满足 `ValidCol <= Col`。
- Source/destination 的 dtype、valid region、mask/index 或 scalar contract 必须兼容；不兼容时硬件不保证结果正确性或应触发 profile-defined trap。
- Source OOB 行为本轮不定义；PTO source OOB 中文/英文页差异后续在统一遗留项中收口。
- 本指令不隐含 memory ordering、cross-PE visibility 或 group-level barrier。

## Lowering 摘要

1. Frontend 从 PTO `TADDS` intrinsic 取得 operand role、dtype、shape/valid 信息、row stride、scalar/mask/index operand 和 destination allocation size。
2. Lowering 生成 `BSTART.TEPL`、所需 `B.DIM` 与一条或多条 `B.IOT`；只有存在非默认 data attribute 时才生成 `B.DATR`，只有存在 scalar/GPR operand 时才生成 `B.IOR`。
3. Decoder 收集 block header，建立内部 tile uop/profile，并绑定 source/destination Tile operand。
4. Issue 阶段读取相关 Tile rename/allocation metadata，检查 dtype、shape、stride、size 与 operand role 兼容性。
5. Execute 阶段按 PTO `TADDS` 语义执行；retire 阶段提交 destination Tile 映射，source 生命周期由 reader/版本记账自动管理。
