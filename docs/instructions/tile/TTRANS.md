---
{
  "schema_version": 1,
  "id": "intrinsic.ttrans",
  "kind": "intrinsic",
  "title": "TTRANS Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "TTRANS.md",
    "pto": "tile/ops/layout-and-rearrangement/ttrans.md"
  },
  "opcode": "TTRANS",
  "family": "layout-movement",
  "bundle": "BSTART.TEPL TTRANS, DataType\nB.DATR (optional)\nB.DIM LB0\nB.DIM (LB1/LB2 for 2D)\nB.IOT",
  "operands": {
    "output": "dst transposed tile",
    "input0": "src tile",
    "input1": null,
    "input2": null
  },
  "dtypes": [
    "U32",
    "S32",
    "F32",
    "U16",
    "S16",
    "F16",
    "BF16",
    "U8",
    "S8"
  ],
  "encoding": {
    "block": "TEPL",
    "mode": 3,
    "function": 14,
    "tile_op": "0x6E"
  },
  "xlsx": {
    "include": true,
    "category": "Complex Layout Transformation\n复杂变换操作",
    "subcategory": "Layout变换",
    "order": 94,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TTRANS Intrinsic

> 状态：DavinciOO v5 superscalar 指令页。本文只描述 `TTRANS` 的 PTO 语义、DavinciOO block intrinsic 展开与合法性；公共 header 的 opcode/bitfield 编码见 [`header/`](../block/overview/block-header-model.md)。

## PTO 语义来源

- PTO 来源页：[`../pto/TTRANS.md`](../pto/TTRANS.md)
- PTO 指令名：`TTRANS`
- C++ intrinsic / RecordEvent 签名摘录：

```cpp
template <typename TileDataDst, typename TileDataSrc, typename TileDataTmp, typename... WaitEvents>
PTO_INST RecordEvent TTRANS(TileDataDst &dst, TileDataSrc &src, TileDataTmp &tmp, WaitEvents &... events);
```

PTO/DavinciOO 语义摘要：Tile transpose。执行域由 destination tile 的 valid region 与 `LB0/LB1/LB2` 描述的 PE-local block dimension 共同约束；dtype、mask/index、round/sat 等高级语义以 PTO 来源页和当前 active profile 为准。

## DavinciOO 汇编语法

DavinciOO v5 采用 Linx-style header-form intrinsic：

```asm
TTRANS <LB0:ValidCol, LB1:ValidRow, LB2:Col, DataType, PadValue>, SrcTile0,
       DepSrc0, DepSrc1, DepSrc2, ->DstTile<Size>, DepDst
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
| `DstTile<Size>` | destination Tile queue 与 allocation size class，由 `B.IOT` 的 `DstTile/TSize` 表达。 |
| `DepSrc0/1/2` | 可选 block dependency source，由 `B.IOD` 表达；无显式依赖时省略。 |
| `DepDst` | 可选 block dependency output/barrier，由 `B.IOD` 表达；无后续依赖消费者时省略。 |

## DavinciOO Block Intrinsic

DavinciOO v5 Local form 示例：

```asm
BSTART.TEPL TTRANS, FP16
B.DATR      PadValue.Null       # 可省略；省略时使用默认 data attribute，包括 PadValue=Zero
B.DIM       rValidCol, 0, ->LB0 # ValidCol；一维 TTRANS 可只保留这一维
B.DIM       rValidRow, 0, ->LB1 # ValidRow；二维 TTRANS 需要
B.DIM       rCol, 0, ->LB2      # Col / row stride；二维 TTRANS 需要，用于计算第二行起始位置
B.IOT       T#10, mask=1111, last, ->T<1KB>
B.IOD       D#1, 0, 0, ->D      # 可选；无显式 block dependency / barrier 时省略
```

说明：

- DavinciOO v5 Local form follows the Linx block/header contract and executes on the selected PE payloads.
- Tile operand binding 使用 `B.IOT`；多 source / 多 output intrinsic 使用多条 `B.IOT` 顺序表达，最后一条设置 `last`。
- `B.DIM LB0/LB1/LB2` 分别表达 `ValidCol/ValidRow/Col`。二维 `TTRANS` 需要 `LB2`，因为 `Col` 决定 row-major Tile 中下一行的起始 stride。
- `B.DATR` 只在需要非默认 data attribute 时发出；默认填零时可以省略。
- `B.IOD` 用于声明显式 block dependency / barrier；它不是 memory fence，也不表示 cross-PE barrier。
- Output size uses `B.IOT.TSize=001..111` for a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).
- PTO C++ 签名中的 `tmp` 是高层接口 scratch；当前 PE-local 物理 ISA 不编码 `tmp`，也不把它作为 `B.IOT` operand。

## Header 展开说明

| Header | 本指令用途 | 公共定义 |
| --- | --- | --- |
| `BSTART.TEPL` | 选择 `TTRANS` opcode profile 与主 `DataType` | [`header/BSTART.TEPL.md`](../block/BSTART.TEPL.md) |
| `B.DATR` | 可选；描述 `PadValue`、dtype 扩展、round/sat/compare 等非默认数据属性 | [`header/B.DATR.md`](../block/B.DATR.md) |
| `B.DIM` | 描述 `ValidCol/ValidRow/Col`，即 `LB0/LB1/LB2` | [`header/B.DIM.md`](../block/B.DIM.md) |
| `B.IOT` | 绑定 source/destination Tile operand 并声明 output size class | [`header/B.IOT.md`](../block/B.IOT.md) |
| `B.IOD` | 可选；声明显式 block dependency source 与 output barrier | [`header/B.IOD.md`](../block/B.IOD.md) |

## 约束与合法性

- Source/destination Tile operand 使用 Linx-style 6-bit / 64-entry TReg namespace：`T#1..T#16`、`U#1..U#16`、`M#1..M#16`、`N#1..N#16`。
- `B.IOT` 中表达的 operand 顺序必须与 intrinsic operand role 保持一致。
- 一个 block 中最后一条 `B.IOT` 必须设置 `last`；只有一条 `B.IOT` 时也必须设置 `last`。
- `B.IOT.TSize=001..111` encodes a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).
- 二维 `TTRANS` 的 `ValidCol/ValidRow/Col` 均为 16-bit dimension 值，并应满足 `ValidCol <= Col`。
- Source/destination 的 dtype、valid region、mask/index 或 scalar contract 必须兼容；不兼容时硬件不保证结果正确性或应触发 profile-defined trap。
- Source OOB 行为本轮不定义；PTO source OOB 中文/英文页差异后续在统一遗留项中收口。
- `B.IOD` 仅表达 PE-local block scheduling dependency。未声明 `B.IOD` 时表示无显式 dependency/barrier，不隐含 memory fence。
- 本指令不隐含 memory ordering、cross-PE visibility 或 group-level barrier。

## Lowering 摘要

1. Frontend 从 PTO `TTRANS` intrinsic 取得 operand role、dtype、shape/valid 信息、row stride、scalar/mask/index operand 和 destination allocation size。
2. Lowering 生成 `BSTART.TEPL`、所需 `B.DIM` 与一条或多条 `B.IOT`；只有存在非默认 data attribute 时才生成 `B.DATR`，只有存在 scalar/GPR operand 时才生成 `B.IOR`，只有 PTO event / 显式调度依赖需要 block token 时才生成 `B.IOD`。
3. Decoder 收集 block header，建立内部 tile uop/profile，并绑定 source/destination Tile operand。
4. Issue 阶段读取相关 Tile rename/allocation metadata，检查 dtype、shape、stride、size 与 operand role 兼容性。
5. Execute 阶段按 PTO `TTRANS` 语义执行；retire 阶段提交 destination Tile 映射，source 生命周期由 reader/版本记账自动管理。
