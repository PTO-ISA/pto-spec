// PTO-REQ-CUBE-001: profile-defined matrix arithmetic with portable integer defaults.
// CUBE arithmetic uses the implicit accumulator.  Normal, BIAS, and MX forms
// replace it; .ACC forms read and replace it; ACCCVT is the only operation that
// publishes the accumulator to a Tile.

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

impdef func TileProfileMatrixScale(value: Word, row_scale: Word, column_scale: Word,
                                   destination_type: TileDataType,
                                   row_type: TileDataType,
                                   column_type: TileDataType) => Word
begin
    return MultiplyWord(MultiplyWord(value, row_scale), column_scale);
end;

// Compute into a local TileInfo snapshot.  No architectural accumulator or
// Tile state changes until the public handler commits the completed result.
func MatrixProductResult(left: TileIndex, right: TileIndex,
                         accumulate: boolean) => TileInfo
begin
    let left_tile = _Tiles[[left]];
    let right_tile = _Tiles[[right]];
    let selected_data_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBlockTileOperationDataTypeCode()));
    assert left_tile.allocated && right_tile.allocated;
    assert left_tile.valid_columns == right_tile.valid_rows;
    if accumulate then
        assert _Accumulator.live;
        assert _Accumulator.info.valid_rows == left_tile.valid_rows;
        assert _Accumulator.info.valid_columns == right_tile.valid_columns;
        assert _Accumulator.info.data_type == selected_data_type;
    end;

    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    var result: TileInfo = if accumulate then _Accumulator.info else left_tile;
    if !accumulate then
        result.capacity_bytes = PTO_TILE_CAPACITY_BYTES;
        result.rows = left_tile.valid_rows;
        result.columns = right_tile.valid_columns;
        result.valid_rows = left_tile.valid_rows;
        result.valid_columns = right_tile.valid_columns;
        result.data_type = selected_data_type;
    end;
    var result_payload: TilePayload = result.payload;
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to right_tile.valid_columns - 1 looplimit 65536 do
            let result_element = TileLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            var sum: Word = if accumulate then result_payload[[result_element]]
                            else Zeros{PTO_XLEN};
            for inner = 0 to left_tile.valid_columns - 1 looplimit 65536 do
                let left_element = TileLinearIndex(left_tile,
                    row as integer {0..65535}, inner as integer {0..65535});
                let right_element = TileLinearIndex(right_tile,
                    inner as integer {0..65535}, column as integer {0..65535});
                sum = TileProfileMatrixAccumulate(sum,
                    left_payload[[left_element]], right_payload[[right_element]],
                    result.data_type, left_tile.data_type, right_tile.data_type);
            end;
            result_payload[[result_element]] = sum;
        end;
    end;
    result.allocated = TRUE;
    result.contents_defined = TRUE;
    result.payload = result_payload;
    return result;
end;

func MatrixBiasResult(input: TileInfo, bias: TileIndex) => TileInfo
begin
    let bias_tile = _Tiles[[bias]];
    assert bias_tile.allocated && bias_tile.contents_defined;
    assert bias_tile.valid_rows == 1 || bias_tile.valid_rows == input.valid_rows;
    assert bias_tile.valid_columns == 1 || bias_tile.valid_columns == input.valid_columns;
    let bias_payload = bias_tile.payload;
    var result: TileInfo = input;
    var result_payload: TilePayload = input.payload;
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

func MatrixScaleResult(input: TileInfo, row_scale: TileIndex,
                       column_scale: TileIndex) => TileInfo
begin
    let row_scale_tile = _Tiles[[row_scale]];
    let column_scale_tile = _Tiles[[column_scale]];
    assert row_scale_tile.allocated && row_scale_tile.contents_defined;
    assert column_scale_tile.allocated && column_scale_tile.contents_defined;
    assert row_scale_tile.valid_rows == input.valid_rows;
    assert row_scale_tile.valid_columns == 1;
    assert column_scale_tile.valid_rows == 1;
    assert column_scale_tile.valid_columns == input.valid_columns;
    let row_scale_payload = row_scale_tile.payload;
    let column_scale_payload = column_scale_tile.payload;
    var result: TileInfo = input;
    var result_payload: TilePayload = input.payload;
    for row = 0 to input.valid_rows - 1 looplimit 65536 do
        for column = 0 to input.valid_columns - 1 looplimit 65536 do
            let result_element = TileLinearIndex(input,
                row as integer {0..65535}, column as integer {0..65535});
            let row_element = TileLinearIndex(row_scale_tile,
                row as integer {0..65535}, 0);
            let column_element = TileLinearIndex(column_scale_tile,
                0, column as integer {0..65535});
            result_payload[[result_element]] = TileProfileMatrixScale(
                input.payload[[result_element]], row_scale_payload[[row_element]],
                column_scale_payload[[column_element]], input.data_type,
                row_scale_tile.data_type, column_scale_tile.data_type);
        end;
    end;
    result.payload = result_payload;
    return result;
