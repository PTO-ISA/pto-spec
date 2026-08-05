---
{
  "schema_version": 1,
  "id": "intrinsic.tmrgsort",
  "kind": "intrinsic",
  "title": "TMRGSORT Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "TMRGSORT.md",
    "pto": "tile/ops/irregular-and-complex/tmrgsort.md"
  },
  "opcode": "TMRGSORT",
  "family": "complex-special",
  "bundle": "BSTART.TEPL TMRGSORT, DataType\nB.DATR (optional)\nB.DIM LB0\nB.DIM (LB1/LB2 for 2D)\nB.IOT\nB.IOR",
  "operands": {
    "output": "dst merged sorted list",
    "input0": "src list tile(s)",
    "input1": "blockLen or executed-count attrs",
    "input2": null
  },
  "dtypes": [
    "F16",
    "F32"
  ],
  "encoding": {
    "block": "TEPL",
    "mode": 3,
    "function": 13,
    "tile_op": "0x6D"
  },
  "xlsx": {
    "include": true,
    "category": "Complex Layout Transformation\n复杂变换操作",
    "subcategory": "排序",
    "order": 97,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TMRGSORT Intrinsic

> 状态：DavinciOO v5 superscalar 指令页。本文只描述 `TMRGSORT` 的 PTO 语义、DavinciOO block intrinsic 展开与合法性；公共 header 的 opcode/bitfield 编码见 [`header/`](../block/overview/block-header-model.md)。

## PTO 语义来源

- PTO 来源页：[`../pto/TMRGSORT.md`](../pto/TMRGSORT.md)
- PTO 指令名：`TMRGSORT`
- C++ intrinsic / RecordEvent 签名摘录：

```cpp
template <typename DstTileData, typename SrcTileData, typename... WaitEvents>
PTO_INST RecordEvent TMRGSORT(DstTileData &dst, SrcTileData &src, uint32_t blockLen, WaitEvents &... events);

template <typename DstTileData, typename TmpTileData, typename Src0TileData, typename Src1TileData, bool exhausted, typename... WaitEvents>
PTO_INST RecordEvent TMRGSORT(DstTileData &dst, MrgSortExecutedNumList &executedNumList, TmpTileData &tmp, Src0TileData &src0, Src1TileData &src1, WaitEvents &... events);
```

PTO/DavinciOO 语义摘要：把一个或多个已排序 list tile 合并成 destination sorted list；single-list 与 multi-list profile 的 operand set 不同。

## DavinciOO 汇编语法

DavinciOO v5 采用 Linx-style header-form intrinsic：

```asm
TMRGSORT <LB0:ValidCol, LB1:ValidRow, LB2:Col, DataType>, SrcTile, blockLen, ->DstTile<Size>
TMRGSORT.MULTI <LB0:ValidCol, LB1:ValidRow, LB2:Col, DataType>, SrcTile0, SrcTile1[, SrcTile2[, SrcTile3]], executed, exhausted, ->DstTile<Size>
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
BSTART.TEPL TMRGSORT, FP16
B.DATR      PadValue.Null       # 可省略；省略时使用默认 data attribute
B.DIM       rValidCol, 0, ->LB0 # ValidCol；一维 TMRGSORT 可只保留这一维
B.DIM       rValidRow, 0, ->LB1 # ValidRow；二维 TMRGSORT 需要
B.DIM       rCol, 0, ->LB2      # Col / row stride；二维 TMRGSORT 需要
B.IOT       T#10, mask=1111, last, ->T<1KB> # single-list source, DstTile
B.IOR       rBlockLen                  # single-list blockLen；multi-list executed/exhausted 由 profile/sideband 表达
```

说明：

- DavinciOO v5 Local form follows the Linx block/header contract and executes on the selected PE payloads.
- Tile operand binding 使用 `B.IOT`；多 source / 多 output intrinsic 使用多条 `B.IOT` 顺序表达，最后一条设置 `last`。
- `B.DIM LB0/LB1/LB2` 分别表达 `ValidCol/ValidRow/Col`。二维 `TMRGSORT` 需要 `LB2`，因为 `Col` 决定 row-major Tile 中下一行的起始 stride。
- `B.DATR` 只在需要非默认 data attribute 时发出；默认属性可省略。
- Output size uses `B.IOT.TSize=001..111` for a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).
- single-list profile 使用一个 source Tile 和 `B.IOR blockLen`。
- multi-list profile 使用 2 到 4 个 visible source Tile，超过两个 source 时按 `B.IOT` 顺序拆分；`executedNumList/exhausted` 通过 profile/sideband contract 表达。
- PTO C++ overload 中的 `tmp` 是高层接口 scratch；当前 PE-local 物理 ISA 不编码 `tmp`，也不把它作为 `B.IOT` operand。

