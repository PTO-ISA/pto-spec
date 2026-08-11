<!-- GENERATED FROM: asl/tile/model/execution/cube.asl -->
# CUBE

**Normative ASL source:** `asl/tile/model/execution/cube.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-CUBE}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/cube.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-CUBE","surface":"tile","classification":["model","execution","cube"],"depends_on":["PTO-TILE-MODEL-MEMORY-RESTART","PTO-TILE-MODEL-EXECUTION-COMPLEX"]}
// PTO-REQ-CUBE-001: profile-defined matrix arithmetic with portable integer
// defaults. DavinciOO v5 CUBE operations name their Local destination D
// explicitly. ACC forms also name their Local accumulator input C explicitly;
// C is snapshotted before D is written so D == C has read-old/write-new
// behavior.

impdef func TileProfileMatrixAccumulate(accumulator: Word, left: Word, right: Word,
                                         destination_type: TileDataType,
                                         left_type: TileDataType,
                                         right_type: TileDataType) => Word
begin
    return accumulator + MultiplyWord(left, right);
end;

impdef func TileProfileMatrixBias(value: Word, bias: Word,
                                  destination_type: TileDataType,
                                  bias_type: TileDataType) => Word
begin
    return value + bias;
end;

impdef func TileProfileMatrixScaledAccumulate(
    accumulator: Word, left: Word, right: Word,
    left_scale: Word, right_scale: Word,
    destination_type: TileDataType, left_type: TileDataType,
    right_type: TileDataType, left_scale_type: TileDataType,
    right_scale_type: TileDataType) => Word
begin
    let scaled_left = MultiplyWord(left, left_scale);
    let scaled_right = MultiplyWord(right, right_scale);
    return accumulator + MultiplyWord(scaled_left, scaled_right);
end;

func MarkLocalTileValidRegionDefined(tile: TileInfo) => TileInfo
begin
    var result = tile;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            result.defined_elements[element] = '1';
        end;
    end;
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns)
            as integer {0..16384};
    result.contents_defined = TRUE;
    return result;
end;

func MatrixProductResultFromTiles(destination: TileIndex,
                                  accumulator: TileIndex,
                                  left_tile: TileInfo,
                                  right_tile: TileInfo,
                                  accumulate: boolean) => TileInfo
begin
    let destination_tile = _Tiles[[destination]];
    let accumulator_tile = _Tiles[[accumulator]];
    let selected_data_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    let accumulator_data_type =
        TileMatrixAccumulatorDataType(selected_data_type);
    let expected_destination_type = if _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0 then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else accumulator_data_type;
    assert left_tile.allocated && left_tile.contents_defined;
    assert right_tile.allocated && right_tile.contents_defined;
    assert left_tile.valid_columns == right_tile.valid_rows;
    assert destination_tile.allocated;
    assert destination_tile.valid_rows == left_tile.valid_rows;
    assert destination_tile.valid_columns == right_tile.valid_columns;
    assert destination_tile.data_type == expected_destination_type;
    if accumulate then
        assert accumulator_tile.allocated && accumulator_tile.contents_defined;
        assert accumulator_tile.valid_rows == left_tile.valid_rows;
        assert accumulator_tile.valid_columns == right_tile.valid_columns;
        assert accumulator_tile.data_type == accumulator_data_type;
        assert accumulator_tile.layout == destination_tile.layout;
        assert accumulator_tile.capacity_bytes == destination_tile.capacity_bytes;
    end;

    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    var result: TileInfo = destination_tile;
    result.data_type = accumulator_data_type;
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.location = TileLocation_Matrix;
    var result_payload: TilePayload = destination_tile.payload;
    let accumulator_payload = accumulator_tile.payload;
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to right_tile.valid_columns - 1 looplimit 65536 do
            let result_element = TileLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            let accumulator_element = if accumulate then
                TileLinearIndex(accumulator_tile,
                    row as integer {0..65535}, column as integer {0..65535})
                else 0;
            var sum: Word = if accumulate then
                accumulator_payload[[accumulator_element]] else Zeros{PTO_XLEN};
            for inner = 0 to left_tile.valid_columns - 1 looplimit 65536 do
                let left_element = TileLinearIndex(left_tile,
                    row as integer {0..65535}, inner as integer {0..65535});
                let right_element = TileLinearIndex(right_tile,
                    inner as integer {0..65535}, column as integer {0..65535});
                sum = TileProfileMatrixAccumulate(sum,
                    left_payload[[left_element]], right_payload[[right_element]],
                    result.data_type, left_tile.data_type,
                    right_tile.data_type);
            end;
            result_payload[[result_element]] = sum;
        end;
    end;
    result.payload = result_payload;
    return MarkLocalTileValidRegionDefined(result);
end;

func MatrixProductResult(destination: TileIndex, accumulator: TileIndex,
                         left: TileIndex, right: TileIndex,
                         accumulate: boolean) => TileInfo
begin
    return MatrixProductResultFromTiles(destination, accumulator,
        _Tiles[[left]], _Tiles[[right]], accumulate);
end;

func MatrixBiasResult(input: TileInfo, bias: TileIndex) => TileInfo
begin
    let bias_tile = _Tiles[[bias]];
    let bias_payload = bias_tile.payload;
    assert bias_tile.allocated && bias_tile.contents_defined;
    assert bias_tile.valid_rows == 1 ||
           bias_tile.valid_rows == input.valid_rows;
    assert bias_tile.valid_columns == 1 ||
           bias_tile.valid_columns == input.valid_columns;
    var result = input;
    var result_payload = input.payload;
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        for column = 0 to input.valid_columns - 1 looplimit 65536 do
            let result_element = TileLinearIndex(input,
                row as integer {0..65535}, column as integer {0..65535});
            let bias_row = if bias_tile.valid_rows == 1 then 0 else row;
            let bias_column = if bias_tile.valid_columns == 1 then 0 else column;
            let bias_element = TileLinearIndex(bias_tile,
                bias_row as integer {0..65535}, bias_column as integer {0..65535});
            result_payload[[result_element]] = TileProfileMatrixBias(
                input.payload[[result_element]], bias_payload[[bias_element]],
                input.data_type, bias_tile.data_type);
        end;
    end;
    result.payload = result_payload;
    return result;
end;

func MatrixMXProductResultFromTiles(destination: TileIndex,
                                    accumulator: TileIndex,
                                    left_tile: TileInfo,
                                    left_scale_tile: TileInfo,
                                    right_tile: TileInfo,
                                    right_scale_tile: TileInfo,
                                    accumulate: boolean) => TileInfo
begin
    let destination_tile = _Tiles[[destination]];
    let accumulator_tile = _Tiles[[accumulator]];
    let selected_data_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    let accumulator_data_type =
        TileMatrixAccumulatorDataType(selected_data_type);
    let expected_destination_type = if _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0 then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else accumulator_data_type;
    assert left_tile.allocated && left_tile.contents_defined;
    assert right_tile.allocated && right_tile.contents_defined;
    assert left_scale_tile.allocated && left_scale_tile.contents_defined;
    assert right_scale_tile.allocated && right_scale_tile.contents_defined;
    assert left_tile.valid_columns == right_tile.valid_rows;
    assert destination_tile.allocated;
    assert destination_tile.valid_rows == left_tile.valid_rows;
    assert destination_tile.valid_columns == right_tile.valid_columns;
    assert destination_tile.data_type == expected_destination_type;
    if accumulate then
        assert accumulator_tile.allocated && accumulator_tile.contents_defined;
        assert accumulator_tile.valid_rows == left_tile.valid_rows;
        assert accumulator_tile.valid_columns == right_tile.valid_columns;
        assert accumulator_tile.data_type == accumulator_data_type;
        assert accumulator_tile.layout == destination_tile.layout;
        assert accumulator_tile.capacity_bytes == destination_tile.capacity_bytes;
    end;

    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    let left_scale_payload = left_scale_tile.payload;
    let right_scale_payload = right_scale_tile.payload;
    var result: TileInfo = destination_tile;
    result.data_type = accumulator_data_type;
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.location = TileLocation_Matrix;
    var result_payload = destination_tile.payload;
    let accumulator_payload = accumulator_tile.payload;
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to right_tile.valid_columns - 1 looplimit 65536 do
            let result_element = TileLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            let accumulator_element = if accumulate then
                TileLinearIndex(accumulator_tile,
                    row as integer {0..65535}, column as integer {0..65535})
                else 0;
            var sum: Word = if accumulate then
                accumulator_payload[[accumulator_element]] else Zeros{PTO_XLEN};
            for inner = 0 to left_tile.valid_columns - 1 looplimit 65536 do
                let left_element = TileLinearIndex(left_tile,
                    row as integer {0..65535}, inner as integer {0..65535});
                let right_element = TileLinearIndex(right_tile,
                    inner as integer {0..65535}, column as integer {0..65535});
                let scale_block =
                    (inner DIVRM 32) as integer {0..65535};
                let left_scale_element = TileLinearIndex(left_scale_tile,
                    row as integer {0..65535}, scale_block);
                let right_scale_element = TileLinearIndex(right_scale_tile,
                    scale_block, column as integer {0..65535});
                sum = TileProfileMatrixScaledAccumulate(
                    sum, left_payload[[left_element]],
                    right_payload[[right_element]],
                    left_scale_payload[[left_scale_element]],
                    right_scale_payload[[right_scale_element]],
                    result.data_type, left_tile.data_type,
                    right_tile.data_type, left_scale_tile.data_type,
                    right_scale_tile.data_type);
            end;
            result_payload[[result_element]] = sum;
        end;
    end;
    result.payload = result_payload;
    return MarkLocalTileValidRegionDefined(result);
end;

func MatrixMXProductResult(destination: TileIndex, accumulator: TileIndex,
                           left: TileIndex, left_scale: TileIndex,
                           right: TileIndex, right_scale: TileIndex,
                           accumulate: boolean) => TileInfo
begin
    return MatrixMXProductResultFromTiles(destination, accumulator,
        _Tiles[[left]], _Tiles[[left_scale]], _Tiles[[right]],
        _Tiles[[right_scale]], accumulate);
end;

func TMATMULShared(destination: TileIndex, accumulator: TileIndex,
                   left: TileInfo, right: TileInfo,
                   bias: TileIndex, use_bias: boolean,
                   accumulate: boolean)
begin
    let product = MatrixProductResultFromTiles(destination, accumulator,
        left, right, accumulate);
    let result = if use_bias then MatrixBiasResult(product, bias)
        else product;
    CommitMatrixResult(destination, result);
end;

func TMATMULMXShared(destination: TileIndex, accumulator: TileIndex,
                     left: TileInfo, left_scale: TileInfo,
                     right: TileInfo, right_scale: TileInfo,
                     bias: TileIndex, use_bias: boolean,
                     accumulate: boolean)
begin
    let product = MatrixMXProductResultFromTiles(destination, accumulator,
        left, left_scale, right, right_scale, accumulate);
    let result = if use_bias then MatrixBiasResult(product, bias)
        else product;
    CommitMatrixResult(destination, result);
end;

func TMATMUL(destination: TileIndex, left: TileIndex, right: TileIndex)
begin
    let result = MatrixProductResult(destination, destination,
        left, right, FALSE);
    CommitMatrixResult(destination, result);
end;

func TMATMUL_BIAS(destination: TileIndex, left: TileIndex, right: TileIndex,
                  bias: TileIndex)
begin
    let product = MatrixProductResult(destination, destination,
        left, right, FALSE);
    let result = MatrixBiasResult(product, bias);
    CommitMatrixResult(destination, result);
end;

func TMATMUL_ACC(destination: TileIndex, accumulator: TileIndex,
                 left: TileIndex, right: TileIndex)
begin
    let result = MatrixProductResult(destination, accumulator,
        left, right, TRUE);
    CommitMatrixResult(destination, result);
end;

func TMATMUL_MX(destination: TileIndex, left: TileIndex,
                left_scale: TileIndex, right: TileIndex,
                right_scale: TileIndex)
begin
    let result = MatrixMXProductResult(destination, destination,
        left, left_scale, right, right_scale, FALSE);
    CommitMatrixResult(destination, result);
end;

func TMATMUL_MX_BIAS(destination: TileIndex, left: TileIndex,
                     left_scale: TileIndex, right: TileIndex,
                     right_scale: TileIndex,
                     bias: TileIndex)
begin
    let product = MatrixMXProductResult(destination, destination,
        left, left_scale, right, right_scale, FALSE);
    let result = MatrixBiasResult(product, bias);
    CommitMatrixResult(destination, result);
end;

func TMATMUL_MX_ACC(destination: TileIndex, accumulator: TileIndex,
                    left: TileIndex, left_scale: TileIndex,
                    right: TileIndex, right_scale: TileIndex)
begin
    let result = MatrixMXProductResult(destination, accumulator,
        left, left_scale, right, right_scale, TRUE);
    CommitMatrixResult(destination, result);
end;

func TGEMV(destination: TileIndex, matrix: TileIndex, vector: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    let result = MatrixProductResult(destination, destination,
        matrix, vector, FALSE);
    CommitMatrixResult(destination, result);
end;

func TGEMV_BIAS(destination: TileIndex, matrix: TileIndex,
                vector: TileIndex, bias: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    let product = MatrixProductResult(destination, destination,
        matrix, vector, FALSE);
    let result = MatrixBiasResult(product, bias);
    CommitMatrixResult(destination, result);
end;

func TGEMV_ACC(destination: TileIndex, accumulator: TileIndex,
               matrix: TileIndex, vector: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    let result = MatrixProductResult(destination, accumulator,
        matrix, vector, TRUE);
    CommitMatrixResult(destination, result);
end;

func TGEMV_MX(destination: TileIndex, matrix: TileIndex,
              left_scale: TileIndex, vector: TileIndex,
              right_scale: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    let result = MatrixMXProductResult(destination, destination,
        matrix, left_scale, vector, right_scale, FALSE);
    CommitMatrixResult(destination, result);
end;

func TGEMV_MX_BIAS(destination: TileIndex, matrix: TileIndex,
                   left_scale: TileIndex, vector: TileIndex,
                   right_scale: TileIndex,
                   bias: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    let product = MatrixMXProductResult(destination, destination,
        matrix, left_scale, vector, right_scale, FALSE);
    let result = MatrixBiasResult(product, bias);
    CommitMatrixResult(destination, result);
end;

func TGEMV_MX_ACC(destination: TileIndex, accumulator: TileIndex,
                  matrix: TileIndex, left_scale: TileIndex,
                  vector: TileIndex, right_scale: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    let result = MatrixMXProductResult(destination, accumulator,
        matrix, left_scale, vector, right_scale, TRUE);
    CommitMatrixResult(destination, result);
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
