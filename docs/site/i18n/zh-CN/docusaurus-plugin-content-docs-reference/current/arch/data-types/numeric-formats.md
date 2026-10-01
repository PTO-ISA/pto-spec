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

`TileNumericFormatDescriptor` 与 `TileNumericFiniteDecomposition` 是两个入口：它们把 `TileDataType` 转换为格式元数据和精确有限值分解。两者都是 `pure func`，对同样的 17 个浮点与缩放成员做 `case`，即从 `TileDataType_FP64` 到 `TileDataType_E6M2`，再加上派生类型 `TileDataType_RCPE6M2`。

本单元只拥有分派。每个分支都返回相应格式归属单元产生的结果，因此载体宽度、通道数、偏置和特殊值规则都不在本页决定。

设计要点：分派器自己对 `Word` 载体做缩窄，`FP32`、`TF32` 和 `HF32` 取 `value[31:0]`，`FP16` 和 `BF16` 取 `value[15:0]`，8 位格式取 `value[7:0]`。因此调用方无法让 8 位格式读到第 7 位以上的比特，每个辅助函数收到的正是它自己的描述符所声明的载体。

<!-- PTO-READER-BLOCK: arch-numeric-formats-concepts-state role=concepts-state -->
## 概念与可见状态

- `TileNumericFormatDescriptor` 与 `TileNumericFiniteDecomposition` 各有 17 个 `when` 分支；描述符的 `otherwise` 分支返回 `UnavailableNumericFormatDescriptor()`，分解的 `otherwise` 分支返回四元组 `(FALSE, FALSE, Zeros{PTO_XLEN}, 0)`。
- 分解结果依次为可用性、符号、整数有效数和整数指数，其精确值为 `(-1)^sign * UInt(significand) * 2^exponent`。指数类型为 `integer {-1074..1023}`。
- 有四个分支原样传入完整 `Word`：`TileDataType_FP64`、`TileDataType_E2M1X2`、`TileDataType_E1M2X2` 和 `TileDataType_HiF4X2`。其中三个 `X2` 辅助函数只读 `value[3:0]`，因此一次调用只分解一个 4 位通道，而不是其描述符所计数的两个通道。

设计要点：指数类型为 `integer {-1074..1023}`，是所有分支共用的一个范围。`-1074` 是 `FP64` 分支对次正规数返回的值，`1023` 是声明的上界，因此使用方可以用同样的两个界限比较任何分支的指数。

<!-- PTO-READER-BLOCK: arch-numeric-formats-rules-interactions role=rules-interactions -->
## 规则与交互

归属 NDF 条款 `PTO-NUMERIC-FINITE-DECOMPOSITION-001` 要求：每个具有有限二进制分解的有效有限浮点或缩放编码，都必须在不用宿主浮点算术的前提下，分解为可用性、符号、整数有效数和整数指数。

对自身类型无效的编码会由格式辅助函数报告 `available = FALSE`；该类型若有无穷大或 NaN 编码，也同样报告；归属 NDF 条款正是这样要求的。十个整数成员 `TileDataType_S64`、`TileDataType_S32`、`TileDataType_S16`、`TileDataType_S8`、`TileDataType_S4X2`、`TileDataType_U64`、`TileDataType_U32`、`TileDataType_U16`、`TileDataType_U8` 和 `TileDataType_U4X2` 没有分支，因此落入 `otherwise`。

`UnavailableNumericFormatDescriptor()` 把 `available = FALSE`、`kind = NumericFormatKind_Unavailable`，以及每个比特计数、比特位置和特殊值标志都置为 `FALSE` 或 `0`。

设计要点：分派器从不检查指数域或尾数域；每个辅助函数先应用自己的合法性规则，例如 `TF32FiniteDecomposition` 要求 `value[12:0]` 为零。因此两种数据类型可以都被分派，却在可用性上给出不同答案，因为答案是 `case` 下一层产生的。

<!-- PTO-READER-BLOCK: arch-numeric-formats-boundaries role=boundaries -->
## 架构边界

返回的描述符是关于编码的元数据，并不表示某条指令接受该数据类型。使用方指令或命名配置档可以接受比该格式族更少的类型。

本单元不会用宿主算术重新解释返回的元组：整数有效数和整数指数就是完整的交换契约，需要舍入值的使用方必须自行舍入。

