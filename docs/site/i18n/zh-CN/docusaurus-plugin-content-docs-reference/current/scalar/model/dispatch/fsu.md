<!-- GENERATED FROM: asl/scalar/model/dispatch/fsu.asl -->
# FSU

**Normative ASL source:** `asl/scalar/model/dispatch/fsu.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-FSU}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-dispatch-fsu-purpose role=purpose-scope -->
## 用途与范围

本单元执行每个已译码的标量浮点（FSU）形式。`ExecuteDecodedFSUForm` 把每个运算映射到五个辅助函数之一：

- `ExecuteDecodedFPUnary` 用于 `FABS`、`FEXP`、`FRECIP` 和 `FSQRT`；
- `ExecuteDecodedFPBinary` 用于 `FADD`、`FSUB`、`FMUL`、`FDIV`、`FMIN` 和 `FMAX`；
- `ExecuteDecodedFPCompare` 用于八种比较；
- `ExecuteDecodedFPFused` 用于 `FMADD`、`FMSUB`、`FNMADD` 和 `FNMSUB`；
- `ExecuteDecodedFPConvert` 用于 `FCVT`、`FCVTA`、`FCVTM`、`FCVTN`、`FCVTP`、`FCVTZ`、`SCVTF` 和 `UCVTF`。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-fsu-concepts role=concepts-state -->
## 概念与可见状态

载体是保存浮点值的 64 位寄存器字（GPR 或 T/U 条目）。2 位 `SrcType` 字段选择载体。对于算术运算，`00` 表示整字中的 FP64，`01` 表示位 31:0 中的 FP32。`NormalizeScalarFPSource` 对 FP32 载体做零扩展，因此源的位 63:32 被忽略。

对于转换，同一 2 位字段表示四种源类型。浮点转换使用 FP64、FP32、FP16 和 E4M3。`SCVTF` 使用 S64、S32、S16 和 S8；`UCVTF` 使用 U64、U32、U16 和 U8。5 位 `DstType` 字段表示目标类型。

`CORE_STATE` 中有两部分相关：

- 位 39:37 选择活动舍入模式，由 `ScalarFPActiveRoundingMode` 读取；
- 位 36:32 保存粘滞标志 NV、DZ、OF、UF 和 NX，由 `ScalarFPRecordFlags` 更新。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-fsu-rules role=rules-interactions -->
## 规则与交互

每个辅助函数先检查源类型，转换还检查目标类型。不受支持的类型引发 `Fault_IllegalInstruction`，并在读取任何源寄存器之前返回。

设计要点：类型合法性先于第一次源读取。因此被拒绝的 FSU 指令不读取 T/U 条目、不调用数值配置档、不写标志，也不写目标。目录把算术、比较和融合形式的 `SrcType` 限定为 0 或 1，并把转换形式的 `DstType` 限定为受支持的编码，因此在已译码路径上，`ScalarFormOperandsLegal` 已经拒绝了辅助函数内部检查会拒绝的每个编码。

检查之后，辅助函数读取源，计算结果和 5 位标志向量，把标志按位或入 `CORE_STATE`，并写入目标。

有些规则固定在本单元中，而不是由配置档决定：

- `FABS` 清除载体的符号位，不记录标志。
- `FMIN` 和 `FMAX` 使用 `ScalarFPMinMax`。它们仅在输入为信号 NaN 时记录 NV。
- 比较是有序比较。任何 NaN 输入都使结果为 0，`FNE` 也不例外。安静形式仅对信号 NaN 记录 NV；信号形式（`FEQS`、`FNES`、`FLTS`、`FGES`）对任何 NaN 记录 NV。结果为字 0 或 1。

设计要点：标志按位或入旧值，运算从不清除标志。因此之后读取 `CORE_STATE` 时，看到的是自 `CORE_STATE` 上次被整体写入（例如通过系统寄存器写入、复位或陷阱上下文恢复）以来所产生标志的并集。

算术运算以及 `FCVT`、`SCVTF` 和 `UCVTF` 使用活动舍入模式。`FCVTA`、`FCVTM`、`FCVTN`、`FCVTP` 和 `FCVTZ` 忽略它，分别使用 RNA、RTM、RNE、RTP 和 RTZ。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-fsu-boundaries role=boundaries -->
## 架构边界

数值结果来自[标量 FP](../fsu/scalar-fp.md)中的配置档钩子，例如 `ScalarFPBinaryProfile` 和 `ScalarFPConvertProfile`。算术配置档使用量化单元和特殊值单元；转换配置档使用[参考转换](../../../tile/model/numeric/reference-conversion.md)中的 `ReferenceCommonConvert`。

数值标志不会引发陷阱。本单元引发的唯一故障是针对不受支持类型的 `Fault_IllegalInstruction`；不可用的 T/U 源由顶层分派更早拒绝。

浮点转整数的 `DstType` 码 0 到 3 选择 U64、U32、U16 和 U8；码 4 到 7 选择 S64、S32、S16 和 S8。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-fsu-example role=example-usage -->
## 非规范阅读示例

取 32 位字 0x027302CB。它匹配 `FADD`（掩码 0xF800707F，匹配值 0x4B）。

| 字段 | 位 | 原始值 | 含义 |
| --- | --- | --- | --- |
| `RegDst` | 11:7 | 5 | GPR 5 |
| `SrcL` | 19:15 | 6 | GPR 6 |
| `SrcR` | 24:20 | 7 | GPR 7 |
| `SrcType` | 26:25 | `01` | FP32 |

设 GPR 6 持有 0xDEADBEEF3F800000，GPR 7 持有 0x40000000。只使用位 31:0，因此输入为 1.0 和 2.0。活动模式为 RNE 时，和 3.0 是精确的。GPR 5 接收 0x0000000040400000，不记录任何标志。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-fsu-related role=related-owners-navigation -->
## 相关所有者

- [标量 FP](../fsu/scalar-fp.md)拥有载体、类型码、比较、最小/最大值和配置档钩子。
- [FSU 算术](../fsu/arithmetic.md)拥有实数运算和舍入译码。
- [参考特殊值](../fsu/reference-scalar-fp-specials.md)拥有 NaN、无穷大和零的结果。
- [数值状态](../../../arch/state/numeric-status.md)拥有粘滞标志字段。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/fsu.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-FSU","surface":"scalar","classification":["model","dispatch","fsu"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-DECODE","PTO-SCALAR-MODEL-FSU-SCALAR-FP","PTO-SCALAR-FABS","PTO-SCALAR-FADD","PTO-SCALAR-FCVT","PTO-SCALAR-FCVTA","PTO-SCALAR-FCVTM","PTO-SCALAR-FCVTN","PTO-SCALAR-FCVTP","PTO-SCALAR-FCVTZ","PTO-SCALAR-FDIV","PTO-SCALAR-FEQ","PTO-SCALAR-FEQS","PTO-SCALAR-FEXP","PTO-SCALAR-FGE","PTO-SCALAR-FGES","PTO-SCALAR-FLT","PTO-SCALAR-FLTS","PTO-SCALAR-FMADD","PTO-SCALAR-FMAX","PTO-SCALAR-FMIN","PTO-SCALAR-FMSUB","PTO-SCALAR-FMUL","PTO-SCALAR-FNE","PTO-SCALAR-FNES","PTO-SCALAR-FNMADD","PTO-SCALAR-FNMSUB","PTO-SCALAR-FRECIP","PTO-SCALAR-FSQRT","PTO-SCALAR-FSUB","PTO-SCALAR-SCVTF","PTO-SCALAR-UCVTF"]}
pure func ScalarDecodedFPSourceType(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1}) => bits(2)
begin
    return DecodeScalarOperandRaw(instruction, form, ScalarField_SrcType)[1:0];
end;

func ExecuteDecodedFPBinary(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    operation: FloatingBinaryOperation)
begin
    let source_selector = ScalarDecodedFPSourceType(instruction, form);
    let source_type = ScalarFPSourceTypeCode(source_selector);
    if !ScalarFPTypeCodeSupported(source_type) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let left = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        source_type);
    let right = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        source_type);
    var result: Word;
    var flags: bits(5);
    if operation == FloatingBinary_MIN || operation == FloatingBinary_MAX then
        result = ScalarFPMinMax(operation, left, right, source_selector);
        flags = if ScalarFPIsSignalingNaN(left, source_selector) ||
                   ScalarFPIsSignalingNaN(right, source_selector)
                then Zeros{5} + 1 else Zeros{5};
    else
        (result, flags) = ScalarFPBinaryProfile(
            operation, ScalarFPActiveRoundingMode(), source_type, left, right);
    end;
    ScalarFPRecordFlags(flags);
    WriteScalarDestination(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        NormalizeScalarFPResult(result, source_type));
end;

func ExecuteDecodedFPUnary(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    operation: FloatingUnaryOperation)
begin
    let source_selector = ScalarDecodedFPSourceType(instruction, form);
    let source_type = ScalarFPSourceTypeCode(source_selector);
    if !ScalarFPTypeCodeSupported(source_type) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let value = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        source_type);
    var result: Word;
    var flags: bits(5);
    if operation == FloatingUnary_ABS then
        if source_selector == '01' then
            result = ZeroExtend{PTO_XLEN}(
                value[31:0] AND (Zeros{32} + 0x7fffffff));
        else
            result = value AND (Zeros{PTO_XLEN} + 0x7fffffffffffffff);
        end;
        flags = Zeros{5};
    else
        (result, flags) = ScalarFPUnaryProfile(
            operation, ScalarFPActiveRoundingMode(), source_type, value);
    end;
    ScalarFPRecordFlags(flags);
    WriteScalarDestination(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        NormalizeScalarFPResult(result, source_type));
end;

func ExecuteDecodedFPCompare(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    operation: FloatingCompareOperation, signaling: boolean)
begin
    let source_selector = ScalarDecodedFPSourceType(instruction, form);
    let source_type = ScalarFPSourceTypeCode(source_selector);
    if !ScalarFPTypeCodeSupported(source_type) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let left = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        source_type);
    let right = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        source_type);
    let any_nan = ScalarFPIsNaN(left, source_selector) ||
                  ScalarFPIsNaN(right, source_selector);
    let any_signaling_nan = ScalarFPIsSignalingNaN(left, source_selector) ||
                            ScalarFPIsSignalingNaN(right, source_selector);
    if (signaling && any_nan) || any_signaling_nan then
        ScalarFPRecordFlags(Zeros{5} + 1);
    end;
    let comparison = ScalarFPEncodingCompare(
        operation, left, right, source_selector);
    WriteScalarDestination(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        if comparison then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
end;

func ExecuteDecodedFPFused(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    operation: FloatingFusedOperation)
begin
    let source_selector = ScalarDecodedFPSourceType(instruction, form);
    let source_type = ScalarFPSourceTypeCode(source_selector);
    if !ScalarFPTypeCodeSupported(source_type) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let addend = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcA),
        source_type);
    let left = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        source_type);
    let right = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        source_type);
    let (result, flags) = ScalarFPFusedProfile(
        operation, ScalarFPActiveRoundingMode(), source_type,
        addend, left, right);
    ScalarFPRecordFlags(flags);
    WriteScalarDestination(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        NormalizeScalarFPResult(result, source_type));
end;

func ExecuteDecodedFPConvert(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    operation: ScalarOperation)
begin
    let source_selector = ScalarDecodedFPSourceType(instruction, form);
    let raw_destination_type = ScalarDecodedBits5(
        instruction, form, ScalarField_DstType);
    var source_type: bits(5);
    var destination_type: bits(5);
    var source_supported: boolean;
    var destination_supported: boolean;
    if operation == ScalarOperation_SCVTF then
        source_type = ScalarSignedIntegerSourceTypeCode(source_selector);
        destination_type = raw_destination_type;
        source_supported = ScalarConvertIntegerTypeCodeSupported(source_type);
        destination_supported =
            ScalarConvertFloatingTypeCodeSupported(destination_type);
    elsif operation == ScalarOperation_UCVTF then
        source_type = ScalarUnsignedIntegerSourceTypeCode(source_selector);
        destination_type = raw_destination_type;
        source_supported = ScalarConvertIntegerTypeCodeSupported(source_type);
        destination_supported =
            ScalarConvertFloatingTypeCodeSupported(destination_type);
    else
        source_type = ScalarConvertFloatingTypeCode(source_selector);
        source_supported =
            ScalarConvertFloatingTypeCodeSupported(source_type);
        if operation == ScalarOperation_FCVT then
            destination_type = raw_destination_type;
            destination_supported =
                ScalarConvertFloatingTypeCodeSupported(destination_type);
        else
            destination_type = ScalarFPToIntegerDestinationTypeCode(
                raw_destination_type);
            destination_supported =
                ScalarConvertIntegerTypeCodeSupported(destination_type);
        end;
    end;
    if !source_supported || !destination_supported then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;

    // Type legality is resolved before this first architectural source read.
    let value = ReadDecodedScalarRegister(
        instruction, form, ScalarField_SrcL);
    var result: Word;
    var flags: bits(5);
    if operation == ScalarOperation_FCVT then
        (result, flags) = ScalarFPConvertProfile(
            ScalarFPActiveRoundingMode(), destination_type, source_type,
            NormalizeScalarConvertFloating(value, source_type));
        result = NormalizeScalarConvertFloating(
            result, destination_type);
    elsif operation == ScalarOperation_SCVTF ||
          operation == ScalarOperation_UCVTF then
        (result, flags) = ScalarIntegerToFPProfile(
            ScalarFPActiveRoundingMode(), source_type, destination_type,
            NormalizeScalarIntegerSource(value, source_type));
        result = NormalizeScalarConvertFloating(
            result, destination_type);
    else
        let rounding_mode = ScalarFPFixedConversionRoundingMode(operation);
        (result, flags) = ScalarFPToIntegerProfile(
            rounding_mode, destination_type, source_type,
            NormalizeScalarConvertFloating(value, source_type));
        result = NormalizeScalarIntegerResult(result, destination_type);
    end;
    ScalarFPRecordFlags(flags);
    WriteScalarDestination(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst), result);
end;

func ExecuteDecodedFSUForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let operation = ScalarOperationOfForm(form);
    case operation of
        when ScalarOperation_FABS =>
            ExecuteDecodedFPUnary(instruction, form, FloatingUnary_ABS);
        when ScalarOperation_FEXP =>
            ExecuteDecodedFPUnary(instruction, form, FloatingUnary_EXP);
        when ScalarOperation_FRECIP =>
            ExecuteDecodedFPUnary(instruction, form, FloatingUnary_RECIP);
        when ScalarOperation_FSQRT =>
            ExecuteDecodedFPUnary(instruction, form, FloatingUnary_SQRT);
        when ScalarOperation_FADD =>
            ExecuteDecodedFPBinary(instruction, form, FloatingBinary_ADD);
        when ScalarOperation_FSUB =>
            ExecuteDecodedFPBinary(instruction, form, FloatingBinary_SUB);
        when ScalarOperation_FMUL =>
            ExecuteDecodedFPBinary(instruction, form, FloatingBinary_MUL);
        when ScalarOperation_FDIV =>
            ExecuteDecodedFPBinary(instruction, form, FloatingBinary_DIV);
        when ScalarOperation_FMIN =>
            ExecuteDecodedFPBinary(instruction, form, FloatingBinary_MIN);
        when ScalarOperation_FMAX =>
            ExecuteDecodedFPBinary(instruction, form, FloatingBinary_MAX);
        when ScalarOperation_FEQ => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_EQ, FALSE);
        when ScalarOperation_FEQS => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_EQ, TRUE);
        when ScalarOperation_FNE => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_NE, FALSE);
        when ScalarOperation_FNES => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_NE, TRUE);
        when ScalarOperation_FLT => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_LT, FALSE);
        when ScalarOperation_FLTS => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_LT, TRUE);
        when ScalarOperation_FGE => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_GE, FALSE);
        when ScalarOperation_FGES => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_GE, TRUE);
        when ScalarOperation_FMADD => ExecuteDecodedFPFused(
            instruction, form, FloatingFused_MADD);
        when ScalarOperation_FMSUB => ExecuteDecodedFPFused(
            instruction, form, FloatingFused_MSUB);
        when ScalarOperation_FNMADD => ExecuteDecodedFPFused(
            instruction, form, FloatingFused_NMADD);
        when ScalarOperation_FNMSUB => ExecuteDecodedFPFused(
            instruction, form, FloatingFused_NMSUB);
        when ScalarOperation_FCVT, ScalarOperation_FCVTA,
             ScalarOperation_FCVTM, ScalarOperation_FCVTN,
             ScalarOperation_FCVTP, ScalarOperation_FCVTZ,
             ScalarOperation_SCVTF, ScalarOperation_UCVTF =>
            ExecuteDecodedFPConvert(instruction, form, operation);
        otherwise => unreachable;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
