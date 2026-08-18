// PTO-UNIT: {"id":"PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","surface":"tile","classification":["model","definedness","elements"],"depends_on":["PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES","PTO-TILE-MODEL-STATE-ALLOCATION"]}
pure func TileFractalInnerElements(
    data_type: TileDataType) => integer {4,8,16,32,64}
begin
    // PTO fractals contain 16 rows by 32 bytes.  Packed X2 formats therefore
    // carry 64 independently addressed logical nibbles in each fractal row.
    return (256 DIV TileElementBits(data_type))
        as integer {4,8,16,32,64};
end;

readonly func TileLayoutShapeLegal(tile: TileInfo) => boolean
begin
    if tile.layout == TileLayout_ImplementationDefined then return FALSE; end;
    if tile.layout == TileLayout_RowMajor ||
       tile.layout == TileLayout_ColumnMajor then
        return TRUE;
    end;
    let inner_elements = TileFractalInnerElements(tile.data_type);
    return tile.rows MOD 16 == 0 &&
           tile.columns MOD inner_elements == 0;
end;

readonly func TileGenericIndexingPermitted(tile: TileInfo) => boolean
begin
    return TileLayoutShapeLegal(tile);
end;

readonly func TileLinearIndex(tile: TileInfo, row: integer {0..65535},
                     column: integer {0..65535}) => ModelTileElementIndex
begin
    assert row < tile.rows;
    assert column < tile.columns;
    assert TileGenericIndexingPermitted(tile);
    var index: integer = 0;
    if tile.layout == TileLayout_RowMajor then
        index = row * tile.columns + column;
    elsif tile.layout == TileLayout_ColumnMajor then
        index = column * tile.rows + row;
    else
        let inner_elements = TileFractalInnerElements(tile.data_type);
        let block_rows: integer {0..65535} =
            (tile.rows DIVRM 16) as integer {0..65535};
        let block_columns: integer {0..65535} =
            (tile.columns DIVRM inner_elements) as integer {0..65535};
        let block_row: integer {0..65535} =
            (row DIVRM 16) as integer {0..65535};
        let block_column: integer {0..65535} =
            (column DIVRM inner_elements) as integer {0..65535};
        let inner_row: integer {0..15} =
            (row MOD 16) as integer {0..15};
        let inner_column: integer {0..63} =
            (column MOD inner_elements) as integer {0..63};
        let block_elements: integer {64..1024} =
            (16 * inner_elements) as integer {64..1024};
        if tile.layout == TileLayout_ZN then
            index = (block_row * block_columns + block_column) *
                    block_elements + inner_column * 16 + inner_row;
        else
            assert tile.layout == TileLayout_NZ;
            index = (block_column * block_rows + block_row) *
                    block_elements + inner_row * inner_elements +
                    inner_column;
        end;
    end;
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

