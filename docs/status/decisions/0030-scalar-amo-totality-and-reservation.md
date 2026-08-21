---
{
  "id": "ADR-0030",
  "title": "Scalar AMO totality, reservations, and restart",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-30",
  "accepted": "2026-07-30",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-SD-XOR-ADR-CONTRACT-001",
    "PTO-SW-ADD-ADR-CONTRACT-001",
    "PTO-SW-AND-ADR-CONTRACT-001",
    "PTO-SW-OR-ADR-CONTRACT-001",
    "PTO-SW-SMAX-ADR-CONTRACT-001",
    "PTO-SW-SMIN-ADR-CONTRACT-001",
    "PTO-SW-UMAX-ADR-CONTRACT-001",
    "PTO-SW-UMIN-ADR-CONTRACT-001",
    "PTO-SW-XOR-ADR-CONTRACT-001",
    "PTO-SWAPB-ADR-CONTRACT-001",
    "PTO-SWAPD-ADR-CONTRACT-001",
    "PTO-SWAPH-ADR-CONTRACT-001",
    "PTO-SWAPW-ADR-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-SCALAR-CASB",
    "PTO-SCALAR-CASD",
    "PTO-SCALAR-CASH",
    "PTO-SCALAR-CASW",
    "PTO-SCALAR-DMA",
    "PTO-SCALAR-HL-CASB",
    "PTO-SCALAR-HL-CASD",
    "PTO-SCALAR-HL-CASH",
    "PTO-SCALAR-HL-CASW",
    "PTO-SCALAR-LD-ADD",
    "PTO-SCALAR-LD-AND",
    "PTO-SCALAR-LD-OR",
    "PTO-SCALAR-LD-SMAX",
    "PTO-SCALAR-LD-SMIN",
    "PTO-SCALAR-LD-UMAX",
    "PTO-SCALAR-LD-UMIN",
    "PTO-SCALAR-LD-XOR",
    "PTO-SCALAR-LR-B",
    "PTO-SCALAR-LR-D",
    "PTO-SCALAR-LR-H",
    "PTO-SCALAR-LR-W",
    "PTO-SCALAR-LW-ADD",
    "PTO-SCALAR-LW-AND",
    "PTO-SCALAR-LW-OR",
    "PTO-SCALAR-LW-SMAX",
    "PTO-SCALAR-LW-SMIN",
    "PTO-SCALAR-LW-UMAX",
    "PTO-SCALAR-LW-UMIN",
    "PTO-SCALAR-LW-XOR",
    "PTO-SCALAR-SC-B",
    "PTO-SCALAR-SC-D",
    "PTO-SCALAR-SC-H",
    "PTO-SCALAR-SC-W",
    "PTO-SCALAR-SD-ADD",
    "PTO-SCALAR-SD-AND",
    "PTO-SCALAR-SD-OR",
    "PTO-SCALAR-SD-SMAX",
    "PTO-SCALAR-SD-SMIN",
    "PTO-SCALAR-SD-UMAX",
    "PTO-SCALAR-SD-UMIN",
    "PTO-SCALAR-SD-XOR",
    "PTO-SCALAR-SW-ADD",
    "PTO-SCALAR-SW-AND",
    "PTO-SCALAR-SW-OR",
    "PTO-SCALAR-SW-SMAX",
    "PTO-SCALAR-SW-SMIN",
    "PTO-SCALAR-SW-UMAX",
    "PTO-SCALAR-SW-UMIN",
    "PTO-SCALAR-SW-XOR",
    "PTO-SCALAR-SWAPB",
    "PTO-SCALAR-SWAPD",
    "PTO-SCALAR-SWAPH",
    "PTO-SCALAR-SWAPW"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR-0030: Scalar AMO totality, reservations, and restart

> Historical-evidence note: test paths named below record the evidence used when this ADR was accepted; they are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

- Date: 2026-07-30
- Requirements: PTO-REQ-SCALAR-AMO-001, PTO-REQ-SCALAR-OPERAND-001,
  PTO-REQ-MEMORY-001, PTO-REQ-MEMORY-COMPLETION-001,
  PTO-REQ-MEMORY-TSO-001

## Context

PTO accepts 53 scalar AMO forms: four load-reserved forms, four
store-conditional forms, four swaps, eight compare-and-swaps, sixteen
load-return read-modify-write forms, sixteen store-only read-modify-write
forms, and one 64-byte DMA form. The Stage 1 decoded-effect suite reached every
form and included representative failed-SC, failed-CAS, and DMA-fault cases.
That evidence did not close the Stage 4 questions around every encoded ordering
and address-class modifier, width boundaries, reservation precedence, faults,
restart, Reg5 aliases, or overlapping DMA ranges.

## Decision

### Width and value rules

AMO memory operands are evaluated at the form width. Byte and halfword old
values are zero-extended on destination writeback, word old values are
sign-extended to XLEN, and doubleword old values are unchanged. Store operands,
CAS expected and desired operands, and RMW arithmetic inputs use only the low
8, 16, 32, or 64 bits selected by the form.

`SWAP` installs the truncated operand. `ADD` wraps at the access width. `AND`,
`OR`, and `XOR` operate on the width-normalized bit patterns. `SMIN` and `SMAX`
compare signed values at the access width; `UMIN` and `UMAX` compare unsigned
values. Load-return RMW forms publish the normalized old value. Store-only RMW
forms perform the same indivisible memory transition without a destination.

CAS compares the width-normalized old value with the width-normalized expected
operand. A match installs the width-normalized desired value. A mismatch leaves
memory unchanged but remains an ordered atomic read. Both outcomes publish the
normalized old value.

### Ordering and address class

For forms that encode both `aq` and `rl`, `00`, `10`, `01`, and `11` select
relaxed, acquire, release, and acquire-release ordering respectively. The
store-only RMW forms encode only `rl`, selecting relaxed or release ordering.
DMA has relaxed load and store events. Every encoded modifier combination is
legal.

The `far` field is an address-class hint owned by `AtomicAddress`. PTO v0 maps
both values to the same flat address. The four short CAS forms do not encode
`far`; the four `HL.CAS*` forms do. A different profile may refine the hint only
through the named profile interface and must retain the AMO completion, fault,
and reservation contract.

### LR/SC reservation contract

The local reservation granule is the 64-byte line containing the original LR
address. A successful LR records the exact original address and access width
for inspection and replaces any previous reservation. A faulting LR performs
no reservation update, so a pre-existing reservation is preserved.

The encoded `SrcZero` field of every LR form is an ignored alias field. All 32
values select the same LR operation and do not read a scalar register.

SC success depends only on a valid reservation for the 64-byte line containing
the SC address. Exact byte address and access width need not match the LR. A
reservation miss returns one, clears the reservation, performs no alignment,
translation, or permission probe, emits no event, and does not access memory.

A line match clears the reservation before probing the store. A successful
probe writes the width-truncated value, emits one store event, and returns zero.
An alignment, translation, or permission fault therefore still clears the
reservation, emits no event, preserves memory and the destination, and enters
the ordinary trap envelope. Recovery reissues the complete instruction. Since
the reservation was already cleared, that reissue completes as a reservation
miss unless software establishes a new reservation first; it returns one and
does not store.

### Faults, completion, and reservation invalidation

Access checks use the common precedence: alignment, translation, then
permission or bounded-memory failure. Faults report the original architectural
address. LR performs one read probe. A reservation-matched SC performs one
write probe. RMW and CAS perform read and write probes before loading or
storing, and require both probes to name the same translated location. DMA
probes its source range before its destination range. The first failing probe
wins.

Translation and permission hooks are readonly. A profile can choose a different
translated address or permission result, including a read/write distinction,
but a probe cannot mutate architectural state. PTO v0 uses identity translation
and one permission decision for reads and writes, so translated-address
mismatch and write-only denial remain reviewed profile obligations rather than
executable PTO-v0 branches.

No faulting LR, RMW, CAS, or DMA commits a destination, memory event, memory
write, or new reservation. Faulting SC follows the deliberate reservation-clear
rule above. After recovery, LR, RMW, CAS, and DMA restart by full reissue and
commit exactly once when the access becomes legal.

Any completed store whose original range overlaps the reserved 64-byte line
invalidates the reservation. This includes successful SC, swap, RMW, successful
CAS, and the DMA destination. A failed CAS is a read only and preserves the
reservation. Non-overlapping writes preserve it.

### DMA completion

DMA copies exactly 64 bytes from `SrcL` to `SrcR`. Both complete ranges are
probed before the first data or event effect. All source bytes are snapshotted
before any destination byte is written, so exact overlap and overlap in either
direction have memmove semantics. A successful captured execution emits eight
ordered 8-byte relaxed loads followed by eight ordered 8-byte relaxed stores.
Source failure takes precedence over destination failure; either fault leaves
memory, events, and reservation state unchanged.

### Reg5 ordering

Every address, value, expected, and desired source is read before the first
memory or destination effect. This defines GPR and T/U queue aliases, including
a destination that aliases any source. Destination codes 0 and 24 through 29
discard, 30 pushes U, and 31 pushes T. Store-only RMW and DMA have no
destination. Source queue reads always use the pre-instruction snapshot.

## Evidence contract

Closure requires `spec/evidence/scalar-amo-totality.json` to bind all 53 form
IDs to generated, decoded evidence. The package retains 66 Stage 1 attempts and
adds 2,474 non-duplicative Stage 4 attempts: 337 modifier/order/address-class,
320 value/conditional, 1,408 Reg5/ignored-field alias, 313 fault/restart/no-probe,
81 reservation-interaction, and 15 DMA overlap/boundary attempts. Reservation
assertions are merged into those attempts whenever the decoded operation already
exercises the same transition; the count does not include duplicate state-only
witnesses. The repository checker derives the inventory from the catalog,
executes the independent AVS points under `tests/asl/scalar/amo/`, and rejects maturity
promotion if any form, field value, effect class, semantic dimension, unique
marker, or evidence count drifts.

## Consequences

- `S4-T3` may close only when the executable package and machine-readable
  ledger pass together.
- The 64-byte line match, failed-SC no-probe rule, and faulting-SC reservation
  clear are PTO architecture, not implementation conveniences.
- LR `SrcZero` remains an accepted ignored alias; constraining it to zero would
  be an incompatible encoding change.
