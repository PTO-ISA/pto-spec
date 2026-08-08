<!-- GENERATED FROM: asl/tile/model/execution/rearrangement.asl -->
# Rearrangement

**Normative ASL source:** `asl/tile/model/execution/rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-REARRANGEMENT}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/rearrangement.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","surface":"tile","classification":["model","execution","rearrangement"],"depends_on":["PTO-TILE-MODEL-NUMERIC-EXCEPTIONS"]}
// PTO-REQ-TEPL-REARRANGE-001: direct tile layout and indexing operations.

func TEXTRACT(destination: TileIndex, source: TileIndex,
              row_offset: integer {0..65535}, column_offset: integer {0..65535})
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert destination_tile.allocated && source_tile.allocated;
    assert destination_tile.data_type == source_tile.data_type;
    assert row_offset + destination_tile.valid_rows <= source_tile.valid_rows;
    assert column_offset + destination_tile.valid_columns <= source_tile.valid_columns;
    let source_payload = source_tile.payload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLinearIndex(source_tile,
                (row + row_offset) as integer {0..65535},
                (column + column_offset) as integer {0..65535});
            WriteTileElement(destination, row as integer {0..65535},
                column as integer {0..65535}, source_payload[[source_element]]);
        end;
    end;
end;

func TINSERT(destination: TileIndex, source: TileIndex,
             row_offset: integer {0..65535}, column_offset: integer {0..65535})
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert destination_tile.allocated && source_tile.allocated;
    assert destination_tile.contents_defined;
    assert destination_tile.data_type == source_tile.data_type;
    assert row_offset + source_tile.valid_rows <= destination_tile.valid_rows;
    assert column_offset + source_tile.valid_columns <= destination_tile.valid_columns;
    let source_payload = source_tile.payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            WriteTileElement(destination,
                (row + row_offset) as integer {0..65535},
                (column + column_offset) as integer {0..65535},
                source_payload[[source_element]]);
        end;
    end;
end;

func TTRANS(destination: TileIndex, source: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert destination_tile.valid_rows == source_tile.valid_columns;
    assert destination_tile.valid_columns == source_tile.valid_rows;
    assert destination_tile.data_type == source_tile.data_type;
    let source_payload = source_tile.payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            WriteTileElement(destination, column as integer {0..65535},
                row as integer {0..65535}, source_payload[[source_element]]);
        end;
    end;
end;

func TCONCAT(destination: TileIndex, source_left: TileIndex,
             source_right: TileIndex, axis: TileAxis)
begin
    let destination_tile = _Tiles[[destination]];
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    assert destination_tile.data_type == left_tile.data_type;
    assert destination_tile.data_type == right_tile.data_type;
    if axis == TileAxis_Row then
        assert left_tile.valid_columns == right_tile.valid_columns;
        assert destination_tile.valid_rows == left_tile.valid_rows + right_tile.valid_rows;
        assert destination_tile.valid_columns == left_tile.valid_columns;
    else
        assert left_tile.valid_rows == right_tile.valid_rows;
        assert destination_tile.valid_rows == left_tile.valid_rows;
        assert destination_tile.valid_columns == left_tile.valid_columns + right_tile.valid_columns;
    end;
    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            if (axis == TileAxis_Row && row < left_tile.valid_rows) ||
               (axis == TileAxis_Column && column < left_tile.valid_columns) then
                let element = TileLinearIndex(left_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                WriteTileElement(destination, row as integer {0..65535},
                    column as integer {0..65535}, left_payload[[element]]);
            else
                let right_row = if axis == TileAxis_Row then row - left_tile.valid_rows else row;
                let right_column = if axis == TileAxis_Column then column - left_tile.valid_columns else column;
                let element = TileLinearIndex(right_tile,
                    right_row as integer {0..65535}, right_column as integer {0..65535});
                WriteTileElement(destination, row as integer {0..65535},
                    column as integer {0..65535}, right_payload[[element]]);
            end;
        end;
    end;
end;

func TGATHER(destination: TileIndex, source: TileIndex, indices: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    assert destination_tile.valid_rows == index_tile.valid_rows;
    assert destination_tile.valid_columns == index_tile.valid_columns;
    let source_payload = source_tile.payload;
    let index_payload = index_tile.payload;
    let source_extent: integer = source_tile.valid_rows * source_tile.valid_columns;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let output_element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let source_index = UInt(index_payload[[output_element]]);
            assert source_index < source_extent;
            _Tiles[[destination]].payload[[output_element]] =
                source_payload[[source_index as ModelTileElementIndex]];
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func TSCATTER(destination: TileIndex, source: TileIndex, indices: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    assert destination_tile.contents_defined;
    assert TileShapesMatch(source_tile, index_tile);
    let source_payload = source_tile.payload;
    let index_payload = index_tile.payload;
    let destination_extent: integer = destination_tile.valid_rows * destination_tile.valid_columns;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let destination_index = UInt(index_payload[[source_element]]);
            assert destination_index < destination_extent;
            _Tiles[[destination]].payload[[destination_index as ModelTileElementIndex]] =
                source_payload[[source_element]];
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func TIMG2COL(destination: TileIndex, source: TileIndex,
              kernel_rows: integer {1..65535}, kernel_columns: integer {1..65535},
              stride_rows: integer {1..65535}, stride_columns: integer {1..65535},
              pad_rows: integer {0..65535}, pad_columns: integer {0..65535},
              padding: Word)
begin
    let source_tile = _Tiles[[source]];
    let destination_tile = _Tiles[[destination]];
    assert source_tile.valid_rows + 2 * pad_rows >= kernel_rows;
    assert source_tile.valid_columns + 2 * pad_columns >= kernel_columns;
    let output_rows: integer = (((source_tile.valid_rows + 2 * pad_rows) - kernel_rows)
        DIVRM stride_rows) + 1;
    let output_columns: integer = (((source_tile.valid_columns + 2 * pad_columns) - kernel_columns)
        DIVRM stride_columns) + 1;
    let patch_count: integer = output_rows * output_columns;
    let patch_elements: integer = kernel_rows * kernel_columns;
    assert destination_tile.valid_rows == patch_count;
    assert destination_tile.valid_columns == patch_elements;
    let source_payload = source_tile.payload;
    for patch = 0 to patch_count - 1 looplimit 4096 do
        let patch_row: integer = patch DIVRM output_columns;
        let patch_column: integer = patch MOD output_columns;
        for kernel_element = 0 to patch_elements - 1 looplimit 4096 do
            let kernel_row: integer = kernel_element DIVRM kernel_columns;
            let kernel_column: integer = kernel_element MOD kernel_columns;
            let input_row: integer = (patch_row * stride_rows + kernel_row) - pad_rows;
            let input_column: integer = (patch_column * stride_columns + kernel_column) - pad_columns;
            var value = padding;
            if input_row >= 0 && input_row < source_tile.valid_rows &&
               input_column >= 0 && input_column < source_tile.valid_columns then
                let source_element = TileLinearIndex(source_tile,
                    input_row as integer {0..65535}, input_column as integer {0..65535});
                value = source_payload[[source_element]];
            end;
            WriteTileElement(destination, patch as integer {0..65535},
                kernel_element as integer {0..65535}, value);
        end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
