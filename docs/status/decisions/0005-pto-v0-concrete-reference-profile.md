# ADR-0005: PTO v0 concrete reference profile

- Status: Accepted
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

- deterministic raw-carrier numeric operations, explicitly not IEEE-754;
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
