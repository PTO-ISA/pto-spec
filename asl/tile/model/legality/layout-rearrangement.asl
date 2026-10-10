// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT","surface":"tile","classification":["model","legality","layout-rearrangement"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}

pure func TileCellRearrangementLayoutLegal(layout: TileLayout) => boolean
begin
    return layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32;
end;

readonly func TileCellRearrangementDescriptorLegal(index: TileIndex)
    => boolean
begin
    return TileCubeDescriptorLegal(_Tiles[[index]]) &&
           TileCellRearrangementLayoutLegal(_Tiles[[index]].layout);
end;

pure func TileCellRearrangementRowBytes(layout: TileLayout) => integer {4,8}
begin
    return if layout == TileLayout_CUBE_M32 then 4 else 8;
end;

pure func TileRearrangementControlWordLegal(control: Word) => boolean
begin
    return control[63:32] == Zeros{32};
end;

readonly func TileCellRearrangementValidBytes(tile: TileInfo)
    => integer {0..262144}
begin
    return ((tile.valid_columns * TileElementBits(tile.data_type) + 7) DIVRM 8)
        as integer {0..262144};
end;

readonly func TileCellRearrangementWordsPerRow(tile: TileInfo)
    => integer {0..65536}
begin
    return ((TileCellRearrangementValidBytes(tile) + 3) DIVRM 4)
        as integer {0..65536};
end;

readonly func TileCellRearrangementByteDefined(
    tile: TileInfo, row: integer {0..65535},
    byte_index: integer {0..262143}) => boolean
begin
    let element_bits = TileElementBits(tile.data_type);
    if element_bits == 4 then
        assert byte_index <= 32767;
        let first_byte_index = byte_index as integer {0..32767};
        let first_nibble = (first_byte_index * 2) as integer {0..65535};
        if first_nibble >= tile.valid_columns then return FALSE; end;
        let first_element = TileLogicalLinearIndex(tile, row,
            first_nibble as integer {0..65535});
        if !TileLogicalElementDefined(tile, first_element) then
            return FALSE;
        end;
        if first_nibble + 1 < tile.valid_columns then
            let second_element = TileLogicalLinearIndex(tile, row,
                (first_nibble + 1) as integer {0..65535});
            return TileLogicalElementDefined(tile, second_element);
        end;
        return TRUE;
    end;
    let element_bytes = TileElementBytes(tile.data_type);
    let element_column = (byte_index DIVRM element_bytes)
        as integer {0..65535};
    if element_column >= tile.valid_columns then return FALSE; end;
    let element = TileLogicalLinearIndex(tile, row,
        element_column as integer {0..65535});
    return TileLogicalElementDefined(tile, element);
end;

readonly func TileReadCellByte(tile: TileInfo,
                               row: integer {0..65535},
                               byte_index: integer {0..262143}) => Byte
begin
    let element_bits = TileElementBits(tile.data_type);
    if element_bits == 4 then
        assert byte_index <= 32767;
        let first_byte_index = byte_index as integer {0..32767};
        let first_nibble = (first_byte_index * 2) as integer {0..65535};
        let first_element = TileLogicalLinearIndex(tile, row,
            first_nibble as integer {0..65535});
        var result = Zeros{8};
        result[3:0] = TileReadLogicalElement(tile, first_element)[3:0];
        if first_nibble + 1 < tile.valid_columns then
            let second_element = TileLogicalLinearIndex(tile, row,
                (first_nibble + 1) as integer {0..65535});
            result[7:4] = TileReadLogicalElement(tile,
                second_element)[3:0];
        end;
        return result;
    end;
    let element_bytes = TileElementBytes(tile.data_type);
    let element_column = (byte_index DIVRM element_bytes)
        as integer {0..65535};
    let byte_in_element = (byte_index MOD element_bytes) as integer {0..7};
    let element = TileLogicalLinearIndex(tile, row,
        element_column as integer {0..65535});
    return TileReadLogicalElement(tile, element)[(byte_in_element * 8) +: 8];