pure func TileDataTypeIsUnsignedInteger(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U8 || data_type == TileDataType_U16 ||
           data_type == TileDataType_U32 || data_type == TileDataType_U64 ||
           data_type == TileDataType_U4X2;
end;

pure func TileDataTypeIsInteger(data_type: TileDataType) => boolean
begin
    return TileDataTypeIsSigned(data_type) ||
           TileDataTypeIsUnsignedInteger(data_type);
end;

pure func IndexedTLSUTransferDataTypeLegal(
    data_type: TileDataType) => boolean
begin
    // Indexed TLSU addresses are byte displacements. A packed four-bit
    // transfer would additionally need a low/high-nibble selector, which the
    // block schema does not encode. IndexTile legality is governed separately
    // by IndexedTLSUIndexDataTypeLegal.
    return !TileDataTypeIsFourBit(data_type);
end;

pure func IndexedTLSUIndexDataTypeLegal(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S32 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
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
    if TileDataTypeIsSigned(data_type) then return TileDataType_S32; end;
    if TileDataTypeIsUnsignedInteger(data_type) then
        return TileDataType_U32;
    end;
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
            when TileDataType_FP64 =>
                return Zeros{PTO_XLEN} + 0x7fefffffffffffff;
            when TileDataType_FP32 =>
                return Zeros{PTO_XLEN} + 0x7f7fffff;
            when TileDataType_TF32 =>
                return Zeros{PTO_XLEN} + 0x7f7fe000;
            when TileDataType_HF32 =>
                return Zeros{PTO_XLEN} + 0x7f7ff000;
            when TileDataType_FP16 =>
                return Zeros{PTO_XLEN} + 0x7bff;
            when TileDataType_BF16 =>
                return Zeros{PTO_XLEN} + 0x7f7f;
            when TileDataType_E4M3 =>
                return Zeros{PTO_XLEN} + 0x7e;
            when TileDataType_E5M2 =>
                return Zeros{PTO_XLEN} + 0x7b;
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
        when TileDataType_FP64 =>
            return Zeros{PTO_XLEN} + 0xffefffffffffffff;
        when TileDataType_FP32 =>
            return Zeros{PTO_XLEN} + 0xff7fffff;
        when TileDataType_TF32 =>
            return Zeros{PTO_XLEN} + 0xff7fe000;
        when TileDataType_HF32 =>
            return Zeros{PTO_XLEN} + 0xff7ff000;
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} + 0xfbff;
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} + 0xff7f;
        when TileDataType_E4M3 =>
            return Zeros{PTO_XLEN} + 0xfe;
        when TileDataType_E5M2 =>
            return Zeros{PTO_XLEN} + 0xfb;
        when TileDataType_U8, TileDataType_U16, TileDataType_U32,
             TileDataType_U64, TileDataType_U4X2 => return Zeros{PTO_XLEN};
        when TileDataType_S8 => return Zeros{PTO_XLEN} + 0x80;
        when TileDataType_S16 => return Zeros{PTO_XLEN} + 0x8000;
        when TileDataType_S32 => return Zeros{PTO_XLEN} + 0x80000000;
        when TileDataType_S64 => return Zeros{PTO_XLEN} + 0x8000000000000000;
        otherwise => return Zeros{PTO_XLEN} + 0x8000000000000000;
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

readonly func TilePredicateValuesLegal(index: TileIndex) => boolean
begin
    return TileSourceContentsDefined(index) &&
           _Tiles[[index]].storage_kind == TileStorage_Predicate;
end;

readonly func TilePredicateLogicalIndex(
    tile: TileInfo,
    row: integer {0..65535},
    column: integer {0..65535}) => integer {0..16383}
begin
    assert tile.storage_kind == TileStorage_Predicate;
    assert row < tile.rows && column < tile.columns;
    return (row * tile.columns + column) as integer {0..16383};
end;

pure func TilePredicateByteIndex(
    logical_index: integer {0..16383}) => integer {0..2047}
begin
    return (logical_index DIVRM 8) as integer {0..2047};
end;

pure func TilePredicateBitIndex(
    logical_index: integer {0..16383}) => integer {0..7}
begin
    return (logical_index MOD 8) as integer {0..7};
end;

readonly func TilePredicateBitFromInfo(
    tile: TileInfo,
    row: integer {0..65535},
    column: integer {0..65535}) => boolean
begin
    let logical = TilePredicateLogicalIndex(tile, row, column);
    let byte_index = TilePredicateByteIndex(logical);
    let bit_index = TilePredicateBitIndex(logical);
    return tile.payload[[byte_index]][bit_index] == '1';
end;

func TileInfoWithPredicateBit(
    tile: TileInfo,
    row: integer {0..65535},
    column: integer {0..65535},
    value: boolean) => TileInfo
begin
    var result = tile;
    let logical = TilePredicateLogicalIndex(result, row, column);
    let byte_index = TilePredicateByteIndex(logical);
    let bit_index = TilePredicateBitIndex(logical);
    result.payload[[byte_index]][bit_index] = if value then '1' else '0';
    if result.defined_elements[logical] == '0' then
        result.defined_elements[logical] = '1';
        result.defined_valid_elements =
            (result.defined_valid_elements + 1) as integer {0..16384};
    end;
    result.contents_defined = result.defined_valid_elements ==
        result.valid_rows * result.valid_columns;
    return result;
end;

func WriteTilePredicateBit(
    index: TileIndex,
    row: integer {0..65535},
    column: integer {0..65535},
    value: boolean)
begin
    assert row < _Tiles[[index]].valid_rows;
    assert column < _Tiles[[index]].valid_columns;
    _Tiles[[index]] = TileInfoWithPredicateBit(
        _Tiles[[index]], row, column, value);
