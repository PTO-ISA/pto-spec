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

本单元为标量、块、Tile、内存、系统寄存器和陷阱归属单元共享的定宽载体与有界索引域命名。

集中定义这些类型后，ASL 签名可以直接表明整数所属的架构域，而无需到处传递无约束整数。

<!-- PTO-READER-BLOCK: arch-integer-types-concepts-state role=concepts-state -->
## 概念与可见状态

- `Word`、`DoubleWord`、`HalfWord` 和 `Byte` 的宽度分别是 `PTO_XLEN`、`PTO_XLEN * 2`、`32` 和 `8` 位；`PredicateWord` 使用 `PTO_PREDICATE_WIDTH`。
- 寄存器索引和绑定索引由各自的数量常量限定，包括 `GPRIndex`、`TileIndex`、`PredicateIndex` 以及各类束绑定索引。
- 地址相关类型区分 `ModelAddress`、24 位 `SystemRegisterAddress` 和 16 位文件索引 `SystemRegisterFileIndex`；陷阱使用六位 `TrapNumber` 和范围为 `0..63` 的 `InterruptID`。

<!-- PTO-READER-BLOCK: arch-integer-types-rules-interactions role=rules-interactions -->
## 规则与交互

`PERegisterFile` 和 `CorePEWords` 等数组类型从模型常量取得范围，不引入新的架构数量。

`SharedTileID` 是六位载体，`SharedTileIndex` 则是有界整数索引；调用者不能混用这两个不同角色。

打包 Tile 索引具有明确的模型边界：元素为 `0..524287`，载体为 `0..PTO_MODEL_TILE_ELEMENTS-1`，通道为 `0..15`。

<!-- PTO-READER-BLOCK: arch-integer-types-boundaries role=boundaries -->
## 架构边界

包含 `PTO_MODEL_*` 的边界属于验证模型边界，并不声称所有实现都具有相同的物理容量。

本单元只定义类型；状态分配、访问检查、故障和指令效果仍由使用这些类型的归属单元定义。

<!-- PTO-READER-BLOCK: arch-integer-types-example-usage role=example-usage -->
## 非规范阅读示例

接受 `TileIndex` 的函数只能接收 `0..PTO_TILE_REGISTER_COUNT-1` 范围内的索引；六位 `SharedTileID` 仍需显式映射后才能用作 `SharedTileIndex`。

模型数组范围应理解为当前 ASL 模型的类型检查契约；架构可见的容量规则仍需查阅使用该类型的状态归属单元。

<!-- PTO-READER-BLOCK: arch-integer-types-related-owners role=related-owners-navigation -->
## 相关归属单元

- [Tile 数据类型](tile-data-types.md)
- [内存模型类型](memory-model.md)
- [系统寄存器类型](system-registers.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/integer.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-INTEGER","surface":"arch","classification":["data-types","integer"],"depends_on":["PTO-ARCH-FEATURES-TILE-ALLOCATION"]}
// Requirement references: PTO-REQ-STATE-001, PTO-REQ-TILE-001,
// PTO-REQ-FAULT-001, PTO-REQ-MEMORY-TSO-001.

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
