<!-- GENERATED FROM: asl/scalar/model/fsu/arithmetic.asl -->
# Arithmetic

**Normative ASL source:** `asl/scalar/model/fsu/arithmetic.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-FSU-ARITHMETIC}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-fsu-arithmetic-purpose role=purpose-scope -->
## 用途与范围

本单元是标量浮点算术的实数层。其大多数函数接收并返回数学 `real` 值或整数，而不是位编码。单元注释说明，编码、NaN 载荷、异常标志和舍入配置档规则与本层分开。

它还把三种舍入选择子译码为 `NumericRoundingMode` 枚举：标量活动模式、指令束 `RMode` 字段和公共转换序号。

<!-- PTO-READER-BLOCK: scalar-model-fsu-arithmetic-concepts role=concepts-state -->
## 概念与可见状态

舍入模式说明实数值如何变为可表示的值。`NumericRoundingMode` 有七个值：

| 模式 | 含义 |
| --- | --- |
| `NumericRound_RNE` | 就近，平局取偶 |
| `NumericRound_RTM` | 向负无穷 |
| `NumericRound_RTP` | 向正无穷 |
| `NumericRound_RTZ` | 向零 |
| `NumericRound_RNA` | 就近，平局远离零 |
| `NumericRound_RTO` | 取奇：不精确的值取奇数邻值 |
| `NumericRound_RHB` | 就近，平局向上 |

`FloatingToInteger` 应用其中一种模式把实数变为整数。[参考量化](reference-quantization.md)中的有限值编码器用它舍入缩放后的有效数。

本单元不保存状态。[标量 FP](scalar-fp.md)中的 `ScalarFPActiveRoundingMode` 读取 `CORE_STATE` 的位 39:37，并传给 `ResolveScalarFPActiveRoundingMode`。

<!-- PTO-READER-BLOCK: scalar-model-fsu-arithmetic-rules role=rules-interactions -->
## 规则与交互

`FloatingBinary`、`FloatingUnary` 和 `FloatingFused` 计算精确的实数结果。`FloatingFused` 形成乘积并加上或减去加数，中间不做舍入；`NMADD` 和 `NMSUB` 形式对整个结果取负。

设计要点：融合结果在实数算术中计算一次，之后由编码器舍入一次。正是这一次舍入把 `FMADD` 与先 `FMUL` 再 `FADD` 区分开来。

`FloatingUnary` 断言平方根输入非负，并对倒数计算 `1.0 / value`。在参考配置档中，特殊值层先处理 NaN、无穷大和零输入以及负的平方根输入，因此这些调用只看到其余的有限值。

`FloatingExponential` 对从 0 次到 18 次的泰勒级数项求和。ASL 注释称其为固定的 18 项确定性参考算法，而不是对宿主数学库的承诺。

`ResolveScalarFPActiveRoundingMode` 把 `001` 映射为 RTM、`010` 为 RTP、`011` 为 RTZ，其他每个值（包括 `000` 以及 `100` 到 `111`）映射为 RNE。

设计要点：每个 3 位值都解析为已定义的模式。写入 `CORE_STATE` 时不检查位 39:37，因此 `001`、`010` 或 `011` 以外的值得到 RNE，而不是故障或未定义结果。

`DecodeBundleRoundingSelection` 映射指令束 `RMode` 字段。编码 `000` 设置 `use_operation_default`；`001` 到 `111` 依次选择 RNE、RTZ、RTM、RTP、RNA、RTO 和 RHB。`DecodePublicConversionRoundingSelection` 把公共转换序号 0 到 6 转换为指令束编码，并把序号 7 报告为未分配。

<!-- PTO-READER-BLOCK: scalar-model-fsu-arithmetic-boundaries role=boundaries -->
## 架构边界

标量活动选择子与指令束 `RMode` 字段是不同的命名空间。同一个 3 位值在两者中表示不同模式；例如 `010` 在标量模式中是 RTP，在 `RMode` 中是 RTZ。

`FloatingCompare`、`SignedWordToReal`、`UnsignedWordToReal`、`ConvertFloatingEncoding` 和 `DecodePublicConversionRoundingSelection` 在规范 `asl/` 树中没有调用者；只有 `tests/asl/` 下的测试调用其中一部分。FSU 目录把 `ConvertFloatingEncoding` 列为转换形式的处理函数，但已译码分派通过 `ExecuteDecodedFPConvert` 执行转换。

`DecodeBundleRoundingSelection` 由指令束和 Tile 单元使用，例如 `tcvt-schema` 和 `cube`。

<!-- PTO-READER-BLOCK: scalar-model-fsu-arithmetic-example role=example-usage -->
## 非规范阅读示例

对四个平局和非平局输入应用 `FloatingToInteger`：

| 输入 | RNE | RNA | RTO | RHB | RTZ |
| --- | --- | --- | --- | --- | --- |
| 2.5 | 2 | 3 | 3 | 3 | 2 |
| -2.5 | -2 | -3 | -3 | -2 | -2 |
| 3.5 | 4 | 4 | 3 | 4 | 3 |
| 2.25 | 2 | 2 | 3 | 2 | 2 |

对于 -2.5，较小的整数为 -3，小数部分为 0.5。RNE 选择偶数 -2，RNA 因为值为负而选择 -3，RHB 因为小数 0.5 向上舍入而选择 -2。

<!-- PTO-READER-BLOCK: scalar-model-fsu-arithmetic-related role=related-owners-navigation -->
## 相关所有者

- [标量 FP](scalar-fp.md)读取活动模式并调用配置档钩子。
- [参考量化](reference-quantization.md)把实数结果舍入为 FP32、FP64 和 FP16 编码。
- [参考特殊值](reference-scalar-fp-specials.md)在本层之前处理 NaN、无穷大和零。
- [数值状态](../../../arch/state/numeric-status.md)拥有本层不触及的粘滞标志。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/fsu/arithmetic.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-FSU-ARITHMETIC","surface":"scalar","classification":["model","fsu","arithmetic"],"depends_on":["PTO-SCALAR-MODEL-SYS-REGISTERS","PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION"]}
// PTO-REQ-SCALAR-FP-001: mathematical floating semantics.
// Encoding, NaN payload, exception flag, and rounding-profile rules remain
// separate from this real-number value layer.

pure func FloatingBinary(op: FloatingBinaryOperation, left: real, right: real) => real
begin
    case op of
        when FloatingBinary_ADD => return left + right;
        when FloatingBinary_SUB => return left - right;
        when FloatingBinary_MUL => return left * right;
        when FloatingBinary_DIV => return left / right;
        when FloatingBinary_MIN => if left < right then return left; else return right; end;
        when FloatingBinary_MAX => if left > right then return left; else return right; end;
    end;
end;

pure func FloatingCompare(op: FloatingCompareOperation, left: real, right: real) => boolean
begin
    case op of
        when FloatingCompare_EQ => return left == right;
        when FloatingCompare_NE => return left != right;
        when FloatingCompare_LT => return left < right;
        when FloatingCompare_LE => return left <= right;
        when FloatingCompare_GT => return left > right;
        when FloatingCompare_GE => return left >= right;
    end;
end;

func FloatingExponential(value: real) => real
begin
    // PTO v0 fixes an 18-term Taylor reference algorithm. It is deterministic
    // executable evidence, not a promise of a host libm implementation.
    var result: real = 1.0;
    var term: real = 1.0;
    for index = 1 to 18 do
        term = (term * value) / Real(index);
        result = result + term;
    end;
    return result;
end;

func FloatingUnary(op: FloatingUnaryOperation, value: real) => real
begin
    case op of
        when FloatingUnary_ABS => if value < 0.0 then return -value; else return value; end;
        when FloatingUnary_SQRT =>
            assert value >= 0.0;
            return SqrtRounded(value, 100);
        when FloatingUnary_EXP => return FloatingExponential(value);
        when FloatingUnary_RECIP => return 1.0 / value;
    end;
end;

pure func FloatingFused(op: FloatingFusedOperation, addend: real,
                        left: real, right: real) => real
begin
    let product = left * right;
    case op of
        when FloatingFused_MADD => return product + addend;
        when FloatingFused_MSUB => return product - addend;
        when FloatingFused_NMADD => return -(product + addend);
        when FloatingFused_NMSUB => return -(product - addend);
    end;
end;

func FloatingRoundNearest(value: real) => integer
begin
    let lower = RoundDown(value);
    let fraction = value - Real(lower);
    if fraction < 0.5 then return lower;
    elsif fraction > 0.5 then return lower + 1;
    elsif lower MOD 2 == 0 then return lower;
    else return lower + 1;
    end;
end;

func FloatingToInteger(value: real, mode: NumericRoundingMode) => integer
begin
    case mode of
        when NumericRound_RNE => return FloatingRoundNearest(value);
        when NumericRound_RTP => return RoundUp(value);
        when NumericRound_RTM => return RoundDown(value);
        when NumericRound_RTZ => return RoundTowardsZero(value);
        when NumericRound_RNA =>
            let lower = RoundDown(value);
            let fraction = value - Real(lower);
            if fraction < 0.5 then return lower;
            elsif fraction > 0.5 then return lower + 1;
            elsif value < 0.0 then return lower;
            else return lower + 1;
            end;
        when NumericRound_RTO =>
            let lower = RoundDown(value);
            let fraction = value - Real(lower);
            if fraction == 0.0 then return lower;
            elsif lower MOD 2 != 0 then return lower;
            else return lower + 1;
            end;
        when NumericRound_RHB =>
            let lower = RoundDown(value);
            let fraction = value - Real(lower);
            if fraction < 0.5 then return lower;
            else return lower + 1;
            end;
    end;
end;

pure func ResolveScalarFPActiveRoundingMode(encoded: bits(3))
                                                => NumericRoundingMode
begin
    if encoded == '001' then return NumericRound_RTM;
    elsif encoded == '010' then return NumericRound_RTP;
    elsif encoded == '011' then return NumericRound_RTZ;
    else return NumericRound_RNE;
    end;
end;

pure func DecodeBundleRoundingSelection(encoded: bits(3))
                                                => TileNumericSelection
begin
    var result = TileNumericSelection {
        use_operation_default = encoded == '000',
        rounding_mode = NumericRound_RNE,
        saturating = FALSE
    };
    if encoded == '010' then result.rounding_mode = NumericRound_RTZ;
    elsif encoded == '011' then result.rounding_mode = NumericRound_RTM;
    elsif encoded == '100' then result.rounding_mode = NumericRound_RTP;
    elsif encoded == '101' then result.rounding_mode = NumericRound_RNA;
    elsif encoded == '110' then result.rounding_mode = NumericRound_RTO;
    elsif encoded == '111' then result.rounding_mode = NumericRound_RHB;
    end;
    return result;
end;

// Public conversion controls are not B.DATR encodings. Translate the seven
// assigned public ordinals explicitly; ordinal 7 is unassigned.
pure func DecodePublicConversionRoundingSelection(encoded: bits(3))
                                                => (boolean, TileNumericSelection)
begin
    if encoded == '000' then return (TRUE, DecodeBundleRoundingSelection('000'));
    elsif encoded == '001' then return (TRUE, DecodeBundleRoundingSelection('001'));
    elsif encoded == '010' then return (TRUE, DecodeBundleRoundingSelection('101'));
    elsif encoded == '011' then return (TRUE, DecodeBundleRoundingSelection('011'));
    elsif encoded == '100' then return (TRUE, DecodeBundleRoundingSelection('100'));
    elsif encoded == '101' then return (TRUE, DecodeBundleRoundingSelection('010'));
    elsif encoded == '110' then return (TRUE, DecodeBundleRoundingSelection('110'));
    else return (FALSE, DecodeBundleRoundingSelection('000'));
    end;
end;

pure func SignedWordToReal(value: Word) => real
begin
    return Real(SInt(value));
end;

pure func UnsignedWordToReal(value: Word) => real
begin
    return Real(UInt(value));
end;

func ConvertFloatingEncoding(value: Word, source_type: bits(5),
                             destination_type: bits(5),
                             rounding_mode: bits(3)) => Word
begin
    let (converted, -) = ScalarFPConvertProfile(
        ResolveScalarFPActiveRoundingMode(rounding_mode),
        destination_type, source_type, value);
    return converted;
end;
```
<!-- GENERATED-ASL-END: unit -->
