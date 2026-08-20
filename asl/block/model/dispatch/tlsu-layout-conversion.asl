// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION","surface":"block","classification":["model","dispatch","tlsu-layout-conversion"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-MEMORY-LOAD-STORE"]}

readonly func BundleCubeTransportSelected() => boolean
begin
    return _BundleDataAttributesPresent &&
           TileDataLayoutIsCubeConversion(
               _BundleDataAttributes.data_layout);
end;

readonly func BundleCubeTransportDimensionsLegal() => boolean
begin
    if !_BundleDimensionPresent[[0]] ||
       !_BundleDimensionPresent[[1]] ||
       _BundleDimensionPresent[[2]] then
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]);
    let valid_rows = UInt(_BundleDimensions[[1]]);
    return 1 <= valid_columns && valid_columns <= 65535 &&
           1 <= valid_rows && valid_rows <= 65535;
end;

readonly func BundleCubeTransportDataAttributesLegal() => boolean
begin
    if !_BundleDataAttributesPresent ||
       _BundleDataAttributes.data_type != DTYPE_NONE ||
       !TileDataLayoutIsCubeConversion(
           _BundleDataAttributes.data_layout) ||
       _BundleDataAttributes.comparison_mode != Zeros{3} ||
       _BundleDataAttributes.rounding_mode != Zeros{3} ||
       _BundleDataAttributes.saturating ||
       _BundleDataAttributes.canonicalize then
        return FALSE;
    end;
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       !_BundleOperation.selector_valid then
        return FALSE;
    end;
    let function = UInt(_BundleOperation.selector[4:0]);
    if function == 0 then
        return TileDataLayoutConversionIsLoad(
            _BundleDataAttributes.data_layout);
    elsif function == 1 then
        return TileDataLayoutConversionIsStore(
            _BundleDataAttributes.data_layout);
    end;
    return FALSE;
end;

readonly func BundleCubeTransportBindingsLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if BundleSharedBindingCount() != 0 ||
       BundleTileBindingCount() != 1 ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationScalarBindingSchemaLegal(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() then
        return FALSE;
    end;
    let function = UInt(_BundleOperation.selector[4:0]);
    let binding = _BundleTileBindings[[0]];
    if !binding.valid || !binding.last then return FALSE; end;
    if function == 0 then
        return binding.destination_valid &&
               !binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(0) &&
               !binding.source0_valid && !binding.source1_valid;
    elsif function == 1 then
        return !binding.destination_valid &&
               binding.source0_valid && !binding.source1_valid;
    end;
    return FALSE;
end;

func ResolveBundleCubeTransportDestination(
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType,
    layout: TileLayout) => boolean
begin
    let binding = _BundleTileBindings[[0]];
    let capacity_bytes = BundleTileDestinationSizeBytes(0);
    if !TileCubeDescriptorShapeLegal(capacity_bytes, valid_rows,
           valid_columns, data_type, layout) ||
       CoreTileCapacityInUse() + TileCoreAllocationBytes(
           binding.pe_mask, capacity_bytes) > TileCapacityLimitBytes() then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let hand = UInt(binding.destination_hand);
    var destination: TileIndex = 0;
    var found = FALSE;
    for offset = 0 to 15 do
        let raw_index: integer = hand * 16 + offset;
        if !found && !_Tiles[[raw_index]].allocated then
            destination = raw_index as TileIndex;
            found = TRUE;
        end;
    end;
    if !found || !ConfigureCubeTileForMask(
           destination, capacity_bytes, valid_rows, valid_columns,
           data_type, layout, TileLocation_Matrix, binding.pe_mask) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    _BundleTileBindings[[0]].destination = destination;
    _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
    return TRUE;
end;

func ExecuteBundleCubeTransportOperation() => boolean
begin
    // A zero Local mask is resolved before every schema, GPR, descriptor,
    // allocation, and memory check.
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    let decoded = DecodeTileOperation(
        TileDecode_TLSU, BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if !BundleCubeTransportDimensionsLegal() ||
       !BundleCubeTransportDataAttributesLegal() ||
       !BundleCubeTransportBindingsLegal(operation) ||
       _BundleFixedPointAttributes.valid then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let (type_valid, data_type) = ResolveBundleEffectiveDataType();
    let layout = TileDataLayoutCubeLayout(
        _BundleDataAttributes.data_layout);
    if !type_valid || !TileCubeDataTypeSupported(data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]])
        as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]])
        as integer {1..65535};
    let base_address = if _BundleScalarBindings[[0]].valid then
        ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source0)
        else Zeros{PTO_XLEN};
    let row_stride_elements = if _BundleScalarBindings[[0]].valid then
        ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source1)
        else NaturalToWord(valid_columns);
    let function = UInt(_BundleOperation.selector[4:0]);
    if function == 0 then
        if !ResolveBundleCubeTransportDestination(
               valid_rows, valid_columns, data_type, layout) then
            return FALSE;
        end;
        let destination = _BundleTileBindings[[0]].destination;
        TLOAD(destination, base_address, row_stride_elements);
        if _LastFault != Fault_None then
            RollBackBundleTileDestinations();
            return FALSE;
        end;
    else
        let source = _BundleTileBindings[[0]].source0;
        let tile = _Tiles[[source]];
        if !TileCubeDescriptorLegal(tile) || !tile.contents_defined ||
           tile.data_type != data_type || tile.layout != layout ||
           tile.valid_rows != valid_rows ||
           tile.valid_columns != valid_columns ||
           (_TileAllocationMasks[[source]] AND
               _BundleTileBindings[[0]].pe_mask) !=
               _BundleTileBindings[[0]].pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        TSTORE(base_address, row_stride_elements, source);
        if _LastFault != Fault_None then return FALSE; end;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
