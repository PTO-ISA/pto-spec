<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-mscatter.asl -->
# TLSU Mscatter

**Normative ASL source:** `asl/block/model/dispatch/tlsu-mscatter.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-purpose role=purpose-scope -->
## Purpose and scope

This unit is the bundle-level handler for plain `MSCATTER`, the indexed store that writes each element of a Local source Tile to a global-memory address formed from an index Tile.

`BundleMSCATTERSelected` recognizes the bundle: a valid `TileMemory` operation descriptor whose selector function (bits `4:0`) is `5`. `ExecuteBundleMSCATTEROperation` validates the complete bundle and calls the Tile-level `MSCATTER` effect. A scatter produces no Tile, so this handler never resolves a destination.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-concepts role=concepts-state -->
## Concepts and visible state

`BundleMSCATTERBindingsLegal` defines the Tile binding schema.

- The first `B.IOT` has no destination and a destination size of zero. It carries the data Tile in `source0` and the index Tile in `source1`.
- Without a predicate-Tile execution mask, that first binding is the only one and carries `last`.
- With a predicate-Tile execution mask, the first binding does not carry `last`. A second `B.IOT` carries the mask Tile in `source0`, no `source1`, no destination, and `last`.
- One `B.IOR` record is required. Its `source0` selects the GPR that holds the base address for the current memory agent.
- `B.DIM` gives valid columns, valid rows, and physical columns. They must equal the data Tile's own values.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-rules role=rules-interactions -->
## Rules and interactions

The handler first returns success with no effect when `SelectedBundleTileMaskIsZero` holds. The ASL comment places this before schema, source, GPR, dimension, address, permission, event, and memory checks.

An unknown TLSU operation code raises `Fault_IllegalInstruction`. Every other check below raises `Fault_TileLegality`, and all of them run before the first memory probe.

- No `B.IOS` binding, a present and legal `B.IOR`, a uniform PE mask, dimensions accepted by `BundleMGATHERDimensionsLegal`, and the binding schema above.
- The data and index Tiles have defined contents and the bundle layout. The data Tile has the operation data type, which must pass `IndexedTLSUOrdinaryTransferDataTypeLegal`. The index Tile is S32, U32, S64, or U64.
- The data shape matches the index shape, the data Tile valid rows, valid columns, and physical columns equal the `B.DIM` values, and the physical shape is legal.
- `TileOperandsLegal_MSCATTER` holds.

On success the handler calls `FinalizeBundleTileAttempt`. A memory fault from `MSCATTER` returns failure; there is no destination to roll back.

Design point: the Tile-level `MSCATTER` probes every active lane for write permission before it commits any store. A translation or permission fault found while probing therefore returns before any store of this scatter.

Design point: the data Tile must match `B.DIM` exactly, including physical columns. Scatter reads an existing Tile rather than creating one, so `B.DIM` restates that Tile's shape instead of describing a new destination.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-boundaries role=boundaries -->
## Architectural boundaries

This unit runs only after `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` finds no earlier specialized selector. `BundleMSCATTERSelected` is tested after plain `MGATHER` and before `MSCATTER.MASK`.

The order in which scattered stores to the same address become visible is owned by `CommitIndexedScatterTransactions` in the Tile gather and scatter owner.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose the data Tile is BF16, RowMajor, with 2 valid rows, 16 valid columns, and 16 physical columns. The bundle sets `LB0` to 16, `LB1` to 2, and `LB2` to 16, and the index Tile is S32 with 2 rows and 16 columns. With no execution mask, the one `B.IOT` names the data Tile then the index Tile and carries `last`. All 32 lanes are probed first, and then 32 stores are committed.

If `LB2` were 32 while the data Tile has 16 physical columns, the bundle raises `Fault_TileLegality` and performs no probe.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-related role=related-owners-navigation -->
## Related owners

- [MGATHER dispatch](tlsu-mgather.md) defines the shared dimension check.
- [MSCATTER.MASK dispatch](tlsu-mscatter-mask.md) handles the predicated form.
- [Gather and scatter memory](../../../tile/model/memory/gather-scatter.md) defines `MSCATTER`.
- [BSTART.MSCATTER](../../execution/BSTART.MSCATTER.md) is the instruction page for the start form.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-mscatter.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER","surface":"block","classification":["model","dispatch","tlsu-mscatter"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"]}

readonly func BundleMSCATTERSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 5;
end;

readonly func BundleMSCATTERBindingsLegal() => boolean
begin
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if BundleTileBindingCount() != (if execution_mask_tile then 2 else 1) then
        return FALSE;
    end;
    let binding = _BundleTileBindings[[0]];
    if !binding.valid || binding.destination_valid ||
       binding.destination_size != 0 || !binding.source0_valid ||
       !binding.source1_valid || (binding.last == execution_mask_tile) then
        return FALSE;
    end;
    if !execution_mask_tile then return TRUE; end;
    let mask_binding = _BundleTileBindings[[1]];
    return mask_binding.valid && !mask_binding.destination_valid &&
           mask_binding.destination_size == 0 &&
           mask_binding.source0_valid && !mask_binding.source1_valid &&
           mask_binding.last;
end;

func ExecuteBundleMSCATTEROperation() => boolean
begin
    // PE_MASK=0000 is a strict no-op before schema, source, GPR, dimension,
    // address, permission, event, and memory checks.
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
       !BundleMSCATTERBindingsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let source = binding.source0;
    let indices = binding.source1;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if !IndexedTLSUExecutionMaskContentsDefined(source) ||
       !IndexedTLSUExecutionMaskContentsDefined(indices) ||
       _Tiles[[source]].data_type != data_type ||
       !IndexedTLSUMemoryIndexDataTypeLegal(_Tiles[[indices]].data_type) ||
       !IndexedTLSUOrdinaryTransferDataTypeLegal(data_type) ||
       !IndexedTLSUDataShapeMatchesIndex(
           _Tiles[[source]].valid_rows, _Tiles[[source]].valid_columns,
           _Tiles[[indices]].valid_rows, _Tiles[[indices]].valid_columns,
           data_type) ||
       _Tiles[[source]].valid_rows != valid_rows ||
       _Tiles[[source]].valid_columns != valid_columns ||
       _Tiles[[source]].columns != columns ||
       !IndexedTLSUPhysicalShapeLegal(CurrentBundleTileLayout(), data_type,
           valid_rows, valid_columns, columns) ||
       _Tiles[[source]].layout != CurrentBundleTileLayout() ||
       _Tiles[[indices]].layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
    if !TileOperandsLegal_MSCATTER(
           Zeros{PTO_XLEN}, source, indices) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    MSCATTER(base_address, source, indices);
    if _LastFault != Fault_None then return FALSE; end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
