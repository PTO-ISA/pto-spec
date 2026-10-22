// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-WRITER-EFFECTS","surface":"block","classification":["model","operands","local-generation-cube-writer-effects"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE","PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY","PTO-TILE-MODEL-LEGALITY-DESTINATION-VALUE-OPERATIONS"]}

readonly func BundleLocalGenerationCubeWriterView(
    parent: TileInfo, writer_size: integer {1..12},
    offset_cells: integer {0..2047},
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535}) => (boolean, TileInfo)
begin
    if !TileCubeNumericOrPredicateCellDescriptorLegal(parent) ||
       !BundleLocalGenerationCubeLayout(parent.layout) then
        return (FALSE, parent);
    end;
    let writer_capacity = TileSizeCodeBytes(writer_size);
    let writer_rows = if parent.layout == TileLayout_CUBE_M16 then 16 else 32;
    let writer_columns = TileCubePhysicalColumnsFromCapacity(
        writer_capacity, parent.layout, parent.data_type);
    let writer_cells = (writer_capacity DIVRM PTO_TILE_CELL_BYTES)
        as integer {1..2048};
    let cells_per_group = TileCubePhysicalCellsPerLogicalGroup(
        parent.layout, parent.data_type);
    let cell_columns = TileCubeCellColumns(parent.layout, parent.data_type);
    let first_column = ((offset_cells DIVRM cells_per_group) * cell_columns)
        as integer {0..65535};
    if parent.rows != writer_rows || writer_columns == 0 ||
       writer_cells != TileCubePhysicalCellCount(parent.layout,
           writer_rows, writer_columns, parent.data_type) ||
       TileCubePhysicalRequiredBytes(parent.layout, writer_rows,
           writer_columns, parent.data_type) != writer_capacity ||
       !TileCubePhysicalCellRangeComplete(parent.layout,
           parent.data_type, offset_cells, writer_cells) ||
       offset_cells + writer_cells >
           (parent.capacity_bytes DIVRM PTO_TILE_CELL_BYTES) ||
       first_column + writer_columns > parent.columns ||
       !TileCubeDescriptorShapeAndPhysicalLegal(writer_capacity,
           writer_rows, writer_columns, valid_rows, valid_columns,
           parent.data_type, parent.layout) then
        return (FALSE, parent);
    end;

    var writer = parent;
    writer.capacity_bytes = writer_capacity;
    writer.rows = writer_rows;
    writer.columns = writer_columns;
    writer.valid_rows = valid_rows;
    writer.valid_columns = valid_columns;
    writer.cube_k_repeat = TileCubePhysicalKRepeat(parent.layout,
        writer_rows, writer_columns, parent.data_type);
    writer.cube_n_repeat = TileCubePhysicalNRepeat(parent.layout,
        writer_rows, writer_columns, parent.data_type);
    writer.cube_cell_count = TileCubePhysicalCellCount(parent.layout,
        writer_rows, writer_columns, parent.data_type);
    writer.cube_storage_bytes = writer_capacity;
    writer.contents_defined = FALSE;
    writer.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    writer.packed_defined_elements = Zeros{524288};
    writer.defined_valid_elements = 0;
    var empty_payload: TilePayload;
    writer.payload = empty_payload;

    // The value view includes the prior range contents so in-place producers
    // retain read/modify/write behavior. The allocated parent remains intact.
    for row = 0 to writer_rows - 1 looplimit 32 do
        for column = 0 to writer_columns - 1 looplimit 65536 do
            let parent_element = TileLogicalLinearIndex(parent,
                row as integer {0..65535},
                (first_column + column) as integer {0..65535});
            let writer_element = TileLogicalLinearIndex(writer,
                row as integer {0..65535},
                column as integer {0..65535});
            writer = TileInfoWithLogicalElementAndDefined(writer,
                writer_element, TileReadLogicalElement(parent, parent_element),
                TileLogicalElementDefined(parent, parent_element));
        end;
    end;
    return (TRUE, writer);
