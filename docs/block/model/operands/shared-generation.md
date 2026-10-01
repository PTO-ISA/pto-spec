<!-- GENERATED FROM: asl/block/model/operands/shared-generation.asl -->
# Shared Generation

**Normative ASL source:** `asl/block/model/operands/shared-generation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-purpose role=purpose-scope -->
## Purpose and scope

This unit owns Shared generations and Shared subviews. A Shared generation is a Shared Tile built by one or more writers with `B.ASSEMBLE`. A Shared subview is a `B.SUBVIEW` range of a published Shared Tile that each PE may place differently.

The unit validates writer ranges, merges each writer's payload into a working copy, and publishes the complete object at LAST.

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-concepts role=concepts-state -->
## Concepts and visible state

The unit updates the `_SharedGenerations` record of one Shared Tile ID and, at LAST, the published `_SharedTiles` entry.

Coverage is tracked in 32-byte units, with 8192 units in a map. An ordinary `B.ASSEMBLE` offset and size code are in 128-byte CELLs, and the wrappers multiply by 4. The ASL comment states the reason: the finer unit lets specialized complete-row producers express the TIMG2COL row ranges without partial CELL rules. Weight `TLOAD` also commits through the same range entry point.

`BundleSharedGenerationCapacity` returns the binding's size code, or, for a reused destination, the generation's `parent_size_code`.

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-rules role=rules-interactions -->
## Rules and interactions

`ValidateBundleSharedGenerationRange` accepts a writer only when:

- INIT names a destination with a size code of 1..12 and no generation is already open for that ID;
- a continuation names a reused destination of an open, unclosed generation with the same participant mask and, for specialized producers, the same inputs and metadata;
- the arriving PEs are a nonempty subset of the mask;
- the range fits in the parent and, for a continuation, overlaps no covered unit;
- at LAST, every parent unit is covered and every participant has arrived.

`ValidateBundleSharedGeneration` applies this to ordinary writers during stage-2 preparation, with the whole binding mask arriving.

`CommitBundleSharedGenerationCandidateRange` repeats the validation. INIT resets the record and starts a working Tile from the candidate with the parent capacity and no defined elements. A continuation requires matching columns, data type, and layout. The candidate's defined elements are copied into the working Tile at the writer's offset, and the valid region grows to cover them. Coverage, readiness, and arrival are updated. At LAST the working Tile becomes the published Shared Tile in the same commit step.

Design point: `CommitBundleSharedGenerationCandidateRange` writes `_SharedTiles` only at LAST; earlier calls change only the generation record. The NDF `PTO-B-ASSEMBLE-SHARED-GENERATION-001` requires publication to replace descriptor and payload atomically and every rejection to preserve the prior published generation.

Design point: participant arrival is tracked apart from coverage. A specialized cooperative producer passes one PE's arrival bit per writer, and a PE with zero rows can arrive without writing cells, so the collective can still close.

`BeginBundleSharedGenerationProbe` saves the published record and hides it while a Shared `TLOAD` or a Local-to-Shared `TMOV` builds a candidate. On the fault-free `TLOAD` path, and always for `TMOV`, `RestoreBundleSharedGenerationProbe` puts it back before the commit. The Shared TLSU comment states that after a first fault the candidate record is left in place and is neither ready nor published.

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-boundaries role=boundaries -->
## Architectural boundaries

`BundleSharedSubviewLegal` requires a size-code-0 source binding of a published, non-CUBE Shared Tile. For every selected PE, it evaluates `GPR[RegSrc] + uimm11` in that PE's own registers, then requires the range to fit the parent and to be either within one row or whole rows starting at column 0. `MaterializeBundleSharedSubviewForPE` builds that PE's view. One bad view rejects the operation.

`AbortBundleSharedGenerationsForBundle` aborts every generation the bundle touched when a tile operation fails.

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Shared Tile 3 is built by two ordinary writer bundles with mask `1111` and parent size code 7 (8192 bytes, 64 CELLs, 256 units). Bundle A carries INIT with writer size code 6 (32 CELLs) at offset 0. After A, units 0..127 are covered and all four PEs have arrived, because an ordinary writer arrives with its whole mask. Bundle B carries LAST with writer size code 6 at offset 32 and covers units 128..255. Coverage is then complete, and the working Tile replaces Shared Tile 3. If B used offset 16 instead, its range would overlap covered units, B would fault with `Fault_TileLegality`, the open generation would be aborted, and any previously published Shared Tile 3 would remain published.

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-related role=related-owners-navigation -->
## Related owners

- [Shared generation state](../state/shared-generation-state.md) clears, resets, and aborts the records.
- [Shared bindings](shared-bindings.md) defines reused destinations.
- [Shared TLSU](../dispatch/shared-tlsu.md), [TIMG2COL execution](../dispatch/timg2col-execution.md), and [Weight-to-shared execution](../dispatch/weight-to-shared-execution.md) commit candidates.
- [B.ASSEMBLE](../../operands/B.ASSEMBLE.md) is the command page.
<!-- SUPPLEMENTARY-END -->

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
// NDF-BEGIN: PTO-B-SUBVIEW-SHARED-PER-PE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A Shared B.SUBVIEW source MUST evaluate GPR[RegSrc]+uimm11 in each
// participating PE's private GPR context. The encoded size is common, but
// selected PEs may materialize distinct ranges of one published parent.
// Matrix consumers derive/validate each selected view's metadata before any
// payload snapshot or destination allocation; one bad view rejects the whole operation.
// NDF-END: PTO-B-SUBVIEW-SHARED-PER-PE-001
readonly func BundleSharedGenerationCapacity(binding: BundleSharedBindingIndex) => integer {0..12}
begin
    if !BundleSharedBindingIsReusedDestination(binding) then return _BundleSharedBindings[[binding]].size_code; end;
    return _SharedGenerations[[SharedTileArrayIndex(_BundleSharedBindings[[binding]].shared_tile_id)]].parent_size_code;
end;
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
// Shared generation coverage is tracked internally in 32-byte units. Ordinary
// B.ASSEMBLE offsets and SizeCodes remain 128-byte Tile CELL quantities and
// the compatibility wrappers below expand each such CELL to four units. The
// finer internal granularity lets specialized complete-row producers express
// the frozen TIMG2COL row ranges without inventing partial generic CELL rules.
readonly func BundleSharedGenerationCoverageWithCurrent(
    shared_tile_id: SharedTileID,
    offset_cells: integer {0..8192},
    coverage_cells: integer {0..8192},
    init: boolean) => bits(8192)
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    var covered = if init then Zeros{8192}
        else _SharedGenerations[[index]].covered_cells;
    for cell = 0 to 8191 do
        if cell < coverage_cells then
            covered[offset_cells + cell] = '1';
        end;
    end;
    return covered;
end;
// A specialized collective may contribute fewer physical cells than the
// size-coded carrier and may contribute no cells at all.  Participant arrival
// remains independent of CELL coverage so a zero-row PE can complete the
// collective without writing payload or definedness.
readonly func ValidateBundleSharedGenerationRange(
    binding: BundleSharedBindingIndex,
    offset_cells: integer {0..8192},
    coverage_cells: integer {0..8192},
    participant_arrival: bits(4),
    specialized_inputs_valid: boolean,
    specialized_input0: Word, specialized_input1: Word, specialized_input2: Word,
    specialized_input3: Word, specialized_metadata: Word) => boolean
begin
    if !_BundleSharedBindings[[binding]].valid ||
       !_BundleSharedBindings[[binding]].destination_assemble.valid then
        return FALSE;
    end;
    let shared_tile_id = _BundleSharedBindings[[binding]].shared_tile_id;
    let index = SharedTileArrayIndex(shared_tile_id);
    let assemble = _BundleSharedBindings[[binding]].destination_assemble;
    let participant_mask = _BundleSharedBindings[[binding]].pe_mask;
    if assemble.init && _BundleSharedBindings[[binding]].size_code == 0 then return FALSE; end;
    if !assemble.init && !BundleSharedBindingIsReusedDestination(binding) then return FALSE; end;
    if participant_arrival == Zeros{4} ||
       (participant_arrival AND participant_mask) != participant_arrival then
        return FALSE;
    end;
    if assemble.init && _SharedGenerations[[index]].open then
        return FALSE;
    end;
    if !assemble.init &&
       (!_SharedGenerations[[index]].open ||
        _SharedGenerations[[index]].closed) then
        return FALSE;
    end;
    if !assemble.init &&
       _SharedGenerations[[index]].participant_mask != participant_mask then
        return FALSE;
    end;
    if !assemble.init &&
       (_SharedGenerations[[index]].specialized_inputs_valid !=
            specialized_inputs_valid ||
        (specialized_inputs_valid &&
         (_SharedGenerations[[index]].specialized_input0 != specialized_input0 ||
          _SharedGenerations[[index]].specialized_input1 != specialized_input1 ||
          _SharedGenerations[[index]].specialized_input2 != specialized_input2 ||
          _SharedGenerations[[index]].specialized_input3 != specialized_input3 ||
          _SharedGenerations[[index]].specialized_metadata != specialized_metadata))) then
        return FALSE;
    end;
    if assemble.init &&
       (_BundleSharedBindings[[binding]].size_code < 1 ||
        _BundleSharedBindings[[binding]].size_code > 12) then
        return FALSE;
    end;
    let parent_cells = if assemble.init then
        BundleLocalGenerationCellCount(
            _BundleSharedBindings[[binding]].size_code as integer {1..12}) * 4
        else _SharedGenerations[[index]].parent_cell_count;
    if offset_cells + coverage_cells > parent_cells then return FALSE; end;
    if !assemble.init then
        for cell = 0 to 8191 do
            if cell < coverage_cells &&
               _SharedGenerations[[index]].covered_cells[
                   offset_cells + cell] == '1' then
                return FALSE;
            end;
        end;
    end;
    if assemble.last then
        let covered = BundleSharedGenerationCoverageWithCurrent(
            shared_tile_id, offset_cells, coverage_cells, assemble.init);
        for cell = 0 to 8191 do
            if cell < parent_cells && covered[cell] == '0' then
                return FALSE;
            end;
        end;
        let arrived = (if assemble.init then Zeros{4}
            else _SharedGenerations[[index]].arrived_participants) OR
            participant_arrival;
        if arrived != participant_mask then return FALSE; end;
    end;
    return TRUE;
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
            let writer_size = assemble.size_code;
            let participant_mask = _BundleSharedBindings[[binding]].pe_mask;
            if writer_size < 1 || writer_size > 12 then return FALSE; end;
            if assemble.init && _BundleSharedBindings[[binding]].size_code == 0 then return FALSE; end;
            if !assemble.init && !BundleSharedBindingIsReusedDestination(binding) then return FALSE; end;
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
            let offset_cells = (raw_offset * 4) as integer {0..8188};
            let writer_cells = (BundleLocalGenerationCellCount(
                writer_size as integer {1..12}) * 4) as integer {4..8192};
            if !ValidateBundleSharedGenerationRange(binding, offset_cells,
                   writer_cells, participant_mask, FALSE,
                   Zeros{PTO_XLEN}, Zeros{PTO_XLEN},
                   Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, Zeros{PTO_XLEN}) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;
func CommitBundleSharedGenerationCandidateRange(
    binding: BundleSharedBindingIndex, candidate: SharedTileInfo,
    offset_cells: integer {0..8192},
    coverage_cells: integer {0..8192},
    payload_cells: integer {0..8192},
    participant_arrival: bits(4),
    specialized_inputs_valid: boolean,
    specialized_input0: Word, specialized_input1: Word, specialized_input2: Word,
    specialized_input3: Word, specialized_metadata: Word) => boolean
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid;
    let shared_tile_id = _BundleSharedBindings[[binding]].shared_tile_id;
    let index = SharedTileArrayIndex(shared_tile_id);
    let assemble = _BundleSharedBindings[[binding]].destination_assemble;
    let participant_mask = _BundleSharedBindings[[binding]].pe_mask;
    if !candidate.descriptor_valid ||
       candidate.allocation_mask != participant_mask ||
       payload_cells > coverage_cells ||
       !ValidateBundleSharedGenerationRange(binding, offset_cells,
           coverage_cells, participant_arrival, specialized_inputs_valid,
           specialized_input0, specialized_input1,
           specialized_input2, specialized_input3, specialized_metadata) then
        return FALSE;
    end;
    if assemble.init then
        let parent_size = _BundleSharedBindings[[binding]].size_code as integer {1..12};
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
            BundleLocalGenerationCellCount(parent_size) * 4;
        _SharedGenerations[[index]].covered_cells = Zeros{8192};
        _SharedGenerations[[index]].ready_cells = Zeros{8192};
        _SharedGenerations[[index]].arrived_participants = Zeros{4};
        _SharedGenerations[[index]].specialized_inputs_valid =
            specialized_inputs_valid;
        _SharedGenerations[[index]].specialized_input0 = specialized_input0;
        _SharedGenerations[[index]].specialized_input1 = specialized_input1;
        _SharedGenerations[[index]].specialized_input2 = specialized_input2;
        _SharedGenerations[[index]].specialized_input3 = specialized_input3;
        _SharedGenerations[[index]].specialized_metadata = specialized_metadata;
        _SharedGenerations[[index]].last_seen = FALSE;
        _SharedGenerations[[index]].working_valid = TRUE;
        _SharedGenerations[[index]].working_tile = candidate.tile;
        _SharedGenerations[[index]].working_tile.capacity_bytes = parent_bytes;
        _SharedGenerations[[index]].working_tile.rows = parent_rows;
        _SharedGenerations[[index]].working_tile.contents_defined = FALSE;
        _SharedGenerations[[index]].working_tile.defined_elements =
            Zeros{PTO_MODEL_TILE_ELEMENTS};
        _SharedGenerations[[index]].working_tile.packed_defined_elements =
            zero_packed_tile_elements;
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
    if payload_cells != 0 then
        let element_bits = TileElementBits(candidate.tile.data_type);
        let destination_offset = ((offset_cells * 32 * 8) DIVRM element_bits)
            as integer {0..524287};
        let source_elements = ((payload_cells * 32 * 8) DIVRM element_bits)
            as integer {1..524288};
        let parent_elements = TileLogicalElementCapacity(
            _SharedGenerations[[index]].working_tile.capacity_bytes,
            candidate.tile.data_type);
        if destination_offset + source_elements > parent_elements then
            return FALSE;
        end;
        if candidate.tile.valid_rows == 0 ||
           candidate.tile.valid_columns == 0 then
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
        let last_valid_row = (candidate.tile.valid_rows - 1)
            as integer {0..65534};
        let last_valid_column = (candidate.tile.valid_columns - 1)
            as integer {0..65534};
        let candidate_valid_extent =
            (TileLogicalLinearIndex(candidate.tile, last_valid_row,
                 last_valid_column) + 1) as integer {1..524288};
        let required_end = destination_offset + candidate_valid_extent;
        if required_end > parent_elements then return FALSE; end;
        let required_rows = ((required_end +
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
    end;
    let covered = BundleSharedGenerationCoverageWithCurrent(
        shared_tile_id, offset_cells, coverage_cells, assemble.init);
    _SharedGenerations[[index]].covered_cells = covered;
    _SharedGenerations[[index]].ready_cells = covered;
    _SharedGenerations[[index]].arrived_participants =
        _SharedGenerations[[index]].arrived_participants OR
        participant_arrival;
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
        _SharedTiles[[index]].whole_parent_ready = TRUE;
        _SharedTiles[[index]].published = TRUE;
        _SharedTiles[[index]].tile =
            _SharedGenerations[[index]].working_tile;
    end;
    return TRUE;
end;
// Ordinary B.ASSEMBLE retains its size-coded range and represents arrival of
// the complete decoded PE mask.  Specialized collectives use the explicit
// range entry point above.
func CommitBundleSharedGenerationCandidate(
    binding: BundleSharedBindingIndex,
    candidate: SharedTileInfo) => boolean
begin
    let assemble = _BundleSharedBindings[[binding]].destination_assemble;
    let offset_cells = (UInt(assemble.offset) * 4) as integer {0..8188};
    let writer_cells = (BundleLocalGenerationCellCount(assemble.size_code as integer {1..12}) * 4) as integer {4..8192};
    return CommitBundleSharedGenerationCandidateRange(binding, candidate,
        offset_cells, writer_cells, writer_cells,
        _BundleSharedBindings[[binding]].pe_mask, FALSE,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN},
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
end;
func BeginBundleSharedGenerationProbe(shared_tile_id: SharedTileID)
    => SharedTileInfo
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    let prior = _SharedTiles[[index]];
    _SharedTiles[[index]].descriptor_valid = FALSE;
    _SharedTiles[[index]].allocation_mask = Zeros{4};
    _SharedTiles[[index]].initialized_mask = Zeros{4};
    _SharedTiles[[index]].whole_parent_ready = FALSE;
    _SharedTiles[[index]].published = FALSE;
    return prior;
end;
func RestoreBundleSharedGenerationProbe(
    shared_tile_id: SharedTileID, prior: SharedTileInfo)
begin
    _SharedTiles[[SharedTileArrayIndex(shared_tile_id)]] = prior;
end;
readonly func BundleSharedSubviewOffsetRawForPE(
    binding: BundleSharedBindingIndex, pe_identity: MemoryAgentId) => Word
begin
    let modifier = _BundleSharedBindings[[binding]].source0_subview;
    return ReadPEAbsoluteGPROperand(pe_identity, modifier.reg_src) +
        ZeroExtend{PTO_XLEN}(modifier.uimm11);
end;
readonly func BundleSharedSubviewOffsetCellsForPE(
    binding: BundleSharedBindingIndex, pe_identity: MemoryAgentId)
    => integer {0..2047}
begin
    let raw_offset = UInt(BundleSharedSubviewOffsetRawForPE(
        binding, pe_identity));
    assert raw_offset <= 2047;
    return raw_offset as integer {0..2047};
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
    if modifier.size_code == 0 then return FALSE; end;
    let selected_bytes = TileSizeCodeBytes(
        modifier.size_code as integer {1..12});
    let element_bits = TileElementBits(parent.data_type);
    let bounded_columns = parent.columns as integer {1..65535};
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe_identity = pe as MemoryAgentId;
        if _BundleSharedBindings[[binding]].pe_mask[
               PTOPEMaskBitOfPEIdentity(pe_identity)] == '1' then
            let raw_offset = UInt(BundleSharedSubviewOffsetRawForPE(
                binding, pe_identity));
            if raw_offset > 2047 then return FALSE; end;
            let offset_cells = raw_offset as integer {0..2047};
            if offset_cells * PTO_TILE_CELL_BYTES + selected_bytes >
                   parent.capacity_bytes then
                return FALSE;
            end;
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
        end;
    end;
    return TRUE;
end;
readonly func MaterializeBundleSharedSubviewForPE(
    binding: BundleSharedBindingIndex, pe_identity: MemoryAgentId) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert BundleSharedSubviewLegal(binding);
    let shared_tile_id = _BundleSharedBindings[[binding]].shared_tile_id;
    let parent = SharedTileRecord(shared_tile_id).tile;
    let modifier = _BundleSharedBindings[[binding]].source0_subview;
    let offset_cells = BundleSharedSubviewOffsetCellsForPE(
        binding, pe_identity);
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
    tile.packed_defined_elements = zero_packed_tile_elements;
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
readonly func MaterializeBundleSharedSubview(
    binding: BundleSharedBindingIndex) => TileInfo
begin
    return MaterializeBundleSharedSubviewForPE(binding, _CurrentMemoryAgent);
end;
```
<!-- GENERATED-ASL-END: unit -->
