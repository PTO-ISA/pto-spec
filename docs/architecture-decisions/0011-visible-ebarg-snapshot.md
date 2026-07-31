# ADR 0011: Make EBARG the visible PTO v0 trap snapshot

## Status

Accepted.

## Context

The system-register contract exposes 18 banked `EBARG` registers, while the
earlier reference model saved all return state only in an internal record. That
made the visible register values observationally unrelated to `ACRE`: software
could inspect or edit an `EBARG` word, but recovery ignored the edit.

The architecture also permits profile-defined extended execution state beyond
the first-layer register snapshot. PTO v0 needs bounded executable storage for
bundle arguments and other state that has no allocated `EBARG` word.

## Decision

In PTO v0, `EBARG` is the editable first-layer trap snapshot:

- `EBARG0[3:0]` records the source ACR, bit 4 is snapshot valid, bits 5 and 6
  record bundle-active and bundle-body-active, bits 10:7 record bundle kind,
  bits 13:11 record transfer kind, and bit 14 records the bundle condition.
  Bits 63:15 are reserved zero.
- `EBARG_BPC_CUR`, `EBARG_BPC_TGT`, `EBARG_TPC`, and `EBARG_LRA` record the
  current BPC, next target, resume TPC, and local return address.
- `EBARG_TQ0` through `EBARG_TQ3` and `EBARG_UQ0` through `EBARG_UQ3` record all
  temporary queue entries in newest-to-oldest order.
- PTO v0 has no first-layer loop-boundary or loop-counter registers, so trap
  save writes zero to `EBARG_LB` and `EBARG_LC`; software may still read and
  write those context words, but recovery does not consume them.
- `EBARG_EXTCTX_PTR`, `EBARG_EXTCTX_META`, and `EBARG_TPLFLAGS` are persistent
  read/write context words. Ordinary trap save does not overwrite them.
- `ECSTATE` records the source `CORE_STATE`; bits 3:0 select the recovery ACR
  and bit 4 records whether the source was in a bundle body.

`ACRE` consumes the visible `ECSTATE` and `EBARG` PC, queue, return, and bundle-
control fields. ACR0 software may therefore edit those fields before recovery.
Recovery clears `EBARG0.VALID`. A missing snapshot, reserved control encoding,
body-active without bundle-active, inconsistent source ACR, or odd BPC/TPC is
an execution-state-check fault rather than a silent no-op. An unsupported ACRE
request-type encoding remains an illegal-instruction fault.

The internal saved context also preserves bundle dimensions, scalar and tile
bindings, control/data attributes, fallthrough state, the 64-bit machine
execution mask, and all eight 32-bit warp predicates. These fields have no
complete EBARG encoding in PTO v0, so successful recovery restores their saved
values. EBARG-covered fields remain authoritative and may be deliberately
edited by manager software before recovery.

The bounded `_TrapContexts` record is PTO v0 profile-defined extended `EBSTATE`,
not an alternative visible register file. It retains bundle argument and commit
state that has no allocated first-layer `EBARG` word. Those fields remain an
explicit extended-context profile dependency.

## Consequences

Trap recovery observes software edits to the visible return PC and queue state,
and every `EBARG` address has a defined reset and access behavior. Complete
portable serialization of the remaining extended bundle state is still tracked
separately from this first-layer snapshot closure.

The system-register behavior catalog therefore partitions the range rather
than assigning one over-broad behavior to all 18 words: 13 recovery-active
snapshot registers, two save-zero/recovery-inert loop-context words, and three
save-preserved/recovery-inert extended-context words. Tests exercise all five
tail registers across reset, software write, trap save, and recovery.
