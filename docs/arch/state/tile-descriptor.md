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

This unit is the stable architecture owner for the Tile-descriptor state concept and routes readers to the Shared Tile state dependency that defines executable state.

<!-- PTO-READER-BLOCK: arch-tile-descriptor-concepts-state role=concepts-state -->
## Concept ownership

The source declares no descriptor record, field, or transition locally. It explicitly assigns executable state to its dependencies.

<!-- PTO-READER-BLOCK: arch-tile-descriptor-rules-interactions role=rules-interactions -->
## Dependency relationship

`PTO-ARCH-STATE-TILE-DESCRIPTOR` depends on `PTO-ARCH-FEATURES-SHARED-TILE-STATE`. Descriptor behavior must be obtained from that reachable ASL graph and the instruction owner that performs a state transition.

<!-- PTO-READER-BLOCK: arch-tile-descriptor-boundaries role=boundaries -->
## Architectural boundaries

This page does not invent descriptor layout, validity, capacity, ownership, lifetime, or fault rules. A name-only owner cannot serve as a second semantic definition for those properties.

<!-- PTO-READER-BLOCK: arch-tile-descriptor-example-usage role=example-usage -->
## Non-normative reading example

For a descriptor-field question, use this page to identify the architecture concept, then inspect the Shared Tile state owner and the exact operation that reads or writes the field.

<!-- PTO-READER-BLOCK: arch-tile-descriptor-related-owners role=related-owners-navigation -->
## Related owners

- [Shared Tile state](../features/shared-tile-state.md) is the direct dependency.
- [Definedness](definedness.md) depends on this concept owner.
- [Tile registers](../programming-model/tile-registers.md) provides the programming-model entry point for Tile registers.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/tile-descriptor.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-TILE-DESCRIPTOR","surface":"arch","classification":["state","tile-descriptor"],"depends_on":["PTO-ARCH-FEATURES-SHARED-TILE-STATE"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
