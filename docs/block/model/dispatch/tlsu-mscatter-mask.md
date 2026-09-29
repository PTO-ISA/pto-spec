<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-mscatter-mask.asl -->
# TLSU Mscatter Mask

**Normative ASL source:** `asl/block/model/dispatch/tlsu-mscatter-mask.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER-MASK}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-mask-purpose role=purpose-scope -->
## Purpose and scope

This unit is the bundle-level handler for `MSCATTER.MASK`, the indexed store that writes only lanes whose predicate Tile bit is set.

`BundleMSCATTERMASKSelected` recognizes the bundle: a valid `TileMemory` operation descriptor whose selector function (bits `4:0`) is `7`. `ExecuteBundleMSCATTERMASKOperation` validates the complete bundle and calls the Tile-level `MSCATTER_MASK` effect. Like plain scatter, it produces no Tile and resolves no destination.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-mask-concepts role=concepts-state -->
## Concepts and visible state

The form always uses two `B.IOT` commands, as `BundleMSCATTERMASKBindingsLegal` requires.

- The first `B.IOT` carries the data Tile in `source0` and the index Tile in `source1`. It has no destination, a destination size of zero, and no `last` flag.
- The second `B.IOT` carries the operation's mask Tile in `source0`, no destination, a destination size of zero, and `last`. It carries `source1` only when a predicate-Tile execution mask is in force.
- One `B.IOR` record is required. Its `source0` selects the GPR that holds the base address for the current memory agent.
- `B.DIM` gives valid columns, valid rows, and physical columns, which must equal the data Tile's own values.

The mask Tile is the operation's predicate operand. It is separate from an optional execution mask, which is an extra final source.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-mask-rules role=rules-interactions -->
## Rules and interactions

The handler first returns success with no effect when `SelectedBundleTileMaskIsZero` holds.

An unknown TLSU operation code raises `Fault_IllegalInstruction`. Every other check below raises `Fault_TileLegality` before the first memory probe.

- No `B.IOS` binding, a present and legal `B.IOR`, a uniform PE mask, dimensions accepted by `BundleMGATHERDimensionsLegal`, and the two-binding schema.
- The data and index Tiles have defined contents, and the mask Tile passes `IndexedTLSUPredicateValuesLegal`. All three have the bundle layout.
- The data Tile has the operation data type, which passes `IndexedTLSUOrdinaryTransferDataTypeLegal`. The index Tile is S32, U32, S64, or U64.
- The data Tile valid rows, valid columns, and physical columns equal the `B.DIM` values. The data shape matches the index shape, the mask shape equals the index valid shape, and the physical shape is legal.
- `TileOperandsLegal_MSCATTER_MASK` holds.

On success the handler calls `FinalizeBundleTileAttempt`. A memory fault from `MSCATTER_MASK` returns failure with no destination to roll back.

Design point: the form needs a data Tile, an index Tile, and a mask Tile. One `B.IOT` holds at most two sources, so the mask always moves to a second command, even without an execution mask. This differs from plain `MSCATTER`, whose second command appears only for an execution mask.

Design point: a lane is probed and stored only when it is active under the execution mask and its predicate bit is set. A lane with a clear predicate bit forms no address, so its index value cannot cause a fault.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-mask-boundaries role=boundaries -->
## Architectural boundaries

This unit runs only after `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` finds no earlier specialized selector. `BundleMSCATTERMASKSelected` is tested after plain `MSCATTER` and before `TPREFETCH`.

Predicate bit reading and the scatter commit order belong to the Tile gather and scatter owner.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-mask-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose the data Tile is S16, RowMajor, with 4 valid rows, 8 valid columns, and 8 physical columns, and `B.DIM` sets `LB0` to 8, `LB1` to 4, and `LB2` to 8. The first `B.IOT` names the data Tile and a U32 index Tile of 4 by 8. The second names a mask Tile of 4 by 8 and carries `last`. If the mask sets 10 of the 32 lanes, the scatter probes and stores 10 addresses.

If the second `B.IOT` were omitted, the binding count is 1 and the bundle raises `Fault_TileLegality`.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-mask-related role=related-owners-navigation -->
## Related owners

- [MSCATTER dispatch](tlsu-mscatter.md) handles the unpredicated form.
- [MGATHER dispatch](tlsu-mgather.md) defines the shared dimension check.
- [Gather and scatter memory](../../../tile/model/memory/gather-scatter.md) defines `MSCATTER_MASK`.
- [BSTART.MSCATTER.MASK](../../execution/BSTART.MSCATTER.MASK.md) is the instruction page for the start form.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-mscatter-mask.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER-MASK","surface":"block","classification":["model","dispatch","tlsu-mscatter-mask"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"]}

readonly func BundleMSCATTERMASKSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 7;
end;

readonly func BundleMSCATTERMASKBindingsLegal() => boolean
begin
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if BundleTileBindingCount() != 2 then return FALSE; end;
    let first = _BundleTileBindings[[0]];
    let second = _BundleTileBindings[[1]];
    return first.valid && !first.destination_valid &&
           first.destination_size == 0 && first.source0_valid &&
           first.source1_valid && !first.last &&
           second.valid && !second.destination_valid &&
           second.destination_size == 0 && second.source0_valid &&
           (second.source1_valid == execution_mask_tile) && second.last;
end;

func ExecuteBundleMSCATTERMASKOperation() => boolean
begin
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
       !BundleMSCATTERMASKBindingsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let source = _BundleTileBindings[[0]].source0;
    let indices = _BundleTileBindings[[0]].source1;
    let mask = _BundleTileBindings[[1]].source0;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if !IndexedTLSUExecutionMaskContentsDefined(source) ||
       !IndexedTLSUExecutionMaskContentsDefined(indices) ||
       !IndexedTLSUPredicateValuesLegal(mask) ||
       _Tiles[[source]].data_type != data_type ||
       !IndexedTLSUMemoryIndexDataTypeLegal(_Tiles[[indices]].data_type) ||
       !IndexedTLSUOrdinaryTransferDataTypeLegal(data_type) ||
       _Tiles[[source]].valid_rows != valid_rows ||
       _Tiles[[source]].valid_columns != valid_columns ||
       _Tiles[[source]].columns != columns ||
       !IndexedTLSUDataShapeMatchesIndex(
           _Tiles[[source]].valid_rows, _Tiles[[source]].valid_columns,
           _Tiles[[indices]].valid_rows, _Tiles[[indices]].valid_columns,
           data_type) ||
       _Tiles[[mask]].valid_rows != _Tiles[[indices]].valid_rows ||
       _Tiles[[mask]].valid_columns != _Tiles[[indices]].valid_columns ||
       !IndexedTLSUPhysicalShapeLegal(CurrentBundleTileLayout(), data_type,
           valid_rows, valid_columns, columns) ||
       _Tiles[[source]].layout != CurrentBundleTileLayout() ||
       _Tiles[[indices]].layout != CurrentBundleTileLayout() ||
       _Tiles[[mask]].layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
    if !TileOperandsLegal_MSCATTER_MASK(
           Zeros{PTO_XLEN}, source, indices, mask) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    MSCATTER_MASK(base_address, source, indices, mask);
    if _LastFault != Fault_None then return FALSE; end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
