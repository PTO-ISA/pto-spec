// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION","surface":"block","classification":["model","operands","local-generation"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS","PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS"]}

// NDF-BEGIN: PTO-B-ASSEMBLE-LOCAL-GENERATION-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A Local B.ASSEMBLE generation is keyed by selected PE mask and
// architectural destination hand/name. INIT captures one normalized parent
// descriptor; later writers must match that identity and use a distinct
// instruction instance unless they are an exact replay. Coverage and
// readiness are checked before LAST publication, and a fault aborts the
// pending working version while preserving the committed version, mapping,
// payload, definedness, and sources.
// NDF-END: PTO-B-ASSEMBLE-LOCAL-GENERATION-001

pure func BundleLocalGenerationSlot(hand: integer {0..3},
                                    participant_mask: bits(4))
    => integer {0..63}
begin
    return (hand + UInt(participant_mask) * 4) as integer {0..63};
end;

readonly func BundleLocalGenerationOpenForDifferentMask(
    hand: integer {0..3}, participant_mask: bits(4)) => boolean
begin
    for mask_value = 1 to 15 do
        let candidate_mask = Zeros{4} + mask_value;
        if candidate_mask != participant_mask &&
           _LocalGenerations[[BundleLocalGenerationSlot(
               hand, candidate_mask)]].open then
            return TRUE;
        end;
    end;
    return FALSE;
end;

readonly func BundleLocalGenerationOpenForHand(
    hand: integer {0..3}) => boolean
begin
    for mask_value = 1 to 15 do
        let candidate_mask = Zeros{4} + mask_value;
        if _LocalGenerations[[BundleLocalGenerationSlot(
               hand, candidate_mask)]].open then
            return TRUE;
        end;
    end;
    return FALSE;
end;

func ClearBundleLocalGenerationState(slot: integer {0..63})
begin
    _LocalGenerations[[slot]].open = FALSE;
    _LocalGenerations[[slot]].closed = FALSE;
    _LocalGenerations[[slot]].published = FALSE;
    _LocalGenerations[[slot]].destination_hand = 0;
    _LocalGenerations[[slot]].participant_mask = Zeros{4};
    _LocalGenerations[[slot]].generation_instance = Zeros{PTO_XLEN};
    _LocalGenerations[[slot]].init_tpc = Zeros{PTO_XLEN};
    _LocalGenerations[[slot]].init_tpc_valid = FALSE;
    _LocalGenerations[[slot]].parent_size_code = 0;
    _LocalGenerations[[slot]].parent_cell_count = 0;
    _LocalGenerations[[slot]].parent_descriptor.valid = FALSE;
    _LocalGenerations[[slot]].parent_descriptor.object_name = 0;
    _LocalGenerations[[slot]].parent_descriptor.object_kind = TileStorage_Numeric;
    _LocalGenerations[[slot]].parent_descriptor.participant_mask = Zeros{4};
    _LocalGenerations[[slot]].parent_descriptor.capacity_bytes = 0;
    _LocalGenerations[[slot]].parent_descriptor.rows = 0;
    _LocalGenerations[[slot]].parent_descriptor.columns = 0;
    _LocalGenerations[[slot]].parent_descriptor.valid_rows = 0;
    _LocalGenerations[[slot]].parent_descriptor.valid_columns = 0;
    _LocalGenerations[[slot]].parent_descriptor.data_type = TileDataType_FP64;
    _LocalGenerations[[slot]].parent_descriptor.predicate_basis_type =
        TileDataType_FP64;
    _LocalGenerations[[slot]].parent_descriptor.layout = TileLayout_RowMajor;
    _LocalGenerations[[slot]].parent_descriptor.location = TileLocation_Any;
    _LocalGenerations[[slot]].parent_descriptor.cube_k_repeat = 0;
    _LocalGenerations[[slot]].parent_descriptor.cube_n_repeat = 0;
    _LocalGenerations[[slot]].parent_descriptor.cube_cell_count = 0;
    _LocalGenerations[[slot]].parent_descriptor.cube_storage_bytes = 0;
    _LocalGenerations[[slot]].covered_cells = Zeros{2048};
    _LocalGenerations[[slot]].ready_cells = Zeros{2048};
    _LocalGenerations[[slot]].writer_count = 0;
    _LocalGenerations[[slot]].consumer_count = 0;
    _LocalGenerations[[slot]].last_seen = FALSE;
    _LocalGenerations[[slot]].working_destination = 0;
    _LocalGenerations[[slot]].published_destination = 0;
    _LocalGenerations[[slot]].committed_destination = 0;
    _LocalGenerations[[slot]].committed_valid = FALSE;
