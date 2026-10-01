<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-mgather-mask.asl -->
# TLSU Mgather Mask

**Normative ASL source:** `asl/block/model/dispatch/tlsu-mgather-mask.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-mask-purpose role=purpose-scope -->
## Purpose and scope

This unit is the bundle-level handler for `MGATHER.MASK`, the indexed load that reads global memory only for lanes whose predicate Tile bit is set.

`BundleMGATHERMASKSelected` recognizes the bundle: a valid `TileMemory` operation descriptor whose selector function (bits `4:0`) is `6`. `ExecuteBundleMGATHERMASKOperation` validates the complete bundle, resolves the destination, and calls the Tile-level `MGATHER_MASK` effect.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-mask-concepts role=concepts-state -->
## Concepts and visible state

The operands are a base address, an index Tile, and a mask Tile. The mask Tile is the operation's own predicate operand, distinct from an optional execution mask.

- One `B.IOR` record is required. Its `source0` selects the GPR that holds the base address for the current memory agent.
- Without a predicate-Tile execution mask, one `B.IOT` carries the destination, the index Tile in `source0`, the mask Tile in `source1`, and `last`.
- With a predicate-Tile execution mask, the first `B.IOT` carries the index and mask Tiles but no destination and no `last`. A second `B.IOT` carries the destination, one source, no `source1`, and `last`.
- `B.DIM` gives the destination valid columns, valid rows, and physical columns, checked by `BundleMGATHERDimensionsLegal`.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-mask-rules role=rules-interactions -->
## Rules and interactions

The handler first returns success with no effect when `SelectedBundleTileMaskIsZero` holds. The ASL comment places this before every schema, source, GPR, dimension, allocation, predicate, address, and fault check.

An unknown TLSU operation code raises `Fault_IllegalInstruction`. Every other check below raises `Fault_TileLegality` before the destination is resolved.

- No `B.IOS` binding, a present `B.IOR`, complete and legal `B.IOR` values, a uniform PE mask, legal dimensions, and the binding layout from `BundleMGATHERMASKBindingsLegal`.
- The index Tile has defined contents, an S32, U32, S64, or U64 type, and the bundle layout.
- The mask Tile passes `IndexedTLSUPredicateValuesLegal` and has the bundle layout.
- The data shape matches the index shape, the mask has the destination valid rows and the index valid columns, and the physical shape is legal.

After these checks the handler resolves the destination and validates Local generation writers. Under a predicate-Tile execution mask the destination is taken from the second binding. A later failure or a memory fault inside `MGATHER_MASK` calls `RollBackBundleTileDestinations`. Success calls `FinalizeBundleTileAttempt`.

Design point: the mask Tile is checked with the predicate-value helper before any address is formed. `MGATHER_MASK` then probes only lanes that are active under the execution mask and whose predicate bit is set. A lane with a clear predicate bit issues no memory access and keeps the pad value from `CurrentBundlePadValue`.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-mask-boundaries role=boundaries -->
## Architectural boundaries

This unit runs only after `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` finds no earlier specialized selector. `BundleMGATHERMASKSelected` is tested after the `MGATHER.CAS` and atomic-or-reduction selectors and before plain `MGATHER`.

The meaning of a predicate bit, the byte-displacement address rule, and the load-event order belong to the Tile gather and scatter owner.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-mask-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose a bundle with no execution mask gathers U16 values into a RowMajor destination with `LB0` equal to 16, `LB1` equal to 2, and `LB2` equal to 16. The single `B.IOT` names a U32 index Tile and a mask Tile, both 2 by 16. If the mask sets 20 of the 32 lanes, the gather probes and loads 20 addresses. The other 12 destination elements hold the pad value.

If the mask Tile had 3 valid rows, the bundle raises `Fault_TileLegality` before the destination is allocated.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-mask-related role=related-owners-navigation -->
## Related owners

- [MGATHER dispatch](tlsu-mgather.md) defines the shared dimension check.
- [Tile execution dispatch](tile-execution.md) orders the specialized selectors.
- [Gather and scatter memory](../../../tile/model/memory/gather-scatter.md) defines `MGATHER_MASK`.
- [BSTART.MGATHER.MASK](../../execution/BSTART.MGATHER.MASK.md) is the instruction page for the start form.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-mgather-mask.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK","surface":"block","classification":["model","dispatch","tlsu-mgather-mask"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"]}

readonly func BundleMGATHERMASKSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 6;
end;

readonly func BundleMGATHERMASKBindingsLegal() => boolean
begin
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if BundleTileBindingCount() != (if execution_mask_tile then 2 else 1) then
        return FALSE;
    end;
    let binding = _BundleTileBindings[[0]];
    if !binding.valid || !binding.source0_valid ||
       !binding.source1_valid then return FALSE; end;
    if !execution_mask_tile then
        return binding.destination_valid && binding.last;
    end;
    if binding.destination_valid || binding.last then return FALSE; end;
    let mask_binding = _BundleTileBindings[[1]];
    return mask_binding.valid && mask_binding.destination_valid &&
           mask_binding.source0_valid && !mask_binding.source1_valid &&
           mask_binding.last;
end;

func ExecuteBundleMGATHERMASKOperation() => boolean
begin
    // PE_MASK=0000 is a strict no-op before every schema, source, GPR,
    // dimension, allocation, predicate, address, and fault check.
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if BundleSharedBindingCount() != 0 ||
       !_BundleScalarBindings[[0]].valid ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       !BundleMGATHERDimensionsLegal() ||
       !BundleMGATHERMASKBindingsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let indices = binding.source0;
    let mask = binding.source1;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !IndexedTLSUExecutionMaskContentsDefined(indices) ||
       !IndexedTLSUPredicateValuesLegal(mask) ||
       !IndexedTLSUMemoryIndexDataTypeLegal(_Tiles[[indices]].data_type) ||
       !IndexedTLSUOrdinaryTransferDataTypeLegal(data_type) ||
       _Tiles[[indices]].layout != CurrentBundleTileLayout() ||
       _Tiles[[mask]].layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if !IndexedTLSUDataShapeMatchesIndex(
           valid_rows, valid_columns,
           _Tiles[[indices]].valid_rows, _Tiles[[indices]].valid_columns,
           data_type) ||
       _Tiles[[mask]].valid_rows != valid_rows ||
       _Tiles[[mask]].valid_columns != _Tiles[[indices]].valid_columns ||
       !IndexedTLSUPhysicalShapeLegal(CurrentBundleTileLayout(), data_type,
           valid_rows, valid_columns, columns) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
    if !ResolveBundleTileDestinationsWithShapeAndType(TRUE, valid_rows,
           valid_columns, columns, TRUE, data_type) then return FALSE; end;
    if !ValidateBundleLocalGenerationWriters() then
        RollBackBundleTileDestinations(); return FALSE;
    end;
    let destination = if _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile
        then _BundleTileBindings[[1]].destination
        else _BundleTileBindings[[0]].destination;
    let pad_value = CurrentBundlePadValue();
    if !TileOperandsLegal_MGATHER_MASK(destination, Zeros{PTO_XLEN},
           indices, mask, pad_value) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    MGATHER_MASK(destination, base_address, indices, mask, pad_value);
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
