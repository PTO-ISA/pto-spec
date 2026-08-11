// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-SHARED-REGISTERS","surface":"tile","classification":["model","state","shared-registers"],"depends_on":["PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","PTO-TILE-MODEL-LEGALITY-PE-MASK"]}
pure func SharedTileArrayIndex(shared_id: bits(8)) => SharedTileIndex
begin
    return UInt(shared_id) as SharedTileIndex;
end;

readonly func SharedTileRecord(shared_id: bits(8)) => SharedTileInfo
begin
    return _SharedTiles[[SharedTileArrayIndex(shared_id)]];
end;

readonly func SharedTileAnyQuarterInitialized(shared_id: bits(8)) => boolean
begin
    let shared = SharedTileRecord(shared_id);
    return shared.descriptor_valid && shared.initialized_mask != Zeros{4};
end;

readonly func SharedTileFullyInitialized(shared_id: bits(8)) => boolean
begin
    let shared = SharedTileRecord(shared_id);
    return shared.descriptor_valid &&
           shared.initialized_mask == shared.allocation_mask &&
           shared.tile.contents_defined;
end;

readonly func SharedTileDescriptorLegal(shared_id: bits(8)) => boolean
begin
    let shared = SharedTileRecord(shared_id);
    return shared.descriptor_valid && shared.tile.allocated &&
           !TileLayoutIsCube(shared.tile.layout) &&
           shared.allocation_mask != Zeros{4} &&
           (shared.initialized_mask AND NOT shared.allocation_mask) == Zeros{4} &&
           TileCapacityIsLegal(shared.tile.capacity_bytes) &&
           TileShapeMatchesCapacity(shared.tile.capacity_bytes,
               shared.tile.rows, shared.tile.columns,
               shared.tile.data_type) &&
           shared.tile.valid_rows <= shared.tile.rows &&
           shared.tile.valid_columns <= shared.tile.columns &&
           shared.tile.rows * shared.tile.columns <= PTO_MODEL_TILE_ELEMENTS &&
           TileGenericIndexingPermitted(shared.tile);
end;

readonly func SharedTileDescriptorsCompatible(left: TileInfo,
                                               right: TileInfo) => boolean
begin
    return left.allocated && right.allocated &&
           left.capacity_bytes == right.capacity_bytes &&
           left.rows == right.rows && left.columns == right.columns &&
           left.valid_rows == right.valid_rows &&
           left.valid_columns == right.valid_columns &&
           left.storage_rows == right.storage_rows &&
           left.storage_columns == right.storage_columns &&
           left.storage_bytes == right.storage_bytes &&
           left.cube_k_repeat == right.cube_k_repeat &&
           left.cube_n_repeat == right.cube_n_repeat &&
           left.cube_cell_count == right.cube_cell_count &&
           left.data_type == right.data_type &&
           left.layout == right.layout && left.location == right.location;
end;

readonly func SharedTileUpdateCompatible(shared_id: bits(8), tile: TileInfo,
                                          pe_mask: bits(4)) => boolean
begin
    if pe_mask == Zeros{4} then return TRUE; end;
    if !TileCapacityIsLegal(tile.capacity_bytes) ||
       TileLayoutIsCube(tile.layout) ||
       !TileShapeMatchesCapacity(tile.capacity_bytes, tile.rows,
                                 tile.columns, tile.data_type) ||
       tile.valid_rows > tile.rows ||
       tile.valid_columns > tile.columns ||
       tile.rows * tile.columns > PTO_MODEL_TILE_ELEMENTS then
        return FALSE;
    end;
    let old = SharedTileRecord(shared_id);
    if old.descriptor_valid then
        return (pe_mask AND NOT old.allocation_mask) == Zeros{4} &&
               SharedTileDescriptorsCompatible(old.tile, tile);
    end;
    return TileCapacityInUse() + SharedTileCapacityInUse() +
           TileCoreAllocationBytes(pe_mask, tile.capacity_bytes) <=
               TileCapacityLimitBytes();
end;

// Architectural undefined-register behavior is represented deterministically
// by pto-v0. The returned word is not a portable value and reading it never
// allocates the register or raises a fault.
readonly func UndefinedSharedTileWord(shared_id: bits(8),
                                      element: ModelTileElementIndex) => Word
