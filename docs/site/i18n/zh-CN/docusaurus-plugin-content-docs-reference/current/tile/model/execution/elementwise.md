<!-- GENERATED FROM: asl/tile/model/execution/elementwise.asl -->
# Elementwise

**Normative ASL source:** `asl/tile/model/execution/elementwise.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-ELEMENTWISE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-elementwise-purpose role=purpose-scope -->
## 用途与范围

本单元拥有 Tile 二元操作共享的逐元素执行。它定义逐元素算术辅助函数和三个处理函数：

- `ExecuteTileBinary` 执行 Tile-Tile 形式 TADD、TSUB、TMUL、TDIV、TREM、TMAX、TMIN、TAND、TOR、TXOR、TSHL 和 TSHR。
- `ExecuteTileScalar` 执行 Tile-标量形式 TADDS、TSUBS、TMULS、TDIVS、TREMS、TMAXS、TMINS、TANDS、TORS、TXORS、TSHLS 和 TSHRS。
- `ExecuteTileFillScalar` 执行 TEXPANDS，用一个标量填充 Tile。

`TileProfileBinaryWithFlags` 还被扩展、EXPDIF 和归约单元复用。

<!-- PTO-READER-BLOCK: tile-model-execution-elementwise-concepts role=concepts-state -->
## 概念与可见状态

操作类型是目标 Tile 的 `data_type`。源的载体宽度必须与之兼容，因此元素宽度相同的其他类型源会被重新解释，而不是被转换。

`TileProfileBinaryWithFlags` 为每个元素选择一条算术路径，返回一个值和五个状态标志。标志位从 bit 0 到 bit 4 依次为 NV、DZ、OF、UF 和 NX。

- 对不超过 32 位的载体类型，AND、OR 和 XOR 按原始位组合。
- 整数 DIV 和 REM 使用 `TileIntegerDivRemValue`。有符号 REM 向下取整，因此非零余数取除数的符号。
- 其他整数操作使用 `TileIntegerBinaryValue`，结果回绕到元素宽度。移位量只使用能容纳该宽度的低位，有符号类型的 SHR 为算术右移。
- 浮点 MIN 和 MAX 使用 `TileFloatingMinMaxValue`。浮点 REM 使用 `ReferenceTileFloatingModulo`，它截断取整。
- 浮点 ADD、SUB、MUL 和 DIV 使用 `ScalarFPBinaryProfile`，舍入为 RNE。

ExecutionMask 选择活动坐标。没有掩码生效时，`BundleExecutionMaskActiveAt` 对每个坐标都为 TRUE。

<!-- PTO-READER-BLOCK: tile-model-execution-elementwise-rules role=rules-interactions -->
## 规则与交互

每个处理函数遍历有效区域。活动坐标由源元素和标量计算出值，TEXPANDS 则直接取该标量；非活动坐标取 `BundleExecutionMaskDestinationValue`：ZERO 策略下为零，MERGE 策略下为合并基准元素。

循环结束后，有效区域被标记为已定义，并应用 `CurrentBundlePadValue` 选择的填充。没有 B.DATR 时，该填充值为 Null。

设计要点：源在第一次写目标之前被快照。`ExecuteTileBinary` 在循环前复制两个源的 `TileInfo` 记录，因此目标即使命名某个源，读取的仍是旧值。`ExecuteTileScalar` 和 `ExecuteTileFillScalar` 私下构建结果并只发布一次。

设计要点：标量用 `TileRawElementValue` 只规范化一次。高于元素宽度的位从不参与，因此像 `0x1_0000_0005` 这样的 64 位寄存器值对 32 位 Tile 而言就是 5。

设计要点：`ExecuteTileBinary` 调用 `TileProfileBinary`，后者丢弃标志。`ExecuteTileScalar` 把活动元素的标志按位或起来，并用 `RecordNumericStatusFlags` 记录。`ExecuteTileFillScalar` 不记录标志。

<!-- PTO-READER-BLOCK: tile-model-execution-elementwise-boundaries role=boundaries -->
## 架构边界

操作数合法性在这些处理函数运行之前检查。整数 TDIV 和 TREM 要求活动坐标读取的每个除数都非零。对 TDIVS 和 TREMS，只有当至少一个坐标处于活动状态时，零标量除数才被拒绝。

`ScalarFPBinaryProfile` 接受 FP64、FP32、FP16 和 BF16。`ReferenceTileFloatingModulo` 接受 FP32、FP16 和 BF16。合法性允许更多浮点类型，但对这些辅助函数断言排除的类型，模型未定义结果。

`TileBinaryValue` 以及 `TileExponential` 等一元桩函数不会被任何指令路径到达。

<!-- PTO-READER-BLOCK: tile-model-execution-elementwise-example role=example-usage -->
## 非规范阅读示例

考虑在 32 乘 4 元素、有效行为一行的 S32 Tile 上执行 TREMS，标量除数 3 位于 `a0`，没有 ExecutionMask：

```text
TREMS <Row=32, Col=4, ValidRow=1, S32>, T#1, a0, ->T<512B>
```

有效源行为 7、-7、6 和 -1。

1. 7 REM 3：商为 2，余数为 1。
2. -7 REM 3：截断商为 -2，余数为 -1。其符号与除数不同，因此加上 3，结果为 2。
3. 6 REM 3 为 0。
4. -1 REM 3：余数为 -1，因此结果为 2。

目标行为 1、2、0、2。整数路径不返回标志，因此数值状态不变。

<!-- PTO-READER-BLOCK: tile-model-execution-elementwise-related role=related-owners-navigation -->
## 相关所有者

- [操作数 schema](../legality/operand-schema.md)拥有这些处理函数运行前的合法性检查。
- [数据类型与布局合法性](../legality/dtype-layout.md)拥有类型集合。
- [最小值与最大值](minmax.md)拥有浮点 MIN 和 MAX 辅助函数。
- [执行掩码状态](execution-mask-state.md)拥有活动与非活动坐标的处理。
- [数值状态](../../../arch/state/numeric-status.md)拥有粘滞标志。
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
