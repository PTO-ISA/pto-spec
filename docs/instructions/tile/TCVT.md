---
{
  "schema_version": 1,
  "id": "intrinsic.tcvt",
  "kind": "intrinsic",
  "title": "TCVT Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "TCVT.md",
    "pto": "tile/ops/elementwise-tile-tile/tcvt.md"
  },
  "opcode": "TCVT",
  "family": "element-wise",
  "bundle": "BSTART.TEPL TCVT, DataType\nB.DATR (optional)\nB.DIM LB0\nB.DIM (LB1/LB2 for 2D)\nB.IOT",
  "operands": {
    "output": "dst tile (converted dtype)",
    "input0": "src tile",
    "input1": "round/sat attrs via B.DATR",
    "input2": null
  },
  "dtypes": [
    "A5 src->dst pairs over S8/U8/S16/U16/S32/U32/S64",
    "F16/BF16/F32",
    "FP8/FP4/e8m0; exact pair depends on RoundMode/SaturationMode"
  ],
  "encoding": {
    "block": "TEPL",
    "mode": 0,
    "function": 27,
    "tile_op": "0x1B"
  },
  "xlsx": {
    "include": true,
    "category": "Complex Layout Transformation\n复杂变换操作",
    "subcategory": "格式转换",
    "order": 86,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TCVT Intrinsic

> 状态：DavinciOO v5 superscalar 指令页。本文只描述 `TCVT` 的 PTO 语义、DavinciOO block intrinsic 展开与合法性；公共 header 的 opcode/bitfield 编码见 [`header/`](../block/overview/block-header-model.md)。

## PTO 语义来源

- PTO 来源页：[`../pto/TCVT.md`](../pto/TCVT.md)
- PTO 指令名：`TCVT`
- C++ intrinsic / RecordEvent 签名摘录：

```cpp
template <typename TileDataD, typename TileDataS, typename... WaitEvents>
PTO_INST RecordEvent TCVT(TileDataD &dst, TileDataS &src, RoundMode mode, SaturationMode satMode, WaitEvents &... events);

template <typename TileDataD, typename TileDataS, typename... WaitEvents>
PTO_INST RecordEvent TCVT(TileDataD &dst, TileDataS &src, RoundMode mode, WaitEvents &... events);
```

PTO/DavinciOO 语义摘要：Tile 的逐元素数据格式转换。`BSTART.TEPL` 的 `DataType` 表达 source element type；`B.DATR.DataType` 表达 destination element type，并同时承载 `RMode/Sat` 转换属性。执行域由 destination tile 的 valid region 与 `LB0/LB1/LB2` 描述的 PE-local block dimension 共同约束；dtype、mask/index、round/sat 等高级语义以 PTO 来源页和当前 active profile 为准。

## DavinciOO 汇编语法

DavinciOO v5 采用 Linx-style header-form intrinsic：

```asm
TCVT <LB0:ValidCol, LB1:ValidRow, LB2:Col, SrcType, DstType, PadValue, RMode, Sat>, SrcTile, ->DstTile<Size>
```

参数说明：

| 参数 | 说明 |
| --- | --- |
| `ValidCol` | 有效列数，写入 `LB0`；一维场景可只声明 `LB0`。 |
| `ValidRow` | 有效行数，写入 `LB1`；二维场景需要声明。 |
| `Col` | Tile 总列数，写入 `LB2`；二维 row-major 访问中也是第二行起始 stride，单位为 element。 |
| `SrcType` | Source element type，编码在 `BSTART.TEPL`。 |
| `DstType` | Destination element type，编码在 `B.DATR.DataType`；这是 `TCVT` 的必需语义字段。 |
| `PadValue` | destination valid-region 外的填充值策略，由 `B.DATR.PadValue` 表达；未显式设置时使用 profile 默认值。 |
| `RMode` | 转换舍入模式，编码在 `B.DATR.RMode`；PTO `RoundMode` 参数必须 lowering 到该字段。 |
| `Sat` | 饱和模式，编码在 `B.DATR.S`；无饱和时显式或默认编码为 disabled。 |
| `SrcTile` | Linx-style 6-bit TReg namespace 中的 source Tile operand。 |
| `DstTile<Size>` | destination Tile queue 与 allocation size class，由 `B.IOT` 的 `DstTile/TSize` 表达。 |

## DavinciOO Block Intrinsic

DavinciOO v5 Local form 示例：

```asm
BSTART.TEPL TCVT, FP32         # SrcType
B.DATR      DataType.FP16, RMode.RNE, Sat, PadValue.Null # 必需；DstType/RMode/Sat，PadValue 可按需设置
B.DIM       rValidCol, 0, ->LB0 # ValidCol；一维 TCVT 可只保留这一维
B.DIM       rValidRow, 0, ->LB1 # ValidRow；二维 TCVT 需要
B.DIM       rCol, 0, ->LB2      # Col / row stride；二维 TCVT 需要，用于计算第二行起始位置
B.IOT       T#10, mask=1111, last, ->T<1KB>
```

说明：

- DavinciOO v5 Local form follows the Linx block/header contract and executes on the selected PE payloads.
- Tile operand binding 使用 `B.IOT`；多 source / 多 output intrinsic 使用多条 `B.IOT` 顺序表达，最后一条设置 `last`。
- `B.DIM LB0/LB1/LB2` 分别表达 `ValidCol/ValidRow/Col`。二维 `TCVT` 需要 `LB2`，因为 `Col` 决定 row-major Tile 中下一行的起始 stride。
- `B.DATR` 对 `TCVT` 不是普通 optional padding header：`DstType/RMode/Sat` 是转换语义的一部分，lowering 必须为每条 `TCVT` 确定这些字段。`PadValue` 仍然只是同一条 `B.DATR` 中的可选 data attribute。
- Output size uses `B.IOT.TSize=001..111` for a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).

