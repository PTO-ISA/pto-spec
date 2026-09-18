// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE","surface":"block","classification":["model","operands","local-generation-cube"],"depends_on":["PTO-BLOCK-MODEL-STATE-TYPES","PTO-TILE-MODEL-SHAPE-CUBE-CELL","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE"]}
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

readonly func BundleLocalGenerationCubeWriterLegal(
    destination: TileIndex, writer_size: integer {1..12}) => boolean
begin
    let tile = _Tiles[[destination]];
    let writer_cells = (TileSizeCodeBytes(writer_size) DIVRM PTO_TILE_CELL_BYTES) as integer {1..2048};
    let expected_rows = if tile.layout == TileLayout_CUBE_M16 then 16 else 32;
    return tile.allocated && tile.storage_kind == TileStorage_Numeric &&
           BundleLocalGenerationCubeLayout(tile.layout) &&
           tile.rows == expected_rows && tile.valid_rows <= tile.rows &&
           tile.valid_rows != 0 && tile.valid_columns <= tile.columns &&
           tile.valid_columns != 0 &&
           TileCubeDescriptorLegal(tile) &&
           tile.cube_cell_count == writer_cells &&
           tile.cube_storage_bytes == TileSizeCodeBytes(writer_size) &&
           tile.cube_storage_bytes ==
               TileCubePhysicalRequiredBytes(tile.layout, tile.rows,
                   tile.columns, tile.data_type);
end;

readonly func BundleLocalGenerationCubeFinalizationLegal(
    slot: integer {0..63}, destination: TileIndex,
    offset_cells: integer {0..2047}, writer_cells: integer {1..2048},
    writer_size: integer {1..12}, writer_mask: bits(4), init: boolean,
    replay: boolean) => boolean
