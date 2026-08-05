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

B.FPATR 是全部 12 个 active Matrix operation 的必需 header，静态编码完整 PostProcessConfig。即使关闭所有 transform，也必须发 canonical None。

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

## PreQuantMode

PreQuantMode 决定 quant/convert 路径和 DType。None 与 ReLU=None、RMode=NONE、Sat=0 组合时，D 保持 AccType/逻辑 TileAcc role；否则 D 为 ordinary ND Tile。

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

## Destination 与原子性

destination 顺序固定为 D、RowMaxOut、GroupMaxOut。所有启用 output 同时 ready，并作为一个结果组 commit/flush。D 必须是 ordinary physical Local TReg；D==C 采用 read-old/rename-new。
