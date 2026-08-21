# Contributing

`pto-spec` accepts small, auditable changes that preserve a single owner for
every architectural statement. Read [Governance](GOVERNANCE.md), the
[ADR process](docs/governance/adr-process.md), and the
[validation guide](docs/governance/validation.md) before starting.

## Choose the change scenario

### Normative architecture change

1. Open an NDF architecture issue against a full baseline commit.
2. Name the affected stable `PTO-*` clauses, owning ASL units, defaults,
   unspecified behavior, compatibility, open questions, evidence, and release
   impact.
3. Reach the required ADR state before implementation.
4. Change the owning ASL/NDF first; never create a parallel prose definition.
5. Regenerate its Markdown, catalog, decoder, AVS, and release-evidence
   projections together.
6. Add focused positive, boundary, negative, fault, alias, ordering, and state
   transition points as applicable.

### Documentation or generated projection

Edit the topic owner, not every hub that links to it. Generated ASL mirrors are
updated through `scripts/instruction_docs.py`; catalogs and AVS fixtures use
their owning generators. Do not hand-edit generated text or copy ASL semantics
into governance prose.

### Validation or toolchain

Keep workflow/toolchain changes separate from architecture semantics. A pinned
ASLRef update must document the upstream delta and pass the complete exact-head
release lane. Never weaken a validator or canary to accept an invalid fixture.

### Repository maintenance or refactor

Lock behavior with regression tests, keep the diff mechanical, and leave ASL
meaning unchanged. Separate governance, toolchain, normative, and mechanical
commits when a larger effort contains more than one class.

## Source and test ownership

Normative sources live below `asl/arch`, `asl/block`, `asl/scalar`, and
`asl/tile`. Their exact generated documentation mirrors live below the same
four names in `docs/`; AVS points mirror them in `tests/asl/`.

Every executable point has one stable `PTO-TEST.id`, one observable purpose,
and one owning `source`. Use the repository filename grammar and keep setup
local. The [repository-layout guide](docs/development/repository-layout.md)
describes these boundaries and the derived surfaces.

## Develop and review

Create the regression or contract test first and observe the intended failure.
Make the smallest owner change, regenerate all affected projections, then run:

```bash
make pr-check
make repo-check
git diff --check
```

Use `scripts/generate-review-summary --base REF --head REF` to prepare a
merge-base semantic-delta aid. It does not replace source review. A pull request
must link the governing issue or ADR, identify changed NDF clauses and ASL
owners, describe compatibility and release impact, and explain any validation
gap.

Commits are signed. Pull requests land only after `PR / validate` succeeds for
the reviewed head and conversations are resolved. A successful pull request or
nightly run does not establish release eligibility.

## Full verification

After merge, release-candidate verification is bound to one full 40-character
commit SHA. The local sequential equivalent is:

```bash
make setup
make release-verify
make release-prepare
```

Pending, skipped, cancelled, failed, stale, or different-commit results are not
evidence for the candidate. Validation records results; publication and tagging
are separate authorized actions.

## Licensing

Contributions use the [BSD 3-Clause License](LICENSE). Do not copy third-party
specification prose, source, or diagrams unless the license is compatible and
attribution is recorded in [NOTICE](NOTICE).
