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
    if !_BundleDimensionPresent[[0]] then return FALSE; end;
    for dimension = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        if _BundleDimensionPresent[[dimension]] &&
           (UInt(_BundleDimensions[[dimension]]) == 0 ||
            UInt(_BundleDimensions[[dimension]]) > 65535) then
            return FALSE;
        end;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) as integer {1..65535} else 1;
    let columns = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]]) as integer {1..65535}
        else valid_columns;
    return valid_columns <= columns && IsNonzeroPowerOfTwo(columns) &&
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
    if !binding.destination_valid || !binding.source0_valid ||
       binding.source1_valid || !binding.last ||
       !TileSourceContentsDefined(binding.source0) ||
       !TileDataTypeIsInteger(_Tiles[[binding.source0]].data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !IndexedTLSUTransferDataTypeLegal(data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) as integer {1..65535} else 1;
    let columns = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]]) as integer {1..65535}
        else valid_columns;
    if _Tiles[[binding.source0]].valid_rows != valid_rows ||
       _Tiles[[binding.source0]].valid_columns != valid_columns then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !ResolveBundleTileDestinationsWithShape(TRUE, valid_rows,
           valid_columns, columns) then return FALSE; end;
    let destination = _BundleTileBindings[[0]].destination;
    let pad_value = CurrentBundlePadValue();
    if !TileOperandsLegal_MGATHER(destination, Zeros{PTO_XLEN},
           binding.source0, pad_value) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
    MGATHER(destination, base_address, binding.source0, pad_value);
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
