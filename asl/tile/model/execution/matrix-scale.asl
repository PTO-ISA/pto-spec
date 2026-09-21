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
