<!-- GENERATED FROM: asl/block/model/dispatch/destination-auxiliary.asl -->
# Destination Auxiliary

**Normative ASL source:** `asl/block/model/dispatch/destination-auxiliary.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-destination-auxiliary-purpose role=purpose-scope -->
## Purpose and scope

This unit holds small helpers used while bundle destinations are shaped and allocated. It does not choose which destinations exist; the destination-shape and CUBE destination owners do that.

It defines five functions:

- `BundleGroupMaxColumns` computes the column count of a GroupMax auxiliary output.
- `BundleDestinationIsOrdinaryTCVT` recognizes a non-CUBE `TCVT` destination.
- `ConfigureBundleTileDestination` writes the destination descriptor through the correct allocation family.
- `SmallestTilePhysicalColumns` returns the smallest power of two that holds a valid column count.
- `MarkBundleTIMG2COLDestinationsMatrix`, which contains only `assert TRUE`.

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-auxiliary-concepts role=concepts-state -->
## Concepts and visible state

A GroupMax output stores one maximum per group of `group_n` columns. `BundleGroupMaxColumns` reads `_BundleFixedPointAttributes.group_max_en` and `group_n_code`. `BundleFPATRGroupN` maps codes 0 to 9 to 0, 8, 16, 32, 48, 64, 80, 96, 112, and 128. When GroupMax is enabled and `group_n` is nonzero, the result is `columns` divided by `group_n`, rounded up. Otherwise the column count is returned unchanged.

`ConfigureBundleTileDestination` is the only function here that writes state. It writes the `_Tiles` descriptor and `_TileAllocationMasks` entry of the given index through one of two allocation families.

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-auxiliary-rules role=rules-interactions -->
## Rules and interactions

`ConfigureBundleTileDestination` routes by its `tgpr2t` argument. The destination-shape owner sets that argument for `TGPR2T` and for any `CUBE_M16` or `CUBE_M32` destination layout.

- When `tgpr2t` is true, it calls `ConfigureCubeTileForMaskWithPhysical` with the supplied physical rows and columns, and returns that call's result.
- Otherwise it calls `ConfigureTileForMask`, and returns true. It passes the supplied physical rows when `preserve_physical_rows` is true, and otherwise rows derived from capacity, columns, and type.

Design point: the CUBE family returns false when the shape or capacity does not fit, and this function passes that result to its caller, which raises `Fault_TileAllocation`. The ordinary family asserts its preconditions instead, so the caller must have validated the shape before this call.

Design point: the caller sets `preserve_physical_rows` from `BundleDestinationIsOrdinaryTCVT` and supplies the source's physical rows. `ConfigureTileForMask` keeps supplied rows only when the column count is not a power of two and the type allows odd physical columns; otherwise it uses rows derived from capacity. A non-CUBE `TCVT` destination can therefore keep its source's row count for such odd-column shapes.

The `exact_cube_columns` argument is accepted but not read in the current body.

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-auxiliary-boundaries role=boundaries -->
## Architectural boundaries

A search of the current ASL finds no caller of `SmallestTilePhysicalColumns` or `MarkBundleTIMG2COLDestinationsMatrix`. The latter has no effect; its comment states that destination representation is established by the explicit layout contract and that no execution-engine or location tag is materialized.

`BundleGroupMaxColumns` is used, for example, by the CUBE destination owner and the destination-shape owner. It does not validate `group_n_code`; the `B.FPATR` owner limits that code to 0 through 9.

This unit raises no fault itself.

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-auxiliary-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Suppose `B.FPATR` sets `group_max_en` true and `group_n_code` 3, so `group_n` is 32. For a D output with 100 columns, `BundleGroupMaxColumns(100)` returns `ceil(100 / 32)`, which is 4. With `group_max_en` false, it returns 100.

For comparison, `SmallestTilePhysicalColumns(100)` returns 128, the smallest power of two that is at least 100.

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-auxiliary-related role=related-owners-navigation -->
## Related owners

- [Destination shape](destination-shape.md) calls `ConfigureBundleTileDestination` and `BundleDestinationIsOrdinaryTCVT`.
- [CUBE destination](cube-destination.md) uses `BundleGroupMaxColumns` for the matrix destination group.
- [Tile allocation](../../../tile/model/state/allocation.md) defines both allocation families.
- [B.FPATR](../../attributes/B.FPATR.md) is the instruction page for the GroupMax controls.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/destination-auxiliary.asl -->
```asl
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
```
<!-- GENERATED-ASL-END: unit -->
