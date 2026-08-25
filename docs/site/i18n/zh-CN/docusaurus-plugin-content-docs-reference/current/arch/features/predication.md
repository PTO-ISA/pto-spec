<!-- GENERATED FROM: asl/arch/features/predication.asl -->
# Predication

**Normative ASL source:** `asl/arch/features/predication.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-PREDICATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-predication-purpose-scope role=purpose-scope -->
## 目的与范围

本单元是谓词控制的命名架构概念，并依赖谓词寄存器编程模型归属单元。

它提供稳定的归属点和导航入口，但不另立第二套谓词状态或执行契约。

<!-- PTO-READER-BLOCK: arch-predication-concepts-state role=concepts-state -->
## 概念与可见状态

- 本单元只包含 `PTO-UNIT` 身份，以及对 `PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS` 的依赖。
- 谓词寄存器的存储、索引、复位和读写由该依赖及其可达状态归属单元定义。
- 具体指令的谓词解码和无操作行为仍由各助记符归属单元定义。

<!-- PTO-READER-BLOCK: arch-predication-rules-interactions role=rules-interactions -->
## 规则与交互

这一概念不引入 ASL 类型、函数、状态变量或状态转换。

对谓词控制的引用必须通过谓词寄存器归属单元和使用该机制的指令当前 ASL 解析。

不能从这个只有标记的单元推断默认谓词极性或指令覆盖范围。

<!-- PTO-READER-BLOCK: arch-predication-boundaries role=boundaries -->
## 架构边界

本页不能在解释性文字中添加缺失的谓词语义；任何新规则都必须进入相应 ASL/NDF 归属单元变更并完成验证。

该命名概念作为身份具有可移植性，具体指令效果仍留在各助记符契约中。

<!-- PTO-READER-BLOCK: arch-predication-example-usage role=example-usage -->
## 非规范阅读示例

要判断假谓词是否抑制某条具体指令，应同时阅读该指令的解码/操作和谓词寄存器归属单元；本单元自身不能回答。

应把本页作为该概念的架构索引，再沿相关归属单元链接查看可执行细节。

<!-- PTO-READER-BLOCK: arch-predication-related-owners role=related-owners-navigation -->
## 相关归属单元

- [谓词寄存器](../programming-model/predicate-registers.md)
- [执行上下文](../programming-model/execution-context.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/predication.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-PREDICATION","surface":"arch","classification":["features","predication"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
