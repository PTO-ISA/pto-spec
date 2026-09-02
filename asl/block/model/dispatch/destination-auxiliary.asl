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
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            _Tiles[[_BundleTileBindings[[binding]].destination]].location =
                TileLocation_Matrix;
        end;
    end;
end;

readonly func BundleTCONCATDestinationShape()
    => (boolean, integer {0..65535}, integer {0..65535},
        integer {0..65535}, TileDataType)
begin
    let source_left = BundleSortingSourceAt(0);
    let source_right = BundleSortingSourceAt(1);
    let valid_rows = _Tiles[[source_left]].valid_rows;
    let output_columns = _Tiles[[source_left]].valid_columns +
        _Tiles[[source_right]].valid_columns;
    if output_columns < 1 || output_columns > 32768 ||
       valid_rows != _Tiles[[source_right]].valid_rows then
        return (FALSE, 0, 0, 0, _Tiles[[source_left]].data_type);
    end;
    let physical_columns = SmallestTilePhysicalColumns(
        output_columns as integer {1..65535});
    return (physical_columns != 0, valid_rows,
        output_columns as integer {1..65535}, physical_columns,
        _Tiles[[source_left]].data_type);
end;
func ConfigureBundleTileDestination(
    index: TileIndex, capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535}, columns: integer {0..65535},
    valid_columns: integer {0..65535}, data_type: TileDataType,
    layout: TileLayout, allocation_mask: bits(4), tgpr2t: boolean)
    => boolean
begin
    if tgpr2t then
        return ConfigureCubeTileForMask(index, capacity_bytes, valid_rows,
            valid_columns, data_type, layout, TileLocation_Matrix,
            allocation_mask);
    end;
    ConfigureTileForMask(index, capacity_bytes, valid_rows, columns,
        valid_rows, valid_columns, data_type, layout, TileLocation_Any,
        allocation_mask);
    return TRUE;
end;
