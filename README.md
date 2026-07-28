# PTO Instruction Set Architecture

[![ASL](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml/badge.svg)](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml)

`pto-spec` is the self-contained golden ASL1 model of the **PTO Instruction Set
Architecture**. It defines a 64-bit scalar ISA and direct tile operations in a
flat, one-level machine.

The current specification is a normative draft. Its complete accepted
instruction surface, operand fields, architectural state, and scalar, TEPL,
TMA, and CUBE semantic primitives execute under ASLRef. Numeric and system
behaviors that require an implementation profile use named ASL `impdef` hooks
rather than silent backend choices. Coverage and those remaining closure items
are tracked in [docs/coverage.md](docs/coverage.md).

## Canonical contract

The normative precedence and one-level boundary are defined in
[docs/normative-sources.md](docs/normative-sources.md) and
[ADR-0001](docs/architecture-decisions/0001-one-level-pto.md). The direct Reg5
tile bridge is fixed by
[ADR-0002](docs/architecture-decisions/0002-direct-reg5-tile-bridge.md).

- 474 scalar forms are accepted across AGU, ALU, AMO, BRU, FSU, and SYS, with
  exact masks, matches, operand pieces, signedness, and legality constraints.
- 111 direct tile operations are accepted: 97 TEPL, 6 TMA, and 8 CUBE.
- 64 tile registers form T/U/M/N hands with 16 registers per hand.
- The architecture contains no nested instruction bodies or body-local state.
- Private tile documentation is used only as anonymized, non-redistributive
  semantic cross-check evidence.

## Validate

Prerequisites are Git, GNU Make, Python 3.11+, OCaml, and an initialized opam
switch. Install ASLRef build dependencies once and run the complete gate:

```bash
make setup
make ci
```

The gate performs:

- repository, naming, and licensing checks;
- exact scalar, system-register, and tile catalog validation;
- generated scalar-form, operand-field, and tile-selector decoder witnesses;
- one-level architecture and legacy-reference checks;
- strict ASLRef type checking;
- executable ASL feature and boundary tests.

ASLRef is built from the exact herdtools7 commit in `.aslref-version`. Generated
assembled files remain ignored under `build/`; the ASLRef checkout remains
ignored under `.cache/`.

## Layout

```text
asl/
  architecture.asl       Architecture identity and model bounds
  types.asl              Scalar, fault, memory-order, and tile domains
  state.asl              Scalar, system, memory, and fault state
  scalar/                Operand bridge, integer, control, memory, atomic, system, and FP semantics
  tile/                  Flat tile state, TEPL, TMA, and CUBE semantics
tests/asl/                Executable feature and boundary tests
spec/
  requirements.json      Machine-readable requirement traceability
  catalog/               Canonical scalar forms, system registers, and tile operations
  evidence/              Independent semantic cross-check results
docs/                     Architecture decisions, coverage, and review contract
scripts/                  Reproducible evidence import and fail-closed validation
```

## Governance and licensing

Normative changes require a formal-model issue, stable requirement IDs,
executable evidence, architecture-owner review, and formal-model review. See
[GOVERNANCE.md](GOVERNANCE.md) and [CONTRIBUTING.md](CONTRIBUTING.md).

This repository is licensed under the [BSD 3-Clause License](LICENSE). External
evidence and its permitted use are recorded in [NOTICE](NOTICE).
