# PTO ADR allocation and classification

Use this reference before creating, renaming, superseding, or amending an ADR.

## Allocation test

Search `spec/evidence/adr-index.json` by affected NDF clause and ASL unit first.

Do not add an ADR for:

- an ASL bug fix or readability refactor;
- an NDF wording or ownership correction under an already decided contract;
- missing or repaired AVS coverage;
- generated Markdown, catalog, decoder, traceability, or evidence refreshes;
- documentation clarification that does not change the public interface; or
- an implementation correction under an existing encoding, operand/schema,
  state, legality/fault, ordering/commit, numeric, assembly, or compatibility
  decision.

Update the owning ASL/NDF/tests and regenerate projections. Amend the existing
topic ADR only when its rationale or affected-owner inventory must record the
accepted correction. Never create a parallel ADR for the same interface.

Add a new ADR only when all of these are true:

1. Review introduces a genuinely new externally visible PTO interface or
   decision boundary.
2. No current ADR owns that interface.
3. The choice needs durable rationale, alternatives, compatibility impact, and
   named NDF/ASL owners.
4. A linked architecture issue supplies the immutable baseline and decision
   scope.

Set `interface_change=true` before implementation.

## Classification

Name the file `docs/status/decisions/ADR-TYPE-NNNN-slug.md`, allocating the next
serial in the primary type.

| Type | Primary decision boundary |
| --- | --- |
| `GOV` | architecture scope, normative ownership, catalog governance, compatibility |
| `STATE` | architectural state, system registers, traps, interrupts, visible control |
| `MEM` | memory model, addressing, atomics, TLSU memory effects, restart |
| `BLOCK` | Block lifecycle, attributes, bindings, commit, extension reservations |
| `SCALAR` | Scalar instruction-family semantics and legality |
| `TILE` | general Tile/VEC/SFU operations, conversion, reduction, generation |
| `CUBE` | CUBE/matrix/CELL layout, Shared matrix state, cooperative execution |
| `NUM` | formats, rounding, flags, special values, accuracy, numeric variation |

For a cross-cutting decision, choose one primary type and list every secondary
surface in `affected_ndf` and `affected_units`; never mint duplicate ADRs.

## Examples

- Fixing an AGU address helper to match an accepted memory contract: update
  ASL, NDF if needed, and tests; do not add an ADR.
- Correcting a generated instruction page: fix the ASL owner or generator; do
  not add an ADR.
- Introducing a new architectural register visible to software with no current
  owner: allocate the next `ADR-STATE-NNNN` after architecture review.
- Introducing a new matrix cooperation contract: use `ADR-CUBE-NNNN`, with
  numeric or Block impacts listed as affected owners rather than extra ADRs.
