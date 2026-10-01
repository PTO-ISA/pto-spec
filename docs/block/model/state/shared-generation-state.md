<!-- GENERATED FROM: asl/block/model/state/shared-generation-state.asl -->
# Shared Generation State

**Normative ASL source:** `asl/block/model/state/shared-generation-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-SHARED-GENERATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-purpose role=purpose-scope -->
## Purpose and scope

This unit defines how the pending Shared generation records are cleared, reset, queried, and aborted. A Shared generation is an in-progress `B.ASSEMBLE` build of one Shared Tile, which several bundles or participating PEs may fill before it is published.

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-concepts role=concepts-state -->
## Concepts and visible state

`_SharedGenerations` has one record per Shared Tile ID, `PTO_SHARED_TILE_COUNT` records in all. Each record tracks:

- lifecycle flags `open`, `closed`, and `published`;
- the Shared Tile ID, participant mask, parent size code, and parent cell count;
- `covered_cells` and `ready_cells` bitmaps and the `arrived_participants` mask;
- specialized producer inputs and metadata, with a valid flag;
- `last_seen`;
- a working copy of the Tile (`working_tile`), with `working_valid` and `working_initialized_mask`.

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-rules role=rules-interactions -->
## Rules and interactions

`ClearBundleSharedGenerationState(id)` resets the record for one ID: it keeps the Shared Tile ID, and all other flags, masks, bitmaps, and inputs become zero or false. `working_tile` is reloaded from the current published Shared Tile.

`ResetBundleSharedGenerationState` clears every record. `BundleSharedGenerationOpen(id)` reports the `open` flag. `AbortBundleSharedGeneration(id)` is the same as clearing that record.

Design point: abort discards only the working copy. The published Shared Tile is not touched, and the working copy is reloaded from it. A rejected or faulted assembly therefore leaves the previously published Shared object exactly as it was, which is what the Shared-generation contract `PTO-B-ASSEMBLE-SHARED-GENERATION-001` requires.

Design point: pending Shared generations stay outside the architectural `S` register file until complete collective publication. Other readers see either the old object or the complete new one, never a partly assembled Tile.

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-boundaries role=boundaries -->
## Architectural boundaries

This unit does not open, extend, or publish a generation. Those steps, and the coverage and participant checks, are owned by the Shared-generation operand unit.

Shared generation records are not cleared by `ClearBundleHeaderState`. They survive commit and are closed by abort, publication, or reset.

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A two-bundle assembly of Shared Tile 3 has half its cells covered when the second bundle faults. Tile execution aborts the generation for ID 3. All flags of the record return to false, its coverage is empty, its working copy equals the published Shared Tile 3, and readers of Shared Tile 3 still see the old object.

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-related role=related-owners-navigation -->
## Related owners

- [Shared generation](../operands/shared-generation.md) opens, extends, and publishes generations.
- [Shared registers](../../../tile/model/state/shared-registers.md) own the published Shared Tiles.
- [Tile execution](../dispatch/tile-execution.md) aborts generations after a failed operation.
- [B.ASSEMBLE](../../operands/B.ASSEMBLE.md) is the command page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/shared-generation-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-SHARED-GENERATION","surface":"block","classification":["model","state","shared-generation-state"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}
func ClearBundleSharedGenerationState(shared_tile_id: SharedTileID)
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    _SharedGenerations[[index]].open = FALSE;
    _SharedGenerations[[index]].closed = FALSE;
    _SharedGenerations[[index]].published = FALSE;
    _SharedGenerations[[index]].shared_tile_id = shared_tile_id;
    _SharedGenerations[[index]].participant_mask = Zeros{4};
    _SharedGenerations[[index]].parent_size_code = 0;
    _SharedGenerations[[index]].parent_cell_count = 0;
    _SharedGenerations[[index]].covered_cells = Zeros{8192};
    _SharedGenerations[[index]].ready_cells = Zeros{8192};
    _SharedGenerations[[index]].arrived_participants = Zeros{4};
    _SharedGenerations[[index]].specialized_inputs_valid = FALSE;
    _SharedGenerations[[index]].specialized_input0 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_input1 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_input2 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_input3 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_metadata = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].last_seen = FALSE;
    _SharedGenerations[[index]].working_valid = FALSE;
    _SharedGenerations[[index]].working_tile =
        _SharedTiles[[index]].tile;
    _SharedGenerations[[index]].working_initialized_mask = Zeros{4};
end;

func ResetBundleSharedGenerationState()
begin
    for raw_id = 0 to PTO_SHARED_TILE_COUNT - 1 do
        ClearBundleSharedGenerationState(
            (Zeros{6} + raw_id) as SharedTileID);
    end;
end;

readonly func BundleSharedGenerationOpen(shared_tile_id: SharedTileID)
    => boolean
begin
    return _SharedGenerations[[SharedTileArrayIndex(shared_tile_id)]].open;
end;

func AbortBundleSharedGeneration(shared_tile_id: SharedTileID)
begin
    ClearBundleSharedGenerationState(shared_tile_id);
end;
```
<!-- GENERATED-ASL-END: unit -->
