---
{
  "id": "ADR-0115",
  "title": "Functional-model exit_group hosted-ABI binding",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-08-30",
  "accepted": "2026-08-30",
  "rejected": null,
  "superseded": null,
  "baseline": "3fe5ae12e8c4ef841c93e5ed5ef46caac01b03a4",
  "target_releases": ["0.58.5"],
  "release_boundary": true,
  "affected_ndf": [
    "PTO-REQ-SCALAR-BODY-ENTRY-001"
  ],
  "affected_model_contracts": [
    "PTO-REQ-FUNCTIONAL-EXIT-GROUP-001",
    "PTO-REQ-FUNCTIONAL-HOST-REQUEST-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROFILE-FUNCTIONAL-MODEL",
    "PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL",
    "PTO-SCALAR-MODEL-SYS-SEMANTICS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/150",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR-0115: Functional-model exit_group hosted-ABI binding

## Summary

Bind the established freestanding `exit_group` convention to the ASL-owned
functional-model host-request state without changing portable ACRC service
request behavior.

## Context

ADR-0111 deliberately used stop-PC completion and left hosted ACRC meanings to
issue #150. The generated library and gfrun now have an ASL-owned resumable
host-request boundary, but no guest instruction can open it. The first ELF
bring-up needs one terminal hosted request while the broader Linux ABI,
startup, TLS, file-descriptor, barrier, and multi-PE runtime remain deferred.

The established freestanding convention uses ACRC request type 1, absolute
GPR `a7` for the syscall number, Linux `exit_group` number 94, and absolute GPR
`a0` for the exit status. Copying that decode into gfrun would recreate a
second functional semantic owner.

## Decision

Only an initialized functional-model profile intercepts the exact tuple:

- decoded ACRC request type is 1;
- current PE `a7` is 94;
- current PE `a0` is the process exit status.

The ASL owner opens generic host request type 94 before portable service-ring
routing, captures `a0` as the immutable argument and response GPR, captures
the next four-byte TPC as the resume address, and marks the active SYS block
terminal. Failure to allocate a unique request token raises
`Fault_ExecutionStateCheck` without a pending request.

For every other ACRC tuple, and whenever the functional profile is not
initialized, the existing portable service-request permission, routing, trap,
terminal, and recovery semantics are unchanged.

The gfrun host shell recognizes only request type 94 in this bring-up. It
completes the ASL request with the same bounded scalar status and then records
terminal runner outcome `exit_group`; unknown request types fail closed. The
process status is the low eight bits of the captured `a0`, matching normal
host process exit-code transport, while the manifest retains the full XLEN
argument.

## Contract delta

The non-architectural hosted-ABI contract
`PTO-REQ-FUNCTIONAL-EXIT-GROUP-001` owns the exact ACRC/GPR tuple,
interception order, request fields, resume TPC, and fail-closed token behavior.
It does not define a PTO instruction encoding, assembly spelling, or
architectural state.

`PTO-REQ-SCALAR-BODY-ENTRY-001` closes the executable phase transition that
was previously present only as an uncalled model action: the first decoded
scalar form after a BSTART header enters the body before applicability. An
undecodable value leaves the phase unchanged.

## Defaults and intentionally unspecified behavior

No other syscall number, ACRC request type, host memory response, file
descriptor, TLS operation, barrier, startup sequence, or multi-PE termination
meaning is assigned. Those inputs remain portable ACRC behavior or an
unsupported host request as applicable.

## Compatibility and dependent-toolchain impact

Freestanding ELF producers may use the already established ACRC/a7/a0 tuple.
The generated library gains no private syscall decoder; the exact behavior is
projected from ASL. gfrun must not inspect guest instruction bytes or GPRs to
reconstruct the request.

## Alternatives considered

- Keep stop-PC as the only bring-up completion. This does not exercise the
  generated host-request boundary from a real ELF.
- Recognize ACRC and `a7` directly in gfrun. This would violate the single
  semantic-source invariant.
- Assign a new instruction or pseudo-op. This would add an unnecessary
  encoding and would not validate the existing freestanding ABI tuple.

## Risks and mitigations

The primary risk is accidental expansion into a Linux syscall emulator. The
exact tuple and single request type are closed, unknown requests fail closed,
and issue #150 retains the broader hosted runtime.

## Implementation obligations

- Implement the interception only in owning ASL.
- Route the first decoded scalar form through the ASL-owned body-entry action.
- Project the request through the generated C ABI without hand-coded guest
  decode in the runtime or gfrun.
- Add a real low-address ELF corpus case and three-way differential evidence.
- Preserve the complete request and terminal outcome in versioned manifests.

## Verification obligations

- Focused ASL proves the exact tuple, immutable argument, origin PE, token,
  response GPR, resume TPC, and absence of portable service-request fault.
- Existing ACRC tests prove all non-matching tuples remain unchanged.
- ASLRef, standalone library, and gfrun agree on every step and final exit
  status for the host-request ELF.
- Unknown request and token failure paths are fail-closed and effect-free.

## Release consequences

This is a 0.58.5 functional-model/hosted-ABI release boundary. Generated ASL
mirrors, ADR index, traceability, model descriptor inputs, corpus identity, and
release evidence must be regenerated at the final commit.
