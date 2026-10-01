<!-- GENERATED FROM: asl/arch/data-types/formats/hif4x2.asl -->
# Hif4x2

**Normative ASL source:** `asl/arch/data-types/formats/hif4x2.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FORMAT-HIF4X2}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-format-hif4x2-purpose role=purpose-scope -->
## 用途与范围

`HiF4X2` 是已分配的 PTO 数值格式，其数值是以每两个四位 lane 打包进一个八位载体的形式存储；本单元拥有它的描述符、有限值分解、值分类和有符号零编码。

该所有者一次只暴露一个 lane，通过 `value[3:0]` 读取，因此需要读取载体两半的调用方必须自行切出高半部分。

设计要点：该记录把载体宽度与逻辑 lane 宽度分开，因此打包类型在一个载体中报告两个 lane，而单 lane 类型在其载体中只报告自己的 lane 宽度。

<!-- PTO-READER-BLOCK: arch-format-hif4x2-concepts role=concepts-state -->
## 载体与字段

描述符使用 `8` 位载体、`4` 位逻辑 lane，并且每个载体包含 `2` 个 lane。

lane 的符号位位于 `3`，`1` 个指数位位于 `2:2`，`2` 个尾数位位于 `1:0`，指数偏置为 `1`。

描述符把 `required_low_zero_bits` 和 `required_high_zero_bits` 都设为 `0`，因此每个八位载体容纳两个已定义的 lane 编码。

只需要值类别的读者可以在分类之后停止，因为分类从不要求分解可用。

<!-- PTO-READER-BLOCK: arch-format-hif4x2-rules role=rules-interactions -->
## 分解与分类

`HiF4X2FiniteDecomposition` 返回可用性、符号、整数有效数和二进制指数，使精确值为 `(-1)^sign * UInt(significand) * 2^exponent`；lane 的指数位取自 `2:2`，尾数取自 `1:0`。

`ClassifyHiF4X2` 把该 lane 归入零类别或带符号的正规数类别；该格式没有无穷大、没有 NaN，也没有次正规数编码，因此每个非零 lane 都是带符号的正规数。

指数位为零且尾数为零时选择带符号零，其余每个 lane 都是带符号的正规数。

<!-- PTO-READER-BLOCK: arch-format-hif4x2-boundaries role=boundaries -->
## 边界与确切编码

该所有者对两种非零情形都返回指数 `-2`：指数位为一时有效数为 `4` 加上尾数，指数位为零且尾数非零时有效数就是尾数本身；因此 lane `0x1` 表示 `0.25`，lane `0x5` 表示 `1.25`，而 lane `0x4` 与 `0x6` 分别确定 `1` 与 `1.5`。

设计要点：指数位在同一比例因子下选择两种有效数构造方式，因此该 lane 字段扩大了可表示量值的集合，而没有扩大指数范围。

设计要点：`0x00` 与负编码是同一量值的两个独立编码，因此保留符号位的调用方仍能分辨结果来自哪一个，即使二者都与零相等。

按函数顺序阅读本页：先从描述符取得字段位置，在需要值类别时调用分类函数，并且只在编码有效性通过之后才调用分解函数。

<!-- PTO-READER-BLOCK: arch-format-hif4x2-example role=example-usage -->
## 非规范阅读示例

本例说明当前的 ASL 归属单元，不替代规范操作。

lane `0x0` 是正零，lane `0x8` 是负零；该格式没有无穷大和 NaN lane。

lane `0x1` 是最小正非零值，分解为有效数 `1` 和指数 `-2`；lane `0x7` 具有最大量值，分解为有效数 `7` 和指数 `-2`，即 `1.75`。

<!-- PTO-READER-BLOCK: arch-format-hif4x2-related role=related-owners-navigation -->
## 相关归属单元

- [数值格式描述符](../format-descriptor.md)定义公共元数据记录。

- [数值格式](../numeric-formats.md)把 Tile 数据类型分派到各格式自己的辅助函数。

- [HiF4 缩放](hif4-scale.md)把共享缩放字应用到 HiF4 lane。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/formats/hif4x2.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-HIF4X2","surface":"arch","classification":["data-types","formats","hif4x2"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR"]}
// DOC-BEGIN: operation
// PTO-REQ-HARDWARE-NUMERIC-001: exact HiF4 E1M2 logical lanes.

pure func HiF4X2NumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = TRUE, kind = NumericFormatKind_FixedBinary,
        carrier_bits = 8, lane_bits = 4, lanes_per_carrier = 2,
        sign_bits = 1, sign_bit = 3,
        exponent_bits_min = 1, exponent_bits_max = 1,
        fraction_bits_min = 2, fraction_bits_max = 2,
        exponent_bias_available = TRUE, exponent_bias = 1,
        required_low_zero_bits = 0, required_high_zero_bits = 0,
        has_zero = TRUE, has_signed_zero = TRUE, has_subnormal = FALSE,
        has_infinity = FALSE, has_quiet_nan = FALSE,
        has_signaling_nan = FALSE
    };
end;

pure func HiF4X2FiniteDecomposition(value: Word)
    => (boolean, boolean, Word, integer {-1074..1023})
begin
    let lane = value[3:0];
    let exponent = lane[2:2];
    let fraction = lane[1:0];
    if exponent == Zeros{1} then
        if fraction == Zeros{2} then
            return (TRUE, lane[3] == '1', Zeros{PTO_XLEN}, 0);
        else return (TRUE, lane[3] == '1',
                     ZeroExtend{PTO_XLEN}(fraction), -2);
        end;
    else return (TRUE, lane[3] == '1',
                 LSL(Zeros{PTO_XLEN} + 1, 2) +
                     ZeroExtend{PTO_XLEN}(fraction), -2);
    end;
end;
pure func ClassifyHiF4X2(value: Word) => NumericValueClass
begin
    return NumericValueClassFromFiniteSign(value[3],
        value[2:0] == Zeros{3}, FALSE);
end;

pure func HiF4X2SignedZeroEncodings() => (Word, Word)
begin
    return (Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x8);
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
