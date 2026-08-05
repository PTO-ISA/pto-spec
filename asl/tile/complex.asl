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

impdef func TileProfileValueIsNaN(value: Word,
                                  data_type: TileDataType) => boolean
begin
    return FALSE;
end;

func TileSortLeftBefore(left: Word, right: Word, descending: boolean,
                        data_type: TileDataType) => boolean
begin
    let left_nan = TileProfileValueIsNaN(left, data_type);
    let right_nan = TileProfileValueIsNaN(right, data_type);
    if left_nan then return right_nan; end;
    if right_nan then return TRUE; end;
    return TileProfileOrderLeft(left, right, descending, data_type);
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

func TSORT32(destination: TileIndex, destination_indices: TileIndex,
           source: TileIndex, descending: boolean)
begin
    let source_tile = _Tiles[[source]];
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[destination_indices]];
    let extent: integer = source_tile.valid_rows * source_tile.valid_columns;
    assert destination_tile.valid_rows * destination_tile.valid_columns == extent;
    assert index_tile.valid_rows * index_tile.valid_columns == extent;
    assert destination_tile.data_type == source_tile.data_type;
    var values: TilePayload = source_tile.payload;
    var indices: TilePayload;
    for element = 0 to extent - 1 looplimit 4096 do
        indices[[element as ModelTileElementIndex]] =
            Zeros{PTO_XLEN} + (element MOD 32);
    end;
    let group_count: integer = (extent + 31) DIVRM 32;
    for group = 0 to group_count - 1 looplimit 128 do
        let group_begin: integer = group * 32;
        let group_end: integer = if group_begin + 32 < extent then
            group_begin + 32 else extent;
        for sort_pass = 0 to 31 do
            for offset = 0 to 30 do
                let element: integer = group_begin + offset;
                if element + 1 < group_end then
                    let left = values[[element as ModelTileElementIndex]];
                    let right = values[[(element + 1) as ModelTileElementIndex]];
                    let swap = !TileSortLeftBefore(
                        left, right, descending, source_tile.data_type);
                    if swap then
                        values[[element as ModelTileElementIndex]] = right;
                        values[[(element + 1) as ModelTileElementIndex]] = left;
                        let left_index =
                            indices[[element as ModelTileElementIndex]];
                        indices[[element as ModelTileElementIndex]] =
                            indices[[(element + 1) as ModelTileElementIndex]];
                        indices[[(element + 1) as ModelTileElementIndex]] =
                            left_index;
                    end;
                end;
            end;
        end;
    end;
    for element = 0 to extent - 1 looplimit 4096 do
        _Tiles[[destination]].payload[[element as ModelTileElementIndex]] =
            values[[element as ModelTileElementIndex]];
        _Tiles[[destination_indices]].payload[[
            element as ModelTileElementIndex]] =
            indices[[element as ModelTileElementIndex]];
    end;
    MarkTileValidRegionDefined(destination);
    MarkTileValidRegionDefined(destination_indices);
end;

// Counter-based 32-bit generator used by the portable ASL profile.  scalar0
// carries the 64-bit key, scalar1/address carry the low/high halves of the
// 128-bit counter, and seven_rounds selects 7 instead of the default 10.
pure func TRandomRoundWord(value: Word, multiplier: Word) => Word
begin
    return MultiplyWord(ZeroExtend{PTO_XLEN}(value[31:0]), multiplier);
end;

func TRANDOM(destination: TileIndex, key: Word, counter_low: Word,
             counter_high: Word, seven_rounds: boolean)
begin
    let destination_tile = _Tiles[[destination]];
    let extent: integer = destination_tile.valid_rows *
        destination_tile.valid_columns;
    let rounds: integer = if seven_rounds then 7 else 10;
    for element = 0 to extent - 1 looplimit 4096 do
        let block: integer = element DIVRM 4;
        var c0: Word = ZeroExtend{PTO_XLEN}(counter_low[31:0]) +
            (Zeros{PTO_XLEN} + block);
        var c1: Word = ZeroExtend{PTO_XLEN}(counter_low[63:32]);
        var c2: Word = ZeroExtend{PTO_XLEN}(counter_high[31:0]);
        var c3: Word = ZeroExtend{PTO_XLEN}(counter_high[63:32]);
        if UInt(counter_low[31:0]) + block > 0xffffffff then
            c1 = c1 + 1;
        end;
        var k0: Word = ZeroExtend{PTO_XLEN}(key[31:0]);
        var k1: Word = ZeroExtend{PTO_XLEN}(key[63:32]);
        for round = 0 to rounds - 1 looplimit 10 do
            let m0 = TRandomRoundWord(c0, Zeros{PTO_XLEN} + 0xD2511F53);
            let m1 = TRandomRoundWord(c2, Zeros{PTO_XLEN} + 0xCD9E8D57);
            let n0 = ZeroExtend{PTO_XLEN}(m1[63:32]) XOR c1 XOR k0;
            let n1 = ZeroExtend{PTO_XLEN}(m1[31:0]);
            let n2 = ZeroExtend{PTO_XLEN}(m0[63:32]) XOR c3 XOR k1;
            let n3 = ZeroExtend{PTO_XLEN}(m0[31:0]);
            c0 = n0; c1 = n1; c2 = n2; c3 = n3;
            k0 = ZeroExtend{PTO_XLEN}((k0 + 0x9E3779B9)[31:0]);
            k1 = ZeroExtend{PTO_XLEN}((k1 + 0xBB67AE85)[31:0]);
        end;
        let value = if element MOD 4 == 0 then c0
                    else if element MOD 4 == 1 then c1
                    else if element MOD 4 == 2 then c2 else c3;
        _Tiles[[destination]].payload[[element as ModelTileElementIndex]] =
            ZeroExtend{PTO_XLEN}(value[31:0]);
    end;
    MarkTileValidRegionDefined(destination);
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
    MarkTileValidRegionDefined(destination);
end;
