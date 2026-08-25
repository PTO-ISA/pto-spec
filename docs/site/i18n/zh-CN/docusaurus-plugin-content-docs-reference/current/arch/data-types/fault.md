<!-- GENERATED FROM: asl/arch/data-types/fault.asl -->
# Fault

**Normative ASL source:** `asl/arch/data-types/fault.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FAULT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-fault-purpose role=purpose-scope -->
## 用途与范围

`FaultCode` 是 PTO ASL 为 `Fault_None` 和 15 个具名且非 `None` 的故障标识定义的枚举。本单元只定义这些标识，不定义它们何时被选择，也不定义随后发生的状态转换。

<!-- PTO-READER-BLOCK: arch-fault-concepts role=concepts-state -->
## 故障分组

`Fault_None` 表示当前没有故障。执行状态检查、非法指令、指令地址/指令页、数据对齐/数据页、调试、断言、Tile 合法性或分配、指令束控制或提交后故障，以及服务请求，都有各自独立的枚举成员。

这种拆分让后续 ASL 所有者能够选择故障原因，而无需把陷阱号或恢复行为编码进这个类型定义。

<!-- PTO-READER-BLOCK: arch-fault-rules role=rules-interactions -->
## 故障码的使用方式

一个 `FaultCode` 值恰好是该枚举的一个成员。这个声明不分配陷阱号、优先级、载荷或恢复行为。

链接到本单元的 AVS 提供跨所有者执行证据，但不属于本页的枚举定义。

<!-- PTO-READER-BLOCK: arch-fault-boundaries role=boundaries -->
## 边界

`Fault_BundleControl` 和 `Fault_BundlePostCommit` 是两个不同的枚举成员。`Fault_TileLegality` 和 `Fault_TileAllocation` 也分别是不同成员。

某条指令选择哪个成员，以及陷阱或配置档所有者如何解释该成员，都不属于这个类型声明。

<!-- PTO-READER-BLOCK: arch-fault-example role=example-usage -->
## 非规范阅读示例

下面只演示阅读路径，不增加故障规则。

当另一个 ASL 单元使用 `Fault_DataAlignment` 时，应把该单元视为周边行为的所有者；本页只确立 `Fault_DataAlignment` 是一个独立的 `FaultCode` 成员。

<!-- PTO-READER-BLOCK: arch-fault-related role=related-owners-navigation -->
## 相关所有者

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
