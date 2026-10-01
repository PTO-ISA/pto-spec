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

本单元拥有一条规则，它把架构周期计数和一个存储的比较值转换为每个环一个定时器中断的待处理状态，并且它固定了每个环的定时器使用哪个中断 ID。

它不计数周期，也不存储比较值本身；它通过上下文寄存器辅助函数读取存储的取值，并通过中断所有者更新待处理状态。

<!-- PTO-READER-BLOCK: arch-timer-concepts-state role=concepts-state -->
## 中断标识与比较值

`TimerInterruptId` 对 ACR0 返回中断 ID 1，对其他每个环返回中断 ID 3，因此某个环的定时器总是占据该环待处理位图中相同的位置。

`RefreshTimerPending` 从传入环的上下文寄存器偏移量 `0x0f21` 读取比较值，并与 `_SystemRegisters.cycle` 比较。两侧都按无符号取值处理。

这两个输入来自不同的所有者：`cycle` 由寻址所有者复位、由执行路径递增，而比较字是普通的上下文寄存器存储。

<!-- PTO-READER-BLOCK: arch-timer-rules-interactions role=rules-interactions -->
## 待处理规则

当比较值不为零且周期计数大于或等于它时，定时器中断被置为待处理。在其他所有情况下，定时器中断被清除。

该更新经由 `SetInterruptPending` 或 `ClearInterruptPending` 完成，因此最高优先待处理中断取值在同一次调用中被重新计算。若某个定时器在存在编号更小的待处理中断时变为待处理，最高优先取值仍指向那个编号更小的中断。

比较值为零时无论周期计数是多少都不可能置位定时器中断。精确相等会置位它，因为该比较是包含端点的。

设计要点：零原本是可达的最小周期计数，因此把它当作普通阈值会让复位后第一个周期起定时器就处于待处理状态。把零保留给禁用，使软件能够布置定时器，而不会让待处理位在复位时就被置位。

设计要点：先按环确定中断，再进行比较，因此同一个刷新函数服务于所有环，待处理位的位置也从不取决于恰好被编程的比较值。

<!-- PTO-READER-BLOCK: arch-timer-boundaries role=boundaries -->
## 架构边界

本所有者只在刷新函数被调用时运行该比较。读取待处理中断位图会调用它，读取最高优先待处理中断会调用它，而写入某个环的比较偏移量会为该环调用它。在本仓库中，复位某个环的比较字并不属于这些写入，因此比较值为零本身并不会清除已置位的定时器位。

确认一个定时器中断会清除待处理位，且不改变比较值，因此在阈值仍然匹配时下一次刷新会再次置位。要彻底清除该中断，就要让比较值为零，或让它超过当前周期计数。

<!-- PTO-READER-BLOCK: arch-timer-example-usage role=example-usage -->
## 非规范阈值示例

在 ACR0 的比较值设为 100 时，周期计数 99 时的一次刷新让中断 ID 1 保持清除，周期计数 100 时的一次刷新则置位它。把比较值提高到当前周期计数之上会再次清除它。

在 ACR1 上同样的序列作用于中断 ID 3，因为 `TimerInterruptId` 把除 ACR0 以外的每个环都映射到 ID 3。

<!-- PTO-READER-BLOCK: arch-timer-related-owners role=related-owners-navigation -->
## 相关所有者

- [上下文寄存器](context.md)是声明的依赖项，并计算此处使用的相对环偏移量。
- [中断寄存器](interrupt.md)拥有待处理位图、使能门控和最高优先待处理取值。
- [系统寄存器寻址](addressing.md)拥有本规则读取的 `cycle` 字段。
- [访问控制](access-control.md)定义在中断 ID 1 与中断 ID 3 之间做选择的环类型。
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
