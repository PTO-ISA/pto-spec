// PTO-REQ-TEPL-GENERATE-001: generated sequences, masks, and padding.

func TCI(destination: TileIndex, start: Word, descending: boolean)
begin
    let tile = _Tiles[[destination]];
    assert tile.allocated;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile, row as integer {0..65535},
                column as integer {0..65535});
            let offset = NaturalToWord(element as integer {0..262144});
            let value = if descending then start - offset else start + offset;
            _Tiles[[destination]].payload[[element]] = value;
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func TTRI(destination: TileIndex, upper: boolean,
          diagonal: integer {-65535..65535})
begin
    let tile = _Tiles[[destination]];
    assert tile.allocated;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let boundary: integer = row + diagonal;
            let selected = if upper then column >= boundary else column <= boundary;
            let value = if selected then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN};
            WriteTileElement(destination, row as integer {0..65535},
                column as integer {0..65535}, value);
        end;
    end;
end;

func TFILLPAD(destination: TileIndex, source: TileIndex, padding: Word)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert destination_tile.allocated && source_tile.allocated;
    assert destination_tile.rows >= source_tile.valid_rows;
    assert destination_tile.columns >= source_tile.valid_columns;
    let source_payload = source_tile.payload;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            var value = padding;
            if row < source_tile.valid_rows && column < source_tile.valid_columns then
                let source_element = TileLinearIndex(source_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                value = source_payload[[source_element]];
            end;
            WriteTileElement(destination, row as integer {0..65535},
                column as integer {0..65535}, value);
        end;
    end;
end;
