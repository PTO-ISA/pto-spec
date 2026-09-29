<!-- GENERATED FROM: asl/tile/model/state/shared-registers.asl -->
# Shared Registers

**Normative ASL source:** `asl/tile/model/state/shared-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-SHARED-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-state-shared-registers-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the behavior of the Core-private Shared Tile registers S0 to S63. A Shared register holds one Tile record that all four PEs of a Core address.

It defines readiness and legality predicates, the read path for consumers, and the single commit transition `AtomicUpdateSharedTileWithPublication`. It carries the accepted requirement `PTO-B-SHARED-WHOLE-PARENT-READY-001`.

<!-- PTO-READER-BLOCK: tile-model-state-shared-registers-concepts role=concepts-state -->
## Concepts and visible state

Each `SharedTileInfo` record wraps a `TileInfo` with five fields:

- `descriptor_valid`: the register holds a descriptor.
- `allocation_mask`: the PEs that participate in the parent, fixed by the first update.
- `initialized_mask`: the producer PEs that have written their part.
- `whole_parent_ready`: the complete parent is ready.
- `published`: the parent is visible to consumers.

A "parent" is the whole Shared Tile, as opposed to the part one PE writes.

`SharedTileFullyInitialized` requires a descriptor, `initialized_mask` equal to `allocation_mask`, and defined contents. `SharedTilePublished` additionally requires `whole_parent_ready` and `published`.

<!-- PTO-READER-BLOCK: tile-model-state-shared-registers-rules role=rules-interactions -->
## Rules and interactions

`AtomicUpdateSharedTileWithPublication` has three paths:

1. Empty register: the whole record is installed, with `allocation_mask` and `initialized_mask` set to the PE mask. It becomes ready and published only when publishing, the mask names one PE or all four, and the Tile contents are defined.
2. Existing register, one publishing PE: the Tile is replaced, marked fully defined, ready, and published.
3. Otherwise: each producer copies only the defined elements that fall in its own quarter of the capacity, `initialized_mask` gains the new bits, and contents become defined when every allocated PE has contributed.

Before any of these, `SharedTileUpdateCompatible` rejects CUBE layouts, illegal Shared capacities, and shapes that do not match capacity. For an existing descriptor, it requires the mask to stay inside `allocation_mask` and the descriptor to match in capacity, physical shape, valid region, data type, layout, and CUBE geometry fields. For a new descriptor, it requires room in the Shared pool.

Design point: one complete record assignment is the commit point. The source comment states this, and the transition builds the new record in a local copy before a single write to `_SharedTiles`. A consumer can never see a half-updated descriptor.

Design point: a zero PE mask is a true no-op. The update returns TRUE without reading or writing state.

Design point: producer coverage, readiness, and visibility stay distinct. `PTO-B-SHARED-WHOLE-PARENT-READY-001` requires every Shared consumer to wait or no-op before payload access until both `whole_parent_ready` and `published` are true, and states that producer and consumer masks are independent.

<!-- PTO-READER-BLOCK: tile-model-state-shared-registers-boundaries role=boundaries -->
## Architectural boundaries

`MaterializeSharedTile` gives every consumer the same complete parent snapshot. The PE mask selects consumers, not payload quarters, and materialization never changes Shared state.

Reading a Shared register that has no descriptor is allowed through `MaterializeSharedTileForReadSchema`. It builds a temporary read-only descriptor, using `MinimumTileCapacityBytesForShape` when no capacity is known. Elements come from `ReadSharedTileWord`, which returns a deterministic model word when the descriptor is missing, the parent is not ready, or the element is undefined. That word is not a portable value, and the read never allocates the register or raises a fault.

<!-- PTO-READER-BLOCK: tile-model-state-shared-registers-example role=example-usage -->
## Non-normative reading example

S5 is empty. PE0 writes a defined 64 KiB RowMajor Tile to it with mask `1000` and publication requested.

- The first path installs the record with `allocation_mask` and `initialized_mask` both `1000`.
- The mask names one PE and the contents are defined, so `whole_parent_ready` and `published` become TRUE.

A later write from PE1 with mask `0100` is rejected: `0100` is not inside the fixed `allocation_mask` of `1000`.

If instead the first write had used mask `1100`, the record would be installed with both masks `1100`, but it would not become ready. Direct readiness on the first path requires a mask naming exactly one PE or all four.

<!-- PTO-READER-BLOCK: tile-model-state-shared-registers-related role=related-owners-navigation -->
## Related owners

- [Types](types.md) defines `SharedTileInfo`.
- [Shared capacity](../capacity/shared.md) supplies the pool limit.
- [Shared movement](../memory/shared-movement.md) calls the update transition for Local-to-Shared moves.
- [Shared TLSU](../../../block/model/dispatch/shared-tlsu.md) and [Shared CUBE matrix](../../../block/model/dispatch/shared-cube-matrix.md) consume Shared registers.
- [Shared tile state](../../../arch/features/shared-tile-state.md) gives the architectural model.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/state/shared-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-SHARED-REGISTERS","surface":"tile","classification":["model","state","shared-registers"],"depends_on":["PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","PTO-TILE-MODEL-LEGALITY-PE-MASK","PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY"]}

// NDF-BEGIN: PTO-B-SHARED-WHOLE-PARENT-READY-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Shared producer participation, logical coverage, whole_parent_ready, and
// published visibility MUST remain distinct. Every Shared source consumer MUST
// wait/no-op before payload access until whole_parent_ready and published are
// both true; producer and consumer masks are independent.
// NDF-END: PTO-B-SHARED-WHOLE-PARENT-READY-001
pure func SharedTileArrayIndex(shared_tile_id: SharedTileID) => SharedTileIndex
begin
    return UInt(shared_tile_id) as SharedTileIndex;
end;

readonly func SharedTileRecord(shared_tile_id: SharedTileID) => SharedTileInfo
begin
    return _SharedTiles[[SharedTileArrayIndex(shared_tile_id)]];
end;

readonly func SharedTileFullyInitialized(shared_tile_id: SharedTileID) => boolean
begin
    let shared = SharedTileRecord(shared_tile_id);
    return shared.descriptor_valid &&
           shared.initialized_mask == shared.allocation_mask &&
           shared.tile.contents_defined;
end;

readonly func SharedTilePublished(shared_tile_id: SharedTileID) => boolean
begin
    let shared = SharedTileRecord(shared_tile_id);
    return SharedTileFullyInitialized(shared_tile_id) &&
           shared.whole_parent_ready && shared.published;
end;

readonly func SharedTileCooperativeMatrixReady(
    shared_tile_id: SharedTileID) => boolean
begin
    let shared = SharedTileRecord(shared_tile_id);
    return SharedTileDescriptorLegal(shared_tile_id) &&
           shared.whole_parent_ready && shared.published &&
           shared.tile.contents_defined;
end;

readonly func SharedTileDescriptorLegal(shared_tile_id: SharedTileID) => boolean
begin
    let shared = SharedTileRecord(shared_tile_id);
    return shared.descriptor_valid && shared.tile.allocated &&
           shared.allocation_mask != Zeros{4} &&
           (shared.initialized_mask AND NOT shared.allocation_mask) == Zeros{4} &&
           SharedTileCapacityIsLegal(shared.tile.capacity_bytes) &&
           TileShapeMatchesCapacity(shared.tile.capacity_bytes,
               shared.tile.rows, shared.tile.columns,
               shared.tile.data_type) &&
           shared.tile.valid_rows <= shared.tile.rows &&
           shared.tile.valid_columns <= shared.tile.columns &&
           shared.tile.rows * shared.tile.columns <=
               TileLogicalElementCapacity(shared.tile.capacity_bytes,
                                          shared.tile.data_type) &&
           TileGenericIndexingPermitted(shared.tile);
end;

readonly func SharedTileDescriptorsCompatible(left: TileInfo,
                                               right: TileInfo) => boolean
begin
    return left.allocated && right.allocated &&
           !TileLayoutIsCube(left.layout) &&
           !TileLayoutIsCube(right.layout) &&
           left.capacity_bytes == right.capacity_bytes &&
           left.rows == right.rows && left.columns == right.columns &&
           left.valid_rows == right.valid_rows &&
           left.valid_columns == right.valid_columns &&
           left.data_type == right.data_type &&
           left.layout == right.layout &&
           left.cube_k_repeat == right.cube_k_repeat &&
           left.cube_n_repeat == right.cube_n_repeat &&
           left.cube_cell_count == right.cube_cell_count &&
           left.cube_storage_bytes == right.cube_storage_bytes;
end;

readonly func SharedTileUpdateCompatible(shared_tile_id: SharedTileID, tile: TileInfo,
                                          pe_mask: bits(4)) => boolean
begin
    if pe_mask == Zeros{4} then return TRUE; end;
    if TileLayoutIsCube(tile.layout) ||
       !SharedTileCapacityIsLegal(tile.capacity_bytes) ||
       !TileShapeMatchesCapacity(tile.capacity_bytes, tile.rows,
                                 tile.columns, tile.data_type) ||
       tile.valid_rows > tile.rows ||
       tile.valid_columns > tile.columns ||
       tile.rows * tile.columns >
           TileLogicalElementCapacity(tile.capacity_bytes, tile.data_type) then
        return FALSE;
    end;
    let old = SharedTileRecord(shared_tile_id);
    if old.descriptor_valid then
        return (pe_mask AND NOT old.allocation_mask) == Zeros{4} &&
               SharedTileDescriptorsCompatible(old.tile, tile);
    end;
    return SharedTileCapacityInUse() + tile.capacity_bytes <=
        SharedTileCapacityLimitBytes();
end;

// Architectural undefined-register behavior is represented deterministically
// by pto-v0. The returned word is not a portable value and reading it never
// allocates the register or raises a fault.
readonly func UndefinedSharedTileWord(shared_tile_id: SharedTileID,
                                      element: PackedTileElementIndex) => Word
begin
    return ZeroExtend{PTO_XLEN}(shared_tile_id) XOR
        (Zeros{PTO_XLEN} + element);
end;

readonly func ReadSharedTileWord(shared_tile_id: SharedTileID,
                                 element: PackedTileElementIndex) => Word
begin
    let shared = SharedTileRecord(shared_tile_id);
    if !shared.descriptor_valid || !shared.whole_parent_ready ||
       !TileLogicalElementDefined(shared.tile, element) then
        return UndefinedSharedTileWord(shared_tile_id, element);
    end;
    return TileReadLogicalElement(shared.tile, element);
end;

// PE_MASK selects consumers, not payload quarters. Materialization returns the
// same complete parent snapshot to every participating consumer and never
// changes Shared state.
readonly func MaterializeSharedTile(shared_tile_id: SharedTileID,
                                    pe_mask: bits(4)) => TileInfo
begin
    let shared = SharedTileRecord(shared_tile_id);
    assert SharedTilePublished(shared_tile_id);
    var tile = shared.tile;
    assert tile.contents_defined;
    return tile;
end;

readonly func SharedTileReadSchemaLegalAtCapacity(
    shared_tile_id: SharedTileID, valid_rows: integer {0..65535},
    valid_columns: integer {0..65535}, columns: integer {0..65535},
    data_type: TileDataType, layout: TileLayout,
    capacity_bytes: integer {0..262144}) => boolean
begin
    if TileLayoutIsCube(layout) then return FALSE; end;
    let shared = SharedTileRecord(shared_tile_id);
    if shared.descriptor_valid then
        return SharedTileDescriptorLegal(shared_tile_id) &&
               shared.tile.capacity_bytes == capacity_bytes &&
               shared.tile.columns == columns &&
               valid_rows <= shared.tile.valid_rows &&
               valid_columns <= shared.tile.valid_columns &&
               shared.tile.data_type == data_type &&
               shared.tile.layout == layout;
    end;
    return SharedTileCapacityIsLegal(capacity_bytes) &&
           TileDescriptorShapeLegal(capacity_bytes, columns, valid_rows,
               valid_columns, data_type) &&
           DerivedTileRows(capacity_bytes, columns, data_type) * columns <=
               TileLogicalElementCapacity(capacity_bytes, data_type);
end;

readonly func SharedTileReadSchemaLegal(
    shared_tile_id: SharedTileID, valid_rows: integer {0..65535},
    valid_columns: integer {0..65535}, columns: integer {0..65535},
    data_type: TileDataType, layout: TileLayout) => boolean
begin
    let shared = SharedTileRecord(shared_tile_id);
    let capacity_bytes = if shared.descriptor_valid then
        shared.tile.capacity_bytes
    else
        MinimumTileCapacityBytesForShape(columns, valid_rows,
            valid_columns, data_type);
    return capacity_bytes != 0 && SharedTileReadSchemaLegalAtCapacity(
        shared_tile_id, valid_rows, valid_columns, columns, data_type, layout,
        capacity_bytes);
end;

readonly func MaterializeSharedTileReadValues(
    shared_tile_id: SharedTileID, tile: TileInfo) => TileInfo
begin
    var result = tile;
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                result, row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, element,
                ReadSharedTileWord(shared_tile_id, element));
        end;
    end;
    return result;
end;

// Reading an unallocated Sx is the Tile analogue of reading an undefined
// scalar register.  The operation receives a temporary read-only descriptor,
// while ReadSharedTileWord supplies deterministic model values without
// allocating or changing the architectural Shared register.
readonly func MaterializeSharedTileForReadSchema(
    shared_tile_id: SharedTileID, valid_rows: integer {0..65535},
    valid_columns: integer {0..65535}, columns: integer {0..65535},
    data_type: TileDataType, layout: TileLayout) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert SharedTileReadSchemaLegal(shared_tile_id, valid_rows, valid_columns,
        columns, data_type, layout);
    let shared = SharedTileRecord(shared_tile_id);
    let capacity_bytes = if shared.descriptor_valid then
        shared.tile.capacity_bytes
    else
        MinimumTileCapacityBytesForShape(columns, valid_rows,
            valid_columns, data_type);
    var tile = shared.tile;
    tile.allocated = TRUE;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.defined_valid_elements = 0;
    tile.packed_defined_elements = zero_packed_tile_elements;
    tile.capacity_bytes = capacity_bytes;
    tile.rows = DerivedTileRows(capacity_bytes, columns, data_type);
    tile.columns = columns;
    tile.valid_rows = valid_rows;
    tile.valid_columns = valid_columns;
    tile.data_type = data_type;
    tile.predicate_basis_type = data_type;
    tile.layout = layout;
    tile.cube_k_repeat = 0;
    tile.cube_n_repeat = 0;
    tile.cube_cell_count = 0;
    tile.cube_storage_bytes = 0;
    return MaterializeSharedTileReadValues(shared_tile_id, tile);
end;

readonly func MaterializeSharedTileForReadSchemaAtCapacity(
    shared_tile_id: SharedTileID, valid_rows: integer {0..65535},
    valid_columns: integer {0..65535}, columns: integer {0..65535},
    data_type: TileDataType, layout: TileLayout,
    capacity_bytes: integer {0..262144}) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert SharedTileReadSchemaLegalAtCapacity(shared_tile_id, valid_rows,
        valid_columns, columns, data_type, layout, capacity_bytes);
    var tile = SharedTileRecord(shared_tile_id).tile;
    tile.allocated = TRUE;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.defined_valid_elements = 0;
    tile.packed_defined_elements = zero_packed_tile_elements;
    tile.capacity_bytes = capacity_bytes;
    tile.rows = DerivedTileRows(capacity_bytes, columns, data_type);
    tile.columns = columns;
    tile.valid_rows = valid_rows;
    tile.valid_columns = valid_columns;
    tile.data_type = data_type;
    tile.predicate_basis_type = data_type;
    tile.layout = layout;
    tile.cube_k_repeat = 0;
    tile.cube_n_repeat = 0;
    tile.cube_cell_count = 0;
    tile.cube_storage_bytes = 0;
    return MaterializeSharedTileReadValues(shared_tile_id, tile);
end;

readonly func SharedTileProspectiveFullyInitialized(
    shared_tile_id: SharedTileID, tile: TileInfo, pe_mask: bits(4)) => boolean
begin
    if pe_mask == Zeros{4} ||
       !SharedTileUpdateCompatible(shared_tile_id, tile, pe_mask) then
        return FALSE;
    end;
    let old = SharedTileRecord(shared_tile_id);
    if !old.descriptor_valid then return TRUE; end;
    return (old.initialized_mask OR pe_mask) == old.allocation_mask;
end;

// One complete record assignment is the architectural commit point. A
// singleton producer publishes the complete parent; multi-PE candidates copy
// their internal writer fragments only for B.ASSEMBLE generation handling.
// A zero mask is a true NOP.
func AtomicUpdateSharedTileWithPublication(
    shared_tile_id: SharedTileID, tile: TileInfo, pe_mask: bits(4),
    publish: boolean) => boolean
begin
    if pe_mask == Zeros{4} then return TRUE; end;
    assert tile.allocated;
    let index = SharedTileArrayIndex(shared_tile_id);
    let old = _SharedTiles[[index]];
    if !SharedTileUpdateCompatible(shared_tile_id, tile, pe_mask) then
        return FALSE;
    end;
    var updated = old;
    if !old.descriptor_valid then
        let direct_complete = PEMaskPopulation(pe_mask) == 1 ||
            pe_mask == '1111';
        updated.descriptor_valid = TRUE;
        updated.allocation_mask = pe_mask;
        updated.tile = tile;
        updated.initialized_mask = pe_mask;
        updated.whole_parent_ready = publish && direct_complete &&
            tile.contents_defined;
        updated.published = updated.whole_parent_ready;
    elsif publish && PEMaskPopulation(pe_mask) == 1 then
        updated.tile = tile;
        updated.tile.contents_defined = TRUE;
        updated.tile.defined_valid_elements =
            (updated.tile.valid_rows * updated.tile.valid_columns)
                as integer {0..524288};
        updated.whole_parent_ready = TRUE;
        updated.published = TRUE;
    else
        for element = 0 to tile.rows * tile.columns - 1
            looplimit 524288 do
            let region = SharedTileElementRegion(tile,
                element as PackedTileElementIndex);
            if pe_mask[PTOPEMaskBitOfPEIdentity(region)] == '1' then
                if TileLogicalElementDefined(tile,
                    element as PackedTileElementIndex) then
                    updated.tile = TileInfoWithLogicalElement(updated.tile,
                        element as PackedTileElementIndex,
                        TileReadLogicalElement(tile,
                            element as PackedTileElementIndex));
                end;
            end;
        end;
        updated.initialized_mask = old.initialized_mask OR pe_mask;
        // Internal multi-PE B.ASSEMBLE candidates use disjoint writer regions.
        // Once their declared participant set has supplied all regions, the
        // candidate descriptor/payload snapshot is complete for LAST.
        updated.tile.contents_defined =
            updated.initialized_mask == updated.allocation_mask;
        if updated.tile.contents_defined then
            updated.tile.defined_valid_elements =
                (updated.tile.valid_rows * updated.tile.valid_columns)
                    as integer {0..524288};
        end;
        let direct_complete = pe_mask == '1111';
        updated.whole_parent_ready = old.whole_parent_ready ||
            (publish && direct_complete && updated.tile.contents_defined);
        updated.published = old.published ||
            (publish && direct_complete && updated.tile.contents_defined);
    end;
    _SharedTiles[[index]] = updated;
    return TRUE;
end;

func AtomicUpdateSharedTile(shared_tile_id: SharedTileID, tile: TileInfo,
                            pe_mask: bits(4)) => boolean
begin
    return AtomicUpdateSharedTileWithPublication(
        shared_tile_id, tile, pe_mask, TRUE);
end;

func InstallSharedTile(shared_tile_id: SharedTileID, tile: TileInfo, pe_mask: bits(4))
begin
    let updated = AtomicUpdateSharedTile(shared_tile_id, tile, pe_mask);
    assert updated;
end;
```
<!-- GENERATED-ASL-END: unit -->
