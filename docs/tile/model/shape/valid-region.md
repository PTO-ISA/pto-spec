<!-- GENERATED FROM: asl/tile/model/shape/valid-region.asl -->
# Valid Region

**Normative ASL source:** `asl/tile/model/shape/valid-region.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-SHAPE-VALID-REGION}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/shape/valid-region.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-SHAPE-VALID-REGION","surface":"tile","classification":["model","shape","valid-region"],"depends_on":["PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS"]}
pure func TileDescriptorShapeLegal(capacity_bytes: integer {0..262144},
                                   columns: integer {0..65535},
                                   valid_rows: integer {0..65535},
                                   valid_columns: integer {0..65535},
                                   data_type: TileDataType) => boolean
begin
    let rows = DerivedTileRows(capacity_bytes, columns, data_type);
    return rows != 0 && valid_rows <= rows && valid_columns <= columns;
end;

pure func TileDataTypeIsFourBit(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_E2M1X2 ||
           data_type == TileDataType_E1M2X2 ||
           data_type == TileDataType_HiF4X2 ||
           data_type == TileDataType_S4X2 ||
           data_type == TileDataType_U4X2;
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
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
