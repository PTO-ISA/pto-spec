// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-CUBE-DESTINATION","surface":"block","classification":["model","dispatch","cube-destination"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-TILE-MODEL-LEGALITY-MATRIX-CUBE-PRIMARY"]}

func ResolveBundleTMATMULCubeDestinationGroup(
    m: integer {1..65535}, n: integer {1..65535},
    accumulator_type: TileDataType,
    output_type: TileDataType,
    primary_layout: TileLayout) => boolean
begin
    var reserved: array [[PTO_TILE_REGISTER_COUNT]] of boolean;
    var resolved: array [[PTO_BUNDLE_TILE_BINDING_COUNT]] of TileIndex;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        reserved[[index]] = FALSE;
    end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        resolved[[binding]] = 0;
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            let capacity_bytes = BundleTileDestinationSizeBytes(
                binding as BundleTileBindingIndex);
            let hand = UInt(
                _BundleTileBindings[[binding]].destination_hand);
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
    if !BundleLocalDestinationCapacityGroupFits() then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;

    var destination_ordinal: integer {0..3} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            let capacity_bytes = BundleTileDestinationSizeBytes(
                binding as BundleTileBindingIndex);
            if destination_ordinal == 0 then
                if !TileMatrixMLayoutLegal(primary_layout, m) ||
                   !TileCubeDescriptorShapeLegal(
                       capacity_bytes, m, n,
                       output_type, primary_layout) then
                    SetFault(Fault_TileAllocation, ReadTPC());
                    return FALSE;
                end;
            else
                let row_auxiliary =
                    _BundleFixedPointAttributes.row_max_en &&
                    destination_ordinal == 1;
                let group_auxiliary =
                    _BundleFixedPointAttributes.group_max_en &&
                    ((!_BundleFixedPointAttributes.row_max_en &&
                      destination_ordinal == 1) ||
                     (_BundleFixedPointAttributes.row_max_en &&
                      destination_ordinal == 2));
                let auxiliary_columns = if row_auxiliary then 1
                    else if group_auxiliary then
                        BundleGroupMaxColumns(n)
                    else n;
                let rows = DerivedTileRows(
                    capacity_bytes, auxiliary_columns, accumulator_type);
                if !TileDescriptorShapeLegal(
                       capacity_bytes, auxiliary_columns, m,
                       auxiliary_columns, accumulator_type) ||
                   rows * auxiliary_columns > PTO_MODEL_TILE_ELEMENTS then
                    SetFault(Fault_TileAllocation, ReadTPC());
                    return FALSE;
                end;
            end;
            destination_ordinal =
                (destination_ordinal + 1) as integer {0..3};
        end;
    end;

    destination_ordinal = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle then
            let capacity_bytes = BundleTileDestinationSizeBytes(
                binding as BundleTileBindingIndex);
            let allocation_mask = _BundleTileBindings[[binding]].pe_mask;
            if destination_ordinal == 0 then
                let configured = ConfigureCubeTileForMask(
                    resolved[[binding]], capacity_bytes, m, n,
                    output_type, primary_layout,
                    TileLocation_Matrix, allocation_mask);
                assert configured;
            else
                let row_auxiliary =
                    _BundleFixedPointAttributes.row_max_en &&
                    destination_ordinal == 1;
                let group_auxiliary =
                    _BundleFixedPointAttributes.group_max_en &&
                    ((!_BundleFixedPointAttributes.row_max_en &&
                      destination_ordinal == 1) ||
                     (_BundleFixedPointAttributes.row_max_en &&
                      destination_ordinal == 2));
                let auxiliary_columns = if row_auxiliary then 1
                    else if group_auxiliary then
                        BundleGroupMaxColumns(n)
                    else n;
                ConfigureTileForMask(
                    resolved[[binding]], capacity_bytes,
                    m, auxiliary_columns, m, auxiliary_columns,
                    accumulator_type, TileLayout_RowMajor,
                    TileLocation_Any, allocation_mask);
            end;
            _BundleTileBindings[[binding]].destination =
                resolved[[binding]];
            _BundleTileBindings[[binding]].destination_allocated_by_bundle =
                TRUE;
            destination_ordinal =
                (destination_ordinal + 1) as integer {0..3};
        end;
    end;
    return TRUE;
end;

func ResolveBundleTMATMULDestination(
    m: integer {1..65535}, n: integer {1..65535},
    accumulator_type: TileDataType,
    cube_primary: boolean,
    primary_layout: TileLayout) => boolean
begin
    var destination_binding: BundleTileBindingIndex = 0;
    var destination_seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if !destination_seen &&
           _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            destination_binding = binding as BundleTileBindingIndex;
            destination_seen = TRUE;
        end;
    end;
    if !destination_seen then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    let output_type = if
        UInt(_BundleFixedPointAttributes.pre_quant_mode) == 0 then
        accumulator_type
    else
        BundleFPATROutputType(
            _BundleFixedPointAttributes.pre_quant_mode);
    let capacity_bytes = BundleTileDestinationSizeBytes(destination_binding);
    if cube_primary then
        return ResolveBundleTMATMULCubeDestinationGroup(
            m, n, accumulator_type, output_type, primary_layout);
    else
        let rows = DerivedTileRows(capacity_bytes, n, output_type);
        if !TileDescriptorShapeLegal(
               capacity_bytes, n, m, n, output_type) ||
           !IsNonzeroPowerOfTwo(rows) ||
           rows * n > PTO_MODEL_TILE_ELEMENTS then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
    end;
    // Reserve the complete D/RowMax/GroupMax destination group first.  Only
    // the primary D descriptor is then converted to persistent CUBE state;
    // auxiliary outputs remain ordinary Local Tiles.
    if !ResolveBundleTileDestinationsWithShape(TRUE, m, n, n) then
        return FALSE;
    end;
    return TRUE;
end;

func ResolveBundleTMATMULDestination(
    m: integer {1..65535}, n: integer {1..65535},
    accumulator_type: TileDataType) => boolean
begin
    return ResolveBundleTMATMULDestination(
        m, n, accumulator_type, FALSE, TileLayout_RowMajor);
end;
