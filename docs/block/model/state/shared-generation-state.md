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

This unit owns the state operations that clear, reset, query, and abort Shared-generation records, plus Core-and-invocation-scoped retirement of actual-PE request metadata. A Shared generation is an in-progress `B.ASSEMBLE` build of one Shared Tile that may receive contributions before publication.

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-concepts role=concepts-state -->
## Concepts and visible state

`_SharedGenerations` has one record per Shared Tile ID, `PTO_SHARED_TILE_COUNT` records in all. Each record tracks:

- lifecycle flags `open`, `closed`, and `published`;
- the Shared Tile ID, logical participant mask, parent size code and cell count, plus actual-PE ownership, Core/invocation identity, operation ordinal, and request provenance;
- `covered_cells` and `ready_cells` bitmaps, `arrived_participants`, per-PE request tokens and program orders, and `released_participants`;
- specialized producer inputs and metadata, with a valid flag;
- `last_seen`;
- a working copy of the Tile (`working_tile`), with `working_valid` and `working_initialized_mask`.

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-rules role=rules-interactions -->
## Rules and interactions

`ClearBundleSharedGenerationState(id)` clears the active record for one ID but preserves its `next_operation_ordinal`; it keeps the Shared Tile ID, resets the other active flags, masks, bitmaps, identities, and inputs, and reloads `working_tile` from the current published Shared Tile.

`ResetBundleSharedGenerationState` clears every record and initializes each `next_operation_ordinal` to zero. `BundleSharedGenerationOpen(id)` reports the `open` flag. `AbortBundleSharedGeneration(id)` clears one active generation record while preserving its next ordinal.

Design point: abort discards the active candidate, identity, coverage, and release bookkeeping for that record, but does not change the published Shared Tile or rewind its next ordinal. The working copy is reloaded from the published Tile, so a rejected or faulted incomplete assembly leaves the prior Shared object intact as required by `PTO-B-ASSEMBLE-SHARED-GENERATION-001`.

Design point: pending Shared generations stay outside the architectural `S` register file until complete collective publication. Other readers see either the old object or the complete new one, never a partly assembled Tile.

The request-squash owner matches Core, invocation, and an actual arrival token before aborting an incomplete actual-PE candidate. It marks the corresponding active and saved PE/trap bindings before clearing the candidate, so context recovery cannot revive that request. Squash preserves a published generation and its pending releases. Separately, `RetirePEOwnedSharedGenerationsForInvocation` clears actual-PE records for the retiring Core and invocation, including unconsumed release metadata, while preserving the published Shared Tile, next ordinal, and unrelated Core, invocation, and aggregate records; kernel End and Abort call this retirement owner.

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-boundaries role=boundaries -->
## Architectural boundaries

This unit does not perform range admission or candidate publication. The Shared-generation operand unit owns low-level range validation and aggregate helpers; the adjacent per-PE request unit owns encoded request identity, actual-PE contribution, and retained release. The related-owner links identify both paths.

Shared generation records are not cleared by `ClearBundleHeaderState`. Incomplete records close through their operation-specific abort or publication path; actual-PE request metadata is also retired on invocation End/Abort, while aggregate records and published Shared Tiles remain under their existing owners.

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A four-PE encoded assembly of Shared Tile 19 publishes only after the fourth actual request supplies its range. If an incomplete candidate is aborted, its active coverage and request/release metadata are cleared, the next operation ordinal is retained, and the previously published Shared Tile remains readable. At invocation End or Abort, actual-PE release bookkeeping for that Core and invocation is retired without clearing the published Tile or another invocation's record.

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-related role=related-owners-navigation -->
## Related owners

- [Shared generation](../operands/shared-generation.md) owns low-level ranges and aggregate operations; [per-PE Shared-generation requests](../operands/shared-generation-pe-requests.md) owns encoded capture, contribution, and release.
- [Shared registers](../../../tile/model/state/shared-registers.md) own the published Shared Tiles.
- [Tile execution](../dispatch/tile-execution.md) aborts destination generations after a failed operation; [kernel lifecycle](../../../arch/state/kernel-lifecycle.md) retires actual-PE request metadata at invocation End/Abort.
- [B.ASSEMBLE](../../operands/B.ASSEMBLE.md) is the command page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/shared-generation-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-SHARED-GENERATION","surface":"block","classification":["model","state","shared-generation-state"],"depends_on":["PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-STATE-SHARED-REGISTERS","PTO-TILE-MODEL-STATE-DESCRIPTORS","PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY"]}
readonly func BundleSharedGenerationStorageRow(
    tile: TileInfo, element: integer {0..524287})
    => integer {0..524287}
