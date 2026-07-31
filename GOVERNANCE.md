# Governance

## Repository status

`specification.toml` is the machine-readable status record. The repository is a
normative draft: accepted definitions are normative, while coverage grades in
`docs/coverage.md` identify incomplete families without overclaiming completion.

## Enforcement map

A governance rule is only real if its enforcement point is visible. This map
distinguishes clone-verifiable checks, GitHub settings, and human review.

| Rule | Enforced by |
| --- | --- |
| The pinned ASLRef accepts valid and rejects invalid ASL1 | `scripts/check-toolchain` (`make toolchain-check`) |
| `.aslref-version` holds one full commit SHA | `scripts/check-repository` |
| `status` and `normative` describe one maturity state | `scripts/check-repository` |
| Every checked-in ASL source reaches the type checker | `scripts/check-repository` |
| Every supported maturity has executable tests | `scripts/check-repository` |
| Catalogs, decoder reachability, profile hooks, feature evidence, and public-source dispositions agree | `scripts/check-catalogs` |
| Prohibited source identities, stale URLs, and broken local documentation links stay unpublished | `scripts/check-publication-hygiene` |
| Generated artifacts stay untracked and scripts are syntactically valid | `scripts/check-repository` |
| The S6-T2 gate inventory, workflow pins, parallel topology, external controls, and empty-before-candidate evidence slots remain exact | `scripts/generate-release-gate-readiness` and `scripts/check-catalogs` |
| Review routing for normative, toolchain, and governance paths | `.github/CODEOWNERS` |
| Admin-only updates, required `validate`, signed commits, linear history, resolved conversations, no force push or deletion | GitHub branch protection on `main` |
| Change-class isolation, requirement traceability, architecture decisions, and two-perspective normative review | Human review against `docs/review-checklist.md` |

The final three rows are not fully verifiable from a clone. CODEOWNERS routes
review but does not replace branch protection, and the repository intentionally
allows an administrator to self-merge after the required validation check. Reconfirm
the CODEOWNERS identities and branch settings whenever repository ownership or
merge policy changes.

## Change classes

- **Repository maintenance** changes tooling, policies, contribution forms, or non-normative documentation.
- **Toolchain changes** update the audited ASLRef pin or its build environment and remain isolated from PTO semantics.
- **Normative changes** define architecture-visible types, state, legality, results, ordering, faults, or profiles.
- **Refactors** preserve accepted semantics and require regression evidence.

Normative changes require a linked formal-model issue, stable requirement
traceability, semantic tests, and review from both a PTO architecture and a
formal-model perspective. Missing requirements are resolved as architecture
decisions, not guessed in ASL.

Catalog changes must preserve all five review layers: the machine-readable form
or selector, generated executable decoder witness, reachable ASL semantic
primitive, decoded operand-to-effect binding, and executable feature evidence.
A green catalog count without those layers is not sufficient.

## Review and merge

- Changes land through pull requests after the required `validate` check passes.
- Only repository administrators may update and merge `main`; administrators may self-merge without an external approval.
- CODEOWNERS routes relevant changes to both current administrators for visibility and review.
- The default branch requires signed commits and linear history and disallows force pushes and deletion.
- Conversations must be resolved before merge.
- Squash merge is preferred so each accepted change has one auditable decision record.

## Toolchain updates

`.aslref-version` pins a full commit from
`https://github.com/herd/herdtools7.git`. An update must compare upstream
parser, typing, interpreter, standard-library, and conformance-test changes;
pass the complete gate; update affected canaries; and remain separate from
normative PTO behavior changes.

## Specification maturity

Maturity transitions require a reviewed change that updates the source
hierarchy, license and notice when needed, requirement IDs, executable tests,
coverage report, and status record together. `architecturally-complete` is
permitted only when every accepted form has total semantics and feature-level
evidence.

`scripts/check-repository` enforces the mechanical part of that transition:
every supported status requires `normative = true` and a non-empty `ASL_TESTS`.
The remaining conditions are review obligations.

### Architecturally-complete candidate evidence

`spec/evidence/release-gate-readiness.json` separates clone-verifiable policy
from release-candidate evidence. Its gate contract and parallel topology may
close while the repository remains a draft, but the candidate fields must stay
empty until all Stage 0–5 targets and S6-T1 close.

At candidate freeze, one signed commit must receive:

- clean-tree results for every listed local gate, including the complete
  parallel runtime suite;
- a passing hosted `validate` result for the same commit;
- a timestamped GitHub API snapshot proving all listed branch and repository
  controls; and
- accepted PTO architecture and formal-model dispositions naming that commit.

No earlier branch run, unpinned approval, or administrator merge capability can
substitute for those candidate-specific records.
