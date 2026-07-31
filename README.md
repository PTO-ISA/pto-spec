# PTO ISA Formal Specification

[![ASL validation](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml/badge.svg)](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml)

`pto-spec` is the normative ASL1 definition of the PTO Instruction Set
Architecture. It specifies a 64-bit scalar ISA, bundle/command forms, direct
tile operations, visible architectural state, legality, faults, completion,
profiles, and memory ordering in one executable model.

The repository is the normative draft of the **PTO ISA 0.57.1** contract at
maturity M4. The release identity and active executable profile identity are
separate: 0.57.1 fixes the encoding ABI, while `pto-v0` remains the deterministic
raw-carrier reference profile. Accepted catalogs, decoded execution paths,
architectural state/fault envelopes, ordering, and scalar, bundle, TEPL, TMA,
and CUBE reference semantics are cumulatively closed through Stage 4. The
independent executable-model comparison is also closed under `S5-T3`; target
numeric conformance and release closure remain staged work. See the
[maturity bring-up plan](docs/maturity-bringup-plan.md),
[maturity evaluation and staged targets](docs/maturity-stage-targets.md), and
[formal model coverage](docs/coverage.md).

The Stage 5 numeric ownership inventory is already closed: 19 scalar forms and
89 direct-tile operations are assigned to all 30 numeric profile hooks in
`spec/evidence/numeric-contracts.json`. This inventory does not claim numerical
or target-hardware conformance; those obligations remain open under `S5-T2`.
The generated `spec/evidence/numeric-conformance-readiness.json` ledger
partitions that work across six parallel lanes and keeps every unavailable
profile, oracle, vector, result, and review identity explicit.
The generated `spec/evidence/numeric-profile-decision-proposals.json` ledger
imports four versioned identities and five selection rules accepted by ADR
0037, then proposes dispositions for all 12 open numeric decisions and mappings
for all 20 domains. Every result-decision and domain-rule acceptance field is
null. ADR 0038 and the generated
`spec/evidence/scalar-numeric-flag-contract.json` ledger separately close the
scalar flag lifecycle and 30/30 producer-owner matrix while leaving exact
conditions open for 19 profile-owned forms, so PD-06 and S5-T2 remain open.
ADRs 0039 and 0047 and the generated
`spec/evidence/numeric-rounding-selector-contract.json` ledger separately map
all scalar, fixed-conversion, bundle, public, matrix, stochastic, and
backend-only rounding selector namespaces. PD-03 now accepts the complete
selector translations, tie behavior, operation defaults, rounding points, and
rounding-before-saturation order across 18 domains, 102 operations, and 25
hooks. Other numeric decisions keep S5-T2 open.
ADR 0040 and the generated
`spec/evidence/numeric-format-namespace-contract.json` ledger close the
structural part of PD-02: five independent code namespaces, all 25
`TileDataType` raw-carrier identities, every mapped and reserved code, and the
low-nibble-first packing rule for all four 4-bit types. Eight format-binding,
exceptional-value, legality, target-availability, and vector obligations remain
open at that checkpoint. ADR 0043 and
`spec/evidence/public-numeric-type-baseline.json` then bind all 16 published
type identities, accept 11 unambiguous catalog bindings, and close the A2/A3
(11 types) and A5 (16 types) availability baseline. Seven bit-exact format,
legality, and vector obligations remain; no complete result rule is accepted,
so PD-02 and `S5-T2` remain open while the M4 status is unchanged.
ADR 0044 and
`spec/evidence/public-integer-conversion-contract.json` close the next bounded
result checkpoint: all 48 unequal-width ordered pairs among the eight public
integer types use source-signed sign extension, source-unsigned zero extension,
or high-bit truncation. These are portable results only after a target profile
accepts the `TCVT` tuple. Six PD-07 residuals—including same-width,
floating-point, saturation, flags, and support legality—remain open; no complete
domain rule or parent numeric decision is accepted.
ADR 0041 and the generated
`spec/evidence/numeric-profile-applicability-closure.json` ledger close one
negative PD-01 applicability slice: A2/A3 rejects the six MX CUBE selectors
for all 25 `TileDataType` identities with `IllegalInstruction` before effects.
It accepts no result rule, so PD-01, `cube-matrix`, and S5-T2 remain open.
ADR 0042 and the generated
`spec/evidence/numeric-variation-point-ownership.json` ledger enumerate all 99
open domain/dimension variation points and map them to all 108 numeric
operations and 30 hooks. Every point remains owned by `pto-numeric-v1`; no
delegation, allowed-result contract, or domain result rule is accepted, so
PD-12 and S5-T2 remain open.
The executable-model comparison has an exhaustive 693-row disposition matrix:
557 exact matches, 96 explicit divergences, 39 non-comparable rows, and one
intentional extension. Of the divergences, 79 TEPL and 7 command rows are the
approved 0.57.1 ABI break traced to issue 18 and ADR 0045; the remaining 10 are
intentional rejected-command differences. The clean content-addressed snapshot
passes its generation, validation, documentation, Sail parser, and Sail
C-backend gates. This classification closes `S5-T3` without changing the open
`S5-T2` and Stage 6 claims.
Release traceability is now generated rather than inferred from prose. The
`spec/evidence/release-traceability-readiness.json` ledger covers 935 exact
units: all 46 requirements, accepted forms and operations, system registers,
traps, 38 profile hooks, and 73 ASL state roots expanded to 238 leaf fields. Its
inventory and links are closed, while S6-T1 promotion remains explicitly open
on S5-T2 and an immutable-commit claim-hygiene review.
The generated `spec/evidence/release-gate-readiness.json` ledger separately
closes the S6-T2 gate contract and hosted/parallel topology without treating a
live draft-branch run as release proof. Ten candidate gates, ten external
controls, and two review perspectives remain fail-closed until one signed,
immutable post-S5-T2 candidate supplies matching local, hosted, protection, and
approval evidence.

