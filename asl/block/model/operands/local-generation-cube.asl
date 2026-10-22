// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE","surface":"block","classification":["model","operands","local-generation-cube"],"depends_on":["PTO-BLOCK-MODEL-STATE-TYPES","PTO-TILE-MODEL-SHAPE-CUBE-CELL","PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE"]}
// A resolved writer plan is an ordinary value passed along the current
// instruction path. It keeps the allocated parent descriptor and the exact
// operation-specific writer descriptor together without installing a view in
// architectural tile state.
type BundleLocalGenerationCubeWriterEffectEntry of record {
    active: boolean,
    destination: TileIndex,
    offset_cells: integer {0..2047},
    cell_count: integer {0..2048},
    size_code: integer {0..12},
    pe_mask: bits(4),
    parent: TileInfo,
    writer: TileInfo
};

type BundleLocalGenerationCubeWriterEffects of record {
    count: integer {0..PTO_BUNDLE_TILE_BINDING_COUNT},
    entries: array [[PTO_BUNDLE_TILE_BINDING_COUNT]]
        of BundleLocalGenerationCubeWriterEffectEntry
};

func EmptyBundleLocalGenerationCubeWriterEffects()
    => BundleLocalGenerationCubeWriterEffects
begin
    var effects: BundleLocalGenerationCubeWriterEffects;
    effects.count = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        effects.entries[[binding]].active = FALSE;
    end;
    return effects;
end;


pure func BundleLocalGenerationCubeLayout(layout: TileLayout) => boolean
begin
    return layout == TileLayout_CUBE_M16 || layout == TileLayout_CUBE_M32;
end;

readonly func BundleLocalGenerationPrefixExtent(
    covered: bits(2048)) => integer {0..2048}
begin
    var extent: integer {0..2048} = 0;
    var gap = FALSE;
    for cell = 0 to 2047 do
        if covered[cell] == '1' then
            if gap then return 0; end;
            extent = (extent + 1) as integer {0..2048};
        elsif extent != 0 then
            gap = TRUE;
        end;
    end;
    return extent;
end;

readonly func BundleLocalGenerationCubeCandidateExtent(
    slot: integer {0..63}, offset_cells: integer {0..2047},
    writer_cells: integer {1..2048}, writer_mask: bits(4),
    pe: integer {0..3}, init: boolean) => integer {0..2048}
begin
    if offset_cells + writer_cells > 2048 then return 0; end;
    var covered: bits(2048) = if init then Zeros{2048}
        else _LocalGenerations[[slot]].per_pe_covered_cells[[pe]];
    if writer_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
        for cell = 0 to 2047 do
            if cell < writer_cells then
                covered[offset_cells + cell] = '1';
            end;
        end;
    end;
    return BundleLocalGenerationPrefixExtent(covered);
end;

readonly func BundleLocalGenerationCubeCurrentValidRows() => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(BundleDimension_LB1);
    let raw = UInt(_BundleDimensions[[index]]);
    return if raw <= 65535 then raw as integer {0..65535} else 0;
end;
readonly func BundleLocalGenerationCubeCurrentValidColumns() => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(BundleDimension_LB0);
    let raw = UInt(_BundleDimensions[[index]]);
    return if raw <= 65535 then raw as integer {0..65535} else 0;
end;
readonly func BundleLocalGenerationCubeWriterColumns(writer_size: integer {1..12}, layout: TileLayout, data_type: TileDataType) => integer {0..65535}
begin
    return TileCubePhysicalColumnsFromCapacity(
        TileSizeCodeBytes(writer_size), layout, data_type);
end;

pure func BundleLocalGenerationCubeValidColumnsAt(
    offset_cells: integer {0..2047}, cell_columns: integer {0,1,2,4,8,16},
    cells_per_group: integer {1..2},
    fragment_valid_columns: integer {0..65535}) => integer {0..65535}
begin
    if offset_cells MOD cells_per_group != 0 then return 0; end;
    let derived = (offset_cells DIVRM cells_per_group) * cell_columns +
        fragment_valid_columns;
    if derived > 65535 then return 0; end;
    return derived as integer {0..65535};
end;

readonly func BundleLocalGenerationCubeWriterLegal(
    destination: TileIndex, writer_size: integer {1..12}) => boolean