end;
func AbortBundleLocalGeneration(hand: integer {0..3},
                                participant_mask: bits(4))
begin
    let slot = BundleLocalGenerationSlot(hand, participant_mask);
    let committed_destination =
        _LocalGenerations[[slot]].committed_destination;
    let committed_valid = _LocalGenerations[[slot]].committed_valid;
    // A closed/published record is the committed version and must survive a
    // later writer-after-LAST fault. Only an open working version is
    // speculative and therefore eligible for abort.
    if _LocalGenerations[[slot]].open ||
       _LocalGenerations[[slot]].init_tpc_valid then
        let destination = _LocalGenerations[[slot]].working_destination;
        if _Tiles[[destination]].allocated &&
           (!committed_valid || destination != committed_destination) then
            ReleaseTile(destination);
        end;
        ClearBundleLocalGenerationState(slot);
        _LocalGenerations[[slot]].committed_destination =
            committed_destination;
        _LocalGenerations[[slot]].committed_valid = committed_valid;
        _LocalGenerations[[slot]].published_destination =
            committed_destination;
        _LocalGenerations[[slot]].published = committed_valid;
        _LocalGenerations[[slot]].closed = committed_valid;
    end;
end;

func AbortBundleLocalGenerationsForBundle()
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_assemble.valid then
            let hand = UInt(_BundleTileBindings[[binding]].destination_hand)
                as integer {0..3};
            AbortBundleLocalGeneration(hand,
                _BundleTileBindings[[binding]].pe_mask);
        end;
    end;
end;
func SetBundleLocalGenerationFault(hand: integer {0..3},
                                   participant_mask: bits(4),
                                   fault: FaultCode)
begin
    let slot = BundleLocalGenerationSlot(hand, participant_mask);
    let restart_tpc = _LocalGenerations[[slot]].init_tpc;
    let restart_valid = _LocalGenerations[[slot]].init_tpc_valid;
    // Abort before SetFault snapshots the trap context, so recovery cannot
    // resurrect speculative coverage, readiness, or the working object.
    AbortBundleLocalGeneration(hand, participant_mask);
    SetFault(fault, ReadTPC());
    let ring = CurrentACR();
    if restart_valid && _TrapContexts[[ring]].valid then
        _TrapContexts[[ring]].tpc = restart_tpc;
    end;
end;
pure func BundleLocalGenerationCellCount(size_code: integer {1..12})
    => integer {1..2048}
begin
    return (TileSizeCodeBytes(size_code) DIVRM PTO_TILE_CELL_BYTES)
        as integer {1..2048};
end;

readonly func BundleLocalDestinationAllocationBytes(
    binding: BundleTileBindingIndex)
    => integer {0,128,256,512,1024,2048,4096,8192,16384,32768,65536,
                131072,262144}
begin
    let assemble = _BundleTileBindings[[binding]].destination_assemble;
    if assemble.valid && assemble.init then
        assert assemble.size_code >= 1 && assemble.size_code <= 12;
        return TileSizeCodeBytes(
            assemble.size_code as integer {1..12});
    end;
    return BundleTileDestinationSizeBytes(binding);
end;

pure func BundleLocalGenerationRangeOverlaps(
    left_offset: integer {0..2047}, left_count: integer {1..2048},
    right_offset: integer {0..2047}, right_count: integer {1..2048}) => boolean
