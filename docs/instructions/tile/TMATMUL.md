---
{
  "schema_version": 1,
  "id": "intrinsic.tmatmul",
  "kind": "intrinsic",
  "title": "TMATMUL 内建函数",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "TMATMUL.md",
    "pto": "tile/ops/matrix-and-matrix-vector/tmatmul.md"
  },
  "opcode": "TMATMUL",
  "family": "matrix-cube",
  "bundle": "BSTART.CUBE TMATMUL AType\nB.DATR BType RMode Sat\nB.FPATR\nB.DIM LB0 M\nB.DIM LB1 N\nB.DIM LB2 K\nC.B.IOS Shared operand binder (optional)\nB.IOT Local sources and Local outputs\nB.IOR scalar PostProcess parameter (optional)",
  "operands": {
    "output": "D Tile\nRowMaxOut Tile (optional)\nGroupMaxOut Tile (optional)",
    "input0": "A Tile",
    "input1": "B/Right Tile",
    "input2": "RowMaxIn Tile (optional)\nQuant parameter Tile or GPR (optional)\nReLU parameter Tile or GPR (optional)"
  },
  "dtypes": [
    "AccType S32 or F32; DType is AccType for canonical None and otherwise follows PostProcessConfig"
  ],
  "encoding": {
    "block": "CUBE",
    "mode": 0,
    "function": 0
  },
  "xlsx": {
    "include": true,
    "category": "MATRIX Operation\n矩阵乘操作",
    "subcategory": "矩阵乘矩阵",
    "order": 68,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TMATMUL 内建函数

> 状态：DavinciOO v5 superscalar active Matrix intrinsic。所有结果写 ordinary physical Local TReg；不存在 architectural implicit ACC。

## PTO 语义来源

- PTO 来源页：[`../pto/TMATMUL.md`](../pto/TMATMUL.md)
- DavinciOO target public name：`TMATMUL`
- 本页描述已冻结的目标 API；当前上游 PTO header 的 `AccPhase`、MX overload 名称或 ACC shorthand 差异由单独 upstream handoff 处理。

```text
P = A * B
D = PostProcess<PP>(P)
```

P 从零开始累加。 PostProcess 只在完整 K 累加后执行一次。

## 公开 C++ Form 与执行范围

```cpp
template <PostProcessConfig PP = PostProcessConfig::None, typename TileDst, typename TileA, typename TileB, typename... WaitEvents>
RecordEvent TMATMUL(TileDst &d, TileA &a, TileB &b, PostProcessOperands<PP> &...ppOperands, WaitEvents &...events);
```

Local form 使用 Local A/B。Cooperative form 的 `PE_MASK` 选择 Shared fixed-offset quarter；B 必须为 Shared，A 可以全 Local 或全 Shared。Shared A 配 Local B 非法；MX 的 data/scale pair 不允许 mixed storage。selected uninitialized data 采用 undefined-register semantics。API 不增加 `<core_scope>`，由 operand storage type 选择 form。

`PostProcessConfig` 完整、静态地描述 PreQuant、ReLU、RowMax、GroupMax、RowMaxInit、MaxAbs、RMode 与 Sat。默认配置为 canonical None，但 lowering 仍发出一个 canonical `B.FPATR`。

## DavinciOO 汇编语法

```asm
TMATMUL <LB0:M, LB1:N, LB2:K, AType, BType, PostProcess>, A, B, [RowMaxIn], [QuantParam], [ReLUParam], ->D, [->RowMaxOut], [->GroupMaxOut]
```

- 逻辑输入 `zero` 表示内部 zero initialization，不占 Tile operand。
- 可选 PostProcess source 的存在性完全由 compile-time config 决定；scalar 形式走 GPR，vector 形式走 Tile。
- destination 顺序固定为 D、RowMaxOut、GroupMaxOut。

## DavinciOO Block Intrinsic

Canonical None 的 Local 示例：

```asm
BSTART.CUBE TMATMUL, AType
B.DATR      BType, RMode.NONE, Sat.Off
B.FPATR     PreQuant.None, ReLU.None, RowMax.Off, GroupMax.Off, RowMaxInit.Off, MaxAbs.Off
B.DIM       rM, 0, ->LB0
B.DIM       rN, 0, ->LB1
B.DIM       rK, 0, ->LB2
B.IOT       A, B, mask=PE_MASK, last, ->D<TSize>
```

Cooperative Local-A 示例：

```asm
BSTART.CUBE TMATMUL, AType
B.DATR      BType, RMode.NONE, Sat.Off
B.FPATR     PreQuant.None, ReLU.None, RowMax.Off, GroupMax.Off, RowMaxInit.Off, MaxAbs.Off
B.DIM       rM, 0, ->LB0
B.DIM       rN, 0, ->LB1
B.DIM       rK, 0, ->LB2
C.B.IOS     S17
B.IOT       A, mask=1111, last, ->D<TSize>
```

Cooperative Shared-A 示例：

```asm
BSTART.CUBE TMATMUL, AType
B.DATR      BType, RMode.NONE, Sat.Off
B.FPATR     PreQuant.None, ReLU.None, RowMax.Off, GroupMax.Off, RowMaxInit.Off, MaxAbs.Off
B.DIM       rM, 0, ->LB0
B.DIM       rN, 0, ->LB1
B.DIM       rK, 0, ->LB2
C.B.IOS     S16
C.B.IOS     S17
B.IOT       mask=1111, last, ->D<TSize>
```

Shared-A form 在上述 binder 前追加 `Left`，完整顺序为 Left、Right；同时从 Local source stream 移除 A。

- Local form：A、B 均由 `B.IOT` 绑定。
- Cooperative Local-A form：`C.B.IOS Right`，Local stream 保留 A。
- Cooperative Shared-A form：`C.B.IOS Left`、`C.B.IOS Right`，顺序固定。

## Header 展开说明

| Header | 本指令用途 | 公共定义 |
| --- | --- | --- |
| `BSTART.CUBE` | 选择 `TMATMUL` 与 AType | [`header/BSTART.CUBE.md`](../bundle/BSTART.CUBE.md) |
| `B.DATR` | 必需；表达 BType、RMode、Sat | [`header/B.DATR.md`](../bundle/B.DATR.md) |
| `B.FPATR` | 必需；表达完整 PostProcessConfig，包括 canonical None | [`header/B.FPATR.md`](../bundle/B.FPATR.md) |
| `B.DIM` | 表达 M/N/K；TGEMV 要求 M=1 | [`header/B.DIM.md`](../bundle/B.DIM.md) |
| `B.IOT` | 绑定 Local source、D 与 auxiliary output | [`header/B.IOT.md`](../bundle/B.IOT.md) |
| `B.IOR` | 按 config 绑定 scalar quant/ReLU 参数 | [`header/B.IOR.md`](../bundle/B.IOR.md) |
| `C.B.IOS` | 仅 cooperative TMATMUL；绑定 Shared Left/Right role | [`header/C.B.IOS.md`](../bundle/C.B.IOS.md) |

## 约束与合法性

- AccType 只允许 S32/F32；C（若存在）必须为 M×N ND AccType Local Tile。U32 accumulator 非法。
- canonical None 为 PreQuant=None、ReLU=None、RMode=NONE、Sat=0；D 保持 AccType 与逻辑 TileAcc role。RowMax/GroupMax 可独立启用且不改变 D role。
- 任一 quant、convert 或 ReLU 使 D 成为由 PostProcess 推导 dtype 的 ordinary ND Tile。
- RowMax/GroupMax 在 ReLU、quant、convert 前观察 P。RowMaxIn/Out 为 M×1；GroupMaxOut 为 M×ceil(N/GroupN)。
- verifier 必须按 config 检查精确 source/destination arity，不接受闲置 operand。
- D、RowMaxOut、GroupMaxOut 同时 ready，并在 retire/flush 上作为一个原子结果组处理。
- Cooperative form 中 C/D、RowMaxIn/Out、GroupMaxOut 为 MShard4；Bias、vector QuantParam、vector PReLU 是四 PE 上内容相同的完整 Local N-vector；scalar GPR 参数也必须在四 PE 上相等。
- D 必须是显式 ordinary physical Local destination。
- Cooperative TMATMUL 的 Shared read 不修改 descriptor/payload；并发 overlap 由程序避免，且该 rendezvous 不建立 GM ordering。
- 一个 block 中最后一条 `B.IOT` 必须设置 `last`；M/N/K、fractal、layout 与 Tile size 必须满足 CUBE profile。
- nondefault `AccPhase` 一律拒绝；K blocking 使用显式 `_ACC(D,C,...)`。

## Lowering 摘要

1. Frontend 固化 `PostProcessConfig`，据此确定精确 operand/output arity、D role 与 DType。
2. Lowering 发出 `BSTART.CUBE`、`B.DATR`、恰好一个 `B.FPATR`、`B.DIM`、`B.IOT`，并按需发出 `B.IOR` 与 cooperative `C.B.IOS`。
3. Rename 为 C/source 绑定旧 physical TReg，为 D 和 auxiliary output 分配新 physical TReg；D==C 仍保持 read-old/write-new。
4. Execute 完成完整 K accumulation 后执行 max reduction 与 PostProcess；retire 原子提交所有 destination。