## Header 展开说明

| Header | 本指令用途 | 公共定义 |
| --- | --- | --- |
| `BSTART.TEPL` | 选择 `TMRGSORT` opcode profile 与主 `DataType` | [`header/BSTART.TEPL.md`](../block/BSTART.TEPL.md) |
| `B.DATR` | 可选；描述 PadValue、dtype/profile、round/sat 或其它非默认数据属性 | [`header/B.DATR.md`](../block/B.DATR.md) |
| `B.DIM` | 描述 `ValidCol/ValidRow/Col`，即 `LB0/LB1/LB2` | [`header/B.DIM.md`](../block/B.DIM.md) |
| `B.IOT` | 绑定 source/destination Tile operand 并声明 output size class | [`header/B.IOT.md`](../block/B.IOT.md) |
| `B.IOR` | 绑定 scalar/GPR/address/index/profile operand | [`header/B.IOR.md`](../block/B.IOR.md) |

## 约束与合法性

- Source/destination Tile operand 使用 Linx-style 6-bit / 64-entry TReg namespace：`T#1..T#16`、`U#1..U#16`、`M#1..M#16`、`N#1..N#16`。
- `B.IOT` 中表达的 operand 顺序必须与 intrinsic operand role 保持一致。
- 一个 block 中最后一条 `B.IOT` 必须设置 `last`；只有一条 `B.IOT` 时也必须设置 `last`。
- `B.IOT.TSize=001..111` encodes a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).
- 二维 `TMRGSORT` 的 `ValidCol/ValidRow/Col` 均为 16-bit dimension 值，并应满足 `ValidCol <= Col`。
- Element type 必须为 `half` 或 `float`，并在 visible tile operands 间匹配。
- 所有 list tile 必须为 `TileType::Vec`、row-major，且 `Rows == 1`。
- single-list variant 要求 `blockLen` 为 64 的倍数，`src.GetValidCol()` 为 `blockLen * 4` 的整数倍，repeatTimes 在 `[1, 255]`。
- 本指令不隐含 memory ordering、cross-PE visibility 或 group-level barrier。

## Lowering 摘要

1. Frontend 从 PTO `TMRGSORT` intrinsic 取得 operand role、dtype、shape/valid 信息、row stride、profile/scalar 参数和 destination allocation size。
2. Lowering 生成 `BSTART.TEPL`、所需 `B.DIM` 与一条或多条 `B.IOT`；只有存在非默认 data attribute 时才生成 `B.DATR`，只有存在 scalar/GPR/address/index/profile operand 时才生成 `B.IOR`。
3. Decoder 收集 block header，建立内部 tile uop/profile，并绑定 source/destination Tile operand。
4. Issue 阶段读取相关 Tile rename/allocation metadata，检查 dtype、shape、stride、size 与 operand role 兼容性。
5. Execute 阶段按 PTO `TMRGSORT` 语义执行；retire 阶段提交 destination Tile 映射，source 生命周期由 reader/版本记账自动管理。
