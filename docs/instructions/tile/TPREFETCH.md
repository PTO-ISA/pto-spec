---
{
  "schema_version": 1,
  "id": "intrinsic.tprefetch",
  "kind": "intrinsic",
  "title": "TPREFETCH Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "TPREFETCH.md",
    "pto": "tile/ops/memory-and-data-movement/tprefetch.md"
  },
  "opcode": "TPREFETCH",
  "family": "memory-tlsu",
  "bundle": "BSTART.TLSU TPREFETCH, DataType\nB.DATR (optional)\nB.DIM LB0\nB.DIM (LB1/LB2 for 2D)\nB.IOT\nB.IOR",
  "operands": {
    "output": "dst tile/cache target",
    "input0": "GM source address",
    "input1": "address/layout attrs",
    "input2": null
  },
  "dtypes": [
    "Same element dtype set as TLOAD profile; src/dst element size must match"
  ],
  "encoding": {
    "block": "TLSU",
    "function": 3
  },
  "xlsx": {
    "include": true,
    "category": "Tile Memory Operation\nTile级访存操作",
    "subcategory": "规则访存",
    "order": 78,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TPREFETCH Intrinsic

> 状态：DavinciOO v5 superscalar 指令页。本文只描述 `TPREFETCH` 的 PTO 语义、DavinciOO block intrinsic 展开与合法性；公共 header 的 opcode/bitfield 编码见 [`header/`](../block/overview/block-header-model.md)。

## PTO 语义来源

- PTO 来源页：[`../pto/TPREFETCH.md`](../pto/TPREFETCH.md)
- PTO 指令名：`TPREFETCH`
- C++ intrinsic / RecordEvent 签名摘录：

```cpp
template <typename TileData, typename GlobalData>
PTO_INST RecordEvent TPREFETCH(TileData &dst, GlobalData &src);
```

PTO/DavinciOO 语义摘要：从 global memory 预取数据到 tile-local cache/buffer。它是 TLSU 数据搬运/缓存 hint 类指令，本页按 `dst tile/cache target + GM source` 作为 ISA-visible operand model。

## DavinciOO 汇编语法

DavinciOO v5 采用 Linx-style header-form intrinsic：

```asm
TPREFETCH <LB0:ValidCol, LB1:ValidRow, LB2:Col, DataType>, GMAddr, ->DstTile<Size>
```

参数说明：

| 参数 | 说明 |
| --- | --- |
| `ValidCol` | 有效列数，写入 `LB0`；一维场景可只声明 `LB0`。 |
| `ValidRow` | 有效行数，写入 `LB1`；二维场景需要声明。 |
| `Col` | Tile 总列数，写入 `LB2`；二维 row-major 访问中也是第二行起始 stride，单位为 element。 |
| `DataType` | 主数据类型，编码在 `BSTART.TLSU`。 |
| `Data attributes` | 由 `B.DATR` 表达 PadValue、round/sat、quant profile 或其它非默认属性；省略时使用 profile 默认值。 |
| `Tile operands` | Linx-style 6-bit TReg namespace 中的 source/destination Tile operand，顺序必须与 intrinsic operand role 一致。 |
| `Scalar/GPR operands` | `B.IOR` 绑定本指令需要的标量、地址、index、key/counter 或 profile 参数。 |
| `DstTile<Size>` | destination Tile queue 与 allocation size class，由 `B.IOT` 的 `DstTile/TSize` 表达。 |

## DavinciOO Block Intrinsic

DavinciOO v5 Local form 示例：

```asm
BSTART.TLSU TPREFETCH, FP16
B.DATR      PadValue.Null       # 可省略；省略时使用默认 data attribute
B.DIM       rValidCol, 0, ->LB0 # ValidCol；一维 TPREFETCH 可只保留这一维
B.DIM       rValidRow, 0, ->LB1 # ValidRow；二维 TPREFETCH 需要
B.DIM       rCol, 0, ->LB2      # Col / row stride；二维 TPREFETCH 需要
B.IOT       mask=1111, last, ->T<1KB>
B.IOR       rBase, rOffset, rStride, ->- # GM source address/stride profile
```

说明：

- DavinciOO v5 Local form follows the Linx block/header contract and executes on the selected PE payloads.
- Tile operand binding 使用 `B.IOT`；多 source / 多 output intrinsic 使用多条 `B.IOT` 顺序表达，最后一条设置 `last`。
- `B.DIM LB0/LB1/LB2` 分别表达 `ValidCol/ValidRow/Col`。二维 `TPREFETCH` 需要 `LB2`，因为 `Col` 决定 row-major Tile 中下一行的起始 stride。
- `B.DATR` 只在需要非默认 data attribute 时发出；默认属性可省略。
- Output size uses `B.IOT.TSize=001..111` for a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).
- `B.IOT` 只声明 destination tile/cache target；GM source address/stride 由 `B.IOR` 绑定。
- PTO 文档明确 `TPREFETCH` 不隐式调用 `TSYNC(events...)`。

