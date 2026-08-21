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

// Mixed EXPDIF owns these conversions locally.  They are exact value
// widenings for the selected source formats; they are not TCVT and never
// produce a conversion-inexact status.
pure func ExactWidenBF16ToFP32(value: Word) => Word
begin
    return LSL(ZeroExtend{PTO_XLEN}(value[15:0]), 16);
end;

pure func ExactWidenFP16ToFP32(value: Word) => Word
begin
    let raw = value[15:0];
    let sign = raw[15];
    let exponent = raw[14:10];
    let fraction = raw[9:0];
    var result: bits(32) = Zeros{32};
    result[31] = sign;
    if exponent == '11111' then
        result[30:23] = Ones{8};
        if fraction != Zeros{10} then
            // The selected IEEE profile canonicalizes produced FP32 NaNs.
            result[31] = '0';
            result[22:0] = Zeros{23} + 0x400000;
        end;
    elsif exponent != Zeros{5} then
        result[30:23] = Zeros{8} + (UInt(exponent) + 112);
        result[22:13] = fraction;
    elsif fraction != Zeros{10} then
        var normalized = fraction;
        var shift_count: integer {0..9} = 0;
        for shift = 0 to 9 looplimit 10 do
            if normalized[9] == '0' then
                normalized = LSL(normalized, 1);
                shift_count = (shift_count + 1) as integer {0..9};
            end;
        end;
        result[30:23] = Zeros{8} + (112 - shift_count);
        result[22:13] = ZeroExtend{10}(normalized[8:0]);
    end;
    return ZeroExtend{PTO_XLEN}(result);
end;

func TileExpandValueWithTypesAndFlags(
    operation: TileExpandOperation,
    source_type: TileDataType,
    destination_type: TileDataType,
    left: Word,
    broadcast: Word) => (Word, bits(5))
begin
    if operation == TileExpand_COPY then
        return (broadcast, Zeros{5});
    end;

    if operation == TileExpand_EXPDIF then
        if source_type != destination_type then
            assert destination_type == TileDataType_FP32;
            let widened_left = if source_type == TileDataType_FP16 then
                ExactWidenFP16ToFP32(left)
            else
                ExactWidenBF16ToFP32(left);
            let widened_broadcast = if source_type == TileDataType_FP16 then
                ExactWidenFP16ToFP32(broadcast)
            else
                ExactWidenBF16ToFP32(broadcast);
            // The named IEEE profile owns FP32 SUB/EXP for this mixed
            // path.  The operation-local widening above remains portable.
            let (profile_result, profile_flags) =
                TileProfileMixedExpdifFP32(
                    source_type,
                    widened_left,
                    widened_broadcast);
            return (
                profile_result,
                profile_flags);
        end;
        let (difference, subtract_flags) =
            TileProfileBinaryWithFlags(
                TileBinary_SUB,
                destination_type,
                left,
                broadcast);
        let (handled, special_result, special_flags) =
            TileSFUUnarySpecialValue(
                TileUnary_EXP,
                destination_type,
                difference);
        if handled then
            return (
                special_result,
                subtract_flags OR special_flags);
        end;
        let (profile_result, profile_flags) = TileProfileUnary(
            TileUnary_EXP,
            destination_type,
            difference);
        return (
            profile_result,
            subtract_flags OR profile_flags);
    end;

    return TileProfileBinaryWithFlags(
        TileExpandBinaryOperation(operation),
        destination_type,
        left,
        broadcast);
end;

impdef func TileProfileMixedExpdifFP32(
    source_type: TileDataType,
    left: Word,
    broadcast: Word) => (Word, bits(5))
begin
    assert source_type == TileDataType_FP16 ||
           source_type == TileDataType_BF16;
    let (difference, subtract_flags) = TileProfileBinaryWithFlags(
        TileBinary_SUB,
        TileDataType_FP32,
        left,
        broadcast);
    let (handled, special_result, special_flags) = TileSFUUnarySpecialValue(
        TileUnary_EXP,
        TileDataType_FP32,
        difference);
    if handled then
        return (
            special_result,
            subtract_flags OR special_flags);
    end;
    let (profile_result, profile_flags) = TileProfileUnary(
        TileUnary_EXP,
        TileDataType_FP32,
        difference);
    return (
        profile_result,
        subtract_flags OR profile_flags);
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

func TileExpandValueWithFlags(
    operation: TileExpandOperation,
    data_type: TileDataType,
    left: Word,
    broadcast: Word) => (Word, bits(5))
begin
    return TileExpandValueWithTypesAndFlags(
        operation,
        data_type,
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
    var result_tile = _Tiles[[destination]];
    var accumulated_flags = Zeros{5};

    for row = 0 to result_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to result_tile.valid_columns - 1 looplimit 65536 do
            let broadcast_row = if axis == TileAxis_Row then row else 0;
            let broadcast_column = if axis == TileAxis_Row then 0 else column;
            let broadcast_element = TileLogicalLinearIndex(broadcast_tile,
                broadcast_row as integer {0..65535},
                broadcast_column as integer {0..65535});
            var left = TileReadLogicalElement(broadcast_tile,
                broadcast_element);
            if op != TileExpand_COPY then
                let source_element = TileLogicalLinearIndex(
                    source_tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                left = TileReadLogicalElement(source_tile, source_element);
            end;
            let (value, element_flags) = TileExpandValueWithTypesAndFlags(
                op,
                source_tile.data_type,
                result_tile.data_type,
                left,
                TileReadLogicalElement(broadcast_tile, broadcast_element));
            let destination_element = TileLogicalLinearIndex(
                result_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            result_tile = TileInfoWithLogicalElement(result_tile,
                destination_element, value);
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