end;

readonly func TileCellRearrangementValidRegionDefined(tile: TileInfo)
    => boolean
begin
    let valid_bytes = TileCellRearrangementValidBytes(tile);
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for byte_index = 0 to valid_bytes - 1 looplimit 262144 do
            if !TileCellRearrangementByteDefined(tile,
                row as integer {0..65535}, byte_index) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileCellRearrangementByteHasActiveCoordinate(
    tile: TileInfo, row: integer {0..65535},
    byte_index: integer {0..262143}) => boolean
begin
    let element_bits = TileElementBits(tile.data_type);
    if element_bits == 4 then
        let first_column = (byte_index * 2) as integer {0..65535};
        if first_column < tile.valid_columns &&
           BundleExecutionMaskActiveAt(tile.layout, row, first_column) then
            return TRUE;
        end;
        return first_column + 1 < tile.valid_columns &&
               BundleExecutionMaskActiveAt(
                   tile.layout, row,
                   (first_column + 1) as integer {0..65535});
    end;
    let element_column = (byte_index DIVRM
        TileElementBytes(tile.data_type)) as integer {0..65535};
    return element_column < tile.valid_columns &&
           BundleExecutionMaskActiveAt(tile.layout, row, element_column);
end;

pure func TileCellRearrangementElementWordIndex(
    data_type: TileDataType, column: integer {0..65535})
    => integer {0..65535}
begin
    return ((column * TileElementBits(data_type)) DIVRM 32)
        as integer {0..65535};
end;

pure func TileShuffleSelectedRow(
    control_word: Word, row: integer {0..65535},
    valid_rows: integer {1..65535}, layout: TileLayout,
    segment_width: integer {2,4,8,16,32}, mode: integer {0..3},
    boundary: integer {0..1})
    => (boolean, integer {0..65535})
begin
    let cell_rows = if layout == TileLayout_CUBE_M32 then 32 else 16;
    let lane = (row MOD cell_rows) as integer {0..31};
    let segment_base = ((lane DIVRM segment_width) * segment_width)
        as integer {0..31};
    let local_lane = (lane - segment_base) as integer {0..31};
    let b = UInt(control_word[4:0]);
    var candidate_valid = TRUE;
    var candidate_lane: integer {0..31} = lane;
    if mode == 0 then
        if b > lane - segment_base then candidate_valid = FALSE;
        else candidate_lane = (lane - b) as integer {0..31}; end;
    elsif mode == 1 then
        if (lane - segment_base) + b >= segment_width then
            candidate_valid = FALSE;
        else candidate_lane = (lane + b) as integer {0..31}; end;
    elsif mode == 2 then
        candidate_lane = (segment_base +
            UInt(((Zeros{5} + local_lane) as bits(5)) XOR
                 ((Zeros{5} + b) as bits(5)))) as integer {0..31};
        if candidate_lane >= segment_base + segment_width then
            candidate_valid = FALSE;
        end;
    else
        candidate_lane = (segment_base + (b MOD segment_width))
            as integer {0..31};
    end;
    let candidate_row = (row - lane) + candidate_lane;
    if candidate_valid && candidate_row < valid_rows then
        return (TRUE, candidate_row as integer {0..65535});
    end;
    return (boundary == 0, row);
end;

