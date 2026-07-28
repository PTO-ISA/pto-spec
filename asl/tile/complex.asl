// PTO-REQ-TEPL-COMPLEX-001: partial, ordering, and histogram operations.

pure func TilePartialValue(op: TilePartialOperation, left: Word, right: Word) => Word
begin
    case op of
        when TilePartial_ADD => return left + right;
        when TilePartial_MUL => return MultiplyWord(left, right);
        when TilePartial_MAX => if SInt(left) >= SInt(right) then return left; else return right; end;
        when TilePartial_MIN => if SInt(left) <= SInt(right) then return left; else return right; end;
        when TilePartial_ARGMAX =>
            if SInt(left) >= SInt(right) then return Zeros{PTO_XLEN};
            else return Zeros{PTO_XLEN} + 1; end;
        when TilePartial_ARGMIN =>
            if SInt(left) <= SInt(right) then return Zeros{PTO_XLEN};
            else return Zeros{PTO_XLEN} + 1; end;
    end;
end;

impdef func TileProfilePartialValue(op: TilePartialOperation,
                                     data_type: TileDataType,
                                     left: Word, right: Word) => Word
begin
    return TilePartialValue(op, left, right);
end;

impdef func TileProfileOrderLeft(left: Word, right: Word,
                                 descending: boolean,
                                 data_type: TileDataType) => boolean
begin
    if descending then return SInt(left) >= SInt(right);
    else return SInt(left) <= SInt(right);
    end;
end;

