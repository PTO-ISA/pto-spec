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

This unit names the fixed-width carriers and bounded index domains shared by scalar, block, tile, memory, system-register, and trap owners.

Central type ownership lets ASL signatures expose which architectural domain an integer belongs to instead of passing unconstrained integers everywhere.

<!-- PTO-READER-BLOCK: arch-integer-types-concepts-state role=concepts-state -->
## Concepts and visible state

- `Word`, `DoubleWord`, `HalfWord`, and `Byte` are `PTO_XLEN`, `PTO_XLEN * 2`, `32`, and `8` bits respectively; `PredicateWord` uses `PTO_PREDICATE_WIDTH`.
- Register and binding indices are bounded by their owning count constants, including `GPRIndex`, `TileIndex`, `PredicateIndex`, and the bundle binding index types.
- Address-facing types separate `ModelAddress`, 24-bit `SystemRegisterAddress`, and 16-bit-file `SystemRegisterFileIndex`; traps use six-bit `TrapNumber` and `0..63` `InterruptID`.

<!-- PTO-READER-BLOCK: arch-integer-types-rules-interactions role=rules-interactions -->
## Rules and interactions

Array types such as `PERegisterFile` and `CorePEWords` derive their extents from model constants rather than introducing new architectural counts.

`SharedTileID` is a six-bit carrier, while `SharedTileIndex` is a bounded integer index; callers must not treat those distinct roles as interchangeable.

Packed tile indices have explicit model bounds: element `0..524287`, carrier `0..PTO_MODEL_TILE_ELEMENTS-1`, and lane `0..15`.

<!-- PTO-READER-BLOCK: arch-integer-types-boundaries role=boundaries -->
## Architectural boundaries

Bounds containing `PTO_MODEL_*` are verification-model bounds. They are not claims that every implementation has the same physical capacity.

This unit defines types only; state allocation, access checks, faults, and instruction effects remain in the owners that consume them.

<!-- PTO-READER-BLOCK: arch-integer-types-example-usage role=example-usage -->
## Non-normative reading example

A function accepting `TileIndex` can only receive an index in `0..PTO_TILE_REGISTER_COUNT-1`; a six-bit `SharedTileID` still requires an explicit mapping before it can serve as a `SharedTileIndex`.

Read a model-bound array extent as a type-checking contract for this ASL model, then follow the consuming state owner for architecture-visible capacity rules.

<!-- PTO-READER-BLOCK: arch-integer-types-related-owners role=related-owners-navigation -->
## Related owners

- [Tile data types](tile-data-types.md)
- [Memory model types](memory-model.md)
- [System register types](system-registers.md)
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
