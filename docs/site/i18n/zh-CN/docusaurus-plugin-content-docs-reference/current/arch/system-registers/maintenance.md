<!-- GENERATED FROM: asl/arch/system-registers/maintenance.asl -->
# Maintenance

**Normative ASL source:** `asl/arch/system-registers/maintenance.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-system-maintenance-purpose-scope role=purpose-scope -->
## 用途与范围

本页只有一件事要描述，而描述很短：该单元只携带它自己的 `PTO-UNIT` 元数据行。文件中没有任何 ASL 声明、常量、类型、变量、函数或状态转换。

该单元存在，是为了让维护行为在依赖图中拥有稳定的标识。阅读它只能知道它依赖什么，而完全不能知道维护操作做什么。

<!-- PTO-READER-BLOCK: arch-system-maintenance-concepts-state role=concepts-state -->
## 所有者内容

声明的标识是 `PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE`，归类于 `system-registers` 与 `maintenance`。

声明的依赖是 `PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION`，它是拥有内存行为故障精确性的单元。

没有列出任何成员状态，因为该所有者本身不持有状态。确实存在的维护状态记录 `PTO-STATE-ARCH-MAINTENANCE` 由执行上下文单元而非本单元拥有。

<!-- PTO-READER-BLOCK: arch-system-maintenance-rules-interactions role=rules-interactions -->
## 行为实际所在之处

维护操作确实保存的状态，即最近一次维护操作、最近一次维护操作数，以及数据缓存纪元、指令缓存纪元、指令束缓存纪元与翻译纪元，由 `PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT` 拥有，并出现在它的状态记录中。

操作选择器及其维护操作列表与其他系统寄存器数据类型一同声明，而每条维护指令在标量表面下都有自己的页面。

本页不在那些所有者之上添加任何规则。

<!-- PTO-READER-BLOCK: arch-system-maintenance-boundaries role=boundaries -->
## 架构边界

由于该单元没有声明任何寄存器，本页本身不指定任何地址、复位取值、访问权限、缓存行为、完成行为或故障副作用。这些规则确实存在，但它们属于维护操作本身：翻译类操作只分配给根环，缓存类操作推进数据、指令或指令束缓存纪元，而被拒绝的访问或操作数会引发 `Fault_IllegalInstruction` 或 `Fault_DataPage`。

该依赖边意味着，当维护问题到达本单元时，故障精确性所有者是下一步应该查看的地方；它并不意味着本单元重述或扩展故障精确性规则。

设计要点：一个单元可以在图中占位而不承载行为。把这个占位者明确写出来，能让读者看到维护寄存器并不存在，而不是让一个看起来像所有者的页面把它藏起来。

<!-- PTO-READER-BLOCK: arch-system-maintenance-example-usage role=example-usage -->
## 非规范阅读示例

从某条维护指令页面来到这里的读者，应从该指令页面取得操作语义，若问题涉及故障何时被报告，再沿着依赖边前往故障精确性所有者。

从依赖图来到这里的读者，应把本单元当作某个边界的名称，而不是当作存在一个行为未被说明的维护寄存器的证据。

<!-- PTO-READER-BLOCK: arch-system-maintenance-related-owners role=related-owners-navigation -->
## 相关所有者

- [故障精确性](../memory-model/fault-precision.md)是声明的依赖项。
- [执行上下文](../programming-model/execution-context.md)拥有维护操作与纪元状态。
- [系统寄存器数据类型](../data-types/system-registers.md)声明维护操作选择器。
- [系统寄存器寻址](addressing.md)拥有基础系统寄存器记录与参考复位。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/maintenance.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE","surface":"arch","classification":["system-registers","maintenance"],"depends_on":["PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION"]}
```
<!-- GENERATED-ASL-END: unit -->
