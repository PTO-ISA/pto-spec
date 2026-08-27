---
{
  "id": "ADR-0099",
  "title": "PTO ISA 0.58.3 to 0.58.4 compatibility boundary",
  "status": "accepted",
  "authors": ["ckwllawliet <641433195@qq.com>"],
  "approvers": ["zhoubot"],
  "created": "2026-08-22",
  "accepted": "2026-08-22",
  "rejected": null,
  "superseded": null,
  "baseline": "23ca8833fef3f97dbc65beef4924b0b4671cdfdf",
  "target_releases": ["0.58.4"],
  "release_boundary": true,
  "affected_ndf": [
    "PTO-B-IOT-STREAM-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-SUBVIEW-RANGE-001",
    "PTO-B-ASSEMBLE-RANGE-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-SUBVIEW",
    "PTO-BLOCK-B-ASSEMBLE",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/123",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0099: PTO ISA 0.58.3 to 0.58.4 compatibility boundary

## Context

Published PTO ISA `0.58.3` is an immutable release identity. The accepted
range-command and PE-level programming-model delta is a new working candidate
and must not mutate the published `0.58.3` manifest, ABI vectors, encoding
evidence, or release provenance. The candidate therefore needs an explicit
compatibility boundary and a distinct release identity.

## Decision

The working candidate advances from architecture version `0.58.3` to
`0.58.4` and uses the repository-convention encoding ABI
`pto-isa-0.58.4-mode-function-v1`. ADR-0097 capacity/M-sharding, ADR-0098
range commands, and the accepted PE-level programming-model delta target
`0.58.4`.

Published `0.58.3` remains immutable: its release manifest, `0.58.3` ABI
vectors, `0.58.3` encoding-totality evidence, release-input registry, and
published encoding ABI are not regenerated or rewritten by this candidate.
The candidate's release selection uses the published `0.58.3` commit as its
baseline and evaluates the accepted candidate NDF set under the new `0.58.4`
identity, so the published-NDF-set blocker does not apply across identities.

This decision assigns release compatibility metadata only. It does not
authorize V2 release validation, manifest regeneration, tagging, publication,
push, or pull-request creation.

## Consequences

- `0.58.3` consumers retain the published instruction and ABI contract.
- `0.58.4` is the only working candidate identity for the range-command and
  PE-level programming-model changes.
- Ordinary PR projections may advance to `0.58.4`; published `0.58.3`
  artifacts remain byte-for-byte unchanged.

## Rejected Alternatives

- Mutating the published `0.58.3` manifest or evidence is rejected because a
  published release identity is immutable.
- Reusing the `0.58.3` architecture version or encoding ABI is rejected because
  it would make the candidate content-addressed identity ambiguous.
