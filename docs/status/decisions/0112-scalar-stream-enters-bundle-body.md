---
{
  "id": "ADR-0112",
  "title": "Decoded scalar stream enters the active bundle body",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-09-01",
  "accepted": "2026-09-01",
  "rejected": null,
  "superseded": null,
  "baseline": "6fc3141ac790b6b6fed192bedc99a9264f2b25ac",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-REQ-INSTRUCTION-DISPATCH-001",
    "PTO-REQ-SCALAR-BODY-ENTRY-001"
  ],
  "affected_units": [
    "PTO-ARCH-DISPATCH-TOP-LEVEL",
    "PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP",
    "PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/191",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0112: Decoded scalar stream enters the active bundle body

## Context

BSTART creates an active bundle and leaves its body inactive while command
instructions collect the header. Scalar instructions belong to the body
microinstruction stream, but the encoded scalar dispatch path did not invoke
the existing `EnterBundleBody` transition. Consequently a fetched compiler
sequence could decode an accepted conditional SETC form and still reject it
because the body-active state remained false.

Independent public v0.58 executable and assembly references separate
BSTART/BSTOP command boundaries from scalar SETC execution and place SETC in
the body microinstruction stream. PTO therefore needs one architecture-owned
transition that is independent of any functional-model worker or ELF ABI.

## Decision

After a scalar form decodes successfully, scalar dispatch checks the current
bundle lifecycle. If a bundle is active and its body is not active, dispatch
enters the body before checking operation applicability and operand legality.

This rule applies to every decoded scalar form. It does not create a list of
special scalar header instructions: SETRET, SETC.TGT, conditional SETC,
ordinary scalar arithmetic, memory, floating-point, and system operations are
all scalar body-stream instructions. Command-family instructions remain the
only header stream and do not perform this transition.

An unmatched scalar carrier does not enter the body because no scalar form was
decoded. Once a form is decoded, body entry precedes later rejection. A fault
from applicability, reserved operands, source readiness, or operation
semantics therefore preserves body-active state in the precise fault context.

BSTOP or a following BSTART may commit an empty block without synthesizing a
body instruction. The absence of a scalar instruction remains distinct from a
decoded scalar instruction that faults after entering the body.

## Compatibility

- No instruction encoding, assembly spelling, or scalar value semantic changes.
- Existing compiler streams gain the missing lifecycle transition without
  rewriting their raw words.
- Direct mnemonic validation that prepares body state explicitly remains valid.
- Unmatched encodings retain their prior illegal-instruction behavior and do
  not publish body entry.
- Model lifecycle, ELF loading, stop policy, worker transport, and C ABI remain
  outside PTO architecture under ADR-0111.

## Verification obligations

- The first decoded scalar instruction enters an active body.
- A later conditional SETC executes with the body active.
- An unmatched carrier rejects without body entry.
- A decoded scalar that later rejects preserves body-active fault context.
- A SYS scalar enters a SYS body before its ordinary permission behavior.
- An empty block can still commit through BSTOP or a following BSTART.
- Existing scalar, command-boundary, fetch, and precise-fault suites remain
  green.

## Decision state

The architecture owner accepted automatic scalar body entry on 2026-09-01.
Implementation is owned by scalar dispatch and the existing bundle lifecycle
state; downstream models must not infer or duplicate the rule.