begin
    return left_offset < right_offset + right_count &&
           right_offset < left_offset + left_count;
end;

readonly func BundleLocalGenerationCoverageComplete(
    slot: integer {0..63}, offset: Word, writer_size: integer {1..12},
    init: boolean, parent_size: integer {0..12}) => boolean
begin
    let raw_offset = UInt(offset);
    if raw_offset > 2047 then return FALSE; end;
    let offset_cells = raw_offset as integer {0..2047};
    let writer_cells = BundleLocalGenerationCellCount(writer_size);
    let required_cells = if init then
        BundleLocalGenerationCellCount(parent_size as integer {1..12})
        else _LocalGenerations[[slot]].parent_cell_count;
    var covered: bits(2048) = if init then Zeros{2048}
        else _LocalGenerations[[slot]].covered_cells;
    for cell = 0 to 2047 do
        if cell < writer_cells then covered[offset_cells + cell] = '1'; end;
    end;
    for required = 0 to 2047 do
        if required < required_cells && covered[required] == '0' then return FALSE; end;
    end;
    return TRUE;
end;

readonly func BundleLocalGenerationReadinessComplete(
    slot: integer {0..63}, offset: Word, writer_size: integer {1..12},
    init: boolean, parent_size: integer {0..12}) => boolean
begin
    let raw_offset = UInt(offset);
    if raw_offset > 2047 then return FALSE; end;
    let offset_cells = raw_offset as integer {0..2047};
    let writer_cells = BundleLocalGenerationCellCount(writer_size);
    let required_cells = if init then
        BundleLocalGenerationCellCount(parent_size as integer {1..12})
        else _LocalGenerations[[slot]].parent_cell_count;
    var ready: bits(2048) = if init then Zeros{2048}
        else _LocalGenerations[[slot]].ready_cells;
    for cell = 0 to 2047 do
        if cell < writer_cells then ready[offset_cells + cell] = '1'; end;
    end;
    for required = 0 to 2047 do
        if required < required_cells && ready[required] == '0' then return FALSE; end;
    end;
    return TRUE;
end;

readonly func BundleLocalGenerationDescriptorMatches(
    slot: integer {0..63}, destination: TileIndex,
    participant_mask: bits(4)) => boolean
begin
    let expected = _LocalGenerations[[slot]].parent_descriptor;
    let actual = _Tiles[[destination]];
    return expected.valid && actual.allocated &&
           expected.object_name == destination &&
           expected.object_kind == actual.storage_kind &&
           expected.participant_mask == participant_mask &&
           actual.capacity_bytes == expected.capacity_bytes &&
           actual.rows == expected.rows && actual.columns == expected.columns &&
           actual.valid_rows == expected.valid_rows &&
           actual.valid_columns == expected.valid_columns &&
           actual.data_type == expected.data_type &&
           actual.predicate_basis_type == expected.predicate_basis_type &&
           actual.layout == expected.layout &&
           actual.location == expected.location &&
           actual.cube_k_repeat == expected.cube_k_repeat &&
           actual.cube_n_repeat == expected.cube_n_repeat &&
           actual.cube_cell_count == expected.cube_cell_count &&
           actual.cube_storage_bytes == expected.cube_storage_bytes &&
           _TileAllocationMasks[[destination]] == participant_mask;
end;

