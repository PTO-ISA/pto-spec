<!-- GENERATED FROM: asl/arch/data-types/integer.asl -->
# Integer

**Normative ASL source:** `asl/arch/data-types/integer.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-INTEGER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-integer-types-purpose-scope role=purpose-scope -->
## 目的与范围

本单元命名标量、块、Tile、内存、系统寄存器和陷阱所有者共享的定宽载体与有界索引域。

它只包含类型声明，因此它定义的是各类整数是什么，而不是任何指令对整数做什么。

<!-- PTO-READER-BLOCK: arch-integer-types-concepts-state role=concepts-state -->
## 概念与可见状态

`Word` 是 `PTO_XLEN` 位，`DoubleWord` 是 `PTO_XLEN * 2` 位，`HalfWord` 是 `32` 位，`Byte` 是 `8` 位，`PredicateWord` 是 `PTO_PREDICATE_WIDTH` 位。

各索引域由各自的数量常量限定：`GPRIndex` 由绝对 GPR 数量限定，`TileIndex` 由 Tile 寄存器数量限定，`PredicateIndex` 由谓词寄存器数量限定，指令束维度、标量绑定和 Tile 绑定索引由各自的数量限定，而 `BundleSharedBindingIndex` 由字面量 `0..3` 限定。

面向地址与标识的类型彼此独立：`ModelAddress` 索引模型内存字节，`SystemRegisterAddress` 是二十四位载体，`SystemRegisterFileIndex` 是 `0..65535` 范围内的十六位文件索引，`TrapNumber` 是六位，`InterruptID` 是 `0..63` 范围内的整数。

<!-- PTO-READER-BLOCK: arch-integer-types-rules-interactions role=rules-interactions -->
## 规则与交互

设计要点：在共享声明中命名这些域，意味着宽度或数量只写一次，因此读取 `GPRIndex` 的调用方无法静默接受来自其他命名空间的索引。

`PERegisterFile`、`CorePEWords` 和 `MemoryRelationMatrix` 等数组类型从模型常量取得范围，因此它们描述的是本模型，而不是可移植的硬件容量。

`SharedTileID` 是六位载体，而 `SharedTileIndex` 是有界整数索引，因此原始标识符必须先经过映射才能用于索引共享 Tile。

<!-- PTO-READER-BLOCK: arch-integer-types-boundaries role=boundaries -->
## 架构边界

打包 Tile 的元素、载体和 lane 索引具有互不相同的边界：`0..524287`、`0..PTO_MODEL_TILE_ELEMENTS-1` 和 `0..15`。

设计要点：把标识载体与有界索引分开，可以避免解码出的字段在没有显式映射步骤的情况下被用作数组下标。

本单元只声明类型名，不含任何函数，因此上面的声明就是各种整数类型的完整定义。

包含 `PTO_MODEL_*` 或固定元素数量的边界属于验证模型边界，并不声称所有实现都具有相同的物理容量。

<!-- PTO-READER-BLOCK: arch-integer-types-example-usage role=example-usage -->
## 非规范阅读示例

本例说明当前的 ASL 归属单元，不替代规范操作。

`ModelAddress` 由 `PTO_MODEL_MEMORY_BYTES` 限定，因此它描述的是本模型的内存，而不是任何实现的地址空间。

<!-- PTO-READER-BLOCK: arch-integer-types-related-owners role=related-owners-navigation -->
## 相关归属单元

- [Tile 数据类型](tile-data-types.md)定义已分配的 Tile 数据类型词汇。

- [内存模型类型](memory-model.md)定义由这些载体构建的内存记录。

- [系统寄存器类型](system-registers.md)定义系统寄存器词汇。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/integer.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-INTEGER","surface":"arch","classification":["data-types","integer"],"depends_on":["PTO-ARCH-FEATURES-TILE-ALLOCATION"]}
// Requirement references: PTO-REQ-STATE-001, PTO-REQ-TILE-001,
// PTO-REQ-FAULT-001, PTO-REQ-MEMORY-RC-001.

type Word of bits(PTO_XLEN);
type DoubleWord of bits(PTO_XLEN * 2);
type HalfWord of bits(32);
type Byte of bits(8);
type PredicateWord of bits(PTO_PREDICATE_WIDTH);
type GPRIndex of integer {0..PTO_ABSOLUTE_GPR_COUNT-1};
type PERegisterFile of array [[PTO_ABSOLUTE_GPR_COUNT]] of Word;
type CorePEWords of array [[PTO_MODEL_MEMORY_AGENTS]] of Word;
type Reg5Selector of integer {0..31};
type TileIndex of integer {0..PTO_TILE_REGISTER_COUNT-1};
type SharedTileID of bits(6);
type SharedTileIndex of integer {0..PTO_SHARED_TILE_COUNT-1};
type TemporaryQueueIndex of integer {0..PTO_TEMPORARY_QUEUE_DEPTH-1};
type PredicateIndex of integer {0..PTO_PREDICATE_REGISTER_COUNT-1};
type BundleDimensionIndex of integer {0..PTO_BUNDLE_DIMENSION_COUNT-1};
type BundleScalarBindingIndex of integer {0..PTO_BUNDLE_SCALAR_BINDING_COUNT-1};
type BundleTileBindingIndex of integer {0..PTO_BUNDLE_TILE_BINDING_COUNT-1};
type BundleSharedBindingIndex of integer {0..3};
type TileBaseIndex of integer {0..PTO_TILE_BASE_COUNT-1};
type ModelTileElementIndex of integer {0..PTO_MODEL_TILE_ELEMENTS-1};
type PackedTileElementIndex of integer {0..524287};
type PackedTileCarrierIndex of integer {0..PTO_MODEL_TILE_ELEMENTS-1};
type PackedTileLaneIndex of integer {0..15};
type ModelAddress of integer {0..PTO_MODEL_MEMORY_BYTES-1};
type SystemRegisterAddress of bits(24);
type SystemRegisterFileIndex of integer {0..65535};
type TrapNumber of bits(6);
type InterruptID of integer {0..63};
```
<!-- GENERATED-ASL-END: unit -->
