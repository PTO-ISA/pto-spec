---
{
  "schema_version": 1,
  "id": "header.header-b.fpatr",
  "kind": "header",
  "title": "B.FPATR",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Dimensions & Attributes",
  "sources": {"davincioo": "header/B.FPATR.md"}
}
---
# B.FPATR

## 说明

`B.FPATR` 是全部 12 个 active CUBE Matrix operation 的必需 header，静态编码完整
`PostProcessConfig`。每个完整 CUBE bundle 必须恰好携带一个 `B.FPATR`；即使关闭全部
transform，也必须发出 canonical None。其他 operation 不得携带该 header。

缺少、重复或用于非 CUBE operation 会产生 `Fault_BundleControl`。重复 header 不得覆盖
第一个已锁存值。保留 mode、非法字段组合、PostProcess operand 数量或 descriptor 不匹配会在
完整 bundle 的只读 preflight 阶段产生 `Fault_TileLegality`，且不得分配 destination、消费
source 或产生部分结果。

## Bit-level Encoding

| Bits | Field | Width | Meaning |
| --- | --- | ---: | --- |
| `[31:26]` | `PreQuantMode` | 6 | 唯一确定 source/output type 与 quant parameter form |
| `[25:23]` | `ReluMode` | 3 | None/Normal/LReLU/PReLU |
| `[22:19]` | `GroupNCode` | 4 | GroupMax group width |
| `[18]` | `RowMaxEn` | 1 | 0=无 RowMax output；1=启用 RowMax output |
| `[17]` | `GroupMaxEn` | 1 | 产生可选 GroupMax |
| `[16]` | `RowMaxInit` | 1 | 仅 RowMaxEn=1 时有效；0=fresh，1=读取显式 RowMaxIn |
| `[15]` | `MaxAbsEn` | 1 | 作用于所有已启用的 max reduction |
| `[14:12]` | `Func` | 3 | `2` |
| `[11]` | `ElementWiseEn` | 1 | v1 预留，必须为 0 |
| `[10:7]` | reserved | 4 | 必须为 0 |
| `[6:4]` | `Opc1` | 3 | `2` |
| `[3:1]` | `Opcode` | 3 | `1` |
| `[0]` | `W` | 1 | `1` |

该 form 的 mask/match 为 `0x00007fff/0x00002023`。所有可变字段为零时，canonical None
word 为 `0x00002023`。

## PreQuantMode

PreQuantMode 决定 quant/convert 路径和 DType。None 与 ReLU=None、RMode=NONE、Sat=0 组合时，D 保持 AccType/逻辑 TileAcc role；否则 D 为 ordinary ND Tile。

| Code | Mode | AccType | D dtype | Parameter |
| ---: | --- | --- | --- | --- |
| 0 | None | FP32/S32 | AccType | none |
| 1 | F322F16 | FP32 | FP16 | none |
| 2/3 | VREQS8_PRE/REQS8_PRE | S32 | S8 | vector/scalar scale + S9 offset |
| 4/5 | VDEQF16/DEQF16 | S32 | FP16 | vector/scalar scale |
| 12/13 | VSHIFTS322S16/SHIFTS322S16 | S32 | S16 | vector/scalar shift |
| 16 | F322BF16 | FP32 | BF16 | none |
| 17/18 | QF322S4_PRE/VQF322S4_PRE | FP32 | S4X2 | scalar/vector scale + S5 offset |
| 19/20 | QF322S16_PRE/VQF322S16_PRE | FP32 | S16 | scalar/vector scale + S17 offset |
| 23/24 | VQF322S8_PRE/QF322S8_PRE | FP32 | S8 | vector/scalar scale + S9 offset |
| 25/28 | QF322HIF8_PRE/VQF322HIF8_PRE | FP32 | HiF8 | scalar/vector scale |
| 26/37 | QF322FP8_PRE/VQF322FP8_PRE | FP32 | E4M3 | scalar/vector scale |
| 27/38 | QF322F32_PRE/VQF322F32_PRE | FP32 | FP32 | scalar/vector scale |
| 32/33 | QF322F16_PRE/VQF322F16_PRE | FP32 | FP16 | scalar/vector scale |
| 34/36 | QF322BF16_PRE/VQF322BF16_PRE | FP32 | BF16 | scalar/vector scale |
| 35/39 | QS322BF16_PRE/VQS322BF16_PRE | S32 | BF16 | scalar/vector scale |

未列出的 code 均为保留值。PTO 0.58.0 不提供 U8 PostProcess destination。

## ReluMode

| Code | Mode | Parameter |
| ---: | --- | --- |
| 0 | None | none |
| 1 | Normal ReLU | negative coefficient 0 |
| 2 | scalar LReLU | one FP19 GPR value |
| 3 | vector PReLU | one Local U64 `1 × N` Tile |

Code 4–7 保留。quant parameter 与 ReLU parameter 是独立输入；negative branch 不会再次乘
quant parameter。

## ReLU、quant 与转换顺序

```text
P = full-K accumulated value
max auxiliary = Reduce(P)
R = ReLU(P)
D = QuantOrConvert(R)
```

RowMax/GroupMax 先于 ReLU、quant、convert。config 决定 QuantParam/ReLUParam 为无、GPR 或 Tile，并决定精确 arity。

## RowMax 与 GroupMax

RowMaxIn/Out 为 M×1；GroupMaxOut 为 M×ceil(N/GroupN)。它们可在 canonical None 下独立启用，且不改变 D 的 TileAcc role。cooperative TMATMUL 中这些值按 MShard4 分布。

`GroupNCode` 0 表示关闭，1–9 分别表示 8、16、32、48、64、80、96、112、128。
GroupMax 关闭时 code 必须为 0；启用时 code 必须为 1–9。最后一个不足 GroupN 的 group
只归约有效列；GroupN 大于 N 时每行产生一个 group。

`RowMaxInit` 仅在 RowMax 启用时合法；置位时额外读取一个 RowMaxIn。`MaxAbsEn` 作用于
所有启用的 max reduction，并且在 RowMax 与 GroupMax 都关闭时必须为 0。

## B.DATR interaction

- BSTART.CUBE 的 DataType 仍是 AType，`B.DATR` DataType 仍是 BType；D dtype 只由
  AccType 与 `B.FPATR` 推导。
- PreQuant=None 要求 RMode=NONE 且 Sat=0。
- Shift mode 要求 RMode=NONE，Sat 可为 0 或 1。
- 其他 non-None mode 接受 bundle RMode；NONE 在 PostProcess conversion 中解析为 RNE。
- Sat 只作用于 D，不作用于 RowMaxOut 或 GroupMaxOut。

## Destination 与原子性

destination 顺序固定为 D、RowMaxOut、GroupMaxOut。所有启用 output 同时 ready，并作为一个结果组 commit/flush。D 必须是 ordinary physical Local TReg；D==C 采用 read-old/rename-new。

RowMaxIn 可以与 RowMaxOut 相同并使用 read-old/write-new。D、RowMaxOut 和 GroupMaxOut
必须两两不同；RowMaxIn 不得与其他启用的 destination 重叠。任一 destination 的 shape、
capacity、alias 或 allocation preflight 失败都必须回滚整个结果组。
