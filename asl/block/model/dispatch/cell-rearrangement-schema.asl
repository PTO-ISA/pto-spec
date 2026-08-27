// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA","surface":"block","classification":["model","dispatch","cell-rearrangement-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA"]}

func ResolveBundleCellRearrangementDestination() => boolean
begin
    var destination_binding: BundleTileBindingIndex = 0;
    var destination_seen = FALSE;
    var source: TileIndex = 0;
    var source_seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid then
            if !destination_seen &&
               _BundleTileBindings[[binding]].destination_valid then
                destination_binding = binding as BundleTileBindingIndex;
                destination_seen = TRUE;
            end;
            if !source_seen &&
               _BundleTileBindings[[binding]].source0_valid then
                source = BundleTileSourceIndex(
                    binding as BundleTileBindingIndex, FALSE);
                source_seen = TRUE;
            elsif !source_seen &&
                  _BundleTileBindings[[binding]].source1_valid then
                source = BundleTileSourceIndex(
                    binding as BundleTileBindingIndex, TRUE);
                source_seen = TRUE;
            end;
        end;
    end;
    if !destination_seen || !source_seen ||
       !TileCubeDescriptorLegal(_Tiles[[source]]) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let binding = _BundleTileBindings[[destination_binding]];
    let source_tile = _Tiles[[source]];
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        destination_binding);
    if !TileCubeDescriptorShapeLegal(capacity_bytes,
           source_tile.valid_rows, source_tile.valid_columns,
           source_tile.data_type, source_tile.layout) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let hand = UInt(binding.destination_hand);
    var resolved: TileIndex = 0;
    var found = FALSE;
    for offset = 0 to 15 looplimit 16 do
        let raw_index = hand * 16 + offset;
        if !found && !_Tiles[[raw_index]].allocated then
            resolved = raw_index as TileIndex;
            found = TRUE;
        end;
    end;
    if !found || !LocalTileAllocationFitsExcept(
           resolved, binding.pe_mask, capacity_bytes) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let configured = ConfigureCubeTileForMask(
        resolved, capacity_bytes, source_tile.valid_rows,
        source_tile.valid_columns, source_tile.data_type,
        source_tile.layout, TileLocation_Matrix, binding.pe_mask);
    if !configured then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    _BundleTileBindings[[destination_binding]].destination = resolved;
    _BundleTileBindings[[destination_binding]].destination_allocated_by_bundle =
        TRUE;
    return TRUE;
end;

pure func TileOperationUsesCellRearrangementSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TPERMUTE ||
           decoded == TileOperation_TSHUF ||
           decoded == TileOperation_TPACK ||
           decoded == TileOperation_TUNPACK;
end;

readonly func SelectedBundleCellRearrangementSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesCellRearrangementSchema(operation) then return TRUE; end;
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TPERMUTE then
        if BundleTileBindingCount() != 2 || BundleSharedBindingCount() != 0 ||
           _BundleScalarBindings[[0]].valid then return FALSE; end;
        let first = _BundleTileBindings[[0]];
        let second = _BundleTileBindings[[1]];
        return !first.destination_valid && first.source0_valid &&
               first.source1_valid && !first.last && second.destination_valid &&
               !second.destination_allocated_by_bundle && second.source0_valid &&
               !second.source1_valid && second.last &&
               second.source0 != first.source0 &&
               second.source0 != first.source1 &&
               BundleTileDestinationSizeLegal(1);
    end;
    if BundleTileBindingCount() != 1 || BundleSharedBindingCount() != 0 ||
       !_BundleScalarBindings[[0]].valid ||
       _BundleScalarBindings[[0]].source1 != 0 ||
       _BundleScalarBindings[[0]].source2 != 0 ||
       _BundleScalarBindings[[0]].destination != 0 then
        return FALSE;
    end;
    let binding = _BundleTileBindings[[0]];
    if !binding.destination_valid || binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) || !binding.last then
        return FALSE;
    end;
    if decoded == TileOperation_TUNPACK then
        return binding.source0_valid && !binding.source1_valid;
    end;
    return binding.source0_valid && binding.source1_valid;
end;
