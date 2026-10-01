<!-- GENERATED FROM: asl/arch/state/tile-descriptor.asl -->
# Tile Descriptor

**Normative ASL source:** `asl/arch/state/tile-descriptor.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-TILE-DESCRIPTOR}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-tile-descriptor-purpose-scope role=purpose-scope -->
## Purpose and scope

`asl/arch/state/tile-descriptor.asl` is a two-line unit. Line 1 is the `PTO-UNIT` JSON naming `PTO-ARCH-STATE-TILE-DESCRIPTOR` and the dependency `PTO-ARCH-FEATURES-SHARED-TILE-STATE`; line 2 is the comment that the unit owns the named architecture concept and that executable state is defined by its dependencies.

No descriptor record, field, accessor or transition is declared here, and the file contains no `DOC-BEGIN` or `NDF-BEGIN` region. This page is the stable name of the concept plus a pointer to the owners that hold descriptor state.

<!-- PTO-READER-BLOCK: arch-tile-descriptor-concepts-state role=concepts-state -->
## What the declared dependency contains

The dependency named on line 1 is name-only as well. `asl/arch/features/shared-tile-state.asl` is two lines and its `PTO-UNIT` JSON names `PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS`, which is two lines and names `PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS`, which is two lines and names `PTO-ARCH-FEATURES-PREDICATION`.

The first unit on that chain with executable ASL is `PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS` in `asl/arch/programming-model/predicate-registers.asl`. Further along the same chain sit `asl/arch/programming-model/execution-context.asl` and `asl/arch/system-registers/addressing.asl`, whose `ResetProfileState` clears the descriptor-bearing records.

Executable descriptor state is declared in `asl/tile/model/state/types.asl`. `SharedTileInfo` has `descriptor_valid` of type `boolean`, `allocation_mask` of type `bits(4)`, `initialized_mask` of type `bits(4)`, `whole_parent_ready` of type `boolean`, `published` of type `boolean` and `tile` of type `TileInfo`. `SharedTileSnapshot` is `array [[PTO_SHARED_TILE_COUNT]] of SharedTileInfo`, and `_SharedTiles` is declared with that type in `asl/tile/model/state/local-registers.asl`, so one core holds `64` Shared records.

Design point: `descriptor_valid` is an allocation gate, not a cached legality result. `SharedTileDescriptorLegal` in `asl/tile/model/state/shared-registers.asl` recomputes legality from `descriptor_valid`, `tile.allocated`, a nonzero `allocation_mask`, the mask test `(initialized_mask AND NOT allocation_mask) == Zeros{4}` and capacity and shape tests on the record it reads at that moment. Changing `initialized_mask` or the geometry therefore changes descriptor legality without any write to `descriptor_valid`.

<!-- PTO-READER-BLOCK: arch-tile-descriptor-rules-interactions role=rules-interactions -->
## How descriptor state changes

`AtomicUpdateSharedTileWithPublication` is the commit point. It builds `updated` from the current record, sets `descriptor_valid`, `allocation_mask` and `tile` on first allocation, advances `initialized_mask` for multi-PE producers, and ends with one record assignment `_SharedTiles[[index]] = updated`. A zero PE mask returns `TRUE` before any write. `SharedTilePublished` then requires `descriptor_valid`, `initialized_mask == allocation_mask`, `tile.contents_defined`, `whole_parent_ready` and `published`.

Local Tile geometry and definedness use the same `TileInfo` type that is nested inside `SharedTileInfo`. `ResetProfileState` clears `_Tiles[[index]]` fields including `allocated`, `contents_defined`, `defined_elements`, `defined_valid_elements`, `capacity_bytes`, `rows`, `columns`, `valid_rows`, `valid_columns`, `data_type` and `layout`, and clears `_SharedTiles[[index]].descriptor_valid` and `published`.

Shape legality is computed rather than stored. `TileDescriptorShapeLegal` in `asl/tile/model/shape/valid-region.asl` derives `rows` from `capacity_bytes`, `columns` and `data_type` with `DerivedTileRows`, then checks `valid_rows <= rows`, `valid_columns <= columns` and that the valid area fits `TileLogicalElementCapacity`.

<!-- PTO-READER-BLOCK: arch-tile-descriptor-boundaries role=boundaries -->
## Architectural boundaries

This page does not invent descriptor layout, validity, capacity, ownership, lifetime or fault behaviour. Each of those rules must be read from the record declaration or from the helper that implements it.

An invalid Shared record is not a fault. `ReadSharedTileWord` returns `UndefinedSharedTileWord(shared_tile_id, element)` when `descriptor_valid` is `FALSE`, when `whole_parent_ready` is `FALSE` or when the addressed element is undefined, and the read neither allocates the register nor changes Shared state.

Design point: because the Shared record nests a complete `TileInfo` by value instead of referring to a local Tile, publication moves one descriptor plus payload snapshot at a time. `MaterializeSharedTile` asserts `SharedTilePublished` and returns `shared.tile`, so a consumer that passes the check reads one internally consistent descriptor and cannot observe a half-updated field set.

<!-- PTO-READER-BLOCK: arch-tile-descriptor-example-usage role=example-usage -->
## Reading example

Immediately after `ResetProfileState`, a Shared record has `descriptor_valid` `FALSE` and `allocation_mask` `0000`, so `SharedTileDescriptorLegal` is `FALSE` and `ReadSharedTileWord` answers with the deterministic model value produced by `UndefinedSharedTileWord`. One `AtomicUpdateSharedTileWithPublication` call with a single-PE mask or the mask `1111`, `publish` true and a record whose `tile.contents_defined` is true sets `descriptor_valid`, `allocation_mask`, `initialized_mask`, `whole_parent_ready` and `published` in that one commit, after which `SharedTilePublished` is `TRUE`.

<!-- PTO-READER-BLOCK: arch-tile-descriptor-related-owners role=related-owners-navigation -->
## Related owners

- [Shared Tile state](../features/shared-tile-state.md) is the dependency named on line 1.
- [Shared Tile registers](../programming-model/shared-tile-registers.md) and [Tile registers](../programming-model/tile-registers.md) continue that chain.
- [Shared registers state](../../tile/model/state/shared-registers.md) owns the descriptor legality and publication helpers.
- [Tile state types](../../tile/model/state/types.md) declares `TileInfo` and `SharedTileInfo`.
- [Definedness](definedness.md) names this concept owner as its dependency.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/tile-descriptor.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-TILE-DESCRIPTOR","surface":"arch","classification":["state","tile-descriptor"],"depends_on":["PTO-ARCH-FEATURES-SHARED-TILE-STATE"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
