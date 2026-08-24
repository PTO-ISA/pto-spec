# PTO ISA Formal Specification

[![PR checks](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml/badge.svg?branch=main&event=push)](https://github.com/PTO-ISA/pto-spec/actions/workflows/asl.yml?query=branch%3Amain)
[![Exact-head release verification](https://github.com/PTO-ISA/pto-spec/actions/workflows/release.yml/badge.svg?branch=main)](https://github.com/PTO-ISA/pto-spec/actions/workflows/release.yml)
[![PTO ISA v0.58.4](https://img.shields.io/badge/PTO_ISA-v0.58.4-blue.svg)](https://github.com/PTO-ISA/pto-spec/releases/tag/v0.58.4)
[![License: BSD 3-Clause](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](LICENSE)

`pto-spec` is the executable ASL1 specification of the PTO Instruction Set
Architecture. It defines a 64-bit scalar ISA, bundle and command forms, direct
Tile operations, architectural state, legality, faults, completion, profiles,
and memory ordering in one reviewable model.

The working tree is a normative draft and may contain architecture changes for
a future release. PTO ISA v0.58.4 is the latest published release; release
identity is bound to an immutable commit and its reproducible formal evidence.

## PTO ISA at a glance

| Surface | Current executable inventory |
| --- | ---: |
| Scalar instruction forms | 466 |
| Active bundle and command forms | 76 |
| Direct Tile operations | 109 |
| Tile execution engines | 4 |
| Tile semantic classes | 7 |
| Architecture and instruction ASL units | 849 |
| Independently runnable AVS points | 3,675 |

Direct Tile operations select one of four execution engines: 35 VEC operations,
10 TLSU operations, 12 CUBE operations, and 52 SFU operations. Classification
is independent of engine selection, so programming intent and execution
placement remain separate architecture concepts.

The generated [release-traceability view](spec/evidence/release-traceability-readiness.json)
contains the complete ASL-to-documentation-to-AVS inventory for the current
tree.

## Architecture scope

PTO ISA specifies:

- a 64-bit scalar execution surface covering address generation, integer and
  logical operations, atomics, branches, floating-point support, and system
  operations;
- a 32-code scalar register namespace with 24 absolute GPRs and T/U temporary
  queues, plus predicate state and an independent execution mask;
- bundle-visible program-control, argument, dimension, data-attribute,
  ordering-attribute, IO-binding, and completion state;
- 64 flat T/U/M/N Tile registers with explicit Local and Shared ownership,
  allocation, descriptors, valid regions, and definedness;
- direct Tile operations for elementwise computation, reductions and expands,
  memory and data movement, matrix and matrix-vector work, layout changes, and
  irregular operations;
- exact instruction masks, fields, constraints, selector values, decoder
  witnesses, and architectural effects;
- explicit legality and fault ordering before effects, including aliasing,
  rollback, restart, and instruction-granular memory completion;
- named profiles for behavior that is not portable across implementations.

Hardware pipelines, physical Tile allocation, backend intrinsics, latency,
throughput, and target scheduling are outside the portable PTO ISA contract.

## Instruction families

| Family | What it defines | Reference |
| --- | --- | --- |
| Architecture | Public types, state, profiles, memory model, traps, and classification | [`docs/arch/`](docs/arch/) |
| Block | `BSTART`, `BSTOP`, bundle configuration, bindings, and block execution | [`docs/block/`](docs/block/) |
| Scalar | AGU, ALU, AMO, BRU, FSU, SYS, compressed, half-long, and long forms | [`docs/scalar/`](docs/scalar/) |
| Tile | Direct Tile operations and VEC, TLSU, CUBE, and SFU behavior | [`docs/tile/`](docs/tile/) |

The `B` prefix denotes a bundle instruction. `BLOCKNUM`, `BLOCKID`, and
`CROSS_BID` instead describe virtual core-block topology. These concepts share
spelling history but represent different architectural state.

## Start reading

Start with the [architecture overview](docs/arch/overview/architecture.md), then
use the [instruction classification](docs/arch/overview/instruction-classification.md)
to understand the seven Tile classes and four execution engines. The block,
scalar, and Tile references above contain generated ASL mirrors and bounded
supplementary explanation.

Machine-readable accepted forms and selectors live under
[`spec/catalog/`](spec/catalog/). Current architecture gaps are listed under
[`docs/status/open/`](docs/status/open/), while accepted decision history is
kept under [`docs/status/decisions/`](docs/status/decisions/). Release identities
and evidence entry points are collected in the
[release hub](docs/releases/index.md).

## Quick start

The lightweight development path needs Git, GNU Make, and Python 3.11 or newer:

```bash
git clone --recurse-submodules https://github.com/PTO-ISA/pto-spec.git
cd pto-spec
make pr-check
```

See [Getting started](docs/development/getting-started.md) for environment setup,
the full formal-validation prerequisites, and troubleshooting. The
[repository layout](docs/development/repository-layout.md) maps each source,
generated projection, and executable evidence surface to its owner.

## Project policy

Current architectural meaning has one source chain:

```text
ASL/NDF owner -> generated Markdown mirror -> AVS -> commit-scoped evidence
```

ADRs record why an architectural choice was accepted, rejected, or superseded;
they do not redefine current ISA behavior. The [ADR process](docs/governance/adr-process.md)
describes that boundary. Contributor commands and exact-commit release rules
are documented in [Validation](docs/governance/validation.md), not duplicated
on this landing page.

Read [Contributing](CONTRIBUTING.md) before changing ASL, tests, generators, or
documentation. The project uses the [BSD 3-Clause License](LICENSE); permitted
external evidence and attribution are recorded in [NOTICE](NOTICE).
