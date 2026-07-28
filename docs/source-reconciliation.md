# Public source reconciliation

This review reconciles the accepted PTO direct binary architecture with the
public PTO source API without importing private text or treating another ISA as
normative. The complete machine-readable result is
`spec/evidence/public-source-reconciliation.json`.

## Audited public baseline

The public baseline is
[`hw-native-sys/pto-isa` commit `712cbe9f`](https://github.com/hw-native-sys/pto-isa/tree/712cbe9f23df5d5362be5e8327599f4285317473).
The ledger records SHA-256 hashes for the public intrinsic header, source-order
policy, current ISA scope, PTO-AS model, shared scalar arithmetic page, and
scalar/control family page. It also records an independently audited 111-symbol
tile intrinsic inventory tied to the header hash. The pinned public source says that its C++ header is
the public intrinsic contract and that PTO-AS, SSA, and DPS are source and
lowering layers for the same public operations.

This repository has a narrower responsibility: exact binary forms, direct tile
selectors, architectural state, legality, faults, completion, and ordering.

## Closure summary

| Surface | Accepted | Public disposition | Open |
| --- | ---: | --- | ---: |
| Scalar binary forms | 473 | every form classified by source layer; a one-to-one public source mnemonic is not required | 0 |
| Direct tile operations | 111 | 110 exact public intrinsic names and one documented `TSORT` → `TSORT32` spelling map | 0 |
| Raw private tile cross-check | 111 | 97 agree, 13 incomplete, 1 conflict; raw observations preserved | 14 raw observations |
| Public closure of raw non-agreements | 14 | 8 public-API alignments and 6 explicit source/binary layer differences | 0 |

“Closed” means PTO has an explicit, public, reviewable disposition. It does not
rewrite an incomplete private page as agreement or claim that typed C++
parameters are binary operand fields.

## Raw non-agreement dispositions

| Operation | Raw result | Public closure |
| --- | --- | --- |
| `TAXPY` | incomplete | Public destination, source, and scalar roles align. |
| `TPREFETCH` | conflict | The typed API carries a destination-shaped lowering context; the direct hint remains destination-free and writes no tile state. |
| `TDEQUANT` | incomplete | Public scale/offset tiles and direct scalar scale/zero-point operands are an explicit layer difference. |
| `TCONCAT` | incomplete | The typed API derives layout and offers index-tile overloads; the direct form carries an axis. |
| `TDEINTERLEAVE` | incomplete | A public overload aligns with two direct destinations and one source. |
| `TINTERLEAVE` | incomplete | The typed API has two destinations; the direct form has one destination and two sources. |
| `TSORT` | incomplete | The public spelling is `TSORT32` with index/temporary tiles; the direct form is `TSORT` with a descending flag. |
| `THISTOGRAM` | incomplete | Destination, source, indices, and selected-byte roles align. |
| `TPARTARGMAX` | incomplete | Value/index destinations and left/right value/index sources align. |
| `TPARTARGMIN` | incomplete | Value/index destinations and left/right value/index sources align. |
| `TPUSH` | incomplete | Typed pipe and tile/global producer overloads align with direct pipe push behavior. |
| `TPOP` | incomplete | Typed pipe and tile consumer overloads align with direct pipe pop behavior. |
| `TALLOC` | incomplete | The typed API takes a GlobalTensor and returns an event; the direct form claims a slot and returns its address. |
| `TFREE` | incomplete | Typed pipe and optional global-resource release overloads align with direct pipe release behavior. |

## Scalar forms and external ISA comparisons

The public PTO source layer deliberately uses shared MLIR `arith` and
scalar/control operations. The 473 scalar catalog rows are direct binary forms,
so absence of identical public intrinsic spelling is not missing binary
semantics. Each form remains traceable to executable ASL through its catalog
handler and tests.

Arm ASL is useful for finding questions, especially load/store destination and
writeback overlap. It is not an authority for PTO behavior. The comparison led
to PTO-owned family constraints in ADR-0004; all retained rules are expressed
in the PTO catalog, generated legality checks, and positive/negative ASL tests.
No constraint is inferred from a shared mnemonic alone.

The concrete comparison questions, official Arm references, retained PTO rules,
and non-import decisions are recorded in `docs/arm-asl-comparison.md`. That
bounded artifact closes the requested review trail without treating Arm as a
PTO source or claiming an exhaustive instruction mapping.

## Reproduction and change control

Run:

```bash
scripts/generate-public-source-reconciliation --check
make repo-check
```

To audit the public snapshot, fetch the pinned commit and compare each listed
path's SHA-256 hash. A later public PTO revision requires a deliberate pin
update, regenerated ledger, review of every changed disposition, and the full
CI gate.