func ValidateBundleLocalGeneration() => boolean
begin
    // An open generation owns the architectural hand until LAST. A later
    // operation that omits B.ASSEMBLE must not replace, release, or rebind
    // that hand through the ordinary destination path.
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_assemble.valid then
            let hand = UInt(_BundleTileBindings[[binding]].destination_hand)
                as integer {0..3};
            if BundleLocalGenerationOpenForHand(hand) then
                SetFault(Fault_BundleControl, ReadTPC());
                return FALSE;
            end;
        end;
    end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_assemble.valid then
            let assemble = _BundleTileBindings[[binding]].destination_assemble;
            let hand = UInt(_BundleTileBindings[[binding]].destination_hand)
                as integer {0..3};
            let participant_mask = _BundleTileBindings[[binding]].pe_mask;
            let slot = BundleLocalGenerationSlot(hand, participant_mask);
            let writer_raw = _BundleTileBindings[[binding]].destination_size;
            if assemble.init && !_LocalGenerations[[slot]].open then
                // Capture the architectural INIT restart point before any
                // legality or allocation check can fault.
                _LocalGenerations[[slot]].init_tpc = ReadBPC();
                _LocalGenerations[[slot]].init_tpc_valid = TRUE;
            end;
            if !_BundleTileBindings[[binding]].destination_valid then
                SetBundleLocalGenerationFault(hand, participant_mask,
                    Fault_BundleControl); return FALSE;
            end;
            if writer_raw < 1 || writer_raw > 12 then
                SetBundleLocalGenerationFault(hand, participant_mask,
                    Fault_TileLegality); return FALSE;
            end;
            let writer_size = writer_raw as integer {1..12};
            if assemble.init && _LocalGenerations[[slot]].open then
                SetBundleLocalGenerationFault(hand, participant_mask,
                    Fault_BundleControl); return FALSE;
            end;
            if !assemble.init && (!_LocalGenerations[[slot]].open ||
                                  _LocalGenerations[[slot]].closed) then
                if BundleLocalGenerationOpenForDifferentMask(
                       hand, participant_mask) then
                    SetFault(Fault_TileLegality, ReadTPC());
                    return FALSE;
                end;
                SetBundleLocalGenerationFault(hand, participant_mask,
                    Fault_BundleControl); return FALSE;
            end;
            let raw_offset = UInt(assemble.offset);
            if raw_offset > 2047 then
                SetBundleLocalGenerationFault(hand, participant_mask,
                    Fault_TileLegality); return FALSE;
            end;
            let offset_cells = raw_offset as integer {0..2047};
            let writer_cells = BundleLocalGenerationCellCount(writer_size)
                as integer {1..2048};
            if assemble.init && (assemble.size_code < 1 ||
                                 assemble.size_code > 12) then
                SetBundleLocalGenerationFault(hand, participant_mask,
                    Fault_TileLegality); return FALSE;
            end;
            let parent_cells = if assemble.init then
                BundleLocalGenerationCellCount(assemble.size_code as integer {1..12})
                else _LocalGenerations[[slot]].parent_cell_count;
            if offset_cells + writer_cells > parent_cells then
                SetBundleLocalGenerationFault(hand, participant_mask,
                    Fault_TileLegality); return FALSE;
            end;
            let replay = BundleLocalGenerationReplay(
                slot, offset_cells, writer_cells, ReadBPC(),
                _BundleExecutionDomainToken);
            for prior = 0 to _LocalGenerations[[slot]].writer_count - 1
                looplimit 16 do
                if _LocalGenerations[[slot]].writers[[prior]].valid &&
                   BundleLocalGenerationRangeOverlaps(offset_cells, writer_cells,
                       _LocalGenerations[[slot]].writers[[prior]].offset_cells,
                       _LocalGenerations[[slot]].writers[[prior]].cell_count
                           as integer {1..2048}) && !replay then
                    SetBundleLocalGenerationFault(hand, participant_mask,
                        Fault_TileLegality); return FALSE;
                end;
            end;
            if assemble.last &&
               !BundleLocalGenerationCoverageComplete(
                    slot, assemble.offset, writer_size, assemble.init,
                    assemble.size_code) then
                SetBundleLocalGenerationFault(hand, participant_mask,
                    Fault_TileLegality); return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

