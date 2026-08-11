// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","surface":"tile","classification":["model","legality","matrix-shape"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA"]}
readonly func TileMatrixShapeLegal(left: TileIndex,
                                   right: TileIndex) => boolean
begin
    return BundleTileOperationSelected() &&
           TileSourceContentsDefined(left) &&
           TileSourceContentsDefined(right) &&
           IsNonzeroPowerOfTwo(_Tiles[[left]].valid_rows) &&
           IsNonzeroPowerOfTwo(_Tiles[[left]].valid_columns) &&
           IsNonzeroPowerOfTwo(_Tiles[[right]].valid_rows) &&
           IsNonzeroPowerOfTwo(_Tiles[[right]].valid_columns) &&
           _Tiles[[left]].valid_columns == _Tiles[[right]].valid_rows &&
           _Tiles[[left]].valid_rows * _Tiles[[right]].valid_columns <=
               PTO_MODEL_TILE_ELEMENTS;
end;

readonly func TileInfoDescriptorLegal(tile: TileInfo) => boolean
begin
    return tile.allocated && tile.contents_defined &&
           TileCapacityIsLegal(tile.capacity_bytes) &&
           TileShapeMatchesCapacity(tile.capacity_bytes, tile.rows,
               tile.columns, tile.data_type) &&
           tile.valid_rows <= tile.rows &&
           tile.valid_columns <= tile.columns &&
           tile.rows * tile.columns <= PTO_MODEL_TILE_ELEMENTS &&
           TileGenericIndexingPermitted(tile);
end;

readonly func TileMatrixInfoShapeLegal(left: TileInfo,
                                       right: TileInfo) => boolean
begin
    return BundleTileOperationSelected() &&
           TileInfoDescriptorLegal(left) && TileInfoDescriptorLegal(right) &&
           IsNonzeroPowerOfTwo(left.valid_rows) &&
           IsNonzeroPowerOfTwo(left.valid_columns) &&
           IsNonzeroPowerOfTwo(right.valid_rows) &&
           IsNonzeroPowerOfTwo(right.valid_columns) &&
           left.valid_columns == right.valid_rows &&
           left.valid_rows * right.valid_columns <= PTO_MODEL_TILE_ELEMENTS;
end;

readonly func TileOrdinaryMatrixInfosLegal(left: TileInfo,
                                           right: TileInfo) => boolean
begin
    if !TileMatrixInfoShapeLegal(left, right) then return FALSE; end;
    let selected_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    return selected_type != TileDataType_E8M0 &&
           left.data_type == selected_type &&
           right.data_type == selected_type;
end;

readonly func TileMatrixInfoDestinationLegal(destination: TileIndex,
                                              left: TileInfo,
                                              right: TileInfo) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileMatrixInfoShapeLegal(left, right) then return FALSE; end;
    let selected_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    let accumulator_type = TileMatrixAccumulatorDataType(selected_type);
    let expected_destination_type = if _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0 then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else accumulator_type;
    return _Tiles[[destination]].valid_rows == left.valid_rows &&
           _Tiles[[destination]].valid_columns == right.valid_columns &&
           _Tiles[[destination]].data_type == expected_destination_type;
end;

readonly func TileMatrixInfoBiasLegal(left: TileInfo, right: TileInfo,
                                      bias: TileIndex,
                                      mx: boolean) => boolean
begin
    if !TileSourceContentsDefined(bias) ||
       !(_Tiles[[bias]].valid_rows == 1 ||
         _Tiles[[bias]].valid_rows == left.valid_rows) ||
       !(_Tiles[[bias]].valid_columns == 1 ||
         _Tiles[[bias]].valid_columns == right.valid_columns) then
        return FALSE;
    end;
    let selected_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    return _Tiles[[bias]].data_type ==
        (if mx then TileDataType_FP32 else selected_type);
end;

readonly func TileMatrixInfoAccumulatorLegal(destination: TileIndex,
                                               accumulator: TileIndex,
                                               left: TileInfo,
                                               right: TileInfo) => boolean
begin
    return TileSourceContentsDefined(accumulator) &&
           TileMatrixInfoDestinationLegal(accumulator, left, right) &&
           _Tiles[[accumulator]].layout == _Tiles[[destination]].layout &&
           _Tiles[[accumulator]].capacity_bytes ==
               _Tiles[[destination]].capacity_bytes;
end;

readonly func TileMatrixInfoScalesLegal(left: TileInfo,
                                         left_scale: TileInfo,
                                         right: TileInfo,
                                         right_scale: TileInfo) => boolean
