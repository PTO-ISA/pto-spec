<!-- GENERATED FROM: asl/arch/system-registers/timer.asl -->
# Timer

**Normative ASL source:** `asl/arch/system-registers/timer.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-TIMER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-timer-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit owns the rule that turns the architectural cycle count and one stored comparison value into the pending state of one timer interrupt per ring, and it fixes which interrupt ID each ring's timer uses.

It does not count cycles and it does not store the comparison value itself; it reads the stored value through the context-register helpers and updates pending state through the interrupt owner.

<!-- PTO-READER-BLOCK: arch-timer-concepts-state role=concepts-state -->
## Interrupt identity and the comparison value

`TimerInterruptId` returns interrupt ID 1 for ACR0 and interrupt ID 3 for every other ring, so the timer of a ring always occupies the same position in that ring's pending bitmap.

`RefreshTimerPending` reads the comparison value from context-register offset `0x0f21` of the ring it is given and compares it with `_SystemRegisters.cycle`. Both sides are treated as unsigned values.

The two inputs come from different owners: `cycle` is reset by the addressing owner and advanced by the execution path, and the comparison word is ordinary context-register storage.

<!-- PTO-READER-BLOCK: arch-timer-rules-interactions role=rules-interactions -->
## The pending rule

The timer interrupt is set pending when the comparison value is not zero and the cycle count is greater than or equal to it. In every other case the timer interrupt is cleared.

The update goes through `SetInterruptPending` or `ClearInterruptPending`, so the top pending interrupt value is recomputed on the same call. A timer that becomes pending while some lower-numbered interrupt is pending leaves the top value pointing at that lower interrupt.

A zero comparison value can never set the timer interrupt, whatever the cycle count is. An exact match does set it, because the comparison is inclusive.

Design point: zero would otherwise be the smallest reachable cycle count, so treating it as an ordinary threshold would make the timer pending from the very first cycle of a reset core. Reserving zero for disabled gives software a way to arm the timer without also having the pending bit set at reset.

Design point: naming the interrupt by the ring comes before the comparison, so the same refresh function serves all rings and the pending bit position never depends on which comparison value happens to be programmed.

<!-- PTO-READER-BLOCK: arch-timer-boundaries role=boundaries -->
## Architectural boundaries

This owner runs the comparison only when the refresh function is called. Reading the interrupt pending bitmap calls it, reading the top pending interrupt calls it, and a write to the comparison offset of a ring calls it for that ring. Resetting a ring's comparison word is not one of those writes in this repository, so a zero comparison value does not by itself clear a pending timer bit.

Acknowledging a timer interrupt clears the pending bit and does not change the comparison value, so the next refresh sets the bit again while the threshold still matches. Clearing the interrupt for good means making the comparison value zero or making it exceed the current cycle count.

<!-- PTO-READER-BLOCK: arch-timer-example-usage role=example-usage -->
## Non-normative threshold example

With the comparison value of ACR0 set to 100, a refresh at cycle count 99 leaves interrupt ID 1 clear, and a refresh at cycle count 100 sets it. Raising the comparison value above the current cycle count clears it again.

On ACR1 the same sequence acts on interrupt ID 3, because `TimerInterruptId` maps every ring other than ACR0 to ID 3.

<!-- PTO-READER-BLOCK: arch-timer-related-owners role=related-owners-navigation -->
## Related owners

- [Context registers](context.md) is the declared dependency and computes the ring-relative offset used here.
- [Interrupt registers](interrupt.md) owns the pending bitmap, the enable gates, and the top pending value.
- [System-register addressing](addressing.md) owns the `cycle` field that this rule reads.
- [Access control](access-control.md) defines the ring type that selects between interrupt ID 1 and interrupt ID 3.
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
