<!-- GENERATED FROM: asl/tile/model/execution/cube-value.asl -->
# CUBE Value

**Normative ASL source:** `asl/tile/model/execution/cube-value.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-CUBE-VALUE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-cube-value-purpose role=purpose-scope -->
## Purpose and scope

This unit computes detached outputs for Shared matrix operations, including the primary result and optional row-maximum and group-maximum outputs.

<!-- PTO-READER-BLOCK: tile-model-execution-cube-value-concepts role=concepts-state -->
## Concepts and state

Ordinary matrix products use the accumulator type derived from the input types. MX products use `FP32` intermediate values and may consume left, right, and accumulator scales.

<!-- PTO-READER-BLOCK: tile-model-execution-cube-value-rules role=rules-interactions -->
## Rules and interactions

`TMATMULSharedToValues` and `TMATMULMXSharedWithOptionalScalesToValues` form the product, optionally add bias, and either return a partial result or run the matrix postprocess for all requested outputs.

<!-- PTO-READER-BLOCK: tile-model-execution-cube-value-boundaries role=boundaries -->
## Architectural boundaries

Legality, source publication, scale presence, and destination allocation are established by callers. A partial output deliberately bypasses final postprocessing and preserves the supplied auxiliary values.

<!-- PTO-READER-BLOCK: tile-model-execution-cube-value-example role=example-usage -->
## Non-normative reading example

When `partial_output` is false and row maxima are enabled, the helper returns the postprocessed primary Tile together with the generated row-maximum Tile and the requested group-maximum Tile.

<!-- PTO-READER-BLOCK: tile-model-execution-cube-value-related role=related-owners-navigation -->
## Related owners

- [Related owner](cube.md) defines matrix product, bias, and postprocess behavior used by these value-returning wrappers.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/cube-value.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-CUBE-VALUE","surface":"tile","classification":["model","execution","cube-value"],"depends_on":["PTO-TILE-MODEL-EXECUTION-CUBE","PTO-TILE-MODEL-EXECUTION-POSTPROCESS","PTO-TILE-MODEL-STATE-TYPES"]}

func TMATMULSharedToValues(
    destination: TileIndex, primary: TileOutputValueTarget,
    row_max: TileOutputValueTarget, group_max: TileOutputValueTarget,
    accumulator: TileIndex, left: TileInfo, right: TileInfo,
    bias: TileIndex, use_bias: boolean, accumulate: boolean,
    c_scale: TileIndex, c_scale_present: boolean,
    partial_output: boolean) => (TileInfo, TileInfo, TileInfo)
begin
    let intermediate_type = TileOrdinaryMatrixAccumulatorType(
        left.data_type, right.data_type);
    let product = MatrixProductResultFromTiles(destination, primary.value,
        accumulator, left, right, accumulate, c_scale, c_scale_present);
    let result = if use_bias then
        MatrixBiasResult(product, bias, intermediate_type)
        else product;
    if partial_output then
        return (result, row_max.value, group_max.value);
    end;
    return CommitMatrixResultToValues(primary, row_max, group_max,
        result, intermediate_type,
        _BundleFixedPointAttributes.row_max_en,
        _BundleFixedPointAttributes.group_max_en);
end;

func TMATMULMXSharedWithOptionalScalesToValues(
    destination: TileIndex, primary: TileOutputValueTarget,
    row_max: TileOutputValueTarget, group_max: TileOutputValueTarget,
    accumulator: TileIndex, left: TileInfo, left_scale: TileInfo,
    left_scale_present: boolean, right: TileInfo, right_scale: TileInfo,
    right_scale_present: boolean, bias: TileIndex, use_bias: boolean,
    accumulate: boolean, c_scale: TileIndex, c_scale_present: boolean,
    partial_output: boolean) => (TileInfo, TileInfo, TileInfo)
begin
    let intermediate_type = TileDataType_FP32;
    let product = MatrixMXProductResultWithOptionalScales(
        destination, primary.value, accumulator,
        left, left_scale, left_scale_present,
        right, right_scale, right_scale_present,
        accumulate, c_scale, c_scale_present);
    let result = if use_bias then
        MatrixBiasResult(product, bias, intermediate_type)
        else product;
    if partial_output then
        return (result, row_max.value, group_max.value);
    end;
    return CommitMatrixResultToValues(primary, row_max, group_max,
        result, intermediate_type,
        _BundleFixedPointAttributes.row_max_en,
        _BundleFixedPointAttributes.group_max_en);
end;
```
<!-- GENERATED-ASL-END: unit -->
