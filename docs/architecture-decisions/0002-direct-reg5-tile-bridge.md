# ADR-0002: Normalize Reg5 tile selectors as direct flat-register bridges

- Status: accepted
- Formal-model issue: [#4](https://github.com/PTO-ISA/pto-spec/issues/4)
- Decision date: 2026-07-28

## Context

Scalar instruction forms use five-bit register selectors. Values 0..23 address
the scalar GPR file. Higher source values name four T-hand and four U-hand
positions, while selected destination values historically implied an ordered
handoff mechanism. PTO requires the inherited scalar forms without introducing
a second instruction level, hidden operand queue, or body-local state.

## Decision

PTO interprets high Reg5 source selectors as direct reads of element (0,0) from
flat tile registers T1..T4 and U1..U4. Destination selector 30 writes U1 element
(0,0), selector 31 writes T1 element (0,0), and selectors 0 and 24..29 discard
the result. Compressed `->t` forms use the same direct T1 destination.

The referenced tile must be allocated with a non-empty valid region. The bridge
does not rotate registers, enqueue values, allocate tiles, or change any hidden
cursor. Source reads and destination writes are ordinary operations on the
single architecture-visible tile register file.

## Consequences

- All accepted scalar forms retain a total Reg5 interpretation.
- The one-level architecture needs no implicit scalar-to-tile queue state.
- Implementations may pipeline the transfer, but the portable result is the
  direct register update defined in `asl/scalar/operands.asl`.
- Any future ordered handoff mechanism requires a new explicit PTO operation and
  a replacement architecture decision.
