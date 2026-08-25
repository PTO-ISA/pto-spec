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

This unit is the named programming-model owner for Shared Tile registers. It exists so the Shared Tile concept has a stable architecture identity and navigation target.

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-concepts-state role=concepts-state -->
## Concept ownership

The owner contains no executable state declaration or access helper of its own. Its source explicitly delegates executable state to its dependencies.

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-rules-interactions role=rules-interactions -->
## Dependency relationship

`PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS` depends on `PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS`. Read the dependency and its reachable state owners for executable behavior.

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-boundaries role=boundaries -->
## Architectural boundaries

This page does not define allocation, lifetime, capacity, aliasing, or instruction effects for Shared Tile state. Those rules must come from the owning reachable ASL rather than from this explanatory page.

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-example-usage role=example-usage -->
## Non-normative reading example

When a question asks how a Shared Tile register changes, use this page to identify the named concept, then continue through the dependency link until reaching the ASL unit that owns the relevant state transition.

<!-- PTO-READER-BLOCK: arch-shared-tile-registers-related-owners role=related-owners-navigation -->
## Related owners

- [Tile registers](tile-registers.md) is the direct dependency.
- [Shared Tile state](../features/shared-tile-state.md) is a related downstream state owner; it is not a declared dependency of this unit.
- [Architecture overview](../overview/architecture.md) lists Shared Tile state in the architecture state closure.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/shared-tile-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS","surface":"arch","classification":["programming-model","shared-tile-registers"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
