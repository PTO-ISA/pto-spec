// PTO-UNIT: {"id":"PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","surface":"tile","classification":["model","definedness","elements"],"depends_on":["PTO-TILE-MODEL-STATE-ALLOCATION"]}
readonly func TileGenericIndexingPermitted(tile: TileInfo) => boolean
begin
    return tile.layout != TileLayout_ImplementationDefined;
end;

readonly func TileLinearIndex(tile: TileInfo, row: integer {0..65535},
                     column: integer {0..65535}) => ModelTileElementIndex
begin
    assert row < tile.rows;
    assert column < tile.columns;
    // An implementation-defined layout is a legal configured descriptor, but
    // portable row/column indexing cannot interpret it.
    assert TileGenericIndexingPermitted(tile);
    let index: integer = if TileLayoutIsCube(tile.layout) then
        TileCubePayloadIndex(tile.layout, tile.data_type,
            tile.cube_k_repeat, row, column)
    else if tile.layout == TileLayout_RowMajor then
        row * tile.columns + column else column * tile.rows + row;
    assert index < PTO_MODEL_TILE_ELEMENTS;
    return index as ModelTileElementIndex;
end;

pure func TileElementBytes(data_type: TileDataType) => integer {1,2,4,8}
begin
    case data_type of
        when TileDataType_S8, TileDataType_U8, TileDataType_HiF8,
             TileDataType_E4M3, TileDataType_E5M2, TileDataType_E3M2,
             TileDataType_E2M3, TileDataType_E2M1X2,
             TileDataType_E1M2X2, TileDataType_E8M0,
             TileDataType_HiF4X2, TileDataType_S4X2,
             TileDataType_U4X2 => return 1;
        when TileDataType_S16, TileDataType_U16,
             TileDataType_FP16, TileDataType_BF16 => return 2;
        when TileDataType_S32, TileDataType_U32, TileDataType_FP32,
             TileDataType_TF32, TileDataType_HF32 => return 4;
        when TileDataType_S64, TileDataType_U64,
             TileDataType_FP64 => return 8;
    end;
end;