## Header 展开说明

| Header | 本指令用途 | 公共定义 |
| --- | --- | --- |
| `BSTART.TEPL` | 选择 `TCVT` opcode profile 与 `SrcType` | [`header/BSTART.TEPL.md`](../block/BSTART.TEPL.md) |
| `B.DATR` | 必需；描述 `DstType/RMode/Sat`，并可同时描述 `PadValue` 等 data attribute | [`header/B.DATR.md`](../block/B.DATR.md) |
| `B.DIM` | 描述 `ValidCol/ValidRow/Col`，即 `LB0/LB1/LB2` | [`header/B.DIM.md`](../block/B.DIM.md) |
| `B.IOT` | 绑定 source/destination Tile operand 并声明 output size class | [`header/B.IOT.md`](../block/B.IOT.md) |

## 约束与合法性

- Source/destination Tile operand 使用 Linx-style 6-bit / 64-entry TReg namespace：`T#1..T#16`、`U#1..U#16`、`M#1..M#16`、`N#1..N#16`。
- `B.IOT` 中表达的 operand 顺序必须与 intrinsic operand role 保持一致。
- 一个 block 中最后一条 `B.IOT` 必须设置 `last`；只有一条 `B.IOT` 时也必须设置 `last`。
- `B.IOT.TSize=001..111` encodes a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).
- 二维 `TCVT` 的 `ValidCol/ValidRow/Col` 均为 16-bit dimension 值，并应满足 `ValidCol <= Col`。
- `BSTART.TEPL.DataType` 和 `B.DATR.DataType` 分别表示 `SrcType/DstType`，不得混用。
- `RMode/Sat` 必须来自 PTO intrinsic 参数或 profile 默认转换策略，并在 `B.DATR` 中形成确定编码。
- Source/destination 的 dtype、valid region、mask/index 或 scalar contract 必须兼容；不兼容时硬件不保证结果正确性或应触发 profile-defined trap。
- Source OOB 行为本轮不定义；PTO source OOB 中文/英文页差异后续在统一遗留项中收口。
- 本指令不隐含 memory ordering、cross-PE visibility 或 group-level barrier。

## Lowering 摘要

1. Frontend 从 PTO `TCVT` intrinsic 取得 operand role、dtype、shape/valid 信息、row stride、scalar/mask/index operand 和 destination allocation size。
2. Lowering 生成 `BSTART.TEPL`、`B.DATR`、所需 `B.DIM` 与 `B.IOT`；`B.DATR` 中必须包含 `DstType/RMode/Sat` 的确定编码，`PadValue` 等属性按需合入同一 header。
3. Decoder 收集 block header，建立内部 tile uop/profile，并绑定 source/destination Tile operand。
4. Issue 阶段读取相关 Tile rename/allocation metadata，检查 dtype、shape、stride、size 与 operand role 兼容性。
5. Execute 阶段按 PTO `TCVT` 语义执行；retire 阶段提交 destination Tile 映射，source 生命周期由 reader/版本记账自动管理。
