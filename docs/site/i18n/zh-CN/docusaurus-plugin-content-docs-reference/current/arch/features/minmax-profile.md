<!-- GENERATED FROM: asl/arch/features/minmax-profile.asl -->
# Minmax Profile

**Normative ASL source:** `asl/arch/features/minmax-profile.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-MINMAX-PROFILE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-minmax-profile-purpose-scope role=purpose-scope -->
## 目的与范围

本单元在特殊 NaN 和带符号零情况处理完毕后，为命名硬件数值配置提供普通浮点排序键以及最小值/最大值选择。

返回的可用性位会明确标出不支持的数据类型，而不会为所有 `TileDataType` 强行规定顺序。

<!-- PTO-READER-BLOCK: arch-minmax-profile-concepts-state role=concepts-state -->
## 概念与可见状态

- `HardwareNumericFloatingOrderKey` 验证载体，并将受支持的二进制浮点编码映射为单调递增的无符号键。
- 负载体按位取反；非负载体则在对应架构宽度上翻转符号位。
- `HardwareNumericFloatingMinMax` 先调用 `HardwareNumericMinMaxSpecial`，只有两个操作数都不是特殊情况时才比较普通排序键。

<!-- PTO-READER-BLOCK: arch-minmax-profile-rules-interactions role=rules-interactions -->
## 规则与交互

排序键辅助函数支持 `FP64`；`FP32`、`TF32` 和 `HF32`；`FP16` 和 `BF16`；以及 `E4M3` 和 `E5M2`。

无效编码和其他数据类型都返回不可用，并附带零占位键。

求最大值时选择较大的无符号键，求最小值时选择较小的键；键相等时选择左侧原始载体。

<!-- PTO-READER-BLOCK: arch-minmax-profile-boundaries role=boundaries -->
## 架构边界

NaN 和带符号零相等时的行为不由普通排序键推导，而是在比较前由 `HardwareNumericMinMaxSpecial` 处理。

这是命名配置的实现，不对返回不可用的格式作出可移植的排序承诺。

<!-- PTO-READER-BLOCK: arch-minmax-profile-example-usage role=example-usage -->
## 非规范阅读示例

对于两个有效的正 `FP32` 正规数，翻转符号位后得到的键与数值顺序一致，因此最小值或最大值会选择相应原始载体。

若任一操作数是无效 `TF32` 载体，普通键选择会报告不可用，而不会静默比较高位。

<!-- PTO-READER-BLOCK: arch-minmax-profile-related-owners role=related-owners-navigation -->
## 相关归属单元

- [硬件数值格式策略](mx-formats.md)
- [数值分类](../data-types/numeric-classification.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/minmax-profile.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-MINMAX-PROFILE","surface":"arch","classification":["features","minmax-profile"],"depends_on":["PTO-ARCH-FEATURES-MX-FORMATS"]}
// Convert an assigned binary floating carrier into a monotonically increasing
// unsigned key. NaNs and signed-zero ties are resolved before this helper is
// called. The returned availability bit keeps unsupported formats explicit.
pure func HardwareNumericFloatingOrderKey(
    data_type: TileDataType,
    value: Word) => (boolean, Word)
begin
    if !TileNumericEncodingValid(data_type, value) then
        return (FALSE, Zeros{PTO_XLEN});
    end;

    case data_type of
        when TileDataType_FP64 =>
            if value[63] == '1' then
                return (TRUE, NOT(value));
            else
                return (TRUE,
                    value XOR (Zeros{PTO_XLEN} + 0x8000000000000000));
            end;
        when TileDataType_FP32, TileDataType_TF32, TileDataType_HF32 =>
            let raw = value[31:0];
            let key =
                if raw[31] == '1' then NOT(raw)
                else raw XOR (Zeros{32} + 0x80000000);
            return (TRUE, ZeroExtend{PTO_XLEN}(key));
        when TileDataType_FP16, TileDataType_BF16 =>
            let raw = value[15:0];
            let key =
                if raw[15] == '1' then NOT(raw)
                else raw XOR (Zeros{16} + 0x8000);
            return (TRUE, ZeroExtend{PTO_XLEN}(key));
        when TileDataType_E4M3, TileDataType_E5M2 =>
            let raw = value[7:0];
            let key =
                if raw[7] == '1' then NOT(raw)
                else raw XOR (Zeros{8} + 0x80);
            return (TRUE, ZeroExtend{PTO_XLEN}(key));
        otherwise =>
            return (FALSE, Zeros{PTO_XLEN});
    end;
end;

// Return availability, selected raw carrier, and invalid-condition status.
// Special NaN and zero rules have priority over ordinary numeric ordering.
pure func HardwareNumericFloatingMinMax(
    maximum: boolean,
    data_type: TileDataType,
    left: Word,
    right: Word) => (boolean, Word, boolean)
begin
    let (special, special_result, invalid) =
        HardwareNumericMinMaxSpecial(maximum, data_type, left, right);
    if special then
        return (TRUE, special_result, invalid);
    end;

    let (left_available, left_key) =
        HardwareNumericFloatingOrderKey(data_type, left);
    let (right_available, right_key) =
        HardwareNumericFloatingOrderKey(data_type, right);
    if !left_available || !right_available then
        return (FALSE, Zeros{PTO_XLEN}, FALSE);
    end;

    if maximum then
        if UInt(left_key) >= UInt(right_key) then
            return (TRUE, left, FALSE);
        else
            return (TRUE, right, FALSE);
        end;
    elsif UInt(left_key) <= UInt(right_key) then
        return (TRUE, left, FALSE);
    else
        return (TRUE, right, FALSE);
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
