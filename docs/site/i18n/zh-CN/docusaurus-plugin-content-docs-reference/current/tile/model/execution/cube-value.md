<!-- GENERATED FROM: asl/tile/model/execution/cube-value.asl -->
# CUBE Value

**Normative ASL source:** `asl/tile/model/execution/cube-value.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-CUBE-VALUE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-cube-value-purpose role=purpose-scope -->
## 用途与范围

本单元为 Shared 矩阵操作计算分离输出，包括主结果以及可选的行最大值和分组最大值输出。

<!-- PTO-READER-BLOCK: tile-model-execution-cube-value-concepts role=concepts-state -->
## 概念与状态

普通矩阵乘法使用由输入类型推导的累加器类型。MX 矩阵乘法使用 `FP32` 中间值，并可使用左、右和累加器缩放。

<!-- PTO-READER-BLOCK: tile-model-execution-cube-value-rules role=rules-interactions -->
## 规则与交互

`TMATMULSharedToValues` 与 `TMATMULMXSharedWithOptionalScalesToValues` 形成乘积，可选加入偏置，然后返回部分结果或为所有请求的输出执行矩阵后处理。

<!-- PTO-READER-BLOCK: tile-model-execution-cube-value-boundaries role=boundaries -->
## 架构边界

调用者负责确认合法性、源发布、缩放存在性和目的分配。部分输出会有意绕过最终后处理，并保留调用者提供的辅助值。

<!-- PTO-READER-BLOCK: tile-model-execution-cube-value-example role=example-usage -->
## 非规范阅读示例

当 `partial_output` 为 false 且启用行最大值时，辅助函数返回后处理后的主 Tile，同时返回生成的行最大值 Tile 和请求的分组最大值 Tile。

<!-- PTO-READER-BLOCK: tile-model-execution-cube-value-related role=related-owners-navigation -->
## 相关所有者

- [相关所有者](cube.md) 定义这些值返回封装所使用的矩阵乘积、偏置和后处理行为。
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
