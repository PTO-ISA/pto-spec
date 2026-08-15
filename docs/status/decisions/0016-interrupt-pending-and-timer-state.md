# ADR 0016: Define interrupt pending and timer state

## Status

Accepted.

## Context

The visible ACR register family includes interrupt configuration, pending,
priority, acknowledgement, timer time, and timer comparison registers. The
previous model treated most of them as unrelated generic words. `EOIEI` cleared
trap-status flags without clearing the named pending interrupt, and timer
comparison had no observable effect.

PTO needs a self-contained rule for interrupt bit identity, priority, enable
gating, and reassertion.

## Decision

- `IPENDING_ACRn` is a read-only 64-bit bitmap. Bit `i` records pending
  interrupt ID `i` for the selected ACR.
- The complete architectural interrupt injection domain is ID 0 through ID 63,
  represented by the `InterruptID` type. Values outside that domain are not
  architectural interrupt events and do not enter the trap or fault model.
- `TOPEI_ACRn` is read-only and returns the numerically lowest set pending ID.
  It returns zero when the bitmap is empty; software uses `IPENDING` to
  distinguish no interrupt from pending ID zero.
- `ECONFIG_ACRn[0]` enables external interrupt entry and bit 1 enables timer
  interrupt entry. PTO v0 resets both bits to one in every ACR bank. Disabled
  interrupts become pending but do not enter a handler.
- ACR0 uses timer interrupt ID 1. ACR1 through ACR15 use timer interrupt ID 3.
- `TIMER_TIME_ACRn` reads the architectural monotonic counter.
  `TIMER_TIMECMP_ACRn` is zero at reset. A nonzero comparison sets the timer
  pending bit whenever unsigned time is greater than or equal to the compare
  value; zero or a future value clears it.
- `EOIEI_ACRn` is write-only. A canonical interrupt ID in bits 5:0 clears that
  pending bit and completes the bank's current interrupt status. A timer whose
  nonzero comparison remains reached reasserts when pending state is observed;
  software writes zero to the comparator to stop it.
- Interrupt injection sets pending state before enable checking. Enabled
  injection then uses the existing interrupt trap envelope and visible saved
  context.

## Consequences

Pending, top priority, enable, acknowledgement, timer threshold, reassertion,
all-bank reset, and trap entry are one coherent executable subsystem. Endpoint
IDs 0 and 63 have direct injection and acknowledgement witnesses. Writes to
`IPENDING` and `TOPEI` fault through their catalog-declared read-only access
class.
