// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-EXPANSION","surface":"tile","classification":["model","execution","expansion"],"depends_on":["PTO-TILE-MODEL-EXECUTION-REDUCTION","PTO-TILE-MODEL-EXECUTION-UNARY"]}
// PTO-REQ-TEPL-EXPAND-001: exact typed row and column broadcast operations.

pure func TileExpandBinaryOperation(
    operation: TileExpandOperation) => TileBinaryOperation
begin
    case operation of
        when TileExpand_ADD =>
            return TileBinary_ADD;
        when TileExpand_SUB =>
            return TileBinary_SUB;
        when TileExpand_MUL =>
            return TileBinary_MUL;
        when TileExpand_DIV =>
            return TileBinary_DIV;
        when TileExpand_MAX =>
            return TileBinary_MAX;
        when TileExpand_MIN =>
            return TileBinary_MIN;
        otherwise =>
            unreachable;
    end;
end;

func TileExpandValueWithFlags(
    operation: TileExpandOperation,
    data_type: TileDataType,
    left: Word,
    broadcast: Word) => (Word, bits(5))
begin
    if operation == TileExpand_COPY then
        return (broadcast, Zeros{5});
    end;

    if operation == TileExpand_EXPDIF then
        let (difference, subtract_flags) =
            TileProfileBinaryWithFlags(
                TileBinary_SUB,
                data_type,
                left,
                broadcast);
        let (handled, special_result, special_flags) =
            TileSFUUnarySpecialValue(
                TileUnary_EXP,
                data_type,
                difference);
        if handled then
            return (
                special_result,
                subtract_flags OR special_flags);
        end;
        let (profile_result, profile_flags) = TileProfileUnary(
            TileUnary_EXP,
            data_type,
            difference);
        return (
            profile_result,
            subtract_flags OR profile_flags);
    end;

    return TileProfileBinaryWithFlags(
        TileExpandBinaryOperation(operation),
        data_type,
        left,
        broadcast);
end;

func TileExpandValue(
    operation: TileExpandOperation,
    data_type: TileDataType,
    left: Word,
    broadcast: Word) => Word
begin
    let (result, -) = TileExpandValueWithFlags(
        operation,
        data_type,
        left,
        broadcast);
    return result;
end;

impdef func TileProfileExpand(op: TileExpandOperation,
                              data_type: TileDataType,
                              left: Word, broadcast: Word) => Word
begin
    return TileExpandValue(
        op,
        data_type,
        left,
        broadcast);
end;

func ExecuteTileExpand(op: TileExpandOperation, axis: TileAxis,
                       destination: TileIndex, source: TileIndex,
                       broadcast_source: TileIndex)
begin
    assert TileOperandsLegal_ExecuteTileExpand(
        op,
        axis,
        destination,
        source,
        broadcast_source);

    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast_source]];
    let source_payload = source_tile.payload;
    let broadcast_payload = broadcast_tile.payload;
    var result_tile = _Tiles[[destination]];
    var accumulated_flags = Zeros{5};

    for row = 0 to result_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to result_tile.valid_columns - 1 looplimit 65536 do
            let broadcast_row = if axis == TileAxis_Row then row else 0;
            let broadcast_column = if axis == TileAxis_Row then 0 else column;
            let broadcast_element = TileLinearIndex(broadcast_tile,
                broadcast_row as integer {0..65535},
                broadcast_column as integer {0..65535});
            var left = broadcast_payload[[broadcast_element]];
            if op != TileExpand_COPY then
                let source_element = TileLinearIndex(
                    source_tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                left = source_payload[[source_element]];
            end;
            let (value, element_flags) = TileExpandValueWithFlags(
                op,
                result_tile.data_type,
                left,
                broadcast_payload[[broadcast_element]]);
            let destination_element = TileLinearIndex(
                result_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            result_tile.payload[[destination_element]] = value;
            accumulated_flags = accumulated_flags OR element_flags;
        end;
    end;

    result_tile = TileWithValidRegionDefined(result_tile);
    result_tile = TileWithPadding(
        result_tile,
        CurrentBundlePadValue());
    RecordNumericStatusFlags(accumulated_flags);
    _Tiles[[destination]] = result_tile;
end;
