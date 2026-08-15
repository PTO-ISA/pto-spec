// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MINMAX","surface":"tile","classification":["model","execution","minmax"],"depends_on":["PTO-ARCH-FEATURES-MINMAX-PROFILE","PTO-TILE-MODEL-STATE-TYPES"]}
pure func TileFloatingMinMaxValue(
    operation: TileBinaryOperation,
    data_type: TileDataType,
    left: Word,
    right: Word) => (Word, boolean)
begin
    assert operation == TileBinary_MIN || operation == TileBinary_MAX;
    let maximum = operation == TileBinary_MAX;
    let (available, result, invalid) =
        HardwareNumericFloatingMinMax(
            maximum,
            data_type,
            left,
            right);
    assert available;
    return (result, invalid);
end;
