---
{
  "id": "ADR-0111",
  "title": "ASL functional-model fetch, step, memory, and host boundary",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-08-29",
  "accepted": "2026-08-29",
  "rejected": null,
  "superseded": null,
  "baseline": "e9b621ddce041ff2c770bef67adc41946db87295",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-REQ-FUNCTIONAL-FETCH-001",
    "PTO-REQ-FUNCTIONAL-MEMORY-001",
    "PTO-REQ-INSTRUCTION-DISPATCH-001",
    "PTO-REQ-SERVICE-REQUEST-INTERCEPT-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-FUNCTIONAL-MODEL",
    "PTO-ARCH-DISPATCH-FUNCTIONAL-STEP",
    "PTO-ARCH-DISPATCH-TOP-LEVEL",
    "PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE",
    "PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH",
    "PTO-ARCH-PROFILE-FUNCTIONAL-MODEL",
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE",
    "PTO-ARCH-PROFILE-RESET",
    "PTO-ARCH-PROFILE-SERVICE-REQUEST-INTERCEPT",
    "PTO-ARCH-STATE-FUNCTIONAL-MODEL",
    "PTO-SCALAR-MODEL-AGU-MEMORY"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/179",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0111: ASL functional-model fetch, step, memory, and host boundary

## Context

The PTO ASL model currently owns complete execution of one instruction only
after a caller supplies both the encoded bits and the 16/32/48/64-bit length.
It does not own instruction fetch, length determination, a typed one-step
result, host-backed memory equivalence, or a resumable functional-model host
request. Existing gfrun code performs those functions privately, which would
leave two functional ISA implementations if reused unchanged.

The functional model must instead be generated from PTO ASL. gfrun may retain
ELF loading, physical-byte storage, CLI, tracing, stop policy, and host service
execution, but it may not retain a private instruction decoder, legality model,
architectural state transition, or PC/fault implementation.

PTO-SPEC owns only the architecture portions of this split. Functional-model
lifecycle, step-result, pending-request, snapshot, and hosted-ABI NDF are
owned in `the downstream model repository` under
`docs/pto-asl-functional-model-ndf-v1.json`.

## Decision

### Fetch and length

The ASL step owner reads the current TPC, rejects odd TPC with
`Fault_InstructionPC`, fetches one little-endian halfword, and selects length
from bit 0 and bits [3:1]. Non-escape prefixes select 16 or 32 bits according to
bit 0; the `111` escape selects 48 or 64 bits according to bit 0. The complete
selected byte range is preflighted before remaining bytes are read.

An unmapped or denied instruction byte raises `Fault_InstructionPage` at the
original TPC. Fetch and length faults publish no partial GPR, queue, bundle,
Tile, memory, PC, or functional request effect beyond the precise trap/fault
transition.

### Model step boundary

The non-architectural `ExecuteOnePTOStep` harness assembles fetched bytes and
calls the existing `ExecutePTOInstruction` owner. Its observation envelope and
runner policy are defined by the the downstream model repository model NDF, not PTO NDF.

### Memory

The reference ASL profile retains the bounded byte array. All physical-byte
reads, writes, and reset use named profile primitives. A generated model may
bind those same primitives to host storage only when it preserves existing
translation, permission, ordering, precise-fault, commit, and reset rules.
Fixed verification bounds do not become implementation address-space limits.

### Model reset and topology

The functional profile is one PTO Core with four architectural PEs, one shared
PC/BPC, and PE0 selected as the reset current memory agent. Initial entry, SP,
and GPR injection use named initialization actions. Legacy gfrun threads are not
reinterpreted as PTO PEs.

The entry/GPR injection and PE0 startup policy belongs to the the downstream model repository
model NDF. The four PE register files and shared PC/BPC they initialize remain
PTO architectural state.

### Snapshot and identity

G1 does not accept a snapshot encoding or generated-model descriptor contract.
`PTO-REQ-FUNCTIONAL-STATE-SNAPSHOT-001` and
`PTO-REQ-FUNCTIONAL-PROFILE-IDENTITY-001` remain open requirements for G2/G3.
Their eventual design must keep functional profile state separate from
portable state and must bind exact normalized generator inputs, but no runtime
or compatibility behavior is inferred by this decision.

## Boundaries retained

- No instruction encoding or assembly spelling changes.
- `RaiseServiceRequest` and `Fault_ServiceRequest` retain their current ACR,
  trap-vector, and resume-TPC semantics.
- Dynamic ELF, MMU, devices, full Linux ABI, TLS/fd/barrier behavior, multi-Core
  execution, and timing remain outside this decision.
- Hosted multi-PE startup and completion remain owned by issue #150.

## Alternatives considered

1. **External model request state/action (selected).** The generated harness
   exposes a pending token and exactly-once completion under the
   the downstream model repository model NDF. It is distinct from PTO service-request traps.
2. **Runner observation only.** Expose existing service-request/trap state and
   do not provide resumable host requests in the model library.

The first bring-up runs freestanding ELF with a runner stop PC. Hosted
`exit_group`/ACRC behavior remains outside this decision and must not be copied
from private gfrun syscall semantics into the ASL library.

## Accepted choices

1. The four-way low-prefix length rule is portable PTO fetch semantics.
2. Functional-model host requests use separate resumable model state under the
   the downstream model repository model NDF; they do not become PTO architectural state.
3. Initial scalar execution uses PE0. PE1–PE3 remain reset until an ASL-owned
   PE-mask or collective action updates them.
4. Initial ELF bring-up uses stop-PC completion. Hosted `exit_group`/ACRC
   behavior remains owned by issue #150.

## Verification obligations

The accepted G1 clauses require:

- Positive 16/32/48/64 fetch and execution points, plus exhaustive prefix
  length totality.
- Odd-PC, unmapped, truncated/cross-boundary, and illegal-encoding points with
  precise no-partial-effect evidence. The accepted prefix rule has no illegal
  length encoding.
- Reference-array physical read/write/reset boundary evidence.
- Four-PE reset/current-agent/initial-state isolation.
- Existing service-request tests proving unchanged trap behavior.
- Pending-step idempotence, frozen origin PE, stale/duplicate/mismatched
  completion, cross-reset token uniqueness, token-exhaustion rejection, and no
  direct host mutation of GPR/PC/trap state.

G2/G3 retain separate, not-yet-accepted obligations for callback transaction
equivalence, deterministic snapshot round trip and schema rejection, model
identity compatibility, hosted request meanings, memory responses, and
fault-versus-process-exit policy.

## Decision state

The architecture owner accepted the G1 fetch, physical-memory primitive, and
service-request interception boundary on 2026-08-29. Model lifecycle, reset,
step observation, host completion, snapshot, identity, callback transaction,
and hosted ABI are maintained in the the downstream model repository model NDF. Generated
model/runtime work must consume PTO owners without introducing a second ISA
semantic definition.
