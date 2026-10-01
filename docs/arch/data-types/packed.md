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

`asl/arch/data-types/packed.asl` contains no executable ASL. Line 1 is the `PTO-UNIT` record, and line 2 states that the unit owns the named architecture concept while executable state is defined by its dependencies. The one declared dependency is `PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES`.

This page therefore records the identity of the packed concept and the boundary of its ownership, not a packing rule. Any numeric or memory behavior a packed element shows belongs to the unit that assigns it.

Design point: the unit is kept as a named ownership point with no body instead of becoming a second definition of packing. Its observable consequence is that no packed rule can be created or changed here: a new lane order or carrier width would have to be made in the dependency, or in the instruction owner that consumes the type, and would then be visible on that page rather than this one.

<!-- PTO-READER-BLOCK: arch-packed-concepts-state role=concepts-state -->
## Concepts and visible state

- This unit declares no type, no state object, and no helper, so it has no state of its own to describe.
- The dependency assigns five members of `TileDataType` whose names end in `X2`: `TileDataType_E2M1X2` at code `11`, `TileDataType_E1M2X2` at code `12`, `TileDataType_HiF4X2` at code `14`, `TileDataType_S4X2` at code `20`, and `TileDataType_U4X2` at code `28`.
- Those codes live in the dependency's `TileDataTypeEncoding`, which is `bits(5)`. Codes `22`, `23`, `29`, `30`, and `31` are reserved there and reject before architectural effects.

Design point: `X2` is a name inside the data-type namespace, not a statement about storage. The dependency assigns the code and the name, while the number of lanes in a carrier, the order of those lanes, and the effect of a move on memory are stated by other owners. A reader who needs those facts cannot obtain them here, and that gap is the unit's actual content.

<!-- PTO-READER-BLOCK: arch-packed-rules-interactions role=rules-interactions -->
## Rules and interactions

The dependency assigns code `0` to `FP64` and declares that zero never means absent, inherited, `NONE`, or `NULL`, so no packed member has a zero-code spelling.

The sentinel that means "no data type" is a separate five-bit constant, code `31`, which `TileDataTypeEncodingValid` rejects and which is not a `TileDataType` member.

A packed mnemonic stays governed by its own decode, legality, and movement contract. This unit adds no case to any of them and defines no transition.

Design point: because a reserved code rejects instead of decoding to a default, the five codes above are the only encodings that can name a packed type. Adding a sixth packed type, or an "unspecified packed" encoding, therefore requires a change to the dependency and cannot be arranged by leaving a code unassigned.

<!-- PTO-READER-BLOCK: arch-packed-boundaries role=boundaries -->
## Architectural boundaries

No lane order, no carrier width, and no memory movement is stated here, because the owning unit contains no statement that could fix them.

The line-2 comment is the whole body of the unit, so the absence of a rule is a boundary of ownership rather than an unspecified rule that this page may fill in.

Design point: a reader who arrives at a packed page and finds no helper should read that as a navigation result and continue to the format or instruction owner. Reading the gap as freedom to choose an implementation-defined packed representation would create a rule with no ASL owner, which is exactly what the named-concept unit avoids.

<!-- PTO-READER-BLOCK: arch-packed-example-usage role=example-usage -->
## Non-normative reading example

To read `TileDataType_U4X2`, take its identity from the dependency first: it is one of the 27 `TileDataType` members, and it is assigned code `28`.

Then follow the consuming instruction for the movement and lane behavior of that type, and the format owners for any numeric interpretation of it. This page contributes only the fact that `U4X2` is a named member with an assigned code, and that the unit owning the name contains no executable ASL.

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