begin
    if tile.layout == TileLayout_RowMajor then
        let row_local_pairs = PackedTileDataTypeUsesRowLocalPairs(
            tile.data_type) && tile.columns MOD 2 == 1;
        let row_pitch = if row_local_pairs then
            ((PackedTileRowPairColumns(
                tile.columns as integer {1..65535}) * 2)
                as integer {1..65536})
            else tile.columns as integer {1..65535};
        return (element DIVRM row_pitch) as integer {0..524287};
    elsif tile.layout == TileLayout_ColumnMajor then
        return (element MOD tile.rows) as integer {0..524287};
    else
        let inner_elements = TileFractalInnerElements(tile.data_type)
            as integer {4..64};
        let block_rows = (tile.rows DIVRM 16) as integer {1..4096};
        let block_columns = (tile.columns DIVRM inner_elements)
            as integer {1..16384};
        let block_elements = (16 * inner_elements)
            as integer {64..1024};
        let block = (element DIVRM block_elements)
            as integer {0..8191};
        let within_block = (element MOD block_elements)
            as integer {0..1023};
        if tile.layout == TileLayout_ZN then
            let block_row = (block DIVRM block_columns)
                as integer {0..8191};
            let inner_row = (within_block MOD 16)
                as integer {0..15};
            return (block_row * 16 + inner_row)
                as integer {0..524287};
        end;
        assert tile.layout == TileLayout_NZ;
        let block_row = (block MOD block_rows) as integer {0..8191};
        let inner_row = (within_block DIVRM inner_elements)
            as integer {0..255};
        return (block_row * 16 + inner_row) as integer {0..524287};
    end;
end;

readonly func BundleSharedGenerationStorageColumn(
    tile: TileInfo, element: integer {0..524287})
    => integer {0..524287}
begin
    if tile.layout == TileLayout_RowMajor then
        let row_local_pairs = PackedTileDataTypeUsesRowLocalPairs(
            tile.data_type) && tile.columns MOD 2 == 1;
        let row_pitch = if row_local_pairs then
            ((PackedTileRowPairColumns(
                tile.columns as integer {1..65535}) * 2)
                as integer {1..65536})
            else tile.columns as integer {1..65535};
        return (element MOD row_pitch) as integer {0..524287};
    elsif tile.layout == TileLayout_ColumnMajor then
        return (element DIVRM tile.rows) as integer {0..524287};
    else
        let inner_elements = TileFractalInnerElements(tile.data_type)
            as integer {4..64};
        let block_rows = (tile.rows DIVRM 16) as integer {1..4096};
        let block_columns = (tile.columns DIVRM inner_elements)
            as integer {1..16384};
        let block_elements = (16 * inner_elements)
            as integer {64..1024};
        let block = (element DIVRM block_elements)
            as integer {0..8191};
        let within_block = (element MOD block_elements)
            as integer {0..1023};
        if tile.layout == TileLayout_ZN then
            let block_column = (block MOD block_columns)
                as integer {0..16383};
            let inner_column = (within_block DIVRM 16)
                as integer {0..63};
            return (block_column * inner_elements + inner_column)
                as integer {0..524287};
        end;
        assert tile.layout == TileLayout_NZ;
        let block_column = (block DIVRM block_rows)
            as integer {0..8191};
        let inner_column = (within_block MOD inner_elements)
            as integer {0..63};
        return (block_column * inner_elements + inner_column)
            as integer {0..524287};
    end;
end;

readonly func BundleSharedGenerationStorageCoordinateIsLogical(
    tile: TileInfo, element: integer {0..524287}) => boolean
begin
    return BundleSharedGenerationStorageRow(tile, element) < tile.rows &&
           BundleSharedGenerationStorageColumn(tile, element) < tile.columns;
end;

readonly func BundleSharedGenerationPlacedExtent(
    source: TileInfo, destination: TileInfo,
    copied_elements: integer {0..524288},
    destination_offset: integer {0..524287},
    previous_extent: integer {0..65535},
    by_column: boolean) => integer {0..65535}
begin
    var extent = previous_extent;
    for row = 0 to source.valid_rows - 1 looplimit 65536 do
        for column = 0 to source.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source,
                row as integer {0..65535},
                column as integer {0..65535})
                as integer {0..524287};
            if source_element < copied_elements then
                let destination_element = (destination_offset + source_element)
                    as integer {0..524287};
                if BundleSharedGenerationStorageCoordinateIsLogical(
                    destination, destination_element) then
                    let coordinate = if by_column then
                        BundleSharedGenerationStorageColumn(
                            destination, destination_element)
                        else BundleSharedGenerationStorageRow(
                            destination, destination_element);
                    if coordinate + 1 > extent then
                        extent = (coordinate + 1) as integer {0..65535};
                    end;
                end;
            end;
        end;
    end;
    return extent;
