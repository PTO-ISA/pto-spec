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

`asl/arch/state/definedness.asl` is a two-line unit. Line 1 is the `PTO-UNIT` JSON that names `PTO-ARCH-STATE-DEFINEDNESS` and the single dependency `PTO-ARCH-STATE-TILE-DESCRIPTOR`; line 2 is the comment `// This unit owns the named architecture concept; executable state is defined by its dependencies.`

The file declares no function, type, constant, state variable, `DOC-BEGIN` region or `NDF-BEGIN` clause. This page owns one architecture name and the routing to the owners that do contain definedness state; it is not a second definition of that state.

<!-- PTO-READER-BLOCK: arch-definedness-concepts-state role=concepts-state -->
## What the declared dependency contains

The dependency named on line 1 is itself name-only. `asl/arch/state/tile-descriptor.asl` is two lines and its own `PTO-UNIT` JSON names `PTO-ARCH-FEATURES-SHARED-TILE-STATE`, which is two lines and names `PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS`, which is two lines and names `PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS`, which is two lines and names `PTO-ARCH-FEATURES-PREDICATION`.

The first unit on that chain whose file contains executable ASL is `PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS` in `asl/arch/programming-model/predicate-registers.asl`: it declares `_PredicateRegisters`, `ReadPredicateRegister` returns `Ones{PTO_PREDICATE_WIDTH}` for index `0` and the stored word otherwise, and `WritePredicateRegister` ignores index `0`.

Design point: the line-1 links from this unit reach a predicate-register owner before they reach any definedness owner. The executable definedness state is owned elsewhere, by `PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS` in `asl/tile/model/definedness/elements.asl`, which is not named anywhere on this page's chain. A reader who resolves definedness by unit identity alone arrives at predicate registers, and predicates are not Tile definedness.

<!-- PTO-READER-BLOCK: arch-definedness-rules-interactions role=rules-interactions -->
## Where definedness is executable

Definedness is a set of fields of the `TileInfo` record declared in `asl/tile/model/state/types.asl`: `contents_defined` is a `boolean`, `defined_elements` is `bits(PTO_MODEL_TILE_ELEMENTS)`, `defined_valid_elements` is `integer {0..524288}` and `packed_defined_elements` is `bits(524288)`. The records live in `_Tiles`, declared in `asl/tile/model/state/local-registers.asl`.

`TileElementDefined(index, row, column)` answers per coordinate: it returns `FALSE` for a packed row padding column, otherwise it maps the coordinate with `TileLogicalLinearIndex` and returns `TileLogicalElementDefined(tile, element)`. Two whole-Tile helpers exist as well: `MarkTileValidRegionDefined(index)` defines each coordinate of the `valid_rows` by `valid_columns` region, and `MarkTilePhysicalRegionDefined(index)` extends the operation to the full `rows` by `columns` region and to packed row slack.

Design point: `WriteTileElement` keeps the summary field derived from the per-element record instead of trusting a caller. It reads `was_defined` before the write, increments `defined_valid_elements` only for a previously undefined coordinate inside the valid region, and then recomputes `contents_defined` as `defined_valid_elements == valid_rows * valid_columns`. The observable effect is that a partially written local Tile reports `contents_defined` `FALSE`, and `TileSourceContentsDefined` in `asl/tile/model/legality/descriptor-shape.asl`, which is `TileDescriptorLegal(index) && _Tiles[[index]].contents_defined`, then refuses that Tile as a source.

<!-- PTO-READER-BLOCK: arch-definedness-boundaries role=boundaries -->
## Architectural boundaries

This page does not define when a value becomes defined, and it introduces no separate validity bit. Definedness is exactly the four `TileInfo` fields above and the helpers that maintain them.

Padding is not automatically defined. `TileWithPadding` computes `padding_defined` as `pad_value != TilePad_Null` and passes that flag to `TileInfoWithLogicalElementAndDefined`, which stores `'1'` or `'0'` in the element's definedness bit. A `PadValue=Null` padding pass therefore leaves padding coordinates undefined, and `TileElementDefined` keeps returning `FALSE` for them.

<!-- PTO-READER-BLOCK: arch-definedness-example-usage role=example-usage -->
## Reading example

Take an allocated Tile with `valid_rows` `4` and `valid_columns` `8`. After `MarkTileValidRegionDefined(index)`, `defined_valid_elements` is `32` and `contents_defined` is `TRUE`. A later `WriteTileElement` in that region reads `was_defined` as true, leaves the count at `32`, and the summary stays `TRUE`. A `PadValue=Null` pass over the physical region changes no definedness bit, so `TileElementDefined` still answers `FALSE` outside the valid region.

<!-- PTO-READER-BLOCK: arch-definedness-related-owners role=related-owners-navigation -->
## Related owners

- [Tile descriptor](tile-descriptor.md) is the dependency named on line 1.
- [Shared Tile state](../features/shared-tile-state.md) is the next link of that chain.
- [Tile local registers](../../tile/model/state/local-registers.md) declares `_Tiles` and the state objects `PTO-STATE-TILE-LOCAL` and `PTO-STATE-TILE-SHARED`.
- [Tile definedness elements](../../tile/model/definedness/elements.md) owns the per-element and whole-Tile definedness helpers.
- [Tile descriptor shape legality](../../tile/model/legality/descriptor-shape.md) owns `TileSourceContentsDefined`.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/definedness.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-DEFINEDNESS","surface":"arch","classification":["state","definedness"],"depends_on":["PTO-ARCH-STATE-TILE-DESCRIPTOR"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
