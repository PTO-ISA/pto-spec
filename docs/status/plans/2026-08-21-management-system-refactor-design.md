# PTO Specification Management System Refactor

- Status: approved governance design
- Baseline: `1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f`
- Change class: repository governance and projection
- Normative ISA impact: none
- Target: preserve an evolving `main` while making release closure efficient,
  auditable, and understandable

## Summary

PTO needs a management system that permits architecture and ASL work to evolve
on `main` without claiming that every merge is semantically validated or ready
for release. The repository already has the correct high-level split: ASL owns
the current normative contract, pull requests run a lightweight structural
lane, and release verification runs the complete model against one exact
commit.

This refactor completes that design. It makes ADRs the only human-authored
architecture-evolution records, removes the parallel PRD and PD decision
namespaces, derives open questions and readiness from checked inputs, reduces
the pull-request critical path to a ten-minute P95 budget, adds non-authoritative
nightly full validation, and reorganizes the repository around a concise
professional contributor experience.

The refactor does not change PTO instruction behavior. Every migration step
must prove that the active ASL, generated catalogs, decoded instruction surface,
and release identity remain unchanged unless a separately approved normative
ADR explicitly changes them.

## Goals

- Keep ASL and its NDF clauses as the only current normative semantic source.
- Make ADRs the only human-authored record of architecture evolution.
- Eliminate active PRD, PDR, and PD decision namespaces.
- Permit accepted decisions, incomplete ASL implementation, and incomplete
  validation to coexist visibly on `main`.
- Compute implementation and release readiness from repository facts rather
  than hand-written status strings.
- Keep the required pull-request lane at or below ten minutes at P95.
- Run complete validation after merge without giving that run release authority.
- Preserve exact-commit, clean, fail-closed release verification.
- Make the repository easy to navigate for architecture reviewers, formal-model
  implementers, toolchain consumers, and new contributors.
- Reduce duplicated policy prose, generated-state drift, and review noise.
- Make `zhoubot` the sole repository CODEOWNER while keeping review evidence
  and branch protection explicit.

## Non-goals

- This refactor does not define or change instruction semantics.
- It does not make ADR prose a second executable specification.
- It does not introduce an external database or hosted project-management
  service as an authority.
- It does not make a nightly result reusable as release evidence.
- It does not introduce selective semantic testing as a required gate before a
  changed-file dependency graph is proven complete.
- It does not weaken ASLRef canaries, exact-head identity checks, evidence set
  equality, or release failure behavior.
- It does not preserve obsolete schemas through parallel compatibility paths.
  The migration is an intentional hard break.

## Current baseline

The latest reviewed baseline already provides several strong foundations:

- 840 ASL units own the current architecture.
- 840 Markdown pages are generated mirrors rather than independent prose.
- 3352 independent AVS points are discovered from the test tree.
- NDF clauses provide stable architecture identities inside ASL.
- catalogs, documentation, navigation, and release evidence are generated.
- `PR / validate` is a strict required check on protected `main`.
- `Release / validate` verifies one explicit 40-character commit.
- the release workflow separates identity, lightweight contract, strict model,
  balanced ASL pages, and evidence aggregation.

The remaining management defects are concentrated rather than architectural:

- ADR 0062 is a 4387-line audit record containing 183 separately named PRDs.
- active ASL still cites PRD identifiers.
- ten numeric PD records remain `review-required` in generator-owned data while
  the generated open-question page reports no open questions.
- ADR status and supersession metadata use several incompatible prose formats.
- accepted ADRs can retain proposal-time wording that contradicts their current
  status.
- the pull-request lane has recently measured a 745-second median and an
  802-second P90, exceeding the ten-minute target.
- the pull-request workflow runs several checks directly and again through the
  script test suite.
- full validation is manual-only, so the current `main` can move several
  normative commits beyond the last fully verified commit without an automatic
  health signal.
- obsolete instructions and deleted management surfaces still appear in active
  guidance or the large checked-in legacy tree.

