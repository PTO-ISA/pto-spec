<!-- GENERATED FROM: asl/arch/data-types/indexed-memory-lane-choice.asl -->
# Indexed Memory Lane Choice

**Normative ASL source:** `asl/arch/data-types/indexed-memory-lane-choice.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-INDEXED-MEMORY-LANE-CHOICE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-indexed-choice-types-purpose role=purpose-scope -->
## 用途与范围

本单元定义多个索引内存 lane 在同一逻辑位置具备资格时使用的配置档钩子。它区分 scatter 提交与 gather-CAS 原子选择，但不指定实现调度策略。

<!-- PTO-READER-BLOCK: arch-indexed-choice-types-concepts role=concepts-state -->
## 选择输入

`IndexedMemoryLaneChoiceKind` 标识操作类别。`position` 是当前逻辑位置，`lane_count` 是非零且有界的 lane 数量，返回的 `ModelTileElementIndex` 命中所选 lane 位置。

<!-- PTO-READER-BLOCK: arch-indexed-choice-types-rules role=rules-interactions -->
## 合法性谓词与钩子

`IndexedMemoryLanePositionLegal` 接受不早于当前位置且严格小于 `lane_count` 的选择。`SelectIndexedMemoryLanePosition` 是实现定义钩子；其声明以当前位置作为参考回退值。

<!-- PTO-READER-BLOCK: arch-indexed-choice-types-boundaries role=boundaries -->
## 边界

此类型单元不重排内存效果、不定义冲突检测，也不在操作类别之间选择。调用者仍负责传入合法当前位置，并通过拥有该索引内存事务的单元应用所选 lane。

<!-- PTO-READER-BLOCK: arch-indexed-choice-types-example role=example-usage -->
## 非规范阅读示例

当 `position=2`、`lane_count=5` 时，合法性辅助函数接受位置 2、3、4。具体 PTO v0 配置档选择 2，但该确定性配置档规则由配置档实现页面拥有。

<!-- PTO-READER-BLOCK: arch-indexed-choice-types-related role=related-owners-navigation -->
## 相关所有者

- [索引内存 lane 选择配置档](../profile/indexed-memory-lane-choice.md)提供 PTO v0 实现。
- 索引 gather/scatter 操作所有者定义使用该选择的内存效果。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/indexed-memory-lane-choice.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-INDEXED-MEMORY-LANE-CHOICE","surface":"arch","classification":["data-types","indexed-memory-lane-choice"],"depends_on":["PTO-ARCH-DATA-TYPES-INTEGER"]}

type IndexedMemoryLaneChoiceKind of enumeration {
    IndexedMemoryLaneChoice_ScatterCommit,
    IndexedMemoryLaneChoice_GatherCASAtomic
};

readonly func IndexedMemoryLanePositionLegal(
    position: ModelTileElementIndex,
    lane_count: integer {1..PTO_MODEL_TILE_ELEMENTS},
    selected: ModelTileElementIndex) => boolean
begin
    return selected >= position && selected < lane_count;
end;

readonly impdef func SelectIndexedMemoryLanePosition(
    kind: IndexedMemoryLaneChoiceKind,
    position: ModelTileElementIndex,
    lane_count: integer {1..PTO_MODEL_TILE_ELEMENTS})
    => ModelTileElementIndex
begin
    return position;
end;
```
<!-- GENERATED-ASL-END: unit -->
