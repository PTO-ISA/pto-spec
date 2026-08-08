<!-- GENERATED FROM: asl/tile/model/shape/rows-columns.asl -->
# Rows Columns

**Normative ASL source:** `asl/tile/model/shape/rows-columns.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/shape/rows-columns.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS","surface":"tile","classification":["model","shape","rows-columns"],"depends_on":["PTO-TILE-MODEL-STATE-DESCRIPTORS"]}
// Architectural Tile dimensions use exact powers of two. This bounded form
// covers every 16-bit dimension value without relying on implementation
// integer bitwise operators.
pure func IsNonzeroPowerOfTwo(value: integer {0..65535}) => boolean
begin
    if value == 0 then return FALSE; end;
    var candidate: integer = 1;
    for exponent = 0 to 15 do
        if value == candidate then return TRUE; end;
        candidate = candidate * 2;
    end;
    return FALSE;
end;

// TSize is a per-PE byte capacity. Physical rows are descriptor state derived
// exactly from that capacity, the physical column count, and the element type.
// Zero means that no legal 16-bit row count exists for the supplied shape.
pure func DerivedTileRows(capacity_bytes: integer {0..262144},
                          columns: integer {0..65535},
                          data_type: TileDataType) => integer {0..65535}
begin
    if capacity_bytes == 0 || !IsNonzeroPowerOfTwo(columns) then
        return 0;
    end;
    let capacity_bits: integer = capacity_bytes * 8;
    let row_bits: integer = columns * TileElementBits(data_type);
    if row_bits == 0 || capacity_bits MOD row_bits != 0 then return 0; end;
    let rows: integer = capacity_bits DIVRM row_bits;
    if rows == 0 || rows > 65535 then return 0; end;
    return rows as integer {0..65535};
end;

pure func TileShapeMatchesCapacity(capacity_bytes: integer {0..262144},
                                   rows: integer {0..65535},
                                   columns: integer {0..65535},
                                   data_type: TileDataType) => boolean
begin
    let derived_rows = DerivedTileRows(capacity_bytes, columns, data_type);
    return derived_rows != 0 && rows == derived_rows;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