## Source and authority model

The refactored authority chain is:

```text
accepted ADR
    explains architecture evolution
              |
              v
ASL owner + NDF clauses
    define current normative behavior
              |
              +--> generated catalogs and documentation
              +--> discovered independent AVS points
              +--> commit-scoped validation evidence
                              |
                              v
                       exact release closure
```

The roles are deliberately distinct:

- An ADR records the accepted decision, motivation, alternatives, compatibility
  consequences, and the exact NDF clauses affected by the decision.
- ASL and NDF express the current architecture after all applicable accepted
  ADRs are composed.
- Generated outputs project ASL and ADR metadata. They never select behavior.
- Tests and evidence prove implementation state at a commit. They never accept
  an architecture decision.
- A release record states that one immutable commit satisfies the selected
  release contract. It does not modify that contract.

## ADR record model

Every active ADR uses one machine-validated frontmatter schema. The schema is a
hard replacement for the existing free-form status headers; it is not named as
a second schema generation.

```yaml
id: ADR-0075
title: Example architecture decision
status: draft
authors:
  - github-handle
approvers: []
created: 2026-08-21
accepted: null
rejected: null
superseded: null
baseline: 1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f
target_releases:
  - 0.59.0
affected_ndf:
  - PTO-INST-TILE-EXAMPLE
affected_units:
  - PTO-TILE-EXAMPLE
resolves: []
supersedes: []
superseded_by: []
implementation_issue: null
release_impact: required
legacy_ids: []
```

Required status values are:

- `draft`: the architecture change is being defined and has no normative effect.
- `accepted`: the architecture decision is approved and may be implemented.
- `rejected`: the proposal was considered and declined.
- `superseded`: a later ADR replaces all or a named subset of the decision.

Status-dependent validation is fail closed:

- an accepted ADR requires at least one approver, an acceptance date, an exact
  baseline commit, and a nonempty NDF impact;
- a rejected ADR records its rejection date and rationale;
- a superseded ADR records its supersession date and names at least one
  `superseded_by` ADR;
- relationship-only metadata may be updated when a later ADR is accepted, but
  the earlier decision text remains unchanged.

`accepted` means that the architecture decision is valid. It does not mean that
ASL implementation, tests, conformance, or release closure are complete.

An accepted ADR is substantively immutable. Editorial repairs may correct
spelling, broken links, or metadata that does not alter meaning. A semantic
change requires a new ADR that names the superseded decision and affected
clauses. Partial supersession names exact decision clauses instead of relying on
prose such as "superseded in part."

The ADR body uses a consistent structure:

- Summary
- Context
- Decision
- Normative delta
- Defaults and intentionally unspecified behavior
- Compatibility and dependent-toolchain impact
- Alternatives considered
- Risks and mitigations
- Implementation obligations
- Verification obligations
- Release consequences

Headings are semantic and unnumbered. The ADR schema and checker own state,
relationships, and identity; Markdown prose owns rationale and explanation.

## PRD, PDR, and PD migration

No active `PRD-*`, `PDR-*`, or `PD-*` identity remains after migration.

### Mnemonic review PRDs

The 183 PRDs in ADR 0062 are grouped into coherent architecture ADRs rather than
converted mechanically into 183 tiny files. The initial grouping is:

- block attributes, defaults, and lifecycle;
- block dimensions and scalar bindings;
- Local and Shared Tile bindings and lifetime;
- scalar and system instruction decisions;
- tile elementwise tile-tile behavior;
- tile scalar and immediate behavior;
- reduction, expansion, and partial-tile behavior;
- conversion, quantization, and numeric status behavior;
- TLSU and global-memory behavior;
- CUBE and matrix behavior;
- irregular, rearrangement, and layout behavior;
- encoding, active inventory, and extension reservations.

Each new ADR records its former PRD identifiers in `legacy_ids`. Active ASL and
tests reference NDF clauses and ADR identities, never PRD identities. A generated
legacy index maps old identifiers to their ADR and NDF replacements for history
navigation only.

