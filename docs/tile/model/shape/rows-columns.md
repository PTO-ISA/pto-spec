<!-- GENERATED FROM: asl/tile/model/shape/rows-columns.asl -->
# Rows Columns

**Normative ASL source:** `asl/tile/model/shape/rows-columns.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-shape-rows-columns-purpose role=purpose-scope -->
## Purpose and scope

This unit decides how many physical rows a Tile has, given its byte capacity, its column count, and its element type. Other shape checks build on it.

It defines four helpers:

- `IsNonzeroPowerOfTwo`, which tests a 16-bit count.
- `TileDataTypeAllowsOddPhysicalColumns`, which names the types that may use a column count that is not a power of two.
- `DerivedTileRows` and `TileShapeMatchesCapacity`, which derive and check the row count.

<!-- PTO-READER-BLOCK: tile-model-shape-rows-columns-concepts role=concepts-state -->
## Concepts and visible state

Capacity (`capacity_bytes`, also called TSize) is a per-PE byte budget. It is not a logical dimension. For power-of-two columns, rows are derived from it; for admitted odd column counts, it bounds the stored rows.

There are two column profiles:

- Power-of-two columns, legal for every type. Except for the row-paired E2M1X2 and E1M2X2, the Tile must fill its capacity exactly.
- Other positive column counts, legal only for FP32, FP16, BF16, and the row-paired packed types E2M1X2 and E1M2X2. Capacity is then an upper bound on the storage of complete rows.

For E2M1X2 and E1M2X2 in the row-paired form, each row stores `(columns + 1) / 2` bytes, rounded down after adding one. An odd final column still reserves a whole byte.

<!-- PTO-READER-BLOCK: tile-model-shape-rows-columns-rules role=rules-interactions -->
## Rules and interactions

`DerivedTileRows(capacity_bytes, columns, data_type)` returns 0, meaning "no legal shape", when the capacity or column count is 0, or when the columns are not a power of two and the type is not admitted.

Otherwise:

1. For row-paired packed types, rows are `capacity_bytes / row_bytes`, rounded down.
2. For other types, rows are `capacity_bits / (columns x element_bits)`, rounded down.
3. With power-of-two columns, a nonzero remainder in step 2 returns 0.
4. A result of 0 or more than 65535 returns 0.

`TileShapeMatchesCapacity` then compares a stored `rows` with the derived value. Power-of-two profiles require equality. Admitted non-power-of-two profiles only require `rows <= derived_rows`.

Design point: the power-of-two profile keeps the exact capacity contract, so rows are fully determined by capacity, columns, and type. The admitted odd profiles instead use the complete rows that fit, leaving unused capacity as a descriptor tail, as the source comment states.

Design point: row-paired storage is row-local. Because each row rounds its own byte count up, padding for an odd final column never shares a byte with the next row.

<!-- PTO-READER-BLOCK: tile-model-shape-rows-columns-boundaries role=boundaries -->
## Architectural boundaries

These helpers are pure. They do not check valid regions, capacity legality, or pool space; the valid-region and allocation owners do that.

`HiF4X2`, `S4X2`, and `U4X2` are four-bit but not row-paired. They follow the generic rule in step 2 and must use power-of-two columns.

The 65535 bound is the width of the 16-bit row field, not a capacity rule.

<!-- PTO-READER-BLOCK: tile-model-shape-rows-columns-example role=example-usage -->
## Non-normative reading example

| Capacity | Columns | Type | Derived rows | Why |
| --- | --- | --- | --- | --- |
| 4096 | 16 | FP32 | 64 | 32768 bits / 512 bits per row, no remainder |
| 4096 | 12 | FP32 | 85 | 32768 / 384 = 85, remainder allowed for FP32 |
| 4096 | 12 | S32 | 0 | 12 is not a power of two and S32 is not admitted |
| 128 | 5 | E2M1X2 | 42 | each row stores 3 bytes; 128 / 3 = 42 |

For the second row, a stored `rows` of 80 also matches, because the admitted profile only requires `rows <= 85`.

<!-- PTO-READER-BLOCK: tile-model-shape-rows-columns-related role=related-owners-navigation -->
## Related owners

- [Valid region](valid-region.md) builds descriptor and storage checks on `DerivedTileRows`.
- [Packed boundary](../definedness/packed-boundary.md) defines `PackedTileRowStorageBytes`.
- [Descriptors](../state/descriptors.md) supplies `TileElementBits`.
- [Allocation](../state/allocation.md) chooses between derived and caller rows.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/shape/rows-columns.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS","surface":"tile","classification":["model","shape","rows-columns"],"depends_on":["PTO-TILE-MODEL-STATE-DESCRIPTORS","PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY"]}
// Non-packed architectural Tile dimensions use exact powers of two. Packed-X2
// RowMajor dimensions retain their logical Col while deriving each row's
// storage from its row-local pair count.
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

pure func TileDataTypeAllowsOddPhysicalColumns(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           PackedTileDataTypeUsesRowLocalPairs(data_type);
end;

// TSize is a per-PE byte capacity. Legacy power-of-two-column descriptors use
// the exact full-capacity row count. Explicitly admitted odd ordinary profiles
// use the capacity as an upper bound: every positive row count whose complete
// row-local storage fits is representable. Zero means that no legal 16-bit row
// count exists for the supplied shape.
pure func DerivedTileRows(capacity_bytes: integer {0..262144},
                          columns: integer {0..65535},
                          data_type: TileDataType) => integer {0..65535}
begin
    if capacity_bytes == 0 || columns == 0 ||
       (!IsNonzeroPowerOfTwo(columns) &&
        !TileDataTypeAllowsOddPhysicalColumns(data_type)) then
        return 0;
    end;
    if PackedTileDataTypeUsesRowLocalPairs(data_type) then
        let row_bytes = PackedTileRowStorageBytes(
            columns as integer {1..65535}, data_type);
        let rows = capacity_bytes DIVRM row_bytes;
        if rows == 0 || rows > 65535 then return 0; end;
        return rows as integer {0..65535};
    end;
    let capacity_bits: integer = capacity_bytes * 8;
    let row_bits: integer = columns * TileElementBits(data_type);
    if row_bits == 0 then return 0; end;
    // Legacy power-of-two columns retain the exact capacity contract. The
    // explicitly admitted odd ordinary FP shapes use the complete rows that
    // fit, leaving unused capacity as the descriptor tail.
    if IsNonzeroPowerOfTwo(columns) && capacity_bits MOD row_bits != 0 then
        return 0;
    end;
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
    if derived_rows == 0 || rows == 0 then return FALSE; end;
    if !IsNonzeroPowerOfTwo(columns) &&
       TileDataTypeAllowsOddPhysicalColumns(data_type) then
        // DerivedTileRows is the floor of capacity/row-storage for the
        // admitted odd profiles, so this is equivalent to a complete-row
        // storage-fit check without creating a shape-module dependency cycle.
        return rows <= derived_rows;
    end;
    return rows == derived_rows;
end;
```
<!-- GENERATED-ASL-END: unit -->
