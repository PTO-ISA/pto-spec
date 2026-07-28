# ADR-0004: Catalog-owned family constraints

- Status: Accepted
- Date: 2026-07-28
- Requirement: PTO-REQ-SCALAR-CONSTRAINT-001

## Context

Instruction-mask recognition alone cannot resolve operand combinations that
would assign multiple architectural meanings to the same encoded selector.
The original scalar catalog could exclude only one literal value from one
field. That was sufficient for three encoding aliases, but could not express a
relation shared by an instruction family.

Other instruction sets demonstrate why load/store writeback overlap must be
addressed explicitly, but their constrained or implementation-selected outcomes
are not PTO semantics. PTO needs a public, PTO-owned decision that can be
generated and tested uniformly.

## Decision

Scalar catalog schema version 2 separates form-local constraints from shared
family constraints. A family constraint has a stable ID, an applicability
selector, a typed operator, operand fields, and a normative rule statement.
Applicability is determined only from catalog metadata: semantic family,
semantic handler, and required fields.

The first relational operator is `fields-not-equal`. PTO applies it to:

- AGU forms with `RegDst0` and `RegDst1`, so two encoded results never target
  the same selector; and
- AGU address-updating stores with `RegDst` and `SrcD`, so the returned updated
  address never overlaps the encoded stored-data selector.

These rules compare encoded selector values. They do not infer hidden physical
aliasing between different Reg5 source and destination roles. A violation is an
illegal instruction and is rejected before any register, memory, ordering, or
writeback effect.

## Consequences

- One catalog rule covers every matching current and future form.
- CI checks the exact application set and requires positive and negative
  execution witnesses.
- Decoder generation, not handwritten dispatch code, owns enforcement.
- Adding an operator or changing an application set requires a schema-versioned
  catalog change and executable evidence.
