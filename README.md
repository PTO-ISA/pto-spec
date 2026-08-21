# PTO ISA Formal Specification

`pto-spec` is the normative ASL1 definition of the PTO Instruction Set
Architecture. It specifies a 64-bit scalar ISA, bundle/command forms, direct
tile operations, visible architectural state, legality, faults, completion,
profiles, and memory ordering in one executable model.

The repository is the normative draft of the **PTO ISA 0.58.0** contract at
maturity **M4**. Release identity and executable profile identity are separate:
0.58.0 fixes the encoding ABI (`pto-isa-0.58.0-mode-function-v1`), while
`pto-v0` remains the deterministic raw-carrier reference profile.

## Status at a glance

| Area | Stage | Status |
| --- | --- | --- |
| Scalar, bundle, TEPL, TLSU, and CUBE reference semantics | M1–M4 | Closed |
| Binary decode and instruction dispatch | — | Mechanically closed |
| Memory ordering (PTO-TSO candidate) | M3 | Closed |
| Numeric ownership inventory | S5-T1 | Closed |
| Target numeric conformance | S5-T2 | **Open** |
| Independent executable-model comparison | S5-T3 | Closed |
| Release traceability promotion | S6-T1 | Open (blocked on S5-T2) |
| Release gate promotion | S6-T2 | Open (blocked on S5-T2) |
| Architectural completion | — | Open |

See the [maturity bring-up plan](docs/maturity-bringup-plan.md),
[maturity evaluation and staged targets](docs/maturity-stage-targets.md), and
[formal model coverage](docs/coverage.md) for the full staging contract.

## Numeric contract status (S5-T2)

The Stage 5 numeric ownership inventory is closed: 19 scalar forms and 85
direct-tile operations are assigned to all 28 numeric profile hooks in
[`spec/evidence/numeric-contracts.json`](spec/evidence/numeric-contracts.json).
This inventory does not claim numerical or target-hardware conformance; those
obligations remain open under S5-T2. The machine-derived closure snapshot is
**2 of 12 numeric decisions accepted, 0 of 18 complete domain rules accepted,
and 16 of 89 variation routes selected**. In decision-count terms, this is
**2 accepted and 10 open**; the variation ledger has **16 selected** and
**73 open** routes. Bounded checkpoints so far:

| Checkpoint | Ledger | Scope |
| --- | --- | --- |
| Decision framework (ADR 0037) | [`numeric-profile-decision-proposals.json`](spec/evidence/numeric-profile-decision-proposals.json) | 4 profile identities, 5 selection rules, dispositions for all 12 decisions and 18 domains |
| Scalar flag lifecycle (ADR 0038) | [`scalar-numeric-flag-contract.json`](spec/evidence/scalar-numeric-flag-contract.json) | 30/30 producer-owner matrix closed; exact conditions open for 19 profile-owned forms (PD-06 open) |
| Rounding selectors (ADRs 0039, 0047) | [`numeric-rounding-selector-contract.json`](spec/evidence/numeric-rounding-selector-contract.json) | **PD-03 accepted**: selector translations, tie behavior, defaults, and rounding-before-saturation across 16 domains, 100 operations, 23 hooks |
| Format namespaces (ADRs 0040, 0048) | [`numeric-format-namespace-contract.json`](spec/evidence/numeric-format-namespace-contract.json) | Structural PD-02 closed: 5 code namespaces, all 25 `TileDataType` identities, typed value classes, five packed four-bit types; propagation and legality open |
| A2/A3 MX applicability (ADR 0041) | [`numeric-profile-applicability-closure.json`](spec/evidence/numeric-profile-applicability-closure.json) | Negative PD-01 slice: 6 MX CUBE selectors rejected for all 25 types with `IllegalInstruction` before effects |
| Variation-point ownership (ADR 0042) | [`numeric-variation-point-ownership.json`](spec/evidence/numeric-variation-point-ownership.json) | All 89 open variation points mapped to 104 numeric operations and 28 hooks; all owned by `pto-numeric-v1` (PD-12 open) |
| Public type baseline (ADR 0043) | [`public-numeric-type-baseline.json`](spec/evidence/public-numeric-type-baseline.json) | 16 published type identities and 16 accepted catalog bindings; A2/A3 (11 types) and A5 (16 types) availability closed; nine catalog types remain outside the public inventory; four legality, vector, parity, and review residuals remain open |
| Integer conversions (ADR 0044) | [`public-integer-conversion-contract.json`](spec/evidence/public-integer-conversion-contract.json) | All 48 unequal-width ordered pairs among the 8 public integer types; 6 PD-07 residuals open |
| Subnormal policy (ADR 0049) | [`numeric-subnormal-contract.json`](spec/evidence/numeric-subnormal-contract.json) | **PD-04 accepted** for the named hardware profile: 11 subnormal-capable formats, gradual underflow, after-rounding tininess, no FTZ/DAZ; 14 domains, 93 operations, 1,023 conditional obligations |
| Special values (ADR 0050) | [`numeric-special-value-contract.json`](spec/evidence/numeric-special-value-contract.json) | Bounded PD-05-SC2 checkpoint: 3 accepted rules across 8 operations and 154 conditional tuples; PD-05 itself open |

Supporting ledgers:
[`numeric-conformance-readiness.json`](spec/evidence/numeric-conformance-readiness.json)
partitions the remaining S5-T2 work across six parallel lanes, keeping every
unavailable profile, oracle, vector, result, and review identity explicit.

