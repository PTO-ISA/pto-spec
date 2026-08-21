---
{
  "id": "ADR-0009",
  "title": "scalar TPC and execution status",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-BARG-CONTINUATION-001",
    "PTO-BSTART-DECISION-BINDING-001",
    "PTO-BSTOP-DECISION-BINDING-001",
    "PTO-C-BSTOP-DECISION-BINDING-001",
    "PTO-L-BSTOP-DECISION-BINDING-001",
    "PTO-REQ-BUNDLE-STATE-001",
    "PTO-REQ-STATE-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT",
    "PTO-ARCH-STATE-PROGRAM-COUNTER",
    "PTO-BLOCK-BSTART",
    "PTO-BLOCK-BSTOP",
    "PTO-BLOCK-C-BSTOP",
    "PTO-BLOCK-L-BSTOP",
    "PTO-BLOCK-MODEL-STATE-BARG",
    "PTO-BLOCK-MODEL-STATE-CONTROL-STATE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0009: scalar TPC and execution status

## Context

The scalar decoder previously invoked instruction semantics without advancing
TPC for ordinary instructions. It also returned `ScalarExecution_Executed`
after a semantic handler raised an architectural fault, while bundle and tile
dispatch returned a rejected status for the same condition. Those behaviors
made sequential execution and the public status contract ambiguous.

## Decision

- TPC contains the address of the scalar instruction being dispatched.
- A non-control scalar instruction that completes without a fault advances TPC
  by its encoded length in bytes.
- Relative branches and jumps, indirect jumps, and ACRE own the next-TPC write;
  the common dispatch path does not add a second sequential advance.
- Any architectural fault raised during scalar execution returns
  `ScalarExecution_Rejected` after the trap transition.
- `ScalarExecution_Executed` means the instruction completed without an
  architectural fault.
- An illegal scalar register selector raises `Fault_IllegalInstruction`; it is
  not a tile-legality fault.

## Consequences

Decoded tests must check both instruction effects and TPC movement. Fault tests
must expect a rejected status and verify trap state, fault address, and absence
of partial instruction effects. A handler that starts writing TPC must be added
to the explicit next-TPC ownership predicate before it can be accepted.