func CommitBundleLocalGeneration()
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_assemble.valid then
            let assemble = _BundleTileBindings[[binding]].destination_assemble;
            let hand = UInt(_BundleTileBindings[[binding]].destination_hand)
                as integer {0..3};
            let participant_mask = _BundleTileBindings[[binding]].pe_mask;
            let slot = BundleLocalGenerationSlot(hand, participant_mask);
            let writer_size = _BundleTileBindings[[binding]].destination_size
                as integer {1..12};
            let offset_cells = UInt(assemble.offset) as integer {0..2047};
            let writer_cells = BundleLocalGenerationCellCount(writer_size)
                as integer {1..2048};
            if assemble.init then
                let prior_committed_destination =
                    _LocalGenerations[[slot]].committed_destination;
                let prior_committed_valid =
                    _LocalGenerations[[slot]].committed_valid;
                _LocalGenerations[[slot]].open = TRUE;
                _LocalGenerations[[slot]].closed = FALSE;
                _LocalGenerations[[slot]].published = FALSE;
                _LocalGenerations[[slot]].destination_hand = hand;
                _LocalGenerations[[slot]].participant_mask = participant_mask;
                _LocalGenerations[[slot]].generation_instance = ReadBPC();
                _LocalGenerations[[slot]].init_tpc = ReadBPC();
                _LocalGenerations[[slot]].init_tpc_valid = TRUE;
                _LocalGenerations[[slot]].working_destination =
                    _BundleTileBindings[[binding]].destination;
                _LocalGenerations[[slot]].committed_destination =
                    prior_committed_destination;
                _LocalGenerations[[slot]].committed_valid =
                    prior_committed_valid;
                _LocalGenerations[[slot]].published_destination =
                    prior_committed_destination;
                let destination = _BundleTileBindings[[binding]].destination;
                _LocalGenerations[[slot]].parent_descriptor.valid = TRUE;
                _LocalGenerations[[slot]].parent_descriptor.object_name = destination;
                _LocalGenerations[[slot]].parent_descriptor.object_kind =
                    _Tiles[[destination]].storage_kind;
                _LocalGenerations[[slot]].parent_descriptor.participant_mask = participant_mask;
                _LocalGenerations[[slot]].parent_descriptor.capacity_bytes = _Tiles[[destination]].capacity_bytes;
                _LocalGenerations[[slot]].parent_descriptor.rows = _Tiles[[destination]].rows;
                _LocalGenerations[[slot]].parent_descriptor.columns = _Tiles[[destination]].columns;
                _LocalGenerations[[slot]].parent_descriptor.valid_rows = _Tiles[[destination]].valid_rows;
                _LocalGenerations[[slot]].parent_descriptor.valid_columns = _Tiles[[destination]].valid_columns;
                _LocalGenerations[[slot]].parent_descriptor.data_type = _Tiles[[destination]].data_type;
                _LocalGenerations[[slot]].parent_descriptor.predicate_basis_type =
                    _Tiles[[destination]].predicate_basis_type;
                _LocalGenerations[[slot]].parent_descriptor.layout = _Tiles[[destination]].layout;
                _LocalGenerations[[slot]].parent_descriptor.location = _Tiles[[destination]].location;
                _LocalGenerations[[slot]].parent_descriptor.cube_k_repeat = _Tiles[[destination]].cube_k_repeat;
                _LocalGenerations[[slot]].parent_descriptor.cube_n_repeat = _Tiles[[destination]].cube_n_repeat;
                _LocalGenerations[[slot]].parent_descriptor.cube_cell_count = _Tiles[[destination]].cube_cell_count;
                _LocalGenerations[[slot]].parent_descriptor.cube_storage_bytes = _Tiles[[destination]].cube_storage_bytes;
                _LocalGenerations[[slot]].parent_size_code = assemble.size_code;
                _LocalGenerations[[slot]].parent_cell_count = BundleLocalGenerationCellCount(assemble.size_code as integer {1..12});
                _LocalGenerations[[slot]].covered_cells = Zeros{2048};
                _LocalGenerations[[slot]].ready_cells = Zeros{2048};
                _LocalGenerations[[slot]].writer_count = 0;
                _LocalGenerations[[slot]].consumer_count = 0;
            end;
            var covered_cells: bits(2048) =
                _LocalGenerations[[slot]].covered_cells;
            var ready_cells: bits(2048) = _LocalGenerations[[slot]].ready_cells;
            let replay = BundleLocalGenerationReplay(
                slot, offset_cells, writer_cells, ReadBPC(),
                _BundleExecutionDomainToken);
            if !replay then
                // The fixed record array is a verification bound, not an ISA
                // writer-count limit.  Architecturally legal executions are
                // modeled only while the bounded witness has a free record.
                assert _LocalGenerations[[slot]].writer_count < 16;
                let ordinal = _LocalGenerations[[slot]].writer_count;
                _LocalGenerations[[slot]].writers[[ordinal]].valid = TRUE;
                _LocalGenerations[[slot]].writers[[ordinal]].offset_cells = offset_cells;
                _LocalGenerations[[slot]].writers[[ordinal]].cell_count = writer_cells;
                _LocalGenerations[[slot]].writers[[ordinal]].destination = _BundleTileBindings[[binding]].destination;
                // Registration contributes coverage only.  Completion is a
                // separate architecture event so OoO readiness cannot be
                // confused with writer-set closure.
                _LocalGenerations[[slot]].writers[[ordinal]].ready = FALSE;
                _LocalGenerations[[slot]].writers[[ordinal]].identity
                    .instruction_instance = ReadBPC();
                _LocalGenerations[[slot]].writers[[ordinal]].identity
                    .execution_domain_token = _BundleExecutionDomainToken;
                _LocalGenerations[[slot]].writer_count = (ordinal + 1) as integer {0..16};
                for cell = 0 to 2047 do
                    if cell < writer_cells then
                        let covered_index = (offset_cells + cell)
                            as integer {0..2047};
                        covered_cells[covered_index] = '1';
                    end;
                end;
            end;
            _LocalGenerations[[slot]].covered_cells = covered_cells;
            _LocalGenerations[[slot]].ready_cells = ready_cells;
            if assemble.last then
                _LocalGenerations[[slot]].last_seen = TRUE;
                _LocalGenerations[[slot]].closed = TRUE;
                if BundleLocalGenerationPublicationEligible(slot) then
                    _LocalGenerations[[slot]].open = FALSE;
                    _LocalGenerations[[slot]].published = TRUE;
                    _LocalGenerations[[slot]].published_destination =
                        _BundleTileBindings[[binding]].destination;
                    _LocalGenerations[[slot]].committed_destination =
                        _BundleTileBindings[[binding]].destination;
                    _LocalGenerations[[slot]].committed_valid = TRUE;
                else
                    // LAST closes the writer set, but an incomplete ready set
                    // remains pending. No mapping or payload is exposed until
                    // the portable publication predicate becomes true.
                    _LocalGenerations[[slot]].open = FALSE;
                    _LocalGenerations[[slot]].published = FALSE;
                end;
            end;
        end;
    end;
end;

func ReuseBundleLocalGenerationDestination() => boolean
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_assemble.valid then
            let assemble = _BundleTileBindings[[binding]].destination_assemble;
            let hand = UInt(_BundleTileBindings[[binding]].destination_hand)
                as integer {0..3};
            let participant_mask = _BundleTileBindings[[binding]].pe_mask;
            let slot = BundleLocalGenerationSlot(hand, participant_mask);
            if !assemble.init then
                if !_LocalGenerations[[slot]].open then
                    SetBundleLocalGenerationFault(hand, participant_mask,
                        Fault_BundleControl); return FALSE;
                end;
                let destination = _LocalGenerations[[slot]].working_destination;
                if !_Tiles[[destination]].allocated ||
                   !BundleLocalGenerationDescriptorMatches(
                       slot, destination, participant_mask) then
                    SetBundleLocalGenerationFault(hand, participant_mask,
                        Fault_TileLegality); return FALSE;
                end;
                _BundleTileBindings[[binding]].destination = destination;
                _BundleTileBindings[[binding]].destination_allocated_by_bundle = TRUE;
                _BundleTileBindings[[binding]].destination_reused_by_generation = TRUE;
            end;
        end;
    end;
    return TRUE;
end;
