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

This unit is the named programming-model owner for Tile registers and provides a stable route from programming-model terminology into the executable architecture owners.

<!-- PTO-READER-BLOCK: arch-tile-registers-concepts-state role=concepts-state -->
## Concept ownership

The unit declares no standalone Tile-register storage or access procedure. Its source states that executable state is defined by dependencies.

<!-- PTO-READER-BLOCK: arch-tile-registers-rules-interactions role=rules-interactions -->
## Dependency relationship

`PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS` depends on `PTO-ARCH-FEATURES-PREDICATION`. The dependency graph, not supplementary prose, determines which reachable ASL owner supplies a concrete state rule.

<!-- PTO-READER-BLOCK: arch-tile-registers-boundaries role=boundaries -->
## Architectural boundaries

This concept page does not assign Tile shapes, data, validity, capacity, predication results, or instruction effects. A reader must use the relevant feature, state, and instruction owner for those contracts.

<!-- PTO-READER-BLOCK: arch-tile-registers-example-usage role=example-usage -->
## Non-normative reading example

For a Tile-register predication question, begin here for the programming-model term, follow the predication dependency, and then use the generated ASL and its AVS references to inspect the actual owner.

<!-- PTO-READER-BLOCK: arch-tile-registers-related-owners role=related-owners-navigation -->
## Related owners

- [Predication](../features/predication.md) is the direct dependency.
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