ADR 0062 becomes a short historical audit summary after every PRD has a new ADR
owner. It no longer contains operative architecture rules.

### Numeric PD records

PD-03 and PD-04 map to their existing accepted ADRs. Their PD identifiers move
to `legacy_ids`.

The other ten review-required numeric decisions become draft ADRs. Proposed
rules move out of Python generators and generated evidence. Generators consume
ADR metadata and ASL facts; they may report that an ADR is draft or missing, but
they may not author a proposed result rule.

The numeric decision input and proposal ledgers are either removed or reduced to
generated readiness indexes. They contain identities, affected domains,
evidence links, and computed status, but no human-authored architecture choice.

### Open questions

`docs/status/open/` is generated from draft ADRs and accepted ADR obligations
that remain unresolved. It is never edited as an independent status source.

An open item has one owner:

- an unresolved architecture choice is a draft ADR;
- an accepted decision awaiting implementation is an accepted ADR with an open
  implementation issue;
- missing ASL, test, conformance, or release evidence is derived from repository
  facts and commit-scoped results.

## Derived lifecycle and readiness

The repository presents a lifecycle for review, but no contributor edits that
lifecycle directly:

```text
draft
  -> architecture-defined
  -> modeled
  -> executable
  -> validated
  -> released
```

The stages are computed as follows:

- `draft`: a draft ADR names the capability or NDF clause.
- `architecture-defined`: every applicable ADR is accepted.
- `modeled`: the affected NDF clauses and ASL operation owners exist and pass
  structural closure.
- `executable`: decoder binding and required AVS points are discoverable.
- `validated`: a named commit has a successful validation event covering the
  required points.
- `released`: an immutable release manifest includes the capability at the
  validated commit.

Validation status is always commit-scoped. A successful result for an earlier
commit cannot make a later commit validated.

## Release selection and evolving main

`main` may contain draft ADRs, accepted but unimplemented decisions, and
implementation gaps. It must remain structurally valid and must not overstate
readiness.

A release selects an exact capability and NDF set through the release manifest.
Draft or future capabilities that are not selected do not appear in the release
projection. This follows the pattern used by mature registry-driven
specifications: tentative definitions may exist, but disabled or unselected
definitions are not generated into the published contract.

Release selection cannot hide a change to an already published capability. A
change to a published contract requires an accepted ADR, compatibility account,
new release identity where required, and exact release evidence.

## Verification lanes

### Pull-request lane

The required pull-request result has a ten-minute P95 service-level objective.
It proves structural validity, not semantic or release closure.

The workflow uses parallel jobs:

- `PR / source-contract`: ADR schema and graph, NDF, ASL layout, ASL test
  ownership, projections, documentation, publication hygiene, and diff hygiene.
- `PR / tooling-tests`: script unit tests and the pinned NDF compiler parity
  tests, with tool build caching.
- `PR / validate`: a small aggregator that requires both jobs and remains the
  stable branch-protection context.

The direct checks and their regression tests must not execute the same full
repository traversal twice. Unit tests exercise checker failure modes with
fixtures; the workflow runs each production checker once.

The workflow records per-job and per-check timing. P50, P95, failure category,
and cache-hit rate are retained as workflow summaries so performance regressions
are visible.

### Post-merge and nightly lane

A scheduled workflow validates the latest `main` commit with the full pinned
model and all AVS points. It may also run after merge when resources allow.

This result is a health signal only:

- it does not block the merge that triggered it;
- it does not modify ADR, ASL, or readiness metadata;
- it does not satisfy release closure;
- it records the exact tested commit and retains per-ID results;
- a later commit makes the health result stale.

The repository landing page reports the last fully validated `main` commit and
its age without presenting it as the current release.

### Release lane

The current exact-head release architecture remains authoritative:

