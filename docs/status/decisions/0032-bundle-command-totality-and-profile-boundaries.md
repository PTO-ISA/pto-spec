# ADR-0032: Bundle-command totality and PTO-v0 profile boundaries

- Status: Accepted
- Date: 2026-07-30
- Requirements: PTO-REQ-BUNDLE-DISPATCH-001,
  PTO-REQ-BUNDLE-OPERATION-001, PTO-REQ-BUNDLE-STATE-001

Current release inventory is governed by ADR 0062; numeric inventories below
are acceptance-time history, not the current active decoder set.

## Context

When this decision was accepted, PTO inventoried 100 bundle-command forms
through 22 semantic handlers. Ninety forms used 12 executable handlers; ten
forms mapped to unsupported handlers and rejected before effects. Earlier
closure work proved decode identity, installed operation descriptors, and the
start/header/stop lifecycle. It did not make every retained command total:
some commands recorded placeholder metadata, five constant `B.ARG` forms
collapsed to the same value, `B.HINT` discarded its fields, `MCOPY` and `MSET`
silently truncated their length, and several successful commands retired
without advancing TPC.

The original bundle-to-tile bridge exposed a smaller operand surface than
direct tile dispatch. ADR 0055 supersedes that limitation: a complete bundle
now resolves ordered tile and GPR bindings, bundle-header operands, and the
selected operation's architectural defaults before commit. This preserves the
direct-operation schema without inventing values at execution time.

## Decision

### Command retirement

Every successful command retires exactly once. Successful commands other than
bundle start and stop advance TPC by the encoded instruction length. Start and
stop own their control transfer through the bundle lifecycle. A rejected
command leaves TPC at its pre-instruction value; the ordinary architectural
attempt tick and trap entry remain governed by the common dispatch contract.

### Historical PTO-v0 rejection boundary

The rejection list below records the boundary when this ADR was accepted.
ADR 0062 PRD-149 through PRD-159 subsequently define these mnemonics as formal
PTO instructions; the current ASL MUST execute those accepted contracts rather
than apply this historical rejection rule.

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
- `MSET` accepts an XLEN length from 0 through 63 bytes, including zero
  length, and rejects larger values before memory or last-command state
  changes;
- PRD-152 supersedes the former `MCOPY` 63-byte bound and snapshot rule:
  `MCOPY` accepts its complete XLEN length, rejects wrapping or overlapping
  ranges before effects, and uses trap-preserved restartable memory steps;
- `MSET` reads destination, fill value, and byte length only from absolute
  GPR selectors `0..23`; selector codes `24..31` are reserved and reject
  before any register, memory, reservation, last-command, or TPC effect;
- bundle starts consume their target, return target, operation selector,
  data type, mode, and branch type when those fields are present.

The `MSET` bound is an architectural bound, not a low-bit encoding rule. A
future profile may raise it only with a corresponding instruction-wide
preflight and evidence update. `MCOPY` has no such byte-count bound.

`B.DIM`, `B.IOR`, `B.IOT`, `B.IOS`, `B.CATR`, and `B.DATR` consume every
decoded field into trap-preserved bundle state. PTO-v0 tile commit resolves
their schema-contributing values after the full bundle is collected. Missing
optional operands use the defaults defined by the selected operation; surplus
or incompatible bindings reject before effects.

### Bundle-to-tile operand bridge

Commit preflights the selected direct tile operation against its complete
schema. Ordered B.IOT entries provide all required tile destinations and
sources, B.IOR provides the operation's consumed GPR inputs, other bundle
headers provide their named controls, and the operation defines defaults for
omitted optional operands. All 109 accepted direct tile operations are
schema-representable. Malformed, missing-required, surplus, or incompatible
bindings reject before a tile payload, definedness, memory, or event effect.

The checked bridge inventory is:

| Family | Direct operations | Representable | Commit-rejected |
| --- | ---: | ---: | ---: |
| TEPL | 87 | 87 | 0 |
| TLSU | 10 | 10 | 0 |
| CUBE | 12 | 12 | 0 |
| **Total** | **109** | **109** | **0** |

This representability statement means only that the PTO bundle schema can
construct every canonical direct operation without changing that operation's
encoding or semantics.

## Evidence contract

`spec/evidence/bundle-command-totality.json` is generated from the canonical
command and tile catalogs. It contains every command `form_id`, decoded and
consumed fields, retirement disposition, effect class, and all 109 bridge
representability decisions. The repository gate regenerates it and fails on
any catalog or policy drift.

`ValidateCanonicalCommandExecution` executes all 74 active canonical form
witnesses.
It asserts success or pre-effect rejection, fault identity, and TPC behavior;
it additionally checks descriptor installation, argument kind, and hint
payload where applicable. `TestBundleCommandTotalityBoundaries` covers
unsupported pre-effect rejection, memory-command zero/upper/over-limit cases,
argument-kind distinction, and hint observability. Bundle commit tests cover
representable execution and missing/incompatible binding rollback.

## Consequences

- Every active command form now reaches a defined formal effect. Occupied
  extension reservations reject outside the active command-form decoder.
- No command length, argument kind, or hint payload is silently discarded.
- Frame, context, queue, and cross-block behavior is implemented only where
  accepted by ADR 0062; reserved extension spellings cannot be mistaken for
  PTO instructions.
- Direct tile and bundle commit use the same canonical operation schemas.
- Future operands require a catalog/default update and executable evidence;
  they cannot silently inherit an unrelated header field.
