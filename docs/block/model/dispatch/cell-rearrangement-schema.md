<!-- GENERATED FROM: asl/block/model/dispatch/cell-rearrangement-schema.asl -->
# Cell Rearrangement Schema

**Normative ASL source:** `asl/block/model/dispatch/cell-rearrangement-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/cell-rearrangement-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA","surface":"block","classification":["model","dispatch","cell-rearrangement-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"]}

func ResolveBundleCellRearrangementDestination(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    var destination_binding: BundleTileBindingIndex = 0;
    var destination_seen = FALSE;
    var source: TileIndex = 0;
    var source1: TileIndex = 0;
    var source_seen = FALSE;
    var source1_seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid then
            if !destination_seen &&
               _BundleTileBindings[[binding]].destination_valid then
                destination_binding = binding as BundleTileBindingIndex;
                destination_seen = TRUE;
            end;
            if !source_seen && _BundleTileBindings[[binding]].source0_valid then
                source = BundleTileSourceIndex(
                    binding as BundleTileBindingIndex, FALSE);
                source_seen = TRUE;
            end;
            if !source1_seen && _BundleTileBindings[[binding]].source1_valid then
                source1 = BundleTileSourceIndex(
                    binding as BundleTileBindingIndex, TRUE);
                source1_seen = TRUE;
            end;
        end;
    end;
    let decoded = TileOperationOfIndex(operation);
    let pack_unpack = decoded == TileOperation_TPACK ||
                      decoded == TileOperation_TUNPACK;
    if !destination_seen || !source_seen ||
       !TileCellRearrangementDescriptorLegal(source) ||
       (decoded == TileOperation_TPACK && !source1_seen) ||
       (source1_seen &&
        !TileCellRearrangementDescriptorLegal(source1)) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let binding = _BundleTileBindings[[destination_binding]];
    let source_tile = _Tiles[[source]];
    let source_semantics_legal = !pack_unpack ||
        (source_tile.storage_kind == TileStorage_Numeric &&
         TileCellRearrangementDataTypeLegal(source_tile.data_type));
    if !source_semantics_legal then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if decoded == TileOperation_TPACK then
        let source1_tile = _Tiles[[source1]];
        if source1_tile.storage_kind != TileStorage_Numeric ||
           !TileCellRearrangementDataTypeLegal(source1_tile.data_type) ||
           source1_tile.layout != source_tile.layout ||
           source1_tile.valid_rows != source_tile.valid_rows then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        if TileCellRearrangementWordsPerRow(source1_tile) !=
           TileCellRearrangementWordsPerRow(source_tile) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    end;
    let selected_type_valid = !pack_unpack ||
        (BundleTileOperationSelected() &&
         _BundleOperation.data_type_valid &&
         BundleDataTypeConcrete(_BundleOperation.data_type));
    let selected_type = if pack_unpack && selected_type_valid then
        TileDataTypeFromEncoding(
            CurrentBundleTileOperationDataTypeCode()
                as TileDataTypeEncoding)
    else source_tile.data_type;
    let destination_elements_per_word =
        if selected_type == TileDataType_U8 then 4
        else if selected_type == TileDataType_U16 then 2
        else if selected_type == TileDataType_U32 then 1
        else 0;
    if !selected_type_valid ||
       (pack_unpack && destination_elements_per_word == 0) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let destination_columns_unbounded = if pack_unpack then
        (TileCellRearrangementWordsPerRow(source_tile) *
            destination_elements_per_word) as integer {0..262144}
    else source_tile.valid_columns as integer {0..262144};
    let destination_type = if pack_unpack then selected_type
                           else source_tile.data_type;
    if destination_columns_unbounded > 65535 then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let destination_columns = destination_columns_unbounded
        as integer {0..65535};
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        destination_binding);
    if binding.destination_reused_by_generation then
        let destination = _Tiles[[binding.destination]];
        if !TileCubeDescriptorLegal(destination) ||
           destination.capacity_bytes != capacity_bytes ||
           destination.valid_rows != source_tile.valid_rows ||
           destination.valid_columns != destination_columns ||
           destination.data_type != destination_type ||
           destination.layout != source_tile.layout ||
           (_TileAllocationMasks[[binding.destination]] AND binding.pe_mask) !=
               binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    if !TileCubeDescriptorShapeLegal(capacity_bytes,
           source_tile.valid_rows, destination_columns,
           destination_type, source_tile.layout) then
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
        destination_columns, destination_type,
        source_tile.layout, binding.pe_mask);
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
```
<!-- GENERATED-ASL-END: unit -->