begin
    let tile = _Tiles[[destination]];
    let writer_cells = (TileSizeCodeBytes(writer_size) DIVRM PTO_TILE_CELL_BYTES) as integer {1..2048};
    let expected_rows = if tile.layout == TileLayout_CUBE_M16 then 16 else 32;
    let writer_columns = BundleLocalGenerationCubeWriterColumns(
        writer_size, tile.layout, tile.data_type);
    let writer_valid_rows = BundleLocalGenerationCubeCurrentValidRows();
    let writer_valid_columns =
        BundleLocalGenerationCubeCurrentValidColumns();
    return tile.allocated && tile.storage_kind == TileStorage_Numeric &&
           BundleLocalGenerationCubeLayout(tile.layout) &&
           tile.rows == expected_rows && tile.valid_rows <= tile.rows &&
           tile.valid_rows != 0 && tile.valid_columns <= tile.columns &&
           tile.valid_columns != 0 &&
           TileCubeDescriptorLegal(tile) &&
           tile.capacity_bytes >= TileSizeCodeBytes(writer_size) &&
           writer_columns != 0 &&
           TileCubeDescriptorShapeAndPhysicalLegal(
               TileSizeCodeBytes(writer_size), expected_rows,
               writer_columns, writer_valid_rows, writer_valid_columns,
               tile.data_type, tile.layout) &&
           TileCubePhysicalCellCount(tile.layout, expected_rows,
               writer_columns, tile.data_type) == writer_cells &&
           TileCubePhysicalRequiredBytes(tile.layout, expected_rows,
               writer_columns, tile.data_type) ==
                   TileSizeCodeBytes(writer_size);
end;



readonly func BundleLocalGenerationCubeFinalExtent(
    slot: integer {0..63}) => integer {0..2048}
begin
    var common_extent: integer {0..2048} = 0;
    var set = FALSE;
    for pe = 0 to 3 do
        if _LocalGenerations[[slot]].participant_mask[
               PTOPEMaskBitOfPEIdentity(pe)] == '1' then
            let extent = BundleLocalGenerationPrefixExtent(
                _LocalGenerations[[slot]].per_pe_covered_cells[[pe]]);
            if !set then
                common_extent = extent;
                set = TRUE;
            elsif extent != common_extent then
                return 0;
            end;
        end;
    end;
    return if set then common_extent else 0;
end;
readonly func BundleLocalGenerationCubeFinalValidColumns(
    slot: integer {0..63}, extent: integer {1..2048}) => integer {0..65535}
begin
    let first = _LocalGenerations[[slot]].writers[[0]];
    let cell_columns = TileCubeCellColumns(first.layout, first.data_type);
    let cells_per_group = TileCubePhysicalCellsPerLogicalGroup(
        first.layout, first.data_type);
    if extent MOD cells_per_group != 0 then return 0; end;
    var selected_pe: integer {0..3} = 0;
    var pe_found = FALSE;
    for pe = 0 to 3 do
        if !pe_found && _LocalGenerations[[slot]].participant_mask[
               PTOPEMaskBitOfPEIdentity(pe)] == '1' then
            selected_pe = pe as integer {0..3};
            pe_found = TRUE;
        end;
    end;
    if !pe_found then return 0; end;
    var valid_columns: integer {0..65535} = 0;
    var found = FALSE;
    for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
        looplimit 16 do
        let current = _LocalGenerations[[slot]].writers[[writer]];
        if current.valid && current.pe_mask[
               PTOPEMaskBitOfPEIdentity(selected_pe)] == '1' &&
           current.offset_cells + current.cell_count == extent then
            if found then return 0; end;
            found = TRUE;
            valid_columns = BundleLocalGenerationCubeValidColumnsAt(
                current.offset_cells, cell_columns, cells_per_group,
                current.valid_columns);
            if valid_columns == 0 then return 0; end;
        end;
    end;
    return if found then valid_columns else 0;
end;
readonly func BundleLocalGenerationCoverageComplete(
    slot: integer {0..63}, offset: Word, writer_size: integer {1..12},
    writer_mask: bits(4), init: boolean,
    parent_size: integer {0..12}) => boolean
begin
    let raw_offset = UInt(offset);
    if raw_offset > 2047 then return FALSE; end;
    let offset_cells = raw_offset as integer {0..2047};
    let writer_cells = (TileSizeCodeBytes(writer_size) DIVRM PTO_TILE_CELL_BYTES) as integer {1..2048};
    let required_cells = if init then
        (TileSizeCodeBytes(parent_size as integer {1..12}) DIVRM PTO_TILE_CELL_BYTES) as integer {1..2048}
        else _LocalGenerations[[slot]].parent_cell_count;
    let participant_mask = if init then writer_mask
        else _LocalGenerations[[slot]].participant_mask;
    for pe = 0 to 3 do
        if participant_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
            var covered: bits(2048) = if init then Zeros{2048}
                else _LocalGenerations[[slot]].per_pe_covered_cells[[pe]];
            if writer_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                for cell = 0 to 2047 do
                    if cell < writer_cells then
                        covered[offset_cells + cell] = '1';
                    end;
                end;
            end;
            for required = 0 to 2047 do
                if required < required_cells && covered[required] == '0' then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;
readonly func BundleLocalGenerationMaskSubset(writer_mask: bits(4), init_mask: bits(4)) => boolean
begin
    for pe = 0 to 3 do if writer_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' && init_mask[PTOPEMaskBitOfPEIdentity(pe)] == '0' then return FALSE; end; end;
    return TRUE;
end;

