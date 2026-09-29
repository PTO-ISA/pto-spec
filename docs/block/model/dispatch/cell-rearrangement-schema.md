<!-- GENERATED FROM: asl/block/model/dispatch/cell-rearrangement-schema.asl -->
# Cell Rearrangement Schema

**Normative ASL source:** `asl/block/model/dispatch/cell-rearrangement-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-cell-rearrangement-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the bundle operand schema and destination allocation for the four CUBE cell-rearrangement operations: `TPERMUTE`, `TSHUF`, `TPACK`, and `TUNPACK`. These operations move bytes or words within Local CUBE Tiles without numeric conversion.

It defines three functions:

- `TileOperationUsesCellRearrangementSchema` recognizes the four operations.
- `SelectedBundleCellRearrangementSchemaLegal` checks that the collected `B.IOT` and `B.IOR` records have the exact shape the selected operation requires.
- `ResolveBundleCellRearrangementDestination` derives the destination descriptor from the source Tile and allocates or checks the destination register.

<!-- PTO-READER-BLOCK: block-model-dispatch-cell-rearrangement-schema-concepts role=concepts-state -->
## Concepts and visible state

The schema check reads header state, for example `_BundleTileBindings` (the `B.IOT` records), `_BundleScalarBindings` (the `B.IOR` records), `_BundleExecutionMask`, and the Shared binding count.

The destination resolver reads the source descriptors in `_Tiles` and, when it succeeds, writes three things:

- a new CUBE Tile descriptor through `ConfigureCubeTileForMask`;
- the resolved absolute index into the destination binding's `destination` field;
- `destination_allocated_by_bundle` set to true on that binding.

For `TPACK` and `TUNPACK`, the destination data type is the operation `DataType` selected by the bundle, and it must be `U8`, `U16`, or `U32`. For `TPERMUTE` and `TSHUF`, the destination keeps the source data type and valid column count. In all four cases, the destination keeps the source valid row count and layout.

<!-- PTO-READER-BLOCK: block-model-dispatch-cell-rearrangement-schema-rules role=rules-interactions -->
## Rules and interactions

The schema check returns true immediately when `SelectedBundleTileMaskIsZero` holds, for example when every valid Tile binding has PE mask `0000`. Otherwise it applies one of two shapes.

- `TPERMUTE` needs exactly two Tile bindings. The first carries two sources and no destination. The second carries a third source and the new destination and ends the sequence. Its source must differ from both first-binding sources. A `B.IOR` record is present only when the ExecutionMask is carried in a GPR.
- `TSHUF`, `TPACK`, and `TUNPACK` need one `B.IOR` record for the control word and one Tile binding, or two bindings when a Tile-carried ExecutionMask is added to a two-source operation. `TSHUF` and `TPACK` use two sources; `TUNPACK` uses one.

Design point: the Tile execution owner calls this schema check before the generic closed-schema check and maps its failure to `Fault_BundleControl`. The ASL comment states the reason: a missing or surplus `B.IOR` or `B.IOT` control is bundle structure. A malformed bundle is therefore reported as a bundle-control fault, not as a Tile legality fault.

For `TPACK` and `TUNPACK`, the destination column count is the source words per row times the destination elements per word: 4 for `U8`, 2 for `U16`, and 1 for `U32`. Words per row come from the source valid bytes rounded up to 4-byte words. `TPACK` also requires the second source to have the same layout, valid row count, and words per row as the first.

Design point: the destination shape is derived from the source descriptor, not from `B.DIM`. The macro assembly reference records the consequence: `TPACK` and `TUNPACK` have no encoded shape, so their Row and Col depend on runtime descriptor state.

A missing role, an illegal source descriptor or type, or a reused-destination mismatch raises `Fault_TileLegality`. More than 65535 destination columns, an illegal CUBE shape, no free register, or insufficient capacity raises `Fault_TileAllocation`.

<!-- PTO-READER-BLOCK: block-model-dispatch-cell-rearrangement-schema-boundaries role=boundaries -->
## Architectural boundaries

This unit performs no data movement. The byte and word semantics, control-word checks, and source definedness belong to the Tile legality and execution owners.

When the destination binding is reused by an assemble generation, the resolver allocates nothing. It only checks that the existing descriptor matches the derived capacity, shape, type, layout, and PE mask.

Design point: the resolver marks a fresh destination with `destination_allocated_by_bundle`. `RollBackBundleTileDestinations` releases exactly those marked registers, so when a later writer validation or the operation itself fails, the Tile execution owner releases the new Tile.

<!-- PTO-READER-BLOCK: block-model-dispatch-cell-rearrangement-schema-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

```text
TPACK <U32>, T#1, T#2, a0, ->T<2KB>
```

Suppose `T#1` and `T#2` are Local `U32` `CUBE_M16` Tiles with 8 valid rows and 8 valid columns. Each source row holds 32 valid bytes, which is 8 words. `U32` places 1 element in each word, so the destination is `U32` `CUBE_M16` with 8 valid rows and 8 valid columns. The resolver takes the first free register among the 16 of the encoded destination hand and allocates it with 2048 bytes, provided that CUBE shape fits.

