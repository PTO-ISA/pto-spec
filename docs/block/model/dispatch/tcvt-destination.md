<!-- GENERATED FROM: asl/block/model/dispatch/tcvt-destination.asl -->
# Tcvt Destination

**Normative ASL source:** `asl/block/model/dispatch/tcvt-destination.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-destination-purpose role=purpose-scope -->
## Purpose and scope

This unit allocates the destination Tile for a `TCVT` whose source uses a `CUBE_M16` or `CUBE_M32` layout. A CUBE layout stores a Tile as fixed-size cells rather than plain rows, so the destination geometry depends on the destination data type, not only on the source.

`ResolveBundleTCVTCubeDestination` is called by the destination-operation owner when the operation is `TCVT` and the source layout is one of those two CUBE layouts. Other `TCVT` sources use the generic destination path.

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-destination-concepts role=concepts-state -->
## Concepts and visible state

- The destination type comes from `ResolveBundleEffectiveDataType`.
- The destination layout is the source layout.
- The valid region is dimension 0 (valid columns) by dimension 1 (valid rows).
- The capacity is `BundleLocalDestinationAllocationBytes` for binding 0, which is the byte size of its size code.
- The destination hand is a 2-bit field of the binding. It selects a group of 16 Tile indices, `hand * 16` through `hand * 16 + 15`.

On success the unit writes the chosen Tile descriptor through `ConfigureCubeTileForMask`, and sets binding 0's `destination` and `destination_allocated_by_bundle`.

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-destination-rules role=rules-interactions -->
## Rules and interactions

The unit first checks that the destination type resolves and that the source layout is `CUBE_M16` or `CUBE_M32`, raising `Fault_TileAllocation` otherwise, and then takes one of two paths.

When the binding reuses an existing generation destination (`destination_reused_by_generation`), nothing is allocated. The existing Tile must be a legal CUBE descriptor with the same capacity, valid rows, valid columns, destination type, and layout, and it must already be allocated on every PE in the binding's PE mask. A mismatch raises `Fault_TileLegality`.

Otherwise the unit allocates, and each failure raises `Fault_TileAllocation`:

1. The type and layout check above has passed.
2. `TileCubeDescriptorShapeLegal` must accept the capacity, valid region, destination type, and layout.
3. `BundleTCVTCubeDestinationCapacityGroupFits` must confirm that, for each PE selected by the mask, the capacity already in use plus the new capacity stays within `TileCapacityLimitBytes`.
4. The first unallocated index in the hand's group of 16 is chosen. If none is free, the allocation fails.
5. `ConfigureCubeTileForMask` must succeed.

Design point: the ASL comment says CUBE physical rows, columns, and cell count are derived from the destination data type. A wider destination type can therefore need a larger power-of-two size code than the source used. The shape check uses the destination type and the requested capacity, not the source capacity.

Design point: the capacity check is per PE and counts only PEs in the binding's mask. A PE outside the mask gets no allocation, so its free capacity does not limit the conversion.

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-destination-boundaries role=boundaries -->
## Architectural boundaries

This unit runs after the TCVT schema has passed, and it does not repeat the schema checks. It does not convert values, publish the destination, or roll it back. The tile-execution owner rolls back bundle-allocated destinations if a later step fails, and publishes them on success. Non-CUBE `TCVT` destinations are not handled here.

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-destination-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A `TCVT` converts a `CUBE_M16` FP16 source to FP32 with the full mask `1111` and destination hand 2. The unit checks the FP32 shape at the requested size code, then checks the capacity on all four PEs. It then scans Tile indices 32 through 47 and takes the first unallocated one, for example 34. Tile 34 becomes a `CUBE_M16` FP32 descriptor on all four PEs, and binding 0 records 34 as its destination.

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-destination-related role=related-owners-navigation -->
## Related owners

- [TCVT schema](tcvt-schema.md) validates the bundle before this unit runs.
- [Destination operation](destination-operation.md) routes CUBE `TCVT` destinations here.
- [Rollback](../faults/rollback.md) releases a bundle-allocated destination after a later failure.
- [Tile allocation](../../../tile/model/state/allocation.md) defines `ConfigureCubeTileForMask`.
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
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let capacity_bytes = BundleLocalDestinationAllocationBytes(0);
    if binding.destination_reused_by_generation then
        let destination = _Tiles[[binding.destination]];
        if !TileCubeDescriptorLegal(destination) ||
           destination.capacity_bytes != capacity_bytes ||
           destination.valid_rows != valid_rows ||
           destination.valid_columns != valid_columns ||
           destination.data_type != destination_type ||
           destination.layout != source_layout ||
           (_TileAllocationMasks[[binding.destination]] AND binding.pe_mask) !=
               binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
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
```
<!-- GENERATED-ASL-END: unit -->
