<!-- GENERATED FROM: asl/tile/model/execution/elementwise.asl -->
# Elementwise

**Normative ASL source:** `asl/tile/model/execution/elementwise.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-ELEMENTWISE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-elementwise-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the shared element-by-element execution of Tile binary operations. It defines the per-element arithmetic helpers and three handlers:

- `ExecuteTileBinary` executes the Tile-Tile forms TADD, TSUB, TMUL, TDIV, TREM, TMAX, TMIN, TAND, TOR, TXOR, TSHL, and TSHR.
- `ExecuteTileScalar` executes the Tile-scalar forms TADDS, TSUBS, TMULS, TDIVS, TREMS, TMAXS, TMINS, TANDS, TORS, TXORS, TSHLS, and TSHRS.
- `ExecuteTileFillScalar` executes TEXPANDS, which fills a Tile with one scalar.

`TileProfileBinaryWithFlags` is also reused by the expansion, EXPDIF, and reduction units.

<!-- PTO-READER-BLOCK: tile-model-execution-elementwise-concepts role=concepts-state -->
## Concepts and visible state

The operation type is the destination Tile's `data_type`. Sources must have a carrier width compatible with it, so a source of another type with the same element width is reinterpreted, not converted.

`TileProfileBinaryWithFlags` chooses one arithmetic path per element and returns a value and five status flags. The flag bits are NV, DZ, OF, UF, and NX, from bit 0 to bit 4.

- AND, OR, and XOR on carrier types up to 32 bits combine raw bits.
- Integer DIV and REM use `TileIntegerDivRemValue`. Signed REM floors, so a nonzero remainder takes the divisor's sign.
- Other integer operations use `TileIntegerBinaryValue`, which wraps to the element width. Shift amounts use only the low bits that fit the width, and SHR is arithmetic for signed types.
- Floating MIN and MAX use `TileFloatingMinMaxValue`. Floating REM uses `ReferenceTileFloatingModulo`, which truncates.
- Floating ADD, SUB, MUL, and DIV use `ScalarFPBinaryProfile` with RNE rounding.

An ExecutionMask selects active coordinates. `BundleExecutionMaskActiveAt` is TRUE for every coordinate when no mask is in force.

<!-- PTO-READER-BLOCK: tile-model-execution-elementwise-rules role=rules-interactions -->
## Rules and interactions

Each handler loops over the valid region. An active coordinate computes a value from the source elements and scalar, or takes the scalar itself for TEXPANDS; an inactive coordinate takes `BundleExecutionMaskDestinationValue`: zero under the ZERO policy or the merge-base element under MERGE.

After the loop, the valid region is marked defined and the padding selected by `CurrentBundlePadValue` is applied. Without a B.DATR, that pad value is Null.

Design point: sources are snapshotted before the first destination write. `ExecuteTileBinary` copies both source `TileInfo` records before the loop, so a destination that names a source still reads the old values. `ExecuteTileScalar` and `ExecuteTileFillScalar` build the result privately and publish it once.

Design point: the scalar is normalized once with `TileRawElementValue`. Bits above the element width never take part, so a 64-bit register value such as `0x1_0000_0005` acts as 5 for a 32-bit Tile.

Design point: `ExecuteTileBinary` calls `TileProfileBinary`, which discards the flags. `ExecuteTileScalar` ORs the flags of active elements and records them with `RecordNumericStatusFlags`. `ExecuteTileFillScalar` records no flags.

<!-- PTO-READER-BLOCK: tile-model-execution-elementwise-boundaries role=boundaries -->
## Architectural boundaries

Operand legality is checked before these handlers run. Integer TDIV and TREM require every divisor read by an active coordinate to be nonzero. For TDIVS and TREMS, a zero scalar divisor is rejected only when at least one coordinate is active.

`ScalarFPBinaryProfile` accepts FP64, FP32, FP16, and BF16. `ReferenceTileFloatingModulo` accepts FP32, FP16, and BF16. Legality admits more floating types, but the model does not define results for types that these helpers assert against.

`TileBinaryValue` and the unary stubs such as `TileExponential` are not reached by any instruction path.

<!-- PTO-READER-BLOCK: tile-model-execution-elementwise-example role=example-usage -->
## Non-normative reading example

Take TREMS on an S32 Tile of 32 by 4 elements with one valid row, a scalar divisor of 3 in `a0`, and no ExecutionMask:

```text
TREMS <Row=32, Col=4, ValidRow=1, S32>, T#1, a0, ->T<512B>
```

The valid source row holds 7, -7, 6, and -1.

1. 7 REM 3: the quotient is 2 and the remainder is 1.
2. -7 REM 3: the truncated quotient is -2 and the remainder is -1. Its sign differs from the divisor, so 3 is added and the result is 2.
3. 6 REM 3 is 0.
4. -1 REM 3: the remainder is -1, so the result is 2.

The destination row is 1, 2, 0, 2. Integer paths return no flags, so the numeric status is unchanged.

<!-- PTO-READER-BLOCK: tile-model-execution-elementwise-related role=related-owners-navigation -->
## Related owners

- [Operand schema](../legality/operand-schema.md) owns the legality checks run before these handlers.
- [Data type and layout legality](../legality/dtype-layout.md) owns the type sets.
- [Min and max](minmax.md) owns the floating MIN and MAX helper.
- [Execution-mask state](execution-mask-state.md) owns active and inactive coordinate handling.
- [Numeric status](../../../arch/state/numeric-status.md) owns the sticky flags.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/elementwise.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","surface":"tile","classification":["model","execution","elementwise"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-EXECUTION-MINMAX","PTO-SCALAR-MODEL-FSU-SCALAR-FP"]}
// PTO-REQ-TEPL-001: direct, read-before-write TEPL semantics.

func TileSquareRoot(value: Word) => Word
begin
    return value;
end;

func TileLogarithm(value: Word) => Word
begin
    return value;
end;

func TileReciprocal(value: Word) => Word
begin
    return DivideWordUnsigned(Ones{PTO_XLEN}, value);
end;

func TileReciprocalSquareRoot(value: Word) => Word
begin
    return value;
end;

func TileExponential(value: Word) => Word
begin
    return value + 1;
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
        when TileBinary_EXPDIF => unreachable;
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
        when TileBinary_EXPDIF => unreachable;
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

func TileProfileFloatingModulo(data_type: TileDataType,
                                               left: Word, right: Word) => Word
begin
    let (result, -) = ReferenceTileFloatingModulo(data_type, left, right);
    return result;
end;

func TileProfileFloatingModuloFlags(
    data_type: TileDataType, left: Word, right: Word) => bits(5)
begin
    let (-, flags) = ReferenceTileFloatingModulo(data_type, left, right);
    return flags;
end;

func TileProfileBinaryWithFlags(
    op: TileBinaryOperation,
    data_type: TileDataType,
    left: Word,
    right: Word) => (Word, bits(5))
begin
    assert op != TileBinary_EXPDIF;
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
            when TileBinary_EXPDIF => unreachable;
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
    assert op != TileBinary_EXPDIF;
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
            var value = Zeros{PTO_XLEN};
            if BundleExecutionMaskActiveAt(
                   left_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                value = TileProfileBinary(op, operation_type,
                    TileReadLogicalElement(left_tile, element),
                    TileReadLogicalElement(right_tile, element));
            else
                value = BundleExecutionMaskDestinationValue(
                    left_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
            _Tiles[[destination]] = TileInfoWithLogicalElement(
                _Tiles[[destination]], element, value);
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
            let value = if BundleExecutionMaskActiveAt(
                result.layout, row as integer {0..65535},
                column as integer {0..65535}) then normalized_scalar
                else BundleExecutionMaskDestinationValue(
                    result.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            result = TileInfoWithLogicalElement(result, element,
                value);
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
            var value = Zeros{PTO_XLEN};
            var element_flags = Zeros{5};
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let (active_value, active_flags) =
                    TileProfileBinaryWithFlags(
                        op, operation_type,
                        TileReadLogicalElement(source_tile, element),
                        normalized_scalar);
                value = active_value;
                element_flags = active_flags;
            else
                value = BundleExecutionMaskDestinationValue(
                    source_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
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