readonly func TileOperandsLegal_TPERMUTE(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, indices: TileIndex) => boolean
begin
    if !TileCellRearrangementDescriptorLegal(destination) ||
       !TileCellRearrangementDescriptorLegal(source0) ||
       !TileCellRearrangementDescriptorLegal(source1) ||
       !TileCellRearrangementDescriptorLegal(indices) || destination == source0 ||
       destination == source1 || indices == source0 || indices == source1 then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let left = _Tiles[[source0]];
    let right = _Tiles[[source1]];
    let index_tile = _Tiles[[indices]];
    if destination_tile.storage_kind != TileStorage_Numeric ||
       left.storage_kind != TileStorage_Numeric ||
       right.storage_kind != TileStorage_Numeric ||
       index_tile.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementLayoutLegal(destination_tile.layout) ||
       destination_tile.layout != left.layout ||
       destination_tile.layout != right.layout ||
       destination_tile.data_type != left.data_type ||
       destination_tile.data_type != right.data_type ||
       !TileCubeLayoutDataTypeSupported(
           destination_tile.layout, destination_tile.data_type) ||
       index_tile.data_type != TileDataType_U8 ||
       index_tile.layout != destination_tile.layout ||
       destination_tile.valid_rows != left.valid_rows ||
       destination_tile.valid_rows != right.valid_rows ||
       destination_tile.valid_columns != left.valid_columns ||
       destination_tile.valid_columns != right.valid_columns ||
       index_tile.valid_rows != destination_tile.valid_rows ||
       index_tile.valid_columns !=
           TileCellRearrangementValidBytes(destination_tile) ||
       index_tile.cube_cell_count != destination_tile.cube_cell_count then
        return FALSE;
    end;
    let row_bytes = TileCellRearrangementRowBytes(destination_tile.layout);
    let valid_bytes = TileCellRearrangementValidBytes(destination_tile);
    if valid_bytes > row_bytes * destination_tile.cube_cell_count then
        return FALSE;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for byte_index = 0 to valid_bytes - 1 looplimit 262144 do
            if TileCellRearrangementByteHasActiveCoordinate(
                   destination_tile, row as integer {0..65535}, byte_index) then
                if !TileCellRearrangementByteDefined(index_tile,
                    row as integer {0..65535}, byte_index) then
                    return FALSE;
                end;
                let index_element = TileLogicalLinearIndex(index_tile,
                    row as integer {0..65535},
                    byte_index as integer {0..65535});
                let index_value = UInt(TileReadLogicalElement(
                    index_tile, index_element));
                if index_value >= row_bytes * 2 then return FALSE; end;
                let cell_base = (byte_index DIVRM row_bytes) * row_bytes;
                let selected_byte = if index_value < row_bytes then
                    index_value else index_value - row_bytes;
                let source_byte = cell_base + selected_byte;
                let selected_source = if index_value < row_bytes then
                    left else right;
                if !TileCellRearrangementByteDefined(selected_source,
                    row as integer {0..65535},
                    source_byte as integer {0..262143}) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TSHUF(
    destination: TileIndex, source: TileIndex,
    controls: TileIndex, control: Word) => boolean
