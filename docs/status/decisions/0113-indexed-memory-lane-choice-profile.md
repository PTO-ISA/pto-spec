---
{
  "id": "ADR-0113",
  "title": "Named indexed-memory lane-choice profiles",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-08-29",
  "accepted": "2026-08-29",
  "rejected": null,
  "superseded": null,
  "baseline": "569ac82a156025f453f133712dbe6360f0280c75",
  "target_releases": ["0.58.5"],
  "release_boundary": true,
  "affected_ndf": [
    "PTO-REQ-INDEXED-MEMORY-LANE-CHOICE-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-INDEXED-MEMORY-LANE-CHOICE",
    "PTO-ARCH-PROFILE-INDEXED-MEMORY-LANE-CHOICE",
    "PTO-TILE-MODEL-MEMORY-ATOMICS",
    "PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/184",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0113: Named indexed-memory lane-choice profiles

## Context

MSCATTER, MSCATTER_MASK, and MGATHER_CAS preflight every enabled lane before
their first memory effect. Duplicate and overlapping lane addresses are legal,
and portable PTO deliberately does not select an internal lane permutation or
duplicate-address winner. The owning ASL represented that freedom with two
bare `ARBITRARY` expressions.

Bare nondeterministic expressions do not identify an executable profile
policy. They also prevent an ASL-generated functional model and the ASLRef
oracle from publishing a stable differential trace. This is a profile-binding
gap, not permission to make one lane order portable.

## Decision

Portable ASL exposes `SelectIndexedMemoryLanePosition` as a named profile hook.
At every permutation position the hook must select one position at or after the
current position and before the enabled-lane count. The existing swap then
commits that lane exactly once. The selection has no architecture-visible
state or fault effect.

The pto-v0 reference and generated functional profiles bind the policy
`pto-v0-indexed-memory-logical-ascending-v1`. It selects the current position,
so lanes commit in the logical row-major order in which the owning operation
built its lane array. A target profile may select another legal permutation
only under a distinct profile identity and executable evidence.

This decision does not make ascending order portable and does not change
B.CATR atomicity. B.CATR may prevent external interleaving of the complete
block effect, but it still does not choose an internal lane order or portable
duplicate-address winner.

## Compatibility

- No instruction encoding, assembly, legality, or operand contract changes.
- Programs that do not depend on duplicate or overlapping lane addresses are
  unaffected by the selected executable profile.
- Programs that observe a duplicate-address winner remain profile-dependent;
  portable software cannot assume the pto-v0 reference result.
- ADR-0020 remains in force for its memory-event and atomicity decisions. Its
  row-major statement is interpreted as the pto-v0 executable profile binding,
  not a replacement for the current owning ASL's portable freedom.

## Verification

- First, middle, last, singleton, and maximum lane-choice boundaries.
- Reference-profile identity selection and legality rejection.
- Duplicate-address MSCATTER event/final-byte order.
- Duplicate-address MGATHER_CAS success, observed-old-value, event, and final
  memory order.
- Full typed-AST generation contains no unprofiled `E_Arbitrary` constructor.
- ASLRef and generated functional-model results agree under the exact policy
  identifier.

## Release boundary

This accepted record covers the PTO ISA 0.58.5 ASL and NDF drift required for
deterministic generated-model execution. Generated artifacts must record the
exact choice-policy identity; they may not reproduce the lane rule in a second
runtime implementation.
