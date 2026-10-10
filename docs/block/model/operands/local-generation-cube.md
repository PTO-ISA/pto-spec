<!-- GENERATED FROM: asl/block/model/operands/local-generation-cube.asl -->
# Local Generation CUBE

**Normative ASL source:** `asl/block/model/operands/local-generation-cube.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-local-generation-cube-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the CUBE-specific rules of a Local `B.ASSEMBLE` generation, plus several helpers that every Local generation uses. A generation builds one parent Tile from several writer bundles. For the `CUBE_M16` and `CUBE_M32` layouts, the final parent shape is not known at INIT. It is derived at LAST from what the writers actually covered.

<!-- PTO-READER-BLOCK: block-model-operands-local-generation-cube-concepts role=concepts-state -->
## Concepts and visible state

The unit declares no state. It reads and updates the `_LocalGenerations` slot of a generation and the parent Tile's descriptor.

- A CELL is the 128-byte storage unit of a CUBE layout. For `CUBE_M16` and `CUBE_M32` it spans 16 or 32 rows and a type-dependent number of columns.
- A writer fragment is the destination Tile of one writer bundle. Each writer keeps its own fragment descriptor.
- For M32 64-bit fragments, one logical column group is two adjacent physical CELLs. Every writer offset, size, covered prefix, and terminal extent must contain complete pairs.
- The extent of one PE is the length of its gap-free covered CELL prefix, from `BundleLocalGenerationPrefixExtent`.
- The terminal writer of a PE is the writer whose range ends exactly at that extent.

<!-- PTO-READER-BLOCK: block-model-operands-local-generation-cube-rules role=rules-interactions -->
## Rules and interactions

`BundleLocalGenerationCubeWriterLegal` accepts a fragment only when it is an allocated numeric `CUBE_M16` or `CUBE_M32` Tile with 16 or 32 physical rows, a nonzero valid region inside its storage, a legal CUBE descriptor, and a CELL count and storage size that both equal the writer size code.

`BundleLocalGenerationCubeFinalizationLegal` runs for a LAST writer before any effect. It requires:

- every earlier writer to match the first writer's layout, data type, basis type, physical rows, and valid rows;
- every participating PE to reach the same nonzero extent, with no writer extending past it;
- exactly one terminal writer per PE, and every other writer's fragment to have full valid columns;
- the same final valid-column count on every PE, computed as the terminal writer's offset times the CELL width plus its valid columns;
- a legal final descriptor at the parent's capacity.

`FinalizeBundleLocalGenerationCube` then installs the final rows, columns, valid region, repeats, CELL count, and storage bytes into both the parent Tile and the slot's parent descriptor, and sets `descriptor_finalized`. For M32 64-bit data it divides the physical CELL extent by two before deriving logical columns, while retaining both CELLs in storage and capacity accounting.

Design point: finalization writes only descriptor fields. The ASL comment states that payload and definedness belong to the writer effects and must survive the aggregate geometry publication.

Design point: parent capacity is allocation metadata only. The contract `PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001` states that capacity slack never creates parent rows, columns, repeats, or CELLs. The final shape comes from covered CELLs alone.

`ValidateBundleLocalGenerationWriters` applies these checks, and for non-CUBE generations `BundleLocalGenerationCoverageComplete` requires every parent CELL to be covered on every participating PE at LAST. It runs after destination shape, allocation, or reuse. The ASL comment gives the reason: writer legality then observes the exact Tile the producer would update, while still preceding producer effects, coverage updates, LAST closure, and finalization.

<!-- PTO-READER-BLOCK: block-model-operands-local-generation-cube-boundaries role=boundaries -->
## Architectural boundaries

`SetBundleLocalGenerationInitFault` raises a fault for a failing INIT and points the trap-context restart address at `BPC`, the INIT bundle. `BundleLocalGenerationDescriptorMatches` checks, before a continuation reuses the parent, that the parent is still the same allocated object with the same participant mask and capacity. It also requires the writer mask to be a subset of the generation's mask and an unchanged descriptor; for CUBE that is the first writer's fragment descriptor. `BundleLocalGenerationRangeOverlaps` and `BundleLocalGenerationMaskSubset` are shared range and mask helpers.

<!-- PTO-READER-BLOCK: block-model-operands-local-generation-cube-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

An FP16 `CUBE_M16` parent is allocated with size code 6, which is 4096 bytes or 32 CELLs. Each CELL is 16 rows by 4 columns. Writer A has size code 3 (4 CELLs) at offset 0, and writer B has size code 3 at offset 4 with LAST. Both fragments are 16 by 16 with full valid columns. The extent is 8 CELLs, so the final parent is 16 rows by 8 x 4 = 32 columns, 8 CELLs, and 1024 bytes of storage. The 24 unused CELLs of capacity create no columns. If B used offset 5 instead, CELL 4 would be a gap, and LAST would fault.

<!-- PTO-READER-BLOCK: block-model-operands-local-generation-cube-related role=related-owners-navigation -->
## Related owners

- [Local generation](local-generation.md) opens, commits, and aborts generations.
- [CUBE cell geometry](../../../tile/model/shape/cube-cell.md) owns CELL rows, columns, and counts.
- [Portable carriers](portable-carriers.md) owns readiness and publication.
- [B.ASSEMBLE](../../operands/B.ASSEMBLE.md) is the command page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/local-generation-cube.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE","surface":"block","classification":["model","operands","local-generation-cube"],"depends_on":["PTO-BLOCK-MODEL-STATE-TYPES","PTO-TILE-MODEL-SHAPE-CUBE-CELL","PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE"]}
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
    let cells_per_group = TileCubePhysicalCellsPerLogicalGroup(
        candidate.layout, candidate.data_type);
    if !TileCubePhysicalCellRangeComplete(candidate.layout,
           candidate.data_type, offset_cells, writer_cells) then return FALSE; end;
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
                if !TileCubePhysicalCellRangeComplete(
                       prior.layout, prior.data_type,
                       prior.offset_cells, prior.cell_count) then return FALSE; end;
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
                            pe_valid_columns =
                                BundleLocalGenerationCubeValidColumnsAt(
                                    prior.offset_cells, cell_columns,
                                    cells_per_group,
                                    prior.valid_columns);
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
                    pe_valid_columns =
                        BundleLocalGenerationCubeValidColumnsAt(
                            offset_cells, cell_columns,
                            cells_per_group,
                            candidate.valid_columns);
                elsif candidate.valid_columns != candidate.columns then
                    return FALSE;
                end;
            end;
            if !terminal_found || pe_valid_columns == 0 ||
               pe_valid_columns >
                   (extent DIVRM cells_per_group) * cell_columns then
                return FALSE;
            end;
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
    if common_extent MOD cells_per_group != 0 then return FALSE; end;
    let final_columns =
        (common_extent DIVRM cells_per_group) * cell_columns;
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
func FinalizeBundleLocalGenerationCube(slot: integer {0..63})
begin
    let destination = _LocalGenerations[[slot]].working_destination;
    let first = _LocalGenerations[[slot]].writers[[0]];
    let extent = BundleLocalGenerationCubeFinalExtent(slot);
    let valid_columns = BundleLocalGenerationCubeFinalValidColumns(slot,
        extent as integer {1..2048});
    let cell_columns = TileCubeCellColumns(first.layout, first.data_type);
    let cells_per_group = TileCubePhysicalCellsPerLogicalGroup(
        first.layout, first.data_type);
    let physical_columns =
        (extent DIVRM cells_per_group) * cell_columns;
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

// Destination shape, allocation, and generation reuse are resolved before
// this check. Writer descriptor legality therefore observes the exact Tile
// that the producer would update, while still preceding producer effects,
// coverage updates, LAST closure, and parent-descriptor finalization.
func ValidateBundleLocalGenerationWriters() => boolean
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
            let slot = if assemble.init then 0
                else BundleLocalGenerationSlotForDestination(destination);
            if !assemble.init && slot == 64 then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            let generation_slot = slot as integer {0..63};
            if BundleLocalGenerationCubeLayout(
                   _Tiles[[destination]].layout) then
                if !BundleLocalGenerationCubeWriterLegal(
                       destination, writer_size) then
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
                       first.valid_rows != actual.valid_rows then
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
                   !BundleLocalGenerationCubeFinalizationLegal(
                       generation_slot, destination, offset_cells,
                       writer_cells, writer_size,
                       if replay then Zeros{4} else writer_mask,
                       assemble.init, replay) then
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
```
<!-- GENERATED-ASL-END: unit -->
