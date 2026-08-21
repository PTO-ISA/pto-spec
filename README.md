# PTO ISA Formal Specification

[![PR checks](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml/badge.svg?branch=main&event=push)](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml?query=branch%3Amain)
[![Exact-head release verification](https://github.com/PTO-ISA/pto-spec/actions/workflows/release.yml/badge.svg?branch=main)](https://github.com/PTO-ISA/pto-spec/actions/workflows/release.yml)
[![PTO ISA v0.58.2](https://img.shields.io/badge/PTO_ISA-v0.58.2-blue.svg)](https://github.com/PTO-ISA/pto-spec/releases/tag/v0.58.2)
[![License: BSD 3-Clause](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](LICENSE)

`pto-spec` is the executable ASL1 specification of the PTO Instruction Set
Architecture. The repository describes scalar, bundle/command, and direct Tile
behavior in one reviewable model.

The working tree is a **normative draft**. A numbered release is an immutable
commit whose exact-head release verification and reproducible evidence have
succeeded; a draft branch, pull request, nightly run, or older successful run is
not a release.

Management-system migration status and efficiency evidence are recorded in the
[generated closure record](spec/evidence/management-system-refactor-closure.json).

## Five-minute quick start

Prerequisites for the pull-request lane are Git, GNU Make, and Python 3.11+.

```bash
git clone --recurse-submodules https://github.com/PTO-ISA/pto-spec.git
cd pto-spec
make pr-check
```

Start architecture reading at the [architecture overview](docs/arch/overview/architecture.md),
then choose the [block](docs/block/), [scalar](docs/scalar/), or
[Tile](docs/tile/) reference. For environment setup and common failures, use
the [getting-started guide](docs/development/getting-started.md).

## Normative authority

There is one source chain:

```text
ASL/NDF owner -> generated Markdown mirror -> AVS -> commit-scoped evidence
```

- ASL under `asl/` owns current architectural state, legality, results, faults,
  and instruction metadata. NDF clauses inside the owning ASL provide stable
  requirement identities.
- Accepted ADRs under [`docs/status/decisions/`](docs/status/decisions/) record
  reviewed choices and rationale. They do not override the current ASL owner.
- Generated Markdown, catalogs, the
  [release-traceability view](spec/evidence/release-traceability-readiness.json),
  release manifests, changelogs, and review summaries are derived navigation or
  evidence. They are not independent authority.
- Unresolved choices live only in the [open-question index](docs/status/open/)
  until an accepted decision updates the owning ASL/NDF.

See the [ADR and NDF process](docs/governance/adr-process.md) for state and
ownership rules.

## Validation lanes

| Lane | Trigger | Meaning |
| --- | --- | --- |
| Pull request | Push or pull request | Fast structure, projection, tooling, documentation, and hygiene feedback; no release claim |
| Nightly | Latest `main` on schedule or dispatch | Non-authoritative full-model health for the exact latest `main` commit |
| Release | Dispatch with one full commit SHA | Authoritative release-candidate verification for that exact commit; does not publish a release |

Run `make pr-check` during ordinary work. Full local verification uses
`make setup`, `make release-verify`, and `make release-prepare`. The
[validation guide](docs/governance/validation.md) defines prerequisites,
fail-closed rules, and the difference between the three lanes.

## Repository map

| Path | Owner |
| --- | --- |
| `asl/{arch,block,scalar,tile}/` | Normative ASL/NDF owners |
| `docs/{arch,block,scalar,tile}/` | Generated ASL mirrors plus bounded supplementary explanation |
| `tests/asl/` | Independently runnable AVS points, mirrored to ASL owners |
| `docs/status/` | ADR and open-question records |
| `spec/catalog/` | Generated accepted-form and selector projections |
| `spec/evidence/` | Commit-scoped generated evidence and traceability |
| `scripts/` | Deterministic generation and fail-closed checks |
| `.github/workflows/` | Pull-request, nightly, and release validation contracts |

The [repository-layout guide](docs/development/repository-layout.md) gives the
complete ownership map without duplicating ISA semantics. Current release
identity and evidence entry points are collected in the
[release hub](docs/releases/index.md).

## Contributing and license

Read [Contributing](CONTRIBUTING.md) before changing ASL, ADRs, tests,
generators, or governance. Repository policy is in [Governance](GOVERNANCE.md).

The project uses the [BSD 3-Clause License](LICENSE). Permitted external
evidence and attribution are recorded in [NOTICE](NOTICE).
