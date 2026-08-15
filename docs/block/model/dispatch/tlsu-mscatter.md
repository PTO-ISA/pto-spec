<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-mscatter.asl -->
# TLSU Mscatter

**Normative ASL source:** `asl/block/model/dispatch/tlsu-mscatter.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER}

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
    if BundleTileBindingCount() != 1 then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    return binding.valid && !binding.destination_valid &&
           binding.destination_size == 0 &&
           binding.source0_valid && binding.source1_valid && binding.last;
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
    let valid_rows = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) as integer {1..65535} else 1;
    let columns = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]]) as integer {1..65535}
        else valid_columns;
    if !TileSourceContentsDefined(source) ||
       !TileSourceContentsDefined(indices) ||
       _Tiles[[source]].data_type != data_type ||
       !TileDataTypeIsInteger(_Tiles[[indices]].data_type) ||
       !IndexedTLSUTransferDataTypeLegal(data_type) ||
       _Tiles[[source]].valid_rows != valid_rows ||
       _Tiles[[source]].valid_columns != valid_columns ||
       _Tiles[[source]].columns != columns ||
       _Tiles[[indices]].valid_rows != valid_rows ||
       _Tiles[[indices]].valid_columns != valid_columns ||
       _Tiles[[source]].layout != CurrentBundleTileLayout() ||
       _Tiles[[indices]].layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !TileOperandsLegal_MSCATTER(Zeros{PTO_XLEN}, source, indices) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
    MSCATTER(base_address, source, indices);
    if _LastFault != Fault_None then return FALSE; end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
