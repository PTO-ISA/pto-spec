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

This unit defines the per-ACR timer interrupt ID and the rule that derives timer-pending state from the cycle counter and comparison register.

<!-- PTO-READER-BLOCK: arch-timer-concepts-state role=concepts-state -->
## Timer identifiers and comparison value

`TimerInterruptId` returns interrupt ID `1` for ACR0 and interrupt ID `3` for every other ACR.

`RefreshTimerPending` reads the comparison value from context-register low index `0x0f21` and compares it with `_SystemRegisters.cycle` as unsigned values.

<!-- PTO-READER-BLOCK: arch-timer-rules-interactions role=rules-interactions -->
## Pending-state rule

The timer interrupt is set pending when the comparison value is nonzero and the cycle value is greater than or equal to it. Otherwise the timer interrupt is cleared.

The update uses `SetInterruptPending` or `ClearInterruptPending`, so it also refreshes the top-pending interrupt value.

<!-- PTO-READER-BLOCK: arch-timer-boundaries role=boundaries -->
## Architectural boundaries

A zero comparison value disables timer-pending assertion even when the cycle value is zero or greater. This owner does not increment the cycle counter or define when timer refresh is invoked beyond calls to `RefreshTimerPending`.

<!-- PTO-READER-BLOCK: arch-timer-example-usage role=example-usage -->
## Non-normative threshold example

On a timer refresh for ACR0 with comparison `100`, cycles `99` and below leave interrupt ID `1` clear. Cycle `100` and later set ID `1` until the comparison becomes zero or moves above the current cycle.

<!-- PTO-READER-BLOCK: arch-timer-related-owners role=related-owners-navigation -->
## Related owners

- [Context registers](context.md) is the declared dependency and supplies the ring-relative index calculation.
- [Interrupt registers](interrupt.md) owns pending-bit storage, enable checks, and top-pending selection.
- [System-register addressing](addressing.md) owns the cycle counter field read here.
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