begin
    return ZeroExtend{PTO_XLEN}(shared_id) XOR
        (Zeros{PTO_XLEN} + element);
end;

readonly func ReadSharedTileWord(shared_id: bits(8),
                                 element: ModelTileElementIndex) => Word
begin
    let shared = SharedTileRecord(shared_id);
    if !shared.descriptor_valid then
        return UndefinedSharedTileWord(shared_id, element);
    end;
    let region = SharedTileElementRegion(shared.tile, element);
    if shared.initialized_mask[region] == '0' then
        return UndefinedSharedTileWord(shared_id, element);
    end;
    return shared.tile.payload[[element]];
end;

// Consumers observe undefined-register values for uninitialized quarters.
// Materialization is a read-only snapshot and never changes Shared state.
readonly func MaterializeSharedTile(shared_id: bits(8),
                                    pe_mask: bits(4)) => TileInfo
begin
    let shared = SharedTileRecord(shared_id);
    assert SharedTileDescriptorLegal(shared_id);
    var tile = shared.tile;
    tile.contents_defined =
        (pe_mask AND shared.initialized_mask) == pe_mask;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.defined_valid_elements = 0;
    for element = 0 to tile.rows * tile.columns - 1 looplimit 4096 do
        let index = element as ModelTileElementIndex;
        let region = SharedTileElementRegion(tile, index);
        if pe_mask[region] == '1' then
            tile.payload[[index]] = ReadSharedTileWord(shared_id, index);
            tile.defined_elements[element] = '1';
        end;
    end;
    if tile.contents_defined then
        tile.defined_valid_elements =
            (tile.valid_rows * tile.valid_columns)
                as integer {0..16384};
    end;
    tile.location = TileLocation_Any;
    return tile;
end;

// One complete record assignment is the architectural commit point. Partial
// initialized writes validate descriptor compatibility before copying any
// selected fixed-offset quarter into the snapshot. A zero mask is a true NOP.
func AtomicUpdateSharedTile(shared_id: bits(8), tile: TileInfo,
                            pe_mask: bits(4)) => boolean
begin
    if pe_mask == Zeros{4} then return TRUE; end;
    assert tile.allocated;
    let index = SharedTileArrayIndex(shared_id);
    let old = _SharedTiles[[index]];
    if !SharedTileUpdateCompatible(shared_id, tile, pe_mask) then
        return FALSE;
    end;
    var updated = old;
    if !old.descriptor_valid then
        updated.descriptor_valid = TRUE;
        updated.allocation_mask = pe_mask;
        updated.tile = tile;
        updated.initialized_mask = pe_mask;
        updated.tile.contents_defined = TRUE;
        updated.tile.defined_valid_elements =
            (updated.tile.valid_rows * updated.tile.valid_columns)
                as integer {0..16384};
    else
        for element = 0 to tile.rows * tile.columns - 1 looplimit 4096 do
            let region = SharedTileElementRegion(tile,
                element as ModelTileElementIndex);
            if pe_mask[region] == '1' then
                updated.tile.payload[[element]] = tile.payload[[element]];
                updated.tile.defined_elements[element] =
                    tile.defined_elements[element];
            end;
        end;
        updated.initialized_mask = old.initialized_mask OR pe_mask;
        // Every valid element belongs to exactly one fixed-offset quarter.
        // Once complementary atomic updates have initialized all four
        // quarters, their aggregate descriptor/payload snapshot is defined
        // even though each individual partial source was not a full tile.
        updated.tile.contents_defined =
            updated.initialized_mask == updated.allocation_mask;
        if updated.tile.contents_defined then
            updated.tile.defined_valid_elements =
                (updated.tile.valid_rows * updated.tile.valid_columns)
                    as integer {0..16384};
        end;
    end;
    _SharedTiles[[index]] = updated;
    return TRUE;
end;

func InstallSharedTile(shared_id: bits(8), tile: TileInfo, pe_mask: bits(4))
begin
    let updated = AtomicUpdateSharedTile(shared_id, tile, pe_mask);
    assert updated;
end;
