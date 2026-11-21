<!-- GENERATED FROM: asl/tile/model/memory/gm-atom-red-values.asl -->
# Gm Atom Red Values

**Normative ASL source:** `asl/tile/model/memory/gm-atom-red-values.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-VALUES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-values-purpose role=purpose-scope -->
## Purpose and scope

This unit validates detached output values for global-memory atomic compare-and-swap and reduction operations.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-values-concepts role=concepts-state -->
## Concepts and state

The value Tile is the operand returned to the caller-facing output path. Its descriptor must match the index Tile and operation data type, and its required elements must be defined.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-values-rules role=rules-interactions -->
## Rules and interactions

`TileOperandsLegal_GM_ATOM_CASToValue` checks compare, replacement, index, and value shapes. `TileOperandsLegal_GM_ATOM_VALUEToValue` checks the single-value reduction family.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-values-boundaries role=boundaries -->
## Architectural boundaries

These predicates do not perform memory access or atomic updates. The global-memory atomic owner defines address translation, ordering, returned old values, and event recording.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-values-example role=example-usage -->
## Non-normative reading example

A compare-and-swap output is rejected when its detached value descriptor uses a different layout from the index Tile, even if both Tiles are individually allocated.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-values-related role=related-owners-navigation -->
## Related owners

- [Related owner](gm-atom-red.md) defines the atomic operation families and memory effects guarded by these detached-value checks.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/gm-atom-red-values.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-VALUES","surface":"tile","classification":["model","memory","gm-atom-red-values"],"depends_on":["PTO-TILE-MODEL-MEMORY-GM-ATOM-RED","PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA","PTO-TILE-MODEL-STATE-TYPES"]}
readonly func TileOperandsLegal_GM_ATOM_CASToValue(
    operation: GMAtomicOperation, destination: TileOutputValueTarget,
    base_address: Word, indices: TileIndex, expected: TileIndex,
    replacement: TileIndex, pad_value: TilePadValue) => boolean
begin
    let tile = destination.value;
    let index = _Tiles[[indices]];
    let expected_tile = _Tiles[[expected]];
    let replacement_tile = _Tiles[[replacement]];
    let data_type = tile.data_type;
    return IndexedTLSUNumericValueDescriptorLegal(tile) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(expected) &&
           IndexedTLSUExecutionMaskContentsDefined(replacement) &&
           GMAtomicOperationDataTypeLegal(operation, data_type) &&
           expected_tile.data_type == data_type &&
           replacement_tile.data_type == data_type &&
           tile.valid_rows == index.valid_rows &&
           tile.valid_columns == index.valid_columns &&
           tile.valid_rows == expected_tile.valid_rows &&
           tile.valid_columns == expected_tile.valid_columns &&
           tile.valid_rows == replacement_tile.valid_rows &&
           tile.valid_columns == replacement_tile.valid_columns &&
           IndexedTLSUMemoryIndexDataTypeLegal(index.data_type) &&
           tile.layout == index.layout && tile.layout == expected_tile.layout &&
           tile.layout == replacement_tile.layout;
end;

readonly func TileOperandsLegal_GM_ATOM_VALUEToValue(
    operation: GMAtomicOperation, destination: TileOutputValueTarget,
    base_address: Word, indices: TileIndex, value: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    let tile = destination.value;
    let index = _Tiles[[indices]];
    let value_tile = _Tiles[[value]];
    let data_type = tile.data_type;
    return IndexedTLSUNumericValueDescriptorLegal(tile) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(value) &&
           GMAtomicOperationDataTypeLegal(operation, data_type) &&
           value_tile.data_type == data_type &&
           tile.valid_rows == index.valid_rows &&
           tile.valid_columns == index.valid_columns &&
           tile.valid_rows == value_tile.valid_rows &&
           tile.valid_columns == value_tile.valid_columns &&
           IndexedTLSUMemoryIndexDataTypeLegal(index.data_type) &&
           tile.layout == index.layout && tile.layout == value_tile.layout;
end;
```
<!-- GENERATED-ASL-END: unit -->
