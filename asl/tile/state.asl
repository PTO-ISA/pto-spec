// PTO-REQ-TILE-001: 64 flat tile registers and descriptor legality.

var _Tiles : array [[PTO_TILE_REGISTER_COUNT]] of TileState;
var _Pipes : array [[PTO_PIPE_COUNT]] of PipeState;

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

pure func TileCapacityIsLegal(capacity_bytes: integer {0..524288}) => boolean
begin
    return capacity_bytes == 0 ||
           (capacity_bytes >= 256 && capacity_bytes <= 262144);
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
    assert TileCapacityInUseExcept(index) + capacity_bytes <= 524288;
    _Tiles[[index]].allocated = capacity_bytes != 0;
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = rows;
    _Tiles[[index]].columns = columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].data_type = data_type;
    _Tiles[[index]].layout = layout;
    _Tiles[[index]].location = location;
end;

readonly func TileLinearIndex(tile: TileState, row: integer {0..65535},
                     column: integer {0..65535}) => ModelTileElementIndex
begin
    assert row < tile.rows;
    assert column < tile.columns;
    assert tile.layout != TileLayout_ImplementationDefined;
    let index: integer = if tile.layout == TileLayout_RowMajor then
        row * tile.columns + column else column * tile.rows + row;
    assert index < PTO_MODEL_TILE_ELEMENTS;
    return index as ModelTileElementIndex;
end;

pure func TileElementBytes(data_type: TileDataType) => integer {1,2,4,8}
begin
    case data_type of
        when TileDataType_S8, TileDataType_U8, TileDataType_FP8,
             TileDataType_FP4, TileDataType_E8M0 => return 1;
        when TileDataType_S16, TileDataType_U16, TileDataType_F16, TileDataType_BF16 => return 2;
        when TileDataType_S32, TileDataType_U32, TileDataType_F32 => return 4;
        when TileDataType_S64, TileDataType_U64 => return 8;
    end;
end;

pure func TileDataTypeIsSigned(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S8 || data_type == TileDataType_S16 ||
           data_type == TileDataType_S32 || data_type == TileDataType_S64;
end;

pure func TileDataTypeIsFloating(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_F16 || data_type == TileDataType_BF16 ||
           data_type == TileDataType_F32 || data_type == TileDataType_FP8 ||
           data_type == TileDataType_FP4 || data_type == TileDataType_E8M0;
end;

readonly func ReadTileElement(index: TileIndex, row: integer {0..65535},
                     column: integer {0..65535}) => Word
begin
    let element = TileLinearIndex(_Tiles[[index]], row, column);
    return _Tiles[[index]].payload[[element]];
end;

func WriteTileElement(index: TileIndex, row: integer {0..65535},
                      column: integer {0..65535}, value: Word)
begin
    let element = TileLinearIndex(_Tiles[[index]], row, column);
    _Tiles[[index]].payload[[element]] = value;
end;

readonly func TileShapesMatch(left: TileState, right: TileState) => boolean
begin
    return left.rows == right.rows &&
           left.columns == right.columns &&
           left.valid_rows == right.valid_rows &&
           left.valid_columns == right.valid_columns &&
           left.data_type == right.data_type;
end;
