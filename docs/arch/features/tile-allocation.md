<!-- GENERATED FROM: asl/arch/features/tile-allocation.asl -->
# Tile Allocation

**Normative ASL source:** `asl/arch/features/tile-allocation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-TILE-ALLOCATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-tile-allocation-purpose role=purpose-scope -->
## Purpose and scope

This unit declares the capacity model that Tile allocation reads. Its whole ASL body is `11` `constant` declarations and `2` `config` declarations, with no function, no state variable, no fault and no executable transition.

Line 1 records classification `features/tile-allocation` and `depends_on` `PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY`, which defines the per-PE topology the independent pools assume.

Design point: the pool size and the largest single object are separate constants, so a full pool and one oversized object are two independent rejections: `PTO_TILE_MAX_ALLOCATION_BYTES` bounds one Local object while `PTO_TILE_CAPACITY_BYTES` bounds the aggregate Local pool.

<!-- PTO-READER-BLOCK: arch-tile-allocation-concepts role=concepts-state -->
## Constants and configuration

- `PTO_TILE_CELL_BYTES` is `128` and `PTO_TILE_CELL_COUNT` is `2048`, so `PTO_TILE_CAPACITY_BYTES` is `262144` bytes.
- `PTO_TILE_MAX_ALLOCATION_BYTES` caps one Local object at `65536` bytes, which is `512` cells; `PTO_SHARED_TILE_MAX_ALLOCATION_BYTES` caps one Shared object at `262144` bytes, the whole Shared pool; and `PTO_MODEL_MAX_TILE_CAPACITY_BYTES` is defined as `PTO_TILE_CAPACITY_BYTES`.
- `PTO_RESERVATION_GRANULE_BYTES` is `64`, half of one cell, and the counts are `PTO_BUNDLE_DIMENSION_COUNT` `3`, `PTO_BUNDLE_SCALAR_BINDING_COUNT` `32`, `PTO_BUNDLE_TILE_BINDING_COUNT` `16`, `PTO_TILE_BASE_COUNT` `6`.
- `PTO_MODEL_TILE_ELEMENTS` is a `config` with declared range `1` through `32768` and default `32768`; `PTO_MODEL_MEMORY_BYTES` is a `config` with declared range `256` through `65536` and default `4096`.

Design point: the two `config` values are model bounds, not architectural numbers. The comment derives the `32768` default from `S63` witnesses for the `262144`-byte Shared boundary.

<!-- PTO-READER-BLOCK: arch-tile-allocation-rules role=rules-interactions -->
## Rules and interactions

Neither constant is a combined budget: the Local and Shared pools stay separate.

Design point: the Local object cap is one quarter of the Local pool, because `65536` times `4` is `262144`. Four maximal Local objects fill a PE's pool exactly; a fifth is rejected on the aggregate budget even though its own capacity is legal. The Shared object cap equals its pool.

<!-- PTO-READER-BLOCK: arch-tile-allocation-boundaries role=boundaries -->
## Model boundaries

Design point: the comment on `PTO_MODEL_TILE_ELEMENTS` states that ASL arrays require static bounds, that the model needs `32768` element slots to carry `S63` witnesses for the `262144`-byte Shared boundary, and that this is a model bound rather than a claim that every payload uses that many elements. A payload past the model bound is a model limitation, not an architectural rejection.

The same comment tells bounded callers to size per-step timeouts for a whole-tile step. This file carries no `NDF-BEGIN` clause; the accepted per-PE capacity clause is `PTO-TILE-CAPACITY-PER-PE` in `asl/arch/overview/architecture.asl`: a Local allocation is one selected PE's share of its independent 256 KiB pool, a Shared allocation is one Core-wide allocation in the independent 256 KiB Shared pool, and the two must not consume one combined budget.

<!-- PTO-READER-BLOCK: arch-tile-allocation-example role=example-usage -->
## Non-normative capacity example

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

A Local object at the `65536`-byte cap occupies `512` of a PE's `2048` cells. Four such objects fill the aggregate pool exactly; a fifth is rejected because `5` times `65536` is more than `262144`, not because its own capacity is illegal.

One Shared object may hold `262144` bytes while each of two Local objects holds `65536` bytes: the Local total is `131072` against the Local pool, the Shared total is `262144` against the Shared pool, and neither sum is charged to the other pool.

Design point: because the pools are independent and equal in size, one maximal Shared object and four maximal Local objects per selected PE can be held at once; on the Local side the per-object cap binds, not the cell count.

<!-- PTO-READER-BLOCK: arch-tile-allocation-related role=related-owners-navigation -->
## Related owners

- `PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY` is the declared dependency.
- Tile state owners apply these constants: for example `asl/tile/model/state/descriptors.asl` bounds a Local capacity to whole `128`-byte cells no larger than `PTO_TILE_MAX_ALLOCATION_BYTES`; `asl/tile/model/capacity/shared.asl` returns `PTO_SHARED_TILE_MAX_ALLOCATION_BYTES`.
- `asl/tile/model/capacity/local.asl` bounds the live Local budget by `PTO_MODEL_MAX_TILE_CAPACITY_BYTES`, the ceiling over the `tile_capacity` system register; scalar atomic units use `PTO_RESERVATION_GRANULE_BYTES` as their reservation granule.
- `PTO-TILE-CAPACITY-PER-PE` is owned by `asl/arch/overview/architecture.asl`, not by this unit.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/tile-allocation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-TILE-ALLOCATION","surface":"arch","classification":["features","tile-allocation"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY"]}
// Every PE owns an independent 2048-cell Local pool; one Local object
// is capped at 64 KiB. Multiple Local objects may consume the aggregate pool.
// The Core also owns one
// independent 2048-cell Shared pool.  Local and Shared allocations do not
// compete for one combined capacity budget.
constant PTO_TILE_CELL_BYTES = 128;
constant PTO_TILE_CELL_COUNT = 2048;
constant PTO_TILE_CAPACITY_BYTES = 262144;
constant PTO_TILE_MAX_ALLOCATION_BYTES = 65536;
constant PTO_SHARED_TILE_MAX_ALLOCATION_BYTES = 262144;
constant PTO_MODEL_MAX_TILE_CAPACITY_BYTES = PTO_TILE_CAPACITY_BYTES;
constant PTO_RESERVATION_GRANULE_BYTES = 64;
constant PTO_BUNDLE_DIMENSION_COUNT = 3;
constant PTO_BUNDLE_SCALAR_BINDING_COUNT = 32;
constant PTO_BUNDLE_TILE_BINDING_COUNT = 16;
constant PTO_TILE_BASE_COUNT = 6;

// ASL arrays require static bounds. The executable model uses S63 witnesses
// for the 256 KiB Shared boundary, requiring 32,768 element slots. This is a
// model bound, not a claim that every payload uses that many architectural
// elements.
//
// Performance bound (issue #287): with the pinned ASLRef interpreter every
// whole-tile operation step moves the full 32,768-element payload and its
// definedness bitmap regardless of the valid region, measured at roughly
// 4 s per step (3.8-4.0 s per PE on a 4-PE BSTART.TSTORE, 2026-09). Callers
// running bounded ELF consistency checks should size per-step timeouts
// accordingly (for example --timeout-s 600 for 4-PE runs). Implementations
// may accelerate the payload path by sparse indexing, vectorization, or
// equivalent means provided observable semantics are unchanged.
config PTO_MODEL_TILE_ELEMENTS : integer {1..32768} = 32768;
config PTO_MODEL_MEMORY_BYTES : integer {256..65536} = 4096;
```
<!-- GENERATED-ASL-END: unit -->
