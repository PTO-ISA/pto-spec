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

readonly func TileInfoWithCellByte(tile: TileInfo,
                                   row: integer {0..65535},
                                   byte_index: integer {0..262143},
                                   value: Byte) => TileInfo
begin
    let element_bits = TileElementBits(tile.data_type);
    if element_bits == 4 then
        assert byte_index <= 32767;
        let first_byte_index = byte_index as integer {0..32767};
        let first_nibble = (first_byte_index * 2) as integer {0..65535};
        let first_element = TileLogicalLinearIndex(tile, row,
            first_nibble as integer {0..65535});
        var first_word = TileReadLogicalElement(tile, first_element);
        first_word[3:0] = value[3:0];
        var result = TileInfoWithLogicalElement(tile, first_element,
            first_word);
        if first_nibble + 1 < tile.valid_columns then
            let second_element = TileLogicalLinearIndex(tile, row,
                (first_nibble + 1) as integer {0..65535});
            var second_word = TileReadLogicalElement(result, second_element);
            second_word[3:0] = value[7:4];
            result = TileInfoWithLogicalElement(result, second_element,
                second_word);
        end;
        return result;
    end;
    let element_bytes = TileElementBytes(tile.data_type);
    let element_column = (byte_index DIVRM element_bytes)
        as integer {0..65535};
    let byte_in_element = (byte_index MOD element_bytes) as integer {0..7};
    let element = TileLogicalLinearIndex(tile, row, element_column);
    var word = TileReadLogicalElement(tile, element);
    word[(byte_in_element * 8) +: 8] = value;
    return TileInfoWithLogicalElement(tile, element, word);
end;

readonly func TileReadCellWord(tile: TileInfo,
                               row: integer {0..65535},
                               word_index: integer {0..65535}) => Word
begin
    let valid_bytes = TileCellRearrangementValidBytes(tile);
    let byte_base = (word_index * 4) as integer {0..262143};
    var result = Zeros{PTO_XLEN};
    for byte_index = 0 to 3 looplimit 4 do
        if byte_base + byte_index < valid_bytes then
            result[(byte_index * 8) +: 8] = TileReadCellByte(tile, row,
                (byte_base + byte_index) as integer {0..262143});
        end;
    end;
    return result;
end;

readonly func TileInfoWithCellWord(tile: TileInfo,
                                   row: integer {0..65535},
                                   word_index: integer {0..65535},
                                   value: Word) => TileInfo
begin
    let valid_bytes = TileCellRearrangementValidBytes(tile);
    let byte_base = (word_index * 4) as integer {0..262143};
    var result = tile;
    for byte_index = 0 to 3 looplimit 4 do
        if byte_base + byte_index < valid_bytes then
            result = TileInfoWithCellByte(result, row,
                (byte_base + byte_index) as integer {0..262143},
                value[(byte_index * 8) +: 8]);
        end;
    end;
    return result;
end;

