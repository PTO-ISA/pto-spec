// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION","surface":"block","classification":["model","dispatch","tcvt-destination"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-WRITER-EFFECTS","PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","PTO-TILE-MODEL-STATE-ALLOCATION"]}
readonly func BundleTCVTCubeDestinationCapacityGroupFits() => boolean
begin
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        0 as BundleTileBindingIndex);
    let mask = _BundleTileBindings[[0]].pe_mask;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        if mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' &&
           TileCapacityInUseForPE(pe) + capacity_bytes >
               TileCapacityLimitBytes() then
            return FALSE;
        end;
    end;
    return TRUE;
end;

func ResolveBundleTCVTCubeDestination() => boolean
begin
    let binding = _BundleTileBindings[[0]];
    let source = BundleTileSourceIndex(0, FALSE);
    let source_layout = _Tiles[[source]].layout;
    let (destination_type_valid, destination_type) =
        ResolveBundleEffectiveDataType();
    if !destination_type_valid ||
       (source_layout != TileLayout_CUBE_M16 &&
        source_layout != TileLayout_CUBE_M32) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;

    let valid_columns = UInt(_BundleDimensions[[0]])
        as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let capacity_bytes = BundleLocalDestinationAllocationBytes(0);
    if binding.destination_reused_by_generation then
        let destination = _Tiles[[binding.destination]];
        let parent_rows = if source_layout == TileLayout_CUBE_M16 then 16
            else 32;
        let parent_columns = TileCubePhysicalColumnsFromCapacity(
            capacity_bytes, source_layout, destination_type);
        let local_generation = binding.destination_assemble.valid;
        if !TileCubeDescriptorLegal(destination) ||
           destination.capacity_bytes != capacity_bytes ||
           (if local_generation then
                destination.rows != parent_rows ||
                destination.columns != parent_columns
            else
                destination.valid_rows != valid_rows ||
                destination.valid_columns != valid_columns) ||
           destination.data_type != destination_type ||
           destination.layout != source_layout ||
           (_TileAllocationMasks[[binding.destination]] AND binding.pe_mask) !=
               binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        if local_generation then
            let assemble = binding.destination_assemble;
            if assemble.size_code < 1 || assemble.size_code > 12 ||
               UInt(assemble.offset) > 2047 ||
               !BundleLocalGenerationCubeWriterPreflightLegal(
                   capacity_bytes, parent_rows, parent_columns,
                   destination_type, source_layout,
                   assemble.size_code as integer {1..12},
                   UInt(assemble.offset) as integer {0..2047},
                   valid_rows, valid_columns) then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
        end;
        return TRUE;
    end;
    // CUBE physical rows/columns and CELL count are derived from the
    // destination DataType.  In particular, a narrower source and wider
    // destination can require a different minimum power-of-two TSize.
    if !TileCubeDescriptorShapeLegal(
           capacity_bytes, valid_rows, valid_columns,
           destination_type, source_layout) ||
       !BundleTCVTCubeDestinationCapacityGroupFits() then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    if binding.destination_assemble.valid then
        let assemble = binding.destination_assemble;
        if assemble.size_code < 1 || assemble.size_code > 12 ||
           UInt(assemble.offset) > 2047 ||
           !BundleLocalGenerationCubeWriterPreflightLegal(
               capacity_bytes,
               (if source_layout == TileLayout_CUBE_M16 then 16 else 32),
               TileCubePhysicalColumnsFromCapacity(
                   capacity_bytes, source_layout, destination_type),
               destination_type, source_layout,
               assemble.size_code as integer {1..12},
               UInt(assemble.offset) as integer {0..2047},
               valid_rows, valid_columns) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    end;

    let hand = UInt(binding.destination_hand);
    var resolved: TileIndex = 0;
    var found = FALSE;
    for offset = 0 to 15 do
        let raw_index: integer = hand * 16 + offset;
        if !found && !_Tiles[[raw_index]].allocated then
            resolved = raw_index as TileIndex;
            found = TRUE;
        end;
    end;
    if !found then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;

    if !ConfigureCubeTileForMask(
           resolved, capacity_bytes, valid_rows, valid_columns,
           destination_type, source_layout,
           binding.pe_mask) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    _BundleTileBindings[[0]].destination = resolved;
    _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
    return TRUE;
end;

func ResolveBundleTCVTCubeDestinationWithWriterEffects()
    => (boolean, BundleLocalGenerationCubeWriterEffects)
begin
    var effects = EmptyBundleLocalGenerationCubeWriterEffects();
    if !ResolveBundleTCVTCubeDestination() then
        return (FALSE, effects);
    end;
    let binding = 0 as BundleTileBindingIndex;
    if _BundleTileBindings[[binding]].destination_assemble.valid then
        let rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
        let columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
        let (effect_legal, updated) =
            AddBundleLocalGenerationCubeWriterEffect(
                effects, binding, rows, columns);
        if !effect_legal then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, effects);
        end;
        effects = updated;
    end;
    return (TRUE, effects);
end;