pure func BundleLocalGenerationRangeOverlaps(
    left_offset: integer {0..2047}, left_count: integer {1..2048},
    right_offset: integer {0..2047}, right_count: integer {1..2048}) => boolean
begin
    return left_offset < right_offset + right_count &&
           right_offset < left_offset + left_count;
end;
func SetBundleLocalGenerationInitFault(fault: FaultCode)
begin
    SetFault(fault, ReadTPC()); let ring = CurrentACR();
    if _TrapContexts[[ring]].valid then _TrapContexts[[ring]].tpc = ReadBPC(); end;
end;

// Destination shape, allocation, and generation reuse are resolved before
// this check. Writer descriptor legality therefore observes the exact Tile
// that the producer would update, while still preceding producer effects,
// coverage updates, LAST closure, and parent-descriptor finalization.
func ValidateBundleLocalGenerationWritersWithWriterEffects(
    writer_effects: BundleLocalGenerationCubeWriterEffects) => boolean
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_assemble.valid then
            let assemble = _BundleTileBindings[[binding]].destination_assemble;
            let destination = _BundleTileBindings[[binding]].destination;
            let writer_mask = _BundleTileBindings[[binding]].pe_mask;
            let writer_size = assemble.size_code as integer {1..12};
            let offset_cells = UInt(assemble.offset) as integer {0..2047};
            let writer_cells = BundleLocalGenerationCellCount(writer_size)
                as integer {1..2048};
            var writer_effect_found = FALSE;
            var writer_effect: BundleLocalGenerationCubeWriterEffectEntry;
            for effect_index = 0 to writer_effects.count - 1 looplimit
                PTO_BUNDLE_TILE_BINDING_COUNT do
                let candidate = writer_effects.entries[[effect_index]];
                if candidate.active && candidate.destination == destination then
                    writer_effect = candidate;
                    writer_effect_found = TRUE;
                end;
            end;
            let slot = if assemble.init then 0
                else BundleLocalGenerationSlotForDestination(destination);
            if !assemble.init && slot == 64 then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            let generation_slot = slot as integer {0..63};
            if BundleLocalGenerationCubeLayout(
                   _Tiles[[destination]].layout) then
                if !writer_effect_found ||
                   writer_effect.size_code != writer_size ||
                   writer_effect.offset_cells != offset_cells ||
                   writer_effect.cell_count != writer_cells ||
                   writer_effect.pe_mask != writer_mask ||
                   !BundleLocalGenerationCubeWriterValueLegal(
                       writer_effect.parent, writer_effect.writer,
                       writer_size, offset_cells, writer_cells) then
                    if assemble.init then
                        SetBundleLocalGenerationInitFault(Fault_TileLegality);
                    else
                        SetBundleLocalGenerationFault(generation_slot,
                            Fault_TileLegality);
                    end;
                    return FALSE;
                end;
                if !assemble.init &&
                   _LocalGenerations[[generation_slot]].writer_count != 0 then
                    let first = _LocalGenerations[[generation_slot]].writers[[0]];
                    let actual = _Tiles[[destination]];
                    if first.layout != actual.layout ||
                       first.data_type != actual.data_type ||
                       first.predicate_basis_type != actual.predicate_basis_type ||
                       first.physical_rows != actual.rows ||
                       first.valid_rows != writer_effect.writer.valid_rows then
                        SetBundleLocalGenerationFault(generation_slot,
                            Fault_TileLegality);
                        return FALSE;
                    end;
                end;
                let replay = if assemble.init then FALSE
                    else BundleLocalGenerationReplay(
                        generation_slot, offset_cells, writer_cells, ReadBPC(),
                        _BundleExecutionDomainToken);
                if assemble.last &&
                   !BundleLocalGenerationCubeFinalizationWithWriterLegal(
                       generation_slot, destination, offset_cells,
                       writer_cells, writer_size,
                       if replay then Zeros{4} else writer_mask,
                       assemble.init, replay, writer_effect.writer) then
                    if assemble.init then
                        SetBundleLocalGenerationInitFault(Fault_TileLegality);
                    else
                        SetBundleLocalGenerationFault(generation_slot,
                            Fault_TileLegality);
                    end;
                    return FALSE;
                end;
            elsif assemble.last &&
                  !BundleLocalGenerationCoverageComplete(
                      generation_slot, assemble.offset, writer_size,
                      writer_mask, assemble.init,
                      if assemble.init then
                          _BundleTileBindings[[binding]].destination_size
                              as integer {1..12}
                      else 0) then
                if assemble.init then
                    SetBundleLocalGenerationInitFault(Fault_TileLegality);
                else
                    SetBundleLocalGenerationFault(generation_slot,
                        Fault_TileLegality);
                end;
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

func ValidateBundleLocalGenerationWriters() => boolean
begin
    return ValidateBundleLocalGenerationWritersWithWriterEffects(
        EmptyBundleLocalGenerationCubeWriterEffects());
end;