end;

readonly func BundleLocalGenerationCubeWriterValueLegal(
    parent: TileInfo, writer: TileInfo, writer_size: integer {1..12},
    offset_cells: integer {0..2047}, writer_cells: integer {1..2048})
    => boolean
begin
    let expected_rows = if parent.layout == TileLayout_CUBE_M16 then 16
        else 32;
    let writer_capacity = TileSizeCodeBytes(writer_size);
    let expected_columns = TileCubePhysicalColumnsFromCapacity(
        writer_capacity, parent.layout, parent.data_type);
    let cells_per_group = TileCubePhysicalCellsPerLogicalGroup(
        parent.layout, parent.data_type);
    let cell_columns = TileCubeCellColumns(parent.layout, parent.data_type);
    let first_column = if cells_per_group == 0 then 65536 else
        ((offset_cells DIVRM cells_per_group) * cell_columns)
            as integer {0..65536};
    return parent.allocated &&
           BundleLocalGenerationCubeLayout(parent.layout) &&
           TileCubeNumericOrPredicateCellDescriptorLegal(parent) &&
           parent.rows == expected_rows &&
           parent.columns == TileCubePhysicalColumnsFromCapacity(
               parent.capacity_bytes, parent.layout, parent.data_type) &&
           parent.capacity_bytes >= writer_capacity &&
           writer.allocated && writer.storage_kind == parent.storage_kind &&
           writer.layout == parent.layout &&
           writer.data_type == parent.data_type &&
           writer.predicate_basis_type == parent.predicate_basis_type &&
           writer.capacity_bytes == writer_capacity &&
           writer.rows == expected_rows &&
           writer.columns == expected_columns &&
           writer.valid_rows != 0 && writer.valid_rows <= writer.rows &&
           writer.valid_columns != 0 &&
           writer.valid_columns <= writer.columns &&
           TileCubeDescriptorShapeAndPhysicalLegal(
               writer_capacity, writer.rows, writer.columns,
               writer.valid_rows, writer.valid_columns,
               writer.data_type, writer.layout) &&
           writer_cells == (writer_capacity DIVRM PTO_TILE_CELL_BYTES) &&
           TileCubePhysicalCellCount(writer.layout, writer.rows,
               writer.columns, writer.data_type) == writer_cells &&
           TileCubePhysicalRequiredBytes(writer.layout, writer.rows,
               writer.columns, writer.data_type) == writer_capacity &&
           TileCubePhysicalCellRangeComplete(writer.layout,
               writer.data_type, offset_cells, writer_cells) &&
           offset_cells + writer_cells <=
               (parent.capacity_bytes DIVRM PTO_TILE_CELL_BYTES) &&
           first_column + writer.columns <= parent.columns;
end;

// A Local CUBE parent remains in architectural state throughout B.ASSEMBLE.
// Producer results are carried in this local value and merged at the existing
// effect completion point.
func BeginBundleLocalGenerationCubeWriterEffects(
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535})
    => (boolean, BundleLocalGenerationCubeWriterEffects)
