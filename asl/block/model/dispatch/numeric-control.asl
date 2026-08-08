// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-NUMERIC-CONTROL","surface":"block","classification":["model","dispatch","numeric-control"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA"]}
readonly func ResolveTileNumericExecutionControl(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1},
    operands: TileInstructionOperands) => NumericExecutionControl
begin
    var result = NumericExecutionControl {
        rounding_mode = operands.numeric_control.rounding_mode,
        saturating = operands.numeric_control.saturating
    };
    if operands.numeric_control.use_operation_default then
        result.rounding_mode = NumericRound_RNE;
        if TileOperationOfIndex(operation) == TileOperation_TCVT &&
           TileDataTypeIsFloating(_Tiles[[operands.source0]].data_type) &&
           !TileDataTypeIsFloating(_Tiles[[operands.destination0]].data_type) then
            result.rounding_mode = NumericRound_RTZ;
        end;
    end;
    return result;
end;
