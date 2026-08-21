---
{
  "id": "ADR-0023",
  "title": "Uniform instruction-attempt status and fault isolation",
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
    "PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001",
    "PTO-ARCH-STATE-CLOSURE-001",
    "PTO-RELEASE-VERIFICATION",
    "PTO-REQ-STATE-001",
    "PTO-SOURCE-HIERARCHY",
    "PTO-TILE-CAPACITY-PER-PE"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ARCHITECTURE",
    "PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT",
    "PTO-BLOCK-MODEL-FAULTS-ROLLBACK"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0023: Uniform instruction-attempt status and fault isolation

## Context

PTO exposes three decoded execution boundaries: scalar, bundle/command, and
direct tile. Each returned an executed or rejected status, but each also read
the shared `_LastFault` latch without first beginning a new attempt. A fault
from an earlier instruction could therefore make a later valid instruction
report rejection unless its caller invoked `ClearFault()` manually.

`ClearFault()` is not the right execution-boundary operation. It clears the
current ACR's visible trap status, cause, arguments, and validity in addition to
the transient model latch. Starting a handler instruction after trap entry must
not erase the architectural record that the manager will inspect.

## Decision

- Every public decoded execution boundary begins exactly one architectural
  instruction attempt. The boundary clears only `_LastFault` and
  `_FaultAddress`, then advances architectural time once.
- Beginning an attempt does not modify ACR trap status, cause, arguments,
  asynchronous state, saved trap context, pending interrupts, or any scalar,
  bundle, tile, memory, or ordering state.
- Scalar, command, tile, and unified status types are typed projections of the
  same two-outcome contract:
  - `Executed` means the decoded attempt completed without a synchronous
    architectural fault;
  - `Rejected` means the attempt raised a synchronous fault, including an
    unknown encoding, illegal operand or selector, instruction-legality fault,
    breakpoint/assertion, service request, or runtime access fault.
- A rejected attempt must leave `_LastFault` set to its architectural fault.
  A successful attempt leaves `_LastFault = Fault_None` and
  `_FaultAddress = 0`.
- Unknown encodings and pre-effect legality failures may change only the
  architectural time and synchronous trap envelope. Instruction-specific
  runtime faults obey their family's defined preflight and rollback contract.
- `ExecutePTOInstruction` delegates 16-, 32-, and 48-bit attempts to exactly
  one scalar or command boundary. Its unknown 64-bit path begins the attempt
  itself. No path may tick twice.
- `ExecuteTileInstructionWithoutTime` is an internal composition boundary. A
  bundle commit may call it only inside an already-started command attempt; it
  neither resets the attempt latch nor advances time.
- `ClearFault()` remains an explicit manager/test transition for clearing the
  visible current-ACR trap bank. It is never an implicit instruction prelude.

## Consequences

A valid handler instruction is no longer poisoned by the fault that transferred
control to it, and inspecting the prior trap remains possible after that
instruction executes. Scalar, command, direct tile, and unified execution now
have the same success/rejection meaning, one-tick rule, and legality-failure
preservation boundary.

The uniform contract does not claim that every instruction-family runtime
corner is already closed. Per-form result, alias, access, and rollback evidence
remains owned by Stage 4; this decision closes only the shared execution-attempt
boundary.
