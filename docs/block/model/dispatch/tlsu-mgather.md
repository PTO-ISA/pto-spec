<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-mgather.asl -->
# TLSU Mgather

**Normative ASL source:** `asl/block/model/dispatch/tlsu-mgather.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-purpose role=purpose-scope -->
## Purpose and scope

This unit is the bundle-level handler for plain `MGATHER`, the indexed load that reads one global-memory element per index into a new Local Tile.

`BundleMGATHERSelected` recognizes the bundle: a valid `TileMemory` operation descriptor whose selector function (bits `4:0`) is `4`. `ExecuteBundleMGATHEROperation` validates the complete bundle, resolves the destination, and calls the Tile-level `MGATHER` effect. The unit also defines `BundleMGATHERDimensionsLegal`, which the other indexed TLSU handlers reuse.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-concepts role=concepts-state -->
## Concepts and visible state

An `MGATHER` bundle has this schema.

- One `B.IOR` record is required. Its `source0` selects the GPR that holds the base address, read for the current memory agent.
- One `B.IOT` binding with a destination, the index Tile in `source0`, and the `last` flag. It carries `source1` only when a predicate-Tile execution mask is in force. No `B.IOS` binding is allowed.
- `B.DIM` gives valid columns, valid rows, and physical columns for the destination.
- The index Tile must be S32, U32, S64, or U64, and must have the bundle layout. The transfer data type must pass `IndexedTLSUOrdinaryTransferDataTypeLegal`.

`BundleMGATHERDimensionsLegal` requires every dimension in `1..65535`, valid rows times valid columns not above `PTO_MODEL_TILE_ELEMENTS`, and, for the RowMajor layout, valid columns not above physical columns and physical columns a nonzero power of two.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-rules role=rules-interactions -->
## Rules and interactions

The handler first returns success with no effect when `SelectedBundleTileMaskIsZero` holds. The ASL comment calls a `B.IOT` PE mask of `0000` a strict no-op before schema, source, GPR, dimension, allocation, and memory checks.

An unknown TLSU operation code raises `Fault_IllegalInstruction`. Schema, type, and shape failures raise `Fault_TileLegality`. These checks all run before the destination is resolved. The data shape must match the index shape through `IndexedTLSUDataShapeMatchesIndex`, and the physical shape must pass `IndexedTLSUPhysicalShapeLegal`.

The handler then resolves the destination with the `B.DIM` shape and the operation data type, and validates Local generation writers. A failure after resolution calls `RollBackBundleTileDestinations`. So does a memory fault raised inside `MGATHER`. On success it calls `FinalizeBundleTileAttempt`, which publishes a bundle-allocated destination.

Design point: the pad value comes from `CurrentBundlePadValue`, so an absent `B.DATR` gives `TilePad_Null`. The Tile-level `MGATHER` writes it into destination elements outside the valid region; elements that an execution mask makes inactive take a separate value.

Design point: `MGATHER` probes every active index address before it writes the result. A translation fault therefore leaves the destination unpublished, and the rollback releases it.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-boundaries role=boundaries -->
## Architectural boundaries

This unit runs only after `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` finds no earlier specialized selector. In that order `BundleMGATHERSelected` is tested after the `MGATHER.CAS`, atomic-or-reduction, and `MGATHER.MASK` selectors. The caller commits or aborts Local generations after the handler returns.

Address arithmetic, the index-to-byte displacement rule, and pad filling belong to the Tile gather and scatter owner.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose the bundle gathers FP32 values with `LB0` equal to 32, `LB1` equal to 4, and `LB2` equal to 32 in RowMajor layout. The index Tile is U32, RowMajor, with 4 valid rows and 32 valid columns. The shapes match, 32 is a power of two, and 4 times 32 is 128 elements. The destination is resolved as a 4 by 32 FP32 Tile and receives 128 gathered elements.

If the index Tile were FP32, the bundle raises `Fault_TileLegality` before any destination is allocated.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-related role=related-owners-navigation -->
## Related owners

- [Tile execution dispatch](tile-execution.md) orders the specialized selectors.
- [MGATHER.MASK dispatch](tlsu-mgather-mask.md) and [MGATHER.CAS dispatch](tlsu-mgather-cas.md) reuse this unit's dimension check.
- [Gather and scatter memory](../../../tile/model/memory/gather-scatter.md) defines the Tile-level `MGATHER`.
- [BSTART.MGATHER](../../execution/BSTART.MGATHER.md) is the instruction page for the start form.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-mgather.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER","surface":"block","classification":["model","dispatch","tlsu-mgather"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"]}

readonly func BundleMGATHERSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 4;
end;

readonly func BundleMGATHERDimensionsLegal() => boolean
begin
    for dimension = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        if UInt(_BundleDimensions[[dimension]]) == 0 ||
           UInt(_BundleDimensions[[dimension]]) > 65535 then
            return FALSE;
        end;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    let row_major_shape_legal =
        CurrentBundleTileLayout() != TileLayout_RowMajor ||
        (valid_columns <= columns && IsNonzeroPowerOfTwo(columns));
    return row_major_shape_legal &&
           valid_rows * valid_columns <= PTO_MODEL_TILE_ELEMENTS;
end;

func ExecuteBundleMGATHEROperation() => boolean
begin
    // B.IOT PE_MASK=0000 is a strict no-op before schema, source, GPR,
    // dimension, allocation, and memory checks.
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if BundleSharedBindingCount() != 0 || BundleTileBindingCount() != 1 ||
       !_BundleScalarBindings[[0]].valid ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       !BundleMGATHERDimensionsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.destination_valid || !binding.source0_valid ||
       (binding.source1_valid != execution_mask_tile) || !binding.last ||
       !IndexedTLSUExecutionMaskContentsDefined(binding.source0) ||
       !IndexedTLSUMemoryIndexDataTypeLegal(
           _Tiles[[binding.source0]].data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !IndexedTLSUOrdinaryTransferDataTypeLegal(data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if !IndexedTLSUDataShapeMatchesIndex(
           valid_rows, valid_columns,
           _Tiles[[binding.source0]].valid_rows,
           _Tiles[[binding.source0]].valid_columns, data_type) ||
       _Tiles[[binding.source0]].layout != CurrentBundleTileLayout() ||
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
    let destination = _BundleTileBindings[[0]].destination;
    let pad_value = CurrentBundlePadValue();
    if !TileOperandsLegal_MGATHER(destination, Zeros{PTO_XLEN},
           binding.source0, pad_value) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    MGATHER(destination, base_address, binding.source0, pad_value);
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
