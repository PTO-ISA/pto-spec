// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY","surface":"block","classification":["model","dispatch","destination-auxiliary"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA"]}
pure func SmallestTilePhysicalColumns(
    valid_columns: integer {1..65535}) => integer {0..65535}
begin
    var columns: integer = 1;
    for exponent = 0 to 15 do
        if valid_columns <= columns then
            return columns as integer {1..32768};
        end;
        columns = columns * 2;
    end;
    return 0;
end;

readonly func BundleGroupMaxColumns(columns: integer {0..65535})
                                      => integer {0..65535}
begin
    let group_n = BundleFPATRGroupN(_BundleFixedPointAttributes.group_n_code);
    if !_BundleFixedPointAttributes.group_max_en || group_n == 0 then
        return columns;
    end;
    assert group_n != 0;
    let nonzero_group_n = group_n as integer {8,16,32,48,64,80,96,112,128};
    return ((columns + (nonzero_group_n - 1)) DIVRM nonzero_group_n)
        as integer {0..65535};
end;

func MarkBundleTIMG2COLDestinationsMatrix()
begin
    // Destination representation is established by the explicit layout
    // contract; no execution-engine/location tag is materialized.
    assert TRUE;
end;

readonly func BundleDestinationIsOrdinaryTCVT(
    decoded_operation: integer {0..PTO_TILE_OPERATION_COUNT},
    cube: boolean) => boolean
begin
    return !cube && decoded_operation != PTO_TILE_OPERATION_COUNT &&
        TileOperationOfIndex(decoded_operation as integer {
            0..PTO_TILE_OPERATION_COUNT-1}) == TileOperation_TCVT;
end;

func ConfigureBundleTileDestination(
    index: TileIndex, capacity_bytes: integer {0..262144},
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    valid_rows: integer {0..65535}, columns: integer {0..65535},
    valid_columns: integer {0..65535}, data_type: TileDataType,
    layout: TileLayout, allocation_mask: bits(4), tgpr2t: boolean,
    exact_cube_columns: boolean, preserve_physical_rows: boolean)
    => boolean
begin
    if tgpr2t then
        return ConfigureCubeTileForMaskWithPhysical(index, capacity_bytes,
            physical_rows, physical_columns, valid_rows, valid_columns,
            data_type, layout, allocation_mask);
    end;
    ConfigureTileForMask(index, capacity_bytes, if preserve_physical_rows then
        physical_rows else DerivedTileRows(capacity_bytes, columns, data_type), columns,
        valid_rows, valid_columns, data_type, layout,
        allocation_mask);
    return TRUE;
end;
