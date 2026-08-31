---
{
  "id": "ADR-0111",
  "title": "ASL instruction fetch and functional-model boundary",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-08-29",
  "accepted": "2026-08-31",
  "rejected": null,
  "superseded": null,
  "baseline": "e9b621ddce041ff2c770bef67adc41946db87295",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-REQ-INSTRUCTION-DISPATCH-001",
    "PTO-REQ-INSTRUCTION-FETCH-001",
    "PTO-REQ-PHYSICAL-MEMORY-BINDING-001"
  ],
  "affected_units": [
    "PTO-ARCH-DISPATCH-TOP-LEVEL",
    "PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE",
    "PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH",
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/179",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0111: ASL instruction fetch and functional-model boundary

## Context

PTO ASL already owns decode, legality, and execution once a caller supplies an
encoded instruction and its 16, 32, 48, or 64-bit length. A functional model
that privately fetches, determines length, decodes, or advances architectural
state would create a second ISA semantic owner.

The executable reference flow also needs model instances, ELF loading, host
memory, scheduling, step observations, process completion, snapshots, identity,
and a consumer ABI. Those mechanisms are not PTO architectural state or
instruction behavior and must not be defined as portable PTO semantics.

## Decision

### Architecture-owned instruction fetch

PTO ASL owns one next-instruction action. It reads the current TPC, rejects an
odd TPC with `Fault_InstructionPC`, preflights and fetches the first
little-endian halfword, and determines instruction length from bit 0 and bits
`[3:1]`:

- non-escape prefixes select 16 bits when bit 0 is zero and 32 bits when it is
  one;
- the `111` escape selects 48 bits when bit 0 is zero and 64 bits when it is
  one.

The action preflights the complete selected byte range before reading the
remaining bytes. A denied, unmapped, overflowing, or truncated range raises
`Fault_InstructionPage` at the original TPC without a decoded instruction
attempt or partial architectural effect. After successful fetch, the existing
`ExecutePTOInstruction` entry remains the only decoded execution owner.

### Architecture-owned physical-memory contract

PTO ASL owns address translation, access permission, preflight, ordering,
precise-fault, and commit semantics. Physical byte storage is reached through
named profile primitives. The reference profile binds those primitives to its
bounded ASL byte array. Another executable profile may bind them to external
storage only while preserving the same architectural contract. Fixed reference
array bounds do not constrain every implementation.

### Model architecture and ABI

Model lifecycle, initial-state injection, cross-instruction session state,
step-result envelopes, pending host requests, ELF loading, scheduling,
stop-PC/step-budget policy, snapshots, descriptors, manifests, worker
protocols, C ABI, and process exit are owned outside PTO architecture by the
functional-model repository.

The accepted bring-up model starts with one PTO Core, one instruction stream,
PE0 selected as the initial/current scalar agent, and PE1 through PE3 left in
reset state until an ASL-owned PE-mask or collective action changes them. This
is model initialization policy over existing PTO state, not new architectural
state.

The first ELF closure may use runner-owned stop-PC completion. A hosted
`exit_group` mapping is a hosted ABI and cannot redefine PTO service-request or
trap behavior.

### Reference and optimized backends

The initial reference backend uses the repository-pinned ASLRef interpreter.
A future native backend may implement the same model ABI only after it is
differentially validated against that reference backend. Backend selection does
not change PTO architectural meaning.

## Compatibility

- No instruction encoding or assembly spelling changes.
- Existing `ExecutePTOInstruction` decode and execution behavior is unchanged.
- Existing `RaiseServiceRequest` and `Fault_ServiceRequest` behavior is
  unchanged.
- Dynamic ELF, full Linux ABI, devices, asynchronous scheduling, timing, and
  multi-Core execution remain outside this decision.
- Model ABI and implementation identities may evolve without claiming PTO ISA
  compatibility.

## Verification obligations

- Positive 16, 32, 48, and 64-bit length and fetch points, plus exhaustive
  low-prefix totality.
- Odd-PC, unmapped first-halfword, truncated complete-range, and illegal
  encoding points with precise no-partial-effect evidence.
- Reference-array physical read/write evidence and an independently tested
  external-memory backend.
- Existing instruction-dispatch and service-request tests remain unchanged.
- Model instance, ELF, host request, descriptor, snapshot, transport, and
  consumer behavior is tested in the functional-model and consumer repositories,
  not asserted as PTO architecture.

## Decision state

The architecture owner accepted the fetch-length rule and the separation of
PTO architecture from model architecture, ABI, hosted runtime, and
implementation on 2026-08-31. Implementation may proceed in the named owners.
