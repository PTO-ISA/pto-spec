<!-- GENERATED FROM: asl/scalar/model/alu/semantics.asl -->
# Semantics

**Normative ASL source:** `asl/scalar/model/alu/semantics.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-ALU-SEMANTICS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-alu-semantics-purpose role=purpose-scope -->
## Purpose and scope

This unit holds the value rules for scalar integer, logic, shift, bitfield, multiply, and divide operations. Most functions are pure: they take `Word` values and return a `Word`. A few `Execute...Pair` functions also write two Reg5 destinations.

Decoded ALU instructions reach these functions through [ALU dispatch](../dispatch/alu.md), which reads the operands. `ExecuteScalarBinary`, which reads absolute GPRs directly, has no caller in the ASL tree.

<!-- PTO-READER-BLOCK: scalar-model-alu-semantics-concepts role=concepts-state -->
## Concepts and visible state

A `Word` is `PTO_XLEN` (64) bits. All 64-bit arithmetic wraps modulo 2^64. `MultiplyWord` returns the low 64 bits of the product; `MultiplyWideSigned` and `MultiplyWideUnsigned` return all 128 bits.

A word operation (suffix W) works on the low 32 bits and sign-extends its 32-bit result to 64 bits. `ScalarBinaryW` uses shift counts from the low five bits of the right operand; `ScalarBinary` uses the low six bits.

A right modifier transforms the right operand before use:

- `ScalarRight_SignedWord` sign-extends bits 31:0.
- `ScalarRight_UnsignedWord` zero-extends bits 31:0.
- `ScalarRight_NegateOrNot` applies bitwise NOT for the logical family and two's-complement negation otherwise.

`PrepareScalarRight` applies the modifier and then shifts left. `ApplyRestrictedCompareModifier` treats `ScalarRight_NegateOrNot` as no change. `ApplySelectModifier` treats it as negation and ignores the other modifiers.

<!-- PTO-READER-BLOCK: scalar-model-alu-semantics-rules role=rules-interactions -->
## Rules and interactions

Division never raises a fault. A zero divisor gives quotient 0 and returns the dividend as the remainder. Signed division divides magnitudes and negates when the signs differ, so the quotient rounds toward zero and the remainder has the dividend's sign.

Design point: the zero-divisor result is written out in the ASL instead of left to an exception. A program can divide by any value, including zero, and then test the result; no trap handler is involved. The signed-minimum overflow case is also defined without a fault: `0x8000000000000000` divided by -1 returns `0x8000000000000000` with remainder 0.

The W division helpers first sign-extend (signed) or zero-extend (unsigned) the low 32 bits of both inputs, apply the 64-bit rule, and sign-extend bits 31:0 of the result.

Bitfield helpers treat the value as a ring of 64 bits. `ExtractBitfield` rotates right by the offset and keeps `width` bits, sign-extending on request. `ModifyBitfield` sets or clears `width` bits starting at the offset. `InsertBitfield` computes its width from `first` and `last` modulo 64, so a field can wrap from bit 63 to bit 0. `ReverseBitfieldBytes` returns zero if the width is not a multiple of 8.

The pair functions compute both results from their inputs before writing either destination. `ExecuteScalarDividePair` writes quotient then remainder; `ExecuteScalarRemainderPair` writes remainder then quotient; the multiply pairs write low then high.

Design point: because the second write happens last, two destinations that name the same GPR end with the second result. Two pushes to the same T or U queue leave the second result newest.

<!-- PTO-READER-BLOCK: scalar-model-alu-semantics-boundaries role=boundaries -->
## Architectural boundaries

`ScalarBinaryW` supports only ADD, SUB, AND, OR, XOR, SLL, SRL, and SRA; it asserts for MIN and MAX variants. Decoded dispatch only passes the supported operations.

Apart from the uncalled `ExecuteScalarBinary`, this unit does not read operands. It does not decode fields or advance TPC. Operand snapshots and T/U queue selection belong to dispatch and [scalar operands](../types/operands.md).

`NaturalToWord` converts a natural number of at most 262144 into a `Word`. Many other units use it for address offsets.

<!-- PTO-READER-BLOCK: scalar-model-alu-semantics-example role=example-usage -->
## Non-normative reading example

Consider `ExecuteScalarDividePair` with dividend -7, divisor 2, signed.

- Magnitudes are 7 and 2, so the unsigned quotient is 3.
- The signs differ, so the quotient is -3.
- The remainder is -7 - (-3 x 2) = -1, which has the dividend's sign.
- The quotient destination is written first, then the remainder destination.

With divisor 0 the same call writes quotient 0 and remainder -7.

<!-- PTO-READER-BLOCK: scalar-model-alu-semantics-related role=related-owners-navigation -->
## Related owners

- [ALU dispatch](../dispatch/alu.md) maps each ALU form to these functions.
- [Operation types](../types/operations.md) defines `ScalarBinaryOperation` and `ScalarRightModifier`.
- [Scalar operands](../types/operands.md) owns Reg5 reads and destination writes.
- [BRU dispatch](../dispatch/bru.md) applies these modifiers to comparison operands.
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