end;

readonly func SharedGenerationPEBit(pe: MemoryAgentId) => bits(4)
begin
    var participant = Zeros{4};
    participant[PTOPEMaskBitOfPEIdentity(
        pe as integer {0..PTO_MODEL_MEMORY_AGENTS-1})] = '1';
    return participant;
end;

readonly func BundleSharedGenerationReadyCellsWithRange(
    tile: TileInfo, prior_ready: bits(8192),
    offset_cells: integer {0..8192},
    coverage_cells: integer {0..8192}) => bits(8192)
begin
    let element_bits = TileElementBits(tile.data_type)
        as integer {1..64};
    let elements_per_cell = ((32 * 8) DIVRM element_bits)
        as integer {1..256};
    let capacity_elements = TileLogicalElementCapacity(
        tile.capacity_bytes, tile.data_type);
    var ready = prior_ready;
    for cell = 0 to 8191 do
        if cell < coverage_cells then
            let target_cell = (offset_cells + cell) as integer {0..8191};
            let first_element = (target_cell * elements_per_cell)
                as integer {0..524287};
            var cell_ready = TRUE;
            for lane = 0 to 255 do
                if lane < elements_per_cell then
                    let element = (first_element + lane)
                        as integer {0..524287};
                    if element < capacity_elements then
                        let row = BundleSharedGenerationStorageRow(
                            tile, element);
                        let column = BundleSharedGenerationStorageColumn(
                            tile, element);
                        if row < tile.valid_rows &&
                           column < tile.valid_columns &&
                           !TileLogicalElementDefined(tile,
                               element as PackedTileElementIndex) then
                            cell_ready = FALSE;
                        end;
                    end;
                end;
            end;
            ready[target_cell] = if cell_ready then '1' else '0';
        end;
    end;
    return ready;
end;

func ClearBundleSharedGenerationState(shared_tile_id: SharedTileID)
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    let next_operation_ordinal =
        _SharedGenerations[[index]].next_operation_ordinal;
    ReleaseSharedTileGenerationCapacity(shared_tile_id);
    _SharedGenerations[[index]].open = FALSE;
    _SharedGenerations[[index]].closed = FALSE;
    _SharedGenerations[[index]].published = FALSE;
    _SharedGenerations[[index]].shared_tile_id = shared_tile_id;
    _SharedGenerations[[index]].participant_mask = Zeros{4};
    _SharedGenerations[[index]].core_identity = 0 as PTOModelCoreIdentity;
    _SharedGenerations[[index]].invocation_identity = 0;
    _SharedGenerations[[index]].origin = MemoryEventOrigin_NonKernel;
    _SharedGenerations[[index]].source_acr = 0 as AccessControlRing;
    _SharedGenerations[[index]].producer_site = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].start_instruction = Zeros{64};
    _SharedGenerations[[index]].operation_form = Zeros{7};
    _SharedGenerations[[index]].operation_selector = Zeros{10};
    _SharedGenerations[[index]].operation_ordinal = 0;
    _SharedGenerations[[index]].next_operation_ordinal =
        next_operation_ordinal;
    _SharedGenerations[[index]].actual_pe_owned = FALSE;
    _SharedGenerations[[index]].parent_size_code = 0;
    _SharedGenerations[[index]].parent_cell_count = 0;
    _SharedGenerations[[index]].covered_cells = Zeros{8192};
    _SharedGenerations[[index]].ready_cells = Zeros{8192};
    _SharedGenerations[[index]].arrived_participants = Zeros{4};
    _SharedGenerations[[index]].released_participants = Zeros{4};
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        _SharedGenerations[[index]].arrival_request_tokens[[pe]] = 0;
        _SharedGenerations[[index]].arrival_program_orders[[pe]] = 0;
    end;
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
        let shared_tile_id = (Zeros{6} + raw_id) as SharedTileID;
        ClearBundleSharedGenerationState(shared_tile_id);
        _SharedGenerations[[SharedTileArrayIndex(shared_tile_id)]]
            .next_operation_ordinal = 0;
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

func PublishPEOwnedSharedGeneration(shared_tile_id: SharedTileID,
                                    participant_mask: bits(4))
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    _SharedTiles[[index]].descriptor_valid = TRUE;
    _SharedTiles[[index]].payload_live = TRUE;
    _SharedTiles[[index]].payload_generation =
        _SharedTiles[[index]].payload_generation + 1;
    _SharedTiles[[index]].allocation_mask = participant_mask;
    _SharedTiles[[index]].initialized_mask = participant_mask;
    _SharedTiles[[index]].whole_parent_ready = TRUE;
    _SharedTiles[[index]].published = TRUE;
    _SharedTiles[[index]].tile = _SharedGenerations[[index]].working_tile;
    ReleaseSharedTileGenerationCapacity(shared_tile_id);
