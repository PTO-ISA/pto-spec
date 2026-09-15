// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","surface":"tile","classification":["model","legality","indexed-layout"],"depends_on":["PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"]}
pure func IndexedTLSULayoutSupported(layout: TileLayout) => boolean
begin
    return layout == TileLayout_RowMajor ||
           layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32;
end;

pure func IndexedTLSUMemoryIndexDataTypeLegal(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S32 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
end;

pure func IndexedTLSUOrdinaryTransferDataTypeLegal(
    data_type: TileDataType) => boolean
begin
    return IndexedTLSUTransferDataTypeLegal(data_type) ||
           TileDataTypeIsFourBit(data_type);
end;

readonly func IndexedTLSUNumericDescriptorLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !IndexedTLSULayoutSupported(tile.layout) ||
       tile.storage_kind != TileStorage_Numeric then
        return FALSE;
    end;
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile) &&
               tile.rows == (if tile.layout == TileLayout_CUBE_M16 then
                   16 else 32);
    end;
    return TileDescriptorLegal(index) && tile.layout == TileLayout_RowMajor;
end;

readonly func IndexedTLSUNumericContentsDefined(index: TileIndex) => boolean
begin
    return IndexedTLSUNumericDescriptorLegal(index) &&
           _Tiles[[index]].contents_defined;
end;

pure func IndexedTLSUDataShapeMatchesIndex(
    data_valid_rows: integer {0..65535},
    data_valid_columns: integer {0..65535},
    index_valid_rows: integer {0..65535},
    index_valid_columns: integer {0..65535},
    data_type: TileDataType) => boolean
begin
    if data_valid_rows != index_valid_rows then return FALSE; end;
    if TileDataTypeIsFourBit(data_type) then
        return data_valid_columns MOD 2 == 0 &&
               data_valid_columns == 2 * index_valid_columns;
    end;
    return data_valid_columns == index_valid_columns;
end;

pure func IndexedTLSUPhysicalShapeLegal(
    layout: TileLayout, data_type: TileDataType,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    columns: integer {1..65535}) => boolean
begin
    if !IndexedTLSULayoutSupported(layout) then return FALSE; end;
    if layout == TileLayout_RowMajor then
        return valid_columns <= columns && IsNonzeroPowerOfTwo(columns);
    end;
    return TileCubeStorageRows(layout, valid_rows, data_type) ==
               (if layout == TileLayout_CUBE_M16 then 16 else 32) &&
           TileCubeStorageColumns(layout, valid_columns, data_type) == columns;
end;

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

readonly func TileOperandsLegal_GMOV(
    destination: TileIndex, source: TileIndex, peer_tid: Word) => boolean
begin
    return UInt(peer_tid) < 4 &&
           TileElementwiseDescriptorLegal(destination) &&
           TileElementwiseSourceContentsDefined(source) &&
           TileElementwiseShapeMatch(destination, source) &&
           TileElementwiseLayoutSupported(_Tiles[[source]].layout) &&
           TileElementwiseLayoutSupported(_Tiles[[destination]].layout) &&
           TileCarrierOrPackedBaselineDataTypeSupported(
               _Tiles[[source]].data_type) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[source]].layout;
end;
