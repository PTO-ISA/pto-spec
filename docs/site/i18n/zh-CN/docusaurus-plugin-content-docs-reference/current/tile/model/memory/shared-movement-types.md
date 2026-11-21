<!-- GENERATED FROM: asl/tile/model/memory/shared-movement-types.asl -->
# Shared Movement Types

**Normative ASL source:** `asl/tile/model/memory/shared-movement-types.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-TYPES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-types-purpose role=purpose-scope -->
## 用途与范围

本单元定义 movement 操作共享的有界容器类型。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-types-concepts role=concepts-state -->
## 概念与状态

`ScatterLaneOrder` 为每个模型 Tile 元素保存一个 word。`CorePETileInfos` 为每个模型 PE 保存一个 `TileInfo` 值。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-types-rules role=rules-interactions -->
## 规则与交互

Movement owner 使用这些类型传递完整 lane 顺序或按 PE 的 Tile 快照集合，不创建隐藏的架构队列。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-types-boundaries role=boundaries -->
## 架构边界

数组边界是参考模型边界。本单元不定义操作、顺序规则、分配或硬件容量要求。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-types-example role=example-usage -->
## 非规范阅读示例

按 PE 的 Shared movement 可以接收一个 `CorePETileInfos` 值，并根据四位 PE 掩码选择条目。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-types-related role=related-owners-navigation -->
## 相关所有者

- [相关所有者](../state/types.md) 定义两个数组所使用的 `TileInfo` 和模型身份。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/shared-movement-types.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-TYPES","surface":"tile","classification":["model","memory","shared-movement-types"],"depends_on":["PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","PTO-TILE-MODEL-STATE-TYPES"]}
type ScatterLaneOrder of array [[PTO_MODEL_TILE_ELEMENTS]] of Word;
type CorePETileInfos of array [[PTO_MODEL_MEMORY_AGENTS]] of TileInfo;
```
<!-- GENERATED-ASL-END: unit -->
