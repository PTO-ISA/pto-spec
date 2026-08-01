# ADR-0032: Bundle-command totality and PTO-v0 profile boundaries

- Status: Accepted
- Date: 2026-07-30
- Requirements: PTO-REQ-BUNDLE-DISPATCH-001,
  PTO-REQ-BUNDLE-OPERATION-001, PTO-REQ-BUNDLE-STATE-001

## Context

PTO accepts 99 bundle-command forms through 12 semantic handlers. Earlier
closure work proved decode identity, installed operation descriptors, and the
start/header/stop lifecycle. It did not make every retained command total:
some commands recorded placeholder metadata, five constant `B.ARG` forms
collapsed to the same value, `B.HINT` discarded its fields, `MCOPY` and `MSET`
silently truncated their length, and several successful commands retired
without advancing TPC.

The bundle-to-tile bridge also exposes a smaller operand surface than direct
tile dispatch. It can bind `destination0`, `source0`, and `source1`. Of the 120
direct tile operations, 69 use only those fields; the other 51 require an
address, scalar, immediate, additional source, additional destination, or
operation-specific control. Silently defaulting those operands would create a
different instruction from the direct operation.

The content-addressed independent comparison snapshot contains all 99 form IDs.
The generated comparison matrix grades 83 as an executable subset and 16 as
decode-only. Its model stages bundle headers rather than executing tile
payloads. It is useful structural evidence, not normative PTO semantics or a
conformance oracle.

## Decision

### Command retirement

Every successful command retires exactly once. Successful commands other than
bundle start and stop advance TPC by the encoded instruction length. Start and
stop own their control transfer through the bundle lifecycle. A rejected
command leaves TPC at its pre-instruction value; the ordinary architectural
attempt tick and trap entry remain governed by the common dispatch contract.

### Explicit PTO-v0 rejection boundary

PTO-v0 rejects the following handlers with `ILLEGAL_INST` before decoding
their operands or changing command, queue, frame, context, memory, or TPC
state:

- `ESAVE` and `ERCOV`;
- `FENTRY`, `FEXIT`, `FRET.RA`, and `FRET.STK`;
- `HL.QMT`, `HL.QPOP`, and `HL.QPUSH`;
- `XB`.

Their encodings remain inventoried so source reconciliation cannot silently
lose them. Making any handler executable requires a new profile decision that
defines its external layout, permissions, atomicity, fault precedence, and
restart behavior. Internal helper state for these handlers is not an
architectural effect while dispatch rejects the handler before entry.

The generic `BSTART.CUBE` and `BSTART.FIXP` forms also reject in PTO-v0. Named
CUBE starts and the accepted direct tile selectors remain the defined paths;
PTO-v0 does not infer a portable FIXP selector namespace.

### Defined retained effects

All remaining forms have a defined effect:

- the six `B.ARG` forms record distinct three-bit argument kinds; the dynamic
  form additionally records the decoded argument value;
- `B.HINT` records its complete instruction payload and increments the hint
  epoch, but has no scheduling or cache-placement effect in PTO-v0;
- dimension, body-address, scalar binding, tile binding, control-attribute,
  and data-attribute fields are stored without truncation in their named
  bundle state;
- `MCOPY` and `MSET` accept an XLEN length from 0 through 63 bytes, including
  zero length, and reject larger values before memory or last-command state
  changes;
- bundle starts consume their target, return target, operation selector,
  data type, mode, and branch type when those fields are present.

The memory-command bound is a PTO-v0 architectural bound, not a low-bit
encoding rule. A future profile may raise it only with a corresponding
instruction-wide preflight and evidence update.

`B.DIM`, `B.TEXT`, `B.IOR`, `B.IOT`, `B.CATR`, and `B.DATR` consume every
decoded field into trap-preserved bundle state. PTO-v0 tile commit consumes
only B.IOT slot 0 destination/source bindings and the descriptor data type.
The other stored dimensions, scalar bindings, sizes, reuse flags, control
attributes, and data attributes have no tile-payload effect in this profile.
They remain explicit architectural metadata so later profiles cannot assign
behavior without changing the profile contract and adding evidence.

### Bundle-to-tile operand bridge

Commit preflights the selected direct tile operation against the complete
binding requirements. Operations whose catalog operands are a subset of
`destination0`, `source0`, and `source1` may execute after a complete binding
and data-type check. Every other operation rejects with `BUNDLE_CONTROL`
before a tile payload, definedness, memory, or event effect.

The checked bridge inventory is:

| Family | Direct operations | Representable | Commit-rejected |
| --- | ---: | ---: | ---: |
| TEPL | 98 | 63 | 35 |
| TMA | 9 | 1 | 8 |
| CUBE | 13 | 5 | 8 |
| **Total** | **120** | **69** | **51** |

This is an explicit PTO-v0 limitation, not an implicit placeholder. Extending
the bridge requires additional architectural binding state plus complete
fault, alias, and restart evidence.

## Evidence contract

`spec/evidence/bundle-command-totality.json` is generated from the canonical
command and tile catalogs. It contains every command `form_id`, decoded and
consumed fields, retirement disposition, effect class, and all 120 bridge
representability decisions. The repository gate regenerates it and fails on
any catalog or policy drift.

`ValidateCanonicalCommandExecution` executes all 99 canonical form witnesses.
It asserts success or pre-effect rejection, fault identity, and TPC behavior;
it additionally checks descriptor installation, argument kind, and hint
payload where applicable. `TestBundleCommandTotalityBoundaries` covers
unsupported pre-effect rejection, memory-command zero/upper/over-limit cases,
argument-kind distinction, and hint observability. Bundle commit tests cover
representable execution and missing/incompatible binding rollback.

The comparison snapshot has aggregate SHA-256
`1f8862ef90ee72d0e917398b2d96b2799f541f2e7198c103d9fc47af998a54ec`.
Its local modifications and staged payload semantics keep executable comparison open
under `S5-T3`.

## Consequences

- Every accepted command form now reaches a defined effect or explicit
  pre-effect PTO-v0 rejection.
- No command length, argument kind, or hint payload is silently discarded.
- Unsupported frame, context, queue, and cross-block behavior cannot be
  mistaken for implemented architecture.
- Direct tile semantics remain available even when the narrower bundle bridge
  rejects an operation at commit.
- Extending a rejected surface is a versioned profile change with new evidence,
  not an unreviewed relaxation of this contract.
