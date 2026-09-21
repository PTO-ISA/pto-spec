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