begin
    var effects: BundleLocalGenerationCubeWriterEffects;
    effects.count = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        effects.entries[[binding]].active = FALSE;
    end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           _BundleTileBindings[[binding]].destination_assemble.valid then
            let destination = _BundleTileBindings[[binding]].destination;
            let parent = _Tiles[[destination]];
            if BundleLocalGenerationCubeLayout(parent.layout) then
                let assemble = _BundleTileBindings[[binding]]
                    .destination_assemble;
                let (view_legal, writer_view) =
                    BundleLocalGenerationCubeWriterView(parent,
                        assemble.size_code as integer {1..12},
                        UInt(assemble.offset) as integer {0..2047},
                        valid_rows, valid_columns);
                if !view_legal || effects.count >=
                   PTO_BUNDLE_TILE_BINDING_COUNT then
                    return (FALSE, effects);
                end;
                effects.entries[[effects.count]].active = TRUE;
                effects.entries[[effects.count]].destination = destination;
                effects.entries[[effects.count]].offset_cells =
                    UInt(assemble.offset) as integer {0..2047};
                effects.entries[[effects.count]].parent = parent;
                effects.entries[[effects.count]].writer = writer_view;
                effects.entries[[effects.count]].size_code =
                    assemble.size_code as integer {1..12};
                effects.entries[[effects.count]].cell_count =
                    (TileSizeCodeBytes(assemble.size_code as integer {1..12})
                        DIVRM PTO_TILE_CELL_BYTES) as integer {1..2048};
                effects.entries[[effects.count]].pe_mask =
                    _BundleTileBindings[[binding]].pe_mask;
                effects.count = (effects.count + 1) as integer {
                    0..PTO_BUNDLE_TILE_BINDING_COUNT};
            end;
        end;
    end;
    return (TRUE, effects);
end;

func AddBundleLocalGenerationCubeWriterEffect(
    effects: BundleLocalGenerationCubeWriterEffects,
    binding: BundleTileBindingIndex,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535})
    => (boolean, BundleLocalGenerationCubeWriterEffects)
begin
    var updated = effects;
    if !_BundleTileBindings[[binding]].valid ||
       !_BundleTileBindings[[binding]].destination_valid ||
       !_BundleTileBindings[[binding]].destination_assemble.valid then
        return (TRUE, updated);
    end;
    let destination = _BundleTileBindings[[binding]].destination;
    let parent = _Tiles[[destination]];
    if !BundleLocalGenerationCubeLayout(parent.layout) then
        return (TRUE, updated);
    end;
    let assemble = _BundleTileBindings[[binding]].destination_assemble;
    let (view_legal, writer_view) = BundleLocalGenerationCubeWriterView(
        parent, assemble.size_code as integer {1..12},
        UInt(assemble.offset) as integer {0..2047},
        valid_rows, valid_columns);
    if !view_legal || updated.count >= PTO_BUNDLE_TILE_BINDING_COUNT then
        return (FALSE, updated);
    end;
    let index = updated.count;
    updated.entries[[index]].active = TRUE;
    updated.entries[[index]].destination = destination;
    updated.entries[[index]].offset_cells =
        UInt(assemble.offset) as integer {0..2047};
    updated.entries[[index]].cell_count =
        (TileSizeCodeBytes(assemble.size_code as integer {1..12})
            DIVRM PTO_TILE_CELL_BYTES) as integer {1..2048};
    updated.entries[[index]].size_code =
        assemble.size_code as integer {1..12};
    updated.entries[[index]].pe_mask =
        _BundleTileBindings[[binding]].pe_mask;
    updated.entries[[index]].parent = parent;
    updated.entries[[index]].writer = writer_view;
    updated.count = (index + 1) as integer {
        0..PTO_BUNDLE_TILE_BINDING_COUNT};
    return (TRUE, updated);
end;

func BundleLocalGenerationCubeWriterEffectWithOutput(
    effects: BundleLocalGenerationCubeWriterEffects,
    destination: TileIndex, output: TileInfo)
    => BundleLocalGenerationCubeWriterEffects
begin
    var updated = effects;
    var found = FALSE;
    for index = 0 to updated.count - 1 looplimit
        PTO_BUNDLE_TILE_BINDING_COUNT do
        if !found && updated.entries[[index]].active &&
           updated.entries[[index]].destination == destination then
            updated.entries[[index]].writer = output;
            found = TRUE;
        end;
    end;
    assert found;
    return updated;
end;

readonly func BundleLocalGenerationCubeWriterValueForDestination(
    effects: BundleLocalGenerationCubeWriterEffects,
    destination: TileIndex, fallback: TileInfo) => (boolean, TileInfo)
