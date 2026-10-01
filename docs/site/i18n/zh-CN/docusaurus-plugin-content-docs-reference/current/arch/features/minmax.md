<!-- GENERATED FROM: asl/arch/features/minmax.asl -->
# Minmax

**Normative ASL source:** `asl/arch/features/minmax.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-MINMAX}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-minmax-profile-purpose-scope role=purpose-scope -->
## 用途与范围

本单元包含某个具名硬件数值配置档的两个 `pure` 辅助函数：`HardwareNumericFloatingOrderKey(data_type, value) => (boolean, Word)` 把一个载体映射为无符号排序键，`HardwareNumericFloatingMinMax(maximum, data_type, left, right) => (boolean, Word, boolean)` 从两个载体中选出一个。

归属文件内没有 NDF 条款；它的规范内容就是这两个函数体及其注释。

每个结果的第一个元素是可用性位。`FALSE` 表示该配置档不给出键也不给出选择，此时返回的 `Word` 是占位值 `Zeros{PTO_XLEN}`。

<!-- PTO-READER-BLOCK: arch-minmax-profile-concepts-state role=concepts-state -->
## 排序键

每次求键都先调用 `TileNumericEncodingValid(data_type, value)`；未通过该检查的载体在任何位操作之前返回 `(FALSE, Zeros{PTO_XLEN})`。

- `FP64`：符号位是位 `63`；负载体返回对整个 `64` 位 `Word` 的 `NOT(value)`，非负载体返回 `value XOR (Zeros{PTO_XLEN} + 0x8000000000000000)`。
- `FP32`、`TF32`、`HF32`：`raw` 为 `value[31:0]`；负载体返回 `NOT(raw)`，否则返回 `raw XOR (Zeros{32} + 0x80000000)`，并零扩展到 `PTO_XLEN`。
- `FP16`、`BF16`：`raw` 为 `value[15:0]`，为负时按位取反，否则与 `0x8000` 异或，然后零扩展到 `PTO_XLEN`。
- `E4M3`、`E5M2`：`raw` 为 `value[7:0]`，为负时按位取反，否则与 `0x80` 异或，然后零扩展到 `PTO_XLEN`。
- 其他所有 `TileDataType` 都返回 `(FALSE, Zeros{PTO_XLEN})`。

设计要点：该变换把符号-数值表示改写为偏置序，对负载体按位取反，对非负载体置最高位。因此两个键的无符号比较就是对底层数值的排序，选择逻辑可以直接判定 `>=` 或 `<=`，而不必额外增加相等分支。

<!-- PTO-READER-BLOCK: arch-minmax-profile-rules-interactions role=rules-interactions -->
## 规则与交互

`HardwareNumericFloatingMinMax` 先调用 `HardwareNumericMinMaxSpecial`，当该处理程序报告已处理该数对时，原样返回它的结果。

否则会计算两个键。若任一键不可用，辅助函数返回 `(FALSE, Zeros{PTO_XLEN}, FALSE)`，因此即使不可用来自编码检查，该路径上的无效条件元素也是 `FALSE`。

当两个键都可用时，`maximum` 在 `UInt(left_key) >= UInt(right_key)` 时返回 `left`，否则返回 `right`；取最小分支使用 `UInt(left_key) <= UInt(right_key)` 并采用同样的回退，因此键相等时两种操作都选中 `left`。

设计要点：键辅助函数内部的编码检查只约束四种类型。`TileNumericEncodingValid` 用 `value[12:0] == Zeros{13}` 检查 `TF32`，用 `value[11:0] == Zeros{12}` 检查 `HF32`，用各自的规则检查 `E3M2` 与 `E2M3`，对其他所有类型都返回 `TRUE`。因此 `FP32`、`FP16`、`BF16`、`E4M3` 或 `E5M2` 载体绝不会因为该检查而键不可用，而低位不全为零的 `TF32` 或 `HF32` 载体则会。

<!-- PTO-READER-BLOCK: arch-minmax-profile-boundaries role=boundaries -->
## 架构边界

特殊情形在任何键存在之前就已判定。一个 NaN 操作数返回另一个载体，信号 NaN 会置起无效元素；两个 NaN 通过 `HardwareNumericCanonicalNaNResult` 返回该数据类型的规范 NaN。两个零只有在“两负零取最大”时返回 `left`，取最小时返回负零操作数，其他情况返回 `Zeros{PTO_XLEN}`。

位于键分支之外的类别（例如 `E3M2`）对特殊处理程序仍有值类别，但这类载体组成的普通数对没有排序键，会报告不可用。

设计要点：可用性位由 Tile 归属单元中的模型断言消费。`asl/tile/model/execution/minmax.asl` 中的 `TileFloatingMinMaxValue` 在返回选择之前断言 `available`，并把无效元素传给它的调用方；因此不受支持的类型或非法的 `TF32` 载体在该调用点变成断言失败，而不是静默的零结果。

本单元不定义指令、不定义故障、也不定义目的操作数；它只返回载体与状态元素。

<!-- PTO-READER-BLOCK: arch-minmax-profile-example-usage role=example-usage -->
## 非规范阅读示例

取两个正 `FP32` 规格化数 `0x3f800000` 与 `0x40000000`。两者都非负，因此翻转符号位后的键分别是 `0xbf800000` 与 `0xc0000000`。对 `maximum`，`UInt(0xbf800000) >= UInt(0xc0000000)` 为假，辅助函数返回右载体 `0x40000000`；对取最小，左侧比较为真，返回 `0x3f800000`。返回的 `Word` 是原始载体，而不是键。

取 `TF32` 载体 `0x3f800001`。它的位 `0` 为 `1`，因此 `value[12:0] == Zeros{13}` 失败，键辅助函数返回不可用，三元组为 `(FALSE, Zeros{PTO_XLEN}, FALSE)`：尽管该载体是非法 `TF32` 编码，无效元素仍为 `FALSE`。

同一数对若经 `TileFloatingMinMaxValue` 到达，就会走到 `assert available` 并使模型断言失败。

<!-- PTO-READER-BLOCK: arch-minmax-profile-related-owners role=related-owners-navigation -->
## 相关归属单元

- [硬件数值格式策略](mx-formats.md) 拥有 `TileNumericEncodingValid` 以及各类型的规范 NaN。
- [数值分类](../data-types/numeric-classification.md) 拥有各值类别与 `NumericValueClassIsZero`。
- [Tile 最小/最大执行](../../tile/model/execution/minmax.md) 是消费可用性位的调用方。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/minmax.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-MINMAX","surface":"arch","classification":["features","minmax"],"depends_on":["PTO-ARCH-FEATURES-MX-FORMATS"]}
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
