// PTO-REQ-CUBE-001: direct integer matrix multiply and accumulation.

func TMATMUL(destination: TileIndex, left: TileIndex, right: TileIndex,
             accumulate: boolean)
begin
    let left_tile = _Tiles[[left]];
    let right_tile = _Tiles[[right]];
    assert left_tile.allocated && right_tile.allocated;
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
                let product = MultiplyWord(left_payload[[left_element]],
                    right_payload[[right_element]]);
                sum = sum + product;
            end;
            WriteTileElement(destination, row as integer {0..65535},
                column as integer {0..65535}, sum);
        end;
    end;
end;

func AddMatrixBias(destination: TileIndex, bias: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let bias_tile = _Tiles[[bias]];
    assert bias_tile.valid_rows == 1 || bias_tile.valid_rows == destination_tile.valid_rows;
    assert bias_tile.valid_columns == 1 || bias_tile.valid_columns == destination_tile.valid_columns;
    let destination_payload = destination_tile.payload;
    let bias_payload = bias_tile.payload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let bias_row = if bias_tile.valid_rows == 1 then 0 else row;
            let bias_column = if bias_tile.valid_columns == 1 then 0 else column;
            let bias_element = TileLinearIndex(bias_tile,
                bias_row as integer {0..65535}, bias_column as integer {0..65535});
            _Tiles[[destination]].payload[[destination_element]] =
                destination_payload[[destination_element]] + bias_payload[[bias_element]];
        end;
    end;
end;

func ScaleMatrixResult(destination: TileIndex, row_scale: TileIndex, column_scale: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let row_scale_tile = _Tiles[[row_scale]];
    let column_scale_tile = _Tiles[[column_scale]];
    assert row_scale_tile.valid_rows == destination_tile.valid_rows;
    assert row_scale_tile.valid_columns == 1;
    assert column_scale_tile.valid_rows == 1;
    assert column_scale_tile.valid_columns == destination_tile.valid_columns;
    let destination_payload = destination_tile.payload;
    let row_scale_payload = row_scale_tile.payload;
    let column_scale_payload = column_scale_tile.payload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let row_element = TileLinearIndex(row_scale_tile,
                row as integer {0..65535}, 0);
            let column_element = TileLinearIndex(column_scale_tile,
                0, column as integer {0..65535});
            _Tiles[[destination]].payload[[destination_element]] = MultiplyWord(
                MultiplyWord(destination_payload[[destination_element]], row_scale_payload[[row_element]]),
                column_scale_payload[[column_element]]);
        end;
    end;
end;

func TMATMUL_BIAS(destination: TileIndex, left: TileIndex, right: TileIndex, bias: TileIndex)
begin
    TMATMUL(destination, left, right, FALSE);
    AddMatrixBias(destination, bias);
end;

func TMATMUL_ACC(destination: TileIndex, left: TileIndex, right: TileIndex)
begin
    TMATMUL(destination, left, right, TRUE);
end;

func TMATMUL_MX(destination: TileIndex, left: TileIndex, right: TileIndex,
                row_scale: TileIndex, column_scale: TileIndex)
begin
    TMATMUL(destination, left, right, FALSE);
    ScaleMatrixResult(destination, row_scale, column_scale);
end;

func TGEMV(destination: TileIndex, matrix: TileIndex, vector: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    TMATMUL(destination, matrix, vector, FALSE);
end;

func TGEMV_BIAS(destination: TileIndex, matrix: TileIndex, vector: TileIndex, bias: TileIndex)
begin
    TGEMV(destination, matrix, vector);
    AddMatrixBias(destination, bias);
end;

func TGEMV_ACC(destination: TileIndex, matrix: TileIndex, vector: TileIndex)
begin
    assert _Tiles[[vector]].valid_columns == 1;
    TMATMUL(destination, matrix, vector, TRUE);
end;

func TGEMV_MX(destination: TileIndex, matrix: TileIndex, vector: TileIndex,
              row_scale: TileIndex, column_scale: TileIndex)
begin
    TGEMV(destination, matrix, vector);
    ScaleMatrixResult(destination, row_scale, column_scale);
end;
