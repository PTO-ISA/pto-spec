<!-- GENERATED FROM: asl/tile/model/numeric/reference-fixed-binary.asl -->
# Reference Fixed Binary

**Normative ASL source:** `asl/tile/model/numeric/reference-fixed-binary.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-REFERENCE-FIXED-BINARY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-reference-fixed-binary-purpose role=purpose-scope -->
## 目的与范围

本单元为 Tile reference-conversion 路径提供确定性的有限值编码器。它负责普通与 reduced 浮点格式的有限端点，以及 `TF32`、`HF32` 与 `E5M2` 目标的精确舍入构造。

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-fixed-binary-concepts role=concepts-state -->
## 概念与可见状态

`ReferenceCommonFloatingEndpoint` 按请求符号返回 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3` 与 `E5M2` 的最大有限编码。`ReferenceCommonReducedFloatingEncoding` 接受有限 real 输入、reduced 目标类型，以及已解析的舍入和饱和控制，返回一个编码 `Word` 与五个数值状态位。

这些 reduced 格式共享指数归一化算法，但分别保留自己的 fraction scale、bias、normal 与 subnormal 界限、低位清零规则、无穷编码和有限端点。

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-fixed-binary-rules role=rules-interactions -->
## 规则与交互

零精确编码为正零。其他有限输入先归一化到 `[1,2)` 并得到整数指数，再按所选模式舍入一次。subnormal 结果在舍入前按格式的最小指数缩放。

溢出在启用饱和时返回带符号有限端点，否则返回带符号无穷编码；两者都报告 OF 与 NX。非精确 normal 结果报告 NX。非精确 subnormal 报告 UF 与 NX；若舍入把它提升为最小 normal，则只报告 NX。

`TF32` 保留 10 个 fraction 位并清零载体低 13 位。`HF32` 保留 11 个 fraction 位并清零低 12 位。`E5M2` 直接使用两个 fraction 位和八位编码。

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-fixed-binary-boundaries role=boundaries -->
## 架构边界

本单元只编码有限值。NaN、无穷、带符号零传播、源分类、整数转换以及是否记录状态仍由 reference-conversion 调用者负责。

扩展后的 TCVT 类型集不会新增标量 opcode，也不会改变标量转换接受的类型对。标量转换继续只使用既有子集，并禁用饱和。

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-fixed-binary-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL owner，不替代规范规则。

对于 `E5M2` 目标，超过可表示指数范围的正有限输入在启用饱和时返回 `0x7B`，否则返回 `0x7C`。两条路径都返回状态 `0x14`（OF 与 NX）。位于两个 E5M2 值之间的可表示结果遵循所选舍入模式并报告 NX。

<!-- PTO-READER-BLOCK: tile-model-numeric-reference-fixed-binary-related role=related-owners-navigation -->
## 相关 owner

- [Reference conversion](reference-conversion.md)对输入分类，并把 finite reduced-format 结果路由到本单元。
- [数值格式](formats.md)提供格式分类与分解。
- [Matrix quantization](../execution/matrix-quantization.md)提供公共舍入原语。
- [TCVT conversion](tcvt-conversion.md)负责封闭 scale 与 packed 转换族。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/reference-fixed-binary.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-REFERENCE-FIXED-BINARY","surface":"tile","classification":["model","numeric","reference-fixed-binary"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MATRIX-QUANTIZATION","PTO-TILE-MODEL-NUMERIC-FORMATS"]}

pure func ReferenceCommonFloatingEndpoint(
    data_type: TileDataType, negative: boolean) => Word
begin
    case data_type of
        when TileDataType_FP64 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xffefffffffffffff
                 else 0x7fefffffffffffff);
        when TileDataType_FP32 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7fffff else 0x7f7fffff);
        when TileDataType_TF32 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7fe000 else 0x7f7fe000);
        when TileDataType_HF32 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7ff000 else 0x7f7ff000);
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfbff else 0x7bff);
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xff7f else 0x7f7f);
        when TileDataType_E4M3 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfe else 0x7e);
        when TileDataType_E5M2 =>
            return Zeros{PTO_XLEN} +
                (if negative then 0xfb else 0x7b);
        otherwise => unreachable;
    end;
