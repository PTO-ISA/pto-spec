---
{
  "id": "ADR-TILE-0004",
  "title": "Bundle-command totality and PTO-v0 profile boundaries",
  "title_zh": "Bundle 命令完备性与 PTO-v0 profile 边界",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "Codex"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "zhoubot"
  ],
  "created": "2026-07-30",
  "accepted": "2026-07-30",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned",
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-B-CATR-CONTROL-001",
    "PTO-B-DATR-FIELDS-001",
    "PTO-B-DIM-WRITE-001",
    "PTO-B-FPATR-MATRIX-POSTPROCESS-001",
    "PTO-B-HINT-LIFECYCLE-001",
    "PTO-B-IOR-BINDING-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-BARG-CONTINUATION-001",
    "PTO-BLOCK-ERCOV-RESERVED-001",
    "PTO-BLOCK-ESAVE-RESERVED-001",
    "PTO-BLOCK-MSET-FILL-001",
    "PTO-BLOCK-XB-RESERVED-001",
    "PTO-BSTART-CALL-DECISION-BINDING-001",
    "PTO-BSTART-DECISION-BINDING-001",
    "PTO-BSTART-FP-CONTROL-001",
    "PTO-BSTART-GMOV-COLLECTIVE-001",
    "PTO-BSTART-ICALL-DECISION-BINDING-001",
    "PTO-BSTART-MGATHER-CAS-SCHEMA-001",
    "PTO-BSTART-MGATHER-MASK-SCHEMA-001",
    "PTO-BSTART-MGATHER-SCHEMA-001",
    "PTO-BSTART-MSCATTER-MASK-SCHEMA-001",
    "PTO-BSTART-MSCATTER-SCHEMA-001",
    "PTO-BSTART-SFU-DECISION-BINDING-001",
    "PTO-BSTART-STD-CONTROL-001",
    "PTO-BSTART-SYS-CONTROL-001",
    "PTO-BSTART-TEPL-DECISION-BINDING-001",
    "PTO-BSTART-TGEMV-ACC-CONTRACT-001",
    "PTO-BSTART-TGEMV-BIAS-CONTRACT-001",
    "PTO-BSTART-TGEMV-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-ACC-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-BIAS-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-CONTRACT-001",
    "PTO-BSTART-TLOAD-CUBE-001",
    "PTO-BSTART-TLOAD-MEMORY-001",
    "PTO-BSTART-TMATMUL-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMUL-BIAS-CONTRACT-001",
    "PTO-BSTART-TMATMUL-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-BIAS-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-CONTRACT-001",
    "PTO-BSTART-TMOV-SHARED-001",
    "PTO-BSTART-TPREFETCH-MEMORY-001",
    "PTO-BSTART-TSTORE-CUBE-001",
    "PTO-BSTART-TSTORE-MEMORY-001",
    "PTO-BSTART-VEC-DECISION-BINDING-001",
    "PTO-BSTOP-DECISION-BINDING-001",
    "PTO-C-BSTART-CONTROL-001",
    "PTO-C-BSTART-FP-CONTROL-001",
    "PTO-C-BSTART-STD-CONTROL-001",
    "PTO-C-BSTART-SYS-CONTROL-001",
    "PTO-C-BSTOP-DECISION-BINDING-001",
    "PTO-CUBE-CELL-TRANSPORT-001",
    "PTO-FENTRY-RESTARTABLE-FRAME-001",
    "PTO-FEXIT-RESTARTABLE-FRAME-001",
    "PTO-FRET-RA-RESTARTABLE-FRAME-001",
    "PTO-FRET-STK-RESTARTABLE-FRAME-001",
    "PTO-HL-QMT-GQM-001",
    "PTO-HL-QPOP-GQM-001",
    "PTO-HL-QPUSH-GQM-001",
    "PTO-L-BSTOP-DECISION-BINDING-001",
    "PTO-MCOPY-RESTART-001",
    "PTO-REQ-BUNDLE-STATE-001",
    "PTO-INST-BLOCK-MSET"
  ],
  "affected_units": [
    "PTO-BLOCK-B-CATR",
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-DIM",
    "PTO-BLOCK-B-FPATR",
    "PTO-BLOCK-B-HINT",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-BSTART",
    "PTO-BLOCK-BSTART-CALL",
    "PTO-BLOCK-BSTART-FP",
    "PTO-BLOCK-BSTART-GMOV",
    "PTO-BLOCK-BSTART-ICALL",
    "PTO-BLOCK-BSTART-MGATHER",
    "PTO-BLOCK-BSTART-MGATHER-CAS",
    "PTO-BLOCK-BSTART-MGATHER-MASK",
    "PTO-BLOCK-BSTART-MSCATTER",
    "PTO-BLOCK-BSTART-MSCATTER-MASK",
    "PTO-BLOCK-BSTART-SFU",
    "PTO-BLOCK-BSTART-STD",
    "PTO-BLOCK-BSTART-SYS",
    "PTO-BLOCK-BSTART-TEPL",
    "PTO-BLOCK-BSTART-TGEMV",
    "PTO-BLOCK-BSTART-TGEMV-ACC",
    "PTO-BLOCK-BSTART-TGEMV-BIAS",
    "PTO-BLOCK-BSTART-TGEMVMX",
    "PTO-BLOCK-BSTART-TGEMVMX-ACC",
    "PTO-BLOCK-BSTART-TGEMVMX-BIAS",
    "PTO-BLOCK-BSTART-TLOAD",
    "PTO-BLOCK-BSTART-TMATMUL",
    "PTO-BLOCK-BSTART-TMATMUL-ACC",
    "PTO-BLOCK-BSTART-TMATMUL-BIAS",
    "PTO-BLOCK-BSTART-TMATMULMX",
    "PTO-BLOCK-BSTART-TMATMULMX-ACC",
    "PTO-BLOCK-BSTART-TMATMULMX-BIAS",
    "PTO-BLOCK-BSTART-TMOV",
    "PTO-BLOCK-BSTART-TPREFETCH",
    "PTO-BLOCK-BSTART-TSTORE",
    "PTO-BLOCK-BSTART-VEC",
    "PTO-BLOCK-BSTOP",
    "PTO-BLOCK-C-B-DIMI",
    "PTO-BLOCK-C-BSTART",
    "PTO-BLOCK-C-BSTART-FP",
    "PTO-BLOCK-C-BSTART-STD",
    "PTO-BLOCK-C-BSTART-SYS",
    "PTO-BLOCK-C-BSTOP",
    "PTO-BLOCK-ERCOV",
    "PTO-BLOCK-ESAVE",
    "PTO-BLOCK-FENTRY",
    "PTO-BLOCK-FEXIT",
    "PTO-BLOCK-FRET-RA",
    "PTO-BLOCK-FRET-STK",
    "PTO-BLOCK-HL-QMT",
    "PTO-BLOCK-HL-QPOP",
    "PTO-BLOCK-HL-QPUSH",
    "PTO-BLOCK-L-BSTOP",
    "PTO-BLOCK-MCOPY",
    "PTO-BLOCK-MODEL-COMMIT-EFFECTS",
    "PTO-BLOCK-MODEL-COMMIT-VALIDATION",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-DESTINATION",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
    "PTO-BLOCK-MODEL-DISPATCH-DECODE",
    "PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY",
    "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE",
    "PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-GENERATION-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-NUMERIC-CONTROL",
    "PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
    "PTO-BLOCK-MODEL-DISPATCH-START",
    "PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER-MASK",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH",
    "PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL",
    "PTO-BLOCK-MODEL-FAULTS-ROLLBACK",
    "PTO-BLOCK-MODEL-LIFECYCLE-BEGIN",
    "PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP",
    "PTO-BLOCK-MODEL-LIFECYCLE-LIFETIME",
    "PTO-BLOCK-MODEL-LIFECYCLE-RESET",
    "PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS",
    "PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS",
    "PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES",
    "PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS",
    "PTO-BLOCK-MODEL-SCHEMA-HEADER",
    "PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING",
    "PTO-BLOCK-MODEL-STATE-BARG",
    "PTO-BLOCK-MODEL-STATE-BINDING-STATE",
    "PTO-BLOCK-MODEL-STATE-CONTROL-STATE",
    "PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-BLOCK-MSET",
    "PTO-BLOCK-XB",
    "PTO-SCALAR-MODEL-AGU-MEMORY"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0032"
  ],
  "amendments": [
    {
      "date": "2026-09-01",
      "baseline": "27f41909deffce3be07360a0c82e5a7f28e6e468",
      "approvers": [
        "zhoubot"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/198",
      "affected_ndf": [
        "PTO-BLOCK-MSET-FILL-001",
        "PTO-INST-BLOCK-MSET"
      ],
      "affected_units": [
        "PTO-BLOCK-MSET",
        "PTO-BLOCK-MODEL-COMMIT-EFFECTS",
        "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
        "PTO-SCALAR-MODEL-AGU-MEMORY"
      ]
    }
  ]
}
---
# ADR-TILE-0004: Bundle-command totality and PTO-v0 profile boundaries

