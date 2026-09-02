---
{
  "id": "ADR-0005",
  "title": "PTO v0 concrete reference profile",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-28",
  "accepted": "2026-07-28",
  "rejected": null,
  "superseded": null,
  "baseline": "b04318ee75b253157a792b9d08f75e9e95eacf0f",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ARCH-EXTENSION-FIRST-USE-PROFILE-001",
    "PTO-MATRIX-POSTPROCESS-BITEXACT-001",
    "PTO-MATRIX-QUANT-BITEXACT-001",
    "PTO-TCVT-E8M0-PROFILE-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROFILE-APPLICABILITY",
    "PTO-ARCH-PROFILE-E8M0-CONVERSION",
    "PTO-ARCH-PROFILE-EXTENSION-FIRST-USE",
    "PTO-ARCH-PROFILE-MATRIX-POSTPROCESS",
    "PTO-ARCH-PROFILE-MATRIX-QUANTIZATION",
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE",
    "PTO-ARCH-PROFILE-REFERENCE-QUANTIZATION",
    "PTO-ARCH-PROFILE-RESET",
    "PTO-ARCH-PROFILE-TRAP-CONTEXT-RECOVERY"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR-0005: PTO v0 concrete reference profile

- Date: 2026-07-28
- Requirement: PTO-REQ-PROFILE-001

## Context

Named `impdef` interfaces make target-dependent choices visible, but an
interface without a selected implementation leaves the executable repository
unable to prove one complete architecture configuration. Numeric behavior,
translation and permissions, reset values, access-control rings, and architectural time
must be reproducible without inheriting host-language or backend behavior.

The present model is intended to establish a deterministic formal reference.
Available public evidence is not sufficient to claim IEEE-754 or any target's
exact numeric implementation.

## Decision

The repository selects `pto-v0` as its active implementation profile. It keeps
the portable `impdef` boundary and supplies exactly one `implementation func`
for every registered hook. The registry, declarations, implementations, and
direct conformance calls must have identical name sets.

PTO v0 defines:

- deterministic typed reference numeric operations. Finite scalar FP32/FP64
  and the shared scalar/TCVT conversion subset use their accepted mathematical
  rules; remaining raw-carrier or delegated hooks do not claim IEEE-754 or
  target-hardware conformance;
- identity address translation with full bounded-memory access for ACR0 and
  ACR1 and a protected upper region for ACR2 through ACR15;
- explicit ACR0..ACR15 state and ACR0-only extended system-register families;
- one architectural time tick per decoded scalar or tile execution attempt;
  and
- a deterministic reset of observable scalar, tile-descriptor, memory,
  reservation, ordering, fault, system, time, and access-control-ring state.

The profile does not remove the implementation interface. A future IEEE or
hardware profile must use a distinct identity, implement the complete registry,
and add its own conformance evidence.

## Consequences

- The assembled ASL model is total under one named, reproducible configuration.
- CI can reject missing, extra, or untested profile hooks.
- Reviewers can distinguish PTO v0's formal-reference choices from portable PTO
  rules and target behavior.
- PTO v0 results must not be cited as IEEE-754 or hardware conformance evidence.
