# PTO ISA Formal Specification

[![PR checks](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml/badge.svg?branch=main&event=push)](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml?query=branch%3Amain)
[![Exact-head release verification](https://github.com/PTO-ISA/pto-spec/actions/workflows/release.yml/badge.svg?branch=main)](https://github.com/PTO-ISA/pto-spec/actions/workflows/release.yml)
[![PTO ISA v0.58.1](https://img.shields.io/badge/PTO_ISA-v0.58.1-blue.svg)](https://github.com/PTO-ISA/pto-spec/releases/tag/v0.58.1)
[![License: BSD 3-Clause](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](LICENSE)

`pto-spec` is the normative ASL1 definition of the PTO Instruction Set
Architecture. It specifies a 64-bit scalar ISA, bundle/command forms, direct
tile operations, visible architectural state, legality, faults, completion,
profiles, and memory ordering in one executable model.

The repository is the normative draft of the **PTO ISA 0.58.1** contract at
maturity M4. The release identity fixes the encoding ABI; `pto-v0` is the
deterministic raw-carrier reference profile. Target numeric conformance remains
open under `S5-T2`, and a pending, skipped, failed, stale, or different-commit
release run is never treated as success.

## Start here

| Need | Entry point |
| --- | --- |
| Architecture and programming model | [Architecture reference](docs/arch/overview/architecture.md) |
| Instruction classes and execution engines | [Instruction classification](docs/arch/overview/instruction-classification.md) |
| Block instructions and model | [`docs/block/`](docs/block/) |
| Scalar instructions and model | [`docs/scalar/`](docs/scalar/) |
| Tile instructions and model | [`docs/tile/`](docs/tile/) |
| Encodings and accepted catalogs | [`spec/catalog/`](spec/catalog/) |
| Open architecture questions | [`docs/status/open/`](docs/status/open/) |
| Normative change process | [Contributing](CONTRIBUTING.md) and [Governance](GOVERNANCE.md) |
| Generated maturity and release evidence | [`spec/evidence/`](spec/evidence/) |

The active source chain is deliberately singular:

```text
normative ASL -> generated Markdown mirror -> independent AVS points -> release evidence
```

The current executable inventory contains 474 scalar forms, 74 active block
forms, 109 direct Tile operations, and 32 occupied extension reservations.
Release traceability covers 819 ASL units, 819 generated pages, 3185
independently runnable AVS points, and 642 executable mnemonic requirements.
Detailed numeric, model-comparison, and release-gate ledgers stay
machine-readable under [`spec/evidence/`](spec/evidence/) instead of being
duplicated in this landing page.

## Architecture scope

- 474 scalar forms across AGU, ALU, AMO, BRU, FSU, and SYS.
- 74 active bundle/command forms for bundle start, dimension, attributes, IO
  binding, hints, stop, and context handling, plus 32 occupied extension
  reservations that are rejected by the PTO decoder and unavailable for future
  PTO allocation.
- 109 direct tile operations across seven semantic classes: elementwise
  tile-tile, tile-scalar/immediate, reduce/expand, memory/data movement,
  matrix/matrix-vector, layout/rearrangement, and irregular/complex.
- Four execution engines: 35 VEC, 52 SFU, 10 TLSU, and 12 CUBE operations.
- PTO ISA 0.58.1 Mode/Function tile encoding with 87 operations retaining the
  unchanged TEPL binary carrier, split canonically between `BSTART.VEC` and
  `BSTART.SFU`; `BSTART.TEPL` remains an accepted compatibility spelling.
- A 32-code scalar namespace: 24 absolute GPRs plus four-entry T and U
  temporary queues, eight 32-bit per-warp predicate registers, one independent
  64-bit MPAR/MSEQ execution mask, and 64 flat T/U/M/N tiles.
- 72 architecturally visible system registers, including THREAD_PTR,
  GLOBAL_PTR, BLOCKID, THREAD_ID, CORE_STATE, CORE_ID, and TILE_CAPACITY.
- Visible TPC/BPC bundle state and `TileInfo` state for every tile register.
- A 128-byte architectural CELL, B.IOT allocation size codes from 128 bytes
  through 8 KiB, and aggregate capacity enforced by `TILE_CAPACITY`.
- Explicit Local D destinations for every CUBE operation; `.ACC` variants read
  explicit Local C with read-old/write-new alias behavior and no implicit ACC
  singleton.
- Exact B.DATR data attributes and B.CATR ordering attributes.
- Exact encoding masks, operand fields, constraints, selectors, and rejection
  witnesses generated from machine-readable catalogs.
- Explicit tile and scalar-queue legality before effects.
- Instruction-granular memory completion and restart behavior.
- A concrete `pto-v0` numeric, memory, ACR, reset, and time profile.
- A named `pto-hardware-numeric-0.58.1-ieee-v1` contract whose independent
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

Normative authority and source precedence are defined in [AGENTS.md](AGENTS.md).
The primary review surfaces are:

```text
ASL owner -> generated instruction page -> decision/open metadata -> release evidence
```

| Surface | Role |
| --- | --- |
| [`asl/`](asl/) | Golden executable architectural state, instruction metadata, legality, and semantics |
| [`docs/arch/`](docs/arch/), [`docs/block/`](docs/block/), [`docs/scalar/`](docs/scalar/), [`docs/tile/`](docs/tile/) | Exact ASL mirror with supplementary explanation and examples |
| [`spec/catalog/`](spec/catalog/) | Generated accepted scalar forms, system registers, traps, and tile selectors |
| [`spec/evidence/release-traceability-readiness.json`](spec/evidence/release-traceability-readiness.json) | Generated ASL-to-page-to-AVS requirement traceability |
| [`spec/release-inputs.json`](spec/release-inputs.json) | Explicit canonical release-evidence registry |
| [`spec/profile-hooks.json`](spec/profile-hooks.json) | Complete `impdef` profile registry |
| [`spec/evidence/`](spec/evidence/) | Generated closure records and release evidence |
| [`specification.toml`](specification.toml) | Machine-readable status, profile, architecture, and toolchain metadata |

Human-readable architecture documents supplement the ASL contract. Instruction
pages embed their normative ASL regions verbatim and are checked for drift:

| Document | Purpose |
| --- | --- |
| [Architecture reference](docs/arch/overview/architecture.md) | Generated architecture overview owned by ASL |
| [Instruction classification](docs/arch/overview/instruction-classification.md) | Seven Tile semantic classes, four execution engines, and unchanged TEPL carrier aliases |
| [Block reference](docs/block/) | BSTART, BSTOP, B.* instructions, and block model units |
| [Scalar reference](docs/scalar/) | Scalar instruction and scalar model units |
| [Tile reference](docs/tile/) | PTO-classified tile instructions and tile model units |
| [Direct Tile and bundle catalog decision](docs/status/decisions/0052-direct-tile-and-bundle-catalog-closure.md) | 109-operation catalog, Mode/Function ownership, ASL, generated-page, decoder, and AVS closure |
| [Memory model](docs/arch/memory-model/) | Generated PTO memory-event, ordering, atomicity, and precision contracts |
| [Profiles](docs/arch/profile/) | Generated profile applicability, reset, and reference-profile contracts |

Accepted architecture decisions are retained under
[`docs/status/decisions/`](docs/status/decisions/).

## Validation

Ordinary pull requests run a lightweight, opam-free contract:

```bash
make pr-check
```

This checks NDF structure, the mirrored ASL/docs/tests topology, generated
catalogs, instruction pages and AVS points, script tests, publication hygiene,
and whitespace. It does not run ASLRef and does not claim release readiness.

Full verification is a separate manual exact-head release lane. Dispatch the
`Release verification` workflow with the full 40-character merged commit SHA,
or run its sequential local equivalent with Git, GNU Make, Python 3.11+, OCaml,
and opam available:

```bash
make setup
make release-verify
make release-prepare
```

The release lane runs the pinned ASLRef canaries, strict assembled model, all
ASL shards, and reproducible release evidence. It records results but does not
create a tag or GitHub release. A pending, skipped, failed, stale, or
different-commit result is not success.

## Repository layout

```text
asl/                     Normative ASL1 sources
  arch/                  Architectural state, programming and memory models, data types, profiles, and classification
  block/                 BSTART, BSTOP, B.* instructions, and block model units
  scalar/                Scalar operand, arithmetic, control, memory, atomic, system, and FP semantics
  tile/                  Tile instructions, seven semantic classes, and VEC/TLSU/CUBE/SFU execution
spec/                    Machine-readable catalogs, requirements, profiles, and evidence
tests/
  asl/                   Arch/block/scalar/tile mirror; one independently runnable AVS point per file
  canary/                Pinned ASLRef parser, type-checker, and interpreter canaries
docs/                    Architecture, generated instruction reference, memory model, profiles, evidence policy, and ADRs
scripts/                 Deterministic generation and fail-closed validation
```

ASL source order is generated from each `PTO-UNIT` dependency declaration, and
AVS points are discovered from the mirrored `tests/asl/` tree. No
hand-maintained aggregate source or test list is normative. Generated
assemblies remain ignored under `build/`. Each test filename is a concise
`<group>-<type>-<purpose>-<NNN>.asl` navigation key; its stable global identity
remains in the embedded `PTO-TEST.id` record.

## Contributing and license

Normative changes require a linked NDF architecture issue, stable clause IDs,
focused executable evidence, and exact-head release verification. See [Governance](GOVERNANCE.md) and
[Contributing](CONTRIBUTING.md).

The repository uses the [BSD 3-Clause License](LICENSE). External evidence and
its permitted use are recorded in [NOTICE](NOTICE).
