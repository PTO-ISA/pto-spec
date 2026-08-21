---
{
  "schema_version": 1,
  "id": "intrinsic.mgather",
  "kind": "intrinsic",
  "title": "MGATHER Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "MGATHER.md",
    "pto": "tile/ops/memory-and-data-movement/mgather.md"
  },
  "opcode": "MGATHER",
  "family": "memory-tlsu",
  "bundle": "BSTART.TLSU MGATHER, DataType\nB.DATR (optional)\nB.DIM LB0\nB.DIM (LB1/LB2 for 2D)\nB.IOT\nB.IOR",
  "operands": {
    "output": "dst tile",
    "input0": "global memory/partition-view src",
    "input1": "signed/unsigned byte-displacement index tile",
    "input2": null
  },
  "dtypes": [
    "data: U8",
    "S8",
    "U16",
    "S16",
    "U32",
    "S32",
    "F16",
    "BF16",
    "F32; index: S32",
    "U32"
  ],
  "encoding": {
    "block": "TLSU",
    "function": 4
  },
  "xlsx": {
    "include": true,
    "category": "Tile Memory Operation\nTile级访存操作",
    "subcategory": "不规则访存",
    "order": 79,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# MGATHER Intrinsic

> 状态：DavinciOO v5 superscalar 指令页。本文只描述 `MGATHER` 的 PTO/Linx 语义、DavinciOO TLSU block intrinsic 展开与合法性；公共 header 的 opcode/bitfield 编码见 [`header/`](../bundle/overview/block-header-model.md)。

## PTO 语义来源

- PTO 来源页：[`../pto/MGATHER.md`](../pto/MGATHER.md)
- PTO 指令名：`MGATHER`
- C++ intrinsic / RecordEvent 签名摘录：

```cpp
template <typename TileDst, typename GlobalData, typename TileInd, typename... WaitEvents>
PTO_INST RecordEvent MGATHER(TileDst &dst, GlobalData &src, TileInd &indexes, WaitEvents &... events);
```

PTO/DavinciOO 语义摘要：将 `base + byte_displacement` 指定的离散 GM
元素聚集到 Tile 寄存器。IndexTile 元素不按 transfer dtype 再缩放。

## DavinciOO 汇编语法

DavinciOO v5 采用 Linx-style TLSU header-form intrinsic：

```asm
MGATHER <LB0:ValidCol, LB1:ValidRow, LB2:Col, DataType, PadValue>, IndexTile, [BaseGPR], ->DstTile<Size>
```

参数说明：

| 参数 | 说明 |
| --- | --- |
| `ValidCol` | 搬运有效列数，写入 `LB0`；一维场景可只声明 `LB0`。 |
| `ValidRow` | 搬运有效行数，写入 `LB1`；二维场景需要声明。 |
| `Col` | destination Tile 物理列数，写入 `LB2`；它不缩放 GM byte-displacement index。 |
| `DataType` | 搬运元素类型，编码在 `BSTART.TLSU`。 |
| `PadValue` | destination valid-region 外或 masked-off lane 的填充值策略，由 `B.DATR` 表达；省略 `B.DATR` 时使用默认 `PadValue=Zero`。 |
| `IndexTile` | PE-local signed/unsigned integer Tile；每个逻辑元素是相对 BaseGPR 的 byte displacement。 |
| `BaseGPR` | GM base byte address，通过 `B.IOR.RegSrc0` 声明；其余 B.IOR 字段为零。 |
| `DstTile<Size>` | destination Tile queue 与 allocation size class，由 `B.IOT` 的 `DstTile/TSize` 表达；store/scatter 类无 Tile destination。 |

## DavinciOO Block Intrinsic

Linx-style PE-local TLSU 示例：

```asm
BSTART.TLSU  MGATHER, U32
B.DATR      PadValue.Null       # 可省略；省略时使用默认 data attribute，包括 PadValue=Zero
B.DIM       rValidCol, 0, ->LB0 # ValidCol；一维 MGATHER 可只保留这一维
B.DIM       rValidRow, 0, ->LB1 # ValidRow；二维 MGATHER 需要
B.DIM       rCol, 0, ->LB2      # destination Tile 物理 Col
B.IOT       T#10, mask=1111, last, ->T<1KB>
B.IOR       a0, zero, zero      # RegSrc0=GM base byte address
```

说明：

- DavinciOO v5 Local form follows the Linx block/header contract and executes on the selected PE payloads.
- `BSTART.TLSU` 选择 TLSU data-movement family 和 `MGATHER` opcode profile。
- Tile operand binding 使用 `B.IOT`；GM base 使用 `B.IOR.RegSrc0`。
- `B.DIM LB0/LB1/LB2` 只表达 destination Tile 的 `ValidCol/ValidRow/Col`；GM 地址由 IndexTile 的 byte displacement 决定。
- `B.DATR` 只在需要非默认 data attribute 时发出；默认填零时可以省略。
- Output size uses `B.IOT.TSize=001..111` for a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).