`TileDataType_RCPE6M2` 正是两个入口故意给出不同答案的情形：其描述符分支返回 `RCPE6M2NumericFormatDescriptor()`，其中 `available = TRUE`；而 `RCPE6M2FiniteDecomposition` 对任何输入都返回 `(FALSE, FALSE, Zeros{PTO_XLEN}, 0)`。`PTO-NUMERIC-FINITE-DECOMPOSITION-001` 允许派生精确实数源在这里报告不可用，同时要求把它的精确实数解码器 `RCPE6M2FiniteValue` 暴露给操作配置档。

设计要点：由于描述符可用性与分解可用性是两个独立答案，使用方必须询问自己真正需要的那一个。读取 `TileDataType_RCPE6M2` 的 `available = TRUE` 之后就期待得到二进制有效数，会把派生精确实数类型当成普通的定点二进制类型。

<!-- PTO-READER-BLOCK: arch-numeric-formats-example-usage role=example-usage -->
## 非规范阅读示例

以 `TileDataType_TF32` 和编码 `0x3F800000` 为例。分派器把 `value[31:0]` 传给 `TF32FiniteDecomposition`；低 13 位为零，指数域为 `0x7F`，尾数域为零，因此该辅助函数返回可用性 `TRUE`、符号 `FALSE`、有效数 `1024` 和指数 `-10`。精确值为 `1024 * 2^-10`，即一。

对于 `TileDataType_S32`，分派器找不到分支，因此可用性为 `FALSE`、符号为 `FALSE`、有效数为 `Zeros{PTO_XLEN}`、指数为 `0`。这里不会为它构造整数分解。

对于 `TileDataType_E2M1X2`，分派器传入完整 `Word`，而 `E2M1X2FiniteDecomposition` 只读 `value[3:0]`，因此把一个字节里两个 4 位通道交给它的调用方，只会得到低通道被分解，高通道不受影响。

<!-- PTO-READER-BLOCK: arch-numeric-formats-related-owners role=related-owners-navigation -->
## 相关归属单元

- [Tile 数据类型命名空间](tile-data-types.md)
- [数值分类](numeric-classification.md)
- [格式描述符记录](format-descriptor.md)
- [TF32 格式](formats/tf32.md)
- [RCPE6M2 格式](formats/rcpe6m2.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/numeric-formats.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS","surface":"arch","classification":["data-types","numeric-formats"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-FP64","PTO-ARCH-DATA-TYPES-FORMAT-FP32","PTO-ARCH-DATA-TYPES-FORMAT-TF32","PTO-ARCH-DATA-TYPES-FORMAT-HF32","PTO-ARCH-DATA-TYPES-FORMAT-FP16","PTO-ARCH-DATA-TYPES-FORMAT-BF16","PTO-ARCH-DATA-TYPES-FORMAT-HIF8","PTO-ARCH-DATA-TYPES-FORMAT-E4M3","PTO-ARCH-DATA-TYPES-FORMAT-E5M2","PTO-ARCH-DATA-TYPES-FORMAT-E3M2","PTO-ARCH-DATA-TYPES-FORMAT-E2M3","PTO-ARCH-DATA-TYPES-FORMAT-E2M1X2","PTO-ARCH-DATA-TYPES-FORMAT-E1M2X2","PTO-ARCH-DATA-TYPES-FORMAT-E8M0","PTO-ARCH-DATA-TYPES-FORMAT-HIF4X2","PTO-ARCH-DATA-TYPES-FORMAT-E6M2","PTO-ARCH-DATA-TYPES-FORMAT-RCPE6M2"]}

// NDF-BEGIN: PTO-NUMERIC-FINITE-DECOMPOSITION-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// Every valid finite floating or scale encoding with a finite-binary
// decomposition MUST decompose without host floating-point arithmetic into
// available, sign, integer significand, and integer exponent such that its
// exact value is (-1)^sign * UInt(significand) * 2^exponent. A derived exact-
// real source whose values are not all finite-binary, such as RCPE6M2, may
// report unavailable here and MUST expose its exact real decoder to the
// operation profile. Invalid internal encodings, infinities, NaNs, and
// integer Tile DataTypes MUST report unavailable.
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
        when TileDataType_E6M2 => return E6M2NumericFormatDescriptor();
        when TileDataType_RCPE6M2 => return RCPE6M2NumericFormatDescriptor();
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
        when TileDataType_E6M2 => return E6M2FiniteDecomposition(value[7:0]);
        when TileDataType_RCPE6M2 => return RCPE6M2FiniteDecomposition(value[7:0]);
        otherwise => return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    end;
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
