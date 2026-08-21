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

## Lifecycle

1. Open and scope the NDF issue against an immutable baseline.
2. Create or update one ADR with the affected clause and unit identities.
3. Review alternatives, compatibility, release impact, and evidence needs.
4. Accept, reject, or retain the proposal as draft.
5. For an accepted decision, update the owning ASL/NDF and focused AVS points.
6. Regenerate Markdown, catalogs, decoder witnesses, the ADR index, traceability,
   and release evidence affected by that owner.
7. Supersede an old ADR only through reciprocal links to the replacing record.

The generated [changelog](../../CHANGELOG.md) groups accepted decisions by
target release and affected surface. It is a review index and does not establish
release contents or current semantics.