end;

// Invocation lifecycle retirement discards only the active-PE Shared
// operation metadata owned by the retiring Core and invocation. Clearing the
// candidate leaves its published Shared parent and monotonically increasing
// operation ordinal intact. Legacy aggregate records have no invocation
// identity and remain under their existing operation-specific owner.
func RetirePEOwnedSharedGenerationsForInvocation(
    core: PTOModelCoreIdentity, invocation: integer)
begin
    if invocation == 0 then return; end;
    let original_core = _CurrentModelCore;
    let original_pe = _CurrentMemoryAgent;
    if core != original_core then
        // Shared-generation storage is in the Core context bank. Select the
        // target bank explicitly; selection saves the caller's live PE/Core
        // context and the restore below leaves it unchanged.
        SelectExecutionContext(core, original_pe);
    end;
    for raw_id = 0 to PTO_SHARED_TILE_COUNT - 1 do
        let shared_tile_id = (Zeros{6} + raw_id) as SharedTileID;
        let index = SharedTileArrayIndex(shared_tile_id);
        if _SharedGenerations[[index]].actual_pe_owned &&
           _SharedGenerations[[index]].core_identity == core &&
           _SharedGenerations[[index]].invocation_identity == invocation then
            ClearBundleSharedGenerationState(shared_tile_id);
        end;
    end;
    SaveSelectedCoreExecutionContext();
    if core != original_core then
        SelectExecutionContext(original_core, original_pe);
    end;
end;

