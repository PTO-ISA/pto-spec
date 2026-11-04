// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SHARED-TMOV-ND-TO-CUBE","surface":"block","classification":["model","dispatch","shared-tmov-nd-to-cube"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-VALIDATION","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-WRITER-EFFECTS","PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS","PTO-TILE-MODEL-MEMORY-SHARED-ND-TO-CUBE","PTO-TILE-MODEL-SHAPE-CUBE-CELL","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}

readonly func BundleSharedTMOVSharedNDToCubeSelected() => boolean
begin
    return BundleTMOVSelected() &&
           UInt(_BundleOperation.selector[4:0]) == 2 &&
           BundleSharedBindingPhysicalCount() != 0 &&
           _BundleDataAttributesPresent &&
           TileDataLayoutIsSharedNDToCube(
               _BundleDataAttributes.data_layout);
end;

readonly func BundleSharedTMOVSharedNDToCubeLayout() => TileLayout
begin
    assert BundleSharedTMOVSharedNDToCubeSelected();
    return TileDataLayoutCubeLayout(_BundleDataAttributes.data_layout);
end;

readonly func BundleSharedTMOVSharedNDToCubeRows()
    => integer {16,32}
begin
    assert BundleSharedTMOVSharedNDToCubeSelected();
    if _BundleDataAttributes.data_layout == Zeros{5} + 21 then
        return 32;
    end;
    return 16;
end;

readonly func BundleSharedTMOVSharedNDToCubeTypePairLegal(
    layout: TileLayout, backing_type: TileDataType,
    carrier_type: TileDataType) => boolean
begin
    return backing_type != TileDataType_RCPE6M2 &&
           TileCubeLayoutDataTypeSupported(layout, backing_type) &&
           TileCarrierWidthCompatible(backing_type, carrier_type);
end;

readonly func BundleSharedTMOVSharedNDToCubeFirstParticipatingPE()
    => MemoryAgentId
begin
    let mask = BundleSharedBindingMask(0);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe_identity = pe as MemoryAgentId;
        if mask[PTOPEMaskBitOfPEIdentity(pe_identity)] == '1' then
            return pe_identity;
        end;
    end;
    unreachable;
end;

readonly func BundleSharedTMOVSharedNDToCubeFragmentForPE(
    source_parent: TileInfo,
    destination_capacity: integer {0..262144},
    pe_identity: MemoryAgentId) => SharedNDToCubeFragment
