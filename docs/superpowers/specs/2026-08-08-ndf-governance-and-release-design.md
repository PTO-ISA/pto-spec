# NDF Governance and Manual Release Design

## Status

Approved by the architecture owner on 2026-08-08.

## Purpose

PTO is an actively evolving ISA. Ordinary architecture pull requests must stay
fast to review and merge, while published releases must remain fail-closed and
fully verified. The repository therefore separates a lightweight merge lane
from a manually started release lane without creating a second interpretation
of the architecture.

All future architecture changes follow the
[Normative Design Format](https://github.com/hengliao1972/normative_language/blob/main/normative_language.md)
(NDF) clause, cross-reference, decision, and open-question conventions adapted
to PTO's ASL-golden source hierarchy.

## Single source of truth

The current repository tree contains one active interpretation of each
architecture contract:

1. Mnemonic ASL files own instruction decode, legality, state transitions,
   faults, ordering, and operation semantics.
2. Architecture ASL modules own NDF regions for contracts that are not local
   to one instruction, such as register visibility, tile lifetime, and bundle
   composition rules.
3. Each normative clause has exactly one owner. Other files refer to it by
   stable clause ID and do not restate it.
4. Catalogs, generated Markdown, MkDocs navigation, evidence ledgers, and
   release manifests are deterministic projections or verification artifacts.
5. Hand-written Markdown may add examples, rationale, and programmer guidance,
   but it is informative and may not introduce architecture behavior.

The current tree must not contain `legacy`, `archive`, copied old manuals,
version-suffixed backups, or parallel normative descriptions. Git history is
the historical archive. When a clause changes, its old body is removed or
replaced in place. The accompanying decision record identifies the old clause
ID, replacement clause ID, and baseline commit without copying the superseded
normative text.

This no-legacy rule is a deliberate PTO specialization of NDF supersession: the
decision graph preserves provenance while the working tree preserves only the
current design.

## PTO NDF contract

ASL files carry NDF regions as structured comments so the executable source
remains the original owner:

```asl
// NDF-BEGIN: PTO-TILE-CAPACITY-PER-PE
// ndf: kind=contract level=L1 layer=tile status=accepted
// The decoded tile size MUST denote the capacity allocated for one selected PE.
// NDF-END: PTO-TILE-CAPACITY-PER-PE
```

The documentation generator projects such regions into NDF Markdown with
stable headings and metadata:

```markdown
## Per-PE tile capacity {#PTO-TILE-CAPACITY-PER-PE}
<!-- ndf: kind=contract level=L1 layer=tile status=accepted -->

The decoded tile size MUST denote the capacity allocated for one selected PE.
```

Cross-references use `[[PTO-TILE-CAPACITY-PER-PE]]` in both ASL comment regions
and their generated Markdown projections. Decision records live in
`docs/architecture-decisions/` and open questions live in `docs/open/`; they
record rationale and unresolved choices without copying the current contract.
Instruction-local NDF identity is carried by the mnemonic ASL metadata and
stable ASL documentation regions. Generated instruction pages expose the same
identity and embed the exact ASL text.

The four NDF levels are:

- L0: architectural intent;
- L1: externally visible contract;
- L2: mechanism and composition rules;
- L3: executable ASL contract and verification binding.

Every normative architecture PR must change an existing clause, add a clause,
or resolve an open question through a decision record. A human instruction
that changes the design is not complete until the same PR records that delta.

## Architecture issue workflow

An architecture issue is the entry point for a normative change. Its template
requires:

- problem statement and intended outcome;
- affected stable NDF clause IDs;
- current baseline commit;
- proposed normative delta, including defaults and unspecified behavior;
- compatibility and toolchain impact;
- open questions that must not be guessed;
- expected ASL, catalog, documentation, and release evidence.

Implementation may begin once the architecture owner resolves the material
questions and marks the issue decision-ready. Small corrections may combine
the issue and decision record, but they do not bypass clause traceability.

## Pull request workflow

Pull requests are small, reviewable architecture deltas. A normative PR must:

- link its architecture issue;
- identify added, changed, and removed NDF clauses;
- update the owning mnemonic or architecture ASL source;
- regenerate every deterministic projection;
- add focused verification for changed behavior;
- run `make pr-check` locally.

The required hosted PR gate runs only `make pr-check`. It must complete without
installing OCaml/opam or building ASLRef. The gate checks:

- NDF metadata, stable IDs, cross-references, decisions, and open-question
  structure;
- permitted repository paths and one-to-one ASL/Markdown mnemonic layout;
- absence of legacy or backup specification trees;
- generated instruction documentation and navigation freshness;
- Python, shell, JSON, YAML, Markdown, and MkDocs lint that uses already
  available lightweight tools;
- catalog, release identity, and repository invariants that do not execute the
  full formal model.

The lightweight gate must never claim ASL verification or coverage. Its result
means only that the change is structurally reviewable and its projections are
consistent.

## Manual release workflow

Publication is started explicitly with a `workflow_dispatch` release workflow
for one exact commit or tag candidate. `make release-verify` is the local and
hosted entry point. It runs, fail-closed:

1. `make pr-check` on a clean checkout;
2. pinned ASLRef toolchain canaries;
3. strict typecheck of the normative model;
4. every canonical ASL runtime shard in parallel;
5. catalog, decoder, traceability, coverage, and release-evidence checks;
6. strict MkDocs generation and publication hygiene;
7. release-manifest regeneration followed by a clean-tree proof.

The workflow records the exact commit, toolchain commit, shard matrix, results,
coverage, and generated release manifest as downloadable artifacts. A tag or
GitHub Release may be created only after all release jobs succeed for that same
exact commit. Pending, skipped, cancelled, stale-head, or failed jobs are never
treated as success.

Long hosted ASL jobs are observed asynchronously. Starting the workflow returns
the run URL; merge and publication automation must not synchronously block an
interactive agent session for the full validation duration.

## Workflow topology

```text
Architecture issue
  -> NDF decision-ready contract
  -> pull request updates ASL/NDF owner
  -> make pr-check
  -> merge
  -> manual release workflow on exact commit
  -> full ASL verification and coverage
  -> tag and GitHub Release
```

## Migration

The first implementation of this design will:

- replace the current PR-triggered full ASL workflow with a lightweight PR
  workflow;
- add a manual full release workflow;
- define `pr-check` and `release-verify` Make targets;
- add a repository-local lightweight NDF checker and its focused tests;
- replace the formal-model issue and PR templates with NDF-aware templates;
- update contributing and governance documentation;
- delete the active `docs/legacy/` tree and reject its return;
- retain only generated indexes where aggregate instruction pages would create
  a second semantic description;
- preserve full release verification strength while removing it from the merge
  critical path.

## Acceptance criteria

- An ordinary PR runs one required lightweight gate and no OCaml/opam job.
- A manual release runs the complete pinned ASL model, all shards, coverage,
  projections, documentation, and release evidence.
- Release verification is tied to one exact commit and cannot accept pending or
  stale results.
- Every normative change is traceable through an NDF issue, stable clause IDs,
  the owning ASL/NDF source, and a decision record when required.
- No active architecture rule has two owners or two hand-maintained texts.
- No legacy or backup specification content exists in the current tree.
- Git history and decision metadata preserve provenance without preserving
  superseded normative bodies in the working tree.
