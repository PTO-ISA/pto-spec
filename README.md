# PTO ASL Specification Template

`pto-spec` is the repository template for describing the Parallel Tile Operation (PTO) architecture in
[ASL1](https://developer.arm.com/Architectures/Architecture%20Specification%20Language) (Architecture Specification
Language). ASL sources are checked with [ASLRef](https://github.com/herd/herdtools7/tree/master/asllib).

This repository intentionally contains no PTO architecture or instruction implementation. It provides only the source
layout, authoring placeholders, validation workflow, and contribution conventions needed to begin the formal model.

## Quick start

Prerequisites:

- GNU Make
- [ASLRef](https://github.com/herd/herdtools7/tree/master/asllib) built from the upstream source

Validate the template:

```bash
make ci
```

`make check` parses and type-checks the assembled ASL source without executing it. Generated, concatenated ASL files
are written under `build/`. If the executable is not named `aslref` or is not on `PATH`, set `ASLREF`, for example:

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
```

The source order is explicit in the `Makefile`. Keep source files independently focused; ASLRef receives a generated
single-file specification because its command-line interface accepts one primary ASL file.

## Starting the specification

Define the architectural boundary in [docs/architecture.md](docs/architecture.md), then add named ASL types, visible
state, common helpers, and instruction operations in small reviewable files. Add each new source to `ASL_SOURCES` in
the `Makefile` and keep it valid under `make check`.

## Licensing

No project license has been selected yet. Until one is added, copyright remains with the contributors and reuse is
not granted beyond rights provided by applicable law.
