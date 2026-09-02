# ADR and NDF process

This page owns the human workflow for architecture decisions. It does not own
ISA semantics; current meaning remains in the affected ASL/NDF clauses.

## Decision states

| State | Meaning | Required metadata |
| --- | --- | --- |
| `draft` | A proposal under review; it cannot authorize implementation | author, baseline, target release, affected surfaces, issue |
| `accepted` | The decision is approved and may be implemented in its named owners | acceptance date, approver, affected NDF clauses and ASL units |
| `rejected` | The proposal will not be implemented | rejection date and retained rationale |
| `superseded` | A later accepted ADR replaces the decision | supersession date and reciprocal replacement links |

The machine-readable [ADR index](../../spec/evidence/adr-index.json) is generated
from JSON frontmatter in `docs/status/decisions/`. The index is navigation, not
architecture authority. Current records remain in the
[decision directory](../status/decisions/); unresolved choices remain in the
[open-question index](../status/open/index.md).

## Typed decision identities

ADR identities use `ADR-TYPE-NNNN`. `NNNN` is allocated independently within
one canonical decision type rather than from one repository-wide sequence.
The canonical filename is `ADR-TYPE-NNNN-slug.md`.

| Type | Decision area |
| --- | --- |
| `GOV` | architecture scope, normative ownership, catalog governance, and compatibility |
| `STATE` | architectural state, system registers, traps, interrupts, and commit-visible control |
| `MEM` | memory model, addressing, atomics, TLSU memory behavior, and restart |
| `BLOCK` | Block lifecycle, command attributes, operand binding, and extension reservations |
| `SCALAR` | Scalar instruction semantics and family-wide legality closure |
| `TILE` | general Tile, VEC, SFU, conversion, reduction, and data-operation closure |
| `CUBE` | CUBE, matrix, CELL layout, cooperative execution, and Shared matrix behavior |
| `NUM` | numeric formats, rounding, flags, exceptional values, accuracy, and variation |

Allocate the next serial in the owning type. If a decision crosses several
areas, choose the first architecture owner whose public contract is changed;
record other affected surfaces through `affected_ndf` and `affected_units`
rather than minting multiple ADR identities.

The pre-migration `ADR-NNNN` identity remains in `legacy_ids` and resolves
through `legacy_adr_map` in the generated index. Historical ASL or AVS evidence
may retain that alias so an identifier-only migration does not change normative
source digests.

## Bilingual decision records

Every active ADR carries an English `title`, a Chinese `title_zh`, and one
`Bilingual decision detail / 双语决策详述` section. The supplement explains, in
both languages, why the decision was needed, the detailed choice, what changed,
and the explicit scope boundary. It records reviewed rationale and impact; it
does not replace the owning ASL/NDF semantics.

New and amended ADRs start from `0000-template.md` and pass:

```bash
scripts/check-adrs
scripts/check-adr-bilingual
```

Explicit NDF clauses have non-normative bilingual supplements under
`docs/ndf/supplements/`. Each supplement is keyed by the stable NDF ID and exact
owning ASL path. The website may display the localized title and summary, but
the NDF body inside the owning ASL remains authoritative. Validate complete
coverage with `scripts/check-ndf-supplements`. Synthetic `PTO-INST-*`
instruction-contract identities use the owning instruction's existing
bilingual reference projection instead of duplicating that explanation in the
NDF supplement catalog.

## NDF ownership

An architecture issue names the full baseline commit, changed stable `PTO-*`
clause IDs, defaults, intentionally unspecified behavior, compatibility,
release impact, evidence, and open questions. Each clause lives inside one ASL
owner. The accepted ADR records why the choice was made; implementation updates
that ASL/NDF owner and all derived surfaces.

Missing preconditions, faults, profiles, or ordering are decision gaps. Record
the gap as an open question rather than inferring behavior from a catalog,
generated page, backend, or historical record.

PTO-SPEC owns only PTO architecture NDF identities. ASL-Model and every other
downstream repository own and number their own NDF records. Downstream records
may be cited by URL as integration evidence, but their identifiers must not be
minted, mirrored, or placed in PTO ADR metadata or PTO ASL NDF regions.

## ADR allocation threshold

Allocate a new PTO ADR only when review accepts a genuinely new externally
visible PTO interface definition. Interface includes instruction encodings and
forms, operands and bundle schemas, architectural state exposed to software,
legality and fault contracts, ordering and commit boundaries, profile
interfaces, and assembly contracts.

Do not allocate an ADR for an implementation correction under an existing
interface. This includes incorrect ASL wording, decode or dispatch mappings,
handler bugs, reference-profile algorithms, model bounds accidentally exposed
as ISA limits, generated projections, and tests that captured the wrong
behavior. Fix the owning ASL/tests directly and preserve the governing issue,
commit, and executable evidence.

When an existing ADR already owns the changed interface, amend that ADR rather
than creating a parallel record. If a temporary new ADR was created but no
downstream consumer has adopted its number, collapse its durable rationale and
affected-owner metadata into the existing ADR, remove the temporary record,
and regenerate the index, changelog, readiness, traceability, and manifest.

## Lifecycle

1. Open and scope the NDF issue against an immutable baseline.
2. Classify the work as an interface definition or an implementation
   correction.
3. For an interface definition, update the existing topic ADR or allocate the
   next serial in the owning ADR type only when no existing record owns the
   interface.
4. Review alternatives, compatibility, release impact, and evidence needs.
5. Accept, reject, or retain the proposal as draft.
6. Update the owning ASL/NDF and focused AVS points. An implementation
   correction proceeds directly through this step without a new ADR.
7. Regenerate Markdown, catalogs, decoder witnesses, the ADR index, traceability,
   and release evidence affected by that owner.
8. Supersede an old ADR only through reciprocal links to the replacing record.

The generated [changelog](../../CHANGELOG.md) groups accepted decisions by
target release and affected surface. It is a review index and does not establish
release contents or current semantics.
