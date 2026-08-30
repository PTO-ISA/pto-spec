---
{
  "id": "ADR-0114",
  "title": "Functional-model step observation v1",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-08-29",
  "accepted": "2026-08-29",
  "rejected": null,
  "superseded": null,
  "baseline": "1fa86d9066dc2772de3929c2d807f944e87a6f28",
  "target_releases": ["0.58.5"],
  "release_boundary": true,
  "affected_ndf": [],
  "affected_model_contracts": [
    "PTO-REQ-FUNCTIONAL-HOST-REQUEST-001",
    "PTO-REQ-FUNCTIONAL-STEP-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-FUNCTIONAL-MODEL",
    "PTO-ARCH-DISPATCH-FUNCTIONAL-STEP",
    "PTO-ARCH-PROFILE-FUNCTIONAL-MODEL"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/179",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0114: Functional-model step observation v1

## Context

ADR-0111 established ASL-owned fetch and one-step execution, but its initial
result record did not distinguish a predecode trap from a decoded instruction
rejection. It also exposed only a host-request token, forcing a runner to read
mutable profile state separately to discover the request type and scalar
argument. Finally, the result did not preserve the precise 24-bit trap cause.

Those omissions would require gfrun or a generated runtime to infer ASL state,
creating a second observation contract even if instruction semantics remained
ASL-owned.

## Decision

`PTOFunctionalStepResult` includes an instruction-attempt status with exactly
three values: `NotAttempted`, `Executed`, and `Rejected`.

- Uninitialized, pre-existing host request, odd TPC, prefix access fault, and
  complete-fetch access fault report `NotAttempted`.
- A decoded instruction accepted by `ExecutePTOInstruction` reports
  `Executed`, including an accepted instruction whose ASL effects end in a
  precise trap or host request.
- A decoded instruction rejected by the unique dispatcher reports `Rejected`.

The result snapshots `fault_cause` from the current precise trap context. It is
zero when no synchronous fault exists. A host-request result also snapshots the
immutable request type and scalar argument together with the existing token and
origin PE. Result GPR and resume TPC remain internal completion state and are
not exposed to the host adapter.

Runner stop reason, process exit, ELF state, memory-write hashes, state hashes,
and hosted syscall meanings remain outside this ASL record. Snapshot and model
descriptor contracts remain open and are not accepted by this decision.

## Observation matrix

| Path | Step status | Instruction status |
| --- | --- | --- |
| Before functional initialization | Unsupported | NotAttempted |
| Existing pending host request | HostRequest | NotAttempted |
| Odd or inaccessible fetch PC | Trap | NotAttempted |
| Truncated complete fetch | Trap | NotAttempted |
| Illegal decoded encoding | Trap | Rejected |
| Accepted 16/32/48/64 instruction | Executed or ASL-produced trap/request | Executed |

## Compatibility

- No instruction encoding, assembly, legality, or architectural state changes.
- The result record is an experimental functional-model profile interface; no
  previously published stable C ABI layout is changed.
- Consumers must read the ASL-projected fields and may not reconstruct them
  from private decoder or host state.

## Verification

- Positive 16/32/48/64 paths report `Executed`.
- Illegal encoding reports `Rejected` after one architectural attempt.
- Predecode fault and pending paths report `NotAttempted` without time advance.
- A nonzero precise fault cause is preserved exactly.
- Repeated pending steps preserve token, origin PE, type, and argument.
- Generated C ABI fields compare one-for-one with the ASL result.

## Release boundary

This accepted record covers the PTO ISA 0.58.5 observation-schema drift needed
by the generated model and gfrun adapter. It adds no hosted ABI or process-exit
semantics.
