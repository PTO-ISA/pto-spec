<!-- GENERATED FROM: asl/block/model/dispatch/predicate-destination.asl -->
# Predicate Destination

**Normative ASL source:** `asl/block/model/dispatch/predicate-destination.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-PREDICATE-DESTINATION}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/predicate-destination.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-PREDICATE-DESTINATION","surface":"block","classification":["model","dispatch","predicate-destination"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","PTO-TILE-MODEL-STATE-ALLOCATION"]}

readonly func BundleFirstDestinationBinding()
    => (boolean, BundleTileBindingIndex)
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            return (TRUE, binding as BundleTileBindingIndex);
        end;
    end;
    return (FALSE, 0);
end;

readonly func BundleFreeDestinationIndex(
    binding: BundleTileBindingIndex) => (boolean, TileIndex)
begin
    let hand = UInt(_BundleTileBindings[[binding]].destination_hand);
    for offset = 0 to 15 do
        let raw_index: integer = hand * 16 + offset;
        if !_Tiles[[raw_index]].allocated then
            return (TRUE, raw_index as TileIndex);
        end;
    end;
    return (FALSE, 0);
end;

func ResolveBundlePredicateDestination() => boolean
begin
    let (destination_seen, destination_binding) =
        BundleFirstDestinationBinding();
    if !destination_seen then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    let binding = _BundleTileBindings[[destination_binding]];
    let source = BundleTileSourceIndex(destination_binding, FALSE);
    let source_tile = _Tiles[[source]];
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        destination_binding);
    let cube = source_tile.layout == TileLayout_CUBE_M16 ||
        source_tile.layout == TileLayout_CUBE_M32;
    if binding.destination_allocated_by_bundle then
        let destination = binding.destination;
        let destination_tile = _Tiles[[destination]];
        let descriptor_legal = if cube then
            TilePredicateCellDescriptorLegal(destination) &&
            destination_tile.predicate_basis_type == source_tile.data_type &&
            destination_tile.valid_rows == source_tile.valid_rows &&
            destination_tile.valid_columns == source_tile.valid_columns &&
            destination_tile.layout == source_tile.layout
        else
            TileDescriptorLegal(destination) &&
            destination_tile.storage_kind == TileStorage_Predicate &&
            destination_tile.rows == source_tile.rows &&
            destination_tile.columns == source_tile.columns &&
            destination_tile.valid_rows == source_tile.valid_rows &&
            destination_tile.valid_columns == source_tile.valid_columns &&
            destination_tile.layout == TileLayout_RowMajor;
        if !descriptor_legal ||
           _TileAllocationMasks[[destination]] != binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    if cube then
        if !TileCubePredicateDataTypeSupported(source_tile.data_type) ||
           !TileCubeDescriptorShapeLegal(
               capacity_bytes, source_tile.valid_rows,
               source_tile.valid_columns, TileDataType_U8,
               source_tile.layout) then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
    elsif source_tile.storage_kind != TileStorage_Numeric ||
          source_tile.rows * source_tile.columns >
              TileLogicalElementCapacity(
                  source_tile.capacity_bytes, source_tile.data_type) ||
          PredicateTileStorageBytes(
              source_tile.rows, source_tile.columns) > capacity_bytes then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    if !LocalTileAllocationFits(binding.pe_mask, capacity_bytes) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let (found, resolved) = BundleFreeDestinationIndex(destination_binding);
    if !found then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    if cube then
        if !ConfigurePredicateCellForMask(
               resolved, capacity_bytes, source_tile.valid_rows,
               source_tile.valid_columns, source_tile.data_type,
               source_tile.layout, binding.pe_mask) then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
    else
        ConfigurePredicateTileForMask(
            resolved, capacity_bytes, source_tile.rows, source_tile.columns,
            source_tile.valid_rows, source_tile.valid_columns,
            binding.pe_mask);
    end;
    _BundleTileBindings[[destination_binding]].destination = resolved;
    _BundleTileBindings[[destination_binding]].destination_allocated_by_bundle =
        TRUE;
    return TRUE;
end;

readonly func BundleComparisonSelectTrueSource(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => TileIndex
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TSEL && BundleTileBindingCount() == 2 then
        return BundleTileSourceIndex(0, TRUE);
    end;
    if decoded == TileOperation_TSELS &&
       _BundleTileBindings[[0]].source1_valid then
        return BundleTileSourceIndex(0, TRUE);
    end;
    return BundleTileSourceIndex(0, FALSE);
end;

func ResolveBundleCUBESelectDestination(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let (destination_seen, destination_binding) =
        BundleFirstDestinationBinding();
    if !destination_seen then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    let source = BundleComparisonSelectTrueSource(operation);
    let source_tile = _Tiles[[source]];
    let binding = _BundleTileBindings[[destination_binding]];
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        destination_binding);
    if !TileCubeDescriptorLegal(source_tile) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    if binding.destination_allocated_by_bundle then
        let destination_tile = _Tiles[[binding.destination]];
        if !TileCubeDescriptorLegal(destination_tile) ||
           destination_tile.storage_kind != TileStorage_Numeric ||
           destination_tile.valid_rows != source_tile.valid_rows ||
           destination_tile.valid_columns != source_tile.valid_columns ||
           destination_tile.data_type != source_tile.data_type ||
           destination_tile.layout != source_tile.layout ||
           _TileAllocationMasks[[binding.destination]] != binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    if !TileCubeDescriptorShapeLegal(
           capacity_bytes, source_tile.valid_rows,
           source_tile.valid_columns, source_tile.data_type,
           source_tile.layout) ||
       !LocalTileAllocationFits(binding.pe_mask, capacity_bytes) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let (found, resolved) = BundleFreeDestinationIndex(destination_binding);
    if !found || !ConfigureCubeTileForMask(
           resolved, capacity_bytes, source_tile.valid_rows,
           source_tile.valid_columns, source_tile.data_type,
           source_tile.layout, TileLocation_Matrix,
           binding.pe_mask) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    _BundleTileBindings[[destination_binding]].destination = resolved;
    _BundleTileBindings[[destination_binding]].destination_allocated_by_bundle =
        TRUE;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
