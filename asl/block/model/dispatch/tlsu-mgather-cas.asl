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
    return first.valid && !first.destination_valid &&
           first.source0_valid && first.source1_valid && !first.last &&
           first.destination_size == 0 &&
           second.valid && second.destination_valid &&
           second.source0_valid && !second.source1_valid && second.last;
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
    if !TileSourceContentsDefined(indices) ||
       !TileSourceContentsDefined(expected) ||
       !TileSourceContentsDefined(replacement) ||
       !IndexedTLSUIndexDataTypeLegal(_Tiles[[indices]].data_type) ||
       !(data_type == TileDataType_U16 ||
         data_type == TileDataType_U32 ||
         data_type == TileDataType_U64) ||
       _Tiles[[expected]].data_type != data_type ||
       _Tiles[[replacement]].data_type != data_type then
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
       _Tiles[[expected]].valid_rows != valid_rows ||
       _Tiles[[expected]].valid_columns != valid_columns ||
       _Tiles[[replacement]].valid_rows != valid_rows ||
       _Tiles[[replacement]].valid_columns != valid_columns then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
    let row_stride_elements = ReadPEAbsoluteGPROperand(
        _CurrentMemoryAgent, _BundleScalarBindings[[0]].source1);
    if UInt(row_stride_elements) < valid_columns then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !ResolveBundleTileDestinationsWithShapeAndType(TRUE, valid_rows,
           valid_columns, columns, TRUE, data_type) then return FALSE; end;
    let destination = _BundleTileBindings[[1]].destination;
    let pad_value = CurrentBundlePadValue();
    if !TileOperandsLegal_MGATHER_CAS(destination, Zeros{PTO_XLEN},
           row_stride_elements, indices, expected, replacement,
           pad_value) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    MGATHER_CAS(destination, base_address, row_stride_elements,
        indices, expected, replacement, pad_value);
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
