<!-- GENERATED FROM: asl/arch/data-types/integer.asl -->
# Integer

**Normative ASL source:** `asl/arch/data-types/integer.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-INTEGER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-integer-types-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit names the fixed-width carriers and bounded index domains shared by the scalar, block, tile, memory, system-register, and trap owners.

It contains only type declarations, so it defines what an integer of each kind is and not what any instruction does with one.

<!-- PTO-READER-BLOCK: arch-integer-types-concepts-state role=concepts-state -->
## Concepts and visible state

`Word` is `PTO_XLEN` bits, `DoubleWord` is `PTO_XLEN * 2` bits, `HalfWord` is `32` bits, `Byte` is `8` bits, and `PredicateWord` is `PTO_PREDICATE_WIDTH` bits.

The index domains are bounded by their owning counts: `GPRIndex` over the absolute GPR count, `TileIndex` over the Tile register count, `PredicateIndex` over the predicate register count, and the bundle dimension, scalar-binding, and Tile-binding indices over their own counts, while `BundleSharedBindingIndex` is bounded by the literal `0..3`.

The address-facing and identity types are separate: `ModelAddress` indexes model memory bytes, `SystemRegisterAddress` is a twenty-four-bit carrier, `SystemRegisterFileIndex` is a sixteen-bit-file index in `0..65535`, `TrapNumber` is six bits, and `InterruptID` is an integer in `0..63`.

<!-- PTO-READER-BLOCK: arch-integer-types-rules-interactions role=rules-interactions -->
## Rules and interactions

Design point: naming the domains in shared declarations means a width or a count is written once, so a consumer that reads `GPRIndex` cannot silently accept an index from a different namespace.

Array types such as `PERegisterFile`, `CorePEWords`, and `MemoryRelationMatrix` take their extents from model constants, so they describe this model rather than a portable hardware capacity.

`SharedTileID` is a six-bit carrier while `SharedTileIndex` is a bounded integer index, so a raw identifier must be mapped before it can index a shared Tile.

<!-- PTO-READER-BLOCK: arch-integer-types-boundaries role=boundaries -->
## Architectural boundaries

The packed Tile element, carrier, and lane indices have distinct bounds: `0..524287`, `0..PTO_MODEL_TILE_ELEMENTS-1`, and `0..15`.

Design point: separating an identifier carrier from a bounded index keeps a decoded field from being used as an array subscript without an explicit mapping step.

This unit declares type names only and contains no functions, so the declarations above are the complete definition of each integer kind.

Bounds that mention `PTO_MODEL_*` or a fixed element count are verification-model bounds, and they are not a claim that every implementation has the same physical capacity.

<!-- PTO-READER-BLOCK: arch-integer-types-example-usage role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

`ModelAddress` is bounded by `PTO_MODEL_MEMORY_BYTES`, so it describes the memory of this model rather than any implementation's address space.

<!-- PTO-READER-BLOCK: arch-integer-types-related-owners role=related-owners-navigation -->
## Related owners

- [Tile data types](tile-data-types.md) defines the assigned Tile data-type vocabulary.

- [Memory model types](memory-model.md) defines the memory records built from these carriers.

- [System register types](system-registers.md) defines the system-register vocabulary.
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
