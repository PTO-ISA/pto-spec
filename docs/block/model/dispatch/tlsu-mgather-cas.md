<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-mgather-cas.asl -->
# TLSU Mgather Cas

**Normative ASL source:** `asl/block/model/dispatch/tlsu-mgather-cas.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-cas-purpose role=purpose-scope -->
## Purpose and scope

This unit is the bundle-level handler for `MGATHER.CAS`, the indexed compare-and-swap. For each active lane it reads the old global-memory value, writes the replacement when the old value equals the expected value, and returns the old value in a new Local Tile.

`BundleMGATHERCASSelected` recognizes the bundle: a valid `TileMemory` operation descriptor whose selector function (bits `4:0`) is `8`. `ExecuteBundleMGATHERCASOperation` validates the complete bundle, resolves the destination, and calls the Tile-level `MGATHER_CAS` effect.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-cas-concepts role=concepts-state -->
## Concepts and visible state

A compare-and-swap needs three Tile sources, so the schema uses two `B.IOT` commands. `BundleMGATHERCASBindingsLegal` requires exactly two Tile bindings.

- The first `B.IOT` carries the index Tile in `source0` and the expected-value Tile in `source1`. It has no destination, a destination size of zero, and no `last` flag.
- The second `B.IOT` carries the destination, the replacement Tile in `source0`, and `last`. It carries `source1` only when a predicate-Tile execution mask is in force.
- One `B.IOR` record is required. Its `source0` selects the GPR that holds the base address for the current memory agent.
- `B.DIM` gives valid columns, valid rows, and physical columns, checked by `BundleMGATHERDimensionsLegal`.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-cas-rules role=rules-interactions -->
## Rules and interactions

The handler first returns success with no effect when `SelectedBundleTileMaskIsZero` holds.

An unknown TLSU operation code raises `Fault_IllegalInstruction`. Every other check below raises `Fault_TileLegality` before the destination is resolved.

- No `B.IOS` binding, a present and legal `B.IOR`, a uniform PE mask, legal dimensions, and the two-binding schema.
- The index, expected, and replacement Tiles all have defined contents and the bundle layout. The index Tile is S32, U32, S64, or U64.
- The operation data type is U16, U32, or U64, and the expected and replacement Tiles have that type.
- All three source Tiles have exactly the `B.DIM` valid rows and valid columns, and the physical shape is legal.

The handler then resolves the destination with the `B.DIM` shape and the operation data type, and validates Local generation writers. The destination comes from the second binding. A later failure, or a memory fault inside `MGATHER_CAS`, calls `RollBackBundleTileDestinations`. Success calls `FinalizeBundleTileAttempt`, which publishes the destination.

Design point: the data type set is restricted to unsigned 16, 32, and 64 bit values. The comparison is a bit-pattern equality, and floating or signed types are not admitted by this handler.

Design point: `MGATHER_CAS` probes each active address for both read and write before it performs the first store. A permission or translation fault therefore occurs before any compare-and-swap takes effect.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-cas-boundaries role=boundaries -->
## Architectural boundaries

`ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` tests `BundleMGATHERCASSelected` right after `BundleGMOVSelected` and before `BundleGMAtomRedSelected`. The atomic-and-reduction selector also covers function `8`, but because this selector is tested first, a function `8` bundle that no earlier selector (such as CUBE transport) claims reaches this handler.

The comparison, store, and atomic-event record belong to the Tile atomics owner.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-cas-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose a U32 bundle sets `LB0` to 8, `LB1` to 1, and `LB2` to 8. The first `B.IOT` names a U64 index Tile and a U32 expected Tile, both 1 by 8. The second names a U32 replacement Tile of 1 by 8 and a destination. Each of the 8 lanes reads its old word. A lane whose old word equals its expected word stores the replacement. The destination receives all 8 old words.

If the expected Tile were S32, the bundle raises `Fault_TileLegality` before the destination is allocated.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-cas-related role=related-owners-navigation -->
## Related owners

- [MGATHER dispatch](tlsu-mgather.md) defines the shared dimension check.
- [GM atomic and reduction dispatch](tlsu-gm-atom-red.md) handles the other atomic functions.
- [Atomics memory](../../../tile/model/memory/atomics.md) defines `MGATHER_CAS`.
- [BSTART.MGATHER.CAS](../../execution/BSTART.MGATHER.CAS.md) is the instruction page for the start form.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-mgather-cas.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS","surface":"block","classification":["model","dispatch","tlsu-mgather-cas"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER","PTO-TILE-MODEL-MEMORY-ATOMICS"]}

readonly func BundleMGATHERCASSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 8;
end;

readonly func BundleMGATHERCASBindingsLegal() => boolean
begin
    if BundleTileBindingCount() != 2 then return FALSE; end;
    let first = _BundleTileBindings[[0]];
    let second = _BundleTileBindings[[1]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    return first.valid && !first.destination_valid &&
           first.source0_valid && first.source1_valid && !first.last &&
           first.destination_size == 0 &&
           second.valid && second.destination_valid &&
           second.source0_valid &&
           (second.source1_valid == execution_mask_tile) && second.last;
end;

func ExecuteBundleMGATHERCASOperation() => boolean
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
       !BundleMGATHERCASBindingsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let first = _BundleTileBindings[[0]];
    let second = _BundleTileBindings[[1]];
    let indices = first.source0;
    let expected = first.source1;
    let replacement = second.source0;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !IndexedTLSUExecutionMaskContentsDefined(indices) ||
       !IndexedTLSUExecutionMaskContentsDefined(expected) ||
       !IndexedTLSUExecutionMaskContentsDefined(replacement) ||
       !IndexedTLSUMemoryIndexDataTypeLegal(_Tiles[[indices]].data_type) ||
       !(data_type == TileDataType_U16 ||
         data_type == TileDataType_U32 ||
         data_type == TileDataType_U64) ||
       _Tiles[[expected]].data_type != data_type ||
       _Tiles[[replacement]].data_type != data_type ||
       _Tiles[[indices]].layout != CurrentBundleTileLayout() ||
       _Tiles[[expected]].layout != CurrentBundleTileLayout() ||
       _Tiles[[replacement]].layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if _Tiles[[indices]].valid_rows != valid_rows ||
       _Tiles[[indices]].valid_columns != valid_columns ||
       _Tiles[[expected]].valid_rows != valid_rows ||
       _Tiles[[expected]].valid_columns != valid_columns ||
       _Tiles[[replacement]].valid_rows != valid_rows ||
       _Tiles[[replacement]].valid_columns != valid_columns ||
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
    let destination = _BundleTileBindings[[1]].destination;
    let pad_value = CurrentBundlePadValue();
    if !TileOperandsLegal_MGATHER_CAS(destination, Zeros{PTO_XLEN},
           indices, expected, replacement,
           pad_value) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    MGATHER_CAS(destination, base_address, indices, expected, replacement,
        pad_value);
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
