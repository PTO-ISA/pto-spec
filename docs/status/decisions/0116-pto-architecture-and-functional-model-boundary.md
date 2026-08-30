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
  "affected_units": [
    "PTO-ARCH-PROFILE-FUNCTIONAL-MODEL",
    "PTO-ARCH-STATE-FUNCTIONAL-MODEL"
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
- Existing functional-model profile state and ASL step behavior are unchanged.
- Snapshot/restore and summary-digest ABI changes may evolve under the exact
  generated-model descriptor without claiming PTO architectural compatibility.

## Verification

- The two owning NDF clauses explicitly exclude model ABI and implementation
  identity from PTO architecture.
- ASLRef continues to execute the same functional-model state transitions.
- Model ABI tests independently cover checkpoint, descriptor, copy-out, hash,
  and consumer behavior.
- PTO/downstream lock gates continue to prove common architectural projections
  against an exact PTO commit and tree.
