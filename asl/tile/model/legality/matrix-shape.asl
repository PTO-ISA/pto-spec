// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","surface":"tile","classification":["model","legality","matrix-shape"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA"]}
pure func TileCubeGroupLayoutForM(group_m: integer {0..65535}) => TileLayout
begin
    if group_m >= 1 && group_m <= 64 then return TileLayout_CUBE_M16; end;
    if group_m >= 65 && group_m <= 128 then return TileLayout_CUBE_M32; end;
    return TileLayout_ImplementationDefined;
end;

pure func TileCubeGroupMPerPE(group_m: integer {0..65535}) => integer {0..32}
begin
    let layout = TileCubeGroupLayoutForM(group_m);
    return TileCubeMPerCell(layout);
end;

pure func TileCubeGroupPEValidM(group_m: integer {0..65535},
                                pe: integer {0..3}) => integer {0..32}
begin
    let per_pe = TileCubeGroupMPerPE(group_m);
    let offset = pe * per_pe;
    if group_m <= offset then return 0; end;
    let remaining = group_m - offset;
    if remaining > per_pe then return per_pe; end;
    return remaining as integer {0..32};
end;

readonly func TileMatrixSourceDescriptorLegal(tile: TileInfo) => boolean
begin
    if !tile.allocated || !tile.contents_defined then return FALSE; end;
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorShapeLegal(tile.capacity_bytes,
            tile.valid_rows, tile.valid_columns, tile.data_type,
            tile.layout) && tile.rows == tile.storage_rows &&
            tile.columns == tile.storage_columns &&
            tile.storage_bytes == TileCubeRequiredBytes(tile.layout,
                tile.valid_rows, tile.valid_columns, tile.data_type) &&
            tile.cube_k_repeat == TileCubeKRepeat(tile.layout,
                tile.valid_rows, tile.valid_columns, tile.data_type) &&
            tile.cube_n_repeat == TileCubeNRepeat(tile.layout,
                tile.valid_columns, tile.data_type) &&
            tile.cube_cell_count == TileCubeCellCount(tile.layout,
                tile.valid_rows, tile.valid_columns, tile.data_type);
    end;
    return TileCapacityIsLegal(tile.capacity_bytes) &&
           TileShapeMatchesCapacity(tile.capacity_bytes, tile.rows,
               tile.columns, tile.data_type) &&
           tile.valid_rows <= tile.rows && tile.valid_columns <= tile.columns &&
           tile.rows * tile.columns <= PTO_MODEL_TILE_ELEMENTS &&
           TileGenericIndexingPermitted(tile);
end;

readonly func TileMatrixDestinationDescriptorLegal(tile: TileInfo) => boolean
begin
    if !tile.allocated then return FALSE; end;
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorShapeLegal(tile.capacity_bytes,
            tile.valid_rows, tile.valid_columns, tile.data_type,
            tile.layout) && tile.rows == tile.storage_rows &&
            tile.columns == tile.storage_columns &&
            tile.storage_bytes == TileCubeRequiredBytes(tile.layout,
                tile.valid_rows, tile.valid_columns, tile.data_type) &&
            tile.cube_k_repeat == TileCubeKRepeat(tile.layout,
                tile.valid_rows, tile.valid_columns, tile.data_type) &&
            tile.cube_n_repeat == TileCubeNRepeat(tile.layout,
                tile.valid_columns, tile.data_type) &&
            tile.cube_cell_count == TileCubeCellCount(tile.layout,
                tile.valid_rows, tile.valid_columns, tile.data_type);
    end;
    return TileCapacityIsLegal(tile.capacity_bytes) &&
           TileShapeMatchesCapacity(tile.capacity_bytes, tile.rows,
               tile.columns, tile.data_type) &&
           tile.valid_rows <= tile.rows && tile.valid_columns <= tile.columns &&
           tile.rows * tile.columns <= PTO_MODEL_TILE_ELEMENTS &&
           TileGenericIndexingPermitted(tile);
end;

readonly func TileMatrixMLayoutLegal(tile: TileInfo) => boolean
begin
    return tile.layout == TileLayout_CUBE_M16 ||
           tile.layout == TileLayout_CUBE_M32;
end;

readonly func TileMatrixCubePairLegal(left: TileInfo, right: TileInfo)
                                      => boolean
begin
    if !TileMatrixMLayoutLegal(left) || left.valid_rows < 1 ||
       left.valid_columns < 1 || left.valid_rows >
       TileCubeMPerCell(left.layout) then return FALSE; end;
    if right.layout == TileLayout_CUBE_N8 then
        return right.valid_rows == left.valid_columns &&
               right.valid_columns >= 1 &&
               right.valid_rows <= right.storage_rows;
    end;
    return !TileLayoutIsCube(right.layout) &&
           right.valid_rows == left.valid_columns &&
           right.valid_columns >= 1;
end;

readonly func TileMatrixEncodedGroupM() => integer {0..65535}
begin
    return UInt(_BundleDimensions[[BundleDimensionIndexOfRole(
        BundleDimension_ValidRows)]]) as integer {0..65535};
end;

