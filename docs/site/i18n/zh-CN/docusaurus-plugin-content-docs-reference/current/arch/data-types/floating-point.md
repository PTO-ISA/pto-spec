<!-- GENERATED FROM: asl/arch/data-types/floating-point.asl -->
# Floating Point

**Normative ASL source:** `asl/arch/data-types/floating-point.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FLOATING-POINT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-floating-point-purpose role=purpose-scope -->
## 用途与范围

本单元为 PTO ASL 提供一个封闭的浮点运算族选择词汇。它只定义运算选择器；操作数格式、舍入、异常、结果值和状态影响仍由使用这些选择器的 ASL 函数定义。

<!-- PTO-READER-BLOCK: arch-floating-point-concepts role=concepts-state -->
## 运算族

`FloatingBinaryOperation` 包含 `ADD`、`SUB`、`MUL`、`DIV`、`MIN` 和 `MAX`。`FloatingCompareOperation` 包含 `EQ`、`NE`、`LT`、`LE`、`GT` 和 `GE`。

`FloatingUnaryOperation` 包含 `ABS`、`SQRT`、`EXP` 和 `RECIP`；`FloatingFusedOperation` 包含 `MADD`、`MSUB`、`NMADD` 和 `NMSUB`。

<!-- PTO-READER-BLOCK: arch-floating-point-rules role=rules-interactions -->
## 选择与解释

调用者把相应枚举中的一个成员传给数值语义所有者。所选数据格式和确切算术行为由该所有者决定，而不是由本枚举决定。

四种枚举类型可避免把比较选择器悄然当成二元、一元或融合运算选择器。

<!-- PTO-READER-BLOCK: arch-floating-point-boundaries role=boundaries -->
## 边界

出现 `MIN`、`MAX`、`RECIP` 或融合运算选择器，本身并不定义 NaN 选择、舍入、上溢、下溢、标志或融合行为。这些问题必须由可达的数值格式或配置档 ASL 契约回答。

本单元的静态 AVS 检查这些选择器声明能够在完整模型中编译；这条证据说明不定义算术结果。

<!-- PTO-READER-BLOCK: arch-floating-point-example role=example-usage -->
## 非规范阅读示例

下面只演示如何查找选择器，并不是算术定义。

看到 `FloatingFused_NMSUB` 时，应先找到使用它的 ASL 函数，再阅读该所有者定义的操作数顺序、格式、舍入和异常值规则，然后才能推导结果。

<!-- PTO-READER-BLOCK: arch-floating-point-related role=related-owners-navigation -->
## 相关所有者

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