// A squashed Shared request may also be present in a saved PE image or in a
// nested ACR trap image. Mark every retained copy by its globally unique
// execution-domain token so recovery cannot resurrect the canceled request.
func MarkBundleSharedRequestDomainSquashed(domain: integer)
begin
    if domain == 0 then return; end;
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid &&
           _BundleSharedBindings[[binding]].destination_assemble
               .shared_request_identity_valid &&
           _BundleSharedBindings[[binding]].destination_assemble
               .shared_request_execution_domain == domain then
            _BundleSharedBindings[[binding]].destination_assemble
                .shared_request_squashed = TRUE;
            _BundleSharedBindings[[binding]].destination_assemble
                .shared_request_waiting = TRUE;
        end;
    end;
    for acr = 0 to PTO_ACR_COUNT - 1 do
        for binding = 0 to 3 do
            if _TrapContexts[[acr]].bundle_shared_bindings[[binding]].valid &&
               _TrapContexts[[acr]].bundle_shared_bindings[[binding]]
                   .destination_assemble.valid &&
               _TrapContexts[[acr]].bundle_shared_bindings[[binding]]
                   .destination_assemble.shared_request_identity_valid &&
               _TrapContexts[[acr]].bundle_shared_bindings[[binding]]
                   .destination_assemble.shared_request_execution_domain ==
                       domain then
                _TrapContexts[[acr]].bundle_shared_bindings[[binding]]
                    .destination_assemble.shared_request_squashed = TRUE;
                _TrapContexts[[acr]].bundle_shared_bindings[[binding]]
                    .destination_assemble.shared_request_waiting = TRUE;
            end;
        end;
    end;
    for core = 0 to PTO_MODEL_CORE_INSTANCES - 1 do
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            if _PEContextBankValid[[core]][pe] == '1' then
                for binding = 0 to 3 do
                    if _PEExecutionContexts[[core]][[pe]]
                           .bundle_shared_bindings[[binding]].valid &&
                       _PEExecutionContexts[[core]][[pe]]
                           .bundle_shared_bindings[[binding]]
                           .destination_assemble.valid &&
                       _PEExecutionContexts[[core]][[pe]]
                           .bundle_shared_bindings[[binding]]
                           .destination_assemble.shared_request_identity_valid &&
                       _PEExecutionContexts[[core]][[pe]]
                           .bundle_shared_bindings[[binding]]
                           .destination_assemble.shared_request_execution_domain ==
                               domain then
                        _PEExecutionContexts[[core]][[pe]]
                            .bundle_shared_bindings[[binding]]
                            .destination_assemble.shared_request_squashed = TRUE;
                        _PEExecutionContexts[[core]][[pe]]
                            .bundle_shared_bindings[[binding]]
                            .destination_assemble.shared_request_waiting = TRUE;
                    end;
                end;
                for acr = 0 to PTO_ACR_COUNT - 1 do
                    for binding = 0 to 3 do
                        if _PEExecutionContexts[[core]][[pe]].trap_contexts[[acr]]
                               .bundle_shared_bindings[[binding]].valid &&
                           _PEExecutionContexts[[core]][[pe]]
                               .trap_contexts[[acr]]
                               .bundle_shared_bindings[[binding]]
                               .destination_assemble.valid &&
                           _PEExecutionContexts[[core]][[pe]]
                               .trap_contexts[[acr]]
                               .bundle_shared_bindings[[binding]]
                               .destination_assemble.shared_request_identity_valid &&
                           _PEExecutionContexts[[core]][[pe]]
                               .trap_contexts[[acr]]
                               .bundle_shared_bindings[[binding]]
                               .destination_assemble.shared_request_execution_domain ==
                                   domain then
                            _PEExecutionContexts[[core]][[pe]]
                                .trap_contexts[[acr]]
                                .bundle_shared_bindings[[binding]]
                                .destination_assemble.shared_request_squashed = TRUE;
                            _PEExecutionContexts[[core]][[pe]]
                                .trap_contexts[[acr]]
                                .bundle_shared_bindings[[binding]]
                                .destination_assemble.shared_request_waiting = TRUE;
                        end;
                    end;
                end;
            end;
        end;
    end;
    for binding = 0 to 3 do
        if _DefaultPEExecutionContext.bundle_shared_bindings[[binding]].valid &&
           _DefaultPEExecutionContext.bundle_shared_bindings[[binding]]
               .destination_assemble.valid &&
           _DefaultPEExecutionContext.bundle_shared_bindings[[binding]]
               .destination_assemble.shared_request_identity_valid &&
           _DefaultPEExecutionContext.bundle_shared_bindings[[binding]]
               .destination_assemble.shared_request_execution_domain == domain then
            _DefaultPEExecutionContext.bundle_shared_bindings[[binding]]
                .destination_assemble.shared_request_squashed = TRUE;
            _DefaultPEExecutionContext.bundle_shared_bindings[[binding]]
                .destination_assemble.shared_request_waiting = TRUE;
        end;
    end;
    for acr = 0 to PTO_ACR_COUNT - 1 do
        for binding = 0 to 3 do
            if _DefaultPEExecutionContext.trap_contexts[[acr]]
                   .bundle_shared_bindings[[binding]].valid &&
               _DefaultPEExecutionContext.trap_contexts[[acr]]
                   .bundle_shared_bindings[[binding]].destination_assemble.valid &&
               _DefaultPEExecutionContext.trap_contexts[[acr]]
                   .bundle_shared_bindings[[binding]]
                   .destination_assemble.shared_request_identity_valid &&
               _DefaultPEExecutionContext.trap_contexts[[acr]]
                   .bundle_shared_bindings[[binding]]
                   .destination_assemble.shared_request_execution_domain == domain then
                _DefaultPEExecutionContext.trap_contexts[[acr]]
                    .bundle_shared_bindings[[binding]]
                    .destination_assemble.shared_request_squashed = TRUE;
                _DefaultPEExecutionContext.trap_contexts[[acr]]
                    .bundle_shared_bindings[[binding]]
                    .destination_assemble.shared_request_waiting = TRUE;
            end;
        end;
    end;
end;

// Squash invalidates a request identity everywhere it is retained before it
// aborts the matching incomplete candidate. Published generations remain
// irrevocable, including their outstanding per-PE completion tokens.
func SquashPEOwnedSharedGenerationRequest(
    core: PTOModelCoreIdentity, invocation: integer, domain: integer)
begin
    if domain == 0 || invocation == 0 then return; end;
    for raw_id = 0 to PTO_SHARED_TILE_COUNT - 1 do
        let shared_tile_id = (Zeros{6} + raw_id) as SharedTileID;
        let index = SharedTileArrayIndex(shared_tile_id);
        if _SharedGenerations[[index]].actual_pe_owned &&
           !_SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].core_identity == core &&
           _SharedGenerations[[index]].invocation_identity == invocation then
            var matching_arrival = FALSE;
            for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                if _SharedGenerations[[index]].arrived_participants[
                       PTOPEMaskBitOfPEIdentity(pe)] == '1' &&
                   _SharedGenerations[[index]].arrival_request_tokens[[pe]] ==
                       domain then
                    matching_arrival = TRUE;
                end;
            end;
            if matching_arrival then
                MarkBundleSharedRequestDomainSquashed(domain);
                AbortBundleSharedGeneration(shared_tile_id);
            end;
        end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
