<!-- GENERATED FROM: asl/arch/system-registers/interrupt.asl -->
# Interrupt

**Normative ASL source:** `asl/arch/system-registers/interrupt.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-INTERRUPT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-interrupt-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit owns pending-interrupt updates, top-pending selection, enable checks, timer refresh on reads, and end-of-interrupt state changes.

<!-- PTO-READER-BLOCK: arch-interrupt-concepts-state role=concepts-state -->
## Context-register layout used here

For each ACR, low index `0x0f07` holds interrupt configuration, `0x0f08` holds the pending bitmap, and `0x0f09` holds the selected top-pending interrupt ID.

`RefreshTopPendingInterrupt` scans pending bits from interrupt ID `0` through `63` and records the first set ID. If no bit is set, the stored top value remains `0`.

<!-- PTO-READER-BLOCK: arch-interrupt-rules-interactions role=rules-interactions -->
## Pending, enable, and read behavior

`SetInterruptPending` sets one pending bit; `ClearInterruptPending` clears one. Both immediately recompute the top-pending value.

`InterruptEnabled` tests configuration bit `1` for the ring's timer interrupt and bit `0` for every other interrupt ID.

`ReadInterruptPending` and `ReadTopPendingInterrupt` call `RefreshTimerPending` before returning their respective context-register values.

<!-- PTO-READER-BLOCK: arch-interrupt-boundaries role=boundaries -->
## End-of-interrupt boundary

`EndOfInterrupt` clears a pending interrupt only when bits `63:6` of its input are zero; the low six bits then select the ID. Regardless of that encoding check, it clears `_ACRTrapAsynchronous` and `_ACRTrapArgumentValid` for the ring.

Top-pending value `0` alone does not distinguish no pending interrupt from pending interrupt ID `0`; the pending bitmap provides that information.

<!-- PTO-READER-BLOCK: arch-interrupt-example-usage role=example-usage -->
## Non-normative priority example

If pending IDs `5` and `9` are both set, refresh records `5` because the scan stops at the first set bit. Clearing ID `5` recomputes the top value as `9`.

<!-- PTO-READER-BLOCK: arch-interrupt-related-owners role=related-owners-navigation -->
## Related owners

- [Timer registers](timer.md) is the declared dependency and drives timer-pending refresh.
- [Context registers](context.md) defines the index arithmetic for per-ACR registers.
- [Access control](access-control.md) defines portable interrupt trap targeting.
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
