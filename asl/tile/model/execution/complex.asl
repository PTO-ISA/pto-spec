// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-COMPLEX","surface":"tile","classification":["model","execution","complex"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT"]}
// PTO-REQ-TEPL-COMPLEX-001: partial, ordering, and histogram operations.

pure func TilePartialBinaryOperation(
    operation: TilePartialOperation) => TileBinaryOperation
begin
    case operation of
        when TilePartial_ADD => return TileBinary_ADD;
        when TilePartial_MUL => return TileBinary_MUL;
        when TilePartial_MAX => return TileBinary_MAX;
        when TilePartial_MIN => return TileBinary_MIN;
        otherwise => unreachable;
    end;
end;

func TileProfilePartialValueWithFlags(
    operation: TilePartialOperation,
    data_type: TileDataType,
    left: Word,
    right: Word) => (Word, bits(5))
begin
    return TileProfileBinaryWithFlags(
        TilePartialBinaryOperation(operation),
        data_type,
        left,
        right);
end;

impdef func TileProfileOrderLeft(
    left: Word,
    right: Word,
    descending: boolean,
    data_type: TileDataType) => boolean
begin
    if descending then
        return SInt(left) >= SInt(right);
    end;
    return SInt(left) <= SInt(right);
end;

impdef func TileProfileValueIsNaN(
    value: Word,
    data_type: TileDataType) => boolean
begin
    return FALSE;
end;

func ExecuteTilePartial(op: TilePartialOperation, destination: TileIndex,
                        source_left: TileIndex, source_right: TileIndex)
begin
    assert TileOperandsLegal_ExecuteTilePartial(
        op,
        destination,
        source_left,
        source_right);
    var result = _Tiles[[destination]];
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    var flags = Zeros{5};
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let left_valid =
                row < left_tile.valid_rows &&
                column < left_tile.valid_columns;
            let right_valid =
                row < right_tile.valid_rows &&
                column < right_tile.valid_columns;
            var value: Word;
            if left_valid && right_valid then
                let left_element = TileLogicalLinearIndex(left_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                let right_element = TileLogicalLinearIndex(right_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                let (combined, element_flags) =
                    TileProfilePartialValueWithFlags(
                        op,
                        result.data_type,
                        TileReadLogicalElement(left_tile, left_element),
                        TileReadLogicalElement(right_tile, right_element));
                value = combined;
                flags = flags OR element_flags;
            elsif left_valid then
                let left_element = TileLogicalLinearIndex(left_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                value = TileReadLogicalElement(left_tile, left_element);
            else
                let right_element = TileLogicalLinearIndex(right_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                value = TileReadLogicalElement(right_tile, right_element);
            end;
            let destination_element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(
                result, destination_element, value);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    result.location = TileLocation_Any;
    RecordNumericStatusFlags(flags);
    _Tiles[[destination]] = result;
end;

func ExecuteTilePartialArg(maximum: boolean, destination: TileIndex,
                           destination_indices: TileIndex,
                           source_left: TileIndex, source_right: TileIndex,
                           left_indices: TileIndex, right_indices: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    let left_index_tile = _Tiles[[left_indices]];
    let right_index_tile = _Tiles[[right_indices]];
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
            var left_element: PackedTileElementIndex = 0;
            var right_element: PackedTileElementIndex = 0;
            if left_valid then
                left_element = TileLogicalLinearIndex(left_tile,
                    row as integer {0..65535}, column as integer {0..65535});
            end;
            if right_valid then
                right_element = TileLogicalLinearIndex(right_tile,
                    row as integer {0..65535}, column as integer {0..65535});
            end;
            if left_valid && right_valid then
                choose_left = TileProfileOrderLeft(
                    TileReadLogicalElement(left_tile, left_element),
                    TileReadLogicalElement(right_tile, right_element),
                    maximum,
                    destination_tile.data_type);
            end;
            let output_value = if choose_left then
                TileReadLogicalElement(left_tile, left_element)
                else TileReadLogicalElement(right_tile, right_element);
            let output_index = if choose_left then
                TileReadLogicalElement(left_index_tile, left_element)
                else TileReadLogicalElement(right_index_tile, right_element);
            WriteTileElement(destination, row as integer {0..65535},
                column as integer {0..65535}, output_value);
            WriteTileElement(destination_indices, row as integer {0..65535},
                column as integer {0..65535}, output_index);
        end;
    end;
end;

pure func ExtractWordByte(value: Word, byte_index: integer {0..3}) => Byte
begin
    return value[(byte_index * 8) +: 8];
end;

func THISTOGRAM(destination: TileIndex, source: TileIndex, filter: TileIndex,
                selected_byte: integer {0..3})
begin
    var result = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let filter_tile = _Tiles[[filter]];
    assert TileOperandsLegal_THISTOGRAM(
        destination,
        source,
        filter,
        selected_byte);
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        var counts: array [[256]] of Word;
        for bin = 0 to 255 do
            counts[[bin]] = Zeros{PTO_XLEN};
        end;
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(
                source_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let value = TileReadLogicalElement(source_tile, source_element);
            var selected = TRUE;
            if source_tile.data_type == TileDataType_U16 &&
               selected_byte == 0 then
                let filter_element = TileLogicalLinearIndex(
                    filter_tile,
                    row as integer {0..65535},
                    0);
                selected = ExtractWordByte(value, 1) ==
                    TileReadLogicalElement(filter_tile, filter_element)[7:0];
            elsif source_tile.data_type == TileDataType_U32 then
                if selected_byte <= 2 then
                    selected = ExtractWordByte(value, 3) ==
                        TileReadLogicalElement(filter_tile,
                            TileLogicalLinearIndex(filter_tile, 0, 0))[7:0];
                end;
                if selected && selected_byte <= 1 then
                    selected = ExtractWordByte(value, 2) ==
                        TileReadLogicalElement(filter_tile,
                            TileLogicalLinearIndex(filter_tile, 1, 0))[7:0];
                end;
                if selected && selected_byte == 0 then
                    selected = ExtractWordByte(value, 1) ==
                        TileReadLogicalElement(filter_tile,
                            TileLogicalLinearIndex(filter_tile, 2, 0))[7:0];
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
            let element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                bin as integer {0..65535});
            result = TileInfoWithLogicalElement(result, element, cumulative);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    result.location = TileLocation_Any;
    _Tiles[[destination]] = result;
end;
