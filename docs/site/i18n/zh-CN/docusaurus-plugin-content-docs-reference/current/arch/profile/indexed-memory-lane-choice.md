<!-- GENERATED FROM: asl/arch/profile/indexed-memory-lane-choice.asl -->
# Indexed Memory Lane Choice

**Normative ASL source:** `asl/arch/profile/indexed-memory-lane-choice.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-INDEXED-MEMORY-LANE-CHOICE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-indexed-choice-profile-purpose role=purpose-scope -->
## 用途与范围

本页提供索引内存 lane 选择钩子的 PTO v0 实现。它使参考模型具备确定性，但不会把该顺序变成额外编码操作数或实现调度要求。

<!-- PTO-READER-BLOCK: arch-indexed-choice-profile-concepts role=concepts-state -->
## 递增逻辑位置

该实现断言当前位置 `position` 小于 `lane_count`，并返回同一位置。因此重复调用者选择其提交给钩子的最早逻辑位置。

<!-- PTO-READER-BLOCK: arch-indexed-choice-profile-rules role=rules-interactions -->
## 操作类别处理

`ScatterCommit` 与 `GatherCASAtomic` 在此配置档中都使用保持位置不变的规则。接口仍保留 `kind`，使不同命名配置档能够定义经过评审的选择策略而不改变调用者。

<!-- PTO-READER-BLOCK: arch-indexed-choice-profile-boundaries role=boundaries -->
## 边界

该配置档不定义 lane 资格、冲突分组、内存顺序或事务提交。这些规则由拥有索引内存操作的单元在钩子前后建立。传入 `position >= lane_count` 违反实现前置条件。

<!-- PTO-READER-BLOCK: arch-indexed-choice-profile-example role=example-usage -->
## 非规范选择示例

若调用者提交 8 个合格位置中的逻辑位置 3，配置档返回 3。调用者随后应用操作专属效果，并按自身事务规则推进。

<!-- PTO-READER-BLOCK: arch-indexed-choice-profile-related role=related-owners-navigation -->
## 相关所有者

- [索引内存 lane 选择类型](../data-types/indexed-memory-lane-choice.md)定义钩子契约和操作类别。
- 索引 gather/scatter 所有者定义资格与已提交内存效果。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/indexed-memory-lane-choice.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-INDEXED-MEMORY-LANE-CHOICE","surface":"arch","classification":["profile","indexed-memory-lane-choice"],"depends_on":["PTO-ARCH-DATA-TYPES-INDEXED-MEMORY-LANE-CHOICE"]}

readonly implementation func SelectIndexedMemoryLanePosition(
    kind: IndexedMemoryLaneChoiceKind,
    position: ModelTileElementIndex,
    lane_count: integer {1..PTO_MODEL_TILE_ELEMENTS})
    => ModelTileElementIndex
begin
    assert position < lane_count;
    return position;
end;
```
<!-- GENERATED-ASL-END: unit -->