end;

func CommitAccumulator(result: TileInfo)
begin
    _Accumulator.info = result;
    _Accumulator.live = TRUE;
end;

func TMATMUL(left: TileIndex, right: TileIndex, accumulate: boolean)
begin
    let result = MatrixProductResult(left, right, accumulate);
    CommitAccumulator(result);
end;

func TMATMUL_BIAS(left: TileIndex, right: TileIndex, bias: TileIndex)
begin
    let product = MatrixProductResult(left, right, FALSE);
    let result = MatrixBiasResult(product, bias);
    CommitAccumulator(result);
end;

func TMATMUL_ACC(left: TileIndex, right: TileIndex)
begin
    let result = MatrixProductResult(left, right, TRUE);
    CommitAccumulator(result);
end;

func TMATMUL_MX(left: TileIndex, right: TileIndex, row_scale: TileIndex,
                column_scale: TileIndex)
begin
    let product = MatrixProductResult(left, right, FALSE);
    let result = MatrixScaleResult(product, row_scale, column_scale);
    CommitAccumulator(result);
end;

func TMATMUL_MX_BIAS(left: TileIndex, right: TileIndex, row_scale: TileIndex,
                     column_scale: TileIndex, bias: TileIndex)
begin
    let product = MatrixProductResult(left, right, FALSE);
    let scaled = MatrixScaleResult(product, row_scale, column_scale);
    let result = MatrixBiasResult(scaled, bias);
    CommitAccumulator(result);
end;

func TMATMUL_MX_ACC(left: TileIndex, right: TileIndex, row_scale: TileIndex,
                    column_scale: TileIndex)
begin
    let product = MatrixProductResult(left, right, TRUE);
    let result = MatrixScaleResult(product, row_scale, column_scale);
    CommitAccumulator(result);
end;

func ACCCVT(destination: TileIndex)
begin
    assert _Accumulator.live;
    let destination_tile = _Tiles[[destination]];
    let accumulator_info = _Accumulator.info;
    assert destination_tile.allocated;
    assert destination_tile.valid_rows == accumulator_info.valid_rows;
    assert destination_tile.valid_columns == accumulator_info.valid_columns;

    var destination_payload: TilePayload = destination_tile.payload;
    for row = 0 to accumulator_info.valid_rows - 1 looplimit 65536 do
        for column = 0 to accumulator_info.valid_columns - 1 looplimit 65536 do
            let source_element = TileLinearIndex(accumulator_info,
                row as integer {0..65535}, column as integer {0..65535});
            let destination_element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            destination_payload[[destination_element]] = TileConvertValue(
                accumulator_info.payload[[source_element]], accumulator_info.data_type,
                destination_tile.data_type);
        end;
    end;

    // Publish first and release second.  No potentially faulting work follows
    // the Tile publication, so a failed/retried ACCCVT retains the accumulator.
    _Tiles[[destination]].payload = destination_payload;
    _Tiles[[destination]].contents_defined = TRUE;
    _Accumulator.live = FALSE;
end;

func TGEMV(matrix: TileIndex, vector: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    let result = MatrixProductResult(matrix, vector, FALSE);
    CommitAccumulator(result);
end;

func TGEMV_BIAS(matrix: TileIndex, vector: TileIndex, bias: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    let product = MatrixProductResult(matrix, vector, FALSE);
    let result = MatrixBiasResult(product, bias);
    CommitAccumulator(result);
end;

func TGEMV_ACC(matrix: TileIndex, vector: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    let result = MatrixProductResult(matrix, vector, TRUE);
    CommitAccumulator(result);
end;

func TGEMV_MX(matrix: TileIndex, vector: TileIndex, row_scale: TileIndex,
              column_scale: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    let product = MatrixProductResult(matrix, vector, FALSE);
    let result = MatrixScaleResult(product, row_scale, column_scale);
    CommitAccumulator(result);
end;

func TGEMV_MX_BIAS(matrix: TileIndex, vector: TileIndex, row_scale: TileIndex,
                   column_scale: TileIndex, bias: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    let product = MatrixProductResult(matrix, vector, FALSE);
    let scaled = MatrixScaleResult(product, row_scale, column_scale);
    let result = MatrixBiasResult(scaled, bias);
    CommitAccumulator(result);
end;

func TGEMV_MX_ACC(matrix: TileIndex, vector: TileIndex, row_scale: TileIndex,
                  column_scale: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    let product = MatrixProductResult(matrix, vector, TRUE);
    let result = MatrixScaleResult(product, row_scale, column_scale);
    CommitAccumulator(result);
end;
