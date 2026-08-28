<!-- GENERATED FROM: asl/block/model/dispatch/tcvt-destination.asl -->
# Tcvt Destination

**Normative ASL source:** `asl/block/model/dispatch/tcvt-destination.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tcvt-destination.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION","surface":"block","classification":["model","dispatch","tcvt-destination"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION","PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","PTO-TILE-MODEL-STATE-ALLOCATION"]}
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
    let valid_rows = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) as integer {1..65535}
        else 1;
    let capacity_bytes = BundleLocalDestinationAllocationBytes(0);
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
           destination_type, source_layout, TileLocation_Matrix,
           binding.pe_mask) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    _BundleTileBindings[[0]].destination = resolved;
    _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
