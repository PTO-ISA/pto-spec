# ADR-0001: Define PTO as a scalar, bundle/command, and tile ISA

- Status: accepted
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

The canonical catalogs contain 474 scalar forms, 107 bundle/command forms, and
120 direct tile operations. Exact admission, selector allocation, reservation,
and semantic coverage are machine checked.

## Consequences

- Binary encodings preserve PTO selector facts without prescribing physical
  queues or pipeline structure.
- Scalar selector values outside R0..R23 are not extra GPRs.
- Tile operands use a separate six-bit register domain.
- Vector instruction execution is outside the PTO ISA. Vector-only forms require
  a new architecture decision, catalog revision, ASL state definition, and
  precise fault/restart model before they can be accepted.