begin
    var fragment = EmptySharedNDToCubeFragment();
    if !BundleSharedTMOVSharedNDToCubeSelected() then return fragment; end;
    let rows = BundleSharedTMOVSharedNDToCubeRows();
    let layout = BundleSharedTMOVSharedNDToCubeLayout();
    let source_type = source_parent.data_type;
    let element_bits = TileElementBits(source_type);
    let physical_columns = source_parent.columns;
    if physical_columns == 0 then return fragment; end;

    let physical_rows_from_capacity = DerivedTileRows(
        source_parent.capacity_bytes, physical_columns, source_type);
    if source_parent.layout != TileLayout_RowMajor ||
       !source_parent.allocated || !source_parent.contents_defined ||
       source_parent.capacity_bytes == 0 ||
       source_parent.rows != physical_rows_from_capacity ||
       !TileDescriptorPhysicalShapeLegal(source_parent.capacity_bytes,
           source_parent.rows, physical_columns,
           source_parent.valid_rows, source_parent.valid_columns,
           source_type) || source_parent.valid_rows == 0 ||
       source_parent.valid_columns == 0 ||
       source_parent.valid_columns > physical_columns ||
       !TileCubeLayoutDataTypeSupported(layout, source_type) then
        return fragment;
    end;
    let (carrier_valid, carrier_type) = ResolveBundleEffectiveDataType();
    if !carrier_valid || !BundleSharedTMOVSharedNDToCubeTypePairLegal(
           layout, source_type, carrier_type) then
        return fragment;
    end;
    let derived_columns = TileCubePhysicalColumnsFromCapacity(
        destination_capacity, layout, source_type);
    if derived_columns == 0 || derived_columns != physical_columns ||
       !TileCubeDescriptorShapeAndPhysicalLegal(destination_capacity,
           rows, derived_columns, 1, 1, source_type, layout) then
        return fragment;
    end;

    var origin_row: integer {0..65535} = 0;
    let modifier = _BundleSharedBindings[[0]].source0_subview;
    if modifier.valid then
        if modifier.size_code == 0 then return fragment; end;
        let selected_bytes = TileSizeCodeBytes(
            modifier.size_code as integer {1..12});
        let row_bytes = TileStorageBytes(1, physical_columns, source_type);
        let raw_offset = UInt(BundleSharedSubviewOffsetRawForPE(
            0, pe_identity));
        if raw_offset > 2047 || row_bytes <= 0 ||
           selected_bytes != destination_capacity ||
           selected_bytes MOD row_bytes != 0 ||
           (raw_offset * 128) MOD row_bytes != 0 then
            return fragment;
        end;
        let selected_rows = selected_bytes DIVRM row_bytes;
        let origin = (raw_offset * 128) DIVRM row_bytes;
        if selected_rows != rows || origin > 65535 ||
           origin + rows > source_parent.rows then
            return fragment;
        end;
        origin_row = origin as integer {0..65535};
    else
        if source_parent.rows != rows ||
           source_parent.capacity_bytes != destination_capacity ||
           TileStorageBytes(rows, physical_columns, source_type) !=
               destination_capacity then
            return fragment;
        end;
    end;

    let valid_rows = (if origin_row < source_parent.valid_rows then
        if source_parent.valid_rows - origin_row < rows then
            source_parent.valid_rows - origin_row
        else rows
    else 0) as integer {0..65535};
    let valid_columns = source_parent.valid_columns;
    if valid_rows == 0 || valid_columns == 0 ||
       UInt(_BundleDimensions[[0]]) != valid_columns ||
       UInt(_BundleDimensions[[1]]) != valid_rows then
        return fragment;
    end;
    // LB2's effective value 1 is the sole capacity-derived sentinel. Do not
    // consult its presence bit: omitted and explicit one are equivalent.
    let effective_lb2 = UInt(_BundleDimensions[[2]]);
    if effective_lb2 != 1 && effective_lb2 != derived_columns then
        return fragment;
    end;
    if !TileCubeDescriptorShapeAndPhysicalLegal(destination_capacity,
           rows, derived_columns, valid_rows, valid_columns,
           source_type, layout) then
        return fragment;
    end;
    for row = 0 to valid_rows - 1 looplimit 65536 do
        for column = 0 to valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_parent,
                (origin_row + row) as integer {0..65535},
                column as integer {0..65535});
            if !TileLogicalElementDefined(source_parent, source_element) then
                return EmptySharedNDToCubeFragment();
            end;
        end;
    end;
    fragment.valid = TRUE;
    fragment.origin_row = origin_row;
    fragment.valid_rows = valid_rows as integer {0..65535};
    fragment.valid_columns = valid_columns as integer {0..65535};
    fragment.physical_rows = rows as integer {0..65535};
    fragment.physical_columns = derived_columns as integer {0..65535};
    fragment.capacity_bytes = destination_capacity;
    fragment.data_type = source_type;
    fragment.layout = layout;
    return fragment;
end;