- explicit 40-character commit input;
- exact checkout identity;
- pinned and verified ASLRef toolchain;
- strict model checking;
- all balanced AVS pages;
- complete per-ID result aggregation;
- regenerated canonical evidence;
- clean-tree equality;
- signed release manifest and publication action performed separately.

Nightly artifacts may warm immutable toolchain caches, but normative build
outputs and result artifacts are keyed by their exact content and commit. A
nightly success cannot be copied into a release record.

## Repository information architecture

The professional repository surface follows a hub-and-spoke structure.

### Root files

- `README.md`: project purpose, current release and draft status, five-minute
  quick start, source-of-truth map, validation lanes, and links to deeper guides.
- `CONTRIBUTING.md`: concise contributor workflow and change classification.
- `GOVERNANCE.md`: authority, decision process, merge and release controls.
- `.github/CODEOWNERS`: one repository owner, `@zhoubot`.
- `SECURITY.md`, `CODE_OF_CONDUCT.md`, `LICENSE`, and `NOTICE`: standard project
  policy surfaces.
- `CHANGELOG.md`: release-oriented architecture changes derived from accepted
  ADRs and release manifests.

### Documentation hubs

- `docs/governance/adr-process.md`: ADR lifecycle, schema, examples, and
  supersession rules.
- `docs/governance/validation.md`: PR, nightly, and release lane contracts.
- `docs/development/repository-layout.md`: source ownership and generated paths.
- `docs/development/getting-started.md`: pinned development environment and
  common commands.
- `docs/releases/`: generated release notes and immutable release links.
- `docs/status/decisions/`: active and historical ADRs using one schema.
- `docs/status/open/`: generated open-decision and implementation dashboard.

The README remains concise. Detailed inventory counts and maturity tables live
in generated status pages rather than being copied into multiple entry points.

### Legacy cleanup

The checked-in `docs/status/legacy/` tree is removed from the active branch once
its required provenance is pinned to tags or release archives. Git history and
published releases remain the historical archive. No active link, checker, or
generator may depend on legacy paths.

This cleanup materially reduces repository noise and prevents readers and tools
from treating stale pages as current documentation.

### Review experience

Every normative pull request produces a compact generated review summary:

- changed ADRs and status transitions;
- changed NDF clauses and ASL owners;
- changed accepted encodings or a statement that the binary surface is stable;
- generated pages and catalogs affected;
- focused AVS points added or changed;
- compatibility and release impact;
- unresolved draft ADRs or implementation gaps introduced by the change.

The summary is a review aid, not authority. A changebar or semantic-delta view
is generated from the merge base so reviewers do not need to inspect large
unchanged projections.

## Development environment

The repository keeps environment ownership at the validation boundary instead
of packaging a second container distribution:

- the PR lane uses standard Python plus the exact NDF submodule and Rust
  toolchain already owned by the repository;
- the full lane pins OCaml, opam inputs, ASLRef revision, action revisions, and
  exact commit checkout in its workflow contract; and
- local contributors use the same checked commands and `make setup` rather
  than a parallel image lifecycle.

A repository-owned Docker/devcontainer layer was evaluated and rejected. It
duplicated existing pins, added registry and installer freshness obligations,
and increased CI/maintenance cost without strengthening any semantic or
release proof. Toolchain changes remain isolated from governance and normative
architecture changes.

## Migration safety

The management refactor is delivered as isolated, reviewable changes. Before
each removal or ownership transfer, regression tests lock the current behavior.

The migration must prove:

- no active ASL semantic body changes as a side effect of record migration;
- NDF clause identities remain stable;
- generated scalar, block, tile, system-register, and reservation inventories
  remain equal;
- the decoded binary envelope and fingerprint remain equal;
- release identity and active profile remain equal;
- every old PRD and PD identity maps to exactly one ADR or explicit rejected
  historical record;
- no active source references PRD, PDR, PD, deleted requirements, or legacy
  paths;
- open-question, ADR, NDF, test, and release indexes regenerate without manual
  edits.

