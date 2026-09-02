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
   next available ADR number only when no existing record owns the interface.
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
