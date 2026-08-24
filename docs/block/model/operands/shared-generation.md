<!-- GENERATED FROM: asl/block/model/operands/shared-generation.asl -->
# Shared Generation

**Normative ASL source:** `asl/block/model/operands/shared-generation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/shared-generation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","surface":"block","classification":["model","operands","shared-generation"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS","PTO-BLOCK-MODEL-STATE-SHARED-GENERATION"]}

// NDF-BEGIN: PTO-B-ASSEMBLE-SHARED-GENERATION-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A Shared B.ASSEMBLE generation MUST retain the previously published Sx
// object until the matching collective LAST has complete non-overlapping CELL
// coverage, all declared writer data is ready, every participating PE reaches
// the same generation ordinal with matching metadata, and no participant has
// faulted or been squashed.  Publication MUST replace the complete Shared
// descriptor and payload atomically; every rejection MUST preserve the prior
// published generation.
// NDF-END: PTO-B-ASSEMBLE-SHARED-GENERATION-001

func AbortBundleSharedGenerationsForBundle()
begin
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid then
            AbortBundleSharedGeneration(
                _BundleSharedBindings[[binding]].shared_tile_id);
        end;
    end;
end;

readonly func BundleSharedGenerationCoverageWithCurrent(
    shared_tile_id: SharedTileID,
    offset_cells: integer {0..2047},
    writer_cells: integer {1..2048},
    init: boolean) => bits(2048)
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    var covered = if init then Zeros{2048}
        else _SharedGenerations[[index]].covered_cells;
    for cell = 0 to 2047 do
        if cell < writer_cells then
            covered[offset_cells + cell] = '1';
        end;
    end;
    return covered;
end;

readonly func ValidateBundleSharedGeneration() => boolean
begin
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid then
            let shared_tile_id =
                _BundleSharedBindings[[binding]].shared_tile_id;
            let index = SharedTileArrayIndex(shared_tile_id);
            let assemble =
                _BundleSharedBindings[[binding]].destination_assemble;
            let writer_size = _BundleSharedBindings[[binding]].size_code;
            let participant_mask = _BundleSharedBindings[[binding]].pe_mask;
            if writer_size < 1 || writer_size > 12 then return FALSE; end;
            if assemble.init && _SharedGenerations[[index]].open then
                return FALSE;
            end;
            if !assemble.init &&
               (!_SharedGenerations[[index]].open ||
                _SharedGenerations[[index]].closed) then
                return FALSE;
            end;
            if !assemble.init &&
               _SharedGenerations[[index]].participant_mask !=
                   participant_mask then
                return FALSE;
            end;
            let raw_offset = UInt(assemble.offset);
            if raw_offset > 2047 then return FALSE; end;
            let offset_cells = raw_offset as integer {0..2047};
            let writer_cells = BundleLocalGenerationCellCount(
                writer_size as integer {1..12});
            let parent_cells = if assemble.init then
                BundleLocalGenerationCellCount(
                    assemble.size_code as integer {1..12})
                else _SharedGenerations[[index]].parent_cell_count;
            if offset_cells + writer_cells > parent_cells then return FALSE; end;
            if !assemble.init then
                for cell = 0 to 2047 do
                    if cell < writer_cells &&
                       _SharedGenerations[[index]].covered_cells[
                           offset_cells + cell] == '1' then
                        return FALSE;
                    end;
                end;
            end;
            if assemble.last then
                let covered = BundleSharedGenerationCoverageWithCurrent(
                    shared_tile_id, offset_cells, writer_cells,
                    assemble.init);
                for cell = 0 to 2047 do
                    if cell < parent_cells && covered[cell] == '0' then
                        return FALSE;
                    end;
                end;
            end;
        end;
    end;
    return TRUE;
end;

func CommitBundleSharedGenerationCandidate(
    binding: BundleSharedBindingIndex,
    candidate: SharedTileInfo) => boolean
begin
    assert _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid;
    let shared_tile_id = _BundleSharedBindings[[binding]].shared_tile_id;
    let index = SharedTileArrayIndex(shared_tile_id);
    let assemble = _BundleSharedBindings[[binding]].destination_assemble;
    let participant_mask = _BundleSharedBindings[[binding]].pe_mask;
    let writer_size = _BundleSharedBindings[[binding]].size_code
        as integer {1..12};
    let offset_cells = UInt(assemble.offset) as integer {0..2047};
    let writer_cells = BundleLocalGenerationCellCount(writer_size);
    if !candidate.descriptor_valid ||
       candidate.allocation_mask != participant_mask then
        return FALSE;
    end;
    if assemble.init then
        let parent_size = assemble.size_code as integer {1..12};
        let parent_bytes = TileSizeCodeBytes(parent_size);
        let parent_rows = DerivedTileRows(
            parent_bytes, candidate.tile.columns, candidate.tile.data_type);
        if parent_rows == 0 then return FALSE; end;
        _SharedGenerations[[index]].open = TRUE;
        _SharedGenerations[[index]].closed = FALSE;
        _SharedGenerations[[index]].published = FALSE;
        _SharedGenerations[[index]].shared_tile_id = shared_tile_id;
        _SharedGenerations[[index]].participant_mask = participant_mask;
        _SharedGenerations[[index]].parent_size_code = parent_size;
        _SharedGenerations[[index]].parent_cell_count =
            BundleLocalGenerationCellCount(parent_size);
        _SharedGenerations[[index]].covered_cells = Zeros{2048};
        _SharedGenerations[[index]].ready_cells = Zeros{2048};
        _SharedGenerations[[index]].last_seen = FALSE;
        _SharedGenerations[[index]].working_valid = TRUE;
        _SharedGenerations[[index]].working_tile = candidate.tile;
        _SharedGenerations[[index]].working_tile.capacity_bytes = parent_bytes;
        _SharedGenerations[[index]].working_tile.rows = parent_rows;
        _SharedGenerations[[index]].working_tile.contents_defined = FALSE;
        _SharedGenerations[[index]].working_tile.defined_elements =
            Zeros{PTO_MODEL_TILE_ELEMENTS};
        _SharedGenerations[[index]].working_tile.packed_defined_elements =
            ZeroPackedTileDefinedElements();
        _SharedGenerations[[index]].working_tile.defined_valid_elements = 0;
        _SharedGenerations[[index]].working_initialized_mask = Zeros{4};
    else
        if !_SharedGenerations[[index]].working_valid ||
           _SharedGenerations[[index]].working_tile.columns !=
               candidate.tile.columns ||
           _SharedGenerations[[index]].working_tile.data_type !=
               candidate.tile.data_type ||
           _SharedGenerations[[index]].working_tile.layout !=
               candidate.tile.layout then
            return FALSE;
        end;
    end;
    let element_bits = TileElementBits(candidate.tile.data_type);
    let destination_offset =
        ((offset_cells * PTO_TILE_CELL_BYTES * 8) DIVRM element_bits)
        as integer {0..524287};
    let source_elements =
        ((candidate.tile.capacity_bytes * 8) DIVRM element_bits)
        as integer {1..524288};
    let parent_elements = TileLogicalElementCapacity(
        _SharedGenerations[[index]].working_tile.capacity_bytes,
        candidate.tile.data_type);
    if destination_offset + source_elements > parent_elements then
        return FALSE;
    end;
    var working = _SharedGenerations[[index]].working_tile;
    for element = 0 to source_elements - 1 looplimit 524288 do
        let source_index = element as PackedTileElementIndex;
        let destination_index = (destination_offset + element)
            as PackedTileElementIndex;
        if TileLogicalElementDefined(candidate.tile, source_index) then
            working = TileInfoWithLogicalElement(
                working, destination_index,
                TileReadLogicalElement(candidate.tile, source_index));
        end;
    end;
    _SharedGenerations[[index]].working_tile = working;
    let working_columns = working.columns as integer {1..65535};
    let required_rows = ((destination_offset + source_elements +
        (working_columns - 1)) DIVRM working_columns)
        as integer {1..65535};
    if _SharedGenerations[[index]].working_tile.valid_rows < required_rows then
        _SharedGenerations[[index]].working_tile.valid_rows = required_rows;
    end;
    if _SharedGenerations[[index]].working_tile.valid_columns <
       candidate.tile.valid_columns then
        _SharedGenerations[[index]].working_tile.valid_columns =
            candidate.tile.valid_columns;
    end;
    let covered = BundleSharedGenerationCoverageWithCurrent(
        shared_tile_id, offset_cells, writer_cells, assemble.init);
    _SharedGenerations[[index]].covered_cells = covered;
    _SharedGenerations[[index]].ready_cells = covered;
    _SharedGenerations[[index]].working_initialized_mask =
        _SharedGenerations[[index]].working_initialized_mask OR
        candidate.initialized_mask;
    if assemble.last then
        _SharedGenerations[[index]].last_seen = TRUE;
        _SharedGenerations[[index]].closed = TRUE;
        _SharedGenerations[[index]].open = FALSE;
        _SharedGenerations[[index]].published = TRUE;
        _SharedGenerations[[index]].working_tile.contents_defined = TRUE;
        _SharedTiles[[index]].descriptor_valid = TRUE;
        _SharedTiles[[index]].allocation_mask = participant_mask;
        _SharedTiles[[index]].initialized_mask = participant_mask;
        _SharedTiles[[index]].published = TRUE;
        _SharedTiles[[index]].tile =
            _SharedGenerations[[index]].working_tile;
    end;
    return TRUE;
end;

func BeginBundleSharedGenerationProbe(shared_tile_id: SharedTileID)
    => SharedTileInfo
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    let prior = _SharedTiles[[index]];
    _SharedTiles[[index]].descriptor_valid = FALSE;
    _SharedTiles[[index]].allocation_mask = Zeros{4};
    _SharedTiles[[index]].initialized_mask = Zeros{4};
    _SharedTiles[[index]].published = FALSE;
    return prior;
end;

func RestoreBundleSharedGenerationProbe(
    shared_tile_id: SharedTileID, prior: SharedTileInfo)
begin
    _SharedTiles[[SharedTileArrayIndex(shared_tile_id)]] = prior;
end;

readonly func BundleSharedSubviewLegal(
    binding: BundleSharedBindingIndex) => boolean
begin
    if !_BundleSharedBindings[[binding]].valid ||
       !_BundleSharedBindings[[binding]].source0_subview.valid ||
       _BundleSharedBindings[[binding]].size_code != 0 then
        return FALSE;
    end;
    let shared_tile_id = _BundleSharedBindings[[binding]].shared_tile_id;
    if !SharedTilePublished(shared_tile_id) then return FALSE; end;
    let parent = SharedTileRecord(shared_tile_id).tile;
    if TileLayoutIsCube(parent.layout) || parent.columns == 0 then
        return FALSE;
    end;
    let modifier = _BundleSharedBindings[[binding]].source0_subview;
    let raw_offset = UInt(modifier.offset);
    if raw_offset > 2047 || modifier.size_code == 0 then return FALSE; end;
    let offset_cells = raw_offset as integer {0..2047};
    let selected_bytes = TileSizeCodeBytes(
        modifier.size_code as integer {1..12});
    if offset_cells * PTO_TILE_CELL_BYTES + selected_bytes >
           parent.capacity_bytes then
        return FALSE;
    end;
    let element_bits = TileElementBits(parent.data_type);
    let bounded_columns = parent.columns as integer {1..65535};
    let offset_elements =
        ((offset_cells * PTO_TILE_CELL_BYTES * 8) DIVRM element_bits)
        as integer {0..524287};
    let selected_elements = ((selected_bytes * 8) DIVRM element_bits)
        as integer {1..524288};
    let origin_column = (offset_elements MOD bounded_columns)
        as integer {0..65535};
    if selected_elements > bounded_columns - origin_column &&
       (origin_column != 0 || selected_elements MOD bounded_columns != 0) then
        return FALSE;
    end;
    if selected_elements > bounded_columns - origin_column &&
       selected_elements DIVRM bounded_columns > 65535 then
        return FALSE;
    end;
    return TRUE;
end;

readonly func MaterializeBundleSharedSubview(
    binding: BundleSharedBindingIndex) => TileInfo
begin
    assert BundleSharedSubviewLegal(binding);
    let shared_tile_id = _BundleSharedBindings[[binding]].shared_tile_id;
    let parent = SharedTileRecord(shared_tile_id).tile;
    let modifier = _BundleSharedBindings[[binding]].source0_subview;
    let offset_cells = UInt(modifier.offset) as integer {0..2047};
    let selected_bytes = TileSizeCodeBytes(
        modifier.size_code as integer {1..12});
    let element_bits = TileElementBits(parent.data_type);
    let bounded_columns = parent.columns as integer {1..65535};
    let offset_elements =
        ((offset_cells * PTO_TILE_CELL_BYTES * 8) DIVRM element_bits)
        as integer {0..524287};
    let selected_elements = ((selected_bytes * 8) DIVRM element_bits)
        as integer {1..524288};
    let origin_row = (offset_elements DIVRM bounded_columns)
        as integer {0..65535};
    let origin_column = (offset_elements MOD bounded_columns)
        as integer {0..65535};
    let selected_columns = (if selected_elements <=
        bounded_columns - origin_column then selected_elements
        else bounded_columns) as integer {1..65535};
    let selected_rows = (if selected_elements <=
        bounded_columns - origin_column then 1
        else selected_elements DIVRM bounded_columns)
        as integer {1..65535};
    var tile = parent;
    tile.capacity_bytes = selected_bytes;
    tile.rows = DerivedTileRows(
        selected_bytes, selected_columns, parent.data_type);
    tile.columns = selected_columns;
    tile.valid_rows = selected_rows;
    tile.valid_columns = selected_columns;
    if origin_row + tile.valid_rows > parent.valid_rows then
        tile.valid_rows = if origin_row < parent.valid_rows then
            (parent.valid_rows - origin_row) as integer {0..65535}
            else 0;
    end;
    if origin_column + tile.valid_columns > parent.valid_columns then
        tile.valid_columns = if origin_column < parent.valid_columns then
            (parent.valid_columns - origin_column) as integer {0..65535}
            else 0;
    end;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.packed_defined_elements = ZeroPackedTileDefinedElements();
    tile.defined_valid_elements = 0;
    tile.contents_defined = FALSE;
    for element = 0 to selected_elements - 1 looplimit 524288 do
        let source_index = (offset_elements + element)
            as PackedTileElementIndex;
        let destination_index = element as PackedTileElementIndex;
        tile = TileInfoWithLogicalElement(tile, destination_index,
            ReadSharedTileWord(shared_tile_id, source_index));
    end;
    tile.contents_defined = TRUE;
    tile.defined_valid_elements =
        (tile.valid_rows * tile.valid_columns) as integer {0..524288};
    return tile;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
