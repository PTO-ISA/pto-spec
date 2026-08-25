<!-- GENERATED FROM: asl/arch/system-registers/timer.asl -->
# Timer

**Normative ASL source:** `asl/arch/system-registers/timer.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-TIMER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-timer-purpose-scope role=purpose-scope -->
## 用途与范围

本单元定义每个 ACR 的定时器中断 ID，以及根据周期计数器与比较寄存器推导定时器待处理状态的规则。

<!-- PTO-READER-BLOCK: arch-timer-concepts-state role=concepts-state -->
## 定时器标识与比较值

`TimerInterruptId` 对 ACR0 返回中断 ID `1`，对其他每个 ACR 返回中断 ID `3`。

`RefreshTimerPending` 从上下文寄存器低位索引 `0x0f21` 读取比较值，并把它和 `_SystemRegisters.cycle` 作为无符号值比较。

<!-- PTO-READER-BLOCK: arch-timer-rules-interactions role=rules-interactions -->
## 待处理状态规则

当比较值非零且周期值大于或等于它时，定时器中断被设为待处理。否则，定时器中断被清除。

更新使用 `SetInterruptPending` 或 `ClearInterruptPending`，因此也会刷新最高优先待处理中断值。

<!-- PTO-READER-BLOCK: arch-timer-boundaries role=boundaries -->
## 架构边界

比较值为零时不会置位定时器待处理状态，即使周期值为零或更大。本所有者不递增周期计数器，也不定义除调用 `RefreshTimerPending` 之外的定时器刷新时机。

<!-- PTO-READER-BLOCK: arch-timer-example-usage role=example-usage -->
## 非规范阈值示例

在一次定时器刷新中，对于比较值为 `100` 的 ACR0，周期值 `99` 及以下保持中断 ID `1` 清零。周期值达到 `100` 后设置 ID `1`，直到比较值变为零或大于当前周期值。

<!-- PTO-READER-BLOCK: arch-timer-related-owners role=related-owners-navigation -->
## 相关所有者

- [上下文寄存器](context.md)是声明的依赖项，并提供相对环的索引计算。
- [中断寄存器](interrupt.md)拥有待处理位存储、使能检查和最高优先待处理中断选择。
- [系统寄存器寻址](addressing.md)拥有本页读取的周期计数器字段。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/timer.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-TIMER","surface":"arch","classification":["system-registers","timer"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-CONTEXT"]}
pure func TimerInterruptId(ring: AccessControlRing) => InterruptID
begin
    return if ring == 0 then 1 else 3;
end;

func RefreshTimerPending(ring: AccessControlRing)
begin
    let comparison = _ExtendedSystemRegisters[[
        ContextRegisterIndex(ring, 0x0f21)]];
    let interrupt_id = TimerInterruptId(ring);
    if comparison != Zeros{PTO_XLEN} &&
       UInt(_SystemRegisters.cycle) >= UInt(comparison) then
        SetInterruptPending(ring, interrupt_id);
    else
        ClearInterruptPending(ring, interrupt_id);
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