A checker or canary is never relaxed to pass the migration. If a current check
encodes an obsolete multi-source rule, a regression test first states the new
single-source contract; only then is the old rule replaced.

## Delivery sequence

The implementation plan will decompose this design into ordered pull requests:

- establish ADR schema, parser, graph, and regression tests;
- migrate PRD decisions and replace active references;
- migrate numeric PD decisions and generate the open dashboard;
- derive lifecycle and release-selection views;
- restructure PR CI and add timing evidence;
- add nightly full validation without release authority;
- reorganize contributor documentation and generate release notes;
- remove active legacy content and stale guidance;
- run exact-head full verification and publish migration closure evidence.

Normative behavior changes discovered during migration are not fixed inside
these governance changes. They become separate draft ADRs and follow the normal
architecture process.

## Success criteria

The refactor is complete when:

- every active decision file passes one ADR schema;
- all active architecture decisions use ADR identities;
- active PRD, PDR, and PD references are zero;
- all former PRD and PD identities have one generated historical mapping;
- the open-question page is generated and exactly matches draft ADRs and
  unresolved accepted-ADR obligations;
- current ASL, NDF, catalogs, decoded surface, and release identity are unchanged
  by the management-only migration;
- required PR validation reaches a ten-minute P95 over at least ten
  representative samples spanning at least five workflow run IDs;
- the latest `main` full-validation commit and age are visible;
- nightly validation cannot be mistaken for release evidence;
- release validation still requires an exact immutable commit and complete
  result set;
- README, contributing, governance, development, ADR, validation, and release
  guidance have one clear owner each;
- `.github/CODEOWNERS` contains `@zhoubot` as the sole owner identity;
- no active file or tool depends on `docs/status/legacy/` or the deleted
  requirements surface;
- a new contributor can identify the normative source, propose an architecture
  change, run the correct local check, and find release status from the root
  documentation without tribal knowledge.

## Alternatives considered

### Keep PRD and PD as subordinate namespaces

Rejected. Nesting those records inside ADR files still creates parallel
identities and permits ASL, generators, and evidence to refer to different
decision systems.

### Make ADR prose the current normative specification

Rejected. This would recreate the multi-source problem and make executable ASL
lag behind prose. ADRs explain evolution; ASL expresses the current composed
contract.

### Require full ASLRef validation before every merge

Rejected. Historical runs take roughly one to two hours when successful and
have experienced multi-hour infrastructure failures. This would unnecessarily
serialize architecture development.

### Remove full validation and rely on focused tests

Rejected. Shared dispatch, profile, catalog, and state dependencies make
changed-file-only coverage unsafe as a release proof.

### Preserve the old schema alongside the new one

Rejected. The user explicitly selected a hard break, and a compatibility period
would prolong the multiple-source condition. Historical ID mapping is enough.

## External design references

This design adopts patterns from mature specification and change-management
projects:

- [RISC-V ISA Manual](https://github.com/riscv/riscv-isa-manual): canonical
  source, normative-rule definitions,
  reproducible build environments, fast incremental review builds, clean final
  builds, and changebar review output.
- [Vulkan-Docs](https://github.com/KhronosGroup/Vulkan-Docs): schema-validated
  registry ownership, generated specification
  projections, and explicit inclusion of selected extensions.
- [WebAssembly specification](https://github.com/WebAssembly/spec): separation
  of major design discussion from the
  current formal specification, reference implementation, and official tests.
- [Rust RFC process](https://github.com/rust-lang/rfcs): acceptance is distinct
  from implementation, accepted
  records are substantively immutable, and major changes use follow-up RFCs.
- [Kubernetes KEP process](https://github.com/kubernetes/enhancements/tree/master/keps):
  controlled lifecycle metadata, owner and approver
  fields, explicit replacement links, implementation history, goals,
  non-goals, risks, and release graduation criteria.

These references inform the management design. They do not override PTO's ASL,
NDF, one-level architecture, or exact release requirements.
