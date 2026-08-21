---
{
  "id": "ADR-0041",
  "title": "A2/A3 MX CUBE profile applicability",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-BSTART-TGEMVMX-ACC-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-BIAS-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-BIAS-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-CONTRACT-001",
    "PTO-TGEMV-MX-ACC-CONTRACT-001",
    "PTO-TGEMV-MX-BIAS-CONTRACT-001",
    "PTO-TGEMV-MX-CONTRACT-001",
    "PTO-TMATMUL-MX-ACC-CONTRACT-001",
    "PTO-TMATMUL-MX-BIAS-CONTRACT-001",
    "PTO-TMATMUL-MX-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-BSTART-TGEMVMX",
    "PTO-BLOCK-BSTART-TGEMVMX-ACC",
    "PTO-BLOCK-BSTART-TGEMVMX-BIAS",
    "PTO-BLOCK-BSTART-TMATMULMX",
    "PTO-BLOCK-BSTART-TMATMULMX-ACC",
    "PTO-BLOCK-BSTART-TMATMULMX-BIAS",
    "PTO-TILE-TGEMV-MX",
    "PTO-TILE-TGEMV-MX-ACC",
    "PTO-TILE-TGEMV-MX-BIAS",
    "PTO-TILE-TMATMUL-MX",
    "PTO-TILE-TMATMUL-MX-ACC",
    "PTO-TILE-TMATMUL-MX-BIAS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0041: A2/A3 MX CUBE profile applicability

## Decision scope

This decision is a bounded negative applicability checkpoint. Parent `ADR 0086`,
`cube-matrix`, and `S5-T2` remain open.

## Context

`S5-T2-A` separates profile applicability from numeric result semantics. The
accepted profile identities from ADR 0037 allow target profiles such as
`pto-a2a3-numeric-v1`, but a profile identity does not imply that every
operation/type tuple is supported by that target.

Target-specific support restrictions must be explicit in PTO. This decision
defines a bounded A2/A3 support exclusion for the six MX CUBE selectors. It is
a support-boundary decision only and supplies no CUBE payload arithmetic.

## Decision

For `pto-a2a3-numeric-v1`, the following direct CUBE operation selectors are
unsupported for every one of the 25 architectural `TileDataType` identities:

| Operation key | Function |
| --- | ---: |
| `tile:CUBE:TMATMUL_MX` | 4 |
| `tile:CUBE:TMATMUL_MX_BIAS` | 5 |
| `tile:CUBE:TMATMUL_MX_ACC` | 6 |
| `tile:CUBE:TGEMV_MX` | 20 |
| `tile:CUBE:TGEMV_MX_BIAS` | 21 |
| `tile:CUBE:TGEMV_MX_ACC` | 22 |

Each tuple rejects as `IllegalInstruction` before operand legality checks,
semantic-handler dispatch, destination writes, memory effects, or result-rule
selection. `result_rule_id` is therefore null for all 150 tuples.

The ASL represents this bounded decision with
`NumericApplicabilityRules_A2A3MxRejection`, an accepted negative-rule set,
not with a complete executable A2/A3 profile. `NumericApplicabilityRules_None`
means that no accepted negative rule is being applied; it does not claim that
an operation is supported by A2/A3 or A5. The public PTO-v0 execution entry
points continue to use that `None` rule set and retain their Stage 4
raw-carrier behavior.

The generated `spec/evidence/numeric-profile-applicability-closure.json`
ledger is the machine-readable acceptance package. Its source catalog is
`spec/catalog/numeric-profile-applicability.json`.

## Consequences

- A2/A3 MX support is now fail-closed instead of inferred from the portable
  CUBE operation inventory.
- The six MX selectors remain accepted PTO direct tile operation identities in
  the portable catalog; this ADR only constrains the A2/A3 numeric profile.
- Absence from this bounded rejection catalog is not positive support evidence;
  the remaining A2/A3 and A5 operation/type matrices stay fail-closed review
  obligations.
- No MX numeric result semantics, FP8/FP4 scale behavior, accumulation order,
  rounding, saturation, or exceptional-value rule is accepted here.
- `ADR 0086`, the `cube-matrix` domain, and `S5-T2` remain open until every
  profile applicability and result rule is complete and independently
  verified.