begin
    if !TileMatrixInfoShapeLegal(left, right) ||
       !TileInfoDescriptorLegal(left_scale) ||
       !TileInfoDescriptorLegal(right_scale) then return FALSE; end;
    let selected_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    let scale_blocks: integer {0..2048} =
        ((left.valid_columns + 31) DIVRM 32) as integer {0..2048};
    return selected_type == TileDataType_FP32 &&
           TileMXOperandPairLegal(left.data_type, right.data_type) &&
           left_scale.data_type == TileDataType_E8M0 &&
           right_scale.data_type == TileDataType_E8M0 &&
           left_scale.valid_rows == left.valid_rows &&
           left_scale.valid_columns == scale_blocks &&
           right_scale.valid_rows == scale_blocks &&
           right_scale.valid_columns == right.valid_columns;
end;

readonly func TileOrdinaryMatrixOperandsLegal(left: TileIndex,
                                              right: TileIndex) => boolean
begin
    if !TileMatrixShapeLegal(left, right) then return FALSE; end;
    let selected_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    return selected_type != TileDataType_E8M0 &&
           _Tiles[[left]].data_type == selected_type &&
           _Tiles[[right]].data_type == selected_type;
end;

pure func TileMXOperandPairLegal(left_type: TileDataType,
                                right_type: TileDataType) => boolean
begin
    let fp8_pair =
        (left_type == TileDataType_E4M3 ||
         left_type == TileDataType_E5M2) &&
        (right_type == TileDataType_E4M3 ||
         right_type == TileDataType_E5M2);
    let fp4_pair =
        (left_type == TileDataType_E2M1X2 ||
         left_type == TileDataType_HiF4X2) &&
        (right_type == TileDataType_E2M1X2 ||
         right_type == TileDataType_HiF4X2);
    return fp8_pair || fp4_pair;
end;

readonly func TileMXMatrixOperandsLegal(left: TileIndex,
                                        right: TileIndex) => boolean
begin
    if !TileMatrixShapeLegal(left, right) then return FALSE; end;
    let selected_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    return selected_type == TileDataType_FP32 &&
           TileMXOperandPairLegal(
               _Tiles[[left]].data_type, _Tiles[[right]].data_type);
end;

readonly func TileMatrixBiasShapeLegal(left: TileIndex, right: TileIndex,
                                       bias: TileIndex) => boolean
begin
    return TileSourceContentsDefined(bias) &&
           (_Tiles[[bias]].valid_rows == 1 ||
            _Tiles[[bias]].valid_rows == _Tiles[[left]].valid_rows) &&
           (_Tiles[[bias]].valid_columns == 1 ||
            _Tiles[[bias]].valid_columns == _Tiles[[right]].valid_columns);
end;

readonly func TileOrdinaryMatrixBiasLegal(left: TileIndex, right: TileIndex,
                                          bias: TileIndex) => boolean
begin
    let selected_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    return TileOrdinaryMatrixOperandsLegal(left, right) &&
           TileMatrixBiasShapeLegal(left, right, bias) &&
           _Tiles[[bias]].data_type == selected_type;
end;

readonly func TileMXMatrixBiasLegal(left: TileIndex, right: TileIndex,
                                    bias: TileIndex) => boolean
begin
    return TileMXMatrixOperandsLegal(left, right) &&
           TileMatrixBiasShapeLegal(left, right, bias) &&
           _Tiles[[bias]].data_type == TileDataType_FP32;
end;

readonly func TileMatrixScaleLegal(left: TileIndex, right: TileIndex,
                                   left_scale: TileIndex,
                                   right_scale: TileIndex) => boolean
begin
    if !TileMXMatrixOperandsLegal(left, right) ||
       !TileSourceContentsDefined(left_scale) ||
       !TileSourceContentsDefined(right_scale) then return FALSE; end;
    let logical_k: integer {0..65535} = _Tiles[[left]].valid_columns;
    let scale_blocks: integer {0..2048} =
        ((logical_k + 31) DIVRM 32) as integer {0..2048};
    return _Tiles[[left_scale]].data_type == TileDataType_E8M0 &&
           _Tiles[[right_scale]].data_type == TileDataType_E8M0 &&
           _Tiles[[left_scale]].valid_rows == _Tiles[[left]].valid_rows &&
           _Tiles[[left_scale]].valid_columns == scale_blocks &&
           _Tiles[[right_scale]].valid_rows == scale_blocks &&
           _Tiles[[right_scale]].valid_columns ==
               _Tiles[[right]].valid_columns;
end;