end;

readonly func TilePredicateBitDefined(
    index: TileIndex,
    row: integer {0..65535},
    column: integer {0..65535}) => boolean
begin
    let logical = TilePredicateLogicalIndex(_Tiles[[index]], row, column);
    return _Tiles[[index]].defined_elements[logical] == '1';
end;

readonly func ReadTilePredicateBit(
    index: TileIndex,
    row: integer {0..65535},
    column: integer {0..65535}) => boolean
begin
    assert TilePredicateBitDefined(index, row, column);
    return TilePredicateBitFromInfo(_Tiles[[index]], row, column);
end;

readonly func ReadTilePredicateByte(
    index: TileIndex,
    byte_index: integer {0..2047}) => bits(8)
begin
    assert _Tiles[[index]].storage_kind == TileStorage_Predicate;
    return _Tiles[[index]].payload[[byte_index]][7:0];
end;

func PredicateTileWithPadding(
    tile: TileInfo,
    pad_value: TilePadValue) => TileInfo
begin
    var result = tile;
    assert result.storage_kind == TileStorage_Predicate;
    let padding_defined = pad_value != TilePad_Null;
    let padding_value = pad_value == TilePad_Max;
    for row = 0 to result.rows - 1 looplimit 65536 do
        for column = 0 to result.columns - 1 looplimit 65536 do
            if row >= result.valid_rows || column >= result.valid_columns then
                let logical = TilePredicateLogicalIndex(
                    result,
                    row as integer {0..65535},
                    column as integer {0..65535});
                let byte_index = TilePredicateByteIndex(logical);
                let bit_index = TilePredicateBitIndex(logical);
                result.payload[[byte_index]][bit_index] =
                    if padding_value then '1' else '0';
                result.defined_elements[logical] =
                    if padding_defined then '1' else '0';
            end;
        end;
    end;
    return result;
end;

func ApplyPredicateTilePadding(index: TileIndex, pad_value: TilePadValue)
begin
    _Tiles[[index]] = PredicateTileWithPadding(
        _Tiles[[index]], pad_value);
end;

readonly func TileSourceEncodingsValid(index: TileIndex) => boolean
begin
    if !TileSourceContentsDefined(index) ||
       !TileGenericIndexingPermitted(_Tiles[[index]]) then
        return FALSE;
    end;

    let tile = _Tiles[[index]];
    let payload = tile.payload;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(
                tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if !TileNumericEncodingValid(
                tile.data_type,
                payload[[element]]) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
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

func TileWithValidRegionDefined(tile: TileInfo) => TileInfo
begin
    var result = tile;
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            result.defined_elements[element] = '1';
        end;
    end;
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns)
            as integer {0..16384};
    result.contents_defined = TRUE;
    return result;
end;

func MarkTileValidRegionDefined(index: TileIndex)
begin
    _Tiles[[index]] = TileWithValidRegionDefined(_Tiles[[index]]);
end;

func TileWithPadding(tile: TileInfo, pad_value: TilePadValue) => TileInfo
begin
    var result = tile;
    let padding_defined = pad_value != TilePad_Null;
    let padding = TilePadValueForDataType(pad_value, result.data_type);
    for row = 0 to result.rows - 1 looplimit 65536 do
        for column = 0 to result.columns - 1 looplimit 65536 do
            if row >= result.valid_rows || column >= result.valid_columns then
                let element = TileLinearIndex(result,
                    row as integer {0..65535},
                    column as integer {0..65535});
                result.payload[[element]] = padding;
                result.defined_elements[element] =
                    if padding_defined then '1' else '0';
            end;
        end;
    end;
    return result;
end;

func ApplyTilePadding(index: TileIndex, pad_value: TilePadValue)
begin
    _Tiles[[index]] = TileWithPadding(_Tiles[[index]], pad_value);
end;

func MarkTilePhysicalRegionDefined(index: TileIndex)
begin
    let tile = _Tiles[[index]];
    for row = 0 to tile.rows - 1 looplimit 65536 do
        for column = 0 to tile.columns - 1 looplimit 65536 do
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
           left.storage_kind == right.storage_kind &&
           left.data_type == right.data_type;
end;
