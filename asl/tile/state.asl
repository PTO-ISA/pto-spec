// PTO-REQ-TILE-001: 64 flat tile registers and TileInfo legality.

var _Tiles : array [[PTO_TILE_REGISTER_COUNT]] of TileInfo;

readonly func TileCapacityLimitBytes() => integer {0..524288}
begin
    assert UInt(_SystemRegisters.tile_capacity) <=
        PTO_MODEL_MAX_TILE_CAPACITY_BYTES;
    return UInt(_SystemRegisters.tile_capacity) as integer {0..524288};
end;

readonly func TileCapacityInUseExcept(excluded: TileIndex) => integer
begin
    var total: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if index != excluded && _Tiles[[index]].allocated then
            total = total + _Tiles[[index]].capacity_bytes;
        end;
    end;
    return total;
end;

pure func TileHandOf(index: TileIndex) => TileHand
begin
    if index < 16 then return TileHand_T;
    elsif index < 32 then return TileHand_U;
    elsif index < 48 then return TileHand_M;
    else return TileHand_N;
    end;
end;

pure func TileIndexWithinHand(index: TileIndex) => integer {1..16}
begin
    return ((index MOD 16) + 1) as integer {1..16};
end;

readonly func TileCapacityIsLegal(capacity_bytes: integer {0..524288}) => boolean
begin
    return capacity_bytes == 0 ||
           (capacity_bytes >= 256 &&
            capacity_bytes <= TileCapacityLimitBytes());
end;

func ConfigureTile(index: TileIndex, capacity_bytes: integer {0..524288},
                   rows: integer {0..65535}, columns: integer {0..65535},
                   valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
                   data_type: TileDataType, layout: TileLayout, location: TileLocation)
begin
    assert TileCapacityIsLegal(capacity_bytes);
    assert valid_rows <= rows;
    assert valid_columns <= columns;
    assert rows * columns <= PTO_MODEL_TILE_ELEMENTS;
    assert TileCapacityInUseExcept(index) + capacity_bytes <=
        TileCapacityLimitBytes();
    _Tiles[[index]].allocated = capacity_bytes != 0;
    // Allocation defines TileInfo but not the payload. A producer must write
    // the tile before any generic payload read is legal.
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = rows;
    _Tiles[[index]].columns = columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].data_type = data_type;
    _Tiles[[index]].layout = layout;
    _Tiles[[index]].location = location;
end;

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
    let index: integer = if tile.layout == TileLayout_RowMajor then
        row * tile.columns + column else column * tile.rows + row;
    assert index < PTO_MODEL_TILE_ELEMENTS;
    return index as ModelTileElementIndex;
end;

pure func TileElementBytes(data_type: TileDataType) => integer {1,2,4,8}
begin
    case data_type of
        when TileDataType_S8, TileDataType_U8, TileDataType_FP8,
             TileDataType_FPL8, TileDataType_FP4, TileDataType_FPL4,
             TileDataType_S4, TileDataType_U4, TileDataType_E8M0 => return 1;
        when TileDataType_S16, TileDataType_U16, TileDataType_F16, TileDataType_BF16 => return 2;
        when TileDataType_S32, TileDataType_U32, TileDataType_F32 => return 4;
        when TileDataType_S64, TileDataType_U64, TileDataType_F64 => return 8;
    end;
end;

pure func TileDataTypeIsSigned(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S8 || data_type == TileDataType_S16 ||
           data_type == TileDataType_S32 || data_type == TileDataType_S64 ||
           data_type == TileDataType_S4;
end;

pure func TileDataTypeIsFloating(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_F64 ||
           data_type == TileDataType_F16 || data_type == TileDataType_BF16 ||
           data_type == TileDataType_F32 || data_type == TileDataType_FP8 ||
           data_type == TileDataType_FPL8 || data_type == TileDataType_FP4 ||
           data_type == TileDataType_FPL4 || data_type == TileDataType_E8M0;
end;

pure func TileDataTypeEncodingValid(encoded: Word) => boolean
begin
    let code = UInt(encoded[5:0]);
    return code == 0 || code == 1 || code == 2 || code == 3 ||
           code == 6 || code == 7 || code == 11 || code == 12 ||
           (16 <= code && code <= 20) || (24 <= code && code <= 28);
end;

pure func TileDataTypeFromEncoding(encoded: Word) => TileDataType
begin
    case UInt(encoded[5:0]) of
        when 0 => return TileDataType_F64;
        when 1 => return TileDataType_F32;
        when 2 => return TileDataType_F16;
        when 3 => return TileDataType_FP8;
        when 6 => return TileDataType_BF16;
        when 7 => return TileDataType_FPL8;
        when 11 => return TileDataType_FP4;
        when 12 => return TileDataType_FPL4;
        when 16 => return TileDataType_S64;
        when 17 => return TileDataType_S32;
        when 18 => return TileDataType_S16;
        when 19 => return TileDataType_S8;
        when 20 => return TileDataType_S4;
        when 24 => return TileDataType_U64;
        when 25 => return TileDataType_U32;
        when 26 => return TileDataType_U16;
        when 27 => return TileDataType_U8;
        when 28 => return TileDataType_U4;
        otherwise => return TileDataType_U8;
    end;
end;

readonly func ReadTileElement(index: TileIndex, row: integer {0..65535},
                     column: integer {0..65535}) => Word
begin
    assert _Tiles[[index]].contents_defined;
    let element = TileLinearIndex(_Tiles[[index]], row, column);
    return _Tiles[[index]].payload[[element]];
end;

func WriteTileElement(index: TileIndex, row: integer {0..65535},
                      column: integer {0..65535}, value: Word)
begin
    let element = TileLinearIndex(_Tiles[[index]], row, column);
    _Tiles[[index]].payload[[element]] = value;
    _Tiles[[index]].contents_defined = TRUE;
end;

readonly func TileShapesMatch(left: TileInfo, right: TileInfo) => boolean
begin
    return left.rows == right.rows &&
           left.columns == right.columns &&
           left.valid_rows == right.valid_rows &&
           left.valid_columns == right.valid_columns &&
           left.data_type == right.data_type;
end;
