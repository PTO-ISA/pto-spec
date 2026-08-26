---
{
  "id": "ADR-0107",
  "title": "Remove legacy Shared movement Functions",
  "status": "accepted",
  "authors": ["PTO ISA maintainers"],
  "approvers": ["PTO ISA maintainers"],
  "created": "2026-08-26",
  "accepted": "2026-08-26",
  "rejected": null,
  "superseded": null,
  "baseline": "5114fb699fa510abd9a3c42bcfa5c592cd724961",
  "target_releases": ["0.58.4.1"],
  "affected_ndf": ["PTO-ISA-LEGACY-SHARED-MOVEMENT-001"],
  "affected_units": [
    "PTO-BLOCK-BSTART-TMOV",
    "PTO-BLOCK-BSTART-TSTORE",
    "PTO-TILE-TMOV",
    "PTO-TILE-TSTORE",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/159",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0107: Remove legacy Shared movement Functions

## Decision

The independent Shared movement Functions 9, 10, 11, 12, and 14 are removed
from the accepted ISA/TLSU operation set. Their encodings are reserved and
raise `Fault_IllegalInstruction` in the 0.58.4.1 candidate.

Canonical lowering is:

- Shared to GM: `TSTORE` with optional `B.SUBVIEW`.
- Local to Shared: ordinary `TMOV` with optional `B.ASSEMBLE`.
- Shared to Local: ordinary `TMOV` with optional `B.SUBVIEW`.
- Function 13 `GMOV` remains unchanged.

A source-level frontend may retain sugar only when it lowers mechanically to
these canonical forms without quarter selection, defined-mask semantics, or
independent readiness/publication behavior.

## Consequences

Operation identity, decoder witnesses, catalogs, documentation, and AVS
closure must no longer accept the removed variants. The canonical forms share
the parent-level readiness and explicit range rules above.
