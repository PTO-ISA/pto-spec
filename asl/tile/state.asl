// PTO-REQ-TILE-001: 64 flat tile registers and TileInfo legality.

var _Tiles : array [[PTO_TILE_REGISTER_COUNT]] of TileInfo;

readonly func TileCapacityLimitBytes() => integer {0..262144}
begin
    assert UInt(_SystemRegisters.tile_capacity) <=
        PTO_MODEL_MAX_TILE_CAPACITY_BYTES;
    return UInt(_SystemRegisters.tile_capacity) as integer {0..262144};
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

readonly func TileCapacityInUse() => integer
begin
    var total: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[index]].allocated then
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

readonly func TileCapacityIsLegal(capacity_bytes: integer {0..262144}) => boolean
begin
    return capacity_bytes >= PTO_TILE_CELL_BYTES &&
           capacity_bytes MOD PTO_TILE_CELL_BYTES == 0 &&
           capacity_bytes <= TileCapacityLimitBytes();
end;

pure func TileSizeCodeIsLegal(size_code: integer {0..15}) => boolean
begin
    return 3 <= size_code && size_code <= 9;
end;

pure func TileSizeCodeBytes(size_code: integer {3..9})
    => integer {128,256,512,1024,2048,4096,8192}
begin
    case size_code of
        when 3 => return 128;
        when 4 => return 256;
        when 5 => return 512;
        when 6 => return 1024;
        when 7 => return 2048;
        when 8 => return 4096;
        when 9 => return 8192;
    end;
end;

pure func TileElementBits(data_type: TileDataType) => integer {4,8,16,32,64}
begin
    case data_type of
        when TileDataType_E2M1X2, TileDataType_E1M2X2,
             TileDataType_HiF4X2, TileDataType_S4X2,
             TileDataType_U4X2 => return 4;
        when TileDataType_S8, TileDataType_U8, TileDataType_HiF8,
             TileDataType_E4M3, TileDataType_E5M2, TileDataType_E3M2,
             TileDataType_E2M3, TileDataType_E8M0 => return 8;
        when TileDataType_S16, TileDataType_U16, TileDataType_FP16,
             TileDataType_BF16 => return 16;
        when TileDataType_S32, TileDataType_U32,
             TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32 => return 32;
        when TileDataType_S64, TileDataType_U64,
             TileDataType_FP64 => return 64;
    end;
end;

pure func TileDataTypeIsFourBit(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_E2M1X2 ||
           data_type == TileDataType_E1M2X2 ||
           data_type == TileDataType_HiF4X2 ||
           data_type == TileDataType_S4X2 ||
           data_type == TileDataType_U4X2;
end;

pure func TileStorageBytes(rows: integer {0..65535},
                           columns: integer {0..65535},
                           data_type: TileDataType) => integer
begin
    // Capacity accounting is bit-packed. In particular, two four-bit
    // elements occupy one byte and an odd final element rounds up.
    return ((rows * columns * TileElementBits(data_type)) + 7) DIVRM 8;
end;

pure func TileStorageFitsCapacity(rows: integer {0..65535},
                                  columns: integer {0..65535},
                                  data_type: TileDataType,
                                  capacity_bytes: integer {0..262144})
    => boolean
begin
    return TileStorageBytes(rows, columns, data_type) <= capacity_bytes;
end;

func ConfigureTile(index: TileIndex, capacity_bytes: integer {0..262144},
                   rows: integer {0..65535}, columns: integer {0..65535},
                   valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
                   data_type: TileDataType, layout: TileLayout, location: TileLocation)
begin
    assert TileCapacityIsLegal(capacity_bytes);
    assert rows > 0;
    assert columns > 0;
    assert valid_rows <= rows;
    assert valid_columns <= columns;
    assert TileStorageFitsCapacity(rows, columns, data_type, capacity_bytes);
    assert rows * columns <= PTO_MODEL_TILE_ELEMENTS;
    assert TileCapacityInUseExcept(index) + capacity_bytes <=
        TileCapacityLimitBytes();
    _Tiles[[index]].allocated = TRUE;
    // Allocation defines TileInfo but not the payload. A producer must write
    // the tile before any generic payload read is legal.
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = rows;
    _Tiles[[index]].columns = columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].data_type = data_type;
    _Tiles[[index]].layout = layout;
    _Tiles[[index]].location = location;
end;

func ReleaseTile(index: TileIndex)
begin
    _Tiles[[index]].allocated = FALSE;
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].capacity_bytes = 0;
    _Tiles[[index]].rows = 0;
    _Tiles[[index]].columns = 0;
    _Tiles[[index]].valid_rows = 0;
    _Tiles[[index]].valid_columns = 0;
    _Tiles[[index]].data_type = TileDataType_U8;
    _Tiles[[index]].layout = TileLayout_RowMajor;
    _Tiles[[index]].location = TileLocation_Any;
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
                    as integer {0..4096};
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
            as integer {0..4096};
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
