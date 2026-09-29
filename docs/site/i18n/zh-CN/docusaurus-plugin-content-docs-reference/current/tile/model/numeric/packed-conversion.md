<!-- GENERATED FROM: asl/tile/model/numeric/packed-conversion.asl -->
# Packed Conversion

**Normative ASL source:** `asl/tile/model/numeric/packed-conversion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-PACKED-CONVERSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-packed-conversion-purpose role=purpose-scope -->
## 作用与范围

本单元拥有三种小格式（E2M1X2、E1M2X2 与 E6M2）的参考编码器。编码器把精确实数值转换为编码；其他辅助函数解码通道或打破平局。

- `ReferencePacked4FiniteValue` 解码一个四位 E2M1X2 或 E1M2X2 通道。
- `ReferencePacked4Encoding` 把实数值舍入到这些通道之一。
- `ReferenceE6M2Encoding` 把正实数值舍入到 E6M2 缩放编码。
- `ReferencePacked4CandidateBetter` 与 `ReferenceE6M2CandidateBetter` 在候选之间打破平局。

<!-- PTO-READER-BLOCK: tile-model-numeric-packed-conversion-concepts role=concepts-state -->
## 概念与可见状态

四位通道有一个符号位（位 3）和一个三位量级编码。编码 8 到 15 是编码 0 到 7 的相反数，因此编码 8 是负零。

| 量级编码 | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| E2M1X2 值 | 0.0 | 0.5 | 1.0 | 1.5 | 2.0 | 3.0 | 4.0 | 6.0 |
| E1M2X2 值 | 0.0 | 0.25 | 0.5 | 0.75 | 1.0 | 1.25 | 1.5 | 1.75 |

两种四位格式都没有无穷或 NaN。E6M2 无符号、没有零，从 0 到 254 的编码 `c` 表示 (4 + 低两位) / 4 x 2^(高六位 - 48)。编码 `0xFF` 是 NaN。

标志使用常量 `0x10` NX、`0x14` OF 加 NX，以及 `0x18` UF 加 NX。

<!-- PTO-READER-BLOCK: tile-model-numeric-packed-conversion-rules role=rules-interactions -->
## 规则与交互

`ReferencePacked4Encoding` 对精确零返回编码 0。量级大于格式最大值（6.0 或 1.75）为上溢，带 OF 与 NX。上溢结果对 E2M1X2 为编码 6 或 14，对 E1M2X2 为编码 7 或 15；不参考 `saturating` 控制。

否则编码器尝试全部 16 个编码，并保留最佳的合格编码。

- RTP 保留不小于该值的最小候选，RTM 保留不大于该值的最大候选。
- RTZ 与 RTO 保留介于零与该值之间、量级最大的候选。
- 就近模式保留最接近的候选。平局时，RNE 偏向偶数编码，RNA 偏向较大量级，RHB 偏向较大值。
- 随后 RTO 把不精确的偶数编码上移一位，到相邻的奇数编码。

设计要点：编码器搜索编码表，而不是操作指数位。其结果是每种舍入模式由哪些列出的值合格以及如何打破平局来定义，并且结果总是 16 个表项之一。

当结果不精确且很小时，以 UF 与 NX 报告下溢。E2M1X2 以所选值与 1.0 比较。E1M2X2 以输入量级与 0.25 比较。

`ReferenceE6M2Encoding` 对精确零返回编码 0 且不带标志，并断言其他输入为正。大于编码 `0xFE`（49152）的值上溢为 `0xFF`，饱和时为 `0xFE`，并带 OF 与 NX。否则在编码 0 到 254 中选择最接近者；RNE 以偶数编码打破平局，其他所有模式以较大值打破平局。小于编码 0（2^-48）且不精确的值报告 UF 与 NX。

<!-- PTO-READER-BLOCK: tile-model-numeric-packed-conversion-boundaries role=boundaries -->
## 架构边界

这些编码器只看到有限实数值：TCVT 转换包装函数先处理 NaN、无穷与带符号零。四位编码器自己处理有限值的符号；只有 E6M2 包装函数拒绝负输入，得到 `0xFF` 并带 NV。矩阵量化编码器 `ReferenceMatrixFloatingEncoding` 也调用这两个编码器。

涉及 E6M2 时 TCVT 合法性只允许 RNE 与 RNA，因此通过 TCVT 不会到达 E6M2 的其他平局规则。

<!-- PTO-READER-BLOCK: tile-model-numeric-packed-conversion-example role=example-usage -->
## 非规范阅读示例

把 2.5 编码为 E2M1X2。

- 相邻值为 2.0（编码 4）与 3.0（编码 5），距离都是 0.5。
- RNE 选择偶数编码 4（2.0），并带 NX。
- RNA 选择较大量级，即编码 5（3.0），并带 NX。
- RTO 先选择 2.0（编码 4），然后因为 4 是偶数而移到编码 5。

以 RNE 把负 0.3 编码为 E1M2X2。最接近的值为负 0.25（编码 9）。结果不精确，且 0.3 不小于 0.25，因此标志只有 NX。

<!-- PTO-READER-BLOCK: tile-model-numeric-packed-conversion-related role=related-owners-navigation -->
## 相关归属

- [TCVT conversion](tcvt-conversion.md) 用特殊值处理包装这些编码器。
- [Matrix quantization](../execution/matrix-quantization.md) 拥有 `ReferenceMatrixFloatingEncoding`。
- [E2M1X2 format](../../../arch/data-types/formats/e2m1x2.md) 与 [E1M2X2 format](../../../arch/data-types/formats/e1m2x2.md) 拥有通道编码。
- [E6M2 format](../../../arch/data-types/formats/e6m2.md) 拥有缩放编码。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/packed-conversion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-PACKED-CONVERSION","surface":"tile","classification":["model","numeric","packed-conversion"],"depends_on":["PTO-ARCH-FEATURES-MX-FORMATS","PTO-ARCH-DATA-TYPES-FORMAT-E6M2","PTO-ARCH-DATA-TYPES-FORMAT-RCPE6M2"]}

pure func ReferencePacked4FiniteValue(
    data_type: TileDataType, code: integer {0..15}) => real
begin
    assert data_type == TileDataType_E2M1X2 ||
           data_type == TileDataType_E1M2X2;
    let negative = code >= 8;
    let magnitude_code = if negative then code - 8 else code;
    var magnitude: real = 0.0;
    if data_type == TileDataType_E2M1X2 then
        case magnitude_code of
            when 0 => magnitude = 0.0;
            when 1 => magnitude = 0.5;
            when 2 => magnitude = 1.0;
            when 3 => magnitude = 1.5;
            when 4 => magnitude = 2.0;
            when 5 => magnitude = 3.0;
            when 6 => magnitude = 4.0;
            when 7 => magnitude = 6.0;
        end;
    else
        magnitude = Real(magnitude_code) / 4.0;
    end;
    if negative then return -magnitude; end;
    return magnitude;
end;

pure func ReferencePacked4CandidateBetter(
    target: real, candidate: real, candidate_code: integer {0..15},
    best: real, best_code: integer {0..15},
    mode: NumericRoundingMode) => boolean
begin
    let candidate_distance = if candidate >= target then
        candidate - target else target - candidate;
    let best_distance = if best >= target then
        best - target else target - best;
    if candidate_distance < best_distance then return TRUE;
    elsif candidate_distance > best_distance then return FALSE;
    end;
    if candidate == 0.0 && best == 0.0 && target < 0.0 then
        return candidate_code >= 8 && best_code < 8;
    end;
    if mode == NumericRound_RNE then
        return candidate_code MOD 2 == 0 && best_code MOD 2 != 0;
    elsif mode == NumericRound_RNA then
        let candidate_magnitude = if candidate < 0.0 then -candidate else candidate;
        let best_magnitude = if best < 0.0 then -best else best;
        return candidate_magnitude > best_magnitude;
    elsif mode == NumericRound_RTO then
        return candidate_code MOD 2 != 0 && best_code MOD 2 == 0;
    else
        return candidate > best;
    end;
end;

func ReferencePacked4Encoding(
    value: real, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert destination_type == TileDataType_E2M1X2 ||
           destination_type == TileDataType_E1M2X2;
    if value == 0.0 then return (Zeros{PTO_XLEN}, Zeros{5}); end;
    let negative = value < 0.0;
    let magnitude = if negative then -value else value;
    let maximum = if destination_type == TileDataType_E2M1X2 then 6.0
        else 1.75;
    if magnitude > maximum then
        return (
            Zeros{PTO_XLEN} + (if negative then
                (if destination_type == TileDataType_E2M1X2 then 14 else 15)
                else if destination_type == TileDataType_E2M1X2 then 6
                else 7),
            Zeros{5} + 0x14);
    end;

    var best_set = FALSE;
    var best_code: integer {0..15} = 0;
    var best_value: real = 0.0;
    for code = 0 to 15 do
        let candidate = ReferencePacked4FiniteValue(
            destination_type, code as integer {0..15});
        var eligible = TRUE;
        if control.rounding_mode == NumericRound_RTP then
            eligible = candidate >= value;
        elsif control.rounding_mode == NumericRound_RTM then
            eligible = candidate <= value;
        elsif control.rounding_mode == NumericRound_RTZ ||
              control.rounding_mode == NumericRound_RTO then
            eligible = if negative then candidate <= 0.0 && candidate >= value
                else candidate >= 0.0 && candidate <= value;
        end;
        if eligible then
                var better = !best_set;
                if best_set then
                    if control.rounding_mode == NumericRound_RTP then
                        better = candidate < best_value ||
                            (candidate == best_value && value < 0.0 &&
                             code >= 8 && best_code < 8);
                elsif control.rounding_mode == NumericRound_RTM then
                    better = candidate > best_value;
                elsif control.rounding_mode == NumericRound_RTZ ||
                      control.rounding_mode == NumericRound_RTO then
                    better = if negative then
                        candidate < best_value ||
                        (candidate == best_value &&
                         code >= 8 && best_code < 8)
                        else candidate > best_value;
                else
                    better = ReferencePacked4CandidateBetter(
                        value, candidate, code as integer {0..15},
                        best_value, best_code, control.rounding_mode);
                end;
            end;
            if better then
                best_set = TRUE;
                best_code = code as integer {0..15};
                best_value = candidate;
            end;
        end;
    end;
    assert best_set;
    if control.rounding_mode == NumericRound_RTO &&
       best_value != value && best_code MOD 2 == 0 then
        assert best_code < 15;
        best_code = (best_code + 1) as integer {0..15};
        best_value = ReferencePacked4FiniteValue(
            destination_type, best_code);
    end;
    let minimum_normal = if destination_type == TileDataType_E2M1X2
        then 1.0 else 0.25;
    let inexact = best_value != value;
    let best_magnitude = if best_value < 0.0 then -best_value else best_value;
    let underflow = if destination_type == TileDataType_E2M1X2 then
        inexact && best_magnitude < minimum_normal
        else inexact && magnitude < minimum_normal;
    return (Zeros{PTO_XLEN} + best_code,
            if underflow then Zeros{5} + 0x18
            else if inexact then Zeros{5} + 0x10
            else Zeros{5});
end;

pure func ReferenceE6M2CandidateBetter(
    target: real, candidate: real, candidate_code: integer {0..254},
    best: real, best_code: integer {0..254},
    mode: NumericRoundingMode) => boolean
begin
    let candidate_distance = if candidate >= target then
        candidate - target else target - candidate;
    let best_distance = if best >= target then
        best - target else target - best;
    if candidate_distance < best_distance then return TRUE;
    elsif candidate_distance > best_distance then return FALSE;
    end;
    if mode == NumericRound_RNE then
        return candidate_code MOD 2 == 0 && best_code MOD 2 != 0;
    elsif mode == NumericRound_RNA then
        return candidate > best;
    else
        return candidate > best;
    end;
end;

func ReferenceE6M2Encoding(
    value: real, control: NumericExecutionControl) => (Word, bits(5))
begin
    if value == 0.0 then return (Zeros{PTO_XLEN}, Zeros{5}); end;
    assert value > 0.0;
    let maximum = E6M2FiniteValue(Zeros{8} + 0xfe);
    if value > maximum then
        return (
            if control.saturating then Zeros{PTO_XLEN} + 0xfe
            else Zeros{PTO_XLEN} + 0xff,
            Zeros{5} + 0x14);
    end;

    var best_set = FALSE;
    var best_code: integer {0..254} = 0;
    var best_value: real = 0.0;
    for code = 0 to 254 do
        let candidate = E6M2FiniteValue(Zeros{8} + code);
        var better = !best_set;
        if best_set then
            better = ReferenceE6M2CandidateBetter(
                value, candidate, code as integer {0..254},
                best_value, best_code, control.rounding_mode);
        end;
        if better then
            best_set = TRUE;
            best_code = code as integer {0..254};
            best_value = candidate;
        end;
    end;
    assert best_set;
    let inexact = best_value != value;
    let underflow = inexact && value < E6M2FiniteValue(Zeros{8});
    return (Zeros{PTO_XLEN} + best_code,
            if underflow then Zeros{5} + 0x18
            else if inexact then Zeros{5} + 0x10
            else Zeros{5});
end;
```
<!-- GENERATED-ASL-END: unit -->
