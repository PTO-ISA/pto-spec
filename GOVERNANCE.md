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

Executable functional-model lifecycle and hosted-ABI contracts are not NDF
architecture. They use `PTO-MODEL-CONTRACT` regions with an explicit `model`
or `abi` layer and are validated by `scripts/check-model-contracts`. Such a
contract may invoke an owning PTO ASL/NDF transition, but it cannot satisfy an
architectural NDF obligation, add PTO state, or change instruction semantics.
ADRs list these separately in `affected_model_contracts`.

## Validation policy

The repository has three distinct lanes: lightweight pull-request feedback,
non-authoritative latest-`main` nightly health, and exact-commit release
verification. Only a successful release run for the candidate commit can
support release eligibility. No run creates a tag or publishes a release.

The [validation guide](docs/governance/validation.md) is the canonical human
description of lane triggers, commands, authority, and failure handling. The
workflows and validation scripts remain the executable contracts.

## Change control

- **Normative architecture** changes state, legality, results, ordering,
  faults, profiles, encodings, or assembly. It requires an NDF issue, reviewed
  decision state, owning ASL/NDF change, and focused executable evidence.
- **Toolchain** updates the audited ASLRef pin or build environment and stays
  isolated from architecture behavior.
- **Functional-model or hosted ABI** changes model lifecycle, observation,
  checkpoint, consumer, or process conventions without changing PTO
  architecture. It uses a model-contract owner and independent ABI/runtime
  evidence; any required PTO semantic change remains a separate NDF change.
- **Governance or projection** changes policy, workflow, generation, or
  non-normative explanation without changing ASL meaning.
- **Refactor** preserves accepted semantics and carries regression evidence.

Changes land through signed, linear pull-request history after `PR / validate`
succeeds for the reviewed head and conversations are resolved. `main` rejects
force pushes and deletion according to repository settings. `.github/CODEOWNERS`
routes all paths to the repository owner; repository settings, required checks,
and access remain auditable administrative controls.

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
