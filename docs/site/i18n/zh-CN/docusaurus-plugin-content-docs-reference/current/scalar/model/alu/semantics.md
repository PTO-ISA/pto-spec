<!-- GENERATED FROM: asl/scalar/model/alu/semantics.asl -->
# Semantics

**Normative ASL source:** `asl/scalar/model/alu/semantics.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-ALU-SEMANTICS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-alu-semantics-purpose role=purpose-scope -->
## 用途与范围

本单元包含标量整数、逻辑、移位、位域、乘法和除法运算的取值规则。大多数函数是纯函数：接收 `Word` 值并返回一个 `Word`。少数 `Execute...Pair` 函数还会写入两个 Reg5 目标。

已译码的 ALU 指令通过[ALU 分派](../dispatch/alu.md)到达这些函数，由分派读取操作数。直接读取绝对 GPR 的 `ExecuteScalarBinary` 在 ASL 树中没有调用者。

<!-- PTO-READER-BLOCK: scalar-model-alu-semantics-concepts role=concepts-state -->
## 概念与可见状态

`Word` 为 `PTO_XLEN`（64）位。所有 64 位算术按 2^64 取模回绕。`MultiplyWord` 返回乘积的低 64 位；`MultiplyWideSigned` 和 `MultiplyWideUnsigned` 返回全部 128 位。

字运算（后缀 W）作用于低 32 位，并把 32 位结果符号扩展到 64 位。`ScalarBinaryW` 的移位计数取自右操作数的低五位；`ScalarBinary` 取低六位。

右操作数修饰符在使用前变换右操作数：

- `ScalarRight_SignedWord` 对位 31:0 做符号扩展。
- `ScalarRight_UnsignedWord` 对位 31:0 做零扩展。
- `ScalarRight_NegateOrNot` 对逻辑族做按位取反（NOT），其他情况下做二进制补码取负。

`PrepareScalarRight` 先应用修饰符，再左移。`ApplyRestrictedCompareModifier` 把 `ScalarRight_NegateOrNot` 视为不变。`ApplySelectModifier` 把它视为取负，并忽略其他修饰符。

<!-- PTO-READER-BLOCK: scalar-model-alu-semantics-rules role=rules-interactions -->
## 规则与交互

除法从不引发故障。除数为零时商为 0，余数返回被除数。有符号除法对绝对值做除法，并在符号不同时取负，因此商向零舍入，余数与被除数同号。

设计要点：零除数的结果在 ASL 中被明确写出，而不是交给异常处理。程序可以除以任何值（包括零），然后检查结果；不涉及陷阱处理程序。有符号最小值溢出情形同样有定义且不产生故障：`0x8000000000000000` 除以 -1 返回 `0x8000000000000000`，余数为 0。

W 除法辅助函数先对两个输入的低 32 位做符号扩展（有符号）或零扩展（无符号），应用 64 位规则，再对结果的位 31:0 做符号扩展。

位域辅助函数把值视为 64 位的环。`ExtractBitfield` 按偏移循环右移并保留 `width` 位，可按需符号扩展。`ModifyBitfield` 从偏移开始置位或清除 `width` 位。`InsertBitfield` 由 `first` 和 `last` 按模 64 计算宽度，因此字段可以从位 63 回绕到位 0。当宽度不是 8 的倍数时，`ReverseBitfieldBytes` 返回零。

成对函数在写任一目标之前，先由其输入计算出两个结果。`ExecuteScalarDividePair` 先写商后写余数；`ExecuteScalarRemainderPair` 先写余数后写商；乘法成对函数先写低位后写高位。

设计要点：由于第二次写入最后发生，两个目标指向同一 GPR 时，最终保留第二个结果。两次压入同一 T 或 U 队列时，第二个结果是最新条目。

<!-- PTO-READER-BLOCK: scalar-model-alu-semantics-boundaries role=boundaries -->
## 架构边界

`ScalarBinaryW` 只支持 ADD、SUB、AND、OR、XOR、SLL、SRL 和 SRA；对 MIN 和 MAX 变体会断言失败。译码分派只传入受支持的运算。

除未被调用的 `ExecuteScalarBinary` 外，本单元不读取操作数。它不译码字段，也不推进 TPC。操作数快照和 T/U 队列选择属于分派和[标量操作数](../types/operands.md)。

`NaturalToWord` 把不超过 262144 的自然数转换为 `Word`。许多其他单元用它计算地址偏移。

<!-- PTO-READER-BLOCK: scalar-model-alu-semantics-example role=example-usage -->
## 非规范阅读示例

考虑以被除数 -7、除数 2、有符号方式调用 `ExecuteScalarDividePair`。

- 绝对值为 7 和 2，因此无符号商为 3。
- 符号不同，因此商为 -3。
- 余数为 -7 - (-3 x 2) = -1，与被除数同号。
- 先写商目标，再写余数目标。

若除数为 0，同一调用写入商 0 和余数 -7。

<!-- PTO-READER-BLOCK: scalar-model-alu-semantics-related role=related-owners-navigation -->
## 相关所有者

- [ALU 分派](../dispatch/alu.md)把每个 ALU 形式映射到这些函数。
- [运算类型](../types/operations.md)定义 `ScalarBinaryOperation` 和 `ScalarRightModifier`。
- [标量操作数](../types/operands.md)拥有 Reg5 读取和目标写入。
- [BRU 分派](../dispatch/bru.md)对比较操作数应用这些修饰符。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/alu/semantics.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-ALU-SEMANTICS","surface":"scalar","classification":["model","alu","semantics"],"depends_on":["PTO-SCALAR-MODEL-TYPES-OPERANDS"]}
// PTO-REQ-SCALAR-ALU-001: PTO integer, logic, and shift value rules.

pure func MultiplyWord(left: Word, right: Word) => Word
begin
    var result: Word = Zeros{PTO_XLEN};
    for bit_index = 0 to PTO_XLEN - 1 do
        if right[bit_index] == '1' then
            result = result + LSL(left, bit_index);
        end;
    end;
    return result;
end;

pure func DivideWordUnsigned(dividend: Word, divisor: Word) => Word
begin
    assert !IsZero(divisor);
    var quotient: Word = Zeros{PTO_XLEN};
    var remainder: bits(PTO_XLEN + 1) = Zeros{PTO_XLEN + 1};
    let extended_divisor: bits(PTO_XLEN + 1) = ZeroExtend{PTO_XLEN + 1}(divisor);
    for bit_index = PTO_XLEN - 1 downto 0 do
        remainder = LSL(remainder, 1);
        remainder[0] = dividend[bit_index];
        if UInt(remainder) >= UInt(extended_divisor) then
            remainder = remainder - extended_divisor;
            quotient[bit_index] = '1';
        end;
    end;
    return quotient;
end;

pure func ScalarDivideUnsigned(dividend: Word, divisor: Word) => Word
begin
    if IsZero(divisor) then return Zeros{PTO_XLEN};
    else return DivideWordUnsigned(dividend, divisor);
    end;
end;

pure func ScalarRemainderUnsigned(dividend: Word, divisor: Word) => Word
begin
    if IsZero(divisor) then return dividend; end;
    let quotient = DivideWordUnsigned(dividend, divisor);
    return dividend - MultiplyWord(quotient, divisor);
end;

pure func ScalarDivideSigned(dividend: Word, divisor: Word) => Word
begin
    if IsZero(divisor) then return Zeros{PTO_XLEN}; end;
    let dividend_negative = dividend[PTO_XLEN - 1] == '1';
    let divisor_negative = divisor[PTO_XLEN - 1] == '1';
    let dividend_magnitude = if dividend_negative then Zeros{PTO_XLEN} - dividend else dividend;
    let divisor_magnitude = if divisor_negative then Zeros{PTO_XLEN} - divisor else divisor;
    let magnitude = DivideWordUnsigned(dividend_magnitude, divisor_magnitude);
    if dividend_negative != divisor_negative then return Zeros{PTO_XLEN} - magnitude;
    else return magnitude;
    end;
end;

pure func ScalarRemainderSigned(dividend: Word, divisor: Word) => Word
begin
    if IsZero(divisor) then return dividend; end;
    let quotient = ScalarDivideSigned(dividend, divisor);
    return dividend - MultiplyWord(quotient, divisor);
end;

pure func ScalarDivideUnsignedW(dividend: Word, divisor: Word) => Word
begin
    let dividend32 = ZeroExtend{PTO_XLEN}(dividend[31:0]);
    let divisor32 = ZeroExtend{PTO_XLEN}(divisor[31:0]);
    let quotient = ScalarDivideUnsigned(dividend32, divisor32);
    return SignExtend{PTO_XLEN}(quotient[31:0]);
end;

pure func ScalarRemainderUnsignedW(dividend: Word, divisor: Word) => Word
begin
    let dividend32 = ZeroExtend{PTO_XLEN}(dividend[31:0]);
    let divisor32 = ZeroExtend{PTO_XLEN}(divisor[31:0]);
    let remainder = ScalarRemainderUnsigned(dividend32, divisor32);
    return SignExtend{PTO_XLEN}(remainder[31:0]);
end;

pure func ScalarDivideSignedW(dividend: Word, divisor: Word) => Word
begin
    let dividend32 = SignExtend{PTO_XLEN}(dividend[31:0]);
    let divisor32 = SignExtend{PTO_XLEN}(divisor[31:0]);
    let quotient = ScalarDivideSigned(dividend32, divisor32);
    return SignExtend{PTO_XLEN}(quotient[31:0]);
end;

pure func ScalarRemainderSignedW(dividend: Word, divisor: Word) => Word
begin
    let dividend32 = SignExtend{PTO_XLEN}(dividend[31:0]);
    let divisor32 = SignExtend{PTO_XLEN}(divisor[31:0]);
    let remainder = ScalarRemainderSigned(dividend32, divisor32);
    return SignExtend{PTO_XLEN}(remainder[31:0]);
end;

pure func ScalarMultiplyW(left: Word, right: Word) => Word
begin
    let left32 = ZeroExtend{PTO_XLEN}(left[31:0]);
    let right32 = ZeroExtend{PTO_XLEN}(right[31:0]);
    let product = MultiplyWord(left32, right32);
    return SignExtend{PTO_XLEN}(product[31:0]);
end;

pure func MultiplyWideUnsigned(left: Word, right: Word) => DoubleWord
begin
    var result: DoubleWord = Zeros{PTO_XLEN * 2};
    let extended_left: DoubleWord = ZeroExtend{PTO_XLEN * 2}(left);
    for bit_index = 0 to PTO_XLEN - 1 do
        if right[bit_index] == '1' then result = result + LSL(extended_left, bit_index); end;
    end;
    return result;
end;

pure func MultiplyWideSigned(left: Word, right: Word) => DoubleWord
begin
    let left_negative = left[PTO_XLEN - 1] == '1';
    let right_negative = right[PTO_XLEN - 1] == '1';
    let left_magnitude = if left_negative then Zeros{PTO_XLEN} - left else left;
    let right_magnitude = if right_negative then Zeros{PTO_XLEN} - right else right;
    let magnitude = MultiplyWideUnsigned(left_magnitude, right_magnitude);
    if left_negative != right_negative then return Zeros{PTO_XLEN * 2} - magnitude;
    else return magnitude;
    end;
end;

pure func RotateRightWord(value: Word, amount: integer {0..63}) => Word
begin
    if amount == 0 then return value;
    else return LSR(value, amount) OR LSL(value, PTO_XLEN - amount);
    end;
end;

pure func RotateLeftWord(value: Word, amount: integer {0..63}) => Word
begin
    if amount == 0 then return value;
    else return LSL(value, amount) OR LSR(value, PTO_XLEN - amount);
    end;
end;

pure func ExtractBitfield(value: Word, width: integer {1..64},
                          offset: integer {0..63}, signed_result: boolean) => Word
begin
    let rotated = RotateRightWord(value, offset);
    var result: Word = Zeros{PTO_XLEN};
    for bit_index = 0 to width - 1 do result[bit_index] = rotated[bit_index]; end;
    if signed_result && result[width - 1] == '1' then
        for bit_index = width to PTO_XLEN - 1 do result[bit_index] = '1'; end;
    end;
    return result;
end;

pure func CountBitfield(value: Word, width: integer {1..64},
                        offset: integer {0..63}, leading: boolean,
                        population: boolean) => Word
begin
    let field = ExtractBitfield(value, width, offset, FALSE);
    var count: integer = 0;
    if population then
        for bit_index = 0 to width - 1 do
            if field[bit_index] == '1' then count = count + 1; end;
        end;
    elsif leading then
        var searching = TRUE;
        for bit_index = 0 to width - 1 do
            let selected = (width - 1) - bit_index;
            if searching && field[selected] == '0' then count = count + 1;
            else searching = FALSE;
            end;
        end;
    else
        var searching = TRUE;
        for bit_index = 0 to width - 1 do
            if searching && field[bit_index] == '0' then count = count + 1;
            else searching = FALSE;
            end;
        end;
    end;
    assert count <= 64;
    return NaturalToWord(count as integer {0..262144});
end;

pure func ModifyBitfield(value: Word, width: integer {1..64},
                         offset: integer {0..63}, set_bits: boolean) => Word
begin
    var rotated = RotateRightWord(value, offset);
    for bit_index = 0 to width - 1 do
        rotated[bit_index] = if set_bits then '1' else '0';
    end;
    return RotateLeftWord(rotated, offset);
end;

pure func ReverseBitfieldBytes(value: Word, width: integer {1..64},
                               offset: integer {0..63}) => Word
begin
    if width MOD 8 != 0 then return Zeros{PTO_XLEN}; end;
    let field = ExtractBitfield(value, width, offset, FALSE);
    let byte_count = width DIV 8;
    var result: Word = Zeros{PTO_XLEN};
    for byte_index = 0 to byte_count - 1 do
        result[(((byte_count - 1) - byte_index) * 8) +: 8] = field[(byte_index * 8) +: 8];
    end;
    return result;
end;

pure func ScalarMultiplyAdd(addend: Word, left: Word, right: Word) => Word
begin
    return addend + MultiplyWord(left, right);
end;

pure func ScalarMultiplyAddW(addend: Word, left: Word, right: Word) => Word
begin
    let product = MultiplyWord(left, right);
    let result: bits(32) = product[31:0] + addend[31:0];
    return SignExtend{PTO_XLEN}(result);
end;

pure func ScalarConditionalSelect(predicate: Word, selected_true: Word,
                                  selected_false: Word) => Word
begin
    if !IsZero(predicate) then return selected_true; else return selected_false; end;
end;

pure func ApplyScalarRightModifier(value: Word, modifier: ScalarRightModifier,
                                   logical_family: boolean) => Word
begin
    case modifier of
        when ScalarRight_None => return value;
        when ScalarRight_SignedWord => return SignExtend{PTO_XLEN}(value[31:0]);
        when ScalarRight_UnsignedWord => return ZeroExtend{PTO_XLEN}(value[31:0]);
        when ScalarRight_NegateOrNot =>
            if logical_family then return NOT(value);
            else return Zeros{PTO_XLEN} - value;
            end;
    end;
end;

pure func ApplyRestrictedCompareModifier(value: Word,
                                         modifier: ScalarRightModifier) => Word
begin
    if modifier == ScalarRight_NegateOrNot then return value;
    else return ApplyScalarRightModifier(value, modifier, FALSE);
    end;
end;

pure func ApplySelectModifier(value: Word, modifier: ScalarRightModifier) => Word
begin
    if modifier == ScalarRight_NegateOrNot then return Zeros{PTO_XLEN} - value;
    else return value;
    end;
end;

pure func PrepareScalarRight(value: Word, modifier: ScalarRightModifier,
                             shift_amount: integer {0..63},
                             logical_family: boolean) => Word
begin
    return LSL(ApplyScalarRightModifier(value, modifier, logical_family), shift_amount);
end;

pure func MaterializeLUI(immediate: bits(20)) => Word
begin
    return LSL(SignExtend{PTO_XLEN}(immediate), 12);
end;

pure func MaterializeLongSigned(immediate: bits(32)) => Word
begin
    return SignExtend{PTO_XLEN}(immediate);
end;

pure func MaterializeLongUpper(immediate: bits(32)) => Word
begin
    return LSL(ZeroExtend{PTO_XLEN}(immediate), 32);
end;

pure func MaterializeLongUnsigned(immediate: bits(32)) => Word
begin
    return ZeroExtend{PTO_XLEN}(immediate);
end;

// The move primitive is explicit so catalog handler identity and decoded
// operand-to-effect binding do not rely on an unrelated modifier helper.
pure func MoveScalarValue(value: Word) => Word
begin
    return value;
end;

pure func ExtendScalarValue(value: Word, width: integer {8,16,32},
                            signed_result: boolean) => Word
begin
    case width of
        when 8 =>
            if signed_result then return SignExtend{PTO_XLEN}(value[7:0]);
            else return ZeroExtend{PTO_XLEN}(value[7:0]); end;
        when 16 =>
            if signed_result then return SignExtend{PTO_XLEN}(value[15:0]);
            else return ZeroExtend{PTO_XLEN}(value[15:0]); end;
        when 32 =>
            if signed_result then return SignExtend{PTO_XLEN}(value[31:0]);
            else return ZeroExtend{PTO_XLEN}(value[31:0]); end;
    end;
end;

pure func ScalarMultiplyImmediateAdd(left: Word, right: Word,
                                    immediate: bits(19), subtract: boolean) => Word
begin
    let product = MultiplyWord(right, ZeroExtend{PTO_XLEN}(immediate));
    if subtract then return left - product; else return left + product; end;
end;

pure func InsertBitfield(base: Word, source: Word,
                         first: integer {0..63}, last: integer {0..63}) => Word
begin
    let width: integer = (((last - first) + 64) MOD 64) + 1;
    var result = base;
    for bit_index = 0 to width - 1 do
        let destination = ((first + bit_index) MOD 64) as integer {0..63};
        result[destination] = source[bit_index];
    end;
    return result;
end;

func ExecuteConcatenatePair(destination_low: Reg5Selector,
                            destination_high: Reg5Selector,
                            left: Word, right: Word,
                            shift_amount: integer {0..127})
begin
    let low = InstructionContractLowResult_HL_CCAT(
        left,
        right,
        shift_amount);
    let high = InstructionContractHighResult_HL_CCAT(
        left,
        right,
        shift_amount);
    WriteScalarDestination(destination_low, low);
    WriteScalarDestination(destination_high, high);
end;

func ExecuteConcatenatePairW(destination_low: Reg5Selector,
                             destination_high: Reg5Selector,
                             left: Word, right: Word,
                             shift_amount: integer {0..127})
begin
    let low = InstructionContractLowResult_HL_CCATW(
        left,
        right,
        shift_amount);
    let high = InstructionContractHighResult_HL_CCATW(
        left,
        right,
        shift_amount);
    WriteScalarDestination(destination_low, low);
    WriteScalarDestination(destination_high, high);
end;

func ExecuteScalarDividePair(destination_quotient: Reg5Selector,
                             destination_remainder: Reg5Selector,
                             left: Word, right: Word, signed_operation: boolean)
begin
    let quotient = if signed_operation then ScalarDivideSigned(left, right)
                   else ScalarDivideUnsigned(left, right);
    let remainder = if signed_operation then ScalarRemainderSigned(left, right)
                    else ScalarRemainderUnsigned(left, right);
    WriteScalarDestination(destination_quotient, quotient);
    WriteScalarDestination(destination_remainder, remainder);
end;

func ExecuteScalarRemainderPair(destination_remainder: Reg5Selector,
                                destination_quotient: Reg5Selector,
                                left: Word, right: Word,
                                signed_operation: boolean)
begin
    let quotient = if signed_operation then ScalarDivideSigned(left, right)
                   else ScalarDivideUnsigned(left, right);
    let remainder = if signed_operation then ScalarRemainderSigned(left, right)
                    else ScalarRemainderUnsigned(left, right);
    WriteScalarDestination(destination_remainder, remainder);
    WriteScalarDestination(destination_quotient, quotient);
end;

func ExecuteScalarDividePairW(destination_quotient: Reg5Selector,
                              destination_remainder: Reg5Selector,
                              left: Word, right: Word, signed_operation: boolean)
begin
    let quotient = if signed_operation then ScalarDivideSignedW(left, right)
                   else ScalarDivideUnsignedW(left, right);
    let remainder = if signed_operation then ScalarRemainderSignedW(left, right)
                    else ScalarRemainderUnsignedW(left, right);
    WriteScalarDestination(destination_quotient, quotient);
    WriteScalarDestination(destination_remainder, remainder);
end;

func ExecuteScalarRemainderPairW(destination_remainder: Reg5Selector,
                                 destination_quotient: Reg5Selector,
                                 left: Word, right: Word,
                                 signed_operation: boolean)
begin
    let quotient = if signed_operation then ScalarDivideSignedW(left, right)
                   else ScalarDivideUnsignedW(left, right);
    let remainder = if signed_operation then ScalarRemainderSignedW(left, right)
                    else ScalarRemainderUnsignedW(left, right);
    WriteScalarDestination(destination_remainder, remainder);
    WriteScalarDestination(destination_quotient, quotient);
end;

func ExecuteScalarMultiplyPair(destination_low: Reg5Selector, destination_high: Reg5Selector,
                               left: Word, right: Word, signed_operation: boolean)
begin
    let product = if signed_operation then MultiplyWideSigned(left, right)
                  else MultiplyWideUnsigned(left, right);
    WriteScalarDestination(destination_low, product[63:0]);
    WriteScalarDestination(destination_high, product[127:64]);
end;

func ExecuteScalarMultiplyAddPair(destination_low: Reg5Selector,
                                  destination_high: Reg5Selector,
                                  addend: Word, left: Word, right: Word,
                                  word_operation: boolean)
begin
    let effective_addend = if word_operation then SignExtend{PTO_XLEN}(addend[31:0]) else addend;
    let effective_left = if word_operation then SignExtend{PTO_XLEN}(left[31:0]) else left;
    let effective_right = if word_operation then SignExtend{PTO_XLEN}(right[31:0]) else right;
    let product = MultiplyWideSigned(effective_left, effective_right);
    let accumulator = product + SignExtend{PTO_XLEN * 2}(effective_addend);
    if word_operation then
        WriteScalarDestination(
            destination_low,
            SignExtend{PTO_XLEN}(accumulator[31:0]));
        WriteScalarDestination(
            destination_high,
            SignExtend{PTO_XLEN}(accumulator[63:32]));
    else
        WriteScalarDestination(destination_low, accumulator[63:0]);
        WriteScalarDestination(destination_high, accumulator[127:64]);
    end;
end;

pure func NaturalToWord(value: integer {0..262144}) => Word
begin
    var result: Word = Zeros{PTO_XLEN};
    for step = 1 to value looplimit 262145 do
        result = result + 1;
    end;
    return result;
end;

pure func ScalarBinary(op: ScalarBinaryOperation, left: Word, right: Word) => Word
begin
    case op of
        when ScalarBinary_ADD => return left + right;
        when ScalarBinary_SUB => return left - right;
        when ScalarBinary_AND => return left AND right;
        when ScalarBinary_OR  => return left OR right;
        when ScalarBinary_XOR => return left XOR right;
        when ScalarBinary_SLL => return LSL(left, UInt(right[5:0]));
        when ScalarBinary_SRL => return LSR(left, UInt(right[5:0]));
        when ScalarBinary_SRA => return ASR(left, UInt(right[5:0]));
        when ScalarBinary_MIN =>
            if SInt(left) < SInt(right) then return left; else return right; end;
        when ScalarBinary_MINU =>
            if UInt(left) < UInt(right) then return left; else return right; end;
        when ScalarBinary_MAX =>
            if SInt(left) > SInt(right) then return left; else return right; end;
        when ScalarBinary_MAXU =>
            if UInt(left) > UInt(right) then return left; else return right; end;
    end;
end;

pure func ScalarBinaryW(op: ScalarBinaryOperation, left: Word, right: Word) => Word
begin
    let left32: bits(32) = left[31:0];
    let right32: bits(32) = right[31:0];
    var result32: bits(32);
    case op of
        when ScalarBinary_ADD => result32 = left32 + right32;
        when ScalarBinary_SUB => result32 = left32 - right32;
        when ScalarBinary_AND => result32 = left32 AND right32;
        when ScalarBinary_OR  => result32 = left32 OR right32;
        when ScalarBinary_XOR => result32 = left32 XOR right32;
        when ScalarBinary_SLL => result32 = LSL(left32, UInt(right[4:0]));
        when ScalarBinary_SRL => result32 = LSR(left32, UInt(right[4:0]));
        when ScalarBinary_SRA => result32 = ASR(left32, UInt(right[4:0]));
        otherwise => assert FALSE;
    end;
    return SignExtend{PTO_XLEN}(result32);
end;

func ExecuteScalarBinary(op: ScalarBinaryOperation, destination: GPRIndex,
                         source_left: GPRIndex, source_right: GPRIndex)
begin
    let left = ReadGPR(source_left);
    let right = ReadGPR(source_right);
    let result = ScalarBinary(op, left, right);
    WriteGPR(destination, result);
end;
```
<!-- GENERATED-ASL-END: unit -->
