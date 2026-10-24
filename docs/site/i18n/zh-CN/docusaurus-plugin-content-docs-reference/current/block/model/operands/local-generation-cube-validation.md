<!-- GENERATED FROM: asl/block/model/operands/local-generation-cube-validation.asl -->
# Local Generation CUBE Validation

**Normative ASL source:** `asl/block/model/operands/local-generation-cube-validation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-VALIDATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/local-generation-cube-validation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-VALIDATION","surface":"block","classification":["model","operands","local-generation-cube-validation"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-WRITER-EFFECTS"]}

readonly func BundleLocalGenerationCubeFinalizationWithWriterLegal(
    slot: integer {0..63}, destination: TileIndex,
    offset_cells: integer {0..2047}, writer_cells: integer {1..2048},
    writer_size: integer {1..12}, writer_mask: bits(4), init: boolean,
    replay: boolean, current_writer: TileInfo) => boolean
begin
    let candidate = _Tiles[[destination]];
    if !BundleLocalGenerationCubeWriterValueLegal(candidate,
           current_writer, writer_size, offset_cells, writer_cells) then
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
           first.valid_rows != current_writer.valid_rows then return FALSE; end;
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
                    if terminal_found || current_writer.valid_columns == 0 ||
                       current_writer.valid_columns > current_writer.columns then
                        return FALSE;
                    end;
                    terminal_found = TRUE;
                    pe_valid_columns =
                        BundleLocalGenerationCubeValidColumnsAt(
                            offset_cells, cell_columns,
                            cells_per_group,
                            current_writer.valid_columns);
                elsif current_writer.valid_columns != current_writer.columns then
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
    let final_columns = TileCubePhysicalColumnsFromCapacity(
        candidate.capacity_bytes, candidate.layout, candidate.data_type);
    return TileCubeDescriptorShapeAndPhysicalLegal(
        candidate.capacity_bytes, candidate.rows, final_columns,
        current_writer.valid_rows, common_valid_columns,
        candidate.data_type,
        candidate.layout);
end;

// Preserve the original index-based entry point for existing validation
// callers. Architectural writer paths pass the already-resolved value view
// directly to BundleLocalGenerationCubeFinalizationWithWriterLegal.
readonly func BundleLocalGenerationCubeFinalizationLegal(
    slot: integer {0..63}, destination: TileIndex,
    offset_cells: integer {0..2047}, writer_cells: integer {1..2048},
    writer_size: integer {1..12}, writer_mask: bits(4), init: boolean,
    replay: boolean) => boolean
begin
    let valid_rows = BundleLocalGenerationCubeCurrentValidRows();
    let valid_columns = BundleLocalGenerationCubeCurrentValidColumns();
    if valid_rows == 0 || valid_columns == 0 then return FALSE; end;
    let (writer_legal, writer) = BundleLocalGenerationCubeWriterView(
        _Tiles[[destination]], writer_size, offset_cells,
        valid_rows as integer {1..65535},
        valid_columns as integer {1..65535});
    if !writer_legal then return FALSE; end;
    return BundleLocalGenerationCubeFinalizationWithWriterLegal(
        slot, destination, offset_cells, writer_cells, writer_size,
        writer_mask, init, replay, writer);
end;
```
<!-- GENERATED-ASL-END: unit -->