## Header 展开说明

| Header | 本指令用途 | 公共定义 |
| --- | --- | --- |
| `BSTART.TLSU` | 选择 `TPREFETCH` opcode profile 与主 `DataType` | [`header/BSTART.TLSU.md`](../block/BSTART.TLSU.md) |
| `B.DATR` | 可选；描述 PadValue、dtype/profile、round/sat 或其它非默认数据属性 | [`header/B.DATR.md`](../block/B.DATR.md) |
| `B.DIM` | 描述 `ValidCol/ValidRow/Col`，即 `LB0/LB1/LB2` | [`header/B.DIM.md`](../block/B.DIM.md) |
| `B.IOT` | 绑定 source/destination Tile operand 并声明 output size class | [`header/B.IOT.md`](../block/B.IOT.md) |
| `B.IOR` | 绑定 scalar/GPR/address/index/profile operand | [`header/B.IOR.md`](../block/B.IOR.md) |

## 约束与合法性

- Source/destination Tile operand 使用 Linx-style 6-bit / 64-entry TReg namespace：`T#1..T#16`、`U#1..U#16`、`M#1..M#16`、`N#1..N#16`。
- `B.IOT` 中表达的 operand 顺序必须与 intrinsic operand role 保持一致。
- 一个 block 中最后一条 `B.IOT` 必须设置 `last`；只有一条 `B.IOT` 时也必须设置 `last`。
- `B.IOT.TSize=001..111` encodes a `512 B..32 KB` logical Tile (`128 B..8 KB` per PE fragment).
- 二维 `TPREFETCH` 的 `ValidCol/ValidRow/Col` 均为 16-bit dimension 值，并应满足 `ValidCol <= Col`。
- GM address/stride、alignment、transfer shape 与 cache-fill 行为均为 target/implementation-defined。
- 部分 target 可以把 prefetch 当作 hint 或与后续 `TLOAD` 合并；软件不得依赖它产生跨 PE 可见性。
- 本指令不隐含 memory ordering、cross-PE visibility 或 group-level barrier。

## Lowering 摘要

1. Frontend 从 PTO `TPREFETCH` intrinsic 取得 operand role、dtype、shape/valid 信息、row stride、profile/scalar 参数和 destination allocation size。
2. Lowering 生成 `BSTART.TLSU`、所需 `B.DIM` 与一条或多条 `B.IOT`；只有存在非默认 data attribute 时才生成 `B.DATR`，只有存在 scalar/GPR/address/index/profile operand 时才生成 `B.IOR`。
3. Decoder 收集 block header，建立内部 tile uop/profile，并绑定 source/destination Tile operand。
4. Issue 阶段读取相关 Tile rename/allocation metadata，检查 dtype、shape、stride、size 与 operand role 兼容性。
5. Execute 阶段按 PTO `TPREFETCH` 语义执行；retire 阶段提交 destination Tile 映射，source 生命周期由 reader/版本记账自动管理。
