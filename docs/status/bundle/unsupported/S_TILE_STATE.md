---
{
  "schema_version": 1,
  "id": "header.unsupported-s-tile-state",
  "kind": "header",
  "title": "S Tile State",
  "status": "removed",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "family": "Unsupported Block/Header"
}
---
# Unused Linx S Tile State

> **NON-NORMATIVE / UNSUPPORTED**
> This document is not part of PTO ISA 0.58.0 and must not be used as assembler, decoder, ASL, encoding, or implementation input.

本文保留 Linx `S` Tile state / `TS` scratch contract 的历史说明。当前 DavinciOO active PE-local intrinsic profile 不引入该 state，也不允许 `B.IOT.DstTile=5` 作为 active destination queue。

## Why Unused

Linx 中的 `S` Tile state 主要服务于 vector / separated block body：

- vector block body 不直接访问 memory；
- block 可以通过 `B.IOT ->S<Size>` 申请一段 block-local scratch Tile storage；
- block body 通过 local Tile address register `TS` 访问这段 storage；
- `TS` 可用于保存调用参数、临时值或 spill 数据；
- `S` 随申请它的 block 提交而释放，不作为跨 block ordinary Tile queue 暴露。

当前 DavinciOO active profile 暂不发布 vector micro-ISA，也不发布可编程 vector block body / local load-store body model。因此 active tile intrinsic 没有 `TS` 访问面。如果在 active profile 中保留 `S`，容易被误解为第五组 ordinary TReg queue，或者误解为 fixed-function tile intrinsic 可直接申请和访问的 scratch storage。

## Linx-style Contract Summary

Linx local Tile address register model 中，输入 Tile 形参为 `TA..TH`，输出 Tile 形参为 `TO/TO1/TO2/TO3`。其中 `TO1/TS` 是同一个第二输出形参槽的双用途别名：

| Local formal register | Meaning |
| --- | --- |
| `TA..TH` | 第 1 到第 8 个 input Tile 的 block-local base |
| `TO` | 第 1 个 output Tile 的 block-local base |
| `TO1/TS` | 第 2 个 output Tile 的 block-local base，或 `S` scratch Tile 的 block-local base |
| `TO2/TO3` | 第 3 / 第 4 个 output Tile 的 block-local base |

Linx-style 示例：

```asm
BSTART.VPAR
B.DIM       zero, 64, ->LB0
B.DIM       zero, 64, ->LB1
B.IOT       T#1, U#1, ->T<8KB>
B.IOT       last,    ->S<1KB>

# block body sees TS as the scratch Tile base:
#   spill:  l.sd vt#1.ud, [TS, lc0.uh<<3]
#   reload: l.ld [TS, lc0.uh<<3], ->vt.d
```

因为 `S` 与 `TO1/TS` 共享第二个 output formal register，带有多个 output 且同时申请 `S` 的 block 必须把 `->S<Size>` 放在第二个 output 位置。否则 `TO1` 和 `TS` 会被两个不同 output 初始化，属于非法 block contract。

## Re-enable Conditions

若后续重新引入 `S` Tile state，需要先明确：

- active profile 是否发布 vector micro-ISA 或其他可编程 block body；
- block body 是否定义 local load/store 到 `TA..TH/TO/TS` 的访问规则；
- `B.IOT.DstTile=5` 是否恢复为 active `S` destination encoding；
- `TO1/TS` 与多 output block 的冲突和合法性规则；
- `S` allocation 对 PE-local CELL capacity、block lifetime 和异常模型的影响。
