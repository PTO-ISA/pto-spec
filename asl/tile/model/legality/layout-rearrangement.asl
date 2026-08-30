// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT","surface":"tile","classification":["model","legality","layout-rearrangement"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}

readonly func TileOperandsLegal_TEXTRACT(
    destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535}) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileSourceContentsDefined(source) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let (operation_type_valid, operation_type) =
        ResolveBundleEffectiveDataType();
    return operation_type_valid &&
           TileCarrierWidthCompatible(source_tile.data_type, operation_type) &&
           destination_tile.storage_kind == TileStorage_Numeric &&
           source_tile.storage_kind == TileStorage_Numeric &&
           TileCarrierOrMove24BaselineDataTypeSupported(
               destination_tile.data_type) &&
           destination_tile.data_type == source_tile.data_type &&
           TileLayoutShapeLegal(destination_tile) &&
           TileLayoutShapeLegal(source_tile) &&
           row_offset + destination_tile.valid_rows <=
               source_tile.valid_rows &&
           column_offset + destination_tile.valid_columns <=
               source_tile.valid_columns;
end;

readonly func TileOperandsLegal_TINSERT(
    destination: TileIndex,
    old_destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535}) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileSourceContentsDefined(old_destination) ||
       !TileSourceContentsDefined(source) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let old_tile = _Tiles[[old_destination]];
    let source_tile = _Tiles[[source]];
    let (operation_type_valid, operation_type) =
        ResolveBundleEffectiveDataType();
    return operation_type_valid &&
           TileCarrierWidthCompatible(old_tile.data_type, operation_type) &&
           TileCarrierWidthCompatible(source_tile.data_type, operation_type) &&
           destination_tile.storage_kind == TileStorage_Numeric &&
           old_tile.storage_kind == TileStorage_Numeric &&
           source_tile.storage_kind == TileStorage_Numeric &&
           TileCarrierOrMove24BaselineDataTypeSupported(
               destination_tile.data_type) &&
           TileShapeAndTypeMatch(destination, old_destination) &&
           destination_tile.data_type == source_tile.data_type &&
           TileLayoutShapeLegal(destination_tile) &&
           TileLayoutShapeLegal(old_tile) &&
           TileLayoutShapeLegal(source_tile) &&
           row_offset + source_tile.valid_rows <=
               destination_tile.valid_rows &&
           column_offset + source_tile.valid_columns <=
               destination_tile.valid_columns;
end;

readonly func TileOperandsLegal_TCONCAT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileSourceContentsDefined(source_left) ||
       !TileSourceContentsDefined(source_right) ||
       _Tiles[[destination]].data_type != _Tiles[[source_left]].data_type ||
       _Tiles[[destination]].data_type != _Tiles[[source_right]].data_type then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    let (operation_type_valid, operation_type) =
        ResolveBundleEffectiveDataType();
    return operation_type_valid &&
           TileCarrierWidthCompatible(left_tile.data_type, operation_type) &&
           TileCarrierWidthCompatible(right_tile.data_type, operation_type) &&
           destination_tile.storage_kind == TileStorage_Numeric &&
           left_tile.storage_kind == TileStorage_Numeric &&
           right_tile.storage_kind == TileStorage_Numeric &&
           TileCarrierOrMove24BaselineDataTypeSupported(
               destination_tile.data_type) &&
           left_tile.valid_rows > 0 &&
           left_tile.valid_rows == right_tile.valid_rows &&
           destination_tile.valid_rows == left_tile.valid_rows &&
           destination_tile.valid_columns ==
               left_tile.valid_columns + right_tile.valid_columns &&
           TileLayoutShapeLegal(destination_tile) &&
           TileLayoutShapeLegal(left_tile) &&
           TileLayoutShapeLegal(right_tile);
end;

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
       !TileCubeDataTypeSupported(destination_tile.data_type) ||
       TileElementBits(destination_tile.data_type) == 64 ||
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
            if !TileCellRearrangementByteDefined(index_tile,
                row as integer {0..65535}, byte_index) then
                return FALSE;
            end;
            let index_element = TileLogicalLinearIndex(index_tile,
                row as integer {0..65535}, byte_index as integer {0..65535});
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
       !TileCubeDataTypeSupported(destination_tile.data_type) ||
       TileElementBits(destination_tile.data_type) == 64 ||
       !TileCellRearrangementValidRegionDefined(source_tile) ||
       !TileCellRearrangementValidRegionDefined(control_tile) then
        return FALSE;
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
    return destination_tile.storage_kind == TileStorage_Numeric &&
           left.storage_kind == TileStorage_Numeric &&
           right.storage_kind == TileStorage_Numeric &&
           TileCellRearrangementLayoutLegal(destination_tile.layout) &&
           destination_tile.layout == left.layout &&
           destination_tile.layout == right.layout &&
           destination_tile.data_type == TileDataType_U32 &&
           left.data_type == TileDataType_U32 &&
           right.data_type == TileDataType_U32 &&
           destination_tile.valid_rows == left.valid_rows &&
           destination_tile.valid_rows == right.valid_rows &&
           destination_tile.valid_columns == left.valid_columns &&
           destination_tile.valid_columns == right.valid_columns &&
           left_bytes >= 1 && left_bytes <= 3 &&
           right_bytes >= 1 && right_bytes <= 3 &&
           left_bytes + right_bytes <= 4 &&
           TileRearrangementControlWordLegal(control) &&
           TileCellRearrangementValidRegionDefined(left) &&
           TileCellRearrangementValidRegionDefined(right);
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
    return destination_tile.storage_kind == TileStorage_Numeric &&
           source_tile.storage_kind == TileStorage_Numeric &&
           TileCellRearrangementLayoutLegal(destination_tile.layout) &&
           destination_tile.layout == source_tile.layout &&
           destination_tile.data_type == TileDataType_U32 &&
           source_tile.data_type == TileDataType_U32 &&
           destination_tile.valid_rows == source_tile.valid_rows &&
           destination_tile.valid_columns == source_tile.valid_columns &&
           offset <= 3 && count >= 1 && count <= 4 && offset + count <= 4 &&
           TileRearrangementControlWordLegal(control) &&
           TileCellRearrangementValidRegionDefined(source_tile);
end;