begin
    for index = 0 to effects.count - 1 looplimit
        PTO_BUNDLE_TILE_BINDING_COUNT do
        let effect = effects.entries[[index]];
        if effect.active && effect.destination == destination then
            return (TRUE, effect.writer);
        end;
    end;
    return (FALSE, fallback);
end;

func FinishBundleLocalGenerationCubeWriterEffects(
    effects: BundleLocalGenerationCubeWriterEffects)
begin
    for index = 0 to effects.count - 1 looplimit
        PTO_BUNDLE_TILE_BINDING_COUNT do
        let effect = effects.entries[[index]];
        if effect.active then
            let writer = effect.writer;
            let cells_per_group = TileCubePhysicalCellsPerLogicalGroup(
                writer.layout, writer.data_type);
            let first_column = ((effect.offset_cells DIVRM
                cells_per_group) * TileCubeCellColumns(
                    writer.layout, writer.data_type))
                    as integer {0..65535};
            var merged = effect.parent;
            for row = 0 to writer.rows - 1 looplimit 32 do
                for column = 0 to writer.columns - 1 looplimit 65536 do
                    let writer_element = TileLogicalLinearIndex(writer,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    let parent_element = TileLogicalLinearIndex(merged,
                        row as integer {0..65535},
                        (first_column + column) as integer {0..65535});
                    merged = TileInfoWithLogicalElementAndDefined(merged,
                        parent_element,
                        TileReadLogicalElement(writer, writer_element),
                        TileLogicalElementDefined(writer, writer_element));
                end;
            end;
            var defined_valid: integer {0..524288} = 0;
            for row = 0 to merged.valid_rows - 1 looplimit 65536 do
                for column = 0 to merged.valid_columns - 1
                    looplimit 65536 do
                    let element = TileLogicalLinearIndex(merged,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    if TileLogicalElementDefined(merged, element) then
                        defined_valid = (defined_valid + 1)
                            as integer {0..524288};
                    end;
                end;
            end;
            merged.defined_valid_elements = defined_valid;
            merged.contents_defined = defined_valid ==
                merged.valid_rows * merged.valid_columns;
            _Tiles[[effect.destination]] = merged;
        end;
    end;
end;

func FinalizeBundleLocalGenerationCube(slot: integer {0..63})
begin
    let destination = _LocalGenerations[[slot]].working_destination;
    let first = _LocalGenerations[[slot]].writers[[0]];
    let extent = BundleLocalGenerationCubeFinalExtent(slot);
    let valid_columns = BundleLocalGenerationCubeFinalValidColumns(slot,
        extent as integer {1..2048});
    let physical_columns = TileCubePhysicalColumnsFromCapacity(
        _Tiles[[destination]].capacity_bytes, first.layout,
        first.data_type);
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
    // Install the complete capacity-backed parent and its published valid
    // prefix without replacing payload. Then derive whole-parent definedness
    // from the writer effects already merged into their exact ranges.
    _Tiles[[destination]].rows = first.physical_rows;
    _Tiles[[destination]].columns = physical_columns;
    _Tiles[[destination]].valid_rows = first.valid_rows;
    _Tiles[[destination]].valid_columns = valid_columns;
    _Tiles[[destination]].cube_k_repeat = k_repeat;
    _Tiles[[destination]].cube_n_repeat = n_repeat;
    _Tiles[[destination]].cube_cell_count = cell_count;
    _Tiles[[destination]].cube_storage_bytes = storage_bytes;
    var defined_valid: integer {0..524288} = 0;
    for row = 0 to first.valid_rows - 1 looplimit 65536 do
        for column = 0 to valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(_Tiles[[destination]],
                row as integer {0..65535},
                column as integer {0..65535});
            if TileLogicalElementDefined(_Tiles[[destination]], element) then
                defined_valid = (defined_valid + 1)
                    as integer {0..524288};
            end;
        end;
    end;
    _Tiles[[destination]].defined_valid_elements = defined_valid;
    _Tiles[[destination]].contents_defined = defined_valid ==
        first.valid_rows * valid_columns;
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
