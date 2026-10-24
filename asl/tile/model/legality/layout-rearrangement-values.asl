// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT-VALUES","surface":"tile","classification":["model","legality","layout-rearrangement-values"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT","PTO-TILE-MODEL-STATE-TYPES"]}
readonly func TileCellRearrangementOutputValueDescriptorLegal(tile: TileInfo)
    => boolean
begin
    return tile.allocated && tile.storage_kind == TileStorage_Numeric &&
           TileCubeDescriptorLegal(tile) &&
           TileCellRearrangementLayoutLegal(tile.layout);
end;

readonly func TileOperandsLegal_TPERMUTEToValue(
    destination: TileOutputValueTarget, source0: TileIndex,
    source1: TileIndex, indices: TileIndex) => boolean
begin
    if !TileCellRearrangementOutputValueDescriptorLegal(destination.value) ||
       !TileCellRearrangementDescriptorLegal(source0) ||
       !TileCellRearrangementDescriptorLegal(source1) ||
       !TileCellRearrangementDescriptorLegal(indices) || destination.destination == source0 ||
       destination.destination == source1 || indices == source0 || indices == source1 then
        return FALSE;
    end;
    let destination_tile = destination.value;
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

readonly func TileOperandsLegal_TSHUFToValue(
    destination: TileOutputValueTarget, source: TileIndex,
    controls: TileIndex, control: Word) => boolean
begin
    if !TileCellRearrangementOutputValueDescriptorLegal(destination.value) ||
       !TileCellRearrangementDescriptorLegal(source) ||
       !TileCellRearrangementDescriptorLegal(controls) || destination.destination == source ||
       destination.destination == controls then return FALSE; end;
    let destination_tile = destination.value;
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

readonly func TileOperandsLegal_TPACKToValue(
    destination: TileOutputValueTarget, source0: TileIndex,
    source1: TileIndex, control: Word) => boolean
begin
    if !TileCellRearrangementOutputValueDescriptorLegal(destination.value) ||
       !TileCellRearrangementDescriptorLegal(source0) ||
       !TileCellRearrangementDescriptorLegal(source1) || destination.destination == source0 ||
       destination.destination == source1 then return FALSE; end;
    let destination_tile = destination.value;
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

readonly func TileOperandsLegal_TUNPACKToValue(
    destination: TileOutputValueTarget, source: TileIndex, control: Word) => boolean
begin
    if !TileCellRearrangementOutputValueDescriptorLegal(destination.value) ||
       !TileCellRearrangementDescriptorLegal(source) || destination.destination == source then
        return FALSE;
    end;
    let destination_tile = destination.value;
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
