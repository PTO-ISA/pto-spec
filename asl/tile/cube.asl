// PTO-REQ-CUBE-001: profile-defined matrix arithmetic with portable integer defaults.

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

func TMATMUL(destination: TileIndex, left: TileIndex, right: TileIndex,
             accumulate: boolean)
begin
    let left_tile = _Tiles[[left]];
    let right_tile = _Tiles[[right]];
    assert _Tiles[[destination]].allocated;
    assert left_tile.allocated && left_tile.contents_defined;
    assert right_tile.allocated && right_tile.contents_defined;
    assert !accumulate || _Tiles[[destination]].contents_defined;
    assert left_tile.valid_columns == right_tile.valid_rows;
    assert _Tiles[[destination]].valid_rows == left_tile.valid_rows;
    assert _Tiles[[destination]].valid_columns == right_tile.valid_columns;
    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    let destination_payload = _Tiles[[destination]].payload;
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to right_tile.valid_columns - 1 looplimit 65536 do
            var sum: Word = Zeros{PTO_XLEN};
            if accumulate then
                let destination_element = TileLinearIndex(_Tiles[[destination]],
                    row as integer {0..65535}, column as integer {0..65535});
                sum = destination_payload[[destination_element]];
            end;
            for inner = 0 to left_tile.valid_columns - 1 looplimit 65536 do
                let left_element = TileLinearIndex(left_tile,
                    row as integer {0..65535}, inner as integer {0..65535});
                let right_element = TileLinearIndex(right_tile,
                    inner as integer {0..65535}, column as integer {0..65535});
                sum = TileProfileMatrixAccumulate(sum,
                    left_payload[[left_element]], right_payload[[right_element]],
                    _Tiles[[destination]].data_type, left_tile.data_type,
                    right_tile.data_type);
            end;
            WriteTileElement(destination, row as integer {0..65535},
                column as integer {0..65535}, sum);
        end;
    end;
end;

func AddMatrixBiasSnapshot(destination: TileIndex, bias_tile: TileInfo,
                           bias_payload: TilePayload)
begin
    let destination_tile = _Tiles[[destination]];
    assert destination_tile.allocated && destination_tile.contents_defined;
    assert bias_tile.allocated && bias_tile.contents_defined;
    assert bias_tile.valid_rows == 1 || bias_tile.valid_rows == destination_tile.valid_rows;
    assert bias_tile.valid_columns == 1 || bias_tile.valid_columns == destination_tile.valid_columns;
    let destination_payload = destination_tile.payload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let bias_row = if bias_tile.valid_rows == 1 then 0 else row;
            let bias_column = if bias_tile.valid_columns == 1 then 0 else column;
            let bias_element = TileLinearIndex(bias_tile,
                bias_row as integer {0..65535}, bias_column as integer {0..65535});
            _Tiles[[destination]].payload[[destination_element]] = TileProfileMatrixBias(
                destination_payload[[destination_element]], bias_payload[[bias_element]],
                destination_tile.data_type, bias_tile.data_type);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func AddMatrixBias(destination: TileIndex, bias: TileIndex)
begin
    let bias_tile = _Tiles[[bias]];
    AddMatrixBiasSnapshot(destination, bias_tile, bias_tile.payload);
end;

func ScaleMatrixResultSnapshot(destination: TileIndex,
                               row_scale_tile: TileInfo,
                               column_scale_tile: TileInfo,
                               row_scale_payload: TilePayload,
                               column_scale_payload: TilePayload)
begin
    let destination_tile = _Tiles[[destination]];
    assert destination_tile.allocated && destination_tile.contents_defined;
    assert row_scale_tile.allocated && row_scale_tile.contents_defined;
    assert column_scale_tile.allocated && column_scale_tile.contents_defined;
    assert row_scale_tile.valid_rows == destination_tile.valid_rows;
    assert row_scale_tile.valid_columns == 1;
    assert column_scale_tile.valid_rows == 1;
    assert column_scale_tile.valid_columns == destination_tile.valid_columns;
    let destination_payload = destination_tile.payload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let row_element = TileLinearIndex(row_scale_tile,
                row as integer {0..65535}, 0);
            let column_element = TileLinearIndex(column_scale_tile,
                0, column as integer {0..65535});
            _Tiles[[destination]].payload[[destination_element]] = TileProfileMatrixScale(
                destination_payload[[destination_element]], row_scale_payload[[row_element]],
                column_scale_payload[[column_element]], destination_tile.data_type,
                row_scale_tile.data_type, column_scale_tile.data_type);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func ScaleMatrixResult(destination: TileIndex, row_scale: TileIndex,
                       column_scale: TileIndex)
begin
    let row_scale_tile = _Tiles[[row_scale]];
    let column_scale_tile = _Tiles[[column_scale]];
    ScaleMatrixResultSnapshot(destination, row_scale_tile, column_scale_tile,
        row_scale_tile.payload, column_scale_tile.payload);
end;

func TMATMUL_BIAS(destination: TileIndex, left: TileIndex, right: TileIndex, bias: TileIndex)
begin
    let bias_tile = _Tiles[[bias]];
    let bias_payload = bias_tile.payload;
    TMATMUL(destination, left, right, FALSE);
    AddMatrixBiasSnapshot(destination, bias_tile, bias_payload);