> Inventory counts in this record are acceptance-time historical context; the current inventory is owned by the ASL tree and its generated projections.

- Date: 2026-07-30
- Requirements: PTO-REQ-BUNDLE-DISPATCH-001,
  PTO-REQ-BUNDLE-OPERATION-001, PTO-REQ-BUNDLE-STATE-001

Current release inventory is governed by ASL and generated projections;
numeric inventories below are acceptance-time history, not the current active
decoder set.

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
Decisions 149 through 159 in ADR 0084 subsequently define these mnemonics as formal
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
- `MSET` consumes the complete unsigned XLEN byte length. Zero remains a
  successful memory-free no-op; every non-wrapping range proceeds through the
  ordinary data-access checks, and a fixed reference-model bound is not an ISA
  legality limit;
- Decision 152 in ADR 0084 supersedes the former `MCOPY` 63-byte bound and
  snapshot rule:
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
  accepted by ADR 0084; reserved extension spellings cannot be mistaken for
  PTO instructions.
- Direct tile and bundle commit use the same canonical operation schemas.
- Future operands require a catalog/default update and executable evidence;
  they cannot silently inherit an unrelated header field.

Issue [#198](https://github.com/PTO-ISA/pto-spec/issues/198) records the MSET
correction. The removed 63-byte ceiling was a bounded-model implementation
artifact and therefore did not allocate a new ADR.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Bundle commands were accepted across several carriers before all header fields, operand bridges, retained effects, retired commands, and rejection paths were closed. Totality was required so every decoded command either performs one defined transaction or rejects without effects.

多个 Bundle 命令在头字段、操作数桥接、保留效果、退役命令和拒绝路径全部闭合前已被接受。必须实现完备性，使每条解码命令要么执行一个已定义事务，要么无副作用拒绝。

### Detailed decision / 详细决策

The decision retires the listed unsupported command forms, states the historical PTO-v0 rejection boundary, preserves explicitly retained lifecycle effects, and defines how Bundle binders become Tile-operation operands. Complete schema, type, descriptor, mask, capacity, and allocation checks precede snapshots and atomic publication.

本决策退役所列不受支持命令，说明历史 PTO-v0 拒绝边界，保留明确列出的生命周期效果，并定义 Bundle 绑定如何转化为 Tile 操作数。完整模式、类型、描述符、掩码、容量和分配检查先于快照与原子发布。

### What changed / 改动内容

#### English

- Closed decoded command behavior, retirement status, rejection behavior, and unsupported command forms.
- Defined the common Bundle-to-Tile operand resolution and transactional publication boundary.
- Kept operation-specific numeric results outside the generic command carrier while preserving fail-closed dispatch.

#### 中文

- 闭合解码命令行为并退役不受支持形式。
- 定义通用 Bundle 到 Tile 的操作数与事务边界。

### Scope and boundaries / 范围与边界

This historical ADR records the command-totality boundary in its accepted terminology. It does not independently define numeric results or authorize unrelated header fields for an operation.

本历史 ADR 以接受时术语记录命令完备性边界；不独立定义数值结果，也不授权操作使用无关头字段。