pure func TileDataTypeIsSigned(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S8 || data_type == TileDataType_S16 ||
           data_type == TileDataType_S32 || data_type == TileDataType_S64 ||
           data_type == TileDataType_S4X2;
end;

pure func TileDataTypeIsFloating(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP64 ||
           data_type == TileDataType_FP32 || data_type == TileDataType_TF32 ||
           data_type == TileDataType_HF32 || data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 || data_type == TileDataType_HiF8 ||
           data_type == TileDataType_E4M3 || data_type == TileDataType_E5M2 ||
           data_type == TileDataType_E3M2 || data_type == TileDataType_E2M3 ||
           data_type == TileDataType_E2M1X2 ||
           data_type == TileDataType_E1M2X2 ||
           data_type == TileDataType_E8M0 ||
           data_type == TileDataType_HiF4X2;
end;

pure func TileMatrixAccumulatorDataType(data_type: TileDataType) => TileDataType
begin
    if data_type == TileDataType_FP64 then return TileDataType_FP64; end;
    if TileDataTypeIsSigned(data_type) then return TileDataType_S64; end;
    if data_type == TileDataType_U64 || data_type == TileDataType_U32 ||
       data_type == TileDataType_U16 || data_type == TileDataType_U8 ||
       data_type == TileDataType_U4X2 then return TileDataType_U64; end;
    return TileDataType_FP32;
end;

pure func TilePadValueForDataType(pad_value: TilePadValue,
                                  data_type: TileDataType) => Word
begin
    if pad_value == TilePad_Zero || pad_value == TilePad_Null then
        return Zeros{PTO_XLEN};
    end;
    if pad_value == TilePad_Max then
        case data_type of
            when TileDataType_U8 => return Zeros{PTO_XLEN} + 0xff;
            when TileDataType_U16 => return Zeros{PTO_XLEN} + 0xffff;
            when TileDataType_U32 => return Zeros{PTO_XLEN} + 0xffffffff;
            when TileDataType_U64 => return Ones{PTO_XLEN};
            when TileDataType_S8 => return Zeros{PTO_XLEN} + 0x7f;
            when TileDataType_S16 => return Zeros{PTO_XLEN} + 0x7fff;
            when TileDataType_S32 => return Zeros{PTO_XLEN} + 0x7fffffff;
            when TileDataType_S64 =>
                return Zeros{PTO_XLEN} + 0x7fffffffffffffff;
            otherwise => return Ones{PTO_XLEN};
        end;
    end;
    case data_type of
        when TileDataType_U8, TileDataType_U16, TileDataType_U32,
             TileDataType_U64, TileDataType_U4X2 => return Zeros{PTO_XLEN};
        when TileDataType_S8 => return Zeros{PTO_XLEN} + 0x80;
        when TileDataType_S16 => return Zeros{PTO_XLEN} + 0x8000;
        when TileDataType_S32 => return Zeros{PTO_XLEN} + 0x80000000;
        when TileDataType_S64 => return Zeros{PTO_XLEN} + 0x8000000000000000;
        otherwise => return Zeros{PTO_XLEN} + 0x8000000000000000;
    end;
end;

pure func TileDataTypeEncodingValid(encoded: Word) => boolean
begin
    let code = UInt(encoded[5:0]);
    return (0 <= code && code <= 14) ||
           (16 <= code && code <= 20) || (24 <= code && code <= 28);
end;

pure func TileDataTypeFromEncoding(encoded: Word) => TileDataType
begin
    case UInt(encoded[5:0]) of
        when 0 => return TileDataType_FP64;
        when 1 => return TileDataType_FP32;
        when 2 => return TileDataType_TF32;
        when 3 => return TileDataType_HF32;
        when 4 => return TileDataType_FP16;
        when 5 => return TileDataType_BF16;
        when 6 => return TileDataType_HiF8;
        when 7 => return TileDataType_E4M3;
        when 8 => return TileDataType_E5M2;
        when 9 => return TileDataType_E3M2;
        when 10 => return TileDataType_E2M3;
        when 11 => return TileDataType_E2M1X2;
        when 12 => return TileDataType_E1M2X2;
        when 13 => return TileDataType_E8M0;
        when 14 => return TileDataType_HiF4X2;
        when 16 => return TileDataType_S64;
        when 17 => return TileDataType_S32;
        when 18 => return TileDataType_S16;
        when 19 => return TileDataType_S8;
        when 20 => return TileDataType_S4X2;
        when 24 => return TileDataType_U64;
        when 25 => return TileDataType_U32;
        when 26 => return TileDataType_U16;
        when 27 => return TileDataType_U8;
        when 28 => return TileDataType_U4X2;
        otherwise => return TileDataType_U8;
    end;
end;

readonly func ReadTileElement(index: TileIndex, row: integer {0..65535},
                     column: integer {0..65535}) => Word
begin
    let element = TileLinearIndex(_Tiles[[index]], row, column);
    assert _Tiles[[index]].defined_elements[element] == '1';
    return _Tiles[[index]].payload[[element]];
end;

readonly func TileElementDefined(index: TileIndex,
                                 row: integer {0..65535},
                                 column: integer {0..65535}) => boolean
begin
    let element = TileLinearIndex(_Tiles[[index]], row, column);
    return _Tiles[[index]].defined_elements[element] == '1';
end;

func WriteTileElement(index: TileIndex, row: integer {0..65535},
                      column: integer {0..65535}, value: Word)
begin
    let element = TileLinearIndex(_Tiles[[index]], row, column);
    _Tiles[[index]].payload[[element]] = value;
    if _Tiles[[index]].defined_elements[element] == '0' then
        _Tiles[[index]].defined_elements[element] = '1';
        if row < _Tiles[[index]].valid_rows &&
           column < _Tiles[[index]].valid_columns then
            assert _Tiles[[index]].defined_valid_elements <
                PTO_MODEL_TILE_ELEMENTS;
            _Tiles[[index]].defined_valid_elements =
                (_Tiles[[index]].defined_valid_elements + 1)
                    as integer {0..16384};
        end;
    end;
    _Tiles[[index]].contents_defined =
        _Tiles[[index]].defined_valid_elements ==
            _Tiles[[index]].valid_rows * _Tiles[[index]].valid_columns;
end;

func MarkTileValidRegionDefined(index: TileIndex)
begin
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            _Tiles[[index]].defined_elements[element] = '1';
        end;
    end;
    _Tiles[[index]].defined_valid_elements =
        (tile.valid_rows * tile.valid_columns)
            as integer {0..16384};
    _Tiles[[index]].contents_defined = TRUE;
end;

readonly func TileShapesMatch(left: TileInfo, right: TileInfo) => boolean
begin
    return left.rows == right.rows &&
           left.columns == right.columns &&
           left.valid_rows == right.valid_rows &&
           left.valid_columns == right.valid_columns &&
           left.storage_rows == right.storage_rows &&
           left.storage_columns == right.storage_columns &&
           left.storage_bytes == right.storage_bytes &&
           left.cube_k_repeat == right.cube_k_repeat &&
           left.cube_n_repeat == right.cube_n_repeat &&
           left.cube_cell_count == right.cube_cell_count &&
           left.data_type == right.data_type;
end;
