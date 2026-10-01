<!-- GENERATED FROM: asl/arch/system-registers/interrupt.asl -->
# Interrupt

**Normative ASL source:** `asl/arch/system-registers/interrupt.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-INTERRUPT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-interrupt-purpose-scope role=purpose-scope -->
## 用途与范围

本单元拥有单个环的中断簿记：待处理集合存放在哪里、最高优先待处理中断如何推导、哪些配置位控制进入陷阱，以及一次中断结束写入会改变什么。

它不把中断送入陷阱信封。定时器所有者与故障精确性所有者中的 `RaiseInterrupt` 是这些函数的另外两个调用者：定时器所有者置位或清除定时器位，而 `RaiseInterrupt` 在测试使能门控之前先置位待处理位。

<!-- PTO-READER-BLOCK: arch-interrupt-concepts-state role=concepts-state -->
## 待处理集合及其推导出的优先级

对每个环，三个上下文寄存器偏移量承载中断状态：`0x0f07` 保存中断配置，`0x0f08` 保存待处理位图，`0x0f09` 保存选中的最高优先待处理中断。

`RefreshTopPendingInterrupt` 扫描待处理位图的位位置 0 到 63，并存入第一个被置位的位置。扫描从位置 0 开始，因此存入的取值是数值最小的待处理中断。

设计要点：最高优先取值是位图的派生缓存，而不是第二个事实来源，本单元中每个改变位图的函数都在同一次调用中重新计算它。因此存入的取值无需单独的软件更新就与位图保持一致。

<!-- PTO-READER-BLOCK: arch-interrupt-rules-interactions role=rules-interactions -->
## 待处理、使能与读取行为

`SetInterruptPending` 置位一个待处理位并重新计算最高优先取值。`ClearInterruptPending` 清除一个待处理位，也同样重新计算最高优先取值。

`InterruptEnabled` 读取配置字：对该环的定时器中断测试位 1，对每个其他中断 ID 测试位 0，因此两个中断源被分别门控。

`ReadInterruptPending` 和 `ReadTopPendingInterrupt` 在返回待处理位图或最高优先取值之前调用 `RefreshTimerPending`，因此两次读取都反映当前周期计数与定时器比较值的关系。

设计要点：因为读取函数先刷新定时器，中断寄存器的读者看到的是最新的定时器状态，而无需定时器源在阈值恰好被越过的时刻自行发布。

<!-- PTO-READER-BLOCK: arch-interrupt-boundaries role=boundaries -->
## 中断结束边界

`EndOfInterrupt` 接受一个字。低 6 位选择中断 ID，其余位 6 到 63 必须全为零，待处理位才会被清除。

无论该编码检查是否通过，该环的中断陷阱状态标志都会被清除，因此带有高位被置位的写入仍会让该环的异步陷阱状态保持清除。

设计要点：定时器中断可以再次置位，因为在比较值仍然匹配周期计数时，下一次读取 `0x0f08` 或 `0x0f09` 会再次运行待处理刷新。要彻底清除定时器中断，需要让比较值不满足定时器规则，即为零或大于当前周期计数。

<!-- PTO-READER-BLOCK: arch-interrupt-example-usage role=example-usage -->
## 非规范优先级示例

如果待处理位图中中断 ID 2 和 7 的位被置位，最高优先取值是 2。置位中断 ID 0 的位把最高优先取值变为 0，清除该位又把最高优先取值恢复为 2。

本单元中的每个函数都以环为参数调用，因此施加到 ACR1 上的同样序列作用于 ACR1 的待处理位图与配置。

<!-- PTO-READER-BLOCK: arch-interrupt-related-owners role=related-owners-navigation -->
## 相关所有者

- [定时器寄存器](timer.md)是声明的依赖项，并根据周期计数驱动一个待处理位。
- [上下文寄存器](context.md)定义中断偏移量所用的索引算术。
- [访问控制](access-control.md)定义被引发的中断所遵循的环路由。
- [陷阱上下文](../state/trap-context.md)记录已使能中断进入陷阱信封时保存的状态。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/interrupt.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-INTERRUPT","surface":"arch","classification":["system-registers","interrupt"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-TIMER"]}
func RefreshTopPendingInterrupt(ring: AccessControlRing)
begin
    let pending = _ExtendedSystemRegisters[[
        ContextRegisterIndex(ring, 0x0f08)]];
    var found = FALSE;
    var top: InterruptID = 0;
    for interrupt_id = 0 to 63 do
        if !found && pending[interrupt_id] == '1' then
            top = interrupt_id as InterruptID;
            found = TRUE;
        end;
    end;
    _ExtendedSystemRegisters[[ContextRegisterIndex(ring, 0x0f09)]] =
        NaturalToWord(top as integer {0..262144});
end;

func SetInterruptPending(ring: AccessControlRing,
                         interrupt_id: InterruptID)
begin
    let index = ContextRegisterIndex(ring, 0x0f08);
    _ExtendedSystemRegisters[[index]][interrupt_id] = '1';
    RefreshTopPendingInterrupt(ring);
end;

func ClearInterruptPending(ring: AccessControlRing,
                           interrupt_id: InterruptID)
begin
    let index = ContextRegisterIndex(ring, 0x0f08);
    _ExtendedSystemRegisters[[index]][interrupt_id] = '0';
    RefreshTopPendingInterrupt(ring);
end;

readonly func InterruptEnabled(ring: AccessControlRing,
                               interrupt_id: InterruptID) => boolean
begin
    let interrupt_config = _ExtendedSystemRegisters[[
        ContextRegisterIndex(ring, 0x0f07)]];
    if interrupt_id == TimerInterruptId(ring) then
        return interrupt_config[1] == '1';
    else return interrupt_config[0] == '1';
    end;
end;

func ReadInterruptPending(ring: AccessControlRing) => Word
begin
    RefreshTimerPending(ring);
    return _ExtendedSystemRegisters[[ContextRegisterIndex(ring, 0x0f08)]];
end;

func ReadTopPendingInterrupt(ring: AccessControlRing) => Word
begin
    RefreshTimerPending(ring);
    return _ExtendedSystemRegisters[[ContextRegisterIndex(ring, 0x0f09)]];
end;

func EndOfInterrupt(ring: AccessControlRing, value: Word)
begin
    if value[63:6] == Zeros{58} then
        ClearInterruptPending(ring, UInt(value[5:0]) as InterruptID);
    end;
    _ACRTrapAsynchronous[[ring]] = FALSE;
    _ACRTrapArgumentValid[[ring]] = FALSE;
end;
```
<!-- GENERATED-ASL-END: unit -->
