# Governance

## Repository status

`specification.toml` is the machine-readable status record. The repository is a
normative draft: accepted definitions are normative, while coverage grades in
`docs/coverage.md` identify incomplete families without overclaiming completion.

## Change classes

- **Repository maintenance** changes tooling, policies, contribution forms, or non-normative documentation.
- **Toolchain changes** update the audited ASLRef commit or its build environment and remain isolated from PTO semantics.
- **Normative changes** define architecture-visible types, state, legality, results, ordering, faults, or profiles.
- **Refactors** preserve accepted semantics and require regression evidence.

Normative changes require a linked formal-model issue, stable requirement traceability, semantic tests, and review by
both a PTO architecture owner and a formal-model reviewer. Missing requirements are resolved as architecture decisions,
not guessed in ASL.

Catalog changes must preserve all three review layers: the machine-readable
form or selector, its generated executable decoder witness, and an ASL semantic
handler with feature evidence. A green catalog count without those layers is
not sufficient.

## Review and merge

- Changes land through pull requests after required checks pass.
- At least one approving review is required; normative changes require the two review perspectives above.
- Stale approvals are dismissed after substantive changes.
- The default branch uses linear history and disallows force pushes and deletion.
- Squash merge is the default so each accepted change has one auditable decision record.

## Toolchain updates

`.aslref-version` pins a full commit from `https://github.com/herd/herdtools7.git`. An update must compare upstream
parser, typing, interpreter, standard-library, and conformance-test changes; pass the full repository gate; and remain
separate from normative PTO behavior changes.

## Specification maturity

Maturity transitions require a reviewed change that updates the source hierarchy,
license/notice when needed, requirement IDs, executable tests, coverage report,
and status record together. `architecturally-complete` is permitted only when
every accepted form has total semantics and feature-level evidence.
