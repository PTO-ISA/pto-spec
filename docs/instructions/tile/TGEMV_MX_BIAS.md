---
{
  "schema_version": 1,
  "id": "intrinsic.tgemv_mx_bias",
  "kind": "intrinsic",
  "title": "TGEMV_MX_BIAS 内建函数",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "TGEMV_MX_BIAS.md",
    "pto": "tile/ops/matrix-and-matrix-vector/tgemv-mx.md"
  },
  "opcode": "TGEMV_MX_BIAS",
  "family": "matrix-cube",
  "bundle": "BSTART.CUBE TGEMVMX.BIAS AType\nB.DATR BType RMode Sat\nB.FPATR\nB.DIM LB0 M\nB.DIM LB1 N\nB.DIM LB2 K\nB.IOT Local sources and Local outputs\nB.IOR scalar PostProcess parameter (optional)",
  "operands": {
    "output": "D Tile\nRowMaxOut Tile (optional)\nGroupMaxOut Tile (optional)",
    "input0": "A Tile\nScaleA Tile",
    "input1": "B/Right Tile\nScaleB/ScaleRight Tile",
    "input2": "Bias Tile\nRowMaxIn Tile (optional)\nQuant parameter Tile or GPR (optional)\nReLU parameter Tile or GPR (optional)"
  },
  "dtypes": [
    "AccType S32 or F32; DType is AccType for canonical None and otherwise follows PostProcessConfig"
  ],
  "encoding": {
    "block": "CUBE",
    "mode": 0,
    "function": 21
  },
  "xlsx": {
    "include": true,
    "category": "MATRIX Operation\n矩阵乘操作",
    "subcategory": "矩阵乘向量",
    "order": 78,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TGEMV_MX_BIAS 内建函数

> 状态：DavinciOO v5 superscalar active Matrix intrinsic。所有结果写 ordinary physical Local TReg；不存在 architectural implicit ACC。

## PTO 语义来源

- PTO 来源页：[`../pto/TGEMV_MX.md`](../pto/TGEMV_MX.md)
- DavinciOO target public name：`TGEMV_MX_BIAS`
- 本页描述已冻结的目标 API；当前上游 PTO header 的 `AccPhase`、MX overload 名称或 ACC shorthand 差异由单独 upstream handoff 处理。

```text
P = MXMatMul(A, ScaleA, B, ScaleB) + Bias
D = PostProcess<PP>(P)
```

Bias 是显式 Local Tile input，并在 K 乘积累加前预装入 P。 PostProcess 只在完整 K 累加后执行一次。

## 公开 C++ Form 与执行范围

```cpp
template <PostProcessConfig PP = PostProcessConfig::None, typename TileDst, typename TileA, typename TileB, typename TileScaleA, typename TileScaleB, typename TileBias, typename... WaitEvents>
RecordEvent TGEMV_MX_BIAS(TileDst &d, TileA &a, TileScaleA &scaleA, TileB &b, TileScaleB &scaleB, TileBias &bias, PostProcessOperands<PP> &...ppOperands, WaitEvents &...events);
```

`TGEMV*` 只定义 PE-local M=1 GEMV。API 不增加 `<pe_scope>`；`PE_MASK=1111` 表示四个 PE 各自执行一个独立 GEMV，不形成 rendezvous、共享 B 或跨 PE reduction。A、B、ScaleA、ScaleB、C/Bias、D 和 auxiliary operand 全部必须为 Local Tile，任何 `SharedTile` 或 `C.B.IOS` 都非法。

`PostProcessConfig` 完整、静态地描述 PreQuant、ReLU、RowMax、GroupMax、RowMaxInit、MaxAbs、RMode 与 Sat。默认配置为 canonical None，但 lowering 仍发出一个 canonical `B.FPATR`。

## DavinciOO 汇编语法

```asm
TGEMVMX.BIAS <LB0:M, LB1:N, LB2:K, AType, BType, PostProcess>, A, ScaleA, B, ScaleB, Bias, [RowMaxIn], [QuantParam], [ReLUParam], ->D, [->RowMaxOut], [->GroupMaxOut]
```

- 逻辑输入 `Bias` 是必需的显式 Tile operand。
- 可选 PostProcess source 的存在性完全由 compile-time config 决定；scalar 形式走 GPR，vector 形式走 Tile。
- destination 顺序固定为 D、RowMaxOut、GroupMaxOut。

## DavinciOO Block Intrinsic

Canonical None 的 Local 示例：

```asm
BSTART.CUBE TGEMVMX.BIAS, AType
B.DATR      BType, RMode.NONE, Sat.Off
B.FPATR     PreQuant.None, ReLU.None, RowMax.Off, GroupMax.Off, RowMaxInit.Off, MaxAbs.Off
B.DIM       rM, 0, ->LB0
B.DIM       rN, 0, ->LB1
B.DIM       rK, 0, ->LB2
B.IOT       A, ScaleA, mask=PE_MASK
B.IOT       B, ScaleB, mask=PE_MASK
B.IOT       Bias, mask=PE_MASK, last, ->D<TSize>
```

- 不生成 `C.B.IOS`；全部 source 由 Local `B.IOT` 绑定。

## Header 展开说明

| Header | 本指令用途 | 公共定义 |
| --- | --- | --- |
| `BSTART.CUBE` | 选择 `TGEMVMX.BIAS` 与 AType | [`header/BSTART.CUBE.md`](../bundle/BSTART.CUBE.md) |
| `B.DATR` | 必需；表达 BType、RMode、Sat | [`header/B.DATR.md`](../bundle/B.DATR.md) |
| `B.FPATR` | 必需；表达完整 PostProcessConfig，包括 canonical None | [`header/B.FPATR.md`](../bundle/B.FPATR.md) |
| `B.DIM` | 表达 M/N/K；TGEMV 要求 M=1 | [`header/B.DIM.md`](../bundle/B.DIM.md) |
| `B.IOT` | 绑定 Local source、D 与 auxiliary output | [`header/B.IOT.md`](../bundle/B.IOT.md) |
| `B.IOR` | 按 config 绑定 scalar quant/ReLU 参数 | [`header/B.IOR.md`](../bundle/B.IOR.md) |

## 约束与合法性

- AccType 只允许 S32/F32；C（若存在）必须为 M×N ND AccType Local Tile。U32 accumulator 非法。
- canonical None 为 PreQuant=None、ReLU=None、RMode=NONE、Sat=0；D 保持 AccType 与逻辑 TileAcc role。RowMax/GroupMax 可独立启用且不改变 D role。
- 任一 quant、convert 或 ReLU 使 D 成为由 PostProcess 推导 dtype 的 ordinary ND Tile。
- RowMax/GroupMax 在 ReLU、quant、convert 前观察 P。RowMaxIn/Out 为 M×1；GroupMaxOut 为 M×ceil(N/GroupN)。
- verifier 必须按 config 检查精确 source/destination arity，不接受闲置 operand。
- D、RowMaxOut、GroupMaxOut 同时 ready，并在 retire/flush 上作为一个原子结果组处理。
- 所有 operand/output 都是单 PE Local Tile；M 固定为 1。
- D 必须是显式 ordinary physical Local destination。
- TGEMV 禁止所有 SharedTile、C.B.IOS 和 core rendezvous；K blocking 通过每 PE 显式 TGEMV_ACC(D,C,A,B) 链完成。
- 一个 block 中最后一条 `B.IOT` 必须设置 `last`；M/N/K、fractal、layout 与 Tile size 必须满足 CUBE profile。
- nondefault `AccPhase` 一律拒绝；K blocking 使用显式 `_ACC(D,C,...)`。

## Lowering 摘要

1. Frontend 固化 `PostProcessConfig`，据此确定精确 operand/output arity、D role 与 DType。
2. Lowering 发出 `BSTART.CUBE`、`B.DATR`、恰好一个 `B.FPATR`、`B.DIM`、`B.IOT`，并按需发出 `B.IOR`。
3. Rename 为 C/source 绑定旧 physical TReg，为 D 和 auxiliary output 分配新 physical TReg；D==C 仍保持 read-old/write-new。
4. Execute 完成完整 K accumulation 后执行 max reduction 与 PostProcess；retire 原子提交所有 destination。
