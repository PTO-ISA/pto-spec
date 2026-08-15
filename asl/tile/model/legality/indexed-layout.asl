// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","surface":"tile","classification":["model","legality","indexed-layout"],"depends_on":["PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"]}
pure func TilePartialDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_S32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_S8 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_U8;
end;

readonly func TileOperandsLegal_ExecuteTilePartial(
    op: TilePartialOperation, destination: TileIndex,
    source_left: TileIndex, source_right: TileIndex) => boolean
begin
    if op == TilePartial_ARGMAX || op == TilePartial_ARGMIN ||
       !TilePartialCoverageLegal(destination, source_left, source_right) then
        return FALSE;
    end;
    let data_type = _Tiles[[destination]].data_type;
    if !TilePartialDataTypeSupported(data_type) ||
       _Tiles[[source_left]].data_type != data_type ||
       _Tiles[[source_right]].data_type != data_type ||
       _Tiles[[destination]].layout != TileLayout_RowMajor ||
       _Tiles[[source_left]].layout != TileLayout_RowMajor ||
       _Tiles[[source_right]].layout != TileLayout_RowMajor ||
       !TileSourceContentsDefined(source_left) ||
       !TileSourceContentsDefined(source_right) then
        return FALSE;
    end;
    return !TileDataTypeIsFloating(data_type) ||
           (TileSourceEncodingsValid(source_left) &&
            TileSourceEncodingsValid(source_right));
end;

readonly func TileOperandsLegal_TFMA(
    destination: TileIndex, source_left: TileIndex,
    source_right: TileIndex, addend: TileIndex) => boolean
begin
    return TileDescriptorLegal(destination) &&
           TileSourceContentsDefined(source_left) &&
           TileSourceContentsDefined(source_right) &&
           TileSourceContentsDefined(addend) &&
           TileFusedMultiplyAddDataTypeSupported(
               _Tiles[[destination]].data_type) &&
           TileLogicalShapeMatch(destination, source_left) &&
           TileLogicalShapeMatch(destination, source_right) &&
           TileLogicalShapeMatch(destination, addend) &&
           _Tiles[[destination]].data_type == _Tiles[[source_left]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_right]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[addend]].data_type &&
           _Tiles[[destination]].layout == TileLayout_RowMajor &&
           (!TileDataTypeIsFloating(_Tiles[[destination]].data_type) ||
            (TileSourceEncodingsValid(source_left) &&
             TileSourceEncodingsValid(source_right) &&
             TileSourceEncodingsValid(addend)));
end;

readonly func TileOperandsLegal_ExecuteTilePartialArg(
    maximum: boolean, destination: TileIndex, destination_indices: TileIndex,
    source_left: TileIndex, source_right: TileIndex,
    left_indices: TileIndex, right_indices: TileIndex) => boolean
begin
    if destination == destination_indices then return FALSE; end;
    return TilePartialCoverageLegal(destination, source_left, source_right) &&
           TileDescriptorLegal(destination_indices) &&
           TileLogicalShapeMatch(destination_indices, destination) &&
           TileLogicalShapeMatch(left_indices, source_left) &&
           TileLogicalShapeMatch(right_indices, source_right) &&
           _Tiles[[destination]].data_type == _Tiles[[source_left]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_right]].data_type;
end;

pure func TileHistogramSourceDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U16 ||
           data_type == TileDataType_U32;
end;

pure func TileHistogramSelectedByteSupported(
    data_type: TileDataType,
    selected_byte: integer {0..3}) => boolean
begin
    if data_type == TileDataType_U16 then
        return selected_byte <= 1;
    end;
    return data_type == TileDataType_U32;
end;

readonly func TileHistogramPrefixDefined(
    filter: TileIndex,
    required_rows: integer {0..3}) => boolean
begin
    if required_rows == 0 then return TRUE; end;
    if _Tiles[[filter]].valid_rows < required_rows ||
       _Tiles[[filter]].valid_columns < 1 then
        return FALSE;
    end;
    for row = 0 to required_rows - 1 do
        if !TileElementDefined(
               filter,
               row as integer {0..65535},
               0) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func TileHistogramInputsLegal(
    source: TileIndex,
    filter: TileIndex,
    selected_byte: integer {0..3}) => boolean
begin
    if !TileSourceContentsDefined(source) ||
       !TileDescriptorLegal(filter) ||
       _Tiles[[source]].storage_kind != TileStorage_Numeric ||
       _Tiles[[filter]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source]].layout != TileLayout_RowMajor ||
       _Tiles[[filter]].data_type != TileDataType_U8 then
        return FALSE;
    end;

    let source_type = _Tiles[[source]].data_type;
    if !TileHistogramSelectedByteSupported(
           source_type,
           selected_byte) then
        return FALSE;
    end;
    if source_type == TileDataType_U16 then
        if selected_byte == 1 then return TRUE; end;
        if _Tiles[[filter]].valid_rows < _Tiles[[source]].valid_rows ||
           _Tiles[[filter]].valid_columns < 1 then
            return FALSE;
        end;
        for row = 0 to _Tiles[[source]].valid_rows - 1 looplimit 65536 do
            if !TileElementDefined(
                   filter,
                   row as integer {0..65535},
                   0) then
                return FALSE;
            end;
        end;
        return TRUE;
    elsif source_type == TileDataType_U32 then
        let required_rows: integer {0..3} = if selected_byte == 0 then 3
            else if selected_byte == 1 then 2
            else if selected_byte == 2 then 1
            else 0;
        return TileHistogramPrefixDefined(filter, required_rows);
    end;
    return FALSE;
end;

readonly func TileOperandsLegal_THISTOGRAM(
    destination: TileIndex, source: TileIndex, filter: TileIndex,
    selected_byte: integer {0..3}) => boolean
begin
    if destination == source || destination == filter ||
       !TileDescriptorLegal(destination) ||
       !TileHistogramInputsLegal(source, filter, selected_byte) then
        return FALSE;
    end;
    let result = _Tiles[[destination]];
    return result.storage_kind == TileStorage_Numeric &&
           result.data_type == TileDataType_U32 &&
           result.layout == TileLayout_RowMajor &&
           result.valid_rows == _Tiles[[source]].valid_rows &&
           result.valid_columns == 256 &&
           result.rows >= result.valid_rows &&
           result.columns >= 256;
end;

readonly func TileOperandsLegal_GMOV(
    destination: TileIndex, source: TileIndex, peer_tid: Word) => boolean
begin
    return UInt(peer_tid) < 4 &&
           TileDescriptorLegal(destination) &&
           TileSourceContentsDefined(source) &&
           TileLogicalShapeMatch(destination, source) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[source]].layout &&
           _Tiles[[destination]].location != TileLocation_Memory &&
           _Tiles[[destination]].location != TileLocation_Matrix &&
           _Tiles[[source]].location != TileLocation_Memory &&
           _Tiles[[source]].location != TileLocation_Matrix;
end;