readonly func BundleSharedTMOVSharedNDToCubeSchemaLegal() => boolean
begin
    if BundleSharedBindingPhysicalCount() != 1 ||
       BundleSharedBindingCount() != 1 ||
       BundleSharedReusedDestinationCount() != 0 ||
       BundleTileBindingCount() != 1 ||
       !_BundleTileBindings[[0]].valid then
        return FALSE;
    end;
    let tile_binding = _BundleTileBindings[[0]];
    let shared_mask = BundleSharedBindingMask(0);
    if !tile_binding.valid || tile_binding.destination_valid == FALSE ||
       tile_binding.source0_valid || tile_binding.source1_valid ||
       !tile_binding.last ||
       !LocalTileSizeCodeIsLegal(tile_binding.destination_size) ||
       tile_binding.pe_mask != shared_mask ||
       BundleSharedBindingIsDestination(0) ||
       BundleSharedBindingIsReusedDestination(0) ||
       BundleSharedBindingSize(0) != 0 ||
       _BundleSharedBindings[[0]].destination_assemble.valid ||
       _BundleTileBindings[[0]].destination_assemble.valid ||
       _BundleScalarBindings[[0]].valid ||
       _BundleScalarBindings[[1]].valid then
        return FALSE;
    end;
    for tile_binding_index = 1 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[tile_binding_index]].valid then
            return FALSE;
        end;
    end;
    if shared_mask == Zeros{4} then return TRUE; end;
    let shared_tile_id = BundleSharedBindingId(0);
    if !SharedTilePublished(shared_tile_id) then return FALSE; end;
    let source_parent = SharedTileRecord(shared_tile_id).tile;
    let destination_capacity = TileSizeCodeBytes(
        tile_binding.destination_size as integer {1..12});
    if !_CurrentPEContextValid then
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let pe_identity = pe as MemoryAgentId;
            if shared_mask[PTOPEMaskBitOfPEIdentity(pe_identity)] == '1' &&
               !BundleSharedTMOVSharedNDToCubeFragmentForPE(
                   source_parent, destination_capacity,
                   pe_identity).valid then
                return FALSE;
            end;
        end;
    else
        if shared_mask[PTOPEMaskBitOfPEIdentity(
               _CurrentMemoryAgent as integer {0..3})] != '1' ||
           !BundleSharedTMOVSharedNDToCubeFragmentForPE(
               source_parent, destination_capacity,
               _CurrentMemoryAgent).valid then
            return FALSE;
        end;
    end;
    return TRUE;
end;

func BundleSharedTMOVSharedNDToCubeValue(
    destination: TileInfo, shared_tile_id: SharedTileID,
    source_parent: TileInfo, pe_identity: MemoryAgentId) => TileInfo
begin
    let destination_capacity = destination.capacity_bytes;
    let fragment = BundleSharedTMOVSharedNDToCubeFragmentForPE(
        source_parent, destination_capacity, pe_identity);
    return TMOVSharedNDToCubeToValue(destination, shared_tile_id,
        source_parent, fragment);
end;

func ExecuteBundleSharedTMOVSharedNDToCube(shared_tile_id: SharedTileID)
    => (boolean, BundleLocalGenerationCubeWriterEffects)
begin
    var writer_effects = EmptyBundleLocalGenerationCubeWriterEffects();
    let binding = _BundleTileBindings[[0]];
    let capacity_bytes = TileSizeCodeBytes(
        binding.destination_size as integer {1..12});
    let pe_identity = if _CurrentPEContextValid then _CurrentMemoryAgent
        else BundleSharedTMOVSharedNDToCubeFirstParticipatingPE();
    let source_parent = SharedTileRecord(shared_tile_id).tile;
    let fragment = BundleSharedTMOVSharedNDToCubeFragmentForPE(
        source_parent, capacity_bytes, pe_identity);
    let (resolved, resolved_effects) =
        ResolveBundleTileDestinationsWithShapeAndTypeAndWriterEffects(
            TRUE, fragment.valid_rows as integer {1..65535},
            fragment.valid_columns as integer {1..65535},
            fragment.physical_columns as integer {1..65535},
            TRUE, fragment.data_type);
    if !resolved then return (FALSE, writer_effects); end;
    writer_effects = resolved_effects;
    let writers_valid =
        ValidateBundleLocalGenerationWritersWithWriterEffects(
            writer_effects);
    if !writers_valid then
        RollBackBundleTileDestinations();
        return (FALSE, writer_effects);
    end;
    let destination = _BundleTileBindings[[0]].destination;
    let (writer_found, writer_value) =
        BundleLocalGenerationCubeWriterValueForDestination(
            writer_effects, destination, _Tiles[[destination]]);
    let destination_value = if writer_found then writer_value
        else _Tiles[[destination]];
    if destination_value.rows != fragment.physical_rows ||
       destination_value.columns != fragment.physical_columns ||
       destination_value.valid_rows != fragment.valid_rows ||
       destination_value.valid_columns != fragment.valid_columns ||
       destination_value.data_type != fragment.data_type ||
       destination_value.layout != fragment.layout then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, writer_effects);
    end;
    let result = BundleSharedTMOVSharedNDToCubeValue(
        destination_value, shared_tile_id, source_parent, pe_identity);
    if writer_found then
        writer_effects = BundleLocalGenerationCubeWriterEffectWithOutput(
            writer_effects, destination, result);
    else
        _Tiles[[destination]] = result;
    end;
    return (TRUE, writer_effects);
end;
