---
{
  "id": "ADR-0098",
  "title": "B.SUBVIEW and B.ASSEMBLE range-modifier association",
  "status": "accepted",
  "authors": ["ckwllawliet <641433195@qq.com>"],
  "approvers": ["zhoubot"],
  "created": "2026-08-21",
  "accepted": "2026-08-21",
  "rejected": null,
  "superseded": null,
  "baseline": "23ca8833fef3f97dbc65beef4924b0b4671cdfdf",
  "target_releases": ["0.58.4"],
  "affected_ndf": [
    "PTO-B-IOT-STREAM-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-SUBVIEW-RANGE-001",
    "PTO-B-ASSEMBLE-RANGE-001",
    "PTO-B-SUBVIEW-DESCRIPTOR-001",
    "PTO-BLOCK-TILE-OPERATION-APPLICABILITY-001",
    "PTO-B-ASSEMBLE-LOCAL-GENERATION-001",
    "PTO-B-ASSEMBLE-SHARED-GENERATION-001",
    "PTO-B-ASSEMBLE-SHARED-STANDALONE-001",
    "PTO-B-ASSEMBLE-CONSUMER-READINESS-001",
    "PTO-B-ASSEMBLE-SPECULATION-001",
    "PTO-B-ASSEMBLE-PRODUCER-EFFECT-ELIGIBILITY-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROFILE-RESET",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-SUBVIEW",
    "PTO-BLOCK-B-ASSEMBLE",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS",
    "PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS",
    "PTO-BLOCK-MODEL-STATE-CONTROL-STATE",
    "PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-ARCH-DATA-TYPES-TRAP-CONTEXT",
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE",
    "PTO-ARCH-PROFILE-TRAP-CONTEXT-RECOVERY",
    "PTO-ARCH-STATE-TRAP-CONTEXT",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
    "PTO-BLOCK-MODEL-FAULTS-ROLLBACK",
    "PTO-BLOCK-MODEL-LIFECYCLE-RESET",
    "PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
    "PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS",
    "PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR",
    "PTO-BLOCK-MODEL-STATE-SHARED-GENERATION",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/122",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0098: B.SUBVIEW and B.ASSEMBLE range-modifier association

## Context

The architecture needs range modifiers that bind source subviews and
destination writer ranges without creating a second Tile-register namespace.
The accepted forms use opcode `0x53`, expose the complete Local and Shared
SizeCode reach, and require decoded carriers, Local lifecycle, and Shared
collective behavior to close together before the candidate can be released.

## Decision

`B.SUBVIEW` uses `match=0x00000053`, `mask=0x0000787f`; `B.ASSEMBLE` uses
`match=0x00001053`, `mask=0x0000707f`. Their Local and Shared range and parent
SizeCodes are 1 through 12, encoding 128 B through 256 KiB; code zero retains
its mnemonic-specific source/MIDDLE/LAST meaning and codes 13 through 15 are
reserved. The derived offset is `GPR[RegSrc] + ZeroExtend(uimm11)` modulo XLEN,
with the unsigned immediate preserved in its carrier.

Each modifier belongs only to the immediately preceding contiguous `B.IOT` or
`B.IOS` syntactic group.  Source zero, source one, and destination roles are
consumed in that order, with omissions and duplicates diagnosed at group
closure; an intervening command closes the group and cannot acquire a
retroactive modifier.  `B.IOT.L=1` keeps the group open for modifiers.  A
`B.IOS` source-one selector is not a destination substitute.

Raw legality and reserved-field checks precede operand reads and carrier
updates.  A binder with `PEMode=000` still opens a syntactic group, but each
raw-legal modifier is discarded without reads, binding, allocation, range,
lifecycle, memory, or downstream effects.  Reserved encodings remain
`IllegalInstruction` even on that zero-mode path.

A Shared destination with more than one participating PE is legal only when
its B.IOS group carries B.ASSEMBLE. A multi-PE standalone Shared destination
raises `Fault_TileLegality` before effects. A single-PE standalone Shared
destination preserves the ordinary B.IOS behavior.

Stage 1 therefore owns the exact decoder forms, strict association/order,
raw-legality and zero-mode evidence, and derived operand carriers.  It does
not assign release identity or expand release selection. Stage 2 also owns
the Local descriptor derivation, all-operation applicability, generation
identity/replay, readiness/coverage, transactional publication, and Local
fault/restart state carried by the model units listed in this record. Shared
descriptor, generation, fault, and publication semantics are part of the same
formal closure and cannot be represented by carrier-only evidence.

The minimal portable abstract carrier records a Local consumer's bound
committed or post-LAST generation,
opaque execution-domain identity, range or whole-parent mode, required CELL
set, and waiting/eligible/retired/cancelled state. Waiting is non-faulting and
has no effect; publication remains one atomic transition after complete
coverage/readiness, no fault or squash, and precise irrevocable LAST
retirement. Dynamic writers carry the instruction-instance plus opaque
execution-domain identity; same-instance same-domain replay is idempotent, and
an architecture squash cancels every unretired contribution in that domain
while preserving the older committed mapping. Every accepted Tile handler
group has exactly one generated rollback-safe, atomic-auxiliary, or
nonrollback-auxiliary effect class. The first two participate in the same
transaction; a nonrollback class raises `Fault_TileLegality` before body or
auxiliary effects. These carriers are portable abstract state only: backend
BlockROB, physical queues, ready tables, hidden replay queues, and token
allocation/width remain implementation-defined.

## Consequences

The ASL instruction units, common dispatch/group model, generated catalog and
traceability projections, and executable AVS points cite this decision.  The
existing B.IOT/B.IOS encoding, PE-mode, source-order, and rollback owners stay
in force except for the explicitly added immediately preceding modifier group.
The range NDF clauses and their direct state,
dispatch, descriptor, rollback, trap-context, and executable consumers are
linked in this record for review and closure. This extension targets the
separately selected 0.58.4 candidate but does not publish it.

## Binary envelope consequence

The accepted `B.SUBVIEW` and `B.ASSEMBLE` forms increase the common
encoded-form envelope from 540 to 542 forms. The reviewed encoded-form
fingerprint for the resulting scalar-plus-command projection is
`3725501cc03c831ad9a4f549d8234272819c6b7e3382e27e06ec744238ed6319`.
This records the exact catalog change; it does not assign a release identity
or alter the already-published release manifest.

## Rejected Alternatives

- The stale `0x43` RFC encoding is not retained because Issue #122 explicitly
  supersedes it.
- A standalone modifier group or retroactive association is rejected because
  it would make source order and fault priority ambiguous.
- Treating `PEMode=000` as an early decoder rejection is rejected; it is a
  discarded syntactic group while reserved raw encodings remain illegal.
