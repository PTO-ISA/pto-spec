<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-mgather-mask.asl -->
# TLSU Mgather Mask

**Normative ASL source:** `asl/block/model/dispatch/tlsu-mgather-mask.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK}

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
    if BundleTileBindingCount() != 1 then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    return binding.valid && binding.destination_valid &&
           binding.source0_valid && binding.source1_valid && binding.last;
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
    if !TileSourceContentsDefined(indices) ||
       !TilePredicateValuesLegal(mask) ||
       !TileDataTypeIsInteger(_Tiles[[indices]].data_type) ||
       !IndexedTLSUTransferDataTypeLegal(data_type) ||
       _Tiles[[indices]].layout != CurrentBundleTileLayout() ||
       _Tiles[[mask]].layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) as integer {1..65535} else 1;
    let columns = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]]) as integer {1..65535}
        else valid_columns;
    if _Tiles[[indices]].valid_rows != valid_rows ||
       _Tiles[[indices]].valid_columns != valid_columns ||
       _Tiles[[mask]].valid_rows != valid_rows ||
       _Tiles[[mask]].valid_columns != valid_columns then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !ResolveBundleTileDestinationsWithShapeAndType(TRUE, valid_rows,
           valid_columns, columns, TRUE, data_type) then return FALSE; end;
    let destination = _BundleTileBindings[[0]].destination;
    let pad_value = CurrentBundlePadValue();
    if !TileOperandsLegal_MGATHER_MASK(destination, Zeros{PTO_XLEN},
           indices, mask, pad_value) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
