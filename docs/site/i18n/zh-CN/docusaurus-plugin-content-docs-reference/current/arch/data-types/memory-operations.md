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

本单元命名标量与 Tile 内存执行共享的地址更新选择器和原子操作选择器。

将这些选择器集中在一个归属单元中，可以避免各条指令为同一操作类别采用不兼容的名称。

<!-- PTO-READER-BLOCK: arch-memory-operations-concepts-state role=concepts-state -->
## 概念与可见状态

- `AddressUpdateMode` 包含 `AddressUpdate_None`、`AddressUpdate_PreIndex` 和 `AddressUpdate_PostIndex`。
- `AtomicOperation` 涵盖交换、加法、按位 AND/OR/XOR、有符号最小值/最大值以及无符号最小值/最大值。
- 这些枚举是可执行辅助函数的类型化输入，本身不包含地址计算或读改写行为。

<!-- PTO-READER-BLOCK: arch-memory-operations-rules-interactions role=rules-interactions -->
## 规则与交互

前索引和后索引是不同的选择器；使用它们的指令归属单元决定何时计算并提交基址更新。

有符号与无符号最小值/最大值使用独立枚举成员：`Atomic_SMIN`、`Atomic_SMAX`、`Atomic_UMIN` 和 `Atomic_UMAX`。

任何枚举成员都不隐含故障、顺序、大小或发布规则；这些参数和行为仍由使用方归属单元定义。

<!-- PTO-READER-BLOCK: arch-memory-operations-boundaries role=boundaries -->
## 架构边界

本单元没有后备值或实现定义的选择器；解码器必须在执行前映射到某个已声明成员。

选择器身份具有可移植性，但具体指令形式是否受支持、是否合法，仍由该指令当前的 ASL 归属单元定义。

<!-- PTO-READER-BLOCK: arch-memory-operations-example-usage role=example-usage -->
## 非规范阅读示例

选择 `Atomic_ADD` 的原子指令仍需定义自己的地址、宽度、顺序、故障和提交契约；此枚举只提供操作身份。

同样，`AddressUpdate_PostIndex` 只标识模式，本身并未规定访问失败时是否更新基址寄存器。

<!-- PTO-READER-BLOCK: arch-memory-operations-related-owners role=related-owners-navigation -->
## 相关归属单元

- [内存模型类型](memory-model.md)
- [原子性](../memory-model/atomicity.md)
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
