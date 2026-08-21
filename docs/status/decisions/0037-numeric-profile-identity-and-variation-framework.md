---
{
  "id": "ADR-0037",
  "title": "Numeric profile identity and bounded variation framework",
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
    "PTO-MATRIX-POSTPROCESS-BITEXACT-001",
    "PTO-MATRIX-QUANT-BITEXACT-001",
    "PTO-TCVT-E8M0-PROFILE-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROFILE-APPLICABILITY",
    "PTO-ARCH-PROFILE-E8M0-CONVERSION",
    "PTO-ARCH-PROFILE-MATRIX-POSTPROCESS",
    "PTO-ARCH-PROFILE-MATRIX-QUANTIZATION",
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE",
    "PTO-ARCH-PROFILE-REFERENCE-QUANTIZATION"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0037: Numeric profile identity and bounded variation framework

> Historical-evidence note: verification paths named below record the evidence used when this ADR was accepted; deleted aggregate checks are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Context

`S5-T2` requires target numeric conformance without allowing CPU, A2A3, or A5
implementation behavior to become PTO semantics implicitly. The public PTO
contract permits target profiles to narrow support and identifies numeric
variation points, while also stating that target profiles cannot redefine the
semantics of legal PTO operations.

The active `pto-v0` implementation profile is deterministic raw-carrier
reference behavior. It proves executable totality but is not an IEEE or target
hardware profile. CPU simulation is also an implementation under test, so its
host arithmetic cannot qualify itself as the independent oracle.

The numeric decision register retains 12 questions over 20 domains. Exact
format encodings, rounding modes, subnormal handling, special values, flags,
conversion overflow, elementary-function accuracy, reductions, quantization,
and matrix arithmetic remain unresolved. Identity and selection rules can be
closed without choosing those results.

## Decision

PTO defines four stable numeric configuration identities in
`spec/catalog/numeric-profile-identities.json`:

| Identity | Kind | Normative role |
| --- | --- | --- |
| `pto-numeric-v1` | Portable numeric contract | Defines the future portable result, legality, and rejection rules for accepted numeric operation/type tuples. |
| `pto-cpu-observation-v1` | Observation only | Names reproducible CPU implementation observations; it is neither an architecture profile nor an independent oracle. |
| `pto-a2a3-numeric-v1` | Target numeric profile | Names A2A3 support restrictions and explicitly delegated, bounded target rules. |
| `pto-a5-numeric-v1` | Target numeric profile | Names A5 support restrictions and explicitly delegated, bounded target rules. |

These identities are accepted independently of their still-open rule bodies.
Naming an identity does not claim that an operation/type tuple is supported,
that a numeric result is known, or that conformance has been demonstrated.

The following selection rules are normative:

1. PTO ASL, accepted architecture decisions, and the numeric identity catalog
   define the numeric profile boundary. Backend behavior is evidence only.
2. A target profile may reject an operation/type tuple through a complete,
   versioned support matrix. It may not silently change the portable result of
   an accepted tuple.
3. A portable rule may delegate a result dimension only to a named target
   profile or visible numeric mode with a finite or mathematically testable
   allowed-result contract. Unbounded `implementation-defined` numeric behavior
   is not a closure disposition.
4. Unknown identities, modes, formats, operation/type tuples, and missing
   delegated rules reject before architectural effects.
5. CPU observations are diagnostic evidence from an implementation under test.
   They cannot define a PTO result or serve as the independent S5-T2 oracle.

`pto-v0` remains the active executable raw-carrier reference profile. The new
identities do not alter, inherit, or re-label its arithmetic as target behavior.

## Consequences

The identity and selection-framework sub-stage `S5-T2-A1` is closed: all four
identities have stable spellings, kinds, selection boundaries, and this accepted
decision record. The remaining numeric decisions are not closed.

`ADR 0086` remains open until every domain has a complete portable/target support
and result-rule applicability matrix. `ADR 0095` remains open until every delegated
variation point has an accepted selector and allowed-result contract. The other
ten questions, all 20 domain rules, all six oracle qualifications, vectors,
target captures, differential dispositions, and independent approvals remain
open. The maturity floor therefore remains M4 and `S5-T2` remains open.

Future target profiles must implement the complete profile-hook registry for
their supported surface and provide profile, oracle, vector, result, and review
evidence without changing `pto-v0` silently.

## Evidence

- `spec/catalog/numeric-profile-identities.json`
- `spec/evidence/numeric-profile-decision-inputs.json`
- `spec/evidence/numeric-profile-decision-proposals.json`
- `spec/evidence/numeric-conformance-readiness.json`
- `asl/arch/profile/applicability.asl`
- `asl/arch/profile/reference-profile.asl`
- `asl/arch/profile/reset.asl`
- `scripts/check-catalogs`
