<!-- GENERATED FROM: asl/tile/model/memory/shared-movement-types.asl -->
# Shared Movement Types

**Normative ASL source:** `asl/tile/model/memory/shared-movement-types.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-TYPES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-types-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the bounded container types shared by movement operations.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-types-concepts role=concepts-state -->
## Concepts and state

`ScatterLaneOrder` stores one word per modeled Tile element. `CorePETileInfos` stores one `TileInfo` value per modeled PE.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-types-rules role=rules-interactions -->
## Rules and interactions

Movement owners use these types to pass a complete lane order or a per-PE set of Tile snapshots without creating hidden architectural queues.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-types-boundaries role=boundaries -->
## Architectural boundaries

The array bounds are reference-model bounds. This unit defines no operation, ordering rule, allocation, or hardware capacity requirement.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-types-example role=example-usage -->
## Non-normative reading example

A per-PE Shared movement can receive one `CorePETileInfos` value and select entries according to its four-bit PE mask.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-types-related role=related-owners-navigation -->
## Related owners

- [Related owner](../state/types.md) defines `TileInfo` and the model identities used by both arrays.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/shared-movement-types.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-TYPES","surface":"tile","classification":["model","memory","shared-movement-types"],"depends_on":["PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","PTO-TILE-MODEL-STATE-TYPES"]}
type ScatterLaneOrder of array [[PTO_MODEL_TILE_ELEMENTS]] of Word;
type CorePETileInfos of array [[PTO_MODEL_MEMORY_AGENTS]] of TileInfo;
```
<!-- GENERATED-ASL-END: unit -->
