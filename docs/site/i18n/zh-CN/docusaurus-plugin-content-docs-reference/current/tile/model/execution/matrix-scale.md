<!-- GENERATED FROM: asl/tile/model/execution/matrix-scale.asl -->
# Matrix Scale

**Normative ASL source:** `asl/tile/model/execution/matrix-scale.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-matrix-scale-purpose role=purpose-scope -->
## 用途与范围

本单元拥有 CUBE 矩阵乘积的逐元素算术。它提供起始累加值、CScale 步骤、MX 缩放索引、乘累加步骤以及偏置加法。

调用者位于 CUBE 执行单元。`MatrixProductResultFromTiles` 和 `MatrixMXProductResultFromTiles` 调用初始值和累加辅助函数，`MatrixBiasResult` 调用 `TileProfileMatrixBias`。

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-scale-concepts role=concepts-state -->
## 概念与可见状态

- CScale 是可选的按行指数，它用二的幂去除累加器输入 C。其 Tile 每行保存一个 U8 指数。
- MX 缩放是每组内维元素一个值。组大小来自 `TileMXScaleGroupSize`：HiF4X2 为 64，其他需缩放类型为 32。
- 载体是保存一个元素的原始 Word。

本单元不保存状态。它读取 Tile 载荷，且只在 `TileProfileMatrixCScale` 中写入数值状态标志。

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-scale-rules role=rules-interactions -->
## 规则与交互

形式不累加时，`MatrixInitialAccumulatorValue` 返回零。否则它读取同一行列的 C 元素。存在 CScale 时，它读取第 `row` 行第 0 列的 U8 指数，并把二者传给 `TileProfileMatrixCScale`。

`TileProfileMatrixCScale` 把值视为 FP32。NaN、无穷和两种零原样通过。有限值按指数每步减半一次，共 0 到 255 步，并以 RNE 编码。编码标志立即通过 `RecordNumericStatusFlags` 记录。

`MatrixLeftScaleElement` 选择位于 (row, inner / 组大小) 的缩放值。缩放 Tile 为 CUBE_M32 时，`MatrixRightScaleElement` 选择 (column, group)，否则选择 (group, column)。

当目标为 FP32 且累加器和两个输入都是有限的普通浮点值时，`TileProfileMatrixAccumulate` 使用 FP32 参考路径。该路径用所提供的控制先把乘积、再把和舍入到 FP32。否则它返回 `accumulator + MultiplyWord(left, right)`。

`TileProfileMatrixScaledAccumulate` 仅在两个 MX 缩放都不存在时才走同一 FP32 路径，并使用默认控制；否则，它用 `MultiplyWord` 把存在缩放的每个主载体乘以该缩放载体，没有缩放的主载体保持不变，然后把两个结果的乘积加到累加器上。

当值和偏置都是有限 FP32 时，`TileProfileMatrixBias` 把二者之和舍入到 FP32。否则它直接相加载体。

设计要点：特殊的 CScale 输入在任何算术之前返回。NaN（包括信号 NaN）、无穷和两种零逐位保持其载体，且不会到达 `RecordNumericStatusFlags`，因此不为它们记录任何标志。

设计要点：回退路径以 64 位回绕算术作用于原始载体。它们对每个输入给出唯一确切的值，但不是 IEEE 算术，也不为其记录标志。

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-scale-boundaries role=boundaries -->
## 架构边界

CScale 的合法性要求 FP32 累加器和支持 CScale 的功能；功能 2 和 6 允许它。累加和偏置辅助函数丢弃其 FP32 编码产生的任何标志。

这些辅助函数不检查形状。CUBE 执行单元对形状进行断言，指令束预检在任何快照之前拒绝非法形状。

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-scale-example role=example-usage -->
## 非规范阅读示例

一个 FP32 TMATMUL_ACC 使用 CScale。对第 0 行，累加器元素 C 为 12.0，CScale 指数为 2。

1. `MatrixInitialAccumulatorValue` 读取 12.0 和指数 2。
2. `TileProfileMatrixCScale` 减半两次：12.0 / 2 = 6.0，然后 6.0 / 2 = 3.0。结果精确，因此标志为零。
3. 内维循环从 3.0 开始。乘积为 1.5 和 0.5 时，和先变为 4.5，再变为 5.0。

对于 K = 64、类型为 E4M3 的 MX 右源，内维索引 40 属于第 40 / 32 = 1 组。

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-scale-related role=related-owners-navigation -->
## 相关所有者

- [CUBE 执行](cube.md)遍历行、列和内维。
- [矩阵操作数](../legality/matrix-operands.md)拥有 CScale schema。
- [矩阵功能](../legality/matrix-functions.md)拥有 MX 组大小和缩放载体类型。
- [参考转换](../numeric/reference-conversion.md)拥有 FP32 参考累加。
- [数值状态](../../../arch/state/numeric-status.md)拥有粘滞标志。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/matrix-scale.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE","surface":"tile","classification":["model","execution","matrix-scale"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-OPERANDS"]}

func TileProfileMatrixCScale(
    value: Word, exponent: bits(8)) => Word
begin
    let value_class = ClassifyFP32(value[31:0]);
    if NumericValueClassIsNaN(value_class) ||
       value_class == NumericValue_PositiveInfinity ||
       value_class == NumericValue_NegativeInfinity ||
       value_class == NumericValue_PositiveZero ||
       value_class == NumericValue_NegativeZero then
        return value;
    end;
    var scaled = ReferenceFP32FiniteValue(value[31:0]);
    for step = 1 to UInt(exponent) looplimit 255 do
        scaled = scaled / 2.0;
    end;
    let (encoded, flags) = ReferenceFP32FiniteEncoding(
        scaled, NumericRound_RNE);
    RecordNumericStatusFlags(flags);
    return encoded;
end;

func MatrixInitialAccumulatorValue(
    accumulator: TileInfo,
    accumulate: boolean,
    row: integer {0..65535},
    column: integer {0..65535},
    c_scale: TileIndex,
    c_scale_present: boolean) => Word
begin
    if !accumulate then return Zeros{PTO_XLEN}; end;
    let accumulator_element = TileStorageIndex(accumulator, row, column);
    let value = accumulator.payload[[accumulator_element]];
    if !c_scale_present then return value; end;
    let scale_element = TileStorageIndex(_Tiles[[c_scale]], row, 0);
    return TileProfileMatrixCScale(
        value, _Tiles[[c_scale]].payload[[scale_element]][7:0]);
end;

readonly func MatrixLeftScaleElement(
    scale: TileInfo,
    primary_type: TileDataType,
    row: integer {0..65535},
    inner: integer {0..65535}) => ModelTileElementIndex
begin
    let group = (inner DIVRM TileMXScaleGroupSize(primary_type))
        as integer {0..65535};
    return TileStorageIndex(scale, row, group);
end;

readonly func MatrixRightScaleElement(
    scale: TileInfo,
    primary_type: TileDataType,
    column: integer {0..65535},
    inner: integer {0..65535}) => ModelTileElementIndex
begin
    let group = (inner DIVRM TileMXScaleGroupSize(primary_type))
        as integer {0..65535};
    if scale.layout == TileLayout_CUBE_M32 then
        return TileStorageIndex(scale, column, group);
    end;
    return TileStorageIndex(scale, group, column);
end;

func TileProfileMatrixAccumulate(
    accumulator: Word, left: Word, right: Word,
    destination_type: TileDataType, left_type: TileDataType,
    right_type: TileDataType, control: NumericExecutionControl) => Word
begin
    if destination_type == TileDataType_FP32 &&
       ReferenceMatrixOrdinaryFloatingInputSupported(left_type) &&
       ReferenceMatrixOrdinaryFloatingInputSupported(right_type) &&
       ReferenceMatrixOrdinaryFloatingCarrierFinite(accumulator, destination_type) &&
       ReferenceMatrixOrdinaryFloatingCarrierFinite(left, left_type) &&
       ReferenceMatrixOrdinaryFloatingCarrierFinite(right, right_type) then
        return ReferenceMatrixOrdinaryFloatingAccumulate(
            accumulator, left, right, left_type, right_type, control);
    end;
    return accumulator + MultiplyWord(left, right);
end;

func TileProfileMatrixBias(value: Word, bias: Word,
                                          destination_type: TileDataType,
                                          bias_type: TileDataType) => Word
begin
    if destination_type == TileDataType_FP32 &&
       bias_type == TileDataType_FP32 &&
       ReferenceMatrixOrdinaryFloatingCarrierFinite(value, destination_type) &&
       ReferenceMatrixOrdinaryFloatingCarrierFinite(bias, bias_type) then
        let value_real = ReferenceFP32FiniteValue(value[31:0]);
        let bias_real = ReferenceFP32FiniteValue(bias[31:0]);
        let (result, -) = ReferenceMatrixFloatingEncoding(
            value_real + bias_real,
            TileDataType_FP32,
            DefaultNumericExecutionControl());
        return result;
    end;
    return value + bias;
end;

func TileProfileMatrixScaledAccumulate(
    accumulator: Word, left: Word, right: Word,
    left_scale: Word, right_scale: Word,
    left_scale_present: boolean, right_scale_present: boolean,
    destination_type: TileDataType, left_type: TileDataType,
    right_type: TileDataType, left_scale_type: TileDataType,
    right_scale_type: TileDataType) => Word
begin
    if !left_scale_present && !right_scale_present &&
       destination_type == TileDataType_FP32 &&
       ReferenceMatrixOrdinaryFloatingInputSupported(left_type) &&
       ReferenceMatrixOrdinaryFloatingInputSupported(right_type) &&
       ReferenceMatrixOrdinaryFloatingCarrierFinite(accumulator, destination_type) &&
       ReferenceMatrixOrdinaryFloatingCarrierFinite(left, left_type) &&
       ReferenceMatrixOrdinaryFloatingCarrierFinite(right, right_type) then
        return ReferenceMatrixOrdinaryFloatingAccumulate(
            accumulator, left, right, left_type, right_type,
            DefaultNumericExecutionControl());
    end;
    let scaled_left = if left_scale_present then
        MultiplyWord(left, left_scale)
    else
        left;
    let scaled_right = if right_scale_present then
        MultiplyWord(right, right_scale)
    else
        right;
    return accumulator + MultiplyWord(scaled_left, scaled_right);
end;
```
<!-- GENERATED-ASL-END: unit -->
