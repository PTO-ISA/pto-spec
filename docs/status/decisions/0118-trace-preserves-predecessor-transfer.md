---
{
  "id": "ADR-0118",
  "title": "B.HINT TRACE preserves the predecessor-selected transfer",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-09-01",
  "accepted": "2026-09-01",
  "rejected": null,
  "superseded": null,
  "baseline": "6df97a3cf31aa83b2c90a8664c2ccb15ef74c8d9",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-B-HINT-LIFECYCLE-001",
    "PTO-INST-BLOCK-B-HINT"
  ],
  "affected_units": [
    "PTO-BLOCK-B-HINT",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/195",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0118: B.HINT TRACE preserves the predecessor-selected transfer

## Context

`B.HINT TRACE` is a special block-start operation. It may be fetched at the
sequential boundary of an active predecessor, but committing that predecessor
may select a different direct, conditional, indirect, call, or return target.

The existing dispatch always opened the fetched trace block after predecessor
commit. That replaced a non-sequential selected TPC and made a taken loop exit
after its first iteration when `TRACE.end` occupied the sequential path.

## Decision

`B.HINT TRACE` first performs the existing predecessor commit. After a
successful commit, it opens and records the trace block only when the committed
TPC equals the fetched TRACE instruction PC.

If the addresses differ, the predecessor selected another continuation. The
retired predecessor and its TPC remain committed; the TRACE block is not
opened, and trace payload, epoch, and hint state are not changed. A failed
predecessor commit retains the old state and prevents TRACE installation as
before.

## Compatibility

- The B.HINT encodings, field meanings, trace boundary kinds, and empty-block
  representation do not change.
- Fallthrough and untaken conditional predecessors continue opening a TRACE
  block at the selected sequential boundary.
- Taken predecessors no longer lose their selected continuation to TRACE on an
  unselected path.
- Functional tracing transport and host reporting remain non-architectural.

## Verification obligations

- Taken conditional, direct, and return predecessors skip sequential TRACE.
- Fallthrough and untaken conditional predecessors open TRACE normally.
- Skipped TRACE leaves payload, epoch, and hint state unchanged.
- Failed predecessor commit retains rollback behavior.
- A compiler-shaped conditional loop containing TRACE.end repeats and reaches
  its independent expected result.

## Decision state

The architecture owner authorized autonomous detailed analysis and the
recommended architecture rule on 2026-09-01. Focused taken, sequential, and
compiler-shaped loop evidence binds the rule to the owning ASL.
