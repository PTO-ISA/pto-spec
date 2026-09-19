<!-- GENERATED FROM: asl/block/model/operands/local-generation.asl -->
# Local Generation

**Normative ASL source:** `asl/block/model/operands/local-generation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/local-generation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION","surface":"block","classification":["model","operands","local-generation"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS","PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE"]}
// NDF-BEGIN: PTO-B-ASSEMBLE-LOCAL-GENERATION-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A Local generation is one logical entry in the ordinary T/U/M/N relative queue; INIT owns per-PE instances; continuations resolve one entry and subset writers.
// INIT allocates before effects; MIDDLE/LAST reuses it. Coverage, readiness, closure, publication, replay, waiting, abort, and explicit no-fallback selectors follow the per-PE contract; Shared Sx is unchanged.
// NDF-END: PTO-B-ASSEMBLE-LOCAL-GENERATION-001

// NDF-BEGIN: PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001
// ndf: kind=contract level=L1 layer=block status=accepted
// For Local CUBE_M16 and CUBE_M32 B.ASSEMBLE generations, ParentCapacity is allocation metadata only. Each writer retains its fragment descriptor. A successful LAST derives one common parent physical/valid descriptor from the participating PEs' gap-free CELL prefix coverage, and atomically publishes that final descriptor. Capacity slack never creates parent rows, columns, repeats, or CELLs. ParentRef selects the open generation by generation identity and does not require the aggregate descriptor to be finalized before LAST.
// Generation structure is preflighted before destination resolution. The exact materialized writer descriptor is validated after destination shape/allocation or reuse and before producer effects, coverage registration, LAST closure, or parent finalization.
// NDF-END: PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001
pure func BundleLocalGenerationQueueSlot(hand: integer {0..3}, distance: integer {0..15}) => integer {0..63}
begin
    return (hand * 16 + distance) as integer {0..63};
end;
readonly func BundleLocalGenerationSlotForDestination(destination: TileIndex) => integer {0..64}
begin
    for slot = 0 to 63 do
        if _LocalGenerations[[slot]].generation_identity_valid &&
           _LocalGenerations[[slot]].working_destination == destination then
            return slot;
        end;
    end;
    return 64;
end;
readonly func BundleLocalGenerationSlot(hand: integer {0..3}, participant_mask: bits(4))
    => integer {0..63}
begin
    for slot = hand * 16 to hand * 16 + 15 do
        if _LocalGenerations[[slot]].generation_identity_valid &&
           _LocalGenerations[[slot]].participant_mask == participant_mask then
            return slot as integer {0..63};
        end;
    end;
    return (hand + UInt(participant_mask) * 4) as integer {0..63};
end;
readonly func BundleLocalGenerationOpenForHand(
    hand: integer {0..3}) => boolean
begin
    for slot = hand * 16 to hand * 16 + 15 do
        if _LocalGenerations[[slot]].generation_identity_valid &&
           _LocalGenerations[[slot]].open then
            return TRUE;
        end;
    end;
    return FALSE;
end;
readonly func BundleLocalGenerationQueueInsertionLegal(
    hand: integer {0..3}) => boolean
begin
    if _TileRelativeValid[[hand]][15] == '0' then return TRUE; end;
    let evicted = _TileRelativeOrder[[hand]][[15]];
    let slot = BundleLocalGenerationSlotForDestination(evicted);
    if slot == 64 then return TRUE; end;
    return _LocalGenerations[[slot]].published ||
           (!_LocalGenerations[[slot]].open &&
            !_LocalGenerations[[slot]].closed &&
            _LocalGenerations[[slot]].consumer_count == 0);
end;
func ClearBundleLocalGenerationState(slot: integer {0..63})
begin
    _LocalGenerations[[slot]].open = FALSE;
    _LocalGenerations[[slot]].closed = FALSE;
    _LocalGenerations[[slot]].published = FALSE;
    _LocalGenerations[[slot]].generation_identity_valid = FALSE;
    _LocalGenerations[[slot]].descriptor_finalized = FALSE;
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
    _LocalGenerations[[slot]].parent_descriptor.predicate_basis_type = TileDataType_FP64;
    _LocalGenerations[[slot]].parent_descriptor.layout = TileLayout_RowMajor;
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
    for pe = 0 to 3 do
        _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = Zeros{2048}; _LocalGenerations[[slot]].per_pe_ready_cells[[pe]] = Zeros{2048}; _LocalGenerations[[slot]].per_pe_closed[[pe]] = FALSE; _LocalGenerations[[slot]].per_pe_published[[pe]] = FALSE; _LocalGenerations[[slot]].per_pe_working_destination[[pe]] = 0;
    end;
    for writer = 0 to 15 do
        _LocalGenerations[[slot]].writers[[writer]].valid = FALSE; _LocalGenerations[[slot]].writers[[writer]].pe_mask = Zeros{4}; _LocalGenerations[[slot]].writers[[writer]].ready = FALSE;
        _LocalGenerations[[slot]].writers[[writer]].physical_rows = 0; _LocalGenerations[[slot]].writers[[writer]].physical_columns = 0;
        _LocalGenerations[[slot]].writers[[writer]].valid_rows = 0; _LocalGenerations[[slot]].writers[[writer]].valid_columns = 0;
        _LocalGenerations[[slot]].writers[[writer]].data_type = TileDataType_FP64;
        _LocalGenerations[[slot]].writers[[writer]].predicate_basis_type = TileDataType_FP64;
        _LocalGenerations[[slot]].writers[[writer]].layout = TileLayout_RowMajor;
    end;
    for consumer = 0 to 15 do _LocalGenerations[[slot]].consumers[[consumer]].valid = FALSE; _LocalGenerations[[slot]].consumers[[consumer]].participant_mask = Zeros{4}; end;
end;
func AbortBundleLocalGeneration(slot: integer {0..63})
begin
    let committed_destination =
        _LocalGenerations[[slot]].committed_destination;
    let committed_valid = _LocalGenerations[[slot]].committed_valid;
    if _LocalGenerations[[slot]].open ||
       (_LocalGenerations[[slot]].closed &&
        !_LocalGenerations[[slot]].published) then
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
            let selected = if !_BundleTileBindings[[binding]].destination_assemble.init && _BundleTileBindings[[binding]].parent_ref_valid then BundleLocalGenerationSlotForDestination(_BundleTileBindings[[binding]].parent_ref) else BundleLocalGenerationSlotForDestination(_BundleTileBindings[[binding]].destination);
            if selected != 64 then
                AbortBundleLocalGeneration(selected as integer {0..63});
            end;
        end;
    end;
end;
func SetBundleLocalGenerationFault(slot: integer {0..63},
                                   fault: FaultCode)
begin
    let restart_tpc = _LocalGenerations[[slot]].init_tpc;
    let restart_valid = _LocalGenerations[[slot]].init_tpc_valid;
    AbortBundleLocalGeneration(slot);
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
        assert _BundleTileBindings[[binding]].destination_size >= 1 && _BundleTileBindings[[binding]].destination_size <= 10;
        return TileSizeCodeBytes(
            _BundleTileBindings[[binding]].destination_size as integer {1..12});
    end;
    return BundleTileDestinationSizeBytes(binding);
end;
func ValidateBundleLocalGenerationStructure() => boolean
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_assemble.valid then
            let assemble = _BundleTileBindings[[binding]].destination_assemble;
            let hand = UInt(_BundleTileBindings[[binding]].destination_hand)
                as integer {0..3};
            let writer_mask = _BundleTileBindings[[binding]].pe_mask;
            let writer_raw = assemble.size_code;
            if writer_raw < 1 || writer_raw > 10 then
                SetFault(Fault_TileLegality, ReadTPC()); return FALSE;
            end;
            let writer_size = writer_raw as integer {1..12};
            if assemble.init then
                if !_BundleTileBindings[[binding]].destination_valid || _BundleTileBindings[[binding]].parent_ref_valid then
                    SetFault(Fault_BundleControl, ReadTPC()); return FALSE;
                end;
                if !BundleLocalGenerationQueueInsertionLegal(hand) then
                    SetBundleLocalGenerationInitFault(Fault_TileAllocation); return FALSE;
                end;
                let parent_size = _BundleTileBindings[[binding]].destination_size;
                if parent_size < 1 || parent_size > 10 then
                    SetBundleLocalGenerationInitFault(Fault_TileLegality); return FALSE;
                end;
                let parent_cells = BundleLocalGenerationCellCount(parent_size as integer {1..12});
                let raw_offset = UInt(assemble.offset);
                let writer_cells = BundleLocalGenerationCellCount(writer_size) as integer {1..2048};
                if raw_offset > 2047 || raw_offset + writer_cells > parent_cells then
                    SetBundleLocalGenerationInitFault(Fault_TileLegality); return FALSE;
                end;
            else
                if _BundleTileBindings[[binding]].destination_valid ||
                   !_BundleTileBindings[[binding]].parent_ref_valid ||
                   _BundleTileBindings[[binding]].parent_ref_relative then
                    SetFault(Fault_BundleControl, ReadTPC()); return FALSE;
                end;
                let parent = _BundleTileBindings[[binding]].parent_ref;
                let slot = BundleLocalGenerationSlotForDestination(parent);
                if slot == 64 then
                    SetFault(Fault_TileLegality, ReadTPC()); return FALSE;
                end;
                let generation_slot = slot as integer {0..63};
                if !_LocalGenerations[[generation_slot]].open ||
                   _LocalGenerations[[generation_slot]].closed then
                    SetBundleLocalGenerationFault(generation_slot,
                        Fault_TileLegality); return FALSE;
                end;
                if !BundleLocalGenerationMaskSubset(writer_mask,
                       _LocalGenerations[[generation_slot]].participant_mask) then
                    SetBundleLocalGenerationFault(generation_slot,
                        Fault_TileLegality); return FALSE;
                end;
                let raw_offset = UInt(assemble.offset);
                if raw_offset > 2047 then
                    SetBundleLocalGenerationFault(generation_slot,
                        Fault_TileLegality); return FALSE;
                end;
                let offset_cells = raw_offset as integer {0..2047};
                let writer_cells = BundleLocalGenerationCellCount(writer_size)
                    as integer {1..2048};
                if offset_cells + writer_cells >
                   _LocalGenerations[[generation_slot]].parent_cell_count then
                    SetBundleLocalGenerationFault(generation_slot,
                        Fault_TileLegality); return FALSE;
                end;
                let replay = BundleLocalGenerationReplay(
                    generation_slot, offset_cells, writer_cells, ReadBPC(),
                    _BundleExecutionDomainToken);
                for prior = 0 to _LocalGenerations[[generation_slot]].writer_count - 1
                    looplimit 16 do
                    var pe_overlap = FALSE;
                    for pe = 0 to 3 do
                        if writer_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' &&
                           _LocalGenerations[[generation_slot]].writers[[prior]].pe_mask[
                               PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                            pe_overlap = TRUE;
                        end;
                    end;
                    if _LocalGenerations[[generation_slot]].writers[[prior]].valid &&
                       pe_overlap &&
                       BundleLocalGenerationRangeOverlaps(
                           offset_cells, writer_cells,
                           _LocalGenerations[[generation_slot]].writers[[prior]].offset_cells,
                           _LocalGenerations[[generation_slot]].writers[[prior]].cell_count
                               as integer {1..2048}) && !replay then
                        SetBundleLocalGenerationFault(generation_slot,
                            Fault_TileLegality); return FALSE;
                    end;
                end;
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
            let destination = _BundleTileBindings[[binding]].destination;
            let hand = UInt(_BundleTileBindings[[binding]].destination_hand)
                as integer {0..3};
            let participant_mask = _BundleTileBindings[[binding]].pe_mask;
            let slot = (if assemble.init then destination as integer {0..63}
                else BundleLocalGenerationSlotForDestination(destination)) as integer {0..63};
            let writer_size = assemble.size_code as integer {1..12};
            let offset_cells = UInt(assemble.offset) as integer {0..2047};
            let writer_cells = BundleLocalGenerationCellCount(writer_size)
                as integer {1..2048};
            if assemble.init then
                ClearBundleLocalGenerationState(slot);
                _LocalGenerations[[slot]].open = TRUE;
                _LocalGenerations[[slot]].closed = FALSE;
                _LocalGenerations[[slot]].published = FALSE;
                _LocalGenerations[[slot]].generation_identity_valid = TRUE;
                _LocalGenerations[[slot]].descriptor_finalized =
                    !BundleLocalGenerationCubeLayout(
                        _Tiles[[destination]].layout);
                _LocalGenerations[[slot]].destination_hand = hand;
                _LocalGenerations[[slot]].participant_mask = participant_mask;
                _LocalGenerations[[slot]].generation_instance = ReadBPC();
                _LocalGenerations[[slot]].init_tpc = ReadBPC();
                _LocalGenerations[[slot]].init_tpc_valid = TRUE;
                _LocalGenerations[[slot]].working_destination = destination;
                _LocalGenerations[[slot]].parent_descriptor.valid = TRUE;
                _LocalGenerations[[slot]].parent_descriptor.object_name = destination;
                _LocalGenerations[[slot]].parent_descriptor.object_kind = _Tiles[[destination]].storage_kind;
                _LocalGenerations[[slot]].parent_descriptor.participant_mask = participant_mask;
                _LocalGenerations[[slot]].parent_descriptor.capacity_bytes = _Tiles[[destination]].capacity_bytes;
                _LocalGenerations[[slot]].parent_descriptor.rows = _Tiles[[destination]].rows;
                _LocalGenerations[[slot]].parent_descriptor.columns = _Tiles[[destination]].columns;
                _LocalGenerations[[slot]].parent_descriptor.valid_rows = _Tiles[[destination]].valid_rows;
                _LocalGenerations[[slot]].parent_descriptor.valid_columns = _Tiles[[destination]].valid_columns;
                _LocalGenerations[[slot]].parent_descriptor.data_type = _Tiles[[destination]].data_type;
                _LocalGenerations[[slot]].parent_descriptor.predicate_basis_type = _Tiles[[destination]].predicate_basis_type;
                _LocalGenerations[[slot]].parent_descriptor.layout = _Tiles[[destination]].layout;
                _LocalGenerations[[slot]].parent_descriptor.cube_k_repeat = _Tiles[[destination]].cube_k_repeat;
                _LocalGenerations[[slot]].parent_descriptor.cube_n_repeat = _Tiles[[destination]].cube_n_repeat;
                _LocalGenerations[[slot]].parent_descriptor.cube_cell_count = _Tiles[[destination]].cube_cell_count;
                _LocalGenerations[[slot]].parent_descriptor.cube_storage_bytes = _Tiles[[destination]].cube_storage_bytes;
                _LocalGenerations[[slot]].parent_size_code = _BundleTileBindings[[binding]].destination_size as integer {1..12};
                _LocalGenerations[[slot]].parent_cell_count = BundleLocalGenerationCellCount(_BundleTileBindings[[binding]].destination_size as integer {1..12});
                _LocalGenerations[[slot]].covered_cells = Zeros{2048};
                _LocalGenerations[[slot]].ready_cells = Zeros{2048};
                _LocalGenerations[[slot]].writer_count = 0;
                _LocalGenerations[[slot]].consumer_count = 0;
                for pe = 0 to 3 do if participant_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then _LocalGenerations[[slot]].per_pe_working_destination[[pe]] = destination; end; end;
                PublishRelativeTileDestination(destination);
            end;
            var covered_cells: bits(2048) = _LocalGenerations[[slot]].covered_cells;
            var ready_cells: bits(2048) = _LocalGenerations[[slot]].ready_cells;
            let replay = BundleLocalGenerationReplay(
                slot, offset_cells, writer_cells, ReadBPC(),
                _BundleExecutionDomainToken);
            if !replay then
                assert _LocalGenerations[[slot]].writer_count < 16;
                let ordinal = _LocalGenerations[[slot]].writer_count;
                _LocalGenerations[[slot]].writers[[ordinal]].valid = TRUE;
                _LocalGenerations[[slot]].writers[[ordinal]].offset_cells = offset_cells;
                _LocalGenerations[[slot]].writers[[ordinal]].cell_count = writer_cells;
                _LocalGenerations[[slot]].writers[[ordinal]].destination = destination;
                _LocalGenerations[[slot]].writers[[ordinal]].pe_mask = participant_mask;
                _LocalGenerations[[slot]].writers[[ordinal]].ready = FALSE;
                _LocalGenerations[[slot]].writers[[ordinal]].physical_rows =
                    _Tiles[[destination]].rows;
                _LocalGenerations[[slot]].writers[[ordinal]].physical_columns =
                    _Tiles[[destination]].columns;
                _LocalGenerations[[slot]].writers[[ordinal]].valid_rows =
                    _Tiles[[destination]].valid_rows;
                _LocalGenerations[[slot]].writers[[ordinal]].valid_columns =
                    _Tiles[[destination]].valid_columns;
                _LocalGenerations[[slot]].writers[[ordinal]].data_type =
                    _Tiles[[destination]].data_type;
                _LocalGenerations[[slot]].writers[[ordinal]].predicate_basis_type =
                    _Tiles[[destination]].predicate_basis_type;
                _LocalGenerations[[slot]].writers[[ordinal]].layout =
                    _Tiles[[destination]].layout;
                _LocalGenerations[[slot]].writers[[ordinal]].identity.instruction_instance = ReadBPC();
                _LocalGenerations[[slot]].writers[[ordinal]].identity.execution_domain_token = _BundleExecutionDomainToken;
                _LocalGenerations[[slot]].writer_count = (ordinal + 1) as integer {0..16};
                for cell = 0 to 2047 do
                    if cell < writer_cells then
                        let covered_index = (offset_cells + cell) as integer {0..2047};
                        covered_cells[covered_index] = '1';
                        for pe = 0 to 3 do
                            if participant_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                                var pe_covered = _LocalGenerations[[slot]].per_pe_covered_cells[[pe]];
                                pe_covered[covered_index] = '1';
                                _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = pe_covered;
                            end;
                        end;
                    end;
                end;
            end;
            _LocalGenerations[[slot]].covered_cells = covered_cells;
            _LocalGenerations[[slot]].ready_cells = ready_cells;
            if assemble.last &&
               BundleLocalGenerationCubeLayout(
                   _Tiles[[destination]].layout) then
                FinalizeBundleLocalGenerationCube(slot);
            end;
            if assemble.last then
                let generation_participant_mask =
                    _LocalGenerations[[slot]].participant_mask;
                _LocalGenerations[[slot]].last_seen = TRUE;
                _LocalGenerations[[slot]].closed = TRUE;
                _LocalGenerations[[slot]].open = FALSE;
                for pe = 0 to 3 do if generation_participant_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then _LocalGenerations[[slot]].per_pe_closed[[pe]] = TRUE; end; end;
                for pe = 0 to 3 do if BundleLocalGenerationPEPublicationEligible(slot, pe) then _LocalGenerations[[slot]].per_pe_published[[pe]] = TRUE; end; end;
                if BundleLocalGenerationPublicationEligible(slot) then
                    _LocalGenerations[[slot]].open = FALSE;
                    _LocalGenerations[[slot]].published = TRUE;
                    _LocalGenerations[[slot]].published_destination =
                        _LocalGenerations[[slot]].working_destination;
                    _LocalGenerations[[slot]].committed_destination =
                        _LocalGenerations[[slot]].working_destination;
                    _LocalGenerations[[slot]].committed_valid = TRUE;
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
            if !assemble.init then
                if _BundleTileBindings[[binding]].destination_valid ||
                   !_BundleTileBindings[[binding]].parent_ref_valid then
                    SetFault(Fault_BundleControl, ReadTPC()); return FALSE;
                end;
                let selected = _BundleTileBindings[[binding]].parent_ref;
                let slot = BundleLocalGenerationSlotForDestination(selected);
                if slot == 64 then
                    SetFault(Fault_TileLegality, ReadTPC()); return FALSE;
                end;
                let generation_slot = slot as integer {0..63};
                let destination = _LocalGenerations[[generation_slot]].working_destination;
                if !_LocalGenerations[[generation_slot]].open ||
                   _LocalGenerations[[generation_slot]].closed ||
                   !_Tiles[[destination]].allocated ||
                   !BundleLocalGenerationDescriptorMatches(
                       generation_slot, destination,
                       _BundleTileBindings[[binding]].pe_mask) then
                    SetBundleLocalGenerationFault(generation_slot,
                        Fault_TileLegality); return FALSE;
                end;
                BindBundleLocalGenerationDestination(
                    binding as BundleTileBindingIndex,
                    generation_slot, selected);
            end;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
