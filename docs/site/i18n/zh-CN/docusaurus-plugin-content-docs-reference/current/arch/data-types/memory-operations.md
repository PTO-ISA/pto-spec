<!-- GENERATED FROM: asl/arch/data-types/memory-operations.asl -->
# Memory Operations

**Normative ASL source:** `asl/arch/data-types/memory-operations.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-MEMORY-OPERATIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-operations-purpose-scope role=purpose-scope -->
## 目的与范围

本单元命名标量内存执行使用的地址更新选择器和原子操作选择器。

它包含两个枚举，不含可执行行为，因此它定义存在哪些操作，而不定义其中任何一个做什么。

<!-- PTO-READER-BLOCK: arch-memory-operations-concepts-state role=concepts-state -->
## 概念与可见状态

`AddressUpdateMode` 包含 `AddressUpdate_None`、`AddressUpdate_PreIndex` 和 `AddressUpdate_PostIndex`。

`AtomicOperation` 包含 `Atomic_SWAP`、`Atomic_ADD`、`Atomic_AND`、`Atomic_OR`、`Atomic_XOR`、`Atomic_SMIN`、`Atomic_SMAX`、`Atomic_UMIN` 和 `Atomic_UMAX`。

设计要点：把两类选择器放在同一个所有者中，可以使同一操作标识在任何出现的地方都一致，因此调用方无需为同一个原子操作协调两个名称。

<!-- PTO-READER-BLOCK: arch-memory-operations-rules-interactions role=rules-interactions -->
## 规则与交互

前索引和后索引是不同的选择器，因此选择器本身并不说明基址更新何时计算或提交；这由消费它的指令所有者决定。

有符号与无符号最小值/最大值使用不同成员，因此比较的有符号性属于操作标识，而不是稍后才选择的操作数解释。

任何成员都不隐含故障、顺序、访问大小或发布规则，因为这些仍是消费它的指令所有者的参数。

<!-- PTO-READER-BLOCK: arch-memory-operations-boundaries role=boundaries -->
## 架构边界

设计要点：由于选择器只命名操作，两条指令可以共用 `Atomic_ADD` 而各自定义不同的宽度、顺序和故障行为，双方都不需要重新定义对方。

本单元没有后备值，也没有实现定义的选择器，因此解码器必须在执行前映射到某个已声明成员。

本单元只声明两个枚举，不含任何函数，因此上面的成员列表就是选择器词汇的完整定义。

<!-- PTO-READER-BLOCK: arch-memory-operations-example-usage role=example-usage -->
## 非规范阅读示例

本例说明当前的 ASL 归属单元，不替代规范操作。

选择器标识具有可移植性，而某种指令形式是否受支持及其合法性，仍由该指令当前的 ASL 所有者定义。

阅读内存操作意味着阅读消费它的指令所有者，以取得地址、宽度、顺序、故障和提交契约。

选择 `Atomic_ADD` 的原子指令仍需自己的地址、宽度、顺序、故障和提交契约，而 `AddressUpdate_PostIndex` 本身并不说明访问失败时是否更新基址寄存器。

因此共用同一个选择器的两条指令可以在宽度和顺序上不同，选择器本身永远不固定调用方执行的访问大小。

<!-- PTO-READER-BLOCK: arch-memory-operations-related-owners role=related-owners-navigation -->
## 相关归属单元

- [内存模型类型](memory-model.md)定义这些选择器作用的事件记录。

- [原子性](../memory-model/atomicity.md)定义原子性要求本身。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/memory-operations.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-MEMORY-OPERATIONS","surface":"arch","classification":["data-types","memory-operations"],"depends_on":["PTO-ARCH-DATA-TYPES-MEMORY-MODEL"]}
type AddressUpdateMode of enumeration {
    AddressUpdate_None,
    AddressUpdate_PreIndex,
    AddressUpdate_PostIndex
};

type AtomicOperation of enumeration {
    Atomic_SWAP,
    Atomic_ADD,
    Atomic_AND,
    Atomic_OR,
    Atomic_XOR,
    Atomic_SMIN,
    Atomic_SMAX,
    Atomic_UMIN,
    Atomic_UMAX
};
```
<!-- GENERATED-ASL-END: unit -->
