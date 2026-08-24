// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-CUBE","surface":"tile","classification":["model","execution","cube"],"depends_on":["PTO-TILE-MODEL-MEMORY-RESTART","PTO-TILE-MODEL-EXECUTION-COMPLEX","PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE"]}
// PTO-REQ-CUBE-001: profile-defined matrix arithmetic with portable integer
// defaults. CUBE operations name their Local destination D explicitly. ACC
// forms also name their Local accumulator input C explicitly;
// C is snapshotted before D is written so D == C has read-old/write-new
// behavior.

impdef func TileProfileMatrixAccumulate(accumulator: Word, left: Word, right: Word,
                                         destination_type: TileDataType,
                                         left_type: TileDataType,
                                         right_type: TileDataType,
                                         control: NumericExecutionControl)
                                         => Word
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
    left_scale_present: boolean, right_scale_present: boolean,
    destination_type: TileDataType, left_type: TileDataType,
    right_type: TileDataType, left_scale_type: TileDataType,
    right_scale_type: TileDataType) => Word
begin
    let scaled_left = if left_scale_present then
        MultiplyWord(left, left_scale)
    else
        left;
    let scaled_right = if right_scale_present then
        MultiplyWord(right, right_scale)
    else
        right;
    return accumulator + MultiplyWord(scaled_left, scaled_right);
end;

func MarkLocalTileValidRegionDefined(tile: TileInfo) => TileInfo
begin
    var result = tile;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.packed_defined_elements = ZeroPackedTileDefinedElements();
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let element = TileStorageIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            result.defined_elements[element] = '1';
        end;
    end;
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns) as integer {0..524288};
    result.contents_defined = TRUE;
    return result;
end;

func MatrixProductResultFromTiles(destination: TileIndex,
                                  accumulator: TileIndex,
                                  left_tile: TileInfo,
                                  right_tile: TileInfo,
                                  accumulate: boolean,
                                  c_scale: TileIndex,
                                  c_scale_present: boolean) => TileInfo
begin
    let destination_tile = _Tiles[[destination]];
    let accumulator_tile = _Tiles[[accumulator]];
    let selected_data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let accumulator_data_type =
        TileMatrixAccumulatorDataType(selected_data_type);
    let expected_destination_type = if _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0 then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else accumulator_data_type;
    let output_converted = _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
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
        assert output_converted ||
               accumulator_tile.capacity_bytes == destination_tile.capacity_bytes;
    end;
    if c_scale_present then
        assert accumulate &&
               TileMatrixLocalCScaleSchemaLegal(
                   c_scale,
                   left_tile.valid_rows as integer {1..65535});
    end;

    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    var result: TileInfo = destination_tile;
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = ZeroPackedTileDefinedElements();
    result.location = TileLocation_Matrix;
    var result_payload: TilePayload = destination_tile.payload;
    let control = NumericExecutionControl {
        rounding_mode = DecodeBundleRoundingSelection(
            _BundleDataAttributes.rounding_mode).rounding_mode,
        saturating = _BundleDataAttributes.saturating
    };
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to right_tile.valid_columns - 1 looplimit 65536 do
            let result_element = TileStorageIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            var sum: Word = MatrixInitialAccumulatorValue(
                accumulator_tile, accumulate,
                row as integer {0..65535},
                column as integer {0..65535},
                c_scale, c_scale_present);
            for inner = 0 to left_tile.valid_columns - 1 looplimit 65536 do
                let left_element = TileStorageIndex(left_tile,
                    row as integer {0..65535}, inner as integer {0..65535});
                let right_element = TileStorageIndex(right_tile,
                    inner as integer {0..65535}, column as integer {0..65535});
                sum = TileProfileMatrixAccumulate(sum,
                    left_payload[[left_element]], right_payload[[right_element]],
                    accumulator_data_type, left_tile.data_type,
                    right_tile.data_type, control);
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
        _Tiles[[left]], _Tiles[[right]], accumulate, 0, FALSE);
end;

func MatrixBiasResult(input: TileInfo, bias: TileIndex,
                      intermediate_type: TileDataType) => TileInfo
