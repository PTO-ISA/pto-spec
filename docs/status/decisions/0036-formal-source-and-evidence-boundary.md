---
{
  "id": "ADR-0036",
  "title": "Formal source and evidence boundary",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-15",
  "accepted": "2026-08-15",
  "rejected": null,
  "superseded": null,
  "baseline": "4d115387b8a8a3c135f78189778d38547e75c697",
  "target_releases": [
    "0.58.1"
  ],
  "affected_ndf": [
    "PTO-SOURCE-HIERARCHY"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ARCHITECTURE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0036: Formal source and evidence boundary

## Context

Architecture meaning must not be reconstructed from generated artifacts,
tool behavior, maturity ledgers, or documentation prose. Those artifacts can
detect drift, but they cannot fill an absent ASL rule.

## Decision

- The four-surface PTO ASL tree is the only authored architecture source.
- Every accepted instruction, rejected form, field domain, default, state
  effect, memory effect, ordering rule, fault, and reservation has one ASL
  owner.
- Catalogs, generated pages, navigation, AVS points, evidence ledgers, and
  release manifests are derived artifacts or checks.
- A derived artifact that disagrees with ASL is stale or defective and must
  fail closed. It never changes the architecture definition.
- An ASL gap remains incomplete or ambiguous until a PTO architecture decision
  resolves it and updates the owning ASL unit first.
- Formal review records contain only review method, outcome, and covered formal
  subjects. They contain no repository, path, page, branch, commit, or blob
  provenance.

## Consequences

PTO release closure proves that the projections agree with the authored ASL;
it does not promote any projection into a second source. Architecture review
therefore remains mnemonic-local, reproducible from this repository, and
independent of the availability or behavior of another implementation.