func ExecuteTilePartial(op: TilePartialOperation, destination: TileIndex,
                        source_left: TileIndex, source_right: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    assert destination_tile.data_type == left_tile.data_type;
    assert destination_tile.data_type == right_tile.data_type;
    assert left_tile.valid_rows <= destination_tile.valid_rows;
    assert left_tile.valid_columns <= destination_tile.valid_columns;
    assert right_tile.valid_rows <= destination_tile.valid_rows;
    assert right_tile.valid_columns <= destination_tile.valid_columns;
    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let left_valid = row < left_tile.valid_rows && column < left_tile.valid_columns;
            let right_valid = row < right_tile.valid_rows && column < right_tile.valid_columns;
            assert left_valid || right_valid;
            var value: Word;
            if left_valid && right_valid then
                let left_element = TileLinearIndex(left_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                let right_element = TileLinearIndex(right_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                value = TileProfilePartialValue(op, destination_tile.data_type,
                    left_payload[[left_element]], right_payload[[right_element]]);
            elsif left_valid then
                let left_element = TileLinearIndex(left_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                value = left_payload[[left_element]];
            else
                let right_element = TileLinearIndex(right_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                value = right_payload[[right_element]];
            end;
            WriteTileElement(destination, row as integer {0..65535},
                column as integer {0..65535}, value);
        end;
    end;
end;

func ExecuteTilePartialArg(maximum: boolean, destination: TileIndex,
                           destination_indices: TileIndex,
                           source_left: TileIndex, source_right: TileIndex,
                           left_indices: TileIndex, right_indices: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    let left_index_payload = _Tiles[[left_indices]].payload;
    let right_index_payload = _Tiles[[right_indices]].payload;
    assert _Tiles[[destination_indices]].valid_rows == destination_tile.valid_rows;
    assert _Tiles[[destination_indices]].valid_columns == destination_tile.valid_columns;
    assert destination_tile.data_type == left_tile.data_type;
    assert destination_tile.data_type == right_tile.data_type;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let left_valid = row < left_tile.valid_rows && column < left_tile.valid_columns;
            let right_valid = row < right_tile.valid_rows && column < right_tile.valid_columns;
            assert left_valid || right_valid;
            var choose_left = left_valid;
            var left_element: ModelTileElementIndex = 0;
            var right_element: ModelTileElementIndex = 0;
            if left_valid then
                left_element = TileLinearIndex(left_tile,
                    row as integer {0..65535}, column as integer {0..65535});
            end;
            if right_valid then
                right_element = TileLinearIndex(right_tile,
                    row as integer {0..65535}, column as integer {0..65535});
            end;
            if left_valid && right_valid then
                choose_left = TileProfileOrderLeft(
                    left_payload[[left_element]], right_payload[[right_element]],
                    maximum, destination_tile.data_type);
            end;
            let output_value = if choose_left then left_payload[[left_element]]
                               else right_payload[[right_element]];
            let output_index = if choose_left then left_index_payload[[left_element]]
                               else right_index_payload[[right_element]];
            WriteTileElement(destination, row as integer {0..65535},
                column as integer {0..65535}, output_value);
            WriteTileElement(destination_indices, row as integer {0..65535},
                column as integer {0..65535}, output_index);
        end;
    end;
end;

func TSORT(destination: TileIndex, source: TileIndex, descending: boolean)
begin
    let source_tile = _Tiles[[source]];
    let destination_tile = _Tiles[[destination]];
    let extent: integer = source_tile.valid_rows * source_tile.valid_columns;
    assert destination_tile.valid_rows * destination_tile.valid_columns == extent;
    assert destination_tile.data_type == source_tile.data_type;
    var values: TilePayload = source_tile.payload;
    for sort_pass = 0 to extent - 1 looplimit 4096 do
        for element = 0 to extent - 2 looplimit 4096 do
            let left = values[[element as ModelTileElementIndex]];
            let right = values[[(element + 1) as ModelTileElementIndex]];
            let swap = !TileProfileOrderLeft(
                left, right, descending, source_tile.data_type);
            if swap then
                values[[element as ModelTileElementIndex]] = right;
                values[[(element + 1) as ModelTileElementIndex]] = left;
            end;
        end;
    end;
    for element = 0 to extent - 1 looplimit 4096 do
        _Tiles[[destination]].payload[[element as ModelTileElementIndex]] =
            values[[element as ModelTileElementIndex]];
    end;
end;

func TMRGSORT(destination: TileIndex, source_left: TileIndex, source_right: TileIndex,
              descending: boolean)
begin
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    let destination_tile = _Tiles[[destination]];
    let left_extent: integer = left_tile.valid_rows * left_tile.valid_columns;
    let right_extent: integer = right_tile.valid_rows * right_tile.valid_columns;
    assert destination_tile.valid_rows * destination_tile.valid_columns == left_extent + right_extent;
    assert left_tile.data_type == right_tile.data_type;
    assert destination_tile.data_type == left_tile.data_type;
    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    var left_index: integer = 0;
    var right_index: integer = 0;
    for output = 0 to (left_extent + right_extent) - 1 looplimit 4096 do
        var take_left = right_index >= right_extent;
        if left_index < left_extent && right_index < right_extent then
            let left_value = left_payload[[left_index as ModelTileElementIndex]];
            let right_value = right_payload[[right_index as ModelTileElementIndex]];
            take_left = TileProfileOrderLeft(
                left_value, right_value, descending, left_tile.data_type);
        end;
        if take_left then
            _Tiles[[destination]].payload[[output as ModelTileElementIndex]] =
                left_payload[[left_index as ModelTileElementIndex]];
            left_index = left_index + 1;
        else
            _Tiles[[destination]].payload[[output as ModelTileElementIndex]] =
                right_payload[[right_index as ModelTileElementIndex]];
            right_index = right_index + 1;
        end;
    end;
end;

pure func ExtractWordByte(value: Word, byte_index: integer {0..3}) => Byte
begin
    return value[(byte_index * 8) +: 8];
end;

func THISTOGRAM(destination: TileIndex, source: TileIndex, indices: TileIndex,
                selected_byte: integer {0..3})
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    assert destination_tile.valid_rows == source_tile.valid_rows;
    assert destination_tile.valid_columns >= 256;
    assert source_tile.data_type == TileDataType_U16 || source_tile.data_type == TileDataType_U32;
    if source_tile.data_type == TileDataType_U16 then assert selected_byte <= 1; end;
    let source_payload = source_tile.payload;
    let index_payload = index_tile.payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        var counts: array [[256]] of Word;
        for bin = 0 to 255 do counts[[bin]] = Zeros{PTO_XLEN}; end;
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let value = source_payload[[source_element]];
            var selected = TRUE;
            if source_tile.data_type == TileDataType_U16 && selected_byte == 0 then
                let filter_element = TileLinearIndex(index_tile,
                    row as integer {0..65535}, 0);
                selected = ExtractWordByte(value, 1) == index_payload[[filter_element]][7:0];
            elsif source_tile.data_type == TileDataType_U32 then
                if selected_byte <= 2 then
                    selected = ExtractWordByte(value, 3) ==
                        index_payload[[TileLinearIndex(index_tile, 0, 0)]][7:0];
                end;
                if selected && selected_byte <= 1 then
                    selected = ExtractWordByte(value, 2) ==
                        index_payload[[TileLinearIndex(index_tile, 1, 0)]][7:0];
                end;
                if selected && selected_byte == 0 then
                    selected = ExtractWordByte(value, 1) ==
                        index_payload[[TileLinearIndex(index_tile, 2, 0)]][7:0];
                end;
            end;
            if selected then
                let bin = UInt(ExtractWordByte(value, selected_byte));
                counts[[bin]] = counts[[bin]] + 1;
            end;
        end;
        var cumulative: Word = Zeros{PTO_XLEN};
        for bin = 0 to 255 do
            cumulative = cumulative + counts[[bin]];
            WriteTileElement(destination, row as integer {0..65535},
                bin as integer {0..65535}, cumulative);
        end;
    end;
end;
