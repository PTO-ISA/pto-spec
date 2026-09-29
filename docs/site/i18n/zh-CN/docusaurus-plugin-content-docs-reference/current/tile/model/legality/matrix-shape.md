<!-- GENERATED FROM: asl/tile/model/legality/matrix-shape.asl -->
# Matrix Shape

**Normative ASL source:** `asl/tile/model/legality/matrix-shape.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-matrix-shape-purpose role=purpose-scope -->
## 用途与范围

本单元负责 CUBE Matrix 族的类型类别、维度检查以及逐指令的操作数合法性。它包含三类内容：

- 普通 Matrix 输入类型与累加器类型规则。
- 针对 `B.DIM` 值 LB0、LB1 与 LB2（M、N 与 K）的指令束维度检查。
- 直接 Tile 合法性处理函数 `TileOperandsLegal_TMATMUL` 至 `TileOperandsLegal_TGEMV_MX_ACC`，十二条 Matrix 指令各一个。每条指令的元数据以 `legality_handler` 命名其处理函数，每个指令单元把它封装在同名的 `InstructionContractOperandsLegal_` 函数中，例如 `InstructionContractOperandsLegal_TMATMUL`。

它还定义基于 `TileInfo` 的检查，指令束路径在预检之后对其进行断言。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-shape-concepts role=concepts-state -->
## 概念与可见状态

普通（非 MX）Matrix 输入是 FP32、TF32、HF32、FP16、BF16、HiF8、E4M3、E5M2、E3M2、E2M3、E2M1X2、E1M2X2、S16、S8、S4X2、U16、U8 或 U4X2 之一。`TileOrdinaryMatrixInputTypesSameClass` 要求 A 的类型（AType）与 B 的类型（BType）同为浮点、同为有符号或同为无符号。

随后 `TileOrdinaryMatrixAccumulatorType` 给出结果类型：有符号输入为 S32，无符号输入为 U32，其余为 FP32。它断言同类别规则，因此调用者需先测试该规则。

AType 是编码的操作 `DataType`。存在 `B.DATR` 时 BType 是 `B.DATR` 的 `DataType`；否则等于 AType。

`BundleCubeDimensionValue` 返回维度寄存器的值；当值超过 65535 时返回 0。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-shape-rules role=rules-interactions -->
## 规则与交互

`BundleTMATMULDimensionsLegal` 是指令束维度检查：

- 没有 Shared 源时，M、N 与 K 各自必须非零。
- 有 Shared 源时，M（Core 总的 group M）必须在 1 到 128 之间，N 与 K 必须是非零的 2 的幂。

直接处理函数由更小的谓词组合而成：

- `TileMatrixShapeLegal` 要求已选中 Tile 操作、由 `TileMatrixCubeInfosMatchDimensions` 判定合法的 Local CUBE A 与 B 对，且 M x N 不大于 `PTO_MODEL_TILE_ELEMENTS`。
- `TileMatrixDestinationLegal` 要求合法的 CUBE D，其有效形状为 [M, N]、使用 A 的布局，并使用 `PreQuantMode` 选定的类型：模式 0 为累加器类型，否则为该模式的输出类型。
- bias 检查要求一个已定义的 [1, N] `CUBE_N8` Tile，类型为累加器类型，MX 形式则为 FP32。
- `_ACC` 处理函数要求 C 与 D 是不同的 Tile，C 已定义且与 D 布局相同，并且除非 `PreQuantMode` 非零，两者容量相等。
- `TGEMV` 处理函数额外要求 A 的有效行数等于 1。

设计要点：这些处理函数是 `readonly` 谓词。它们读取描述符与指令束属性并返回布尔值，因此求值不会改变任何 Tile、分配或载荷状态。

HiF4X2 不是普通 Matrix 类型。`TileOperandsLegal_TMATMUL_MX` 及其他 MX 处理函数调用 `TileMatrixDestinationLegal`，后者应用普通同类别测试，因此当 AType 或 BType 为 HiF4X2 时这些直接处理函数返回 FALSE。指令束路径则改用 `TileMXOperandPairLegal` 检查 MX 类型并接受 HiF4X2，这符合 NDF 条款 `PTO-CUBE-MATRIX-SCALE-001` 对 Matrix-MX 输入角色的要求。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-shape-boundaries role=boundaries -->
## 架构边界

在指令束路径中，`ExecuteBundleTMATMULOperation` 在预检中调用 `BundleTMATMULDimensionsLegal`，并对普通函数调用 `TileOrdinaryMatrixInputTypesSameClass`、对 MX 函数调用 `TileMXOperandPairLegal`；分配之后，它断言 `TileMatrixCubeInfosMatchDimensions`、`TileMatrixMixedInfosMatchDimensions` 或 `TileMatrixInfosMatchDimensions`（分别对应全 Local、Local A 加 Shared B、全 Shared），并对 MX 形式断言 `TileMatrixInfoOptionalScalesLegal`、对 bias 形式断言 `TileMatrixInfoBiasLegal`。

`TileOrdinaryMatrixInfosLegal`、`TileMatrixInfoDestinationLegal`、`TileMatrixInfoAccumulatorLegal` 与 `TileMatrixInfoScalesLegal` 在当前 ASL 中没有调用者。

合法性接受 8 位与 4 位浮点类型，但数值辅助函数并不把它们全部当作浮点处理。`TileProfileMatrixAccumulate` 只在两个输入都是 FP32、TF32、HF32、FP16 或 BF16 且三个值都有限时使用参考浮点累加。对于 HiF8、E4M3、E5M2、E3M2、E2M3、E2M1X2、E1M2X2 或非有限值，它加上原始字乘积 `accumulator + MultiplyWord(left, right)`。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-shape-example role=example-usage -->
## 非规范阅读示例

考虑 AType 为 S8、`B.DATR` BType 为 U8 的 `TMATMUL`。S8 有符号而 U8 无符号，因此同类别测试失败，指令束以 `Fault_TileLegality` 故障。

若改为 BType S8，则类别一致，结果类型为 S32。对于 M = 16、N = 64、K = 32 且 `PreQuantMode` 为 0 的全 Local 指令束：

- `B.DIM` 值 16、64 与 32 均非零，因此维度检查通过。
- D 必须具有有效形状 [16, 64]、类型 S32 以及 A 的 M 布局。
- M x N = 1024，在 `PTO_MODEL_TILE_ELEMENTS`（32768）以内。

若有一个 Shared 右组且 M = 200，维度检查失败，因为 200 超过 128。

本示例只用于演示当前 ASL 所有者，不替代规范操作。

<!-- PTO-READER-BLOCK: tile-model-legality-matrix-shape-related role=related-owners-navigation -->
## 相关所有者

- [Matrix CUBE 主操作数](matrix-cube-primary.md) 负责 Local A、B 与 C 的描述符检查。
- [Matrix info 描述符](matrix-info-descriptor.md) 负责 RowMajor 与混合描述符检查。
- [Matrix 函数](matrix-functions.md) 负责 MX 类型与缩放规则。
- [CUBE 执行](../execution/cube.md) 在这些检查之后计算乘积。
- [TMATMUL](../../matrix-and-matrix-vector/matrix-matrix/TMATMUL.md) 与 [TMATMUL_MX](../../matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX.md) 是参考指令。
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
