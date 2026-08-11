<!-- GENERATED FROM: asl/block/model/dispatch/destination-shape.asl -->
# Destination Shape

**Normative ASL source:** `asl/block/model/dispatch/destination-shape.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/destination-shape.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","surface":"block","classification":["model","dispatch","destination-shape"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-NUMERIC-CONTROL"]}
readonly func BundleDestinationValidRows(shape_source_valid: boolean,
                                         shape_source: TileIndex)
                                         => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRole(BundleDimension_ValidRows);
    if UInt(_BundleDimensions[[index]]) >= 1 &&
       UInt(_BundleDimensions[[index]]) <= 65535 then
        return UInt(_BundleDimensions[[index]]) as integer {1..65535};
    elsif shape_source_valid && TileDescriptorConfigured(shape_source) then
        return _Tiles[[shape_source]].valid_rows;
    else
        return 1;
    end;
end;

readonly func BundleDestinationValidColumns(shape_source_valid: boolean,
                                            shape_source: TileIndex)
                                            => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRole(BundleDimension_ValidColumns);
    if UInt(_BundleDimensions[[index]]) >= 1 &&
       UInt(_BundleDimensions[[index]]) <= 65535 then
        return UInt(_BundleDimensions[[index]]) as integer {1..65535};
    elsif shape_source_valid && TileDescriptorConfigured(shape_source) then
        return _Tiles[[shape_source]].valid_columns;
    else
        return 1;
    end;
end;

readonly func BundleDestinationPhysicalColumns(shape_source_valid: boolean,
                                               shape_source: TileIndex)
                                               => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRole(BundleDimension_PhysicalColumns);
    if UInt(_BundleDimensions[[index]]) >= 1 &&
       UInt(_BundleDimensions[[index]]) <= 65535 then
        return UInt(_BundleDimensions[[index]]) as integer {1..65535};
    elsif shape_source_valid && TileDescriptorConfigured(shape_source) then
        return _Tiles[[shape_source]].columns;
    else
        return BundleDestinationValidColumns(FALSE, 0);
    end;
end;

readonly func BundleGroupMaxColumns(columns: integer {0..65535})
                                      => integer {0..65535}
begin
    let group_n = BundleFPATRGroupN(_BundleFixedPointAttributes.group_n_code);
    if !_BundleFixedPointAttributes.group_max_en || group_n == 0 then
        return columns;
    end;
    return ((columns + (group_n - 1)) DIVRM group_n)
        as integer {0..65535};
end;

func ResolveBundleTileDestinations() => boolean
begin
    var reserved: array [[PTO_TILE_REGISTER_COUNT]] of boolean;
    var resolved: array [[PTO_BUNDLE_TILE_BINDING_COUNT]] of TileIndex;
    var required_capacity: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        reserved[[index]] = FALSE;
    end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        resolved[[binding]] = 0;
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
            !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            required_capacity = required_capacity +
                TileCoreAllocationBytes(
                    _BundleTileBindings[[binding]].pe_mask,
                    BundleTileDestinationSizeBytes(
                        binding as BundleTileBindingIndex));
            let hand =
                UInt(_BundleTileBindings[[binding]].destination_hand);
            var found = FALSE;
            for offset = 0 to 15 do
                let raw_index: integer = hand * 16 + offset;
                if !found && !_Tiles[[raw_index]].allocated &&
                   !reserved[[raw_index]] then
                    resolved[[binding]] = raw_index as TileIndex;
                    reserved[[raw_index]] = TRUE;
                    found = TRUE;
                end;
            end;
            if !found then
                SetFault(Fault_TileAllocation, ReadTPC());
                return FALSE;
            end;
        end;
    end;
    if CoreTileCapacityInUse() + required_capacity >
       TileCapacityLimitBytes() then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;

    let selected_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    let matrix = _BundleOperation.valid &&
        _BundleOperation.operation_class == BundleOperation_TileMatrix;
    let accumulator_type = TileMatrixAccumulatorDataType(selected_type);
    let matrix_output_type = if matrix &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) == 0 then
        accumulator_type
    else if matrix then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else selected_type;
    var shape_source_valid = FALSE;
    var shape_source: TileIndex = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if !shape_source_valid && _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                shape_source = _BundleTileBindings[[binding]].source0;
                shape_source_valid = TRUE;
            elsif _BundleTileBindings[[binding]].source1_valid then
                shape_source = _BundleTileBindings[[binding]].source1;
                shape_source_valid = TRUE;
            end;
        end;
    end;

    // Validate every derived descriptor before allocating any destination.
    // This preserves precise all-or-nothing B.IOT allocation when a size code
    // is too small for its logical shape.
    var destination_ordinal: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            let valid_rows = BundleDestinationValidRows(
                shape_source_valid, shape_source);
            let valid_columns = BundleDestinationValidColumns(
                shape_source_valid, shape_source);
            let columns = BundleDestinationPhysicalColumns(
                shape_source_valid, shape_source);
            let destination_type = if destination_ordinal == 0 then
                matrix_output_type else if matrix then accumulator_type
                else TileDataType_U32;
            let auxiliary_row = matrix && destination_ordinal > 0 &&
                _BundleFixedPointAttributes.row_max_en &&
                ((destination_ordinal == 1) ||
                 !_BundleFixedPointAttributes.group_max_en);
            let auxiliary_columns = if auxiliary_row then 1
                else if matrix && _BundleFixedPointAttributes.group_max_en then
                    BundleGroupMaxColumns(columns)
                else columns;
            let auxiliary_valid_columns = if auxiliary_row then 1
                else if matrix && _BundleFixedPointAttributes.group_max_en then
                    BundleGroupMaxColumns(valid_columns)
                else valid_columns;
            let capacity_bytes = BundleTileDestinationSizeBytes(
                binding as BundleTileBindingIndex);
            let rows = DerivedTileRows(capacity_bytes, auxiliary_columns,
                destination_type);
            if !TileDescriptorShapeLegal(capacity_bytes, auxiliary_columns,
                   valid_rows, auxiliary_valid_columns, destination_type) ||
               rows * auxiliary_columns > PTO_MODEL_TILE_ELEMENTS then
                SetFault(Fault_TileAllocation, ReadTPC());
                return FALSE;
            end;
            destination_ordinal = destination_ordinal + 1;
        end;
    end;

    destination_ordinal = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            let valid_rows = BundleDestinationValidRows(
                shape_source_valid, shape_source);
            let valid_columns = BundleDestinationValidColumns(
                shape_source_valid, shape_source);
            let columns = BundleDestinationPhysicalColumns(
                shape_source_valid, shape_source);
            let destination_type = if destination_ordinal == 0 then
                matrix_output_type else if matrix then accumulator_type
                else TileDataType_U32;
            let auxiliary_row = matrix && destination_ordinal > 0 &&
                _BundleFixedPointAttributes.row_max_en &&
                ((destination_ordinal == 1) ||
                 !_BundleFixedPointAttributes.group_max_en);
            let auxiliary_columns = if auxiliary_row then 1
                else if matrix && _BundleFixedPointAttributes.group_max_en then
                    BundleGroupMaxColumns(columns)
                else columns;
            let auxiliary_valid_columns = if auxiliary_row then 1
                else if matrix && _BundleFixedPointAttributes.group_max_en then
                    BundleGroupMaxColumns(valid_columns)
                else valid_columns;
            let capacity_bytes = BundleTileDestinationSizeBytes(
                binding as BundleTileBindingIndex);
            ConfigureTileForMask(resolved[[binding]],
                capacity_bytes, valid_rows, auxiliary_columns, valid_rows,
                auxiliary_valid_columns, destination_type,
                CurrentBundleTileLayout(), TileLocation_Any,
                _BundleTileBindings[[binding]].pe_mask);
            _BundleTileBindings[[binding]].destination = resolved[[binding]];
            _BundleTileBindings[[binding]].destination_allocated_by_bundle =
                TRUE;
            destination_ordinal = destination_ordinal + 1;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