## Header 展开说明

| Header | 本指令用途 | 公共定义 |
| --- | --- | --- |
| `BSTART.TLSU` | 选择 `MGATHER` opcode profile 与主 `DataType` | [`header/BSTART.TLSU.md`](../bundle/BSTART.TLSU.md) |
| `B.DATR` | 可选；描述 `PadValue`、dtype 扩展等非默认数据属性 | [`header/B.DATR.md`](../bundle/B.DATR.md) |
| `B.DIM` | 描述 `ValidCol/ValidRow/Col`，即 `LB0/LB1/LB2` | [`header/B.DIM.md`](../bundle/B.DIM.md) |
| `B.IOT` | 绑定 Tile operand 并声明 output size class（若有 Tile output） | [`header/B.IOT.md`](../bundle/B.IOT.md) |
| `B.IOR` | 声明 GM base byte address；未使用字段为零 | [`header/B.IOR.md`](../bundle/B.IOR.md) |

## 约束与合法性

- Tile operand 使用 Linx-style 6-bit / 64-entry TReg namespace：`T#1..T#16`、`U#1..U#16`、`M#1..M#16`、`N#1..N#16`。
- `B.IOT` 中表达的 operand 顺序必须与 `MGATHER` operand role 保持一致。
- 一个 block 中最后一条 `B.IOT` 必须设置 `last`；只有一条 `B.IOT` 时也必须设置 `last`。
- `B.IOT.TSize=001..111` encodes a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).
- 二维 `MGATHER` 的 `ValidCol/ValidRow/Col` 均为 16-bit dimension 值，并应满足 `ValidCol <= Col`。
- IndexTile 使用整数 dtype；其元素直接作为 byte displacement。Packed four-bit transfer dtype 因缺少 nibble selector 而在访存前拒绝。
- GM base、byte displacement、alignment、dtype、mask 和 access size 约束由 PTO/Linx 来源页和当前 TLSU target profile 共同约束。
- 本指令不隐含 cross-PE visibility 或 group-level barrier。

## Lowering 摘要

1. Frontend 从 `MGATHER` intrinsic 取得 GM base、byte-displacement IndexTile、dtype、shape/valid 信息和 destination allocation size。
2. Lowering 生成 `BSTART.TLSU`、所需 `B.DIM`、`B.IOT` 和 `B.IOR`；只有存在非默认 data attribute 时才生成 `B.DATR`。
3. Decoder 收集 block header，建立内部 TLSU uop/profile，并绑定 Tile 与 GPR operand。
4. Issue 阶段检查 GM base、byte displacement、dtype、shape、size 与 operand role 兼容性。
5. Execute 阶段按 `MGATHER` 语义执行 TLSU 搬运；retire 阶段提交 destination Tile 映射或 store/scatter side effect。