end;

func ReferenceCommonReducedFloatingEncoding(
    value: real,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert destination_type == TileDataType_TF32 ||
           destination_type == TileDataType_HF32 ||
           destination_type == TileDataType_E5M2;
    if value == 0.0 then return (Zeros{PTO_XLEN}, Zeros{5}); end;
    let negative = value < 0.0;
    var normalized = if negative then -value else value;
    var exponent: integer {-137..128} = 0;
    for step = 1 to 128 looplimit 128 do
        if normalized >= 2.0 && exponent < 128 then
            normalized = normalized / 2.0;
            exponent = (exponent + 1) as integer {-137..128};
        end;
    end;
    for step = 1 to 137 looplimit 137 do
        if normalized < 1.0 && exponent > -137 then
            normalized = normalized * 2.0;
            exponent = (exponent - 1) as integer {-137..128};
        end;
    end;
    let tf32 = destination_type == TileDataType_TF32;
    let hf32 = destination_type == TileDataType_HF32;
    let fraction_scale = if tf32 then 0x400
        else if hf32 then 0x800 else 4;
    let bias = if destination_type == TileDataType_E5M2 then 15 else 127;
    let maximum_exponent = if destination_type == TileDataType_E5M2
        then 15 else 127;
    let minimum_exponent = if destination_type == TileDataType_E5M2
        then -14 else -126;
    let minimum_subnormal_exponent = if tf32 then -136
        else if hf32 then -137 else -16;
    let low_zero_bits = if tf32 then 13 else if hf32 then 12 else 0;
    let sign = if negative then
        (if destination_type == TileDataType_E5M2
            then 0x80 else 0x80000000)
        else 0;
    let infinity = if destination_type == TileDataType_E5M2
        then 0x7c else 0x7f800000;
    if exponent > maximum_exponent then
        return (
            if control.saturating then
                ReferenceCommonFloatingEndpoint(destination_type, negative)
            else Zeros{PTO_XLEN} + sign + infinity,
            Zeros{5} + 0x14);
    end;
    if exponent < minimum_exponent then
        let scaled = normalized * ReferencePowerOfTwo(
            (exponent - minimum_subnormal_exponent)
                as integer {-1074..1023});
        var rounded = MatrixRoundMagnitude(
            scaled, control.rounding_mode, negative);
        if rounded < 0 then rounded = 0; end;
        let encoded = Zeros{PTO_XLEN} + sign + LSL(
            Zeros{PTO_XLEN} + rounded, low_zero_bits);
        let inexact = Real(rounded) != scaled;
        return (
            encoded,
            if !inexact then Zeros{5}
            else if rounded >= fraction_scale then Zeros{5} + 0x10
            else Zeros{5} + 0x18);
    end;
    let scaled = normalized * Real(fraction_scale);
    var rounded = MatrixRoundMagnitude(
        scaled, control.rounding_mode, negative);
    var encoded_exponent = exponent + bias;
    if rounded == 2 * fraction_scale then
        rounded = fraction_scale;
        encoded_exponent =
            (encoded_exponent + 1) as integer {-122..255};
    end;
    if encoded_exponent >= 2 * bias + 1 then
        return (
            if control.saturating then
                ReferenceCommonFloatingEndpoint(destination_type, negative)
            else Zeros{PTO_XLEN} + sign + infinity,
            Zeros{5} + 0x14);
    end;
    let fraction = rounded - fraction_scale;
    let code = encoded_exponent * fraction_scale + fraction;
    return (
        Zeros{PTO_XLEN} + sign +
            LSL(Zeros{PTO_XLEN} + code, low_zero_bits),
        if Real(rounded) == scaled then Zeros{5}
        else Zeros{5} + 0x10);
end;
```
<!-- GENERATED-ASL-END: unit -->