begin
    let bias_tile = _Tiles[[bias]];
    let bias_payload = bias_tile.payload;
    assert bias_tile.allocated && bias_tile.contents_defined;
    assert bias_tile.valid_rows == 1;
    assert bias_tile.valid_columns == input.valid_columns;
    assert bias_tile.layout == TileLayout_RowMajor;
    var result = input;
    var result_payload = input.payload;
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        for column = 0 to input.valid_columns - 1 looplimit 65536 do
            let result_element = TileStorageIndex(input,
                row as integer {0..65535}, column as integer {0..65535});
            let bias_element = TileStorageIndex(bias_tile,
                0, column as integer {0..65535});
            result_payload[[result_element]] = TileProfileMatrixBias(
                input.payload[[result_element]], bias_payload[[bias_element]],
                intermediate_type, bias_tile.data_type);
        end;
    end;
    result.payload = result_payload;
    return result;
end;

func MatrixMXProductResultFromTiles(destination: TileIndex,
                                    accumulator: TileIndex,
                                    left_tile: TileInfo,
                                    left_scale_tile: TileInfo,
                                    left_scale_present: boolean,
                                    right_tile: TileInfo,
                                    right_scale_tile: TileInfo,
                                    right_scale_present: boolean,
                                    accumulate: boolean,
                                    c_scale: TileIndex,
                                    c_scale_present: boolean) => TileInfo
