---
{
  "id": "ADR-BLOCK-0012",
  "title": "Block attributes and lifecycle",
  "title_zh": "Block 属性与生命周期",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "Codex"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "zhoubot"
  ],
  "created": "2026-08-21",
  "accepted": "2026-08-21",
  "rejected": null,
  "superseded": null,
  "baseline": "1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f",
  "target_releases": [
    "0.58.1",
    "0.58.2",
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-B-CATR-CONTROL-001",
    "PTO-B-DATR-FIELDS-001",
    "PTO-B-DIM-WRITE-001",
    "PTO-B-HINT-LIFECYCLE-001",
    "PTO-BSTART-DECISION-BINDING-001",
    "PTO-BSTOP-DECISION-BINDING-001",
    "PTO-C-BSTOP-DECISION-BINDING-001",
    "PTO-CUBE-CELL-TRANSPORT-001",
    "PTO-L-BSTOP-DECISION-BINDING-001",
    "PTO-TCVT-CONTRACT-001",
    "PTO-REQ-INSTRUCTION-DISPATCH-001",
    "PTO-REQ-SCALAR-BODY-ENTRY-001",
    "PTO-FENTRY-RESTARTABLE-FRAME-001",
    "PTO-FEXIT-RESTARTABLE-FRAME-001",
    "PTO-FRET-RA-RESTARTABLE-FRAME-001",
    "PTO-FRET-STK-RESTARTABLE-FRAME-001",
    "PTO-INST-BLOCK-FENTRY",
    "PTO-INST-BLOCK-FEXIT",
    "PTO-INST-BLOCK-FRET-RA",
    "PTO-INST-BLOCK-FRET-STK"
  ],
  "affected_units": [
    "PTO-BLOCK-B-CATR",
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-DIM",
    "PTO-BLOCK-B-HINT",
    "PTO-BLOCK-BSTART",
    "PTO-BLOCK-BSTOP",
    "PTO-BLOCK-C-BSTOP",
    "PTO-BLOCK-L-BSTOP",
    "PTO-TILE-TCVT",
    "PTO-ARCH-DISPATCH-TOP-LEVEL",
    "PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP",
    "PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL",
    "PTO-BLOCK-FENTRY",
    "PTO-BLOCK-FEXIT",
    "PTO-BLOCK-FRET-RA",
    "PTO-BLOCK-FRET-STK",
    "PTO-BLOCK-MODEL-LIFECYCLE-LIFETIME"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-GOV-0006"
  ],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "PRD-001",
    "PRD-002",
    "PRD-003",
    "PRD-004",
    "PRD-005",
    "PRD-006",
    "PRD-007",
    "PRD-008",
    "PRD-009",
    "PRD-010",
    "PRD-011",
    "PRD-012",
    "PRD-013",
    "PRD-014",
    "PRD-015",
    "PRD-016",
    "PRD-017",
    "ADR-0075"
  ],
  "amendments": [
    {
      "date": "2026-09-01",
      "baseline": "8966a3e5a5e2bf5bc1d3264288e3cd315d2e2e32",
      "approvers": [
        "zhoubot"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/191",
      "affected_ndf": [
        "PTO-REQ-INSTRUCTION-DISPATCH-001",
        "PTO-REQ-SCALAR-BODY-ENTRY-001"
      ],
      "affected_units": [
        "PTO-ARCH-DISPATCH-TOP-LEVEL",
        "PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP",
        "PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL"
      ]
    },
    {
      "date": "2026-09-01",
      "baseline": "835ae4dbafd9fd65eda082ba8f83cb0825c9f2c0",
      "approvers": [
        "zhoubot"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/203",
      "affected_ndf": [
        "PTO-FENTRY-RESTARTABLE-FRAME-001",
        "PTO-FEXIT-RESTARTABLE-FRAME-001",
        "PTO-FRET-RA-RESTARTABLE-FRAME-001",
        "PTO-FRET-STK-RESTARTABLE-FRAME-001",
        "PTO-INST-BLOCK-FENTRY",
        "PTO-INST-BLOCK-FEXIT",
        "PTO-INST-BLOCK-FRET-RA",
        "PTO-INST-BLOCK-FRET-STK"
      ],
      "affected_units": [
        "PTO-BLOCK-FENTRY",
        "PTO-BLOCK-FEXIT",
        "PTO-BLOCK-FRET-RA",
        "PTO-BLOCK-FRET-STK",
        "PTO-BLOCK-MODEL-LIFECYCLE-LIFETIME"
      ]
    }
  ]
}
---
# ADR-BLOCK-0012: Block attributes and lifecycle

## Context

ADR 0062 recorded a single repository-wide mnemonic audit. This record preserves the accepted decisions for this family as one decision-scoped owner. The former identifiers remain only in `legacy_ids` and the generated ADR index; current normative meaning is owned by the affected ASL/NDF clauses.

## Decisions

## Decision 001: `B.CATR.DR` selects dimension-reduction mode

`B.CATR.DR` is the dimension-reduction-mode selector. It does not select
dynamic rounding and does not select direct-register addressing.

An encoded `DR=0` selects the default multidimensional mode. An encoded
`DR=1` selects dimension-reduction mode for block operations that define that
mode.

## Decision 002: `B.CATR.trap` requests a post-commit trap

An encoded `trap=1` requests a synchronous post-commit trap. The current
block MUST first commit successfully and atomically. After that commit and
before the selected continuation executes, the processor MUST enter the
architectural trap/context path.

The saved trap context MUST retain the selected continuation, and trap return
MUST resume that continuation. A failed or rejected block commit MUST NOT
generate this post-commit trap.

## Decision 003: `B.CATR.far` selects remote block execution

An encoded `far=0` selects the default behavior: the current block executes on
the initiating core.

An encoded `far=1` marks the current block for remote execution. The remote
destination is selected by the existing routing state; `B.CATR` does not
encode a destination. The block inputs MUST be sent to the selected remote
execution target. After remote execution completes, its results MUST be
returned to the initiating core, and the block MUST commit on that initiating
core.

## Decision 004: `B.CATR.atomic` makes the block one transaction

An encoded `atomic=0` selects normal block execution. An encoded `atomic=1`
makes the entire block one non-interleavable, all-or-nothing architectural
transaction.

The block's memory effects and register-output effects MUST become visible
together or MUST all remain ineffective. An interrupt, exception, or other
fault before successful completion MUST NOT expose a partial result.

## Decision 005: `B.CATR` may appear at most once per block

A block MAY omit `B.CATR`, in which case every control attribute has its
default zero value. A block MUST NOT contain more than one `B.CATR`.

Encountering a second `B.CATR` in the same block MUST raise Illegal Block
Exception before the second instruction changes architectural or pending block
state. Attribute bits from multiple `B.CATR` instructions MUST NOT be merged,
and a later instruction MUST NOT overwrite an earlier one.

## Decision 006: `B.CATR.DR` is limited to group-executed tile engines

An encoded `DR=1` is legal only for a block whose selected execution engine is
`VEC`, `SFU`, or `TLSU`.

An encoded `DR=1` in a `CUBE` block or a non-tile block MUST raise Illegal
Block Exception before architectural or pending block effects. An encoded
`DR=0` selects the default multidimensional mode and introduces no additional
engine restriction.

## Decision 007: omitted and encoded `B.DATR.PadValueOrByteId` are distinct

When an operation consumes `PadValueOrByteId` as a padding-value selector, an
omitted `B.DATR` contribution selects `Null`. Omission MUST NOT be represented
by clearing the encoded field.

An explicitly encoded field has the following complete mapping:

| Code | Padding value |
| ---: | --- |
| `00` | `Zero` |
| `01` | `Max` |
| `10` | `Min` |
| `11` | `Null` |

Operation-specific schemas MAY consume the same two encoded bits for another
defined role, such as a byte selector. An operation that consumes neither role
MUST require the field to be zero.

## Decision 008: `B.DATR.CMode` defines six comparison predicates

`B.DATR.CMode` is a comparison-mode selector. It is not a conversion-mode
selector. Its three-bit allocation is:

| Code | Predicate |
| ---: | --- |
| `000` | `EQ` |
| `001` | `NE` |
| `010` | `LT` |
| `011` | `GT` |
| `100` | `LE` |
| `101` | `GE` |
| `110` | reserved for future extension |
| `111` | reserved for future extension |

Reserved values MUST raise an illegal-instruction fault before effects.

## Decision 009: `B.DATR.Layout` has thirteen assigned transformations

The five-bit `Layout` field has exactly the following assigned values:

| Code | Layout |
| ---: | --- |
| `0` | `NORM` |
| `1` | `ND2DN` |
| `3` | `ND2ZN` |
| `4` | `ND2NZ` |
| `6` | `DN2ND` |
| `8` | `DN2ZN` |
| `9` | `DN2NZ` |
| `17` | `ZN2ND` |
| `18` | `ZN2DN` |
| `20` | `ZN2NZ` |
| `27` | `NZ2ND` |
| `28` | `NZ2DN` |
| `30` | `NZ2ZN` |

Every other five-bit value is reserved for future extension and MUST reject
before effects. Each assigned transformation requires an executable layout
mapping; an implementation-defined placeholder is not sufficient.

## Decision 010: omitted `B.DATR.DataType` inherits the block input type

When an operation-specific schema permits the `B.DATR.DataType` contribution
to be omitted, it inherits the data type selected by the block start. Omission
MUST be tracked independently from the encoded value.

An explicitly encoded zero selects `FP64`; it does not mean inherit. Other
assigned codes select their architecture data types. Reserved codes MUST
reject before effects. Every Tile mnemonic MUST explicitly define the defaults
and supported type subset for each optional field it consumes.

## Decision 011: `Canonicalize` converts CUBE-private output through `TCVT`

`B.DATR.Canonicalize` is an assigned field. `Canonicalize=1` is consumed only
by `TCVT` when converting a CUBE-private output representation into the
standard left-matrix Tile representation, including any data-type-dependent
fractal merge or split required by that conversion.

`Canonicalize=0` disables that conversion. Any other operation carrying a
nonzero `Canonicalize` field MUST reject before effects.

## Decision 012: `B.DATR` may appear at most once per block

A block MAY omit `B.DATR` and use the operation-specific defaults defined for
every data attribute. A block MUST NOT contain more than one `B.DATR`.

Encountering a second `B.DATR` in the same block MUST raise Illegal Block
Exception before the second instruction changes architectural or pending block
state. Multiple `B.DATR` instructions MUST NOT be merged, and a later
instruction MUST NOT overwrite an earlier one.

## Decision 013: `B.DIM.RegSrc` names only an absolute GPR

`B.DIM.RegSrc` codes `0..23` name the twenty-four absolute GPRs, including the
architectural zero register at code zero. Codes `24..31` are reserved in
`B.DIM`; they MUST NOT read either temporary queue and MUST reject as an
illegal instruction before effects.

## Decision 014: `B.DIM` writes the low sixteen bits of base plus immediate

`B.DIM` reads the selected absolute GPR, zero-extends the encoded unsigned
seventeen-bit immediate, and performs the addition at `PTO_XLEN` width. It
writes the low sixteen bits of that sum, zero-extended to the LB storage width,
to the LB selected by the instruction form.

Encoded `RegSrc=0` supplies a zero base and encoded `uimm17=0` supplies a zero
immediate. Neither encoded zero denotes omission.

## Decision 015: each LB may be written at most once per block

Within one block, the combined `B.DIM` and compressed dimension-setting forms
MUST write each of `LB0`, `LB1`, and `LB2` at most once.

An attempt to write an LB that has already been written in the current block
MUST raise Illegal Block Exception before changing the LB or any other pending
or architectural block state. A later write MUST NOT overwrite or merge with
the earlier value.

## Decision 016: `B.HINT` may appear at most once per block header

An ordinary block header MAY contain at most one `B.HINT`, regardless of the
encoded hint form. Encountering a second `B.HINT` in the same block header MUST
raise Illegal Block Exception before the second instruction changes pending or
architectural state. Multiple hints MUST NOT be merged, and a later hint MUST
NOT overwrite an earlier hint.

## Decision 017: `B.HINT.TRACE` opens an empty block without auto-termination

The TRACE form is a special block-start operation. Its `B/E` field selects the
trace boundary: zero begins a traced region and one ends it. Executing the form
opens an empty block and records the selected boundary.

The TRACE form MUST NOT complete or commit the empty block by itself. The block
MUST subsequently be terminated by `BSTOP` or by the next `BSTART`, following
the normal block lifecycle and commit rules.

## Lifecycle corrections

The first successfully decoded scalar form in an active header enters the
bundle body before operation applicability and operand legality are checked.
An unmatched scalar encoding does not enter the body. Empty blocks remain
committable through `BSTOP` or a following `BSTART` without synthesizing a body
instruction.

`FENTRY`, `FEXIT`, `FRET.RA`, and `FRET.STK` use the architectural `sp`, GPR1,
for all implicit stack accesses. The earlier GPR2 use was an ASL and fixture
bug under the existing register map.

Issue [#191](https://github.com/PTO-ISA/pto-spec/issues/191) records the body
entry interface, while [#203](https://github.com/PTO-ISA/pto-spec/issues/203)
records the direct stack-pointer implementation correction. Selected-path
installation for following `BSTART` and TRACE boundaries remains owned by
ADR-BLOCK-0009.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Block headers combine control attributes, data attributes, dimensions, hints, entry, and termination. The audit needed to close each field's meaning and lifecycle so that omitted values, repeated commands, illegal combinations, and restart behavior are deterministic.

Block 头组合控制属性、数据属性、维度、提示、进入与终止。审计需要闭合每个字段的含义和生命周期，使省略值、重复命令、非法组合及重启行为均可确定。

### Detailed decision / 详细决策

The numbered decisions define `B.CATR`, `B.DATR`, `B.DIM`, and `B.HINT` applicability, defaults, uniqueness, and effects, then bind those attributes to start/stop and frame lifecycle. They distinguish omitted values from explicit encodings, constrain operation-specific fields, and require legality checks before architectural publication.

编号决策定义 `B.CATR`、`B.DATR`、`B.DIM` 和 `B.HINT` 的适用性、默认值、唯一性及效果，并把这些属性绑定到启动/停止和帧生命周期。它们区分省略值与显式编码，限制操作特定字段，并要求在架构发布前完成合法性检查。

### What changed / 改动内容

#### English

- Closed attribute field meanings, defaults, multiplicity, and operation applicability.
- Connected header state to deterministic Block and frame lifecycle behavior.

#### 中文

- 闭合属性字段含义、默认值、出现次数及操作适用性。
- 将头状态连接到确定的 Block 与帧生命周期行为。

### Scope and boundaries / 范围与边界

This record owns the listed header and lifecycle decisions. It does not restate selected-path installation owned by ADR-BLOCK-0009 or operation arithmetic owned by the affected instruction units.

本记录管理所列头部与生命周期决策；不重述 ADR-BLOCK-0009 管理的 selected-path 安装，也不定义受影响指令单元负责的算术语义。
