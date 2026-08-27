---
{
  "id": "ADR-0102",
  "title": "PTO ISA 0.58.4.1 publication-contract correction boundary",
  "status": "accepted",
  "authors": [
    "Codex"
  ],
  "approvers": [
    "zhoubot"
  ],
  "created": "2026-08-26",
  "accepted": "2026-08-26",
  "rejected": null,
  "superseded": null,
  "baseline": "2052214b8e4b046aa77f68dc0ba8ca23447ae00d",
  "target_releases": [
    "0.58.4.1"
  ],
  "release_boundary": true,
  "affected_ndf": [
    "PTO-FCVTA-DECISION-BINDING-001",
    "PTO-MGATHER-BYTE-DISPLACEMENT-001",
    "PTO-SETRET-ADR-CONTRACT-001",
    "PTO-TSEL-CONTRACT-001",
    "PTO-TSORT-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-SCALAR-FCVTA",
    "PTO-SCALAR-SETRET",
    "PTO-TILE-MGATHER",
    "PTO-TILE-TSEL",
    "PTO-TILE-TSORT"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/18",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0102: PTO ISA 0.58.4.1 publication-contract correction boundary

## Context

Bilingual reader-guide review found contradictions inside several structured
`PTO-INSTRUCTION` contracts. Executable ASL handlers and discriminating AVS
already agreed on the behavior, but generated contract prose named a wrong base
operand, an absent field, a stale DataType set, or an imprecise operation label.
Because synthetic instruction-contract NDF clauses include that metadata,
correcting the owner text changes their content digests even though execution
does not change.

Published architecture version `0.58.4` and its encoding ABI remain the current
architectural identity. Reusing the exact published artifact identity for
changed documentation contracts would make release provenance ambiguous.

## Decision

The corrected documentation and evidence use publication revision `0.58.4.1`
while retaining architecture version `0.58.4` and encoding ABI
`pto-isa-0.58.4-mode-function-v1`. Release selection records both identities
and freezes NDF digests by publication revision.

Accepted corrections are limited to statements already determined by the
current executable owner and AVS:

- no-operand system forms no longer describe a nonexistent encoded-zero operand;
- AGU contracts name the executable `SrcR` base, fixed scaling, and aligned TPC;
- `SETRET` and `FCVTA` terminology matches the selected immediate and rounding mode;
- Tile instruction DataType and definedness contracts match active helpers.

No opcode, mask/match, operand encoding, semantic handler, state transition,
fault selection, ordering rule, profile algorithm, or ABI changes in this
publication revision. Current meaning remains in the affected ASL/NDF owners;
this ADR records only the compatibility and publication boundary.

## Compatibility

Software and implementations conforming to architecture `0.58.4` observe no
behavioral delta. The corrected artifacts no longer contradict the already
executable contract. Consumers that content-address documentation or NDF
projections select publication `0.58.4.1`; consumers selecting architectural
behavior continue to select architecture `0.58.4`.

## Verification

Focused AVS covers every corrected contract family. The complete ASL inventory,
generated contracts, catalogs, bilingual projections, release traceability, and
site gates are rerun at the publication commit.

## Release impact

A distinct publication revision and regenerated content-addressed evidence are
required. This decision does not itself authorize tagging, GitHub Release
publication, Pages deployment, or mutation of a previously published artifact.
