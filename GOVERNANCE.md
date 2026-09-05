# Governance

## Authority and ownership

Current architectural meaning is owned once in ASL/NDF. Generated instruction
pages, catalogs, AVS inventories, release evidence, the changelog, and review
summaries are projections or evidence; they cannot create or amend semantics.
Accepted ADRs record reviewed decisions and rationale but do not replace the
current ASL owner. Git history is the archive—active trees do not carry legacy
copies, backups, or alternate contracts.

All architecture changes use stable `PTO-*` clauses and the
[Normative Design Framework](https://github.com/PTO-ISA/normative_language/blob/main/normative_language.md).
The [ADR process](docs/governance/adr-process.md) owns decision states, NDF
responsibilities, and supersession rules.

PTO-SPEC owns only PTO architecture NDF identities. Downstream repositories,
including ASL-Model, own and number their own NDF records. Downstream IDs may
be linked as integration evidence but must not appear as PTO ADR
`affected_ndf`, `affected_units`, or ASL NDF regions.

## Validation policy

The repository has three distinct lanes: lightweight pull-request feedback,
non-authoritative latest-`main` nightly health, and exact-commit release
verification. Only a successful release run for the candidate commit can
support release eligibility. No run creates a tag or publishes a release.

The [validation guide](docs/governance/validation.md) is the canonical operator
description of lane triggers, commands, authority, and failure handling. The
workflows and validation scripts remain the executable contracts.

Compiler-to-model acceptance is owned by
[`PTO-ISA/asl-model`](https://github.com/PTO-ISA/asl-model). PTO-SPEC keeps its
direct ASL semantic AVS, while the ASL-MODEL corpus owns the exact LLVM
compile/link to PTO ELF, ELF identity validation, ASLRef execution, independent
golden comparison, and closure payload. The manual PTO release workflow invokes
that corpus in the same protected run and rejects a missing, stale, partial, or
different-version result.

The first integrated release uses the immutable adoption baseline and mandatory
case set in `spec/model-closure-selection.json`. That baseline is not a waiver:
it marks where the new cross-repository gate becomes authoritative. Every later
instruction-identity change must close its ASL-MODEL mapping before publication.

## Change control

- **Interface definition** changes an externally visible encoding, operand or
  bundle schema, architectural state interface, legality/fault contract,
  ordering/commit boundary, profile contract, or assembly interface. It
  requires an NDF issue, reviewed decision state, owning ASL/NDF change, and
  focused executable evidence. Update the existing topic ADR when one already
  owns that interface; allocate a new ADR only for a genuinely new interface
  decision.
- **Implementation correction** fixes ASL wording, decode, dispatch, helper,
  reference-profile implementation, model-bound leakage, or tests under an
  unchanged interface. Fix the owning ASL/tests directly and preserve the
  issue, commit, and executable evidence; do not allocate an ADR.
- **Toolchain** updates the audited ASLRef pin or build environment and stays
  isolated from architecture behavior.
- **Governance or projection** changes policy, workflow, generation, or
  non-normative explanation without changing ASL meaning.
- **Refactor** preserves accepted semantics and carries regression evidence.

Changes land through signed, linear pull-request history after `PR / validate`
succeeds for the reviewed head and conversations are resolved. `main` rejects
force pushes and deletion according to repository settings. `.github/CODEOWNERS`
routes all paths to the repository owner; repository settings, required checks,
and access remain auditable administrative controls.

### Agent operation and review

Implementers, reviewers, and release operators may all be agents. Review is a
separate execution from implementation; it does not require a human reviewer,
an additional GitHub account, or a queue of domain approvals. One independent
reviewer covers the changed contracts. Escalate only unresolved architecture
decisions or findings that exceed that reviewer's scope.

The implementer supplies an exact base, head, diff identity, focused results,
compatibility impact, and downstream obligations. The reviewer reads the owning
sources and rejection tests, records findings, and approves or requests changes.
Changed input invalidates the review. Preserve the independent execution's
transcript or host record with the PR evidence: a reviewer name or local JSON
receipt proves neither authentication nor independent execution.

`scripts/prepare-pr` prepares the bounded handoff and checks receipt freshness.
It never manufactures an approval or replaces hosted required checks. Agents
using the same GitHub account must preserve the independent review record;
they must not invent another account's approval. GitHub access controls remain
the authorization boundary for merges and publication.

## Compatibility and downstream consumption

`main` is a moving normative draft. A candidate names frozen inputs awaiting
verification. A published release binds an immutable commit and evidence; its
publication status does not imply that every architectural area is complete.
Consumers read the profile, maturity and known gaps in that exact release.

Architecture version, publication revision, encoding ABI and content digests
are distinct identities. In the current four-part version scheme, a publication
revision is not a promise of patch compatibility. An unchanged ABI name or
encoding digest alone does not prove unchanged execution semantics.

Every interface change states `compatible`, `breaking`, or `unspecified` and
names the affected consumer contract. Instruction removal, encoding changes,
new legality restrictions and changed observable behavior require explicit
compatibility review and migration obligations. `unspecified` cannot be
advertised as compatible. Documentation or packaging corrections may claim
compatibility only when the normative contract is unchanged. These declarations
describe change impact; ASL/NDF remains the sole semantic authority.

Production consumers pin the full release tag, commit, manifest digest and
applicable profile. They verify the release evidence before updating that pin.
Development consumers may track a commit but must not treat it as a published
release. Downstream repositories keep their own identities and acceptance cases;
PTO-SPEC links their obligations without copying their normative records.

## Release eligibility

A candidate is eligible only when the complete pinned toolchain and ASL model,
all AVS points, and reproducible evidence succeed for the same immutable commit.
The release manifest binds content and encoding fingerprints. A pending,
skipped, cancelled, failed, stale, or different-commit job never counts as
success, and administrator capability cannot convert missing evidence into a
passing result.

[`spec/release-selection.json`](spec/release-selection.json) owns the exact
release-selection policy. The generated manifest expands its selected ADR and
NDF identities and retains NDF digests so a published contract cannot change
under the same release identity.

Current lifecycle state is derived in
[`spec/evidence/architecture-readiness.json`](spec/evidence/architecture-readiness.json).
Its unit and NDF relationships are linked through
[`spec/evidence/release-traceability-readiness.json`](spec/evidence/release-traceability-readiness.json).
Neither projection overrides ASL/NDF or turns a stale validation event into
current readiness.
