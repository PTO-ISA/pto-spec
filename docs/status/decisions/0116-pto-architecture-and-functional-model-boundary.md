---
{
  "id": "ADR-0116",
  "title": "PTO architecture and functional-model implementation boundary",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-08-30",
  "accepted": "2026-08-30",
  "rejected": null,
  "superseded": null,
  "baseline": "ce644e3e1b4a37acc0c69d4ab00763797c2df4c0",
  "target_releases": ["0.58.5"],
  "release_boundary": true,
  "affected_ndf": [
    "PTO-REQ-FUNCTIONAL-PROFILE-IDENTITY-001",
    "PTO-REQ-FUNCTIONAL-STATE-SNAPSHOT-001"
  ],
  "affected_model_contracts": [
    "PTO-REQ-FUNCTIONAL-EXIT-GROUP-001",
    "PTO-REQ-FUNCTIONAL-HOST-REQUEST-001",
    "PTO-REQ-FUNCTIONAL-RESET-001",
    "PTO-REQ-FUNCTIONAL-STEP-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-FUNCTIONAL-MODEL",
    "PTO-ARCH-DISPATCH-FUNCTIONAL-STEP",
    "PTO-ARCH-PROFILE-FUNCTIONAL-MODEL",
    "PTO-ARCH-STATE-FUNCTIONAL-MODEL",
    "PTO-SCALAR-MODEL-SYS-SEMANTICS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/179",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR-0116: PTO architecture and functional-model implementation boundary

## Context

PTO-SPEC is the architecture source. Its owning ASL defines instruction
semantics, architectural state, legality, faults, ordering, and profile
behavior. A downstream ISA projection may provide comparison evidence, but a
compiler, emulator, functional model, or downstream implementation cannot
replace the PTO owner.

The functional-model bring-up also needs checkpointing, C ABI negotiation,
descriptor identity, trace digests, and gfrun integration. Treating those
mechanisms as PTO architecture would create architecture-visible behavior that
no PTO instruction or state requirement defines.

## Decision

The specification distinguishes four layers:

1. PTO architecture owns state and transitions once in ASL/NDF.
2. Functional-model architecture defines how one model instance observes and
   carries the ASL-owned state without creating another semantic owner.
3. The model ABI defines lifecycle calls, version negotiation, copy-out,
   checkpoint compatibility, and consumer failure behavior.
4. The implementation selects MIR/runtime data structures, binary envelopes,
   hashing, storage, and optimization.

The contract registry is part of this distinction. Portable and named PTO
behavior remains in NDF with the existing architecture/scalar/block/tile/state
and memory layers. Functional step envelopes, initialization lifecycle,
deterministic sequence, pending tokens, and completion handshakes use separate
`PTO-MODEL-CONTRACT` records with `layer=model`. The freestanding ACRC/a7/a0
`exit_group(94)` convention uses the same non-NDF registry with `layer=abi`.
Neither registry layer is PTO architecture or may satisfy an architectural
NDF obligation.

The executable model-contract ASL may call PTO architecture owners so ASLRef
and the generated library exercise the same semantics. Its model-control
globals use a model state identity, are excluded from PTO architectural-state
claims, and are reset by model initialization rather than by the architecture
reset owner. This executable harness placement does not turn model lifecycle
or hosted ABI behavior into PTO architecture.

The existing `PTO-ARCH-*` unit IDs and `asl/arch/` paths identify the shared
ASL source-order surface used by the generator; they are not sufficient to
classify a clause or state as architectural. NDF versus
`PTO-MODEL-CONTRACT`, the contract layer, and the state identity provide that
classification.

PTO architecture defines no snapshot operation, snapshot format, model
descriptor, C ABI, or summary hash. A functional-model checkpoint may cover
the model's representation of all ASL-owned portable and named profile state,
but its envelope and restore rules remain a model ABI. Host-backed physical
memory must continue to satisfy PTO memory semantics; whether its bytes are
checkpointed by the model or separately by the caller is not PTO architecture.

PTO release and encoding identity remain architectural publication contracts.
Exact source commit/tree, ASLRef pin, generator/MIR inputs, descriptor digest,
and ABI version are generated-model identity. ASL execution cannot branch on
those implementation identities.

## Validation role

The generated functional model is validation evidence for PTO ASL, not an
independent architecture definition. Differential failures are classified as:

- an ASL implementation error, fixed in the owning PTO ASL;
- an ambiguous or missing PTO architecture definition, resolved in PTO before
  downstream work continues;
- a model generator/runtime/ABI defect, fixed without changing architecture;
- a downstream projection mismatch, reconciled back to the PTO owner.

A current downstream projection may be consulted when it states the common
contract more clearly. Agreement is evidence; conflicting definitions remain
visible until PTO makes the owning decision.

## Compatibility

- No instruction encoding, architectural state, legality, fault, or ordering
  rule changes.
- Existing functional-model control state and ASL step behavior are unchanged;
  their classification is corrected from PTO architecture to model or ABI.
- Snapshot/restore and summary-digest ABI changes may evolve under the exact
  generated-model descriptor without claiming PTO architectural compatibility.

## Verification

- Functional-model and hosted-ABI contracts are validated in a separate
  non-NDF registry, while fetch/length, instruction execution, architectural
  state, faults, and memory effects retain their PTO architecture owners.
- Generated functional-model pages identify model-contract ASL as
  non-architectural and do not label it a normative PTO architecture source.
- The functional control state registry uses a model identity and the PTO
  architecture reset owner has no dependency on model-control reset.
- ASLRef continues to execute the same functional-model state transitions.
- Model ABI tests independently cover checkpoint, descriptor, copy-out, hash,
  and consumer behavior.
- PTO/downstream lock gates continue to prove common architectural projections
  against an exact PTO commit and tree.
