<!-- GENERATED FROM: asl/arch/data-types/packed.asl -->
# Packed

**Normative ASL source:** `asl/arch/data-types/packed.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-PACKED}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-packed-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit is the current architecture identity for packed data types and depends on the tile data-type namespace.

It exists as a named ownership point so packed behavior can be referenced without placing an alternate encoding or execution contract in prose.

<!-- PTO-READER-BLOCK: arch-packed-concepts-state role=concepts-state -->
## Concepts and visible state

- The unit contains no independent ASL type, state, or executable helper beyond its `PTO-UNIT` identity.
- Its dependency, `PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES`, owns the assigned packed tile members such as `S4X2`, `U4X2`, `E2M1X2`, `E1M2X2`, and `HiF4X2`.
- Packing layout, lane interpretation, memory movement, and arithmetic remain in the current owners that define those mechanisms.

<!-- PTO-READER-BLOCK: arch-packed-rules-interactions role=rules-interactions -->
## Rules and interactions

Do not infer a universal lane order or carrier width from the word `packed`; consult the selected `TileDataType` and its format or execution owner.

The named concept creates no architectural state and performs no transition.

A packed mnemonic remains governed by its own decode, legality, movement, and result contracts.

<!-- PTO-READER-BLOCK: arch-packed-boundaries role=boundaries -->
## Architectural boundaries

This page cannot supply missing packed semantics because the owner intentionally contains none; a new rule would require a change to an owning ASL/NDF unit.

Historical ADR material can explain why ownership exists, but current meaning must be read from the reachable ASL owners.

<!-- PTO-READER-BLOCK: arch-packed-example-usage role=example-usage -->
## Non-normative reading example

When encountering `TileDataType_U4X2`, use the tile-data-type owner for its assigned identity and then follow the consuming instruction for lane and memory behavior.

The absence of a helper here is therefore a navigation boundary, not permission to choose an implementation-defined packed representation.

<!-- PTO-READER-BLOCK: arch-packed-related-owners role=related-owners-navigation -->
## Related owners

- [Tile data types](tile-data-types.md)
- [Numeric format dispatch](numeric-formats.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/packed.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-PACKED","surface":"arch","classification":["data-types","packed"],"depends_on":["PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