begin
    if !TileCellRearrangementDescriptorLegal(destination) ||
       !TileCellRearrangementDescriptorLegal(source) ||
       !TileCellRearrangementDescriptorLegal(controls) || destination == source ||
       destination == controls then return FALSE; end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let control_tile = _Tiles[[controls]];
    let mode = UInt(control[7:0]);
    let segment_code = UInt(control[15:8]);
    let boundary = UInt(control[23:16]);
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       control_tile.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementLayoutLegal(destination_tile.layout) ||
       destination_tile.layout != source_tile.layout ||
       destination_tile.layout != control_tile.layout ||
       destination_tile.data_type != source_tile.data_type ||
       control_tile.data_type != TileDataType_U32 ||
       destination_tile.valid_rows != source_tile.valid_rows ||
       destination_tile.valid_columns != source_tile.valid_columns ||
       control_tile.valid_rows != source_tile.valid_rows ||
       control_tile.valid_columns !=
           TileCellRearrangementWordsPerRow(source_tile) ||
       control_tile.cube_cell_count != source_tile.cube_cell_count ||
       mode > 3 || boundary > 1 || segment_code > 4 ||
       (segment_code == 4 &&
        destination_tile.layout != TileLayout_CUBE_M32) ||
       (destination_tile.layout == TileLayout_CUBE_M16 &&
        segment_code == 4) || !TileRearrangementControlWordLegal(control) ||
       !TileCubeLayoutDataTypeSupported(
           destination_tile.layout, destination_tile.data_type) then
        return FALSE;
    end;
    let segment_width = if segment_code == 0 then 2
        else if segment_code == 1 then 4
        else if segment_code == 2 then 8
        else if segment_code == 3 then 16
        else 32;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let first_word = TileCellRearrangementElementWordIndex(
                    source_tile.data_type,
                    column as integer {0..65535});
                let raw_words = if TileElementBits(source_tile.data_type) == 64
                    then 2 else 1;
                for raw_word = 0 to raw_words - 1 looplimit 2 do
                    let word_index = (first_word + raw_word)
                        as integer {0..65535};
                    let control_element = TileLogicalLinearIndex(
                        control_tile, row as integer {0..65535}, word_index);
                    if !TileLogicalElementDefined(
                           control_tile, control_element) then return FALSE; end;
                    let control_word = TileReadLogicalElement(
                        control_tile, control_element);
                    let (source_required, source_row) = TileShuffleSelectedRow(
                        control_word, row as integer {0..65535},
                        source_tile.valid_rows as integer {1..65535},
                        source_tile.layout,
                        segment_width, mode as integer {0..3},
                        boundary as integer {0..1});
                    if source_required then
                        let source_element = TileLogicalLinearIndex(
                            source_tile, source_row,
                            column as integer {0..65535});
                        if !TileLogicalElementDefined(
                               source_tile, source_element) then return FALSE; end;
                    end;
                end;
            end;
        end;
    end;
    return TRUE;
end;

pure func TileCellRearrangementDataTypeLegal(
    data_type: TileDataType) => boolean
begin
    return TileCubeDataTypeSupported(data_type) &&
           (TileElementBits(data_type) == 8 ||
            TileElementBits(data_type) == 16 ||
            TileElementBits(data_type) == 32 ||
            TileElementBits(data_type) == 64);
end;

readonly func TileCellRearrangementSelectedBytesDefined(
    tile: TileInfo, row: integer {0..65535},
    byte_offset: integer {0..262143},
    byte_count: integer {0..4}) => boolean
begin
    for byte_index = 0 to byte_count - 1 looplimit 4 do
        if !TileCellRearrangementByteDefined(
            tile, row, (byte_offset + byte_index) as integer {0..262143}) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TPACK(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, control: Word) => boolean
