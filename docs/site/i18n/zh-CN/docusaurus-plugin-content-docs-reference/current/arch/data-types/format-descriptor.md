<!-- GENERATED FROM: asl/arch/data-types/format-descriptor.asl -->
# Format Descriptor

**Normative ASL source:** `asl/arch/data-types/format-descriptor.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-format-descriptor-purpose role=purpose-scope -->
## 用途与范围

`NumericFormatDescriptor` 记录数值格式元数据是否可用；可用时，它描述载体宽度、逻辑 lane、字段宽度与位置、必须为零的约束位、指数偏置和受支持的值类别。

<!-- PTO-READER-BLOCK: arch-format-descriptor-concepts role=concepts-state -->
## 描述符结构

`NumericFormatKind` 区分不可用元数据、固定二进制格式、`HiF8` 和 `E8M0`。宽度字段描述载体、每个逻辑 lane、lane 数量，以及符号、指数和尾数字段。

其余字段说明是否存在指数偏置、有多少高位或低位必须为零，以及是否存在零、带符号零、次正规数、无穷大、静默 NaN 和信号 NaN 类别。

<!-- PTO-READER-BLOCK: arch-format-descriptor-rules role=rules-interactions -->
## 使用方式

嵌入的 `PTO-NUMERIC-FORMAT-DESCRIPTOR-001` 契约为每个浮点或缩放 Tile 数据类型分配一个确切描述符，并为整数 Tile 数据类型分配不可用结果。

描述符报告能力和布局；原始编码的解释仍由各格式自己的分解和分类函数定义。

<!-- PTO-READER-BLOCK: arch-format-descriptor-boundaries role=boundaries -->
## 不可用描述符

`UnavailableNumericFormatDescriptor` 把 `available` 设为 false，选择 `NumericFormatKind_Unavailable`，把所有宽度、位置、偏置和约束位字段清零，并关闭全部特殊值能力。

聚焦的边界 AVS 检查上面列出的不可用描述符字段；这句话记录证据范围，不定义另一条描述符规则。

<!-- PTO-READER-BLOCK: arch-format-descriptor-example role=example-usage -->
## 非规范阅读示例

下面是一种检查路径，不增加格式规则。

在把 Tile 数据类型按浮点格式解码之前，先检查 `available` 和 `kind`；再依据字段宽度与约束位计数，找到该格式的有效性、分解和分类所有者。

<!-- PTO-READER-BLOCK: arch-format-descriptor-related role=related-owners-navigation -->
## 相关所有者

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
