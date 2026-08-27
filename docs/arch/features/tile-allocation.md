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

This unit fixes the capacities and model parameters used when PTO reasons about Local and Shared Tile allocation. It separates architectural capacity constants from ASL verification bounds.

<!-- PTO-READER-BLOCK: arch-tile-allocation-concepts role=concepts-state -->
## Capacity model

- A Tile cell is `128` bytes, and each pool contains `2048` cells, yielding `262144` bytes.
- Each PE has an independent Local pool; the Core has a separate Shared pool.
- `PTO_RESERVATION_GRANULE_BYTES` is `64`, while the bundle exposes `3` dimensions, `32` scalar bindings, and `16` Tile bindings.

<!-- PTO-READER-BLOCK: arch-tile-allocation-rules role=rules-interactions -->
## Rules and interactions

Local and Shared allocations consume different budgets. `PTO_TILE_MAX_ALLOCATION_BYTES` caps one Local object at `65536` bytes, while `PTO_SHARED_TILE_MAX_ALLOCATION_BYTES` permits one Shared object up to `262144` bytes. The separate `PTO_TILE_CAPACITY_BYTES` value keeps each PE's aggregate Local pool at `262144` bytes.

<!-- PTO-READER-BLOCK: arch-tile-allocation-boundaries role=boundaries -->
## Model boundaries

`PTO_MODEL_TILE_ELEMENTS` defaults to `32768` so the executable model can carry the largest required witnesses. `PTO_MODEL_MEMORY_BYTES` defaults to `4096` within its declared `256` through `65536` range. These static ASL bounds are verification configuration, not universal payload, profile, or implementation limits.

<!-- PTO-READER-BLOCK: arch-tile-allocation-example role=example-usage -->
## Non-normative capacity example

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-tile-allocation-related role=related-owners-navigation -->
## Related owners

- `PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY` defines the topology assumed by the independent pools.
- Allocation instructions and Tile state owners apply these constants to concrete transitions.
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
config PTO_MODEL_TILE_ELEMENTS : integer {1..32768} = 32768;
config PTO_MODEL_MEMORY_BYTES : integer {256..65536} = 4096;
```
<!-- GENERATED-ASL-END: unit -->
