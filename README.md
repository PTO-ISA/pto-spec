# PTO ISA Formal Specification

[![ASL validation](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml/badge.svg)](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml)

`pto-spec` is the normative ASL1 definition of the PTO Instruction Set
Architecture. It specifies a 64-bit scalar ISA, bundle/command forms, direct
tile operations, visible architectural state, legality, faults, completion,
profiles, and memory ordering in one executable model.

The repository is a normative draft at maturity M4. Its accepted catalogs,
decoded execution paths, architectural state/fault envelopes, ordering model,
and all scalar, bundle, TEPL, TMA, and CUBE reference semantics are cumulatively
closed through Stage 4. The independent executable-model comparison is also
closed under `S5-T3`; target numeric conformance and release closure remain
staged work. See the
[maturity bring-up plan](docs/maturity-bringup-plan.md),
[maturity stage and target index](docs/maturity-stage-targets.md), and
[formal model coverage](docs/coverage.md).

The Stage 5 numeric ownership inventory is already closed: 19 scalar forms and
89 direct-tile operations are assigned to all 29 numeric profile hooks in
`spec/evidence/numeric-contracts.json`. This inventory does not claim numerical
or target-hardware conformance; those obligations remain open under `S5-T2`.
The executable-model comparison has an exhaustive 701-row disposition matrix
and a clean content-addressed snapshot whose generation, validation,
documentation, Sail parser, and Sail C-backend gates all pass.

## Architecture scope

- 474 scalar forms across AGU, ALU, AMO, BRU, FSU, and SYS.
- 107 bundle/command forms for bundle start, split, argument, dimension,
  attributes, IO binding, hints, stop, and context handling.
- 120 direct tile operations: 98 TEPL, 9 TMA, and 13 CUBE.
- A 32-code scalar namespace: 24 absolute GPRs plus four-entry T and U
  temporary queues, eight predicate registers, and 64 flat T/U/M/N tiles.
- 72 architecturally visible system registers, including THREAD_PTR,
  GLOBAL_PTR, BLOCKID, THREAD_ID, CORE_STATE, CORE_ID, and TILE_CAPACITY.
- Visible TPC/BPC bundle state and `TileInfo` state for every tile register.
- Exact encoding masks, operand fields, constraints, selectors, and rejection
  witnesses generated from machine-readable catalogs.
- Explicit tile and scalar-queue legality before effects.
- Instruction-granular memory completion and restart behavior.
- A concrete `pto-v0` numeric, memory, ACR, reset, and time profile.
- A bounded production-connected PTO-TSO candidate model.
- No vector instruction execution surface; vector-only encodings are outside
  the PTO ISA.

Hardware pipelines, physical tile allocation, backend intrinsics, latency,
throughput, and target scheduling are outside this architecture contract.

## Bundle and core-block terminology

**Bundle** is PTO's architecture term for the visible unit of grouped execution
and control. The encoded ISA keeps its established `B` spellings:

| Architecture concept | Stable ISA spelling |
| --- | --- |
| Start or stop a bundle | `BSTART`, `BSTOP`, `C.BSTART`, `C.BSTOP` |
| Configure a bundle | `B.ARG`, `B.DIM`, `B.CATR`, and other `B.*` forms |
| Bundle-body program counter | BPC |
| Virtual core-block topology | `BLOCKNUM`, `BLOCKID` |
| Cross-core-block target | the `CROSS_BID` operand field |

The `B` prefix on bundle instructions means **bundle**. By contrast,
`BLOCKNUM`, `BLOCKID`, and `CROSS_BID` refer to virtual core blocks and are not
bundle-state names. These spellings are part of the binary and assembly
contract; the bundle terminology change does not alter instruction encodings,
register addresses, or execution behavior.

## Normative contract

Normative authority and source precedence are defined in
[Normative sources](docs/normative-sources.md). The primary review surfaces are:

| Surface | Role |
| --- | --- |
| [`asl/`](asl/) | Executable architectural state and semantics |
| [`spec/catalog/`](spec/catalog/) | Accepted scalar forms, system registers, traps, and tile selectors |
| [`spec/requirements.json`](spec/requirements.json) | Requirement-to-model-to-test traceability |
| [`spec/profile-hooks.json`](spec/profile-hooks.json) | Complete `impdef` profile registry |
| [`spec/evidence/`](spec/evidence/) | Generated closure records and release evidence |
| [`specification.toml`](specification.toml) | Machine-readable status, profile, architecture, and toolchain metadata |

Human-readable architecture documents supplement those machine-readable
contracts:

| Document | Purpose |
| --- | --- |
| [Instruction reference](docs/instructions/index.md) | Generated catalog reference for scalar forms, bundle/command forms, direct tile operations, and system registers |
| [Architecture boundary](docs/architecture.md) | State, execution, legality, faults, and excluded implementation detail |
| [Memory model](docs/memory-model.md) | PTO-TSO events, relations, axioms, and executable evidence |
| [Profile contracts](docs/profile-contracts.md) | `pto-v0` behavior and alternate-profile obligations |
| [Maturity bring-up plan](docs/maturity-bringup-plan.md) | Staged targets and exit gates from executable draft to architectural completeness |
| [Maturity stage and target index](docs/maturity-stage-targets.md) | Compact stage map and target register for bring-up review |
| [Modeling conventions](docs/modeling-conventions.md) | ASL organization and normative modeling rules |
| [Formal review checklist](docs/review-checklist.md) | Required evidence for normative review |

Accepted architecture decisions are retained under
[`docs/architecture-decisions/`](docs/architecture-decisions/).

## Validation

Prerequisites are Git, GNU Make, Python 3.11+, OCaml, and an initialized opam
switch. Install ASLRef build dependencies once, then run the complete gate:

```bash
make setup
make ci
```

`make ci` runs:

| Target | Checks | Needs ASLRef |
| --- | --- | --- |
| `repo-check` | Repository structure, catalogs, generated evidence, traceability, and publication hygiene | No |
| `toolchain-check` | Pinned ASLRef accept/reject/execute canaries | Yes |
| `check` | Strict type-checking of the assembled specification | Yes |
| `test-parallel` | Thirty-four focused shards covering every canonical executable architecture and boundary test exactly once | Yes |

`make ci` uses four concurrent ASLRef jobs by default. Set
`ASL_TEST_JOBS=<n>` to match the available CPU and memory. The canonical
single-process regression remains available as `make test`; the shard checker
proves that the parallel mains contain every canonical test call exactly once
and that every declared test subprogram remains reachable.

The `scripts/aslref` wrapper fetches the exact audited ASLRef commit in
`.aslref-version` and builds it under the ignored `.cache/` directory. To use a
local ASLRef binary for iteration:

```bash
make ci ASLREF=/path/to/aslref
```

A substituted binary is not evidence about the audited toolchain pin. Hosted
validation always uses the pinned source wrapper.

## Repository layout

```text
asl/                     Normative ASL1 sources
  scalar/                Scalar operand, arithmetic, control, memory, atomic, system, and FP semantics
  bundle/                 Bundle/command state and semantics
  tile/                  Flat tile state, legality, TEPL, TMA, and CUBE semantics
  profiles/              Concrete architecture profiles
spec/                    Machine-readable catalogs, requirements, profiles, and evidence
tests/
  asl/                   Executable architecture and boundary tests
  canary/                Pinned ASLRef parser, type-checker, and interpreter canaries
docs/                    Architecture, generated instruction reference, memory model, profiles, evidence policy, and ADRs
scripts/                 Deterministic generation and fail-closed validation
```

Every checked-in ASL source must appear in `ASL_SOURCES`, and every semantic
test must appear in `ASL_TESTS`, both in dependency order in the `Makefile`.
Generated assemblies remain ignored under `build/`.

## Contributing and license

Normative changes require stable requirement IDs, executable evidence, and both
architecture and formal-model review. See [Governance](GOVERNANCE.md) and
[Contributing](CONTRIBUTING.md).

The repository uses the [BSD 3-Clause License](LICENSE). External evidence and
its permitted use are recorded in [NOTICE](NOTICE).