begin
    let destination_tile = _Tiles[[destination]];
    let accumulator_tile = _Tiles[[accumulator]];
    let selected_data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let accumulator_data_type =
        TileMatrixAccumulatorDataType(selected_data_type);
    let expected_destination_type = if _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0 then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else accumulator_data_type;
    let output_converted = _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
    assert left_tile.allocated && left_tile.contents_defined;
    assert right_tile.allocated && right_tile.contents_defined;
    assert !left_scale_present ||
           (left_scale_tile.allocated && left_scale_tile.contents_defined);
    assert !right_scale_present ||
           (right_scale_tile.allocated && right_scale_tile.contents_defined);
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
        assert output_converted ||
               accumulator_tile.capacity_bytes == destination_tile.capacity_bytes;
    end;
    if c_scale_present then
        assert accumulate &&
               TileMatrixLocalCScaleSchemaLegal(
                   c_scale,
                   left_tile.valid_rows as integer {1..65535});
    end;

    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    let left_scale_payload = left_scale_tile.payload;
    let right_scale_payload = right_scale_tile.payload;
    var result: TileInfo = destination_tile;
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = ZeroPackedTileDefinedElements();
    result.location = TileLocation_Matrix;
    var result_payload = destination_tile.payload;
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to right_tile.valid_columns - 1 looplimit 65536 do
            let result_element = TileStorageIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            var sum: Word = MatrixInitialAccumulatorValue(
                accumulator_tile, accumulate,
                row as integer {0..65535},
                column as integer {0..65535},
                c_scale, c_scale_present);
            for inner = 0 to left_tile.valid_columns - 1 looplimit 65536 do
                let left_element = TileStorageIndex(left_tile,
                    row as integer {0..65535}, inner as integer {0..65535});
                let right_element = TileStorageIndex(right_tile,
                    inner as integer {0..65535}, column as integer {0..65535});
                let left_scale_element = if left_scale_present then
                    MatrixLeftScaleElement(
                        left_scale_tile, left_tile.data_type,
                        row as integer {0..65535},
                        inner as integer {0..65535})
                else
                    0;
                let right_scale_element = if right_scale_present then
                    MatrixRightScaleElement(
                        right_scale_tile, right_tile.data_type,
                        column as integer {0..65535},
                        inner as integer {0..65535})
                else
                    0;
                let left_scale_value = if left_scale_present then
                    left_scale_payload[[left_scale_element]]
                else
                    Zeros{PTO_XLEN};
                let right_scale_value = if right_scale_present then
                    right_scale_payload[[right_scale_element]]
                else
                    Zeros{PTO_XLEN};
                sum = TileProfileMatrixScaledAccumulate(
                    sum, left_payload[[left_element]],
                    right_payload[[right_element]],
                    left_scale_value, right_scale_value,
                    left_scale_present, right_scale_present,
                    accumulator_data_type, left_tile.data_type,
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
    let left_scale_present =
        TileMXInputTypeNeedsScale(_Tiles[[left]].data_type);
    let right_scale_present =
        TileMXInputTypeNeedsScale(_Tiles[[right]].data_type);
    return MatrixMXProductResultFromTiles(
        destination, accumulator,
        _Tiles[[left]], _Tiles[[left_scale]], left_scale_present,
        _Tiles[[right]], _Tiles[[right_scale]], right_scale_present,
        accumulate, 0, FALSE);
end;

func MatrixMXProductResultWithOptionalScales(
    destination: TileIndex, accumulator: TileIndex,
    left: TileInfo, left_scale: TileInfo, left_scale_present: boolean,
    right: TileInfo, right_scale: TileInfo, right_scale_present: boolean,
    accumulate: boolean,
    c_scale: TileIndex, c_scale_present: boolean) => TileInfo
begin
    return MatrixMXProductResultFromTiles(destination, accumulator,
        left, left_scale, left_scale_present, right, right_scale,
        right_scale_present, accumulate, c_scale, c_scale_present);
end;

func TMATMULShared(destination: TileIndex, accumulator: TileIndex,
                   left: TileInfo, right: TileInfo,
                   bias: TileIndex, use_bias: boolean,
                   accumulate: boolean,
                   c_scale: TileIndex, c_scale_present: boolean)
begin
    let intermediate_type = TileOrdinaryMatrixAccumulatorType(
        left.data_type, right.data_type);
    let product = MatrixProductResultFromTiles(destination, accumulator,
        left, right, accumulate, c_scale, c_scale_present);
    let result = if use_bias then
        MatrixBiasResult(product, bias, intermediate_type)
        else product;
    CommitMatrixResult(destination, result, intermediate_type);
end;

func TMATMULMXShared(destination: TileIndex, accumulator: TileIndex,
                     left: TileInfo, left_scale: TileInfo,
                     right: TileInfo, right_scale: TileInfo,
                     bias: TileIndex, use_bias: boolean,
                     accumulate: boolean)
begin
    let intermediate_type = TileDataType_FP32;
    let product = MatrixMXProductResultFromTiles(destination, accumulator,
        left, left_scale, TRUE, right, right_scale, TRUE,
        accumulate, 0, FALSE);
    let result = if use_bias then
        MatrixBiasResult(product, bias, intermediate_type)
        else product;
    CommitMatrixResult(destination, result, intermediate_type);
end;

func TMATMULMXSharedWithOptionalScales(
    destination: TileIndex, accumulator: TileIndex,
    left: TileInfo, left_scale: TileInfo, left_scale_present: boolean,
    right: TileInfo, right_scale: TileInfo, right_scale_present: boolean,
    bias: TileIndex, use_bias: boolean, accumulate: boolean,
    c_scale: TileIndex, c_scale_present: boolean)
begin
    let intermediate_type = TileDataType_FP32;
    let product = MatrixMXProductResultWithOptionalScales(
        destination, accumulator,
        left, left_scale, left_scale_present,
        right, right_scale, right_scale_present,
        accumulate, c_scale, c_scale_present);
    let result = if use_bias then
        MatrixBiasResult(product, bias, intermediate_type)
        else product;
    CommitMatrixResult(destination, result, intermediate_type);
end;

func TMATMUL(destination: TileIndex, left: TileIndex, right: TileIndex)
begin
    let result = MatrixProductResult(destination, destination,
        left, right, FALSE);
    CommitMatrixResult(destination, result,
        TileOrdinaryMatrixAccumulatorType(
            _Tiles[[left]].data_type, _Tiles[[right]].data_type));
end;

func TMATMUL_BIAS(destination: TileIndex, left: TileIndex, right: TileIndex,
                  bias: TileIndex)
begin
    let intermediate_type = TileOrdinaryMatrixAccumulatorType(
        _Tiles[[left]].data_type, _Tiles[[right]].data_type);
    let product = MatrixProductResult(destination, destination,
        left, right, FALSE);
    let result = MatrixBiasResult(product, bias, intermediate_type);
    CommitMatrixResult(destination, result, intermediate_type);
end;

func TMATMUL_ACC(destination: TileIndex, accumulator: TileIndex,
                 left: TileIndex, right: TileIndex)
begin
    let result = MatrixProductResult(destination, accumulator,
        left, right, TRUE);
    CommitMatrixResult(destination, result,
        TileOrdinaryMatrixAccumulatorType(
            _Tiles[[left]].data_type, _Tiles[[right]].data_type));
end;

func TMATMUL_MX(destination: TileIndex, left: TileIndex,
                left_scale: TileIndex, right: TileIndex,
                right_scale: TileIndex)
begin
    let result = MatrixMXProductResult(destination, destination,
        left, left_scale, right, right_scale, FALSE);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;

func TMATMUL_MX_BIAS(destination: TileIndex, left: TileIndex,
                     left_scale: TileIndex, right: TileIndex,
                     right_scale: TileIndex,
                     bias: TileIndex)
begin
    let product = MatrixMXProductResult(destination, destination,
        left, left_scale, right, right_scale, FALSE);
    let result = MatrixBiasResult(product, bias, TileDataType_FP32);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;

func TMATMUL_MX_ACC(destination: TileIndex, accumulator: TileIndex,
                    left: TileIndex, left_scale: TileIndex,
                    right: TileIndex, right_scale: TileIndex)
begin
    let result = MatrixMXProductResult(destination, accumulator,
        left, left_scale, right, right_scale, TRUE);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;

func TGEMV(destination: TileIndex, left_vector: TileIndex,
           right_matrix: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let result = MatrixProductResult(destination, destination,
        left_vector, right_matrix, FALSE);
    CommitMatrixResult(destination, result,
        TileOrdinaryMatrixAccumulatorType(
            _Tiles[[left_vector]].data_type,
            _Tiles[[right_matrix]].data_type));
end;

func TGEMV_BIAS(destination: TileIndex, left_vector: TileIndex,
                right_matrix: TileIndex, bias: TileIndex)
begin
    let intermediate_type = TileOrdinaryMatrixAccumulatorType(
        _Tiles[[left_vector]].data_type,
        _Tiles[[right_matrix]].data_type);
    assert _Tiles[[left_vector]].valid_rows == 1;
    let product = MatrixProductResult(destination, destination,
        left_vector, right_matrix, FALSE);
    let result = MatrixBiasResult(product, bias, intermediate_type);
    CommitMatrixResult(destination, result, intermediate_type);
end;

func TGEMV_ACC(destination: TileIndex, accumulator: TileIndex,
               left_vector: TileIndex, right_matrix: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let result = MatrixProductResult(destination, accumulator,
        left_vector, right_matrix, TRUE);
    CommitMatrixResult(destination, result,
        TileOrdinaryMatrixAccumulatorType(
            _Tiles[[left_vector]].data_type,
            _Tiles[[right_matrix]].data_type));
end;

func TGEMV_MX(destination: TileIndex, left_vector: TileIndex,
              left_scale: TileIndex, right_matrix: TileIndex,
              right_scale: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let result = MatrixMXProductResult(destination, destination,
        left_vector, left_scale, right_matrix, right_scale, FALSE);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;

func TGEMV_MX_BIAS(destination: TileIndex, left_vector: TileIndex,
                   left_scale: TileIndex, right_matrix: TileIndex,
                   right_scale: TileIndex,
                   bias: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let product = MatrixMXProductResult(destination, destination,
        left_vector, left_scale, right_matrix, right_scale, FALSE);
    let result = MatrixBiasResult(product, bias, TileDataType_FP32);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;

func TGEMV_MX_ACC(destination: TileIndex, accumulator: TileIndex,
                  left_vector: TileIndex, left_scale: TileIndex,
                  right_matrix: TileIndex, right_scale: TileIndex)
begin
    assert _Tiles[[left_vector]].valid_rows == 1;
    let result = MatrixMXProductResult(destination, accumulator,
        left_vector, left_scale, right_matrix, right_scale, TRUE);
    CommitMatrixResult(destination, result, TileDataType_FP32);
end;
