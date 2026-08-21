// PTO-UNIT: {"id":"PTO-TILE-MODEL-SHAPE-VALID-REGION","surface":"tile","classification":["model","shape","valid-region"],"depends_on":["PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS"]}
readonly func TileDescriptorShapeLegal(capacity_bytes: integer {0..262144},
                                   columns: integer {0..65535},
                                   valid_rows: integer {0..65535},
                                   valid_columns: integer {0..65535},
                                   data_type: TileDataType) => boolean
begin
    let rows = DerivedTileRows(capacity_bytes, columns, data_type);
    return rows != 0 && valid_rows <= rows && valid_columns <= columns &&
           valid_rows * valid_columns <=
               TileLogicalElementCapacity(capacity_bytes, data_type);
end;

// A source-form B.IOS carries SizeCode=0. When the selected Shared register has
// no descriptor, the consuming operation derives the smallest architectural
// per-PE capacity that can represent its completed schema.  Zero reports that
// no 128 B through 256 KiB Shared Tile size can represent the requested shape.
readonly func MinimumTileCapacityBytesForShape(
    columns: integer {0..65535}, valid_rows: integer {0..65535},
    valid_columns: integer {0..65535}, data_type: TileDataType)
    => integer {0..262144}
begin
    for size_code = 1 to 12 do
        let capacity_bytes = TileSizeCodeBytes(
            size_code as integer {1..12});
        if TileDescriptorShapeLegal(capacity_bytes, columns, valid_rows,
               valid_columns, data_type) then
            return capacity_bytes;
        end;
    end;
    return 0;
end;

pure func TileStorageBytes(rows: integer {0..65535},
                           columns: integer {0..65535},
                           data_type: TileDataType) => integer
begin
    // Capacity accounting is bit-packed. In particular, two four-bit
    // elements occupy one byte and an odd final element rounds up.
    return ((rows * columns * TileElementBits(data_type)) + 7) DIVRM 8;
end;

pure func TileStorageFitsCapacity(rows: integer {0..65535},
                                  columns: integer {0..65535},
                                  data_type: TileDataType,
                                  capacity_bytes: integer {0..262144})
    => boolean
begin
    return TileStorageBytes(rows, columns, data_type) <= capacity_bytes;
end;
