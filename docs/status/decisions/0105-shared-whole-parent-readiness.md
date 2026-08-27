---
{
  "id": "ADR-0105",
  "title": "Shared whole-parent readiness and single-issuer publication",
  "status": "accepted",
  "authors": ["PTO ISA maintainers"],
  "approvers": ["PTO ISA maintainers"],
  "created": "2026-08-26",
  "accepted": "2026-08-26",
  "rejected": null,
  "superseded": null,
  "baseline": "5114fb699fa510abd9a3c42bcfa5c592cd724961",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-B-SHARED-WHOLE-PARENT-READY-001",
    "PTO-B-ASSEMBLE-SHARED-GENERATION-001"
  ],
  "affected_units": [
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX",
    "PTO-TILE-MODEL-STATE-SHARED-REGISTERS",
    "PTO-TILE-MODEL-STATE-TYPES",
    "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/159",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0105: Shared whole-parent readiness and single-issuer publication

## Context

Shared producer participation is not the same thing as Shared parent coverage or
consumer visibility. A producer mask such as `0001` can describe one PE that
writes a complete Shared parent, while a later consumer may use a different
mask. The previous model conflated fixed-quarter initialization with readiness.

## Decision

`B.IOS` without `B.ASSEMBLE` is legal only for one participating issuer PE. That
issuer writes and publishes the complete logical Shared parent; `PE_MASK` never
creates implicit quarters or offsets. A multi-PE producer must use `B.ASSEMBLE`
with explicit per-PE offsets, non-overlap checks, complete coverage, and an
atomic `LAST` publication.

Shared generation state records producer participation/metadata, logical
coverage, parent-level `whole_parent_ready`, and consumer-visible `published`
separately. Readiness is hardware-maintained. A pending or incomplete
assembled generation does not replace the prior published generation and is
not readable by a Shared consumer. Every Shared consumer waits/no-ops before
payload access until both `whole_parent_ready` and `published` are true.

No READY instruction or READY encoding field is added.

## Consequences

- A producer mask is independent of a consumer mask.
- A one-PE full writer can publish a 32 KiB or larger Shared parent without
  requiring all four PE bits.
- Undefined Shared words are not a legal pending-source path for TSTORE, TMOV,
  or Shared-input TMATMUL.

## Verification

Focused AVS points cover single-PE whole-parent publication, sparse producer
masks, atomic assembled `LAST`, incomplete-generation waiting, and preservation
of the prior published generation.
