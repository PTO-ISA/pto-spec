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

This unit owns the interrupt bookkeeping of one ring: where the pending set lives, how the highest-priority pending interrupt is derived, which configuration bits gate trap entry, and what an end-of-interrupt write changes.

It does not put an interrupt into the trap envelope. The timer owner and `RaiseInterrupt` in the fault-precision owner are the other callers of these functions: the timer owner sets or clears the timer bit, and `RaiseInterrupt` sets the pending bit before it tests the enable gate.

<!-- PTO-READER-BLOCK: arch-interrupt-concepts-state role=concepts-state -->
## Pending set and its derived priority

For each ring, three context-register offsets carry the interrupt state: `0x0f07` holds the interrupt configuration, `0x0f08` holds the pending bitmap, and `0x0f09` holds the selected top pending interrupt.

`RefreshTopPendingInterrupt` scans bit positions 0 through 63 of the pending bitmap and stores the position of the first set bit. The scan starts at position 0, so the stored value is the numerically lowest pending interrupt.

Design point: the top pending value is a derived cache of the bitmap rather than a second source of truth, and every function here that changes the bitmap recomputes it in the same call. The stored value therefore stays consistent with the bitmap without a separate software update.

<!-- PTO-READER-BLOCK: arch-interrupt-rules-interactions role=rules-interactions -->
## Pending, enable, and read behavior

`SetInterruptPending` sets one pending bit and recomputes the top value. `ClearInterruptPending` clears one pending bit and also recomputes the top value.

`InterruptEnabled` reads the configuration word: it tests bit 1 for the ring's timer interrupt and bit 0 for every other interrupt ID, so the two interrupt sources are gated separately.

`ReadInterruptPending` and `ReadTopPendingInterrupt` call `RefreshTimerPending` before returning the pending bitmap or the top value, so both reads reflect the current cycle count against the timer comparison.

Design point: because the read functions refresh the timer first, a reader of the interrupt registers sees an up-to-date timer state without the timer source having to post it at the moment the threshold is crossed.

<!-- PTO-READER-BLOCK: arch-interrupt-boundaries role=boundaries -->
## End-of-interrupt boundary

`EndOfInterrupt` takes one word. The low six bits select the interrupt ID, and the remaining bits 6 through 63 must all be zero for the pending bit to be cleared.

The interrupt trap status flags are cleared for the ring whether or not the encoding check passed, so a write with a high bit set still leaves the ring's asynchronous trap status clear.

Design point: a timer interrupt can be reasserted, because the pending refresh runs again on the next read of `0x0f08` or `0x0f09` while the comparison still matches the cycle count. Clearing a timer interrupt for good takes a comparison value that fails the timer rule, that is, zero or a value greater than the current cycle count.

<!-- PTO-READER-BLOCK: arch-interrupt-example-usage role=example-usage -->
## Non-normative priority example

If the pending bitmap has bits for interrupt IDs 2 and 7 set, the top value is 2. Setting the bit for interrupt ID 0 changes the top value to 0, and clearing that bit returns the top value to 2.

Every function in this unit is called with a ring, so the same sequences applied to ACR1 act on the pending bitmap and configuration of ACR1.

<!-- PTO-READER-BLOCK: arch-interrupt-related-owners role=related-owners-navigation -->
## Related owners

- [Timer registers](timer.md) is the declared dependency and drives one pending bit from the cycle count.
- [Context registers](context.md) defines the index arithmetic used for the interrupt offsets.
- [Access control](access-control.md) defines the ring routing that a raised interrupt follows.
- [Trap context](../state/trap-context.md) records the state taken when an enabled interrupt enters the trap envelope.
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
