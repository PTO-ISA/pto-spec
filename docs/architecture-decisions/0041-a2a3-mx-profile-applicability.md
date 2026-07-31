# ADR 0041: A2/A3 MX CUBE profile applicability

## Status

Accepted for a bounded negative applicability checkpoint. Parent `PD-01`,
`cube-matrix`, and `S5-T2` remain open.

## Context

`S5-T2-A` separates profile applicability from numeric result semantics. The
accepted profile identities from ADR 0037 allow target profiles such as
`pto-a2a3-numeric-v1`, but a profile identity does not imply that every
operation/type tuple is supported by that target.

Public target and portability documents require target-specific support
restrictions to be explicit. Pinned A2/A3 matrix evidence does not expose MX
CUBE support, while pinned A5 and public intrinsic evidence expose the MX
operation names. The independent executable-model comparison corroborates the
six MX CUBE selector identities structurally, but those rows are header/decode
evidence only and are not an oracle for tile payload arithmetic.

A broad public statement that a target supports the PTO tile family could be
read as covering these operations. This decision resolves that ambiguity in
favor of the more specific public evidence: the MX overloads are guarded for
A5/CPU exposure, the A2/A3 matrix has no MX surface, and the A5 matrix does.
This is a support-boundary decision only; no backend implementation behavior is
imported as PTO arithmetic semantics.

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
- `PD-01`, the `cube-matrix` domain, and `S5-T2` remain open until every
  profile applicability and result rule is complete and independently
  verified.
