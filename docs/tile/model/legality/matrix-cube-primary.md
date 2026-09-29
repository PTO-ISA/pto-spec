<!-- GENERATED FROM: asl/tile/model/legality/matrix-cube-primary.asl -->
# Matrix CUBE Primary

**Normative ASL source:** `asl/tile/model/legality/matrix-cube-primary.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-CUBE-PRIMARY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-matrix-cube-primary-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the descriptor checks for the Local primary operands of the CUBE Matrix family: `TMATMUL`, `TGEMV`, and their `_BIAS`, `_ACC`, and `_MX` variants. A primary operand is one of the matrices that take part in the product: A (the left M x K matrix), B (the right K x N matrix), C (the explicit accumulator input of an `_ACC` form), and D (the destination).

It defines six predicates:

- `TileMatrixMLayoutLegal` pairs an M-side layout with the M dimension.
- `TileMatrixLocalPrimaryInfoLegal` is the shared descriptor check behind the A, B, and C checks; D is checked by the CUBE destination resolver in block dispatch.
- `TileMatrixCubeInfosMatchDimensions` checks a Local A and Local B pair against M, N, and K.
- `TileMatrixLocalMOperandSchemaLegal` and `TileMatrixLocalNOperandSchemaLegal` check one A or one B source.
- `TileMatrixLocalCubeAccumulatorSchemaLegal` checks the C source.

All of them are read-only. They return a boolean and change no state.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-cube-primary-concepts role=concepts-state -->
## Concepts and visible state

A CUBE layout stores a Tile as fixed-size cells instead of plain rows. The M-side layouts are `CUBE_M16` and `CUBE_M32`; their physical row count is exactly 16 or 32. The N-side layout is `CUBE_N8`.

`TileMatrixMLayoutLegal` returns TRUE for `CUBE_M16` with M no greater than 16, or for `CUBE_M32` with M no greater than 32. Every other layout returns FALSE.

`TileMatrixLocalPrimaryInfoLegal` reads one `TileInfo` record and requires all of the following:

- `TileCubeDescriptorLegal` holds, so the Tile is allocated, numeric, and its stored CUBE repeat, cell, and byte counts match its shape.
- `contents_defined` is TRUE.
- `valid_rows`, `valid_columns`, `data_type`, and `layout` equal the expected values exactly.

Design point: the definedness test is part of the descriptor check. A Tile that was allocated but never written fails here, so a Matrix operation is rejected before it reads a payload that no producer has defined.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-cube-primary-rules role=rules-interactions -->
## Rules and interactions

The role rules follow the NDF clause `PTO-CUBE-LOCAL-MATRIX-001`:

- A must have valid shape [M, K], its own type, and a layout accepted by `TileMatrixMLayoutLegal`.
- B must have valid shape [K, N] and layout `CUBE_N8`.
- C must have valid shape [M, N], the result type, and the expected M layout supplied by the caller.

`TileMatrixCubeInfosMatchDimensions` returns FALSE at once if M, N, or K is 0. It then applies the A and B rules above.

`TileMatrixLocalCubeAccumulatorSchemaLegal` adds a capacity rule. When `pre_quant_mode` in `_BundleFixedPointAttributes` is 0, the C capacity must equal the D capacity. When a nonzero pre-quantization mode converts the output, the capacities may differ.

Design point: the shape checks compare valid rows and columns with M, N, and K, not with a capacity-derived row count. The M layout only bounds M by 16 or 32. This is how the M, N, and K dimensions stay independent of per-PE TSize, as the NDF clause requires.

Design point: a Matrix primary is never accepted as `U64`. `TileMatrixCubeInfosMatchDimensions` takes each expected type from the descriptor itself, so on its own it would accept a `U64` `CUBE_N8` B. Its callers also compare the types with `TileOrdinaryMatrixInputTypeSupported` or `TileMXInputTypeSupported`, and neither list contains `U64`. `CUBE_N8` with `U64` is left for auxiliary vector parameters.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-cube-primary-boundaries role=boundaries -->
## Architectural boundaries

These predicates run in preflight. In the bundle path, `ExecuteBundleTMATMULOperation` reaches them through `BundleMatrixLocalMathematicalSourcesLegal` before it allocates D or snapshots any source. A FALSE result raises `Fault_TileLegality`.

Other callers, grep-verified in the current ASL:

- `TileMatrixMLayoutLegal` also checks the D layout in the CUBE destination resolver and the resolved layout in `BundleMatrixCooperativeMLayout`.
- `TileMatrixCubeInfosMatchDimensions` backs `TileMatrixShapeLegal` for the direct Tile legality handlers, is one of the primary-shape alternatives in `TileMatrixInfoOptionalScalesLegal`, and appears in an `assert` after preflight for all-Local bundles.
- `TileMatrixLocalCubeAccumulatorSchemaLegal` is also asserted after allocation in the bundle path.

Shared primaries are checked by the Shared Matrix schema in block dispatch, not here.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-cube-primary-example role=example-usage -->
## Non-normative reading example

Consider an all-Local `TMATMUL` with M = 20, N = 24, K = 40, and FP16 for both A and B.

- A with layout `CUBE_M16` fails: 20 is greater than 16.
- A with layout `CUBE_M32` passes the layout rule, since 20 is at most 32. Its descriptor needs valid shape [20, 40], FP16, and 32 physical rows.
- B needs valid shape [40, 24], FP16, and layout `CUBE_N8`.
- If B was allocated but no producer has written it, `contents_defined` is FALSE and the bundle faults with `Fault_TileLegality` before D is allocated.

This example illustrates the current ASL owner and does not replace the normative operation.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-cube-primary-related role=related-owners-navigation -->
## Related owners

- [CUBE cell geometry](../shape/cube-cell.md) owns `TileCubeDescriptorLegal` inputs and the cell counts.
- [Matrix operands](matrix-operands.md) walks the Local source stream and calls these checks.
- [Matrix shape](matrix-shape.md) builds the direct Tile legality handlers on `TileMatrixCubeInfosMatchDimensions`.
- [CUBE TMATMUL dispatch](../../../block/model/dispatch/cube-tmatmul.md) shows the preflight order.
- [TMATMUL](../../matrix-and-matrix-vector/matrix-matrix/TMATMUL.md) is the reference instruction.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-cube-primary.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-CUBE-PRIMARY","surface":"tile","classification":["model","legality","matrix-cube-primary"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE"]}

// NDF-BEGIN: PTO-CUBE-LOCAL-MATRIX-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local Matrix primary A, C, and D MUST use one compatible CUBE_M16 or
// CUBE_M32 layout, primary B MUST use CUBE_N8, and their logical M/N/K
// dimensions MUST remain independent of per-PE TSize. Matrix primary roles
// never authorize U64 CUBE descriptors; CUBE_N8/U64 is auxiliary-only.
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