func TPERMUTE(destination: TileIndex, source0: TileIndex,
              source1: TileIndex, indices: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let source0_tile = _Tiles[[source0]];
    let source1_tile = _Tiles[[source1]];
    let index_tile = _Tiles[[indices]];
    assert TileOperandsLegal_TPERMUTE(
        destination, source0, source1, indices);
    let row_bytes = TileCellRearrangementRowBytes(destination_tile.layout);
    let valid_bytes = TileCellRearrangementValidBytes(destination_tile);
    var result = destination_tile;
    // Validate all indices before the first destination write.
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for byte_index = 0 to valid_bytes - 1 looplimit 65536 do
            let index_value = UInt(TileReadCellByte(
                index_tile, row as integer {0..65535}, byte_index));
            assert index_value < row_bytes * 2;
        end;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for byte_index = 0 to valid_bytes - 1 looplimit 65536 do
            let index_value = UInt(TileReadCellByte(
                index_tile, row as integer {0..65535}, byte_index));
            let selected_source = if index_value < row_bytes then
                source0_tile else source1_tile;
            let cell_base = (byte_index DIVRM row_bytes) * row_bytes;
            let selected_byte = if index_value < row_bytes then
                index_value else index_value - row_bytes;
            result = TileInfoWithCellByte(
                result,
                row as integer {0..65535},
                byte_index,
                TileReadCellByte(
                    selected_source,
                    row as integer {0..65535},
                    (cell_base + selected_byte)
                        as integer {0..262143}));
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

func TSHUF(destination: TileIndex, source: TileIndex,
           controls: TileIndex, control: Word)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let controls_tile = _Tiles[[controls]];
    assert TileOperandsLegal_TSHUF(destination, source, controls, control);
    let mode = UInt(control[7:0]);
    let segment_code = UInt(control[15:8]);
    let boundary = UInt(control[23:16]);
    let segment_width = if segment_code == 0 then 2
        else if segment_code == 1 then 4
        else if segment_code == 2 then 8
        else if segment_code == 3 then 16
        else 32;
    let cell_rows = if destination_tile.layout == TileLayout_CUBE_M32 then 32
        else 16;
    var result = destination_tile;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        let lane = (row MOD cell_rows) as integer {0..31};
        let segment_base = ((lane DIVRM segment_width) * segment_width)
            as integer {0..31};
        let local_lane = (lane - segment_base) as integer {0..31};
        let word_count = TileCellRearrangementWordsPerRow(source_tile);
        for word_index = 0 to word_count - 1 looplimit 65536 do
            let source_word = TileReadCellWord(source_tile,
                row as integer {0..65535},
                word_index as integer {0..65535});
            let control_word = TileReadCellWord(controls_tile,
                row as integer {0..65535},
                word_index as integer {0..65535});
            let b = UInt(control_word[4:0]);
            var candidate_valid = TRUE;
            var candidate_lane: integer {0..31} = lane as integer {0..31};
            if mode == 0 then
                if b > lane - segment_base then candidate_valid = FALSE;
                else candidate_lane = (lane - b) as integer {0..31};
                end;
            elsif mode == 1 then
                if (lane - segment_base) + b >= segment_width then
                    candidate_valid = FALSE;
                else candidate_lane = (lane + b) as integer {0..31};
                end;
            elsif mode == 2 then
                candidate_lane = (segment_base +
                    UInt(((Zeros{5} + local_lane) as bits(5)) XOR
                         ((Zeros{5} + b) as bits(5))))
                    as integer {0..31};
                if candidate_lane >= segment_base + segment_width then
                    candidate_valid = FALSE;
                end;
            else
                candidate_lane = (segment_base +
                    (b MOD segment_width)) as integer {0..31};
            end;
            let candidate_row = (row - lane) + candidate_lane;
            var value = Zeros{PTO_XLEN};
            if candidate_valid && candidate_row < source_tile.valid_rows then
                value = TileReadCellWord(source_tile,
                    candidate_row as integer {0..65535},
                    word_index as integer {0..65535});
            elsif boundary == 0 then
                value = source_word;
            end;
            result = TileInfoWithCellWord(result,
                row as integer {0..65535},
                word_index as integer {0..65535}, value);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

func TPACK(destination: TileIndex, source0: TileIndex,
           source1: TileIndex, control: Word)
begin
    let destination_tile = _Tiles[[destination]];
    let source0_tile = _Tiles[[source0]];
    let source1_tile = _Tiles[[source1]];
    assert TileOperandsLegal_TPACK(destination, source0, source1, control);
    let source0_bytes = UInt(control[7:0]);
    let source1_bytes = UInt(control[15:8]);
    var result = destination_tile;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for word_index = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let left_element = TileLogicalLinearIndex(source0_tile,
                row as integer {0..65535}, word_index as integer {0..65535});
            let right_element = TileLogicalLinearIndex(source1_tile,
                row as integer {0..65535}, word_index as integer {0..65535});
            let left_word = TileReadLogicalElement(source0_tile, left_element);
            let right_word = TileReadLogicalElement(source1_tile, right_element);
            var packed = Zeros{PTO_XLEN};
            for byte_index = 0 to source0_bytes - 1 looplimit 3 do
                packed[(byte_index * 8) +: 8] = left_word[(byte_index * 8) +: 8];
            end;
            for byte_index = 0 to source1_bytes - 1 looplimit 3 do
                packed[((source0_bytes + byte_index) * 8) +: 8] =
                    right_word[(byte_index * 8) +: 8];
            end;
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, word_index as integer {0..65535});
            result = TileInfoWithLogicalElement(result, destination_element, packed);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

func TUNPACK(destination: TileIndex, source: TileIndex, control: Word)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert TileOperandsLegal_TUNPACK(destination, source, control);
    let byte_offset = UInt(control[7:0]);
    let byte_count = UInt(control[15:8]);
    var result = destination_tile;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for word_index = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535}, word_index as integer {0..65535});
            let source_word = TileReadLogicalElement(source_tile, source_element);
            var unpacked = Zeros{PTO_XLEN};
            for byte_index = 0 to byte_count - 1 looplimit 4 do
                unpacked[(byte_index * 8) +: 8] =
                    source_word[((byte_offset + byte_index) * 8) +: 8];
            end;
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, word_index as integer {0..65535});
            result = TileInfoWithLogicalElement(result, destination_element, unpacked);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;