## Executable-model comparison (S5-T3)

The independent executable-model comparison is closed with an exhaustive
682-row disposition matrix in
[`spec/evidence/executable-model-comparison.json`](spec/evidence/executable-model-comparison.json):
648 exact matches, 11 explicit divergences, and 23 non-comparable rows. Ten
command divergences are intentional pre-effect rejections; `TTRANS` has no
matching independent operation-manifest row. The clean
content-addressed snapshot passes its generation, validation, documentation,
Sail parser, and Sail C-backend gates.

[`spec/evidence/noncomparable-oracle-coverage.json`](spec/evidence/noncomparable-oracle-coverage.json)
keeps a separate independent-executable-parity grade for the 23 non-comparable
rows. Qualified executable parity is currently 0/23 and fails closed on
structural-only, stale, missing, timed-out, nonzero, or unreviewed evidence.

## Release traceability and gates (S6)

Release traceability is generated rather than inferred from prose.
[`spec/evidence/release-traceability-readiness.json`](spec/evidence/release-traceability-readiness.json)
covers 924 exact units: all 47 requirements, accepted forms and operations,
system registers, traps, 36 profile hooks, and 74 ASL state roots expanded to
233 leaf fields. Its inventory and links are closed, while S6-T1 promotion
remains explicitly open on S5-T2 and an immutable-commit claim-hygiene review.

[`spec/evidence/release-gate-readiness.json`](spec/evidence/release-gate-readiness.json)
closes the S6-T2 manual-gate contract and the exact 34-shard / 110-call /
105-subprogram topology without treating a development run as release proof.
Ten candidate gates and nine retained external controls remain fail-closed
until one signed, immutable post-S5-T2 candidate supplies matching manual
release-validation and repository-control evidence.

## Architecture scope

- 474 scalar forms across AGU, ALU, AMO, BRU, FSU, and SYS.
- 99 bundle/command forms for bundle start, dimension, attributes, IO binding,
  hints, stop, and context handling.
- 109 direct tile operations: 87 TEPL, 10 TLSU, and 12 CUBE (see
  [ADR 0053](docs/architecture-decisions/0053-pto-isa-0580-tile-operation-cleanup.md)).
- Four Tile execution engines: 35 VEC, 52 SFU, 10 TLSU, and 12 CUBE. TEPL is
  the unchanged packed Mode/Function encoding carrier, not an engine (see
  [ADR 0054](docs/architecture-decisions/0054-tile-execution-engine-classification.md)).
- PTO ISA 0.58.0 Mode/Function tile encoding with no untagged legacy decoder.
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
- A named `pto-hardware-numeric-0.58.0-ieee-v1` contract whose independent
  implementation conformance remains open under S5-T2.
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
| [PTO ISA 0.58.0 catalog decision](docs/architecture-decisions/0052-pto-isa-0580-davincioo-catalog.md) | DavinciOO catalog, Mode/Function encoding, documentation, ASL, HTML, and Excel closure |
| [Tile operation cleanup](docs/architecture-decisions/0053-pto-isa-0580-tile-operation-cleanup.md) | TRANDOM removal, TSORT parameterization, four operation restores, and the TMA→TLSU rename |
| [Tile execution-engine classification](docs/architecture-decisions/0054-tile-execution-engine-classification.md) | Exact VEC/SFU/TLSU/CUBE partition while preserving the TEPL encoding carrier |
| [GM byte addressing](docs/architecture-decisions/0058-gm-byte-addressing.md) | TLOAD/TSTORE byte row stride, indexed TLSU byte displacements, and packed indexed-transfer rejection |
| [Memory model](docs/memory-model.md) | PTO-TSO events, relations, axioms, and executable evidence |
| [Profile contracts](docs/profile-contracts.md) | `pto-v0` behavior and alternate-profile obligations |
| [Maturity bring-up plan](docs/maturity-bringup-plan.md) | Staged targets and exit gates from executable draft to architectural completeness |
| [Maturity evaluation and staged targets](docs/maturity-stage-targets.md) | Reviewer-oriented entry gates, measurable targets, exit evidence, and promotion order |
| [Numeric profile decision register](docs/numeric-profile-decision-register.md) | Open S5-T2-A format, rounding, exception, reduction, quantization, and matrix decisions |
| [Modeling conventions](docs/modeling-conventions.md) | ASL organization and normative modeling rules |
| [Formal review checklist](docs/review-checklist.md) | Optional guidance for inspecting normative changes and release evidence |

Accepted architecture decisions are retained under
[`docs/architecture-decisions/`](docs/architecture-decisions/).

## Release validation

Prerequisites are Git, GNU Make, Python 3.11+, OCaml, and an initialized opam
switch. Pull requests have no required checks or approvals. Before publishing a
release, run the complete pinned ASLRef gate manually:

```bash
make release-validate
```

`make release-validate` cleans generated output, prepares ASLRef, runs
`make ci`, and checks diff hygiene. The lower-level targets remain available
for voluntary development and troubleshooting:

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

A substituted binary is not evidence about the audited toolchain pin. Release
validation uses the pinned source wrapper unless the release record explicitly
documents an alternate diagnostic run.

## Repository layout

```text
asl/                     Normative ASL1 sources
  scalar/                Scalar operand, arithmetic, control, memory, atomic, system, and FP semantics
  bundle/                Bundle/command state and semantics
  tile/                  Flat tile state, legality, TEPL, TLSU, and CUBE semantics
  numeric/               Shared numeric format classification
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