end;

func TMATMUL_ACC(destination: TileIndex, left: TileIndex, right: TileIndex)
begin
    TMATMUL(destination, left, right, TRUE);
end;

func TMATMUL_MX(destination: TileIndex, left: TileIndex, right: TileIndex,
                row_scale: TileIndex, column_scale: TileIndex)
begin
    let row_scale_tile = _Tiles[[row_scale]];
    let column_scale_tile = _Tiles[[column_scale]];
    let row_scale_payload = row_scale_tile.payload;
    let column_scale_payload = column_scale_tile.payload;
    TMATMUL(destination, left, right, FALSE);
    ScaleMatrixResultSnapshot(destination, row_scale_tile, column_scale_tile,
        row_scale_payload, column_scale_payload);
end;

func TMATMUL_MX_BIAS(destination: TileIndex, left: TileIndex, right: TileIndex,
                     row_scale: TileIndex, column_scale: TileIndex,
                     bias: TileIndex)
begin
    let row_scale_tile = _Tiles[[row_scale]];
    let column_scale_tile = _Tiles[[column_scale]];
    let bias_tile = _Tiles[[bias]];
    let row_scale_payload = row_scale_tile.payload;
    let column_scale_payload = column_scale_tile.payload;
    let bias_payload = bias_tile.payload;
    TMATMUL(destination, left, right, FALSE);
    ScaleMatrixResultSnapshot(destination, row_scale_tile, column_scale_tile,
        row_scale_payload, column_scale_payload);
    AddMatrixBiasSnapshot(destination, bias_tile, bias_payload);
end;

func TMATMUL_MX_ACC(destination: TileIndex, left: TileIndex, right: TileIndex,
                    row_scale: TileIndex, column_scale: TileIndex)
begin
    let row_scale_tile = _Tiles[[row_scale]];
    let column_scale_tile = _Tiles[[column_scale]];
    let row_scale_payload = row_scale_tile.payload;
    let column_scale_payload = column_scale_tile.payload;
    TMATMUL(destination, left, right, TRUE);
    ScaleMatrixResultSnapshot(destination, row_scale_tile, column_scale_tile,
        row_scale_payload, column_scale_payload);
end;

func ACCCVT(destination: TileIndex, source: TileIndex)
begin
    assert _Tiles[[destination]].allocated;
    assert _Tiles[[source]].allocated && _Tiles[[source]].contents_defined;
    TCVT(destination, source);
end;

func TGEMV(destination: TileIndex, matrix: TileIndex, vector: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    TMATMUL(destination, matrix, vector, FALSE);
end;

func TGEMV_BIAS(destination: TileIndex, matrix: TileIndex, vector: TileIndex, bias: TileIndex)
begin
    let bias_tile = _Tiles[[bias]];
    let bias_payload = bias_tile.payload;
    TGEMV(destination, matrix, vector);
    AddMatrixBiasSnapshot(destination, bias_tile, bias_payload);
end;

func TGEMV_ACC(destination: TileIndex, matrix: TileIndex, vector: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    TMATMUL(destination, matrix, vector, TRUE);
end;

func TGEMV_MX(destination: TileIndex, matrix: TileIndex, vector: TileIndex,
              row_scale: TileIndex, column_scale: TileIndex)
begin
    let row_scale_tile = _Tiles[[row_scale]];
    let column_scale_tile = _Tiles[[column_scale]];
    let row_scale_payload = row_scale_tile.payload;
    let column_scale_payload = column_scale_tile.payload;
    TGEMV(destination, matrix, vector);
    ScaleMatrixResultSnapshot(destination, row_scale_tile, column_scale_tile,
        row_scale_payload, column_scale_payload);
end;

func TGEMV_MX_BIAS(destination: TileIndex, matrix: TileIndex, vector: TileIndex,
                   row_scale: TileIndex, column_scale: TileIndex, bias: TileIndex)
begin
    let row_scale_tile = _Tiles[[row_scale]];
    let column_scale_tile = _Tiles[[column_scale]];
    let bias_tile = _Tiles[[bias]];
    let row_scale_payload = row_scale_tile.payload;
    let column_scale_payload = column_scale_tile.payload;
    let bias_payload = bias_tile.payload;
    TGEMV(destination, matrix, vector);
    ScaleMatrixResultSnapshot(destination, row_scale_tile, column_scale_tile,
        row_scale_payload, column_scale_payload);
    AddMatrixBiasSnapshot(destination, bias_tile, bias_payload);
end;

func TGEMV_MX_ACC(destination: TileIndex, matrix: TileIndex, vector: TileIndex,
                  row_scale: TileIndex, column_scale: TileIndex)
begin
    let row_scale_tile = _Tiles[[row_scale]];
    let column_scale_tile = _Tiles[[column_scale]];
    let row_scale_payload = row_scale_tile.payload;
    let column_scale_payload = column_scale_tile.payload;
    TGEMV_ACC(destination, matrix, vector);
    ScaleMatrixResultSnapshot(destination, row_scale_tile, column_scale_tile,
        row_scale_payload, column_scale_payload);
end;
