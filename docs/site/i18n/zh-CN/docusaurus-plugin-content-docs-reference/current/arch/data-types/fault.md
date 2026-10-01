<!-- GENERATED FROM: asl/arch/data-types/fault.asl -->
# Fault

**Normative ASL source:** `asl/arch/data-types/fault.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FAULT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-fault-purpose role=purpose-scope -->
## 目的与范围

`FaultCode` 是 PTO ASL 中故障标识的枚举，包含 `Fault_None` 以及十五个具名且非 `None` 的成员。本单元只定义这些标识，不定义何时选择其中之一，也不定义随后发生的状态转换。

这十五个非 `None` 成员分别命名执行状态检查、非法指令、指令地址或指令页、数据对齐或数据页、硬件或软件断点、硬件观察点、断言、Tile 合法性与 Tile 分配、指令束控制与提交后故障，以及服务请求。

<!-- PTO-READER-BLOCK: arch-fault-concepts role=concepts-state -->
## 概念与可见状态

每个 `FaultCode` 值恰好是该枚举的一个成员，因此调用方无法用单个值表达同时包含两种原因的故障。

这些声明的成员不携带陷阱号、优先级、参数或恢复行为；这些属于触发故障的 ASL 所有者以及处理它的陷阱机制。

设计要点：故障标识与报告它的陷阱分离，因此同一个 `FaultCode` 可以由多条指令触发，并通过一个陷阱入口报告，而双方都不需要重新定义对方。

<!-- PTO-READER-BLOCK: arch-fault-rules role=rules-interactions -->
## 规则与交互

`Fault_BundleControl` 和 `Fault_BundlePostCommit` 是不同的成员，因此被控制检查拒绝的指令束与成功提交并在提交边界请求陷阱的指令束可以区分。

`Fault_TileLegality` 和 `Fault_TileAllocation` 同样是不同成员，因此调用方可以区分未通过描述符或类型检查的操作数与分配无法满足的目标请求。

`Fault_None` 本身就是一个成员，因此该类型的值总有一个答案，不需要额外的缺失表示。

<!-- PTO-READER-BLOCK: arch-fault-boundaries role=boundaries -->
## 架构边界

本单元不声明自身行为，因此调用方从未选择的 `FaultCode` 没有可观察效果。

阅读故障报告意味着阅读选中该成员的所有者，而不是本页；陷阱所有者决定陷阱号、参数和重启行为。

本页应作为词表阅读：该单元只声明一个枚举，没有函数，因此关于何时触发、报告或恢复故障的每条规则都由其他单元拥有。

<!-- PTO-READER-BLOCK: arch-fault-example role=example-usage -->
## 非规范阅读示例

本例说明当前的 ASL 归属单元，不替代规范操作。

这些声明的标识本身并不说明某条指令能够产生相应条件，因为可达性由每个消费单元决定。

当另一个 ASL 单元使用 `Fault_DataAlignment` 时，应把该单元视为周边行为的所有者；本页只确立 `Fault_DataAlignment` 是一个独立的 `FaultCode` 成员。

<!-- PTO-READER-BLOCK: arch-fault-related role=related-owners-navigation -->
## 相关归属单元

- [陷阱上下文](trap-context.md)定义保存的陷阱上下文状态。

- [执行上下文](../programming-model/execution-context.md)说明故障状态和程序控制状态在架构状态模型中的位置。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/fault.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FAULT","surface":"arch","classification":["data-types","fault"],"depends_on":["PTO-ARCH-DATA-TYPES-INTEGER"]}
type FaultCode of enumeration {
    Fault_None,
    Fault_ExecutionStateCheck,
    Fault_IllegalInstruction,
    Fault_InstructionPC,
    Fault_InstructionPage,
    Fault_DataAlignment,
    Fault_DataPage,
    Fault_SoftwareBreakpoint,
    Fault_HardwareBreakpoint,
    Fault_HardwareWatchpoint,
    Fault_Assert,
    Fault_TileLegality,
    Fault_TileAllocation,
    Fault_BundleControl,
    Fault_BundlePostCommit,
    Fault_ServiceRequest
};
```
<!-- GENERATED-ASL-END: unit -->