begin
    if !TileCellRearrangementDescriptorLegal(destination) ||
       !TileCellRearrangementDescriptorLegal(source0) ||
       !TileCellRearrangementDescriptorLegal(source1) || destination == source0 ||
       destination == source1 then return FALSE; end;
    let destination_tile = _Tiles[[destination]];
    let left = _Tiles[[source0]];
    let right = _Tiles[[source1]];
    let left_bytes = UInt(control[7:0]);
    let right_bytes = UInt(control[15:8]);
    if left.storage_kind != TileStorage_Numeric ||
       right.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementDataTypeLegal(left.data_type) ||
       !TileCellRearrangementDataTypeLegal(right.data_type) then
        return FALSE;
    end;
    let words = TileCellRearrangementWordsPerRow(left);
    let destination_elements_per_word =
        if destination_tile.data_type == TileDataType_U8 then 4
        else if destination_tile.data_type == TileDataType_U16 then 2
        else if destination_tile.data_type == TileDataType_U32 then 1
        else if destination_tile.data_type == TileDataType_U64 then 0
        else 0;
    let destination_columns: integer = if destination_tile.data_type == TileDataType_U64
        then words DIVRM 2 else words * destination_elements_per_word;
    if destination_tile.storage_kind != TileStorage_Numeric ||
       left.storage_kind != TileStorage_Numeric ||
       right.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementDataTypeLegal(left.data_type) ||
       !TileCellRearrangementDataTypeLegal(right.data_type) ||
       (destination_elements_per_word == 0 &&
        destination_tile.data_type != TileDataType_U64) ||
       (destination_tile.data_type == TileDataType_U64 &&
        (destination_tile.layout != TileLayout_CUBE_M32 ||
         words MOD 2 != 0)) ||
       destination_tile.layout != left.layout ||
       destination_tile.layout != right.layout ||
       destination_tile.valid_rows != left.valid_rows ||
       destination_tile.valid_rows != right.valid_rows ||
       TileCellRearrangementWordsPerRow(right) != words ||
       destination_tile.valid_columns != destination_columns ||
       left_bytes < 1 || left_bytes > 3 ||
       right_bytes < 1 || right_bytes > 3 ||
       left_bytes + right_bytes > 4 ||
       !TileRearrangementControlWordLegal(control) then
        return FALSE;
    end;
    for row = 0 to left.valid_rows - 1 looplimit 65536 do
        for word_index = 0 to words - 1 looplimit 65536 do
            let word_start = (word_index * 4) as integer {0..262143};
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   left.layout, row as integer {0..65535},
                   word_index as integer {0..65535}) then
                if !TileCellRearrangementSelectedBytesDefined(
                    left, row as integer {0..65535}, word_start,
                    left_bytes as integer {0..4}) ||
                   !TileCellRearrangementSelectedBytesDefined(
                    right, row as integer {0..65535}, word_start,
                    right_bytes as integer {0..4}) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TUNPACK(
    destination: TileIndex, source: TileIndex, control: Word) => boolean
begin
    if !TileCellRearrangementDescriptorLegal(destination) ||
       !TileCellRearrangementDescriptorLegal(source) || destination == source then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let offset = UInt(control[7:0]);
    let count = UInt(control[15:8]);
    if source_tile.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementDataTypeLegal(source_tile.data_type) then
        return FALSE;
    end;
    let words = TileCellRearrangementWordsPerRow(source_tile);
    let destination_elements_per_word =
        if destination_tile.data_type == TileDataType_U8 then 4
        else if destination_tile.data_type == TileDataType_U16 then 2
        else if destination_tile.data_type == TileDataType_U32 then 1
        else if destination_tile.data_type == TileDataType_U64 then 0
        else 0;
    let destination_columns: integer = if destination_tile.data_type == TileDataType_U64
        then words DIVRM 2 else words * destination_elements_per_word;
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementDataTypeLegal(source_tile.data_type) ||
       (destination_elements_per_word == 0 &&
        destination_tile.data_type != TileDataType_U64) ||
       (destination_tile.data_type == TileDataType_U64 &&
        (destination_tile.layout != TileLayout_CUBE_M32 ||
         words MOD 2 != 0)) ||
       destination_tile.layout != source_tile.layout ||
       destination_tile.valid_rows != source_tile.valid_rows ||
       destination_tile.valid_columns != destination_columns ||
       offset > 3 || count < 1 || count > 4 || offset + count > 4 ||
       !TileRearrangementControlWordLegal(control) then
        return FALSE;
    end;
    let valid_bytes = TileCellRearrangementValidBytes(source_tile);
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for word_index = 0 to words - 1 looplimit 65536 do
            let word_start = (word_index * 4) as integer {0..262143};
            let word_valid = if valid_bytes > word_start then
                (if valid_bytes - word_start > 4 then 4
                 else valid_bytes - word_start)
            else 0;
            if offset + count > word_valid then
                return FALSE;
            end;
            if (!_BundleExecutionMask.valid ||
                BundleExecutionMaskActiveAt(
                    source_tile.layout, row as integer {0..65535},
                    word_index as integer {0..65535})) &&
               !TileCellRearrangementSelectedBytesDefined(
                   source_tile, row as integer {0..65535},
                   (word_start + offset) as integer {0..262143},
                   count as integer {0..4}) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;
