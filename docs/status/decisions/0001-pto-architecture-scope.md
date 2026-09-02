---
{
  "id": "ADR-0001",
  "title": "Define PTO as a scalar, bundle/command, and tile ISA",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "Codex"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "zhoubot"
  ],
  "created": "2026-07-28",
  "accepted": "2026-07-28",
  "rejected": null,
  "superseded": null,
  "baseline": "007844f182ca87c843ebf274d7c9509188e68e01",
  "target_releases": [
    "unassigned",
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001",
    "PTO-ARCH-CONDITIONAL-BRANCH-RESERVATION-001",
    "PTO-ARCH-ENCODING-OWNERSHIP-001",
    "PTO-ARCH-STATE-CLOSURE-001",
    "PTO-ARCH-TEPL-ALIAS-001",
    "PTO-ARCH-TILE-EXECUTION-ENGINE-001",
    "PTO-ARCH-TILE-INSTRUCTION-CLASS-001",
    "PTO-RELEASE-VERIFICATION",
    "PTO-SOURCE-HIERARCHY",
    "PTO-TILE-CAPACITY-PER-PE",
    "PTO-REQ-INSTRUCTION-DISPATCH-001",
    "PTO-REQ-INSTRUCTION-FETCH-001",
    "PTO-REQ-PHYSICAL-MEMORY-BINDING-001"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ARCHITECTURE",
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION",
    "PTO-ARCH-DISPATCH-TOP-LEVEL",
    "PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE",
    "PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH",
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/4",
  "release_impact": "required",
  "legacy_ids": [],
  "amendments": [
    {
      "date": "2026-08-31",
      "baseline": "e9b621ddce041ff2c770bef67adc41946db87295",
      "approvers": [
        "zhoubot"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/179",
      "affected_ndf": [
        "PTO-REQ-INSTRUCTION-DISPATCH-001",
        "PTO-REQ-INSTRUCTION-FETCH-001",
        "PTO-REQ-PHYSICAL-MEMORY-BINDING-001"
      ],
      "affected_units": [
        "PTO-ARCH-DISPATCH-TOP-LEVEL",
        "PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE",
        "PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH",
        "PTO-ARCH-PROFILE-REFERENCE-PROFILE"
      ]
    }
  ]
}
---
# ADR-0001: Define PTO as a scalar, bundle/command, and tile ISA

> Inventory counts in this record are acceptance-time historical context; the current inventory is owned by the ASL tree and its generated projections.

- Formal-model issue: [#4](https://github.com/PTO-ISA/pto-spec/issues/4)
- Decision date: 2026-07-28

## Context

PTO needs scalar execution, visible bundle/command state, and direct tile
operations in one coherent architectural state. The ISA must define exact
instruction encodings and state transitions without depending on backend
pipelines, hidden command streams, or implementation scheduling.

## Decision

Scalar instructions, bundle/command forms, and direct tile instructions update
the same architecture-visible state. Bundle state is explicit through TPC, BPC,
active/body flags, arguments, dimensions, IO bindings, and attributes. Tile
registers are explicit operands.

The canonical catalogs contain 466 Scalar forms, 94 active Block forms, 126
direct Tile operations, and 46 occupied extension reservations. Exact
admission, selector allocation, reservation, and semantic coverage are machine
checked.

## Consequences

- Binary encodings preserve PTO selector facts without prescribing physical
  queues or pipeline structure.
- Scalar selector values outside R0..R23 are not extra GPRs.
- Tile operands use a separate six-bit register domain.
- Vector instruction execution is outside the PTO ISA. Vector-only forms require
  a new architecture decision, catalog revision, ASL state definition, and
  precise fault/restart model before they can be accepted.

## Executable-specification boundary update

PTO-SPEC owns the architecture-visible instruction fetch, length selection,
decode dispatch, translation, access preflight, precise faults, and physical
memory profile hooks used by its executable ASL. A consumer must invoke those
owners rather than privately redefining them.

ELF loading, model instances, run manifests, stop policy, snapshots, worker
lifecycle, host storage, and C/C++ APIs are downstream model interfaces. The
ASL-Model repository owns their NDF identifiers and lifecycle. PTO-SPEC may
link to those downstream records as non-normative integration evidence, but it
must not mint, mirror, or carry ASL-Model NDF identifiers in PTO ADR metadata.

This boundary was closed through issues
[#179](https://github.com/PTO-ISA/pto-spec/issues/179) and
[#185](https://github.com/PTO-ISA/pto-spec/issues/185). The PTO-owned ASL
actions remain normative here; downstream initialization and execution policy
remain outside the PTO ISA.
