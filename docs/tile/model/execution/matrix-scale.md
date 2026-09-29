<!-- GENERATED FROM: asl/tile/model/execution/matrix-scale.asl -->
# Matrix Scale

**Normative ASL source:** `asl/tile/model/execution/matrix-scale.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-matrix-scale-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the per-element arithmetic of the CUBE matrix product. It supplies the starting accumulator value, the CScale step, MX scale indexing, the multiply-accumulate step, and the bias addition.

The callers are in the CUBE execution unit. `MatrixProductResultFromTiles` and `MatrixMXProductResultFromTiles` call the initial-value and accumulate helpers, and `MatrixBiasResult` calls `TileProfileMatrixBias`.

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-scale-concepts role=concepts-state -->
## Concepts and visible state

- CScale is an optional per-row exponent that divides the accumulator input C by a power of two. Its Tile holds one U8 exponent per row.
- An MX scale is one value per group of inner elements. The group size comes from `TileMXScaleGroupSize`: 64 for HiF4X2 and 32 for the other scaled types.
- A carrier is the raw Word that holds one element.

This unit holds no state. It reads Tile payloads and writes the numeric status flags only from `TileProfileMatrixCScale`.

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-scale-rules role=rules-interactions -->
## Rules and interactions

`MatrixInitialAccumulatorValue` returns zero when the form does not accumulate. Otherwise it reads the C element at the same row and column. With CScale present, it reads the U8 exponent at row `row`, column 0, and passes both to `TileProfileMatrixCScale`.

`TileProfileMatrixCScale` treats the value as FP32. NaN, infinity, and both zeros pass through unchanged. A finite value is halved once per exponent step, from 0 to 255 steps, and is encoded with RNE. The encoding flags are recorded at once with `RecordNumericStatusFlags`.

`MatrixLeftScaleElement` selects the scale at (row, inner / group size). `MatrixRightScaleElement` selects (column, group) when the scale Tile is CUBE_M32 and (group, column) otherwise.

`TileProfileMatrixAccumulate` uses the FP32 reference path when the destination is FP32 and the accumulator and both inputs are finite ordinary floating values. That path rounds the product and then the sum to FP32 with the supplied control. Otherwise it returns `accumulator + MultiplyWord(left, right)`.

`TileProfileMatrixScaledAccumulate` takes the same FP32 path only when neither MX scale is present, using the default control; otherwise it multiplies each primary carrier whose scale is present by that scale carrier with `MultiplyWord`, leaves a primary without a scale unchanged, and adds the product of the two results to the accumulator.

`TileProfileMatrixBias` rounds value plus bias to FP32 when both are finite FP32. Otherwise it adds the carriers.

Design point: special CScale inputs return before any arithmetic. NaN (including a signaling NaN), infinity, and both zeros keep their carrier bit-for-bit, and `RecordNumericStatusFlags` is not reached, so no flags are recorded for them.

Design point: the fallback paths operate on raw carriers with 64-bit wrapping arithmetic. They produce one exact value for every input, but they are not IEEE arithmetic, and no flags are recorded for them.

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-scale-boundaries role=boundaries -->
## Architectural boundaries

CScale legality requires an FP32 accumulator and a CScale-capable function; functions 2 and 6 allow it. The accumulate and bias helpers discard any flags from their FP32 encodings.

These helpers do not check shapes. The CUBE execution unit asserts them, and bundle preflight rejects illegal shapes before any snapshot.

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-scale-example role=example-usage -->
## Non-normative reading example

An FP32 TMATMUL_ACC uses CScale. For row 0 the accumulator element C is 12.0 and the CScale exponent is 2.

1. `MatrixInitialAccumulatorValue` reads 12.0 and the exponent 2.
2. `TileProfileMatrixCScale` halves twice: 12.0 / 2 = 6.0, then 6.0 / 2 = 3.0. The result is exact, so the flags are zero.
3. The inner loop starts from 3.0. With products 1.5 and 0.5, the sum becomes 4.5 and then 5.0.

For an MX right source of type E4M3 with K = 64, inner index 40 belongs to group 40 / 32 = 1.

<!-- PTO-READER-BLOCK: tile-model-execution-matrix-scale-related role=related-owners-navigation -->
## Related owners

- [CUBE execution](cube.md) loops over rows, columns, and the inner dimension.
- [Matrix operands](../legality/matrix-operands.md) owns the CScale schema.
- [Matrix functions](../legality/matrix-functions.md) owns MX group sizes and scale carrier types.
- [Reference conversion](../numeric/reference-conversion.md) owns the FP32 reference accumulate.
- [Numeric status](../../../arch/state/numeric-status.md) owns the sticky flags.
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
