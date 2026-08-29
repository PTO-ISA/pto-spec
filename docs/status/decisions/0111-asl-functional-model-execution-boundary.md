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
    "PTO-REQ-FUNCTIONAL-HOST-REQUEST-001",
    "PTO-REQ-FUNCTIONAL-MEMORY-001",
    "PTO-REQ-FUNCTIONAL-RESET-001",
    "PTO-REQ-FUNCTIONAL-STEP-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-FUNCTIONAL-MODEL",
    "PTO-ARCH-DISPATCH-FUNCTIONAL-STEP",
    "PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE",
    "PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH",
    "PTO-ARCH-PROFILE-FUNCTIONAL-MODEL",
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE",
    "PTO-ARCH-PROFILE-RESET",
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

### Step

`ExecuteOnePTOStep` assembles the fetched bytes into a zero-extended `bits(64)`
container and calls the existing `ExecutePTOInstruction` owner. Its result
exposes pre/post PC/BPC, raw bytes, length, execution status, precise fault, and
current PE identity. Runner stop-PC and step-budget policy remain outside the
ASL result.

### Memory

The reference ASL profile retains the bounded byte array. All physical-byte
reads, writes, and reset use named profile primitives. A generated model may
bind those same primitives to host storage only when it preserves existing
translation, permission, ordering, precise-fault, commit, and reset rules.
Fixed verification bounds do not become implementation address-space limits.

### Reset and topology

The functional profile is one PTO Core with four architectural PEs, one shared
PC/BPC, and PE0 selected as the reset current memory agent. Initial entry, SP,
and GPR injection use named initialization actions. Legacy gfrun threads are not
reinterpreted as PTO PEs.

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

1. **Host request profile state/action (selected).** Add a named
   functional-model profile request with a pending token and exactly-once
   completion. It is distinct from architecture service-request traps and is
   the only accepted G1 path for a host adapter to return one scalar GPR result
   and resume at a captured TPC.
2. **Runner observation only.** Expose existing service-request/trap state and
   do not provide resumable host requests in the model library.

The first bring-up runs freestanding ELF with a runner stop PC. Hosted
`exit_group`/ACRC behavior remains outside this decision and must not be copied
from private gfrun syscall semantics into the ASL library.

## Accepted choices

1. The four-way low-prefix length rule is portable PTO fetch semantics.
2. Functional-model host requests use separate resumable profile state with a
   pending token and exactly-once completion; they do not reuse
   `Fault_ServiceRequest`.
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

The architecture owner accepted the G1 fetch, step, physical-memory primitive,
reset, topology, and generic scalar host-completion choices on 2026-08-29.
Their owning ASL clauses and focused AVS implement those accepted clauses.
Snapshot, model identity, callback transaction, hosted ABI, and memory-response
contracts remain open for G2/G3. Generated model/runtime work must consume the
accepted owners without introducing a second semantic definition.
