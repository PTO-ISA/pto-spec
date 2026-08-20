<!-- GENERATED FROM: asl/tile/model/legality/matrix-shape.asl -->
# Matrix Shape

**Normative ASL source:** `asl/tile/model/legality/matrix-shape.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/matrix-shape.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE","surface":"tile","classification":["model","legality","matrix-shape"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS","PTO-TILE-MODEL-LEGALITY-MATRIX-INFO-DESCRIPTOR","PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA"]}
readonly func TileMatrixShapeLegal(left: TileIndex,
                                   right: TileIndex) => boolean
begin
    return BundleTileOperationSelected() &&
           TileMatrixCubeInfosMatchDimensions(
               _Tiles[[left]], _Tiles[[right]],
               _Tiles[[left]].valid_rows,
               _Tiles[[right]].valid_columns,
               _Tiles[[left]].valid_columns) &&
           _Tiles[[left]].valid_rows * _Tiles[[right]].valid_columns <=
               PTO_MODEL_TILE_ELEMENTS;
end;

pure func TileOrdinaryMatrixInputTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP32 ||
           data_type == TileDataType_TF32 ||
           data_type == TileDataType_HF32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_HiF8 ||
           data_type == TileDataType_E4M3 ||
           data_type == TileDataType_E5M2 ||
           data_type == TileDataType_E3M2 ||
           data_type == TileDataType_E2M3 ||
           data_type == TileDataType_E2M1X2 ||
           data_type == TileDataType_E1M2X2 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_S8 ||
           data_type == TileDataType_S4X2 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_U8 ||
           data_type == TileDataType_U4X2;
end;

pure func TileOrdinaryMatrixInputTypesSameClass(
    left_type: TileDataType, right_type: TileDataType) => boolean
begin
    if !TileOrdinaryMatrixInputTypeSupported(left_type) ||
       !TileOrdinaryMatrixInputTypeSupported(right_type) then
        return FALSE;
    end;
    return (TileDataTypeIsFloating(left_type) &&
            TileDataTypeIsFloating(right_type)) ||
           (TileDataTypeIsSigned(left_type) &&
            TileDataTypeIsSigned(right_type)) ||
           (TileDataTypeIsUnsignedInteger(left_type) &&
            TileDataTypeIsUnsignedInteger(right_type));
end;

pure func TileOrdinaryMatrixAccumulatorType(
    left_type: TileDataType, right_type: TileDataType) => TileDataType
begin
    assert TileOrdinaryMatrixInputTypesSameClass(left_type, right_type);
    return TileMatrixAccumulatorDataType(left_type);
end;

readonly func BundleCubeDimensionValue(
    dimension: BundleDimensionRegister) => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(dimension);
    if !_BundleDimensionPresent[[index]] then return 1; end;
    let raw = UInt(_BundleDimensions[[index]]);
    if raw <= 65535 then return raw as integer {0..65535}; end;
    return 0;
end;

readonly func BundleTMATMULDimensionsLegal(
    shared_count: integer {0..4}) => boolean
begin
    let m = BundleCubeDimensionValue(BundleDimension_LB0);
    let n = BundleCubeDimensionValue(BundleDimension_LB1);
    let k = BundleCubeDimensionValue(BundleDimension_LB2);
    if shared_count == 0 then
        return m != 0 && n != 0 && k != 0;
    end;
    return IsNonzeroPowerOfTwo(m) && IsNonzeroPowerOfTwo(n) &&
           IsNonzeroPowerOfTwo(k);
end;

readonly func TileMatrixInfosMatchDimensions(
    left: TileInfo, right: TileInfo,
    m: integer {1..65535}, n: integer {1..65535},
    k: integer {1..65535}) => boolean
begin
    return TileInfoDescriptorLegal(left) && TileInfoDescriptorLegal(right) &&
           IsNonzeroPowerOfTwo(left.rows) &&
           IsNonzeroPowerOfTwo(left.columns) &&
           IsNonzeroPowerOfTwo(right.rows) &&
           IsNonzeroPowerOfTwo(right.columns) &&
           left.valid_rows == m && left.valid_columns == k &&
           right.valid_rows == k && right.valid_columns == n;
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
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    return left.data_type == left_type && right.data_type == right_type &&
           TileOrdinaryMatrixInputTypesSameClass(left_type, right_type);
end;

readonly func TileMatrixInfoDestinationLegal(destination: TileIndex,
                                              left: TileInfo,
                                              right: TileInfo) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileMatrixInfoShapeLegal(left, right) then return FALSE; end;
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    if !TileOrdinaryMatrixInputTypesSameClass(left_type, right_type) then
        return FALSE;
    end;
    let accumulator_type = TileOrdinaryMatrixAccumulatorType(
        left_type, right_type);
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
       _Tiles[[bias]].valid_rows != 1 ||
       _Tiles[[bias]].valid_columns != right.valid_columns ||
       _Tiles[[bias]].layout != TileLayout_RowMajor then
        return FALSE;
    end;
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    let result_type = if mx then TileDataType_FP32 else
        TileOrdinaryMatrixAccumulatorType(left_type, right_type);
    return _Tiles[[bias]].data_type == result_type;
end;

readonly func TileMatrixInfoAccumulatorLegal(destination: TileIndex,
                                               accumulator: TileIndex,
                                               left: TileInfo,
                                               right: TileInfo) => boolean
begin
    let output_converted = _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
    let accumulator_type = TileOrdinaryMatrixAccumulatorType(
        left.data_type, right.data_type);
    return TileSourceContentsDefined(accumulator) &&
           TileDescriptorLegal(accumulator) &&
           TileMatrixInfoShapeLegal(left, right) &&
           _Tiles[[accumulator]].valid_rows == left.valid_rows &&
           _Tiles[[accumulator]].valid_columns == right.valid_columns &&
           _Tiles[[accumulator]].data_type == accumulator_type &&
           _Tiles[[accumulator]].layout == _Tiles[[destination]].layout &&
           (output_converted ||
            _Tiles[[accumulator]].capacity_bytes ==
                _Tiles[[destination]].capacity_bytes);
end;

readonly func TileMatrixInfoOptionalScalesLegal(
    left: TileInfo, left_scale: TileInfo, left_scale_present: boolean,
    right: TileInfo, right_scale: TileInfo, right_scale_present: boolean)
    => boolean
begin
    let primary_shape_legal = TileMatrixInfoShapeLegal(left, right) ||
        TileMatrixCubeInfosMatchDimensions(
            left, right, left.valid_rows,
            right.valid_columns, left.valid_columns) ||
        TileMatrixMixedInfosMatchDimensions(
            left, right, left.valid_rows,
            right.valid_columns, left.valid_columns);
    if !primary_shape_legal then return FALSE; end;
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    if left.data_type != left_type || right.data_type != right_type ||
       !TileMXOperandPairLegal(left_type, right_type) then
        return FALSE;
    end;
    let left_scale_required = TileMXInputTypeNeedsScale(left_type);
    let right_scale_required = TileMXInputTypeNeedsScale(right_type);
    if left_scale_present != left_scale_required ||
       right_scale_present != right_scale_required then
        return FALSE;
    end;
    let scale_blocks: integer {0..2048} =
        ((left.valid_columns + 31) DIVRM 32) as integer {0..2048};
    let left_scale_legal = !left_scale_present ||
        (TileInfoDescriptorLegal(left_scale) &&
         left_scale.data_type == TileDataType_E8M0 &&
         left_scale.layout == TileLayout_RowMajor &&
         left_scale.valid_rows == left.valid_rows &&
         left_scale.valid_columns == scale_blocks);
    let right_scale_legal = !right_scale_present ||
        (TileInfoDescriptorLegal(right_scale) &&
         right_scale.data_type == TileDataType_E8M0 &&
         right_scale.layout == TileLayout_RowMajor &&
         right_scale.valid_rows == scale_blocks &&
         right_scale.valid_columns == right.valid_columns);
    return left_scale_legal && right_scale_legal;
end;

readonly func TileMatrixInfoScalesLegal(left: TileInfo,
                                         left_scale: TileInfo,
                                         right: TileInfo,
                                         right_scale: TileInfo) => boolean
begin
    return TileMatrixInfoOptionalScalesLegal(
        left, left_scale, TRUE, right, right_scale, TRUE);
end;

readonly func TileOrdinaryMatrixOperandsLegal(left: TileIndex,
                                              right: TileIndex) => boolean
begin
    if !TileMatrixShapeLegal(left, right) then return FALSE; end;
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    return _Tiles[[left]].data_type == left_type &&
           _Tiles[[right]].data_type == right_type &&
           TileOrdinaryMatrixInputTypesSameClass(left_type, right_type);
end;

readonly func TileMXMatrixOperandsLegal(left: TileIndex,
                                        right: TileIndex) => boolean
begin
    if !TileMatrixShapeLegal(left, right) then return FALSE; end;
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    return _Tiles[[left]].data_type == left_type &&
           _Tiles[[right]].data_type == right_type &&
           TileMXOperandPairLegal(left_type, right_type);
end;

readonly func TileMatrixBiasShapeLegal(left: TileIndex, right: TileIndex,
                                       bias: TileIndex) => boolean
begin
    return TileSourceContentsDefined(bias) &&
           _Tiles[[bias]].valid_rows == 1 &&
           _Tiles[[bias]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[bias]].layout == TileLayout_RowMajor;
end;

readonly func TileOrdinaryMatrixBiasLegal(left: TileIndex, right: TileIndex,
                                          bias: TileIndex) => boolean
begin
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    return TileOrdinaryMatrixOperandsLegal(left, right) &&
           TileMatrixBiasShapeLegal(left, right, bias) &&
           _Tiles[[bias]].data_type == TileOrdinaryMatrixAccumulatorType(
               left_type, right_type);
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
    if !TileMXMatrixOperandsLegal(left, right) then return FALSE; end;
    let left_scale_present =
        TileMXInputTypeNeedsScale(_Tiles[[left]].data_type);
    let right_scale_present =
        TileMXInputTypeNeedsScale(_Tiles[[right]].data_type);
    return TileMatrixInfoOptionalScalesLegal(
        _Tiles[[left]], _Tiles[[left_scale]], left_scale_present,
        _Tiles[[right]], _Tiles[[right_scale]], right_scale_present);
end;

readonly func TileMatrixDestinationLegal(destination: TileIndex,
                                         left: TileIndex,
                                         right: TileIndex) => boolean
begin
    if !TileCubeDescriptorLegal(_Tiles[[destination]]) ||
       !TileMatrixShapeLegal(left, right) then return FALSE; end;
    let left_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let right_type = if _BundleDataAttributesPresent then
        TileDataTypeFromEncoding(
            _BundleDataAttributes.data_type as TileDataTypeEncoding)
        else left_type;
    if !TileOrdinaryMatrixInputTypesSameClass(left_type, right_type) then
        return FALSE;
    end;
    let accumulator_type = TileOrdinaryMatrixAccumulatorType(
        left_type, right_type);
    let expected_destination_type = if _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0 then
        BundleFPATROutputType(_BundleFixedPointAttributes.pre_quant_mode)
    else accumulator_type;
    return _Tiles[[destination]].valid_rows == _Tiles[[left]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[destination]].data_type == expected_destination_type &&
           _Tiles[[destination]].layout == _Tiles[[left]].layout;
end;

readonly func TileMatrixAccumulatorDestinationLegal(destination: TileIndex,
                                                     left: TileIndex,
                                                     right: TileIndex) => boolean
begin
    if !TileCubeDescriptorLegal(_Tiles[[destination]]) ||
       !TileMatrixShapeLegal(left, right) then return FALSE; end;
    let accumulator_type = TileOrdinaryMatrixAccumulatorType(
        _Tiles[[left]].data_type, _Tiles[[right]].data_type);
    return _Tiles[[destination]].valid_rows == _Tiles[[left]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[destination]].data_type == accumulator_type &&
           _Tiles[[destination]].layout == _Tiles[[left]].layout;
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
    let output_converted = _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
    return TileOperandsLegal_TMATMUL(destination, left, right) &&
           TileCubeDescriptorLegal(_Tiles[[accumulator]]) &&
           _Tiles[[accumulator]].contents_defined &&
           TileMatrixAccumulatorDestinationLegal(accumulator, left, right) &&
           _Tiles[[accumulator]].layout == _Tiles[[destination]].layout &&
           (output_converted ||
            _Tiles[[accumulator]].capacity_bytes ==
                _Tiles[[destination]].capacity_bytes);
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
    let output_converted = _BundleFixedPointAttributes.valid &&
        UInt(_BundleFixedPointAttributes.pre_quant_mode) != 0;
    return TileOperandsLegal_TMATMUL_MX(
               destination, left, left_scale, right, right_scale) &&
           TileCubeDescriptorLegal(_Tiles[[accumulator]]) &&
           _Tiles[[accumulator]].contents_defined &&
           TileMatrixAccumulatorDestinationLegal(accumulator, left, right) &&
           _Tiles[[accumulator]].layout == _Tiles[[destination]].layout &&
           (output_converted ||
            _Tiles[[accumulator]].capacity_bytes ==
                _Tiles[[destination]].capacity_bytes);
end;

readonly func TileOperandsLegal_TGEMV(
    destination: TileIndex, left_vector: TileIndex,
    right_matrix: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL(
               destination, left_vector, right_matrix) &&
           _Tiles[[left_vector]].valid_rows == 1;
end;

readonly func TileOperandsLegal_TGEMV_BIAS(
    destination: TileIndex, left_vector: TileIndex,
    right_matrix: TileIndex,
    bias: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV(
               destination, left_vector, right_matrix) &&
           TileOrdinaryMatrixBiasLegal(left_vector, right_matrix, bias);
end;

readonly func TileOperandsLegal_TGEMV_ACC(
    destination: TileIndex, accumulator: TileIndex,
    left_vector: TileIndex, right_matrix: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_ACC(
               destination, accumulator, left_vector, right_matrix) &&
           _Tiles[[left_vector]].valid_rows == 1;
end;

readonly func TileOperandsLegal_TGEMV_MX(
    destination: TileIndex, left_vector: TileIndex,
    left_scale: TileIndex, right_matrix: TileIndex,
    right_scale: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_MX(
               destination, left_vector, left_scale,
               right_matrix, right_scale) &&
           _Tiles[[left_vector]].valid_rows == 1;
end;

readonly func TileOperandsLegal_TGEMV_MX_BIAS(
    destination: TileIndex, left_vector: TileIndex,
    left_scale: TileIndex, right_matrix: TileIndex,
    right_scale: TileIndex,
    bias: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV_MX(
               destination, left_vector, left_scale,
               right_matrix, right_scale) &&
           TileMXMatrixBiasLegal(left_vector, right_matrix, bias);
end;

readonly func TileOperandsLegal_TGEMV_MX_ACC(
    destination: TileIndex, accumulator: TileIndex,
    left_vector: TileIndex, left_scale: TileIndex,
    right_matrix: TileIndex, right_scale: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_MX_ACC(destination, accumulator,
               left_vector, left_scale, right_matrix, right_scale) &&
           _Tiles[[left_vector]].valid_rows == 1;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
