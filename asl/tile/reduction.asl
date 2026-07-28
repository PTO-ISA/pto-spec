// PTO-REQ-TEPL-REDUCE-001: row/column reductions and index reductions.

pure func ReductionInitial(op: TileReductionOperation, first: Word) => Word
begin
    case op of
        when TileReduction_SUM     => return Zeros{PTO_XLEN};
        when TileReduction_PRODUCT => return Zeros{PTO_XLEN} + 1;
        when TileReduction_MIN     => return first;
        when TileReduction_MAX     => return first;
        when TileReduction_ARGMIN  => return first;
        when TileReduction_ARGMAX  => return first;
    end;
end;

func ExecuteTileReduction(op: TileReductionOperation, axis: TileAxis,
                          destination: TileIndex, source: TileIndex)
begin
    let tile = _Tiles[[source]];
    assert tile.allocated;
    assert tile.valid_rows > 0 && tile.valid_columns > 0;
    let payload = tile.payload;
    let outer_count = if axis == TileAxis_Row then tile.valid_rows else tile.valid_columns;
    let inner_count = if axis == TileAxis_Row then tile.valid_columns else tile.valid_rows;

    for outer = 0 to outer_count - 1 looplimit 65536 do
        let first_row = if axis == TileAxis_Row then outer else 0;
        let first_column = if axis == TileAxis_Row then 0 else outer;
        let first_element = TileLinearIndex(tile,
            first_row as integer {0..65535}, first_column as integer {0..65535});
        var accumulator = ReductionInitial(op, payload[[first_element]]);
        var selected_index: integer {0..65535} = 0;
        for inner = 0 to inner_count - 1 looplimit 65536 do
            let row = if axis == TileAxis_Row then outer else inner;
            let column = if axis == TileAxis_Row then inner else outer;
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let value = payload[[element]];
            case op of
                when TileReduction_SUM => accumulator = accumulator + value;
                when TileReduction_PRODUCT => accumulator = MultiplyWord(accumulator, value);
                when TileReduction_MIN => if SInt(value) < SInt(accumulator) then accumulator = value; end;
                when TileReduction_MAX => if SInt(value) > SInt(accumulator) then accumulator = value; end;
                when TileReduction_ARGMIN =>
                    if SInt(value) < SInt(accumulator) then
                        accumulator = value;
                        selected_index = inner as integer {0..65535};
                    end;
                when TileReduction_ARGMAX =>
                    if SInt(value) > SInt(accumulator) then
                        accumulator = value;
                        selected_index = inner as integer {0..65535};
                    end;
            end;
        end;
        let destination_row = if axis == TileAxis_Row then outer else 0;
        let destination_column = if axis == TileAxis_Row then 0 else outer;
        let output = if op == TileReduction_ARGMIN || op == TileReduction_ARGMAX then
            NaturalToWord(selected_index as integer {0..262144}) else accumulator;
        WriteTileElement(destination,
            destination_row as integer {0..65535},
            destination_column as integer {0..65535}, output);
    end;
end;
