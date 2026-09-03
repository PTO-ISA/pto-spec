# Contributing

`pto-spec` accepts small, auditable changes that preserve a single owner for
every architectural statement. Read [Governance](GOVERNANCE.md), the
[ADR process](docs/governance/adr-process.md), and the
[validation guide](docs/governance/validation.md) before starting.

## Choose the change scenario

### PTO interface definition change

1. Open an NDF architecture issue against a full baseline commit.
2. Name the affected stable `PTO-*` clauses, owning ASL units, defaults,
   unspecified behavior, compatibility, open questions, evidence, and release
   impact.
3. Identify the existing topic ADR and update it. Allocate a new ADR only when
   the change defines a genuinely new externally visible PTO interface.
4. Reach the required ADR state before implementation.
5. Change the owning ASL/NDF first; never create a parallel prose definition.
6. Regenerate its Markdown, catalog, decoder, AVS, and release-evidence
   projections together.
7. Add focused positive, boundary, negative, fault, alias, ordering, and state
   transition points as applicable.

### ASL or specification implementation correction

When the public interface is already decided and ASL, decode, dispatch,
reference-profile code, a bounded model, or a test implements it incorrectly,
fix the owning ASL/tests directly. Link the governing interface ADR when one
exists, but do not allocate a new ADR. The issue and commit history record why
the correction was needed.

Before downstream consumers adopt a newly allocated ADR number, collapse it
into the existing topic ADR if review shows that it covers the same interface.
Remove the temporary record, reuse the established owner number, and regenerate
all ADR and release projections.

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

Generated exhaustive coverage also keeps one case per result file. A generator
must delete obsolete generated results, reject unexpected extras in `--check`
mode, and must not recreate multi-case shards.

Cross-component source programs, linker scripts, independent golden results,
and LLVM-to-ASL execution cases live in `PTO-ISA/asl-model`, not in this
repository. A normative instruction change updates its owning PTO-SPEC ASL and
direct AVS here, then adds or updates the corresponding ASL-MODEL obligation and
case before the exact-head release closure can pass.

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

PTO-SPEC ADRs and ASL NDF regions contain only PTO-owned identities.
ASL-Model and other downstream repositories own their own NDF numbering;
reference those records by repository URL rather than copying their IDs into
PTO metadata.

For an ASL owner or family rerun, put its exact current IDs in a file and use
`scripts/print-asl-test-matrix --ids-file`. Run the emitted page through
`scripts/run-asl-page -j "$(getconf _NPROCESSORS_ONLN)"`; do not build the full
release matrix merely to select a focused subset.

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
