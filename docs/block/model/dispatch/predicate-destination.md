<!-- GENERATED FROM: asl/block/model/dispatch/predicate-destination.asl -->
# Predicate Destination

**Normative ASL source:** `asl/block/model/dispatch/predicate-destination.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-PREDICATE-DESTINATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-predicate-destination-purpose role=purpose-scope -->
## Purpose and scope

This unit resolves the destination Tile for comparisons and for CUBE selects. It finds the destination binding, validates or allocates the Tile, and records the chosen register in the binding.

It defines these functions:

- `BundleFirstDestinationBinding` returns the lowest valid binding that has a destination.
- `BundleFreeDestinationIndex` returns the first unallocated register in the destination hand. A hand is one of the four groups of 16 Local registers: T is 0 to 15, U is 16 to 31, M is 32 to 47, and N is 48 to 63.
- `ResolveBundlePredicateDestination` resolves the predicate result of `TCMP` and `TCMPS`.
- `BundleComparisonSelectTrueSource` picks the Tile that supplies the "true" values of `TSEL` or `TSELS`.
- `ResolveBundleCUBESelectDestination` resolves the numeric result of a CUBE `TSEL` or `TSELS`.

<!-- PTO-READER-BLOCK: block-model-dispatch-predicate-destination-concepts role=concepts-state -->
## Concepts and visible state

A comparison writes one of two predicate carriers, chosen by the layout of the first source:

- A `RowMajor` source produces a packed predicate Tile with `TileStorage_Predicate`, one bit per element, stored in `(rows * columns + 7) DIVRM 8` bytes.
- A `CUBE_M16` or `CUBE_M32` source produces a PredicateCell: a `U8` CUBE Tile with `TileStorage_PredicateCell` whose `predicate_basis_type` records the comparison type.

The unit reads `_BundleTileBindings`, the source descriptor in `_Tiles`, `_TileAllocationMasks`, and Local capacity. When it allocates a new Tile, it writes the allocated Tile descriptor, sets the binding `destination` to the chosen register, and sets `destination_allocated_by_bundle`; when it only validates an existing destination, it writes nothing.

<!-- PTO-READER-BLOCK: block-model-dispatch-predicate-destination-rules role=rules-interactions -->
## Rules and interactions

`ResolveBundlePredicateDestination` takes shape and layout from source 0 of binding 0, not from the destination binding. The ASL comment gives the reason: a later binding may carry both the new destination and a PredicateCell ExecutionMask, so it does not own the source type.

If the destination is already resolved for this bundle (allocated by the bundle or reused through a Local generation), the unit only validates it. A PredicateCell must be a legal PredicateCell whose basis type equals the comparison type and whose valid shape and layout equal the source's. A packed predicate Tile must have predicate storage, the same physical and valid shape, and `RowMajor`. Its allocation mask must equal the binding `PE_MASK`. Failure raises `Fault_TileLegality`.

Otherwise it allocates a new Tile:

- For a CUBE source, the comparison type must be a supported CUBE predicate type and width-compatible with the source, and the `U8` CUBE shape must fit the destination size.
- For a `RowMajor` source, the source must be numeric, its physical shape must fit its own capacity, and the predicate storage bytes must fit the destination size.
- Local capacity must fit on every PE in the binding mask, and the hand must have a free register.

Each of these failures raises `Fault_TileAllocation`.

`ResolveBundleCUBESelectDestination` follows the same pattern for a numeric CUBE result. The true source must hold a legal CUBE descriptor. The result has the effective operation type, the source valid shape, and the source layout.

Design point: all checks run before `ConfigurePredicateTileForMask`, `ConfigurePredicateCellForMask`, or `ConfigureCubeTileForMask` changes a descriptor. The caller runs this resolution after the closed schemas have passed. If a later step fails, `RollBackBundleTileDestinations` releases any Tile marked `destination_allocated_by_bundle` that was not reused through a generation.

<!-- PTO-READER-BLOCK: block-model-dispatch-predicate-destination-boundaries role=boundaries -->
## Architectural boundaries

This unit does not compute comparison or select results. It is reached through `ResolveBundleTileDestinationsForOperation` in [destination operation](destination-operation.md): for `TCMP` and `TCMPS` after the effective data type resolves, and for `TSEL` and `TSELS` only when the true source is CUBE. A missing destination binding raises `Fault_BundleControl`. Comparisons that write a GPR carrier do not reach this unit.

<!-- PTO-READER-BLOCK: block-model-dispatch-predicate-destination-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Consider `TCMP <Row=8, Col=64, FP32, LT>, T#1, T#2, ->U<512B>`. The left source `T#1` is a `RowMajor` `FP32` Tile with 8 rows and 64 columns. The predicate needs (8 * 64 + 7) DIVRM 8 = 64 bytes, which fits in 512 bytes. If registers 16 and 17 are allocated and 18 is free, `BundleFreeDestinationIndex` returns 18. The new packed predicate Tile has 8 rows and 64 columns, and the binding records register 18 as its destination.

