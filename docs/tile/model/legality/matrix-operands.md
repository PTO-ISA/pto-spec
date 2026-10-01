<!-- GENERATED FROM: asl/tile/model/legality/matrix-operands.asl -->
# Matrix Operands

**Normative ASL source:** `asl/tile/model/legality/matrix-operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-matrix-operands-purpose role=purpose-scope -->
## Purpose and scope

This unit checks the Local mathematical sources of a CUBE Matrix bundle, in stream order, before any source snapshot is taken. Mathematical sources are the operands of the product itself: the accumulator C, A and its scale, B and its scale, the bias, and the optional CScale Tile. Post-process sources are checked by the matrix-postprocess unit.

The entry point is `BundleMatrixLocalMathematicalSourcesLegal`. Its only caller is `ExecuteBundleTMATMULOperation`, which calls it for each `TMATMUL` and `TGEMV` form that passes the earlier bundle checks. The unit also defines one descriptor predicate per auxiliary role:

- `TileMatrixLocalAScaleSchemaLegal` and `TileMatrixLocalBScaleSchemaLegal` for MX scales.
- `TileMatrixLocalBiasSchemaLegal` for the bias.
- `TileMatrixLocalCScaleSchemaLegal` for CScale.

Two further predicates, `TileMatrixLocalOperandSchemaLegal` (RowMajor operand) and `TileMatrixInfoAccumulatorSchemaLegal`, have no caller in the current ASL.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-operands-concepts role=concepts-state -->
## Concepts and visible state

The unit reads `_Tiles`, the bundle Tile bindings through `BundleMatrixSourceAt`, and two fields of `_BundleFixedPointAttributes`: `pre_quant_mode` and `c_scale_en`. It writes nothing.

`BundleMatrixSourceAt(n)` returns the n-th valid source across all Tile bindings, counting `source0` before `source1` in each binding. If a source has a materialized subview, it returns the materialized Tile.

Each auxiliary role has a fixed descriptor:

| Role | Valid shape | Type | Layout |
| --- | --- | --- | --- |
| A scale | [M, groups] | scale carrier of A | `CUBE_M32` |
| B scale | [N, groups] | scale carrier of B | `CUBE_M32` |
| Bias | [1, N] | result type | `CUBE_N8` |
| CScale | [M, 1] | `U8` | `CUBE_M32` |

Each role also requires `contents_defined` and `TileCubeDescriptorLegal`. The scale carrier is `E8M0` or `U32` as defined by the matrix-functions unit.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-operands-rules role=rules-interactions -->
## Rules and interactions

`BundleMatrixLocalMathematicalSourcesLegal` walks an ordinal from 0 and stops at the first failure:

1. For an accumulator form, C is checked with `TileMatrixLocalCubeAccumulatorSchemaLegal` against [M, N], the result type, the M layout, and the D capacity.
2. If A is Local (Shared count 0 or equal to the right group size), A is checked with `TileMatrixLocalMOperandSchemaLegal`, then its scale if the function is MX and A's type needs one.
3. If the Shared count is 0, B is checked with `TileMatrixLocalNOperandSchemaLegal`, then its scale if needed.
4. For a bias form, the bias is checked.
5. If `c_scale_en` is set, the next source is CScale. The function must allow CScale, the result type must be FP32, and the CScale descriptor must be legal.

The layout C must match is Local A's layout when A is Local; otherwise it is C's own layout, so this walk does not constrain C's layout, and `BundleMatrixCooperativeMLayout` later requires the resolved layout to pass `TileMatrixMLayoutLegal`.

Design point: sources are identified by position, not by name. The same stream order is used later to fetch the operands for execution, so the preflight checks exactly the Tiles that the operation will read.

Design point: CScale requires an FP32 result type. The execution helper `TileProfileMatrixCScale` classifies each C element as FP32 and divides it by 2 raised to the `U8` exponent, so the preflight admits CScale only for the type that helper reads.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-operands-boundaries role=boundaries -->
## Architectural boundaries

This check runs in preflight, after the Shared schema and before post-process checks, destination allocation, and source snapshots. A FALSE result makes `ExecuteBundleTMATMULOperation` raise `Fault_TileLegality`, so no D is allocated and no source snapshot is taken.

`TileMatrixLocalCScaleSchemaLegal` is also asserted by the execution helper in the CUBE execution unit when CScale is present.

The source count itself is not checked here. `BundleMatrixDynamicBindingsComplete` in block dispatch first requires that the number of Local sources equals the mathematical count plus the post-process count.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-operands-example role=example-usage -->
## Non-normative reading example

Consider an all-Local `TMATMUL_ACC` with FP16 A and B, M = 16, N = 32, K = 64, and `c_scale_en` set. The result type is FP32.

- Ordinal 0 is C: valid shape [16, 32], FP32, and the layout of A; its capacity must equal D's unless `pre_quant_mode` is nonzero.
- Ordinal 1 is A: [16, 64], FP16, `CUBE_M16` or `CUBE_M32`.
- Ordinal 2 is B: [64, 32], FP16, `CUBE_N8`.
- Ordinal 3 is CScale: [16, 1], `U8`, `CUBE_M32`. Function 2 allows CScale and the result is FP32, so it passes.

With `TMATMUL` (function 0) instead, `c_scale_en` raises `Fault_TileLegality`, because function 0 does not allow CScale; `ExecuteBundleTMATMULOperation` rejects it before it calls this walk.

This example illustrates the current ASL owner and does not replace the normative operation.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-operands-related role=related-owners-navigation -->
## Related owners

- [Matrix CUBE primary](matrix-cube-primary.md) owns the A, B, and C descriptor checks.
- [Matrix functions](matrix-functions.md) owns the function table, scale carriers, and group counts.
- [Matrix postprocess](matrix-postprocess.md) checks the sources that follow these ones.
- [CUBE TMATMUL dispatch](../../../block/model/dispatch/cube-tmatmul.md) calls this check.
- [Matrix scale execution](../execution/matrix-scale.md) applies CScale and MX scales.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-operands.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS","surface":"tile","classification":["model","legality","matrix-operands"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-CUBE-PRIMARY","PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS"]}
// PTO-REQ-CUBE-OPERANDS-001: every Local matrix source descriptor is checked
// in stream order before any Local or Shared payload is snapshotted.

readonly func TileMatrixLocalOperandSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    return TileElementwiseSourceContentsDefined(source) &&
           IsNonzeroPowerOfTwo(tile.rows) &&
           IsNonzeroPowerOfTwo(tile.columns) &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == valid_columns &&
           tile.data_type == data_type &&
           tile.layout == TileLayout_RowMajor;
end;

readonly func TileMatrixLocalAScaleSchemaLegal(
    source: TileIndex,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    primary_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == valid_columns &&
           tile.data_type == TileMXScaleCarrierType(primary_type) &&
           tile.layout == TileLayout_CUBE_M32;
end;

readonly func TileMatrixLocalBScaleSchemaLegal(
    source: TileIndex,
    groups: integer {1..65535},
    n: integer {1..65535},
    primary_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == n &&
           tile.valid_columns == groups &&
           tile.data_type == TileMXScaleCarrierType(primary_type) &&
           tile.layout == TileLayout_CUBE_M32;
end;

readonly func TileMatrixLocalBiasSchemaLegal(
    source: TileIndex,
    n: integer {1..65535},
    accumulator_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == 1 &&
           tile.valid_columns == n &&
           tile.data_type == accumulator_type &&
           tile.layout == TileLayout_CUBE_N8;
end;

readonly func TileMatrixLocalCScaleSchemaLegal(
    source: TileIndex,
    m: integer {1..65535}) => boolean
begin
    let tile = _Tiles[[source]];
    return tile.contents_defined && TileCubeDescriptorLegal(tile) &&
           tile.valid_rows == m && tile.valid_columns == 1 &&
           tile.data_type == TileDataType_U8 &&
           tile.layout == TileLayout_CUBE_M32;
end;

readonly func TileMatrixInfoAccumulatorSchemaLegal(
    accumulator: TileIndex,
    m: integer {1..65535},
    n: integer {1..65535},
    result_type: TileDataType,
    destination_capacity: integer {0..262144}) => boolean
begin
    let tile = _Tiles[[accumulator]];
    let output_converted =
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
    return TileSourceContentsDefined(accumulator) &&
           TileInfoDescriptorLegal(tile) &&
           tile.valid_rows == m &&
           tile.valid_columns == n &&
           tile.data_type == result_type &&
           (tile.layout == TileLayout_CUBE_M16 ||
            tile.layout == TileLayout_CUBE_M32) &&
           (output_converted ||
            tile.capacity_bytes == destination_capacity);
end;

readonly func BundleMatrixLocalMathematicalSourcesLegal(
    function: integer {0..31},
    left_type: TileDataType,
    right_type: TileDataType,
    m: integer {1..65535},
    n: integer {1..65535},
    k: integer {1..65535},
    shared_count: integer {0..4},
    accumulator_type: TileDataType,
    destination_capacity: integer {0..262144}) => boolean
begin
    let left_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(left_type);
    let right_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(right_type);
    let left_scale_groups = if left_scale_present then
        TileMXScaleGroupCount(k, left_type) else 1;
    let right_scale_groups = if right_scale_present then
        TileMXScaleGroupCount(k, right_type) else 1;
    var ordinal: integer {0..6} = 0;
    let right_group = TileMatrixRightGroupSourceCount(
        function, right_type);
    let local_left_present = shared_count == 0 ||
        shared_count == right_group;
    let left_ordinal = if TileMatrixFunctionUsesAccumulator(function)
        then 1 else 0;
    let local_m_layout = if local_left_present then
        _Tiles[[BundleMatrixSourceAt(
            left_ordinal as integer {0..8})]].layout
        else if TileMatrixFunctionUsesAccumulator(function) then
            _Tiles[[BundleMatrixSourceAt(0)]].layout
        else if m <= 16 then TileLayout_CUBE_M16
        else if m <= 32 then TileLayout_CUBE_M32
        // Defensive default only: no legal bias or accumulator bundle can
        // reach this fallback, because those schemas require the resolved
        // ML to be CUBE_M16/CUBE_M32.
        else TileLayout_RowMajor;

    if TileMatrixFunctionUsesAccumulator(function) then
        let accumulator = BundleMatrixSourceAt(
            ordinal as integer {0..8});
        let accumulator_legal = TileMatrixLocalCubeAccumulatorSchemaLegal(
            accumulator, m, n, accumulator_type,
            local_m_layout, destination_capacity);
        if !accumulator_legal then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..6};
    end;

    if shared_count == 0 || shared_count == right_group then
        let left = BundleMatrixSourceAt(
            ordinal as integer {0..8});
        let left_legal = TileMatrixLocalMOperandSchemaLegal(
            left, m, k, left_type);
        if !left_legal then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..6};
        if left_scale_present then
            let left_scale = BundleMatrixSourceAt(
                ordinal as integer {0..8});
            if !TileMatrixLocalAScaleSchemaLegal(
                   left_scale, m, left_scale_groups, left_type) then
                return FALSE;
            end;
            ordinal = (ordinal + 1) as integer {0..6};
        end;
    end;

    if shared_count == 0 then
        let right = BundleMatrixSourceAt(
            ordinal as integer {0..8});
        let right_legal = TileMatrixLocalNOperandSchemaLegal(
            right, k, n, right_type);
        if !right_legal then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..6};
        if right_scale_present then
            let right_scale = BundleMatrixSourceAt(
                ordinal as integer {0..8});
            if !TileMatrixLocalBScaleSchemaLegal(
                   right_scale, right_scale_groups, n, right_type) then
                return FALSE;
            end;
            ordinal = (ordinal + 1) as integer {0..6};
        end;
    end;

    if TileMatrixFunctionUsesBias(function) then
        let bias = BundleMatrixSourceAt(
            ordinal as integer {0..8});
        if !TileMatrixLocalBiasSchemaLegal(
               bias, n, accumulator_type) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..6};
    end;

    if _BundleFixedPointAttributes.c_scale_en then
        let c_scale = BundleMatrixSourceAt(
            ordinal as integer {0..8});
        if !TileMatrixFunctionAllowsCScale(function) ||
           accumulator_type != TileDataType_FP32 ||
           !TileMatrixLocalCScaleSchemaLegal(c_scale, m) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
