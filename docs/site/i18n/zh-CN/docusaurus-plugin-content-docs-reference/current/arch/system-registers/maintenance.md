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

本单元为架构依赖图中的维护行为提供稳定的系统寄存器标识。

<!-- PTO-READER-BLOCK: arch-system-maintenance-concepts-state role=concepts-state -->
## 所有者内容

该所有者只包含其 `PTO-UNIT` 声明，没有在本地声明维护寄存器、字段、辅助函数或状态转换。

<!-- PTO-READER-BLOCK: arch-system-maintenance-rules-interactions role=rules-interactions -->
## 依赖关系

`PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE` 依赖 `PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION`。任何可执行的维护或故障精确性行为都必须来自可达的当前所有者。

<!-- PTO-READER-BLOCK: arch-system-maintenance-boundaries role=boundaries -->
## 架构边界

本页不会为维护寄存器指定地址、复位值、许可、缓存行为、完成行为或故障副作用。这些内容将是在本所有者中不存在的新语义。

<!-- PTO-READER-BLOCK: arch-system-maintenance-example-usage role=example-usage -->
## 非规范阅读示例

当维护相关的故障问题到达本页时，应继续查找故障精确性依赖项，再找到确切指令或状态转换所有者。不能把这个导航单元的存在当作未陈述寄存器行为的证据。

<!-- PTO-READER-BLOCK: arch-system-maintenance-related-owners role=related-owners-navigation -->
## 相关所有者

- [故障精确性](../memory-model/fault-precision.md)是直接依赖项。
- [系统寄存器寻址](addressing.md)拥有基础系统寄存器状态记录。
- [架构概览](../overview/architecture.md)解释生成的导航为何不能创建语义。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/maintenance.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE","surface":"arch","classification":["system-registers","maintenance"],"depends_on":["PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION"]}
```
<!-- GENERATED-ASL-END: unit -->