<!-- PTO-READER-BLOCK: block-model-dispatch-cell-rearrangement-schema-related role=related-owners-navigation -->
## Related owners

- [Tile execution dispatch](tile-execution.md) orders this schema check before generic schemas and destination resolution.
- [Destination operation routing](destination-operation.md) sends the four operations to this resolver.
- [Layout rearrangement legality](../../../tile/model/legality/layout-rearrangement.md) defines descriptor, type, and words-per-row helpers.
- [Rollback](../faults/rollback.md) releases destinations marked as allocated by the bundle.
- [TPACK](../../../tile/layout-and-rearrangement/layout/TPACK.md) is the instruction page for one of the four operations.
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
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    if decoded == TileOperation_TPERMUTE then
        if BundleTileBindingCount() != 2 || BundleSharedBindingCount() != 0 ||
           (_BundleScalarBindings[[0]].valid != execution_mask_gpr) ||
           (execution_mask_gpr &&
            !BundleExecutionMaskGPRBindingSchemaLegal(operation)) then
            return FALSE;
        end;
        let first = _BundleTileBindings[[0]];
        let second = _BundleTileBindings[[1]];
        return !first.destination_valid && first.source0_valid &&
               first.source1_valid && !first.last && second.destination_valid &&
               !second.destination_allocated_by_bundle && second.source0_valid &&
               (second.source1_valid == execution_mask_tile) && second.last &&
               (!execution_mask_tile ||
                _BundleExecutionMask.predicate_source_ordinal == 3) &&
               second.source0 != first.source0 &&
               second.source0 != first.source1 &&
               BundleTileDestinationSizeLegal(1);
    end;
    let operation_uses_source1 = decoded == TileOperation_TSHUF ||
        decoded == TileOperation_TPACK;
    let split_final_binding = execution_mask_tile &&
        operation_uses_source1;
    let expected_binding_count = if split_final_binding then 2 else 1;
    if BundleTileBindingCount() != expected_binding_count ||
       BundleSharedBindingCount() != 0 ||
       !_BundleScalarBindings[[0]].valid ||
       (!execution_mask_gpr &&
        (_BundleScalarBindings[[0]].source1 != 0 ||
         _BundleScalarBindings[[0]].source2 != 0)) ||
       (execution_mask_gpr &&
        !BundleExecutionMaskGPRBindingSchemaLegal(operation)) ||
       _BundleScalarBindings[[0]].destination != 0 then
        return FALSE;
    end;
    let binding = _BundleTileBindings[[0]];
    let final_binding = if split_final_binding then
        _BundleTileBindings[[1]] else binding;
    if !final_binding.destination_valid ||
       final_binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(
           if split_final_binding then 1 else 0) ||
       (if split_final_binding then
            binding.destination_valid || !binding.source0_valid ||
            !binding.source1_valid || binding.last ||
            !final_binding.source0_valid || final_binding.source1_valid ||
            !final_binding.last
        else
            !binding.source0_valid ||
            (binding.source1_valid !=
                (operation_uses_source1 || execution_mask_tile)) ||
            !binding.last) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal !=
            (if operation_uses_source1 then 2 else 1)) then
        return FALSE;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