## Architecture scope

- 474 scalar forms across AGU, ALU, AMO, BRU, FSU, and SYS.
- 99 bundle/command forms for bundle start, dimension,
  attributes, IO binding, hints, stop, and context handling.
- 120 direct tile operations: 98 TEPL, 9 TMA, and 13 CUBE.
- PTO ISA 0.57.1 Mode/Function tile encoding with no untagged legacy decoder.
- A 32-code scalar namespace: 24 absolute GPRs plus four-entry T and U
  temporary queues, eight 32-bit per-warp predicate registers, one independent
  64-bit MPAR/MSEQ execution mask, and 64 flat T/U/M/N tiles.
- 72 architecturally visible system registers, including THREAD_PTR,
  GLOBAL_PTR, BLOCKID, THREAD_ID, CORE_STATE, CORE_ID, and TILE_CAPACITY.
- Visible TPC/BPC bundle state and `TileInfo` state for every tile register.
- A 128-byte architectural CELL, B.IOT allocation size codes from 128 bytes
  through 8 KiB, and aggregate capacity enforced by `TILE_CAPACITY`.
- Implicit architectural ACC state for CUBE, including logical and physical
  accumulation type and trap-preserved lifetime.
- Exact B.DATR data attributes and B.CATR ordering attributes.
- Exact encoding masks, operand fields, constraints, selectors, and rejection
  witnesses generated from machine-readable catalogs.
- Explicit tile and scalar-queue legality before effects.
- Instruction-granular memory completion and restart behavior.
- A concrete `pto-v0` numeric, memory, ACR, reset, and time profile.
- A named `pto-hardware-numeric-0.57.1-ieee-v1` contract whose independent
  implementation conformance remains open under `S5-T2`.
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
| [PTO ISA 0.57.1 decision](docs/architecture-decisions/0045-pto-isa-release-tile-contract.md) | Release identity, Mode/Function encoding, bundle attributes, CELL allocation, ACC, and hardware-profile boundary |
| [Memory model](docs/memory-model.md) | PTO-TSO events, relations, axioms, and executable evidence |
| [Profile contracts](docs/profile-contracts.md) | `pto-v0` behavior and alternate-profile obligations |
| [Maturity bring-up plan](docs/maturity-bringup-plan.md) | Staged targets and exit gates from executable draft to architectural completeness |
| [Maturity evaluation and staged targets](docs/maturity-stage-targets.md) | Reviewer-oriented entry gates, measurable targets, exit evidence, and promotion order |
| [Numeric profile decision register](docs/numeric-profile-decision-register.md) | Open S5-T2-A format, rounding, exception, reduction, quantization, and matrix decisions |
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
