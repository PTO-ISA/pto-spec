<!-- GENERATED FROM: asl/arch/programming-model/shared-tile-registers.asl -->
# Shared Tile Registers

**Normative ASL source:** `asl/arch/programming-model/shared-tile-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-shared-tile-registers-purpose-scope role=purpose-scope -->
## Purpose and scope

A Shared Tile is a Tile that all four PEs of a Core address in common. Local Tiles are split into per-PE fragments; a Shared Tile is one Core-wide object. This unit is the named programming-model entry for Shared Tile registers and routes the reader to the ASL owners that define them.

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-concepts-state role=concepts-state -->
## Concept ownership

The owner contains no executable state declaration or access helper of its own. Its source explicitly delegates executable state to its dependencies.

The state it names is `PTO-STATE-TILE-SHARED`: `64` absolute, Core-private registers `S0` through `S63`. Each record holds a Tile descriptor and payload, an allocation mask, an initialized mask, a whole-parent readiness flag, and a published flag. All four PEs of one Core address the same `64` records.

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-rules-interactions role=rules-interactions -->
## Dependency relationship

`PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS` depends on `PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS`. Read the dependency and its reachable state owners for executable behavior.

Shared Tiles are bound by `B.IOS`, not by `B.IOT`. One `B.IOS` SizeCode describes one complete Core-wide Shared allocation.

Design point: Shared Tiles have their own `256 KiB` pool, separate from every PE's Local pool. A Shared allocation therefore never reduces the Local capacity on any PE, and filling Local storage never blocks a Shared allocation.

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-boundaries role=boundaries -->
## Architectural boundaries

This page does not define allocation, lifetime, capacity, aliasing, or instruction effects for Shared Tile state. Those rules must come from the owning reachable ASL rather than from this explanatory page.

Design point: producer coverage, whole-parent readiness, and publication are kept as separate facts. A Shared source consumer must wait or no-op until the parent is both whole-parent ready and published, so a consumer on one PE cannot read a Shared Tile that other PEs are still writing.

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-example-usage role=example-usage -->
## Non-normative reading example

When a question asks how a Shared Tile register changes, use this page to identify the named concept, then continue through the dependency link until reaching the ASL unit that owns the relevant state transition.

For example, after a first write records allocation mask `1100` for `S7`, a later write to `S7` may select the subset `1000`. A write that selects `0011` includes PEs outside the recorded mask and is not a compatible update of `S7`.

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-related-owners role=related-owners-navigation -->
## Related owners

- [Tile registers](tile-registers.md) is the direct dependency.
- [Shared Tile state](../features/shared-tile-state.md) is a related downstream state owner; it is not a declared dependency of this unit.
- [Shared Tile register model](../../tile/model/state/shared-registers.md) owns the readiness, publication, and mask rules.
- [Architecture overview](../overview/architecture.md) lists Shared Tile state in the architecture state closure and owns the Shared capacity contract.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/shared-tile-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS","surface":"arch","classification":["programming-model","shared-tile-registers"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