<!-- PTO-READER-BLOCK: block-model-dispatch-predicate-destination-related role=related-owners-navigation -->
## Related owners

- [Destination operation](destination-operation.md) routes comparisons and CUBE selects to this unit.
- [Comparison schema](comparison-schema.md) validates the comparison bundle before resolution.
- [Tile allocation](../../../tile/model/state/allocation.md) defines the configure functions and predicate storage size.
- [Predicate carrier legality](../../../tile/model/legality/predicate-carriers.md) defines PredicateCell legality.
- [TCMP](../../../tile/elementwise-tile-tile/logical/TCMP.md) is one instruction page that uses this unit.
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

func ResolveBundlePredicateDestination(operation_type: TileDataType) => boolean
begin
    let (destination_seen, destination_binding) =
        BundleFirstDestinationBinding();
    if !destination_seen then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    let binding = _BundleTileBindings[[destination_binding]];
    // Comparison input binding 0 owns the numeric shape and basis.  A later
    // binding may carry both the fresh destination and a PredicateCell
    // ExecutionMask, so the destination binding is not a source-type owner.
    let source = BundleTileSourceIndex(0, FALSE);
    let source_tile = _Tiles[[source]];
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        destination_binding);
    let cube = source_tile.layout == TileLayout_CUBE_M16 ||
        source_tile.layout == TileLayout_CUBE_M32;
    if binding.destination_allocated_by_bundle ||
       binding.destination_reused_by_generation then
        let destination = binding.destination;
        let destination_tile = _Tiles[[destination]];
        let descriptor_legal = if cube then
            TilePredicateCellDescriptorLegal(destination) &&
            destination_tile.predicate_basis_type == operation_type &&
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
        if !TileCubePredicateDataTypeSupported(operation_type) ||
           !TileCarrierWidthCompatible(
               source_tile.data_type, operation_type) ||
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
               source_tile.valid_columns, operation_type,
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
    let first = BundleTileSourceIndex(0, FALSE);
    let cell_select = _BundleTileBindings[[0]].source0_valid &&
        _Tiles[[first]].storage_kind == TileStorage_PredicateCell;
    if (decoded == TileOperation_TSEL || decoded == TileOperation_TSELS) &&
       cell_select then
        return BundleTileSourceIndex(0, TRUE);
    end;
    return first;
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
    let (operation_type_valid, operation_type) =
        ResolveBundleEffectiveDataType();
    if !operation_type_valid then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !TileCubeDescriptorLegal(source_tile) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    if binding.destination_allocated_by_bundle ||
       binding.destination_reused_by_generation then
        let destination_tile = _Tiles[[binding.destination]];
        if !TileCubeDescriptorLegal(destination_tile) ||
           destination_tile.storage_kind != TileStorage_Numeric ||
           destination_tile.valid_rows != source_tile.valid_rows ||
           destination_tile.valid_columns != source_tile.valid_columns ||
           destination_tile.data_type != operation_type ||
           destination_tile.layout != source_tile.layout ||
           _TileAllocationMasks[[binding.destination]] != binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    if !TileCubeDescriptorShapeLegal(
           capacity_bytes, source_tile.valid_rows,
           source_tile.valid_columns, operation_type,
           source_tile.layout) ||
       !LocalTileAllocationFits(binding.pe_mask, capacity_bytes) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let (found, resolved) = BundleFreeDestinationIndex(destination_binding);
    if !found || !ConfigureCubeTileForMask(
           resolved, capacity_bytes, source_tile.valid_rows,
           source_tile.valid_columns, operation_type,
           source_tile.layout,
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
