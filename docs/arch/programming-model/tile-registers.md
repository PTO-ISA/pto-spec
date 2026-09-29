<!-- GENERATED FROM: asl/arch/programming-model/tile-registers.asl -->
# Tile Registers

**Normative ASL source:** `asl/arch/programming-model/tile-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-tile-registers-purpose-scope role=purpose-scope -->
## Purpose and scope

A Tile is a two-dimensional block of elements held in architectural Tile storage. Tile operations read Tiles as sources and publish new Tiles as destinations. This unit is the named programming-model entry for Local Tile registers and routes the reader to the ASL owners that define them.

The unit itself declares no storage and no access procedure. Its source states that executable state is defined by its dependencies.

<!-- PTO-READER-BLOCK: arch-tile-registers-concepts-state role=concepts-state -->
## Concept ownership

There are `64` Local Tile registers. Each one holds a `TileInfo` descriptor, which records allocation, shape, valid region, data type, layout, capacity, element definedness, and payload. Each register also has a four-bit allocation mask that records which PEs hold a fragment of it.

The registers are grouped into four hands, T, U, M, and N, of `16` registers each. Programs name a Local Tile by hand and recency, such as `T#1` for the newest T Tile and `T#2` for the one before it.

Design point: a destination names only its hand, not a register number. When a destination publishes, it becomes `#1` of its hand, and the older live generations shift toward `#16`. Source generations persist, so a program keeps reading an older Tile by its new relative name, for example `T#2`.

<!-- PTO-READER-BLOCK: arch-tile-registers-rules-interactions role=rules-interactions -->
## Dependency relationship

`PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS` depends on `PTO-ARCH-FEATURES-PREDICATION`. The dependency graph, not supplementary prose, determines which reachable ASL owner supplies a concrete state rule.

The Local Tile storage itself is `PTO-STATE-TILE-LOCAL`, owned by the Tile local-register model. It is one member of the closed architecture state set.

Design point: every Tile an operation reads or publishes is a named Local or Shared Tile register with an explicit descriptor, and `PTO-STATE-TILE-LOCAL` and `PTO-STATE-TILE-SHARED` are the Tile register members of the closed architecture state set. Implementation storage outside that set, such as the CUBE internal accumulator cache, must not change architectural results, faults, or publication.

<!-- PTO-READER-BLOCK: arch-tile-registers-boundaries role=boundaries -->
## Architectural boundaries

This concept page does not assign Tile shapes, data, validity, capacity, predication results, or instruction effects. A reader must use the relevant feature, state, and instruction owner for those contracts.

Capacity is charged per PE. One `B.IOT` destination may use `128 B` through `64 KiB`, charged to each selected PE's `256 KiB` Local pool, independently of the Shared pool.

<!-- PTO-READER-BLOCK: arch-tile-registers-example-usage role=example-usage -->
## Non-normative reading example

For a Tile-register predication question, begin here for the programming-model term, follow the predication dependency, and then use the generated ASL and its AVS references to inspect the actual owner.

For a naming example, suppose `T#1` names Tile A and `T#2` names Tile B. The macro `TADD <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>` publishes the sum as a new `T#1`. After it completes, Tile A is still live and is named `T#2`, and Tile B is named `T#3`.

<!-- PTO-READER-BLOCK: arch-tile-registers-related-owners role=related-owners-navigation -->
## Related owners

- [Predication](../features/predication.md) is the direct dependency.
- [Local Tile registers](../../tile/model/state/local-registers.md) owns `PTO-STATE-TILE-LOCAL` and the newest-first hand rule.
- [Tile allocation](../features/tile-allocation.md) declares the Local pool and per-object capacity limits.
- [Shared Tile registers](shared-tile-registers.md) builds its named concept on this unit.
- [Core PE topology](core-pe-topology.md) declares the Tile and Shared Tile namespace counts.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/tile-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS","surface":"arch","classification":["programming-model","tile-registers"],"depends_on":["PTO-ARCH-FEATURES-PREDICATION"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
