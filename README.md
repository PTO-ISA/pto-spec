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
are tracked in [docs/coverage.md](docs/coverage.md), with exact portable
defaults and override obligations in
[docs/profile-contracts.md](docs/profile-contracts.md).

## Canonical contract

The normative precedence and one-level boundary are defined in
[docs/normative-sources.md](docs/normative-sources.md) and
[ADR-0001](docs/architecture-decisions/0001-one-level-pto.md). The direct Reg5
tile bridge is fixed by
[ADR-0002](docs/architecture-decisions/0002-direct-reg5-tile-bridge.md).

- 473 scalar forms are accepted across AGU, ALU, AMO, BRU, FSU, and SYS, with
  exact masks, matches, operand pieces, signedness, and legality constraints.
- All 473 scalar forms have executable decoded state transitions, including
  the 30 FSU forms and their explicit scalar numeric profile boundaries.
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

`make ci` runs five checks:

| Target | Checks | Needs ASLRef |
| --- | --- | --- |
| `gate-check` | the template gate detects active ASL and scanner failures | no |
| `repo-check` | repository, source-list, catalog, maturity, and publication invariants | no |
| `toolchain-check` | the pinned ASLRef accepts valid and rejects invalid ASL1 | yes |
| `check` | strict type-checking of the assembled specification | yes |
| `test` | executable PTO feature and boundary tests | yes |

`gate-check` and `repo-check` run without an opam switch, so most repository
work can fail fast before ASLRef is built. The complete gate also validates:

- exact scalar, system-register, and tile catalogs;
- generated scalar-form, operand-field, and tile-selector decoder witnesses;
- one-level architecture and publication hygiene;
- strict ASLRef type checking and executable semantic evidence;
- gate and toolchain canaries that prove validation can fail correctly.

The wrapper in `scripts/aslref` fetches the exact audited `herdtools7` commit
recorded in `.aslref-version` and builds it under the ignored `.cache/`
directory. To use an existing ASLRef binary locally:

```bash
make ci ASLREF=/path/to/aslref
```

Substituting a binary bypasses the repository pin, so it is useful for local
iteration but is not evidence about the audited commit. Hosted CI always uses
the pinned wrapper.

## Layout

```text
asl/
  architecture.asl       Architecture identity and model bounds
  types.asl              Scalar, fault, memory-order, and tile domains
  state.asl              Scalar, system, memory, and fault state
  scalar/                Operand bridge, integer, control, memory, atomic, system, and FP semantics
  tile/                  Flat tile state, TEPL, TMA, and CUBE semantics
tests/
  asl/                   Executable PTO feature and boundary tests
  gate/                  Fixtures proving the template gate works
  canary/                Fixtures proving the pinned ASLRef works
spec/
  requirements.json      Machine-readable requirement traceability
  catalog/               Canonical scalar forms, system registers, and tile operations
  evidence/              Independent semantic cross-check results
  profile-hooks.json     Exact impdef/default/override obligation registry
docs/                     Architecture decisions, coverage, and review contract
scripts/                  Reproducible evidence import and fail-closed validation
```

Every checked-in ASL source must appear in `ASL_SOURCES`, and every semantic
test must appear in `ASL_TESTS`, both in dependency order in the `Makefile`.
`make repo-check` rejects unlisted inputs so they cannot silently bypass ASLRef.
Generated assembled files remain ignored under `build/`.

Every validation result ultimately becomes an exit code, so `tests/gate/` and
`tests/canary/` test the checks themselves. The enforcement map in
[GOVERNANCE.md](GOVERNANCE.md) distinguishes clone-verifiable rules from GitHub
repository settings and human review obligations.

## Governance and licensing

Normative changes require a formal-model issue, stable requirement IDs,
executable evidence, architecture-owner review, and formal-model review. See
[GOVERNANCE.md](GOVERNANCE.md) and [CONTRIBUTING.md](CONTRIBUTING.md).

This repository is licensed under the [BSD 3-Clause License](LICENSE). External
evidence and its permitted use are recorded in [NOTICE](NOTICE).
