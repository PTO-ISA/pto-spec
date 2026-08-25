<!-- GENERATED FROM: asl/arch/system-registers/addressing.asl -->
# Addressing

**Normative ASL source:** `asl/arch/system-registers/addressing.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-system-addressing-purpose-scope role=purpose-scope -->
## 用途与范围

本单元拥有基础系统寄存器状态记录，以及用于初始化架构状态中由配置档拥有的部分的配置档复位钩子。

<!-- PTO-READER-BLOCK: arch-system-addressing-concepts-state role=concepts-state -->
## 基础系统寄存器状态

`BaseSystemRegisterState` 包含 `thread_ptr`、`global_ptr`、`core_state`、`core_id`、`thread_id`、`vendor`、`version`、`core_feature`、`core_feature_enable`、`tile_capacity`、`blocknum`、`blockid` 和 `cycle`，每个字段都表示为 `Word`。

架构可见的所有者是 `_SystemRegisters`，其标识为 `PTO-STATE-ARCH-SYSTEM-REGISTERS`。

<!-- PTO-READER-BLOCK: arch-system-addressing-rules-interactions role=rules-interactions -->
## 配置档复位钩子

`ResetProfileState` 由实现定义，可以由当前活动的具体配置档覆写。本所有者中的默认函数体把 `_CurrentACR` 设为 `0`，并把 `_SystemRegisters.cycle` 清为 `Zeros{PTO_XLEN}`。

<!-- PTO-READER-BLOCK: arch-system-addressing-boundaries role=boundaries -->
## 架构边界

默认函数体不会写入 `BaseSystemRegisterState` 的其他字段。因此，本页不会为所有者未触及的字段指定复位值。

配置档专用的复位行为必须保留在 `ResetProfileState` 钩子后面，不能从某个目标实现推断。

<!-- PTO-READER-BLOCK: arch-system-addressing-example-usage role=example-usage -->
## 非规范复位阅读示例

检查可移植默认行为时，调用 `ResetProfileState` 后应看到 ACR0 和清零的周期计数器。除非另一个当前所有者或活动配置档给出定义，否则应把 `vendor` 或 `tile_capacity` 的值视为本辅助函数未解决的问题。

<!-- PTO-READER-BLOCK: arch-system-addressing-related-owners role=related-owners-navigation -->
## 相关所有者

- [陷阱上下文数据类型](../data-types/trap-context.md)是声明的依赖项。
- [上下文寄存器](context.md)把相对环的上下文寄存器映射到扩展系统寄存器存储。
- [数值状态](../state/numeric-status.md)使用本页拥有的 `core_state` 字段。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/addressing.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING","surface":"arch","classification":["system-registers","addressing"],"depends_on":["PTO-ARCH-DATA-TYPES-TRAP-CONTEXT"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-SYSTEM-REGISTERS","classification":["architecture","system-registers"],"scope":"system","owner":"PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING","members":["_SystemRegisters"],"depends_on":[]}
type BaseSystemRegisterState of record {
    thread_ptr: Word,
    global_ptr: Word,
    core_state: Word,
    core_id: Word,
    thread_id: Word,
    vendor: Word,
    version: Word,
    core_feature: Word,
    core_feature_enable: Word,
    tile_capacity: Word,
    blocknum: Word,
    blockid: Word,
    cycle: Word
};

var _SystemRegisters : BaseSystemRegisterState;

impdef func ResetProfileState()
begin
    // Overridden by the active concrete profile.
    _CurrentACR = 0;
    _SystemRegisters.cycle = Zeros{PTO_XLEN};
end;
```
<!-- GENERATED-ASL-END: unit -->
