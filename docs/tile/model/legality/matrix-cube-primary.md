<!-- GENERATED FROM: asl/tile/model/legality/matrix-cube-primary.asl -->
# Matrix CUBE Primary

**Normative ASL source:** `asl/tile/model/legality/matrix-cube-primary.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-CUBE-PRIMARY}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-cube-primary.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-CUBE-PRIMARY","surface":"tile","classification":["model","legality","matrix-cube-primary"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE"]}

// NDF-BEGIN: PTO-CUBE-LOCAL-MATRIX-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local Matrix primary A, C, and D MUST use one compatible CUBE_M16 or
// CUBE_M32 layout, primary B MUST use CUBE_N8, and their logical M/N/K
// dimensions MUST remain independent of per-PE TSize.
// NDF-END: PTO-CUBE-LOCAL-MATRIX-001

pure func TileMatrixMLayoutLegal(
    layout: TileLayout,
    m: integer {1..65535}) => boolean
begin
    return (layout == TileLayout_CUBE_M16 && m <= 16) ||
           (layout == TileLayout_CUBE_M32 && m <= 32);
end;

readonly func TileMatrixLocalPrimaryInfoLegal(
    tile: TileInfo,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType,
    expected_layout: TileLayout) => boolean
begin
    return TileCubeDescriptorLegal(tile) && tile.contents_defined &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == valid_columns &&
           tile.data_type == data_type &&
           tile.layout == expected_layout;
end;

readonly func TileMatrixCubeInfosMatchDimensions(
    left: TileInfo, right: TileInfo,
    m: integer {0..65535}, n: integer {0..65535},
    k: integer {0..65535}) => boolean
begin
    if m == 0 || n == 0 || k == 0 then return FALSE; end;
    let positive_m = m as integer {1..65535};
    let positive_n = n as integer {1..65535};
    let positive_k = k as integer {1..65535};
    return TileMatrixMLayoutLegal(left.layout, positive_m) &&
           TileMatrixLocalPrimaryInfoLegal(
               left, positive_m, positive_k,
               left.data_type, left.layout) &&
           TileMatrixLocalPrimaryInfoLegal(
               right, positive_k, positive_n,
               right.data_type, TileLayout_CUBE_N8);
end;

readonly func TileMatrixLocalMOperandSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    return TileMatrixMLayoutLegal(tile.layout, valid_rows) &&
           TileMatrixLocalPrimaryInfoLegal(
               tile, valid_rows, valid_columns, data_type, tile.layout);
end;

readonly func TileMatrixLocalNOperandSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType) => boolean
begin
    return TileMatrixLocalPrimaryInfoLegal(
        _Tiles[[source]], valid_rows, valid_columns,
        data_type, TileLayout_CUBE_N8);
end;

readonly func TileMatrixLocalCubeAccumulatorSchemaLegal(
    accumulator: TileIndex,
    m: integer {1..65535},
    n: integer {1..65535},
    result_type: TileDataType,
    expected_layout: TileLayout,
    destination_capacity: integer {0..262144}) => boolean
begin
    let tile = _Tiles[[accumulator]];
    let output_converted =
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
    return TileMatrixLocalPrimaryInfoLegal(
               tile, m, n, result_type, expected_layout) &&
           (output_converted ||
            tile.capacity_bytes == destination_capacity);
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