readonly func TileMatrixDestinationLegal(destination: TileIndex,
                                         left: TileIndex,
                                         right: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileMatrixShapeLegal(left, right) then return FALSE; end;
    let selected_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    let accumulator_type = TileMatrixAccumulatorDataType(selected_type);
    let expected_destination_type = if _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0 then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else accumulator_type;
    return _Tiles[[destination]].valid_rows == _Tiles[[left]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[destination]].data_type == expected_destination_type;
end;

readonly func TileMatrixAccumulatorDestinationLegal(destination: TileIndex,
                                                     left: TileIndex,
                                                     right: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileMatrixShapeLegal(left, right) then return FALSE; end;
    let selected_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    let accumulator_type = TileMatrixAccumulatorDataType(selected_type);
    return _Tiles[[destination]].valid_rows == _Tiles[[left]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[destination]].data_type == accumulator_type;
end;

readonly func TileOperandsLegal_TMATMUL(
    destination: TileIndex, left: TileIndex, right: TileIndex) => boolean
begin
    return TileOrdinaryMatrixOperandsLegal(left, right) &&
           TileMatrixDestinationLegal(destination, left, right);
end;

readonly func TileOperandsLegal_TMATMUL_BIAS(
    destination: TileIndex, left: TileIndex, right: TileIndex,
    bias: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL(destination, left, right) &&
           TileOrdinaryMatrixBiasLegal(left, right, bias);
end;

readonly func TileOperandsLegal_TMATMUL_ACC(
    destination: TileIndex, accumulator: TileIndex,
    left: TileIndex, right: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL(destination, left, right) &&
           TileSourceContentsDefined(accumulator) &&
           TileMatrixAccumulatorDestinationLegal(accumulator, left, right) &&
           _Tiles[[accumulator]].layout == _Tiles[[destination]].layout &&
           _Tiles[[accumulator]].capacity_bytes ==
               _Tiles[[destination]].capacity_bytes;
end;

readonly func TileOperandsLegal_TMATMUL_MX(
    destination: TileIndex, left: TileIndex, left_scale: TileIndex,
    right: TileIndex, right_scale: TileIndex) => boolean
begin
    return TileMatrixScaleLegal(left, right, left_scale, right_scale) &&
           TileMatrixDestinationLegal(destination, left, right);
end;

readonly func TileOperandsLegal_TMATMUL_MX_BIAS(
    destination: TileIndex, left: TileIndex, left_scale: TileIndex,
    right: TileIndex, right_scale: TileIndex,
    bias: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_MX(
               destination, left, left_scale, right, right_scale) &&
           TileMXMatrixBiasLegal(left, right, bias);
end;

readonly func TileOperandsLegal_TMATMUL_MX_ACC(
    destination: TileIndex, accumulator: TileIndex,
    left: TileIndex, left_scale: TileIndex,
    right: TileIndex, right_scale: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_MX(
               destination, left, left_scale, right, right_scale) &&
           TileSourceContentsDefined(accumulator) &&
           TileMatrixAccumulatorDestinationLegal(accumulator, left, right) &&
           _Tiles[[accumulator]].layout == _Tiles[[destination]].layout &&
           _Tiles[[accumulator]].capacity_bytes ==
               _Tiles[[destination]].capacity_bytes;
end;

readonly func TileOperandsLegal_TGEMV(
    destination: TileIndex, matrix: TileIndex, vector: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL(destination, matrix, vector) &&
           _Tiles[[vector]].valid_columns == 1;
end;

readonly func TileOperandsLegal_TGEMV_BIAS(
    destination: TileIndex, matrix: TileIndex, vector: TileIndex,
    bias: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV(destination, matrix, vector) &&
           TileOrdinaryMatrixBiasLegal(matrix, vector, bias);
end;

readonly func TileOperandsLegal_TGEMV_ACC(
    destination: TileIndex, accumulator: TileIndex,
    matrix: TileIndex, vector: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_ACC(
               destination, accumulator, matrix, vector) &&
           _Tiles[[vector]].valid_columns == 1;
end;

readonly func TileOperandsLegal_TGEMV_MX(
    destination: TileIndex, matrix: TileIndex, left_scale: TileIndex,
    vector: TileIndex, right_scale: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_MX(
               destination, matrix, left_scale, vector, right_scale) &&
           _Tiles[[vector]].valid_columns == 1 &&
           TileMatrixScaleLegal(matrix, vector, left_scale, right_scale);
end;

readonly func TileOperandsLegal_TGEMV_MX_BIAS(
    destination: TileIndex, matrix: TileIndex, left_scale: TileIndex,
    vector: TileIndex, right_scale: TileIndex,
    bias: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV_MX(
               destination, matrix, left_scale, vector, right_scale) &&
           TileMXMatrixBiasLegal(matrix, vector, bias);
end;

readonly func TileOperandsLegal_TGEMV_MX_ACC(
    destination: TileIndex, accumulator: TileIndex,
    matrix: TileIndex, left_scale: TileIndex,
    vector: TileIndex, right_scale: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_MX_ACC(destination, accumulator,
               matrix, left_scale, vector, right_scale) &&
           _Tiles[[vector]].valid_columns == 1;
end;
