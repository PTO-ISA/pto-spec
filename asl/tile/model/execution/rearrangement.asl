// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","surface":"tile","classification":["model","execution","rearrangement"],"depends_on":["PTO-TILE-MODEL-NUMERIC-EXCEPTIONS","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"]}
// PTO-REQ-TEPL-REARRANGE-001: direct tile layout and indexing operations.

func TEXTRACT(destination: TileIndex, source: TileIndex,
              row_offset: integer {0..65535}, column_offset: integer {0..65535})
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert TileOperandsLegal_TEXTRACT(
        destination,
        source,
        row_offset,
        column_offset);
    var result = destination_tile;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_tile,
                (row + row_offset) as integer {0..65535},
                (column + column_offset) as integer {0..65535});
            let destination_element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, destination_element,
                TileReadLogicalElement(source_tile, source_element));
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;

func TINSERT(destination: TileIndex,
             old_destination: TileIndex,
             source: TileIndex,
             row_offset: integer {0..65535}, column_offset: integer {0..65535})
begin
    let destination_tile = _Tiles[[destination]];
    let old_tile = _Tiles[[old_destination]];
    let source_tile = _Tiles[[source]];
    assert TileOperandsLegal_TINSERT(
        destination,
        old_destination,
        source,
        row_offset,
        column_offset);
    let old_payload = old_tile.payload;
    var result = destination_tile;
    result.payload = old_payload;
    result.defined_elements = old_tile.defined_elements;
    result.packed_defined_elements = old_tile.packed_defined_elements;
    result.defined_valid_elements = old_tile.defined_valid_elements;
    result.contents_defined = old_tile.contents_defined;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let destination_element = TileLogicalLinearIndex(
                result,
                (row + row_offset) as integer {0..65535},
                (column + column_offset) as integer {0..65535});
            result = TileInfoWithLogicalElement(result, destination_element,
                TileReadLogicalElement(source_tile, source_element));
        end;
    end;
    result = TileWithValidRegionDefined(result);
    _Tiles[[destination]] = result;
end;

func TTRANS(destination: TileIndex, source: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert TileOperandsLegal_TTRANS(destination, source);
    var result = destination_tile;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let destination_element = TileLogicalLinearIndex(
                result,
                column as integer {0..65535},
                row as integer {0..65535});
            result = TileInfoWithLogicalElement(result, destination_element,
                TileReadLogicalElement(source_tile, source_element));
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

func TCONCAT(destination: TileIndex, source_left: TileIndex,
             source_right: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    assert TileOperandsLegal_TCONCAT(
        destination,
        source_left,
        source_right);
    var result = destination_tile;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            if column < left_tile.valid_columns then
                let element = TileLogicalLinearIndex(left_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                result = TileInfoWithLogicalElement(result, destination_element,
                    TileReadLogicalElement(left_tile, element));
            else
                let element = TileLogicalLinearIndex(right_tile,
                    row as integer {0..65535},
                    (column - left_tile.valid_columns)
                        as integer {0..65535});
                result = TileInfoWithLogicalElement(result, destination_element,
                    TileReadLogicalElement(right_tile, element));
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;
