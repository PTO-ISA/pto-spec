// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","surface":"tile","classification":["model","legality","indexed-layout"],"depends_on":["PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"]}
readonly func TileOperandsLegal_TFMA(
    destination: TileIndex, source_left: TileIndex,
    source_right: TileIndex, addend: TileIndex) => boolean
begin
    return TileElementwiseDescriptorLegal(destination) &&
           TileElementwiseSourceContentsDefined(source_left) &&
           TileElementwiseSourceContentsDefined(source_right) &&
           TileElementwiseSourceContentsDefined(addend) &&
           TileFusedMultiplyAddDataTypeSupported(
               _Tiles[[destination]].data_type) &&
           TileElementwiseShapeAndTypeMatch(destination, source_left) &&
           TileElementwiseShapeAndTypeMatch(destination, source_right) &&
           TileElementwiseShapeAndTypeMatch(destination, addend) &&
           _Tiles[[destination]].data_type == _Tiles[[source_left]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_right]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[addend]].data_type &&
           TileElementwiseLayoutSupported(_Tiles[[destination]].layout) &&
           (!TileDataTypeIsFloating(_Tiles[[destination]].data_type) ||
            (TileElementwiseSourceEncodingsValid(source_left) &&
             TileElementwiseSourceEncodingsValid(source_right) &&
             TileElementwiseSourceEncodingsValid(addend)));
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
           TileCarrierOrPackedBaselineDataTypeSupported(
               _Tiles[[source]].data_type) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[source]].layout &&
           _Tiles[[destination]].location != TileLocation_Memory &&
           _Tiles[[destination]].location != TileLocation_Matrix &&
           _Tiles[[source]].location != TileLocation_Memory &&
           _Tiles[[source]].location != TileLocation_Matrix;
end;
