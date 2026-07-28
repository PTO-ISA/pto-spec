# PTO ASL Specification Template

[![ASL](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml/badge.svg)](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml)

`pto-spec` is the repository template for describing the Parallel Tile Operation (PTO) architecture in
[ASL1](https://developer.arm.com/Architectures/Architecture%20Specification%20Language) (Architecture Specification
Language). ASL sources are checked with [ASLRef](https://github.com/herd/herdtools7/tree/master/asllib).

This repository intentionally contains no PTO architecture or instruction implementation. It provides only the source
layout, authoring placeholders, validation workflow, governance, and contribution conventions needed to begin the
formal model.

## Quick start

Prerequisites:

- GNU Make
- Git
- OCaml and an initialized [opam](https://opam.ocaml.org/) switch

Install ASLRef build dependencies once, then validate the template:

```bash
make setup
make ci
```

`make check` parses and type-checks the assembled ASL source without executing it. Generated, concatenated ASL files
are written under `build/`. The wrapper in `scripts/aslref` fetches the exact audited `herdtools7` commit recorded in
`.aslref-version` and builds it under the ignored `.cache/` directory. To use an existing ASLRef binary instead:

```bash
make ci ASLREF=/path/to/aslref
```

## Repository layout

```text
asl/
  architecture.asl       Empty specification entry point
  instructions/
    TEMPLATE.asl         Commented instruction authoring template
docs/
  architecture.md        Scope and architecture-design checklist
  modeling-conventions.md
  review-checklist.md     Formal review obligations
  traceability.md         Requirement-to-model evidence matrix
.codex/skills/pto-asl/    Repo-local ASL authoring and review workflow
scripts/                  Reproducible ASLRef and repository checks
specification.toml        Machine-readable maturity status
```

The source order is explicit in the `Makefile`. Keep source files independently focused; ASLRef receives a generated
single-file specification because its command-line interface accepts one primary ASL file.

## Starting the specification

Define the architectural boundary in [docs/architecture.md](docs/architecture.md), then add named ASL types, visible
state, common helpers, and instruction operations in small reviewable files. Add each new source to `ASL_SOURCES` in
the `Makefile` and keep it valid under `make check`.

## Quality and governance

Read [GOVERNANCE.md](GOVERNANCE.md) and [CONTRIBUTING.md](CONTRIBUTING.md) before proposing changes. Normative model
changes require stable public requirement IDs, explicit architecture boundaries, executable evidence, and traceability.
Repository/tooling changes and ASLRef pin updates stay separate from semantic changes.

The reference implementation and ASL1 conformance corpus live in
[`herd/herdtools7`](https://github.com/herd/herdtools7/tree/master). CI uses a full commit pin rather than a moving
branch so parser, type-checker, interpreter, and standard-library behavior remain auditable.

## Licensing

No project license has been selected yet. Until one is added, copyright remains with the contributors and reuse is
not granted beyond rights provided by applicable law. Selecting a license is a governance prerequisite before accepting
external semantic contributions.
