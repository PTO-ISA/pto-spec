<!-- GENERATED FROM: asl/tile/model/legality/matrix-shape.asl -->
# Matrix Shape

**Normative ASL source:** `asl/tile/model/legality/matrix-shape.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-matrix-shape-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the type classes, dimension checks, and per-instruction operand legality of the CUBE Matrix family. It has three kinds of content:

- The ordinary Matrix input types and the accumulator type rule.
- Bundle dimension checks for `B.DIM` values LB0, LB1, and LB2 (M, N, and K).
- The direct Tile legality handlers `TileOperandsLegal_TMATMUL` through `TileOperandsLegal_TGEMV_MX_ACC`, one for each of the twelve Matrix instructions. Each instruction's metadata names its handler as `legality_handler`, and each instruction unit wraps it in a matching `InstructionContractOperandsLegal_` function, for example `InstructionContractOperandsLegal_TMATMUL`.

It also defines `TileInfo`-based checks that the bundle path asserts after preflight.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-shape-concepts role=concepts-state -->
## Concepts and visible state

An ordinary (non-MX) Matrix input is one of FP32, TF32, HF32, FP16, BF16, HiF8, E4M3, E5M2, E3M2, E2M3, E2M1X2, E1M2X2, S16, S8, S4X2, U16, U8, or U4X2. `TileOrdinaryMatrixInputTypesSameClass` requires A's type (AType) and B's type (BType) to be both floating, both signed, or both unsigned.

`TileOrdinaryMatrixAccumulatorType` then gives the result type: S32 for signed inputs, U32 for unsigned inputs, and FP32 otherwise. It asserts the same-class rule, so callers test that rule first.

AType is the encoded operation `DataType`. BType is the `B.DATR` `DataType` when `B.DATR` is present; otherwise it equals AType.

`BundleCubeDimensionValue` returns a dimension register value, or 0 when the value exceeds 65535.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-shape-rules role=rules-interactions -->
## Rules and interactions

`BundleTMATMULDimensionsLegal` is the bundle dimension check:

- With no Shared sources, M, N, and K must each be nonzero.
- With Shared sources, M (the Core-total group M) must be 1 to 128, and N and K must be nonzero powers of two.

The direct handlers compose smaller predicates:

- `TileMatrixShapeLegal` requires a selected Tile operation, a legal Local CUBE A and B pair from `TileMatrixCubeInfosMatchDimensions`, and M x N no greater than `PTO_MODEL_TILE_ELEMENTS`.
- `TileMatrixDestinationLegal` requires a legal CUBE D with valid shape [M, N], A's layout, and the type chosen by `PreQuantMode`: the accumulator type for mode 0, or the mode's output type.
- The bias check requires a defined [1, N] `CUBE_N8` Tile of the accumulator type, or FP32 for MX forms.
- The `_ACC` handlers require C and D to be different Tiles, C to be defined with D's layout, and equal capacities unless `PreQuantMode` is nonzero.
- The `TGEMV` handlers add A's valid rows equal to 1.

Design point: the handlers are `readonly` predicates. They read descriptors and bundle attributes and return a boolean, so evaluating one changes no Tile, allocation, or payload state.

HiF4X2 is not an ordinary Matrix type. `TileOperandsLegal_TMATMUL_MX` and the other MX handlers call `TileMatrixDestinationLegal`, which applies the ordinary same-class test, so these direct handlers return FALSE when AType or BType is HiF4X2. The bundle path checks MX types with `TileMXOperandPairLegal` instead and accepts HiF4X2, as NDF clause `PTO-CUBE-MATRIX-SCALE-001` requires for Matrix-MX input roles.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-shape-boundaries role=boundaries -->
## Architectural boundaries

In the bundle path, `ExecuteBundleTMATMULOperation` calls `BundleTMATMULDimensionsLegal` in preflight together with `TileOrdinaryMatrixInputTypesSameClass` for ordinary functions or `TileMXOperandPairLegal` for MX functions; after allocation it asserts `TileMatrixCubeInfosMatchDimensions`, `TileMatrixMixedInfosMatchDimensions`, or `TileMatrixInfosMatchDimensions` (all-Local, Local A with Shared B, or all-Shared), plus `TileMatrixInfoOptionalScalesLegal` for MX forms and `TileMatrixInfoBiasLegal` for bias forms.

`TileOrdinaryMatrixInfosLegal`, `TileMatrixInfoDestinationLegal`, `TileMatrixInfoAccumulatorLegal`, and `TileMatrixInfoScalesLegal` have no caller in the current ASL.

Legality admits the 8-bit and 4-bit floating types, but the numeric helper does not treat all of them as floating. `TileProfileMatrixAccumulate` uses reference floating accumulation only when both inputs are FP32, TF32, HF32, FP16, or BF16 and all three values are finite. For HiF8, E4M3, E5M2, E3M2, E2M3, E2M1X2, E1M2X2, or a nonfinite value, it adds the raw word product `accumulator + MultiplyWord(left, right)`.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-shape-example role=example-usage -->
## Non-normative reading example

Consider `TMATMUL` with AType S8 and `B.DATR` BType U8. S8 is signed and U8 is unsigned, so the same-class test fails and the bundle faults with `Fault_TileLegality`.

With BType S8 instead, the class matches and the result type is S32. For an all-Local bundle with M = 16, N = 64, K = 32 and `PreQuantMode` 0:

- `B.DIM` values 16, 64, and 32 are nonzero, so the dimension check passes.
- D must have valid shape [16, 64], type S32, and A's M layout.
- M x N = 1024, within `PTO_MODEL_TILE_ELEMENTS` (32768).

With one Shared right group and M = 200, the dimension check fails because 200 exceeds 128.

This example illustrates the current ASL owner and does not replace the normative operation.

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-shape-related role=related-owners-navigation -->
## Related owners

- [Matrix CUBE primary](matrix-cube-primary.md) owns the Local A, B, and C descriptor checks.
- [Matrix info descriptor](matrix-info-descriptor.md) owns the RowMajor and mixed descriptor checks.
- [Matrix functions](matrix-functions.md) owns the MX types and scale rules.
- [CUBE execution](../execution/cube.md) computes the product after these checks.
- [TMATMUL](../../matrix-and-matrix-vector/matrix-matrix/TMATMUL.md) and [TMATMUL_MX](../../matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX.md) are reference instructions.
<!-- SUPPLEMENTARY-END -->

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
    return m >= 1 && m <= 128 && IsNonzeroPowerOfTwo(n) &&
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
    if !TileElementwiseSourceContentsDefined(bias) ||
       !TileCubeDescriptorLegal(_Tiles[[bias]]) ||
       _Tiles[[bias]].valid_rows != 1 ||
       _Tiles[[bias]].valid_columns != right.valid_columns ||
       _Tiles[[bias]].layout != TileLayout_CUBE_N8 then
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
    let left_groups = if left_scale_present then TileMXScaleGroupCount(
        left.valid_columns as integer {1..65535}, left_type) else 1;
    let right_groups = if right_scale_present then TileMXScaleGroupCount(
        left.valid_columns as integer {1..65535}, right_type) else 1;
    let left_scale_legal = !left_scale_present ||
        (((left_scale.layout == TileLayout_CUBE_M32 && TileCubeDescriptorLegal(left_scale)) ||
          (left_scale.layout == TileLayout_RowMajor &&
           TileInfoDescriptorLegal(left_scale))) &&
         left_scale.data_type == TileMXScaleCarrierType(left_type) &&
         left_scale.valid_rows == left.valid_rows &&
         left_scale.valid_columns == left_groups);
    let right_scale_legal = !right_scale_present ||
        (((right_scale.layout == TileLayout_CUBE_M32 && TileCubeDescriptorLegal(right_scale) &&
           right_scale.valid_rows == right.valid_columns &&
           right_scale.valid_columns == right_groups) ||
          (right_scale.layout == TileLayout_RowMajor &&
           TileInfoDescriptorLegal(right_scale) &&
           right_scale.valid_rows == right_groups &&
           right_scale.valid_columns == right.valid_columns)) &&
         right_scale.data_type == TileMXScaleCarrierType(right_type));
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
    return TileElementwiseSourceContentsDefined(bias) &&
           TileCubeDescriptorLegal(_Tiles[[bias]]) &&
           _Tiles[[bias]].valid_rows == 1 &&
           _Tiles[[bias]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[bias]].layout == TileLayout_CUBE_N8;
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
    return destination != accumulator &&
           TileOperandsLegal_TMATMUL(destination, left, right) &&
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
    return destination != accumulator &&
           TileOperandsLegal_TMATMUL_MX(
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
