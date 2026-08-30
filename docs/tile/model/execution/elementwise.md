<!-- GENERATED FROM: asl/tile/model/execution/elementwise.asl -->
# Elementwise

**Normative ASL source:** `asl/tile/model/execution/elementwise.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-ELEMENTWISE}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/elementwise.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","surface":"tile","classification":["model","execution","elementwise"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-EXECUTION-MINMAX","PTO-SCALAR-MODEL-FSU-PROFILE"]}
// PTO-REQ-TEPL-001: direct, read-before-write TEPL semantics.

impdef func TileSquareRoot(value: Word) => Word
begin
    // A numeric profile replaces this stable raw-encoding default.
    return value;
end;

impdef func TileLogarithm(value: Word) => Word
begin
    return value;
end;

impdef func TileReciprocal(value: Word) => Word
begin
    // The typed SFU special-value path handles representable signed
    // infinities and status before this finite-profile hook is called.
    return DivideWordUnsigned(Ones{PTO_XLEN}, value);
end;

impdef func TileReciprocalSquareRoot(value: Word) => Word
begin
    // One profile operation; this is not two architecturally rounded steps.
    return value;
end;

impdef func TileExponential(value: Word) => Word
begin
    return value;
end;

pure func TileBinaryValue(op: TileBinaryOperation, left: Word, right: Word) => Word
begin
    case op of
        when TileBinary_ADD => return left + right;
        when TileBinary_SUB => return left - right;
        when TileBinary_MUL => return MultiplyWord(left, right);
        when TileBinary_MAX =>
            if SInt(left) > SInt(right) then return left; else return right; end;
        when TileBinary_MIN =>
            if SInt(left) < SInt(right) then return left; else return right; end;
        when TileBinary_AND => return left AND right;
        when TileBinary_OR  => return left OR right;
        when TileBinary_XOR => return left XOR right;
        when TileBinary_SHL => return LSL(left, UInt(right[5:0]));
        when TileBinary_SHR => return LSR(left, UInt(right[5:0]));
        when TileBinary_DIV => return DivideWordUnsigned(left, right);
        when TileBinary_REM => return left - MultiplyWord(DivideWordUnsigned(left, right), right);
    end;
end;

pure func TileIntegerOperandValue(value: Word,
                                  data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_S8 => return SignExtend{PTO_XLEN}(value[7:0]);
        when TileDataType_S16 => return SignExtend{PTO_XLEN}(value[15:0]);
        when TileDataType_S32 => return SignExtend{PTO_XLEN}(value[31:0]);
        when TileDataType_S64 => return value;
        when TileDataType_U8 => return ZeroExtend{PTO_XLEN}(value[7:0]);
        when TileDataType_U16 => return ZeroExtend{PTO_XLEN}(value[15:0]);
        when TileDataType_U32 => return ZeroExtend{PTO_XLEN}(value[31:0]);
        when TileDataType_U64 => return value;
        otherwise => unreachable;
    end;
end;

// A scalar bound through B.IOR is one raw Tile element carried in an XLEN
// GPR.  Bits above the architectural element width never participate in the
// Tile operation.  Keep this normalization separate from signed integer
// interpretation: a later operation decides whether the retained bits are a
// floating encoding, a signed integer, or an unsigned integer.
pure func TileRawElementValue(
    value: Word,
    data_type: TileDataType) => Word
begin
    case TileElementBits(data_type) of
        when 8 =>
            return ZeroExtend{PTO_XLEN}(value[7:0]);
        when 16 =>
            return ZeroExtend{PTO_XLEN}(value[15:0]);
        when 32 =>
            return ZeroExtend{PTO_XLEN}(value[31:0]);
        when 64 =>
            return value;
        otherwise =>
            // Packed four-bit types do not belong to the closed scalar-VEC
            // type sets.  Retaining the low nibble makes this helper total
            // without granting those types operation legality.
            return ZeroExtend{PTO_XLEN}(value[3:0]);
    end;
end;

pure func TileUnsignedElementValue(
    value: Word,
    data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_S8, TileDataType_U8 =>
            return ZeroExtend{PTO_XLEN}(value[7:0]);
        when TileDataType_S16, TileDataType_U16 =>
            return ZeroExtend{PTO_XLEN}(value[15:0]);
        when TileDataType_S32, TileDataType_U32 =>
            return ZeroExtend{PTO_XLEN}(value[31:0]);
        when TileDataType_S64, TileDataType_U64 =>
            return value;
        otherwise =>
            unreachable;
    end;
end;

pure func TileIntegerShiftAmount(
    value: Word,
    data_type: TileDataType) => integer {0..63}
begin
    case data_type of
        when TileDataType_S8, TileDataType_U8 =>
            return UInt(value[2:0]);
        when TileDataType_S16, TileDataType_U16 =>
            return UInt(value[3:0]);
        when TileDataType_S32, TileDataType_U32 =>
            return UInt(value[4:0]);
        when TileDataType_S64, TileDataType_U64 =>
            return UInt(value[5:0]);
        otherwise =>
            unreachable;
    end;
end;

pure func TileIntegerMinMaxValue(
    operation: TileBinaryOperation,
    data_type: TileDataType,
    left: Word,
    right: Word) => Word
begin
    assert operation == TileBinary_MIN || operation == TileBinary_MAX;
    let left_value = TileIntegerOperandValue(left, data_type);
    let right_value = TileIntegerOperandValue(right, data_type);
    if TileDataTypeIsSigned(data_type) then
        if operation == TileBinary_MIN then
            if SInt(left_value) <= SInt(right_value) then
                return left_value;
            else
                return right_value;
            end;
        else
            if SInt(left_value) >= SInt(right_value) then
                return left_value;
            else
                return right_value;
            end;
        end;
    end;
    if operation == TileBinary_MIN then
        if UInt(left_value) <= UInt(right_value) then
            return left_value;
        else
            return right_value;
        end;
    else
        if UInt(left_value) >= UInt(right_value) then
            return left_value;
        else
            return right_value;
        end;
    end;
end;

pure func TileIntegerBinaryValue(
    operation: TileBinaryOperation,
    data_type: TileDataType,
    left: Word,
    right: Word) => Word
begin
    let left_value = TileIntegerOperandValue(left, data_type);
    let right_value = TileIntegerOperandValue(right, data_type);
    case operation of
        when TileBinary_ADD =>
            return NormalizeTileInteger(left_value + right_value, data_type);
        when TileBinary_SUB =>
            return NormalizeTileInteger(left_value - right_value, data_type);
        when TileBinary_MUL =>
            return NormalizeTileInteger(
                MultiplyWord(left_value, right_value),
                data_type);
        when TileBinary_MAX, TileBinary_MIN =>
            return TileIntegerMinMaxValue(
                operation,
                data_type,
                left_value,
                right_value);
        when TileBinary_AND =>
            return TileUnsignedElementValue(left_value AND right_value, data_type);
        when TileBinary_OR =>
            return TileUnsignedElementValue(left_value OR right_value, data_type);
        when TileBinary_XOR =>
            return TileUnsignedElementValue(left_value XOR right_value, data_type);
        when TileBinary_SHL =>
            return TileUnsignedElementValue(
                LSL(left_value, TileIntegerShiftAmount(right_value, data_type)),
                data_type);
        when TileBinary_SHR =>
            let shifted =
                if TileDataTypeIsSigned(data_type) then
                    ASR(left_value,
                        TileIntegerShiftAmount(right_value, data_type))
                else
                    LSR(left_value,
                        TileIntegerShiftAmount(right_value, data_type));
            return TileUnsignedElementValue(shifted, data_type);
        otherwise =>
            unreachable;
    end;
end;

pure func TileCarrierBinaryValue(
    operation: TileBinaryOperation,
    data_type: TileDataType,
    left: Word,
    right: Word) => Word
begin
    assert operation == TileBinary_AND ||
           operation == TileBinary_OR ||
           operation == TileBinary_XOR;
    var result = Zeros{PTO_XLEN};
    case operation of
        when TileBinary_AND => result = left AND right;
        when TileBinary_OR => result = left OR right;
        when TileBinary_XOR => result = left XOR right;
        otherwise => unreachable;
    end;
    return TileRawElementValue(result, data_type);
end;

pure func TileSignedModulo(dividend: Word, divisor: Word) => Word
begin
    let quotient = ScalarDivideSigned(dividend, divisor);
    let remainder = dividend - MultiplyWord(quotient, divisor);
    if IsZero(remainder) ||
       remainder[PTO_XLEN - 1] == divisor[PTO_XLEN - 1] then
        return remainder;
    end;
    return remainder + divisor;
end;

pure func TileIntegerDivRemValue(op: TileBinaryOperation,
                                 data_type: TileDataType,
                                 left: Word, right: Word) => Word
begin
    assert op == TileBinary_DIV || op == TileBinary_REM;
    let dividend = TileIntegerOperandValue(left, data_type);
    let divisor = TileIntegerOperandValue(right, data_type);
    assert !IsZero(divisor);
    if op == TileBinary_DIV then
        if TileDataTypeIsSigned(data_type) then
            return ScalarDivideSigned(dividend, divisor);
        else
            return DivideWordUnsigned(dividend, divisor);
        end;
    elsif TileDataTypeIsSigned(data_type) then
        return TileSignedModulo(dividend, divisor);
    else
        let quotient = DivideWordUnsigned(dividend, divisor);
        return dividend - MultiplyWord(quotient, divisor);
    end;
end;

impdef func TileProfileFloatingModulo(data_type: TileDataType,
                                      left: Word, right: Word) => Word
begin
    return left;
end;

impdef func TileProfileFloatingModuloFlags(
    data_type: TileDataType,
    left: Word,
    right: Word) => bits(5)
begin
    return Zeros{5};
end;

func TileProfileBinaryWithFlags(
    op: TileBinaryOperation,
    data_type: TileDataType,
    left: Word,
    right: Word) => (Word, bits(5))
begin
    if (op == TileBinary_AND || op == TileBinary_OR ||
       op == TileBinary_XOR) &&
       TileCarrierOnlyDataTypeSupported(data_type) then
        return (
            TileCarrierBinaryValue(op, data_type, left, right),
            Zeros{5});
    elsif (op == TileBinary_DIV || op == TileBinary_REM) &&
       TileDataTypeIsInteger(data_type) then
        return (
            TileIntegerDivRemValue(op, data_type, left, right),
            Zeros{5});
    elsif TileDataTypeIsInteger(data_type) then
        return (
            TileIntegerBinaryValue(op, data_type, left, right),
            Zeros{5});
    elsif op == TileBinary_MIN || op == TileBinary_MAX then
        let (result, invalid) =
            TileFloatingMinMaxValue(op, data_type, left, right);
        return (
            result,
            if invalid then Zeros{5} + 1 else Zeros{5});
    elsif op == TileBinary_REM then
        return (
            TileProfileFloatingModulo(data_type, left, right),
            TileProfileFloatingModuloFlags(data_type, left, right));
    else
        let control = DefaultNumericExecutionControl();
        var operation: FloatingBinaryOperation;
        case op of
            when TileBinary_ADD => operation = FloatingBinary_ADD;
            when TileBinary_SUB => operation = FloatingBinary_SUB;
            when TileBinary_MUL => operation = FloatingBinary_MUL;
            when TileBinary_DIV => operation = FloatingBinary_DIV;
            otherwise => unreachable;
        end;
        return ScalarFPBinaryProfile(
            operation,
            control.rounding_mode,
            TileDataTypeToEncoding(data_type),
            left,
            right);
    end;
end;

func TileProfileBinary(op: TileBinaryOperation, data_type: TileDataType,
                       left: Word, right: Word) => Word
begin
    let (result, -) = TileProfileBinaryWithFlags(
        op,
        data_type,
        left,
        right);
    return result;
end;

func ExecuteTileBinary(op: TileBinaryOperation, destination: TileIndex,
                       source_left: TileIndex, source_right: TileIndex)
begin
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    let operation_type = _Tiles[[destination]].data_type;
    assert left_tile.allocated && right_tile.allocated;
    assert TileElementwiseShapeMatch(source_left, source_right);
    assert TileElementwiseShapeMatch(destination, source_left);
    assert TileCarrierWidthCompatible(left_tile.data_type, operation_type);
    assert TileCarrierWidthCompatible(right_tile.data_type, operation_type);
    assert _Tiles[[destination]].data_type == operation_type;
    assert (op != TileBinary_SHL && op != TileBinary_SHR) ||
           TileDataTypeIsInteger(right_tile.data_type);

    // Snapshot both sources before the first destination write. This defines
    // source/destination aliasing as read-before-write.
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to left_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(left_tile,
                row as integer {0..65535}, column as integer {0..65535});
            _Tiles[[destination]] = TileInfoWithLogicalElement(
                _Tiles[[destination]], element,
                TileProfileBinary(op, operation_type,
                    TileReadLogicalElement(left_tile, element),
                    TileReadLogicalElement(right_tile, element)));
        end;
    end;
    MarkTileValidRegionDefined(destination);
    if TileBinaryUsesClosedElementwiseContract(op) then
        ApplyTilePadding(destination, CurrentBundlePadValue());
    end;
end;

func ExecuteTileFillScalar(destination: TileIndex, scalar: Word)
begin
    assert TileOperandsLegal_ExecuteTileFillScalar(destination, scalar);
    var result = _Tiles[[destination]];
    let normalized_scalar = TileRawElementValue(
        scalar,
        result.data_type);
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, element,
                normalized_scalar);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;

func ExecuteTileScalar(op: TileBinaryOperation, destination: TileIndex,
                       source: TileIndex, scalar: Word)
begin
    let operation_type = _Tiles[[destination]].data_type;
    assert TileOperandsLegal_ExecuteTileScalar(
        op,
        destination,
        source,
        scalar);
    let source_tile = _Tiles[[source]];
    var result = _Tiles[[destination]];
    let normalized_scalar = TileRawElementValue(scalar, operation_type);
    var flags = Zeros{5};
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let (value, element_flags) = TileProfileBinaryWithFlags(
                op,
                operation_type,
                TileReadLogicalElement(source_tile, element),
                normalized_scalar);
            result = TileInfoWithLogicalElement(result, element, value);
            flags = flags OR element_flags;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    RecordNumericStatusFlags(flags);
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->
