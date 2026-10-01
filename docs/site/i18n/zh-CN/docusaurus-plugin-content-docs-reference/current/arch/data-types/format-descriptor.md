<!-- GENERATED FROM: asl/arch/data-types/format-descriptor.asl -->
# Format Descriptor

**Normative ASL source:** `asl/arch/data-types/format-descriptor.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-format-descriptor-purpose role=purpose-scope -->
## 目的与范围

`NumericFormatDescriptor` 是公共记录，用来说明某个 Tile 数据类型是否有可用的数值格式元数据；可用时，它精确描述该格式。

一条记录承载载体宽度、逻辑 lane 宽度、每个载体的 lane 数量、符号、指数和尾数字段、必须为零的约束位、指数偏置，以及该格式支持的特殊值类别。

<!-- PTO-READER-BLOCK: arch-format-descriptor-concepts role=concepts-state -->
## 概念与可见状态

`NumericFormatKind` 区分 `NumericFormatKind_Unavailable`、各固定二进制格式、`HiF8` 和 `E8M0`，因此调用方可以分辨自己读到的是哪一种字段描述风格。

宽度字段 `carrier_bits`、`lane_bits` 和 `lanes_per_carrier` 说明一个载体有多少原始位、一个逻辑值占多少位，以及多少个值共享一个载体。

字段描述 `sign_bits`、`sign_bit`、`exponent_bits_min` 到 `exponent_bits_max`、`fraction_bits_min` 到 `fraction_bits_max`、`exponent_bias_available` 和 `exponent_bias` 给出 lane 各部分的位置与宽度，或者在格式会改变它们时给出范围。

<!-- PTO-READER-BLOCK: arch-format-descriptor-rules role=rules-interactions -->
## 规则与交互

设计要点：像 `HiF8` 这样的动态格式报告指数范围而不是单一宽度，因此该记录描述的是格式族而不是某一个载体，具体字段宽度来自该格式自己的解码器。

`required_low_zero_bits` 和 `required_high_zero_bits` 统计合法载体中必须为零的位数，这正是让 `TF32` 这样的截断载体与同宽度的全精度载体保持区别的方式。

其余布尔值说明是否存在零、带符号零、次正规数、无穷大、静默 NaN 和信号 NaN 编码，从而在解码某个原始载体之前告诉调用方它可以表示什么。

嵌入的 `PTO-NUMERIC-FORMAT-DESCRIPTOR-001` 条款要求每个已分配的浮点或缩放 Tile 数据类型暴露一个这种形状的确切描述符，并要求整数 Tile 数据类型报告不存在浮点格式描述符。

<!-- PTO-READER-BLOCK: arch-format-descriptor-boundaries role=boundaries -->
## 架构边界

设计要点：为每个已分配类型都要求描述符，而不是让字段保持未指定，意味着调用方永远不必猜测缺失值是表示窄格式还是表示缺失元数据。

描述符报告布局和能力；某个值的原始编码仍由该格式自己的分解和分类函数解释。

`UnavailableNumericFormatDescriptor` 把 `available` 设为 false，选择 `NumericFormatKind_Unavailable`，把所有宽度、位置、偏置和约束位字段清零，并清除全部特殊值能力。

按函数顺序阅读本页：先从描述符取得字段位置，然后用受限位计数选择各格式自己的有效性、分解和分类归属函数。

<!-- PTO-READER-BLOCK: arch-format-descriptor-example role=example-usage -->
## 非规范阅读示例

本例说明当前的 ASL 归属单元，不替代规范操作。

设计要点：不可用结果是字段齐全、能力全部清除的记录，因此忽略可用性的调用方读到的是零宽度和不支持任何类别，而不是任意一种格式。

阅读一个格式时先看 `available` 和 `kind`，再看字段宽度，然后是约束位计数，最后才看该格式自己的辅助函数。

在把 Tile 数据类型按浮点格式解码之前，先检查 `available` 和 `kind`；再依据字段宽度与约束位计数，找到该格式的有效性、分解和分类所有者。

<!-- PTO-READER-BLOCK: arch-format-descriptor-related role=related-owners-navigation -->
## 相关归属单元

- [Tile 数据类型](tile-data-types.md)定义已分配的 Tile 数据类型词汇。

- [数值格式](numeric-formats.md)把已分配类型分派到确切的描述符和值辅助函数。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/format-descriptor.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR","surface":"arch","classification":["data-types","format-descriptor"],"depends_on":["PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES"]}

// NDF-BEGIN: PTO-NUMERIC-FORMAT-DESCRIPTOR-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Each assigned floating or scale Tile DataType MUST expose one exact carrier,
// lane, field-width, bias, constrained-bit, and special-value descriptor.
// Integer Tile DataTypes MUST report that no floating-format descriptor exists.
// NDF-END: PTO-NUMERIC-FORMAT-DESCRIPTOR-001

// DOC-BEGIN: operation
type NumericFormatKind of enumeration {
    NumericFormatKind_Unavailable,
    NumericFormatKind_FixedBinary,
    NumericFormatKind_HiF8,
    NumericFormatKind_E8M0
};

type NumericFormatDescriptor of record {
    available: boolean,
    kind: NumericFormatKind,
    carrier_bits: integer {0..64},
    lane_bits: integer {0..64},
    lanes_per_carrier: integer {0..2},
    sign_bits: integer {0..1},
    sign_bit: integer {0..63},
    exponent_bits_min: integer {0..11},
    exponent_bits_max: integer {0..11},
    fraction_bits_min: integer {0..52},
    fraction_bits_max: integer {0..52},
    exponent_bias_available: boolean,
    exponent_bias: integer {0..1023},
    required_low_zero_bits: integer {0..13},
    required_high_zero_bits: integer {0..2},
    has_zero: boolean,
    has_signed_zero: boolean,
    has_subnormal: boolean,
    has_infinity: boolean,
    has_quiet_nan: boolean,
    has_signaling_nan: boolean
};

type HiF8DotField of enumeration {
    HiF8DotField_Denormal,
    HiF8DotField_D0,
    HiF8DotField_D1,
    HiF8DotField_D2,
    HiF8DotField_D3,
    HiF8DotField_D4
};

pure func UnavailableNumericFormatDescriptor() => NumericFormatDescriptor
begin
    return NumericFormatDescriptor {
        available = FALSE,
        kind = NumericFormatKind_Unavailable,
        carrier_bits = 0,
        lane_bits = 0,
        lanes_per_carrier = 0,
        sign_bits = 0,
        sign_bit = 0,
        exponent_bits_min = 0,
        exponent_bits_max = 0,
        fraction_bits_min = 0,
        fraction_bits_max = 0,
        exponent_bias_available = FALSE,
        exponent_bias = 0,
        required_low_zero_bits = 0,
        required_high_zero_bits = 0,
        has_zero = FALSE,
        has_signed_zero = FALSE,
        has_subnormal = FALSE,
        has_infinity = FALSE,
        has_quiet_nan = FALSE,
        has_signaling_nan = FALSE
    };
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
