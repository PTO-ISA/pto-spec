<!-- GENERATED FROM: asl/arch/data-types/floating-point.asl -->
# Floating Point

**Normative ASL source:** `asl/arch/data-types/floating-point.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FLOATING-POINT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-floating-point-purpose role=purpose-scope -->
## 目的与范围

本单元为 PTO ASL 提供选择浮点运算族的封闭词汇。它只定义运算选择器。

这四个枚举分别覆盖普通算术、比较、一元求值和融合乘加形式；每一个都是独立类型。

<!-- PTO-READER-BLOCK: arch-floating-point-concepts role=concepts-state -->
## 概念与可见状态

`FloatingBinaryOperation` 包含 `FloatingBinary_ADD`、`FloatingBinary_SUB`、`FloatingBinary_MUL`、`FloatingBinary_DIV`、`FloatingBinary_MIN` 和 `FloatingBinary_MAX`，调用方从这些成员中选择一个作为运算标识。

`FloatingCompareOperation` 包含 `EQ`、`NE`、`LT`、`LE`、`GT` 和 `GE`；`FloatingUnaryOperation` 包含 `ABS`、`SQRT`、`EXP` 和 `RECIP`；`FloatingFusedOperation` 包含 `MADD`、`MSUB`、`NMADD` 和 `NMSUB`。

设计要点：使用四个枚举而不是一个，意味着比较选择器不能传到处期望二元选择器的位置，因此运算类别不匹配会成为类型错误，而不是被静默重新解释。

<!-- PTO-READER-BLOCK: arch-floating-point-rules role=rules-interactions -->
## 规则与交互

调用方把相应枚举中的一个成员传给数值语义所有者，由该所有者决定操作数格式和精确算术结果。

选择 `MIN`、`MAX`、`RECIP` 或融合形式，并不定义 NaN 选择、舍入或异常值处理；这些问题属于消费它的所有者。

`NMADD` 和 `NMSUB` 是与 `MADD` 和 `MSUB` 不同的成员，因此融合运算中乘积的符号由运算标识承载，而不是由操作数标志承载。

<!-- PTO-READER-BLOCK: arch-floating-point-boundaries role=boundaries -->
## 架构边界

由于这些选择器不携带格式，同一个选择器可以被接受多种数据类型的所有者使用，而枚举本身并不声称这种支持。

本单元不声明算术和状态，因此没有消费者引用的选择器没有可观察效果。

本单元只声明四个枚举，不含任何函数，因此上面的成员列表就是全部范围，运算语义由消费它的所有者提供。

<!-- PTO-READER-BLOCK: arch-floating-point-example role=example-usage -->
## 非规范阅读示例

本例说明当前的 ASL 归属单元，不替代规范操作。

阅读结果意味着阅读消费它的操作配置，由它提供格式、舍入模式和异常值规则。

看到 `FloatingFused_NMSUB` 时，应先找到使用它的 ASL 函数，再阅读该所有者定义的操作数顺序、格式、舍入和异常值规则，然后才能推导结果。

由于这些选择器不携带格式，本单元不接受操作数、不产生值，也不记录数值状态；这些全部属于消费它的操作配置。

<!-- PTO-READER-BLOCK: arch-floating-point-related role=related-owners-navigation -->
## 相关归属单元

- [舍入](rounding.md)定义架构的舍入词汇。

- [数值格式](numeric-formats.md)把 Tile 数据类型连接到它们的确切格式辅助函数。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/floating-point.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FLOATING-POINT","surface":"arch","classification":["data-types","floating-point"],"depends_on":["PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS"]}
type FloatingBinaryOperation of enumeration {
    FloatingBinary_ADD,
    FloatingBinary_SUB,
    FloatingBinary_MUL,
    FloatingBinary_DIV,
    FloatingBinary_MIN,
    FloatingBinary_MAX
};

type FloatingCompareOperation of enumeration {
    FloatingCompare_EQ,
    FloatingCompare_NE,
    FloatingCompare_LT,
    FloatingCompare_LE,
    FloatingCompare_GT,
    FloatingCompare_GE
};

type FloatingUnaryOperation of enumeration {
    FloatingUnary_ABS,
    FloatingUnary_SQRT,
    FloatingUnary_EXP,
    FloatingUnary_RECIP
};

type FloatingFusedOperation of enumeration {
    FloatingFused_MADD,
    FloatingFused_MSUB,
    FloatingFused_NMADD,
    FloatingFused_NMSUB
};
```
<!-- GENERATED-ASL-END: unit -->
