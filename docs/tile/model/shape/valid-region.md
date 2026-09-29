<!-- GENERATED FROM: asl/tile/model/shape/valid-region.asl -->
# Valid Region

**Normative ASL source:** `asl/tile/model/shape/valid-region.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-SHAPE-VALID-REGION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-shape-valid-region-purpose role=purpose-scope -->
## Purpose and scope

This unit checks that a Tile's valid region and physical storage fit its capacity. It also finds the smallest SizeCode capacity that can represent a requested shape.

The valid region is the rectangle `valid_rows` by `valid_columns` at the top left of the physical `rows` by `columns` shape. Operations compute on the valid region; the rest of the physical shape is padding.

<!-- PTO-READER-BLOCK: tile-model-shape-valid-region-concepts role=concepts-state -->
## Concepts and visible state

The unit defines five helpers:

- `TileDescriptorShapeLegal` checks a requested shape at the derived row count.
- `TileDescriptorPhysicalShapeLegal` checks a stored physical shape.
- `TileStorageBytes` computes the storage of a physical shape.
- `TileStorageFitsCapacity` compares that storage with a capacity.
- `MinimumTileCapacityBytesForShape` searches SizeCodes 1 to 12.

Storage accounting is bit-packed. Two four-bit elements occupy one byte, and an odd final element rounds up. Row-paired E2M1X2 and E1M2X2 instead round each row up separately.

<!-- PTO-READER-BLOCK: tile-model-shape-valid-region-rules role=rules-interactions -->
## Rules and interactions

`TileDescriptorShapeLegal(capacity_bytes, columns, valid_rows, valid_columns, data_type)` holds when:

- `DerivedTileRows` is nonzero.
- `valid_rows` is at most the derived rows and `valid_columns` at most `columns`.
- `valid_rows x valid_columns` is at most the logical element capacity.

`TileDescriptorPhysicalShapeLegal` adds the stored `rows`: the shape must match capacity under the rows-and-columns rule, the valid region must fit inside it, and `TileStorageBytes` must not exceed the capacity.

Design point: a Shared source may be named without a size. The source comment states that a source-form `B.IOS` carries SizeCode 0. When the selected Shared register has no descriptor, the consumer derives the smallest capacity that represents its shape with `MinimumTileCapacityBytesForShape`, which returns the first SizeCode byte value that passes `TileDescriptorShapeLegal`. A result of 0 means no 128 B to 256 KiB size fits.

Design point: the physical check measures storage separately from the row derivation. For admitted odd column counts, fewer rows than the derived maximum are allowed, and the storage check confirms that those rows still fit.

<!-- PTO-READER-BLOCK: tile-model-shape-valid-region-boundaries role=boundaries -->
## Architectural boundaries

These helpers do not check capacity legality or pool space, and they do not apply to CUBE layouts, which have their own geometry owner.

`MinimumTileCapacityBytesForShape` searches the full 1 to 12 range. Whether the result is then legal for a Local or Shared role is decided by the caller.

<!-- PTO-READER-BLOCK: tile-model-shape-valid-region-example role=example-usage -->
## Non-normative reading example

A Shared read requests 32 columns of FP16 with a valid region of 20 by 30.

- 128 bytes: derived rows are 1024 / 512 = 2, fewer than 20 valid rows. Rejected.
- 256 and 512 bytes give 4 and 8 rows. Rejected.
- 1024 bytes give 16 rows. Rejected.
- 2048 bytes give 32 rows. 20 fits in 32, 30 fits in 32, and 600 elements fit in 1024. Accepted.

`MinimumTileCapacityBytesForShape` returns 2048.

For storage, a U4X2 Tile of 16 by 8 needs 16 x 8 x 4 = 512 bits, which is 64 bytes. A row-paired E2M1X2 Tile of 16 by 5 needs 16 x 3 = 48 bytes, because each row rounds up to whole pairs.

<!-- PTO-READER-BLOCK: tile-model-shape-valid-region-related role=related-owners-navigation -->
## Related owners

- [Rows and columns](rows-columns.md) owns `DerivedTileRows` and `TileShapeMatchesCapacity`.
- [CUBE cell geometry](cube-cell.md) owns the CUBE shape rules.
- [Shared registers](../state/shared-registers.md) uses the minimum-capacity search for size-less Shared reads.
- [Allocation](../state/allocation.md) asserts both shape checks.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/shape/valid-region.asl -->
```asl
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
    // Packed-X2 rows reserve a complete final byte for an odd logical column,
    // so row padding is not shared across row boundaries.
    if PackedTileDataTypeUsesRowLocalPairs(data_type) then
        if columns == 0 then return 0; end;
        return rows * PackedTileRowStorageBytes(
            columns as integer {1..65535}, data_type);
    end;
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

readonly func TileDescriptorPhysicalShapeLegal(
    capacity_bytes: integer {0..262144},
    rows: integer {0..65535}, columns: integer {0..65535},
    valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
    data_type: TileDataType) => boolean
begin
    return TileShapeMatchesCapacity(capacity_bytes, rows, columns, data_type) &&
           valid_rows <= rows && valid_columns <= columns &&
           valid_rows * valid_columns <=
               TileLogicalElementCapacity(capacity_bytes, data_type) &&
           TileStorageFitsCapacity(rows, columns, data_type, capacity_bytes);
end;
```
<!-- GENERATED-ASL-END: unit -->
