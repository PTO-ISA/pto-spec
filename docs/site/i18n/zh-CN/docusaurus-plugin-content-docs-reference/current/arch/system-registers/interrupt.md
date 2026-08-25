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

本单元拥有待处理中断更新、最高优先待处理中断选择、使能检查、读取时的定时器刷新以及中断结束状态变化。

<!-- PTO-READER-BLOCK: arch-interrupt-concepts-state role=concepts-state -->
## 本页使用的上下文寄存器布局

对每个 ACR，低位索引 `0x0f07` 保存中断配置，`0x0f08` 保存待处理中断位图，`0x0f09` 保存选中的最高优先待处理中断 ID。

`RefreshTopPendingInterrupt` 从中断 ID `0` 扫描到 `63`，并记录第一个被置位的 ID。如果没有位被置位，保存的最高优先值保持为 `0`。

<!-- PTO-READER-BLOCK: arch-interrupt-rules-interactions role=rules-interactions -->
## 待处理、使能与读取行为

`SetInterruptPending` 设置一个待处理位；`ClearInterruptPending` 清除一个待处理位。两者都会立即重新计算最高优先待处理中断值。

`InterruptEnabled` 对该环的定时器中断检查配置位 `1`，对其他每个中断 ID 检查位 `0`。

`ReadInterruptPending` 和 `ReadTopPendingInterrupt` 在返回各自的上下文寄存器值之前调用 `RefreshTimerPending`。

<!-- PTO-READER-BLOCK: arch-interrupt-boundaries role=boundaries -->
## 中断结束边界

只有输入的位 `63:6` 都为零时，`EndOfInterrupt` 才清除一个待处理中断；此时低六位选择 ID。无论编码检查结果如何，它都会清除该环的 `_ACRTrapAsynchronous` 和 `_ACRTrapArgumentValid`。

单独的最高优先待处理中断值 `0` 无法区分“没有待处理中断”和“中断 ID `0` 待处理”；待处理中断位图才提供该信息。

<!-- PTO-READER-BLOCK: arch-interrupt-example-usage role=example-usage -->
## 非规范优先级示例

如果待处理中断 ID `5` 和 `9` 同时被置位，刷新会记录 `5`，因为扫描在第一个置位处停止。清除 ID `5` 后，最高优先值重新计算为 `9`。

<!-- PTO-READER-BLOCK: arch-interrupt-related-owners role=related-owners-navigation -->
## 相关所有者

- [定时器寄存器](timer.md)是声明的依赖项，并驱动定时器待处理状态刷新。
- [上下文寄存器](context.md)定义每 ACR 寄存器的索引算术。
- [访问控制](access-control.md)定义可移植中断陷阱目标。
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
