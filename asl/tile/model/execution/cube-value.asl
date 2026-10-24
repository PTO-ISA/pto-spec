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
