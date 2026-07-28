# ADR-0001: Define PTO as a one-level scalar and tile ISA

- Status: accepted
- Formal-model issue: [#4](https://github.com/PTO-ISA/pto-spec/issues/4)
- Decision date: 2026-07-28

## Context

PTO needs scalar execution and direct tile operations without a nested
instruction-body architecture. A nested model would duplicate architectural
state, complicate precise faults and replay, and contradict the direct PTO
operation contract.

## Decision

PTO has one architectural execution level. Scalar instructions and direct tile
instructions update the same architectural state. Tile registers are explicit
operands, never implicit queue results. Direct instruction entrypoints carry all
dimensions, addresses, sources, destinations, and attributes.

The initial canonical catalogs contain 474 scalar forms and 111 tile operations.
Exact admission, selector allocation, reservation, and semantic coverage are
machine checked.

## Consequences

- Binary encodings preserve PTO selector facts without prescribing command
  queues or pipeline structure.
- Scalar selector values outside R0..R23 are not extra GPRs.
- Tile operands use a separate six-bit register domain.
- The architecture contains no nested body PC, body-local carriers, implicit
  tile queue, group predicate, group loop state, or group replay snapshot.
- New execution levels require a replacement architecture decision, catalog
  revision, ASL state definition, and precise fault/restart model.
