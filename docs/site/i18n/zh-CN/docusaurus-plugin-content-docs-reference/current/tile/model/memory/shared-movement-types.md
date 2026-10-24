<!-- GENERATED FROM: asl/tile/model/memory/shared-movement-types.asl -->
# Shared Movement Types

**Normative ASL source:** `asl/tile/model/memory/shared-movement-types.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-TYPES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/shared-movement-types.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-TYPES","surface":"tile","classification":["model","memory","shared-movement-types"],"depends_on":["PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","PTO-TILE-MODEL-STATE-TYPES"]}
type ScatterLaneOrder of array [[PTO_MODEL_TILE_ELEMENTS]] of Word;
type CorePETileInfos of array [[PTO_MODEL_MEMORY_AGENTS]] of TileInfo;
```
<!-- GENERATED-ASL-END: unit -->
