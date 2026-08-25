<!-- GENERATED FROM: asl/arch/data-types/numeric-formats.asl -->
# Numeric Formats

**Normative ASL source:** `asl/arch/data-types/numeric-formats.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-numeric-formats-purpose-scope role=purpose-scope -->
## 目的与范围

本单元是从 `TileDataType` 到各浮点或缩放格式描述符及精确有限值分解的中央分派器。

它为调用方提供统一的类型化入口，同时保留各格式文件对自身原始编码的所有权。

<!-- PTO-READER-BLOCK: arch-numeric-formats-concepts-state role=concepts-state -->
## 概念与可见状态

- `TileNumericFormatDescriptor` 将从 `FP64` 到 `HiF4X2` 的所有已声明浮点与缩放数据类型分派到各自的格式描述符。
- `TileNumericFiniteDecomposition` 将同一组格式分派到精确有限值分解，并在需要时把 `Word` 载体缩窄到架构宽度。
- 分解结果依次为可用性、符号、整数有效数和整数指数，表示 `(-1)^sign * UInt(significand) * 2^exponent`。

<!-- PTO-READER-BLOCK: arch-numeric-formats-rules-interactions role=rules-interactions -->
## 规则与交互

有效的有限浮点或缩放编码无需宿主浮点算术即可完成分解。

无效内部编码、无穷大、NaN 和整数 `TileDataType` 成员都报告不可用。

没有匹配分支的描述符请求返回 `UnavailableNumericFormatDescriptor`；没有匹配分支的分解返回 `(FALSE, FALSE, Zeros{PTO_XLEN}, 0)`。

<!-- PTO-READER-BLOCK: arch-numeric-formats-boundaries role=boundaries -->
## 架构边界

本单元不会用宿主算术重新解释返回结果；整数有效数和指数就是精确交换契约。

格式可用不等于操作受支持。使用方指令或命名配置可以进一步限制可接受的数据类型。

<!-- PTO-READER-BLOCK: arch-numeric-formats-example-usage role=example-usage -->
## 非规范阅读示例

对于 `TileDataType_TF32`，分派器把 `value[31:0]` 传给 `TF32FiniteDecomposition`，因此必须为零的低位由 `TF32` 归属单元检查。

对于 `TileDataType_S32`，没有浮点分解分支，因此可用性为假，而不会构造一套整数分解。

<!-- PTO-READER-BLOCK: arch-numeric-formats-related-owners role=related-owners-navigation -->
## 相关归属单元

- [Tile 数据类型命名空间](tile-data-types.md)
- [数值分类](numeric-classification.md)
- [TF32 格式](formats/tf32.md)
- [HiF8 格式](formats/hif8.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/numeric-formats.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS","surface":"arch","classification":["data-types","numeric-formats"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-FP64","PTO-ARCH-DATA-TYPES-FORMAT-FP32","PTO-ARCH-DATA-TYPES-FORMAT-TF32","PTO-ARCH-DATA-TYPES-FORMAT-HF32","PTO-ARCH-DATA-TYPES-FORMAT-FP16","PTO-ARCH-DATA-TYPES-FORMAT-BF16","PTO-ARCH-DATA-TYPES-FORMAT-HIF8","PTO-ARCH-DATA-TYPES-FORMAT-E4M3","PTO-ARCH-DATA-TYPES-FORMAT-E5M2","PTO-ARCH-DATA-TYPES-FORMAT-E3M2","PTO-ARCH-DATA-TYPES-FORMAT-E2M3","PTO-ARCH-DATA-TYPES-FORMAT-E2M1X2","PTO-ARCH-DATA-TYPES-FORMAT-E1M2X2","PTO-ARCH-DATA-TYPES-FORMAT-E8M0","PTO-ARCH-DATA-TYPES-FORMAT-HIF4X2"]}

// NDF-BEGIN: PTO-NUMERIC-FINITE-DECOMPOSITION-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// Every valid finite floating or scale encoding MUST decompose without host
// floating-point arithmetic into available, sign, integer significand, and
// integer exponent such that its exact value is
// (-1)^sign * UInt(significand) * 2^exponent. Invalid internal encodings,
// infinities, NaNs, and integer Tile DataTypes MUST report unavailable.
// NDF-END: PTO-NUMERIC-FINITE-DECOMPOSITION-001

// DOC-BEGIN: operation
pure func TileNumericFormatDescriptor(data_type: TileDataType)
    => NumericFormatDescriptor
begin
    case data_type of
        when TileDataType_FP64 => return FP64NumericFormatDescriptor();
        when TileDataType_FP32 => return FP32NumericFormatDescriptor();
        when TileDataType_TF32 => return TF32NumericFormatDescriptor();
        when TileDataType_HF32 => return HF32NumericFormatDescriptor();
        when TileDataType_FP16 => return FP16NumericFormatDescriptor();
        when TileDataType_BF16 => return BF16NumericFormatDescriptor();
        when TileDataType_HiF8 => return HiF8NumericFormatDescriptor();
        when TileDataType_E4M3 => return E4M3NumericFormatDescriptor();
        when TileDataType_E5M2 => return E5M2NumericFormatDescriptor();
        when TileDataType_E3M2 => return E3M2NumericFormatDescriptor();
        when TileDataType_E2M3 => return E2M3NumericFormatDescriptor();
        when TileDataType_E2M1X2 => return E2M1X2NumericFormatDescriptor();
        when TileDataType_E1M2X2 => return E1M2X2NumericFormatDescriptor();
        when TileDataType_E8M0 => return E8M0NumericFormatDescriptor();
        when TileDataType_HiF4X2 => return HiF4X2NumericFormatDescriptor();
        otherwise => return UnavailableNumericFormatDescriptor();
    end;
end;

pure func TileNumericFiniteDecomposition(
    data_type: TileDataType,
    value: Word) => (boolean, boolean, Word, integer {-1074..1023})
begin
    case data_type of
        when TileDataType_FP64 => return FP64FiniteDecomposition(value);
        when TileDataType_FP32 => return FP32FiniteDecomposition(value[31:0]);
        when TileDataType_TF32 => return TF32FiniteDecomposition(value[31:0]);
        when TileDataType_HF32 => return HF32FiniteDecomposition(value[31:0]);
        when TileDataType_FP16 => return FP16FiniteDecomposition(value[15:0]);
        when TileDataType_BF16 => return BF16FiniteDecomposition(value[15:0]);
        when TileDataType_HiF8 => return HiF8FiniteDecomposition(value[7:0]);
        when TileDataType_E4M3 => return E4M3FiniteDecomposition(value[7:0]);
        when TileDataType_E5M2 => return E5M2FiniteDecomposition(value[7:0]);
        when TileDataType_E3M2 => return E3M2FiniteDecomposition(value[7:0]);
        when TileDataType_E2M3 => return E2M3FiniteDecomposition(value[7:0]);
        when TileDataType_E2M1X2 => return E2M1X2FiniteDecomposition(value);
        when TileDataType_E1M2X2 => return E1M2X2FiniteDecomposition(value);
        when TileDataType_E8M0 => return E8M0FiniteDecomposition(value[7:0]);
        when TileDataType_HiF4X2 => return HiF4X2FiniteDecomposition(value);
        otherwise => return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    end;
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
