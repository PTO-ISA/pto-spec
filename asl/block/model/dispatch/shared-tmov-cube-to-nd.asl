// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SHARED-TMOV-CUBE-TO-ND","surface":"block","classification":["model","dispatch","shared-tmov-cube-to-nd"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-MEMORY-SHARED-CUBE-TO-ND","PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS","PTO-TILE-MODEL-SHAPE-VALID-REGION"]}
readonly func BundleSharedTMOVCubeToNDSelected() => boolean
begin
    return BundleTMOVSelected() &&
           UInt(_BundleOperation.selector[4:0]) == 2 &&
           BundleSharedBindingPhysicalCount() != 0 &&
           _BundleDataAttributesPresent &&
           TileDataLayoutIsCubeToSharedND(
               _BundleDataAttributes.data_layout);
end;

readonly func BundleSharedTMOVGenerationModeLegal(
    binding: BundleSharedBindingIndex, conversion: boolean) => boolean
begin
    let assemble = _BundleSharedBindings[[binding]].destination_assemble;
    if !assemble.valid || assemble.init then return TRUE; end;
    let index = SharedTileArrayIndex(
        BundleSharedBindingId(binding));
    let expected_metadata = if conversion then
        Zeros{PTO_XLEN} + UInt(_BundleDataAttributes.data_layout)
        else Zeros{PTO_XLEN};
    return _SharedGenerations[[index]].open &&
           _SharedGenerations[[index]].specialized_inputs_valid == conversion &&
           _SharedGenerations[[index]].specialized_metadata ==
               expected_metadata;
end;

readonly func BundleSharedTMOVCubeToNDSchemaLegal() => boolean
begin
    if BundleSharedBindingPhysicalCount() != 1 ||
       (BundleSharedBindingCount() != 1 &&
        BundleSharedReusedDestinationCount() != 1) ||
       !_BundleTileBindings[[0]].valid then
        return FALSE;
    end;
    for tile_binding = 1 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[tile_binding]].valid then return FALSE; end;
    end;
    let binding = _BundleTileBindings[[0]];
    let shared_size = if BundleSharedBindingIsReusedDestination(0) then
        BundleSharedGenerationCapacity(0)
        else BundleSharedBindingSize(0);
    let shared_mask = BundleSharedBindingMask(0);
    if !binding.valid || binding.destination_valid ||
       !binding.source0_valid || binding.source1_valid || !binding.last ||
       binding.destination_size != 0 || binding.pe_mask != shared_mask ||
       (!TileSizeCodeIsLegal(shared_size) &&
        !BundleSharedBindingIsReusedDestination(0)) then
        return FALSE;
    end;
    if shared_mask == Zeros{4} then return TRUE; end;
    let source_index = binding.source0;
    let source_tile = _Tiles[[source_index]];
    let layout = if _BundleDataAttributes.data_layout == Zeros{5} + 24 then
        TileLayout_CUBE_M32 else TileLayout_CUBE_M16;
    if !BundleSharedTMOVGenerationModeLegal(0, TRUE) then return FALSE; end;
    let parent_capacity = TileSizeCodeBytes(
        shared_size as integer {1..12});
    let writer_size = if _BundleSharedBindings[[0]].destination_assemble.valid
        then _BundleSharedBindings[[0]].destination_assemble.size_code
        else shared_size;
    if !TileSizeCodeIsLegal(writer_size) ||
       !TileCubeDescriptorLegal(source_tile) ||
       !source_tile.contents_defined || source_tile.layout != layout ||
       source_tile.data_type == TileDataType_RCPE6M2 ||
       !TileCubeLayoutDataTypeSupported(layout, source_tile.data_type) ||
       source_tile.capacity_bytes != TileSizeCodeBytes(
           writer_size as integer {1..12}) ||
       source_tile.columns != TileCubePhysicalColumnsFromCapacity(
           source_tile.capacity_bytes, layout, source_tile.data_type) ||
       (_TileAllocationMasks[[source_index]] AND shared_mask) != shared_mask then
        return FALSE;
    end;
    let (operation_type_valid, operation_type) =
        ResolveBundleEffectiveDataType();
    if !operation_type_valid ||
       !TileCarrierWidthCompatible(source_tile.data_type, operation_type) then
        return FALSE;
    end;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            if !TileElementDefined(source_index,
                   row as integer {0..65535},
                   column as integer {0..65535}) then return FALSE; end;
        end;
    end;
    let parent_rows = DerivedTileRows(parent_capacity,
        source_tile.columns, source_tile.data_type);
    if parent_rows < source_tile.valid_rows ||
       TileStorageBytes(parent_rows, source_tile.columns,
           source_tile.data_type) != parent_capacity ||
       !TileDescriptorShapeLegal(parent_capacity, source_tile.columns,
           source_tile.valid_rows, source_tile.valid_columns,
           source_tile.data_type) then
        return FALSE;
    end;
    if _BundleSharedBindings[[0]].destination_assemble.valid then
        let assemble = _BundleSharedBindings[[0]].destination_assemble;
        let raw_offset = UInt(assemble.offset);
        if raw_offset > 2047 ||
           ((raw_offset * 128) + source_tile.capacity_bytes) >
               parent_capacity then return FALSE; end;
    elsif source_tile.capacity_bytes != parent_capacity then
        return FALSE;
    end;
    return TRUE;
end;

func BundleSharedTMOVCubeToNDCandidate(
    binding: BundleSharedBindingIndex) => SharedTileInfo
begin
    let shared_tile_id = BundleSharedBindingId(binding);
    let shared_mask = BundleSharedBindingMask(binding);
    let writer_size = if _BundleSharedBindings[[binding]].destination_assemble.valid
        then _BundleSharedBindings[[binding]].destination_assemble.size_code
        else BundleSharedBindingSize(binding);
    let source = _BundleTileBindings[[0]].source0;
    var candidate: SharedTileInfo;
    candidate.descriptor_valid = TRUE;
    candidate.payload_live = FALSE;
    candidate.payload_generation = 0;
    candidate.reserved_capacity_bytes = 0;
    candidate.allocation_mask = shared_mask;
    candidate.initialized_mask = shared_mask;
    if _CurrentPEContextValid then
        candidate.initialized_mask = Zeros{4};
        candidate.initialized_mask[PTOPEMaskBitOfPEIdentity(
            _CurrentMemoryAgent as integer {0..3})] = '1';
    end;
    candidate.whole_parent_ready = FALSE;
    candidate.published = FALSE;
    candidate.tile = SharedTileFromLocalCubeToND(source,
        TileSizeCodeBytes(writer_size as integer {1..12}));
    return candidate;
end;
