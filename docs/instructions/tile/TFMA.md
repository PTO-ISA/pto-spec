---
{
  "schema_version": 1,
  "id": "intrinsic.tfma",
  "kind": "intrinsic",
  "title": "TFMA Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "TFMA.md"
  },
  "opcode": "TFMA",
  "family": "element-wise",
  "bundle": "BSTART.TEPL TFMA, DataType\nB.DATR (optional)\nB.DIM LB0\nB.DIM (LB1/LB2 for 2D)\nB.IOT\nB.IOT",
  "operands": {
    "output": "dst tile",
    "input0": "src0 tile",
    "input1": "src1 tile",
    "input2": "src2 tile"
  },
  "dtypes": [
    "F16",
    "F32",
    "BF16"
  ],
  "encoding": {
    "block": "TEPL",
    "mode": 0,
    "function": 28,
    "tile_op": "0x1C"
  },
  "xlsx": {
    "include": true,
    "category": "Tile-Tile Elementwise\n逐元素双输入\n短Latency",
    "subcategory": "算术计算",
    "order": 7,
    "description_section": "PTO/DavinciOO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TFMA Intrinsic

> 状态：DavinciOO v5 superscalar 指令页。本文定义 `TFMA` 作为 DavinciOO PTO-visible TEPL extension，描述其 fused multiply-add 语义、DavinciOO block intrinsic 展开与合法性；公共 header 的 opcode/bitfield 编码见 [`header/`](../block/overview/block-header-model.md)。

## PTO/DavinciOO 语义来源

- PTO 来源页：当前 PTO ISA 源树未找到现有 `TFMA` 独立来源页；本文按 DavinciOO active profile 新增 PE-local PTO-visible intrinsic。
- PTO 指令名：`TFMA`
- 语义定义：`dst = src0 * src1 + src2`

PTO/DavinciOO 语义摘要：`TFMA` 对三个 source Tile 做逐元素 fused multiply-add，语义为 `dst[i,j] = fma(src0[i,j], src1[i,j], src2[i,j])`。执行域由 destination tile 的 valid region 与 `LB0/LB1/LB2` 描述的 PE-local block dimension 共同约束；dtype、round/sat 等高级语义以当前 DavinciOO active profile 为准。`TFMA` 是 DavinciOO TEPL extension，编码为 `BSTART.TEPL Mode=0, Function=28`。

## DavinciOO 汇编语法

DavinciOO v5 采用 Linx-style header-form intrinsic：

```asm
TFMA <LB0:ValidCol, LB1:ValidRow, LB2:Col, DataType, PadValue>, SrcTile0, SrcTile1, SrcTile2, ->DstTile<Size>
```

参数说明：

| 参数 | 说明 |
| --- | --- |
| `ValidCol` | 有效列数，写入 `LB0`；一维场景可只声明 `LB0`。 |
| `ValidRow` | 有效行数，写入 `LB1`；二维场景需要声明。 |
| `Col` | Tile 总列数，写入 `LB2`；二维 row-major 访问中也是第二行起始 stride，单位为 element。 |
| `DataType` | 主计算数据类型，编码在 `BSTART.TEPL`。 |
| `PadValue` | destination valid-region 外的填充值策略，由 `B.DATR` 表达；省略 `B.DATR` 时使用默认 `PadValue=Zero`。 |
| `SrcTile0/1/2` | Linx-style 6-bit TReg namespace 中的 source Tile operand，分别对应 `a`、`b`、`c`。 |
| `DstTile<Size>` | destination Tile queue 与 allocation size class，由 `B.IOT` 的 `DstTile/TSize` 表达。 |

## DavinciOO Block Intrinsic

DavinciOO v5 Local form 示例：

```asm
BSTART.TEPL TFMA, FP16
B.DATR      PadValue.Null       # 可省略；省略时使用默认 data attribute，包括 PadValue=Zero
B.DIM       rValidCol, 0, ->LB0 # ValidCol；一维 TFMA 可只保留这一维
B.DIM       rValidRow, 0, ->LB1 # ValidRow；二维 TFMA 需要
B.DIM       rCol, 0, ->LB2      # Col / row stride；二维 TFMA 需要，用于计算第二行起始位置
B.IOT       T#10, T#11, mask=1111        # SrcTile0(a), SrcTile1(b)
B.IOT       T#12, mask=1111, last, ->T<1KB> # SrcTile2(c), DstTile
```

说明：

- DavinciOO v5 Local form follows the Linx block/header contract and executes on the selected PE payloads.
- Tile operand binding 使用 `B.IOT`；`TFMA` 有三个 source Tile，必须使用多条 `B.IOT` 顺序表达，最后一条设置 `last`。
- `B.DIM LB0/LB1/LB2` 分别表达 `ValidCol/ValidRow/Col`。二维 `TFMA` 需要 `LB2`，因为 `Col` 决定 row-major Tile 中下一行的起始 stride。
- `B.DATR` 只在需要非默认 data attribute 时发出；默认填零时可以省略。
- Output size uses `B.IOT.TSize=001..111` for a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).

