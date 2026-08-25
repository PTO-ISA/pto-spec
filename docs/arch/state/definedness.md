<!-- GENERATED FROM: asl/arch/state/definedness.asl -->
# Definedness

**Normative ASL source:** `asl/arch/state/definedness.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-DEFINEDNESS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-definedness-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit gives architectural definedness a stable state-owner identity and a route into the Tile-descriptor dependency that supplies executable state.

<!-- PTO-READER-BLOCK: arch-definedness-concepts-state role=concepts-state -->
## Concept ownership

The owner declares no definedness field, enumeration, or transition locally. Its source explicitly says that executable state is defined by dependencies.

<!-- PTO-READER-BLOCK: arch-definedness-rules-interactions role=rules-interactions -->
## Dependency relationship

`PTO-ARCH-STATE-DEFINEDNESS` depends on `PTO-ARCH-STATE-TILE-DESCRIPTOR`. Any concrete definedness rule must therefore be read from the reachable current ASL owners rather than inferred from this page title.

<!-- PTO-READER-BLOCK: arch-definedness-boundaries role=boundaries -->
## Architectural boundaries

This page does not define when a value becomes defined, undefined, initialized, invalid, or faulting. It also does not introduce an implicit validity bit.

<!-- PTO-READER-BLOCK: arch-definedness-example-usage role=example-usage -->
## Non-normative reading example

If a review asks whether a Tile field is readable before some transition, use this page only as a concept index. Resolve the question at the Tile-descriptor or state-transition owner that contains the actual rule.

<!-- PTO-READER-BLOCK: arch-definedness-related-owners role=related-owners-navigation -->
## Related owners

- [Tile descriptor](tile-descriptor.md) is the direct dependency.
- [Shared Tile state](../features/shared-tile-state.md) is reachable through the Tile-descriptor dependency.
- [Architecture overview](../overview/architecture.md) explains the single-owner rule for architecture state.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/definedness.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-DEFINEDNESS","surface":"arch","classification":["state","definedness"],"depends_on":["PTO-ARCH-STATE-TILE-DESCRIPTOR"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