readonly func TileMatrixGroupBindingLegal(left: TileInfo,
                                          destination: TileInfo) => boolean
begin
    let shared_count = BundleSharedBindingCount();
    if shared_count == 0 then return TRUE; end;
    let encoded_group_m = TileMatrixEncodedGroupM();
    let group_m = if encoded_group_m == 0 then left.valid_rows
        else encoded_group_m;
    if group_m == 0 || group_m > 128 then return FALSE; end;
    let required = TileCubeGroupLayoutForM(group_m);
    if destination.layout != required then return FALSE; end;
    let pe_m = TileCubeGroupPEValidM(group_m, 0);
    if destination.valid_rows != pe_m then return FALSE; end;
    if TileLayoutIsCube(left.layout) then
        return left.layout == required && left.valid_rows == pe_m;
    end;
    return TRUE;
end;
readonly func TileMatrixShapeLegal(left: TileIndex,
                                   right: TileIndex) => boolean
begin
    if !BundleTileOperationSelected() ||
       !TileMatrixSourceDescriptorLegal(_Tiles[[left]]) ||
       !TileMatrixSourceDescriptorLegal(_Tiles[[right]]) then return FALSE; end;
    if TileLayoutIsCube(_Tiles[[left]].layout) ||
       TileLayoutIsCube(_Tiles[[right]].layout) then
        return TileMatrixCubePairLegal(_Tiles[[left]], _Tiles[[right]]);
    end;
    return IsNonzeroPowerOfTwo(_Tiles[[left]].valid_rows) &&
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
    if !BundleTileOperationSelected() ||
       !TileMatrixSourceDescriptorLegal(left) ||
       !TileMatrixSourceDescriptorLegal(right) then return FALSE; end;
    if TileLayoutIsCube(left.layout) || TileLayoutIsCube(right.layout) then
        return TileMatrixCubePairLegal(left, right);
    end;
    return IsNonzeroPowerOfTwo(left.valid_rows) &&
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
    if !TileMatrixDestinationDescriptorLegal(_Tiles[[destination]]) ||
       !TileMatrixInfoShapeLegal(left, right) then return FALSE; end;
    let selected_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    let accumulator_type = TileMatrixAccumulatorDataType(selected_type);
    let expected_destination_type = if _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0 then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else accumulator_type;
    let shape = _Tiles[[destination]];
    let layout_legal = if TileLayoutIsCube(left.layout) then
        TileMatrixMLayoutLegal(left) &&
        (right.layout == TileLayout_CUBE_N8 ||
         (BundleSharedBindingCount() > 0 && !TileLayoutIsCube(right.layout))) &&
        shape.layout == left.layout &&
        shape.valid_rows == left.valid_rows &&
        shape.valid_columns == right.valid_columns
    else if TileLayoutIsCube(right.layout) then FALSE
    else if BundleSharedBindingCount() > 0 && TileLayoutIsCube(shape.layout) then
        TileMatrixGroupBindingLegal(left, shape)
    else !TileLayoutIsCube(shape.layout);
    return layout_legal &&
           _Tiles[[destination]].valid_rows == left.valid_rows &&
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
    // Complete-bundle destinations are freshly allocated; D==C reuse is not
    // an accepted TMATMUL_ACC form. Reject before any destination effect.
    return destination != accumulator &&
           TileMatrixSourceDescriptorLegal(_Tiles[[accumulator]]) &&
           TileMatrixInfoShapeLegal(left, right) &&
           _Tiles[[accumulator]].valid_rows == left.valid_rows &&
           _Tiles[[accumulator]].valid_columns == right.valid_columns &&
           _Tiles[[accumulator]].data_type ==
               TileMatrixAccumulatorDataType(TileDataTypeFromEncoding(
                   ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()))) &&
           _Tiles[[accumulator]].layout == _Tiles[[destination]].layout;
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
    return TileMatrixInfoDestinationLegal(destination, _Tiles[[left]],
        _Tiles[[right]]);
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
           TileMatrixInfoDestinationLegal(destination, _Tiles[[left]],
               _Tiles[[right]]);
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
    if !TileMatrixInfoShapeLegal(_Tiles[[left]], _Tiles[[right]]) ||
       !TileMatrixInfoDestinationLegal(destination, _Tiles[[left]],
           _Tiles[[right]]) ||
       !TileMatrixInfoAccumulatorLegal(destination, accumulator,
           _Tiles[[left]], _Tiles[[right]]) then return FALSE; end;
    let selected_type = TileDataTypeFromEncoding(
        ZeroExtend{PTO_XLEN}(CurrentBundleTileOperationDataTypeCode()));
    let accumulator_type = TileMatrixAccumulatorDataType(selected_type);
    return _Tiles[[accumulator]].data_type == accumulator_type &&
           destination != accumulator;
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
    return TileMatrixScaleLegal(left, right, left_scale, right_scale) &&
           TileMatrixInfoDestinationLegal(destination, _Tiles[[left]],
               _Tiles[[right]]) &&
           TileMatrixInfoAccumulatorLegal(destination, accumulator,
               _Tiles[[left]], _Tiles[[right]]);
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