## Header 展开说明

| Header | 本指令用途 | 公共定义 |
| --- | --- | --- |
| `BSTART.TEPL` | 选择 `TFMA` opcode profile 与主 `DataType` | [`header/BSTART.TEPL.md`](../block/BSTART.TEPL.md) |
| `B.DATR` | 可选；描述 `PadValue`、dtype 扩展、round/sat/compare 等非默认数据属性 | [`header/B.DATR.md`](../block/B.DATR.md) |
| `B.DIM` | 描述 `ValidCol/ValidRow/Col`，即 `LB0/LB1/LB2` | [`header/B.DIM.md`](../block/B.DIM.md) |
| `B.IOT` | 绑定 source/destination Tile operand 并声明 output size class | [`header/B.IOT.md`](../block/B.IOT.md) |

## 约束与合法性

- Source/destination Tile operand 使用 Linx-style 6-bit / 64-entry TReg namespace：`T#1..T#16`、`U#1..U#16`、`M#1..M#16`、`N#1..N#16`。
- `B.IOT` 中表达的 operand 顺序必须与 intrinsic operand role 保持一致：`src0(a)`、`src1(b)`、`src2(c)`、`dst`。
- 一个 block 中最后一条 `B.IOT` 必须设置 `last`；只有一条 `B.IOT` 时也必须设置 `last`。
- `B.IOT.TSize=001..111` encodes a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).
- 二维 `TFMA` 的 `ValidCol/ValidRow/Col` 均为 16-bit dimension 值，并应满足 `ValidCol <= Col`。
- Source/destination 的 dtype 和 valid region 必须兼容；不兼容时硬件不保证结果正确性或应触发 profile-defined trap。
- 对支持 fused floating-point 语义的 dtype/profile，乘法与加法作为一个 fused op 执行，不暴露中间 rounded product；其它 dtype/profile 的支持性与 rounding/overflow 行为为 profile-defined。
- 本指令不隐含 memory ordering、cross-PE visibility 或 group-level barrier。

## Lowering 摘要

1. Frontend 从 PTO `TFMA` intrinsic 取得 operand role、dtype、shape/valid 信息、row stride 和 destination allocation size。
2. Lowering 生成 `BSTART.TEPL`、所需 `B.DIM` 与两条 `B.IOT`；只有存在非默认 data attribute 时才生成 `B.DATR`。
3. Decoder 收集 block header，建立内部 tile uop/profile，并绑定 source/destination Tile operand。
4. Issue 阶段读取相关 Tile rename/allocation metadata，检查 dtype、shape、stride、size 与 operand role 兼容性。
5. Execute 阶段按 `dst = src0 * src1 + src2` fused multiply-add 语义执行；retire 阶段提交 destination Tile 映射，source 生命周期由 reader/版本记账自动管理。