begin
    let candidate = _Tiles[[destination]];
    if !BundleLocalGenerationCubeWriterLegal(destination, writer_size) then
        return FALSE;
    end;
    let participant_mask = if init then writer_mask
        else _LocalGenerations[[slot]].participant_mask;
    if participant_mask == Zeros{4} ||
       (writer_mask AND participant_mask) != writer_mask then return FALSE; end;
    if !init && _LocalGenerations[[slot]].writer_count != 0 then
        let first = _LocalGenerations[[slot]].writers[[0]];
        if first.layout != candidate.layout ||
           first.data_type != candidate.data_type ||
           first.predicate_basis_type != candidate.predicate_basis_type ||
           first.physical_rows != candidate.rows ||
           first.valid_rows != candidate.valid_rows then return FALSE; end;
        for prior_index = 0 to _LocalGenerations[[slot]].writer_count - 1
            looplimit 16 do
            let prior = _LocalGenerations[[slot]].writers[[prior_index]];
            if prior.valid then
                let expected_rows = if prior.layout == TileLayout_CUBE_M16 then
                    16 else 32;
                if prior.physical_rows != expected_rows ||
                   prior.valid_rows == 0 ||
                   prior.valid_rows > prior.physical_rows ||
                   prior.valid_columns == 0 ||
                   prior.valid_columns > prior.physical_columns ||
                   TileCubePhysicalCellCount(prior.layout,
                       prior.physical_rows, prior.physical_columns,
                       prior.data_type) != prior.cell_count ||
                   TileCubePhysicalRequiredBytes(prior.layout,
                       prior.physical_rows, prior.physical_columns,
                       prior.data_type) != prior.cell_count * PTO_TILE_CELL_BYTES then
                    return FALSE;
                end;
                if prior.layout != first.layout ||
                   prior.data_type != first.data_type ||
                   prior.predicate_basis_type != first.predicate_basis_type ||
                   prior.physical_rows != first.physical_rows ||
                   prior.valid_rows != first.valid_rows then
                    return FALSE;
                end;
            end;
        end;
    end;
    var common_extent: integer {0..2048} = 0;
    var common_valid_columns: integer {0..65535} = 0;
    var common_set = FALSE;
    let cell_columns = TileCubeCellColumns(candidate.layout,
        candidate.data_type);
    if cell_columns == 0 then return FALSE; end;
    for pe = 0 to 3 do
        if participant_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
            let extent = BundleLocalGenerationCubeCandidateExtent(
                slot, offset_cells, writer_cells, writer_mask, pe, init);
            if extent == 0 then return FALSE; end;
            if !common_set then
                common_extent = extent;
            elsif extent != common_extent then
                return FALSE;
            end;
            var terminal_found = FALSE;
            var pe_valid_columns: integer {0..65535} = 0;
            if !init then
                for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
                    looplimit 16 do
                    let prior = _LocalGenerations[[slot]].writers[[writer]];
                    if prior.valid && prior.pe_mask[
                           PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                        let end_cell = prior.offset_cells + prior.cell_count;
                        if end_cell > extent then return FALSE; end;
                        if end_cell == extent then
                            if terminal_found || prior.valid_columns == 0 ||
                               prior.valid_columns > prior.physical_columns then
                                return FALSE;
                            end;
                            terminal_found = TRUE;
                            pe_valid_columns = prior.offset_cells * cell_columns +
                                prior.valid_columns;
                        elsif prior.valid_columns != prior.physical_columns then
                            return FALSE;
                        end;
                    end;
                end;
            end;
            if writer_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                let end_cell = offset_cells + writer_cells;
                if end_cell > extent then return FALSE; end;
                if end_cell == extent then
                    if terminal_found || candidate.valid_columns == 0 ||
                       candidate.valid_columns > candidate.columns then
                        return FALSE;
                    end;
                    terminal_found = TRUE;
                    pe_valid_columns = offset_cells * cell_columns +
                        candidate.valid_columns;
                elsif candidate.valid_columns != candidate.columns then
                    return FALSE;
                end;
            end;
            if !terminal_found || pe_valid_columns == 0 ||
               pe_valid_columns > extent * cell_columns then return FALSE; end;
            if !common_set then
                common_valid_columns = pe_valid_columns;
                common_set = TRUE;
            elsif pe_valid_columns != common_valid_columns then
                return FALSE;
            end;
        end;
    end;
    if !common_set || common_extent == 0 || common_valid_columns == 0 then
        return FALSE;
    end;
    let final_columns = common_extent * cell_columns;
    return TileCubeDescriptorShapeAndPhysicalLegal(
        candidate.capacity_bytes, candidate.rows, final_columns,
        candidate.valid_rows, common_valid_columns, candidate.data_type,
        candidate.layout);
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
            valid_columns = current.offset_cells * cell_columns +
                current.valid_columns;
        end;
    end;
    return if found then valid_columns else 0;
end;

func FinalizeBundleLocalGenerationCube(slot: integer {0..63})
begin
    let destination = _LocalGenerations[[slot]].working_destination;
    let first = _LocalGenerations[[slot]].writers[[0]];
    let extent = BundleLocalGenerationCubeFinalExtent(slot);
    let valid_columns = BundleLocalGenerationCubeFinalValidColumns(slot,
        extent as integer {1..2048});
    let cell_columns = TileCubeCellColumns(first.layout, first.data_type);
    let physical_columns = extent * cell_columns;
    let k_repeat = TileCubePhysicalKRepeat(first.layout, first.physical_rows,
        physical_columns, first.data_type);
    let n_repeat = TileCubePhysicalNRepeat(first.layout, first.physical_rows,
        physical_columns, first.data_type);
    let cell_count = TileCubePhysicalCellCount(first.layout, first.physical_rows,
        physical_columns, first.data_type);
    let storage_bytes = TileCubePhysicalRequiredBytes(first.layout,
        first.physical_rows, physical_columns, first.data_type);
    assert extent != 0 && valid_columns != 0 &&
           TileCubeDescriptorShapeAndPhysicalLegal(
               _Tiles[[destination]].capacity_bytes, first.physical_rows,
               physical_columns, first.valid_rows, valid_columns,
               first.data_type, first.layout);
    // Install only descriptor state. Payload and definedness belong to the
    // writer effects and must survive the aggregate geometry publication.
    _Tiles[[destination]].rows = first.physical_rows;
    _Tiles[[destination]].columns = physical_columns;
    _Tiles[[destination]].valid_rows = first.valid_rows;
    _Tiles[[destination]].valid_columns = valid_columns;
    _Tiles[[destination]].cube_k_repeat = k_repeat;
    _Tiles[[destination]].cube_n_repeat = n_repeat;
    _Tiles[[destination]].cube_cell_count = cell_count;
    _Tiles[[destination]].cube_storage_bytes = storage_bytes;
    _LocalGenerations[[slot]].parent_descriptor.rows = first.physical_rows;
    _LocalGenerations[[slot]].parent_descriptor.columns = physical_columns;
    _LocalGenerations[[slot]].parent_descriptor.valid_rows = first.valid_rows;
    _LocalGenerations[[slot]].parent_descriptor.valid_columns = valid_columns;
    _LocalGenerations[[slot]].parent_descriptor.data_type = first.data_type;
    _LocalGenerations[[slot]].parent_descriptor.predicate_basis_type =
        first.predicate_basis_type;
    _LocalGenerations[[slot]].parent_descriptor.layout = first.layout;
    _LocalGenerations[[slot]].parent_descriptor.cube_k_repeat = k_repeat;
    _LocalGenerations[[slot]].parent_descriptor.cube_n_repeat = n_repeat;
    _LocalGenerations[[slot]].parent_descriptor.cube_cell_count = cell_count;
    _LocalGenerations[[slot]].parent_descriptor.cube_storage_bytes =
        storage_bytes;
    _LocalGenerations[[slot]].parent_descriptor.valid = TRUE;
    _LocalGenerations[[slot]].descriptor_finalized = TRUE;
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
readonly func BundleLocalGenerationDescriptorMatches(
    slot: integer {0..63}, destination: TileIndex,
    participant_mask: bits(4)) => boolean
begin
    let expected = _LocalGenerations[[slot]].parent_descriptor;
    let actual = _Tiles[[destination]];
    if !_LocalGenerations[[slot]].generation_identity_valid ||
       !actual.allocated || expected.object_name != destination ||
       expected.object_kind != actual.storage_kind ||
       expected.participant_mask != _TileAllocationMasks[[destination]] ||
       !BundleLocalGenerationMaskSubset(participant_mask,
           expected.participant_mask) ||
       actual.capacity_bytes != expected.capacity_bytes then
        return FALSE;
    end;
    if BundleLocalGenerationCubeLayout(actual.layout) then
        if _LocalGenerations[[slot]].writer_count == 0 then return FALSE; end;
        let first = _LocalGenerations[[slot]].writers[[0]];
        return first.valid && actual.rows == first.physical_rows &&
               actual.columns == first.physical_columns &&
               actual.valid_rows == first.valid_rows &&
               actual.valid_columns == first.valid_columns &&
               actual.data_type == first.data_type &&
               actual.predicate_basis_type == first.predicate_basis_type &&
               actual.layout == first.layout &&
               actual.cube_cell_count == first.cell_count &&
               actual.cube_storage_bytes ==
                   TileCubePhysicalRequiredBytes(actual.layout,
                       actual.rows, actual.columns, actual.data_type);
    end;
    return actual.rows == expected.rows && actual.columns == expected.columns &&
           actual.valid_rows == expected.valid_rows &&
           actual.valid_columns == expected.valid_columns &&
           actual.data_type == expected.data_type &&
           actual.predicate_basis_type == expected.predicate_basis_type &&
           actual.layout == expected.layout &&
           actual.cube_k_repeat == expected.cube_k_repeat &&
           actual.cube_n_repeat == expected.cube_n_repeat &&
           actual.cube_cell_count == expected.cube_cell_count &&
           actual.cube_storage_bytes == expected.cube_storage_bytes;
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
