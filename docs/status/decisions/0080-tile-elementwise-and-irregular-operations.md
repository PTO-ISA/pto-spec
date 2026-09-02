---
{
  "id": "ADR-0080",
  "title": "Tile elementwise and irregular operations",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "Codex",
    "PTO ISA maintainers"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "PTO ISA maintainers"
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
    "PTO-B-DATR-FIELDS-001",
    "PTO-B-IOR-BINDING-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-BSTART-SFU-DECISION-BINDING-001",
    "PTO-BSTART-TEPL-DECISION-BINDING-001",
    "PTO-BSTART-VEC-DECISION-BINDING-001",
    "PTO-CUBE-CELL-TRANSPORT-001",
    "PTO-TABS-CONTRACT-001",
    "PTO-TADD-CONTRACT-001",
    "PTO-TAND-CONTRACT-001",
    "PTO-TCMP-CONTRACT-001",
    "PTO-TCVT-CONTRACT-001",
    "PTO-TDIV-CONTRACT-001",
    "PTO-TEXP-CONTRACT-001",
    "PTO-TEXTRACT-CONTRACT-001",
    "PTO-TFMA-CONTRACT-001",
    "PTO-TIMG2COL-CONTRACT-001",
    "PTO-TINSERT-CONTRACT-001",
    "PTO-TLOG-CONTRACT-001",
    "PTO-TMAX-CONTRACT-001",
    "PTO-TMIN-CONTRACT-001",
    "PTO-TMOV-CONTRACT-001",
    "PTO-TMUL-CONTRACT-001",
    "PTO-TNEG-CONTRACT-001",
    "PTO-TNOT-CONTRACT-001",
    "PTO-TOR-CONTRACT-001",
    "PTO-TRECIP-CONTRACT-001",
    "PTO-TRELU-CONTRACT-001",
    "PTO-TREM-CONTRACT-001",
    "PTO-TRSQRT-CONTRACT-001",
    "PTO-TSEL-CONTRACT-001",
    "PTO-TSHL-CONTRACT-001",
    "PTO-TSHR-CONTRACT-001",
    "PTO-TSQRT-CONTRACT-001",
    "PTO-TSUB-CONTRACT-001",
    "PTO-TXOR-CONTRACT-001",
    "PTO-TILE-CARRIER-REINTERPRETATION-001",
    "PTO-INST-BLOCK-BSTART-TMOV",
    "PTO-INST-TILE-TADD",
    "PTO-INST-TILE-TSUB",
    "PTO-INST-TILE-TMUL",
    "PTO-INST-TILE-TDIV",
    "PTO-INST-TILE-TREM",
    "PTO-INST-TILE-TMAX",
    "PTO-INST-TILE-TMIN",
    "PTO-INST-TILE-TABS",
    "PTO-INST-TILE-TNEG",
    "PTO-INST-TILE-TRELU",
    "PTO-INST-TILE-TRECIP",
    "PTO-INST-TILE-TRSQRT",
    "PTO-INST-TILE-TSQRT",
    "PTO-INST-TILE-TEXP",
    "PTO-INST-TILE-TLOG",
    "PTO-INST-TILE-TADDS",
    "PTO-INST-TILE-TSUBS",
    "PTO-INST-TILE-TMULS",
    "PTO-INST-TILE-TDIVS",
    "PTO-INST-TILE-TREMS",
    "PTO-INST-TILE-TMAXS",
    "PTO-INST-TILE-TMINS",
    "PTO-INST-TILE-TAND",
    "PTO-INST-TILE-TANDS",
    "PTO-INST-TILE-TOR",
    "PTO-INST-TILE-TORS",
    "PTO-INST-TILE-TXOR",
    "PTO-INST-TILE-TXORS",
    "PTO-INST-TILE-TSHL",
    "PTO-INST-TILE-TSHLS",
    "PTO-INST-TILE-TSHR",
    "PTO-INST-TILE-TSHRS",
    "PTO-INST-TILE-TCVT",
    "PTO-INST-TILE-TMOV",
    "PTO-INST-TILE-TCONCAT",
    "PTO-INST-TILE-TEXTRACT",
    "PTO-INST-TILE-TINSERT",
    "PTO-INST-TILE-TIMG2COL",
    "PTO-TADDS-CONTRACT-001",
    "PTO-TSUBS-CONTRACT-001",
    "PTO-TMULS-CONTRACT-001",
    "PTO-TDIVS-CONTRACT-001",
    "PTO-TREMS-CONTRACT-001",
    "PTO-TMAXS-CONTRACT-001",
    "PTO-TMINS-CONTRACT-001",
    "PTO-TANDS-CONTRACT-001",
    "PTO-TORS-CONTRACT-001",
    "PTO-TXORS-CONTRACT-001",
    "PTO-TSHLS-CONTRACT-001",
    "PTO-TSHRS-CONTRACT-001",
    "PTO-TCONCAT-CONTRACT-001",
    "PTO-TCMPS-CONTRACT-001",
    "PTO-TSELS-CONTRACT-001",
    "PTO-TGPR2T-CONTRACT-001",
    "PTO-TILE-MODEL-DEFINEDNESS-PREDICATE-CELL-001",
    "PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001",
    "PTO-BLOCK-MODEL-DISPATCH-TGPR2T-BOUNDARY-001",
    "PTO-INST-BLOCK-B-DATR",
    "PTO-INST-BLOCK-B-IOR",
    "PTO-INST-TILE-TCMP",
    "PTO-INST-TILE-TCMPS",
    "PTO-INST-TILE-TGPR2T",
    "PTO-INST-TILE-TSEL",
    "PTO-INST-TILE-TSELS"
  ],
  "affected_units": [
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-BSTART-SFU",
    "PTO-BLOCK-BSTART-TEPL",
    "PTO-BLOCK-BSTART-VEC",
    "PTO-TILE-TABS",
    "PTO-TILE-TADD",
    "PTO-TILE-TAND",
    "PTO-TILE-TCMP",
    "PTO-TILE-TCVT",
    "PTO-TILE-TDIV",
    "PTO-TILE-TEXP",
    "PTO-TILE-TEXTRACT",
    "PTO-TILE-TFMA",
    "PTO-TILE-TIMG2COL",
    "PTO-TILE-TINSERT",
    "PTO-TILE-TLOG",
    "PTO-TILE-TMAX",
    "PTO-TILE-TMIN",
    "PTO-TILE-TMOV",
    "PTO-TILE-TMUL",
    "PTO-TILE-TNEG",
    "PTO-TILE-TNOT",
    "PTO-TILE-TOR",
    "PTO-TILE-TRECIP",
    "PTO-TILE-TRELU",
    "PTO-TILE-TREM",
    "PTO-TILE-TRSQRT",
    "PTO-TILE-TSEL",
    "PTO-TILE-TSHL",
    "PTO-TILE-TSHR",
    "PTO-TILE-TSQRT",
    "PTO-TILE-TSUB",
    "PTO-TILE-TXOR",
    "PTO-BLOCK-BSTART-TMOV",
    "PTO-TILE-TADDS",
    "PTO-TILE-TSUBS",
    "PTO-TILE-TMULS",
    "PTO-TILE-TDIVS",
    "PTO-TILE-TREMS",
    "PTO-TILE-TMAXS",
    "PTO-TILE-TMINS",
    "PTO-TILE-TANDS",
    "PTO-TILE-TORS",
    "PTO-TILE-TXORS",
    "PTO-TILE-TSHLS",
    "PTO-TILE-TSHRS",
    "PTO-TILE-TCONCAT",
    "PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT",
    "PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA",
    "PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT",
    "PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA",
    "PTO-TILE-MODEL-LEGALITY-IMAGE-TO-COLUMN",
    "PTO-TILE-MODEL-EXECUTION-ELEMENTWISE",
    "PTO-TILE-MODEL-EXECUTION-UNARY",
    "PTO-TILE-MODEL-EXECUTION-REARRANGEMENT",
    "PTO-TILE-MODEL-NUMERIC-FORMATS",
    "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE",
    "PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION",
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE",
    "PTO-ARCH-PROFILE-RESET",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION",
    "PTO-BLOCK-MODEL-DISPATCH-PREDICATE-DESTINATION",
    "PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY",
    "PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA",
    "PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION",
    "PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-TILE-MODEL-EXECUTION-COMPARISON",
    "PTO-TILE-MODEL-EXECUTION-POSTPROCESS",
    "PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS",
    "PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS",
    "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
    "PTO-TILE-MODEL-STATE-ALLOCATION",
    "PTO-TILE-MODEL-STATE-SHARED-REGISTERS",
    "PTO-TILE-MODEL-STATE-TYPES",
    "PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS",
    "PTO-TILE-MODEL-DISPATCH-LAYOUT-AND-REARRANGEMENT",
    "PTO-TILE-TCMPS",
    "PTO-TILE-TSELS",
    "PTO-TILE-TGPR2T"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-0062"
  ],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "PRD-056",
    "PRD-057",
    "PRD-058",
    "PRD-059",
    "PRD-060",
    "PRD-061",
    "PRD-062",
    "PRD-063",
    "PRD-064",
    "PRD-065",
    "PRD-066",
    "PRD-067",
    "PRD-068",
    "PRD-069",
    "PRD-070",
    "PRD-071",
    "PRD-072",
    "PRD-073",
    "PRD-074",
    "PRD-075",
    "PRD-076",
    "PRD-077",
    "PRD-078",
    "PRD-079",
    "PRD-080",
    "PRD-081",
    "PRD-126",
    "PRD-127",
    "PRD-128"
  ],
  "amendments": [
    {
      "date": "2026-08-30",
      "baseline": "0d3365264eee82827214e7240c8aeaf270a6f94a",
      "approvers": [
        "PTO ISA maintainers"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/162",
      "affected_ndf": [
        "PTO-TILE-CARRIER-REINTERPRETATION-001",
        "PTO-INST-BLOCK-BSTART-TMOV",
        "PTO-INST-TILE-TADD",
        "PTO-INST-TILE-TSUB",
        "PTO-INST-TILE-TMUL",
        "PTO-INST-TILE-TDIV",
        "PTO-INST-TILE-TREM",
        "PTO-INST-TILE-TMAX",
        "PTO-INST-TILE-TMIN",
        "PTO-INST-TILE-TABS",
        "PTO-INST-TILE-TNEG",
        "PTO-INST-TILE-TRELU",
        "PTO-INST-TILE-TRECIP",
        "PTO-INST-TILE-TRSQRT",
        "PTO-INST-TILE-TSQRT",
        "PTO-INST-TILE-TEXP",
        "PTO-INST-TILE-TLOG",
        "PTO-INST-TILE-TADDS",
        "PTO-INST-TILE-TSUBS",
        "PTO-INST-TILE-TMULS",
        "PTO-INST-TILE-TDIVS",
        "PTO-INST-TILE-TREMS",
        "PTO-INST-TILE-TMAXS",
        "PTO-INST-TILE-TMINS",
        "PTO-INST-TILE-TAND",
        "PTO-INST-TILE-TANDS",
        "PTO-INST-TILE-TOR",
        "PTO-INST-TILE-TORS",
        "PTO-INST-TILE-TXOR",
        "PTO-INST-TILE-TXORS",
        "PTO-INST-TILE-TSHL",
        "PTO-INST-TILE-TSHLS",
        "PTO-INST-TILE-TSHR",
        "PTO-INST-TILE-TSHRS",
        "PTO-INST-TILE-TCVT",
        "PTO-INST-TILE-TMOV",
        "PTO-INST-TILE-TCONCAT",
        "PTO-INST-TILE-TEXTRACT",
        "PTO-INST-TILE-TINSERT",
        "PTO-INST-TILE-TIMG2COL",
        "PTO-TADD-CONTRACT-001",
        "PTO-TSUB-CONTRACT-001",
        "PTO-TMUL-CONTRACT-001",
        "PTO-TDIV-CONTRACT-001",
        "PTO-TREM-CONTRACT-001",
        "PTO-TMAX-CONTRACT-001",
        "PTO-TMIN-CONTRACT-001",
        "PTO-TABS-CONTRACT-001",
        "PTO-TNEG-CONTRACT-001",
        "PTO-TRELU-CONTRACT-001",
        "PTO-TRECIP-CONTRACT-001",
        "PTO-TRSQRT-CONTRACT-001",
        "PTO-TSQRT-CONTRACT-001",
        "PTO-TEXP-CONTRACT-001",
        "PTO-TLOG-CONTRACT-001",
        "PTO-TADDS-CONTRACT-001",
        "PTO-TSUBS-CONTRACT-001",
        "PTO-TMULS-CONTRACT-001",
        "PTO-TDIVS-CONTRACT-001",
        "PTO-TREMS-CONTRACT-001",
        "PTO-TMAXS-CONTRACT-001",
        "PTO-TMINS-CONTRACT-001",
        "PTO-TAND-CONTRACT-001",
        "PTO-TANDS-CONTRACT-001",
        "PTO-TOR-CONTRACT-001",
        "PTO-TORS-CONTRACT-001",
        "PTO-TXOR-CONTRACT-001",
        "PTO-TXORS-CONTRACT-001",
        "PTO-TSHL-CONTRACT-001",
        "PTO-TSHLS-CONTRACT-001",
        "PTO-TSHR-CONTRACT-001",
        "PTO-TSHRS-CONTRACT-001",
        "PTO-TCVT-CONTRACT-001",
        "PTO-TMOV-CONTRACT-001",
        "PTO-TCONCAT-CONTRACT-001",
        "PTO-TEXTRACT-CONTRACT-001",
        "PTO-TINSERT-CONTRACT-001",
        "PTO-TIMG2COL-CONTRACT-001"
      ],
      "affected_units": [
        "PTO-BLOCK-BSTART-TMOV",
        "PTO-TILE-TADD",
        "PTO-TILE-TSUB",
        "PTO-TILE-TMUL",
        "PTO-TILE-TDIV",
        "PTO-TILE-TREM",
        "PTO-TILE-TMAX",
        "PTO-TILE-TMIN",
        "PTO-TILE-TABS",
        "PTO-TILE-TNEG",
        "PTO-TILE-TRELU",
        "PTO-TILE-TRECIP",
        "PTO-TILE-TRSQRT",
        "PTO-TILE-TSQRT",
        "PTO-TILE-TEXP",
        "PTO-TILE-TLOG",
        "PTO-TILE-TADDS",
        "PTO-TILE-TSUBS",
        "PTO-TILE-TMULS",
        "PTO-TILE-TDIVS",
        "PTO-TILE-TREMS",
        "PTO-TILE-TMAXS",
        "PTO-TILE-TMINS",
        "PTO-TILE-TAND",
        "PTO-TILE-TANDS",
        "PTO-TILE-TOR",
        "PTO-TILE-TORS",
        "PTO-TILE-TXOR",
        "PTO-TILE-TXORS",
        "PTO-TILE-TSHL",
        "PTO-TILE-TSHLS",
        "PTO-TILE-TSHR",
        "PTO-TILE-TSHRS",
        "PTO-TILE-TCVT",
        "PTO-TILE-TMOV",
        "PTO-TILE-TCONCAT",
        "PTO-TILE-TEXTRACT",
        "PTO-TILE-TINSERT",
        "PTO-TILE-TIMG2COL",
        "PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT",
        "PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA",
        "PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT",
        "PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA",
        "PTO-TILE-MODEL-LEGALITY-IMAGE-TO-COLUMN",
        "PTO-TILE-MODEL-EXECUTION-ELEMENTWISE",
        "PTO-TILE-MODEL-EXECUTION-UNARY",
        "PTO-TILE-MODEL-EXECUTION-REARRANGEMENT",
        "PTO-TILE-MODEL-NUMERIC-FORMATS",
        "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE",
        "PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA",
        "PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION"
      ]
    },
    {
      "date": "2026-08-31",
      "baseline": "e811355419182144784af802ff4c86d6a7014c70",
      "approvers": [
        "PTO ISA maintainers"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/pull/172",
      "affected_ndf": [
        "PTO-B-IOR-BINDING-001",
        "PTO-B-DATR-FIELDS-001",
        "PTO-TCMP-CONTRACT-001",
        "PTO-TCMPS-CONTRACT-001",
        "PTO-TSEL-CONTRACT-001",
        "PTO-TSELS-CONTRACT-001",
        "PTO-TGPR2T-CONTRACT-001",
        "PTO-TILE-MODEL-DEFINEDNESS-PREDICATE-CELL-001",
        "PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001",
        "PTO-BLOCK-MODEL-DISPATCH-TGPR2T-BOUNDARY-001",
        "PTO-INST-BLOCK-B-DATR",
        "PTO-INST-BLOCK-B-IOR",
        "PTO-INST-TILE-TCMP",
        "PTO-INST-TILE-TCMPS",
        "PTO-INST-TILE-TGPR2T",
        "PTO-INST-TILE-TSEL",
        "PTO-INST-TILE-TSELS"
      ],
      "affected_units": [
        "PTO-ARCH-PROFILE-REFERENCE-PROFILE",
        "PTO-ARCH-PROFILE-RESET",
        "PTO-BLOCK-B-IOR",
        "PTO-BLOCK-B-DATR",
        "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
        "PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA",
        "PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY",
        "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE",
        "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
        "PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION",
        "PTO-BLOCK-MODEL-DISPATCH-PREDICATE-DESTINATION",
        "PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA",
        "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY",
        "PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA",
        "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX",
        "PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA",
        "PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION",
        "PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS",
        "PTO-BLOCK-MODEL-STATE-TYPES",
        "PTO-TILE-MODEL-EXECUTION-COMPARISON",
        "PTO-TILE-MODEL-EXECUTION-POSTPROCESS",
        "PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS",
        "PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS",
        "PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA",
        "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
        "PTO-TILE-MODEL-STATE-ALLOCATION",
        "PTO-TILE-MODEL-STATE-SHARED-REGISTERS",
        "PTO-TILE-MODEL-STATE-TYPES",
        "PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS",
        "PTO-TILE-MODEL-DISPATCH-LAYOUT-AND-REARRANGEMENT",
        "PTO-TILE-TCMP",
        "PTO-TILE-TCMPS",
        "PTO-TILE-TSEL",
        "PTO-TILE-TSELS",
        "PTO-TILE-TGPR2T"
      ]
    }
  ]
}
---
# ADR 0080: Tile elementwise and irregular operations

## Context

ADR 0062 recorded a single repository-wide mnemonic audit. This record preserves the accepted decisions for this family as one decision-scoped owner. The former identifiers remain only in `legacy_ids` and the generated ADR index; current normative meaning is owned by the affected ASL/NDF clauses.

## Decisions

## Decision 056: `TADD` applies `PadValue` outside the valid destination rectangle

`TADD` accepts the `B.DATR.PadValueOrByteId` field in its `PadValue`
interpretation. Within `ValidRow x ValidCol`, the destination element is the
profile-defined sum of the corresponding left and right source elements. The
two sources and destination MUST have matching physical rows, physical
columns, valid rows, valid columns, row-major layout, and DataType.

After the valid-rectangle additions are computed, every physical destination
element outside `ValidRow x ValidCol` is handled by the resolved `PadValue`.
`Zero`, `Max`, and `Min` define those elements using the selected DataType's
corresponding value. `Null` leaves those elements undefined. Omission resolves
to `Null`. An explicitly present code `00` selects `Zero`, so omission and
encoded zero remain architecturally distinct.

All source elements required by the valid rectangle MUST be defined before any
destination effect. Both source payloads are snapshotted after complete
preflight, so either source MAY alias the destination with read-old/write-new
behavior. The destination update, including padding definedness, becomes
visible as one complete commit.

## Decision 057: `TADD` has a closed Local VEC block schema

`TADD` is the VEC elementwise addition operation selected by TEPL carrier
`Mode=0, Function=0`. It reads two Local source Tiles in left-to-right binding
order and writes one explicit new Local destination. `B.IOS` and `B.IOR` are
illegal for this operation. All participating `B.IOT` bindings MUST carry the
same `PE_MASK`; each selected PE executes independently, while
`PE_MASK=0000` is a strict no-op before source reads, destination allocation,
or faults.

`LB0` specifies `ValidCol` and MUST resolve to a nonzero 16-bit value. `LB1`
specifies `ValidRow`; omission defaults it to one. `LB2` specifies physical
`Col`; omission defaults it to `ValidCol`. The resolved physical row count is
derived from destination capacity, `Col`, and DataType. `ValidRow` MUST NOT
exceed physical rows and `ValidCol` MUST NOT exceed `Col`. Both sources and
the destination MUST have matching physical rows, physical columns, valid
rows, valid columns, row-major layout, and DataType.

The TADD DataType set is exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Every other DataType encoding is unsupported by TADD and MUST reject
before effects. The selected numeric profile defines addition, exceptional
values, overflow, and its fixed default rounding behavior for each supported
type. TADD does not consume `CMode`, `Sat`, `Canonicalize`, secondary
`DataType`, `RMode`, or `Layout`; any explicit nondefault value in those fields
is illegal.

`PadValueOrByteId` is the only applicable `B.DATR` field and follows Decision 056 in ADR-0080.
The valid source rectangles MUST be defined before any effect. Descriptor,
schema, mask, field, dimension, allocation, and source-definedness checks all
complete before source snapshots or destination publication.

## Decision 058: `TSUB` is ordered Local VEC subtraction with the binary Tile schema

`TSUB` is selected by TEPL carrier `Mode=0, Function=1`. It reads an ordered
left Local source and right Local source, and writes one explicit new Local
destination. Within `ValidRow x ValidCol`, each destination element is the
selected numeric profile's `left - right` result. Operand order MUST NOT be
commuted. The numeric profile defines floating exceptional values, integer
overflow and underflow, and the fixed default rounding behavior for each
supported DataType.

The block schema, dimensions, allocation, Local-only restriction, equal
`PE_MASK` rule, zero-mask strict no-op, source persistence, destination rename,
preflight, snapshot, and atomic publication rules are the same as the closed
binary VEC schema defined for `TADD`: `LB0` is required nonzero `ValidCol`,
omitted `LB1` gives `ValidRow=1`, omitted `LB2` gives `Col=ValidCol`, and
physical rows are derived from capacity, `Col`, and DataType. Both sources and
the destination MUST match in physical and valid shape, row-major layout, and
DataType. All source elements required by the valid rectangle MUST be defined.

The TSUB DataType set is exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Every other DataType encoding is unsupported by TSUB and MUST reject
before effects. `PadValueOrByteId` is the only applicable `B.DATR` field:
omission selects `Null`, explicit `00` selects `Zero`, `01` selects `Max`, `10`
selects `Min`, and `11` selects `Null`. The selected padding rule applies to
every physical destination element outside the valid rectangle. `CMode`,
`Sat`, `Canonicalize`, secondary `DataType`, `RMode`, and `Layout` are not
consumed, and explicit nondefault values are illegal.

Both source payloads are snapshotted after complete preflight. Either source
MAY alias the destination with read-old/write-new behavior, and both sources
MAY name the same Tile. The complete valid result plus padding definedness is
published as one destination commit; any rejection leaves all descriptors,
payloads, and allocation state unchanged.

## Decision 059: `TMUL` is Local VEC elementwise multiplication

`TMUL` is selected by TEPL carrier `Mode=0, Function=2`. It reads two Local
source Tiles and writes one explicit new Local destination. Within
`ValidRow x ValidCol`, each destination element is the selected numeric
profile's product of the corresponding source elements. The profile defines
floating exceptional values, integer overflow, and its fixed default rounding
behavior.

TMUL uses the same closed Local binary VEC block schema, dimension defaults,
descriptor matching, allocation, mask, source persistence, rename, preflight,
snapshot, and atomic publication rules as TADD. `LB0` is required nonzero
`ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows are derived from capacity, `Col`, and
DataType. Both sources and destination MUST match in physical and valid shape,
row-major layout, and DataType, and every source element used by the valid
rectangle MUST be defined.

The TMUL DataType set is exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Other DataType encodings are unsupported by TMUL and reject before
effects. `PadValueOrByteId` is the only applicable `B.DATR` field and applies
to every physical destination element outside the valid rectangle: omission
selects `Null`, explicit `00` selects `Zero`, `01` selects `Max`, `10` selects
`Min`, and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`,
`Canonicalize`, secondary `DataType`, `RMode`, or `Layout` is illegal.

Both source payloads are snapshotted after complete preflight. Either source
MAY alias the destination with read-old/write-new behavior, and both sources
MAY name the same Tile. `PE_MASK=0000` is a strict no-op before reads,
allocation, or faults. An executing block publishes the complete valid result
and padding definedness as one destination commit; rejection has no
architectural effect.

## Decision 060: `TDIV` is SFU elementwise division with type-specific zero handling

`TDIV` retains the unchanged TEPL carrier `Mode=0, Function=3`, but its
semantic engine is `SFU` because division requires complex execution hardware.
Canonical block assembly uses `BSTART.SFU TDIV, DataType`; the raw encoding is
unchanged and `BSTART.TEPL` remains only the carrier-compatible spelling.

TDIV reads an ordered Local numerator Tile and denominator Tile and writes one
explicit new Local destination. Within `ValidRow x ValidCol`, each destination
element is the selected numeric profile's quotient `numerator / denominator`.
Signed integer DataTypes use signed division, unsigned integer DataTypes use
unsigned division, and floating DataTypes use their floating division profile.
Integer division by zero in any element of the valid denominator rectangle
causes Illegal Block Exception before source snapshots, allocation publication,
or destination effects. Floating division by positive or negative zero is not
a block-legality failure; its result and numeric status follow the selected
floating profile. Denominator elements outside the valid rectangle are not
read and do not participate in zero checking.

TDIV uses the closed Local binary Tile schema: required nonzero `LB0=ValidCol`,
omitted `LB1` default `ValidRow=1`, omitted `LB2` default `Col=ValidCol`,
capacity-derived physical rows, equal source/destination physical and valid
shape, row-major layout, DataType, equal `PE_MASK`, and zero-mask strict no-op.
Both valid source rectangles MUST be defined before effects. The TDIV DataType
set is exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`,
`S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`; every other type is
unsupported and rejects before effects.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Padding applies only outside the valid destination
rectangle. `CMode`, `Sat`, `Canonicalize`, secondary `DataType`, `RMode`, and
`Layout` are not consumed and explicit nondefault values are illegal; the
numeric profile owns TDIV's fixed rounding and exceptional-value behavior.

All legality and integer zero checks complete before both source payloads are
snapshotted. Either source MAY alias the destination with read-old/write-new
behavior. The valid quotient results and padding definedness publish in one
destination commit; any exception leaves descriptors, payloads, and allocation
state unchanged.

## Decision 061: `TREM` is SFU modulo with a divisor-signed result

`TREM` retains the unchanged TEPL carrier `Mode=0, Function=4`, but its
semantic engine is `SFU`. Canonical block assembly uses
`BSTART.SFU TREM, DataType`; no raw encoding changes.

TREM reads an ordered Local dividend Tile and divisor Tile and writes one
explicit new Local destination. Within `ValidRow x ValidCol`, it computes
modulo rather than a truncation-toward-zero language remainder. For signed
integer DataTypes, `q=floor(dividend/divisor)` and
`result=dividend-q*divisor`, so every nonzero result has the divisor's sign and
its magnitude is smaller than the divisor's magnitude. Unsigned DataTypes use
ordinary unsigned remainder. Floating DataTypes use the selected floating
modulo profile with the same divisor-signed result rule.

An integer zero divisor in any valid element causes Illegal Block Exception
before effects. Floating modulo by positive or negative zero is not a
block-legality rejection; its result and numeric status follow the floating
profile. Elements outside the valid divisor rectangle are not read or checked.
The profile also defines signed overflow boundaries and floating exceptional
values.

TREM uses the same closed Local binary Tile schema and defaults as TDIV:
required nonzero `LB0=ValidCol`, omitted `LB1` gives `ValidRow=1`, omitted
`LB2` gives `Col=ValidCol`, physical rows derive from capacity, and both
sources and destination match in physical shape, valid shape, row-major
layout, and DataType. Both source valid rectangles MUST be defined. The exact
TREM DataType set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`; other types
reject before effects.

`PadValueOrByteId` is the only applicable `B.DATR` field, with omission
`Null`, explicit `00` `Zero`, `01` `Max`, `10` `Min`, and `11` `Null`.
Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`,
`RMode`, or `Layout` is illegal. Equal masks, zero-mask no-op, source
persistence, destination rename, complete preflight, source snapshots,
read-old/write-new aliasing, padding definedness, atomic commit, and rollback
follow the binary Tile contract.

## Decision 062: `TAND` is integer-only Local VEC bitwise AND

`TAND` is selected by TEPL carrier `Mode=0, Function=6`. It reads two ordered
Local source Tiles and writes one explicit renamed Local destination. Within
`ValidRow x ValidCol`, every destination element is the raw bitwise AND of the
corresponding left and right integer elements. Signedness does not change the
bit operation.

The exact supported DataType set is `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`. Floating, compact floating, exponent-only, and packed integer
encodings are unsupported by TAND and reject before effects. TAND uses the
closed Local binary VEC schema: nonzero `LB0=ValidCol` is required; omitted
`LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows
derive from capacity, `Col`, and DataType. Both sources and destination MUST
match in physical and valid shape, row-major layout, and DataType, and every
source element read by the valid rectangle MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. `Max` and `Min` use the selected integer DataType's
numeric maximum and minimum. The selector applies to every physical
destination element outside the valid rectangle. Explicit nondefault `CMode`,
`Sat`, `Canonicalize`, secondary `DataType`, `RMode`, or `Layout` is illegal.

TAND takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and treats `PE_MASK=0000` as a strict no-op before reads,
allocation, or faults. Both source payloads are snapshotted only after complete
preflight. Sources MAY be identical and either source MAY alias the destination
with read-old/write-new behavior. The valid bitwise result plus padding
definedness publishes as one destination commit; rejection leaves descriptors,
payloads, and allocation state unchanged.

## Decision 063: `TOR` is integer-only Local VEC bitwise OR

`TOR` is selected by TEPL carrier `Mode=0, Function=7`. It reads two ordered
Local source Tiles and writes one explicit renamed Local destination. Within
`ValidRow x ValidCol`, each destination element is the raw bitwise OR of the
corresponding left and right integer elements. Signedness does not change the
bit operation.

The exact supported DataType set is `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`. Every floating, compact floating, exponent-only, and packed
integer encoding is unsupported by TOR and rejects before effects. TOR uses
the closed Local binary VEC schema: `LB0=ValidCol` is required and nonzero;
omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and
physical rows derive from capacity, `Col`, and DataType. Both sources and the
destination MUST match in physical and valid shape, row-major layout, and
DataType, and all valid source elements MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. `Max` and `Min` use the selected integer DataType's
numeric maximum and minimum. Padding applies outside the valid destination
rectangle. Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary
`DataType`, `RMode`, or `Layout` is illegal.

TOR takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and treats `PE_MASK=0000` as a strict no-op before reads,
allocation, or faults. Both source payloads are snapshotted after complete
preflight. Sources MAY be identical and either source MAY alias the destination
with read-old/write-new behavior. Valid results plus padding definedness publish
as one destination commit; rejection leaves architectural state unchanged.

## Decision 064: `TXOR` is integer-only Local VEC bitwise XOR

`TXOR` is selected by TEPL carrier `Mode=0, Function=8`. It reads two ordered
Local source Tiles and writes one explicit renamed Local destination. Within
`ValidRow x ValidCol`, each destination element is the raw bitwise XOR of the
corresponding left and right integer elements. Signedness does not affect the
bit operation.

TXOR supports exactly `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Floating, compact floating, exponent-only, and packed integer encodings
are unsupported and reject before effects. The closed Local binary VEC schema
requires nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted
`LB2` gives `Col=ValidCol`; and physical rows derive from capacity, `Col`, and
DataType. Both sources and destination MUST match in physical and valid shape,
row-major layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`, using the selected integer DataType's numeric bounds.
Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`,
`RMode`, or `Layout` is illegal.

TXOR takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and treats `PE_MASK=0000` as a strict no-op before reads,
allocation, or faults. Both sources persist and are snapshotted after complete
preflight. They MAY be identical and either MAY alias the destination with
read-old/write-new behavior. Valid XOR results plus padding definedness publish
atomically; rejection leaves architectural state unchanged.

## Decision 065: `TSHL` uses element-width-masked logical left shifts

`TSHL` is selected by TEPL carrier `Mode=0, Function=9`. It reads a Local
value Tile as source0 and a Local shift-count Tile as source1, and writes one
explicit renamed Local destination. For an element width `W` of 8, 16, 32, or
64 bits, the shift count is the unsigned value of the low `log2(W)` bits of
the corresponding source1 element. The destination element is the low `W`
bits of `source0 << count`; verification-carrier bits above `W` are zero.
Signedness does not alter this raw left-shift rule.

TSHL supports exactly `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Other DataTypes reject before effects. Its closed Local binary VEC
schema requires nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`;
omitted `LB2` gives `Col=ValidCol`; and physical rows derive from capacity,
`Col`, and DataType. Sources and destination MUST match in physical and valid
shape, row-major layout, and DataType, and all valid source elements MUST be
defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`, using the selected integer type's numeric bounds.
Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`,
`RMode`, or `Layout` is illegal.

TSHL takes no `B.IOR` or `B.IOS`, requires equal `PE_MASK` values, and mask
zero is a strict no-op. Sources persist, may be identical, and may alias the
destination. Both payloads are snapshotted after complete preflight; narrowed
valid results plus padding definedness publish atomically, and rejection has no
architectural effect.

## Decision 066: `TSHR` follows integer signedness at the element width

`TSHR` is selected by TEPL carrier `Mode=0, Function=10`. It reads a Local
value Tile as source0 and a Local shift-count Tile as source1, and writes one
explicit renamed Local destination. For element width `W`, the unsigned shift
count is selected by the low `log2(W)` bits of source1. Signed DataTypes use
arithmetic right shift with sign fill; unsigned DataTypes use logical right
shift with zero fill. The low `W` result bits are stored and verification-
carrier bits above `W` are zero.

TSHR supports exactly `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Other types reject before effects. The closed Local binary VEC schema
requires nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted
`LB2` gives `Col=ValidCol`; and physical rows derive from capacity, `Col`, and
DataType. Sources and destination MUST match physical shape, valid shape,
row-major layout, and DataType, and all valid source elements MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`, using the selected integer type's numeric bounds.
Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`,
`RMode`, or `Layout` is illegal.

TSHR takes no `B.IOR` or `B.IOS`, requires equal `PE_MASK` values, and mask
zero is a strict no-op. Both sources persist, may be identical, and may alias
the destination. Payloads are snapshotted after complete preflight; the typed
shift results plus padding definedness publish atomically, and rejection has no
architectural effect.

## Decision 067: `TMAX` is typed maximum with deterministic floating ties

`TMAX` is selected by TEPL carrier `Mode=0, Function=11`. It reads two ordered
Local source Tiles and writes one explicit renamed Local destination. Signed
integer DataTypes use signed numeric ordering, unsigned integer DataTypes use
unsigned numeric ordering, and floating DataTypes use the selected numeric
profile's maximum operation.

TMAX supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Other types
reject before effects. For supported floating types, one NaN selects the
non-NaN operand without changing its encoding; two NaNs produce the
destination canonical NaN; signaling NaN reports the selected profile's
invalid condition; equal-sign zero preserves that sign; and a mixed-sign zero
tie produces positive zero. Operand order does not change these results.
Source encodings invalid for the selected operation/profile reject before
effects.

The closed Local binary VEC schema requires nonzero `LB0=ValidCol`; omitted
`LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows
derive from capacity, `Col`, and DataType. Both sources and destination MUST
match physical and valid shape, row-major layout, and DataType, and all valid
source elements MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal.

TMAX takes no `B.IOR` or `B.IOS`, requires equal `PE_MASK` values, and mask
zero is a strict no-op. Sources persist, may be identical, and may alias the
destination. Payloads are snapshotted after all legality and value-encoding
checks; the complete result plus padding definedness publishes atomically, and
rejection has no architectural effect.

## Carrier interpretation and CUBE predicate interface

For ordinary numeric, logical, shift, and unary Tile operations, the operation
DataType is the execution interpretation and destination backing type. A
source backing DataType need not equal that operation type when the stored
carrier has the same element width and satisfies the operation's geometry,
layout, definedness, and type-specific legality. Pure layout/carrier operations
preserve the source backing type; `TCVT` independently selects source and
destination operation types. Source-language reinterpretation provenance is
not architectural state.

`TCMP/TCMPS` and `TSEL/TSELS` use complete, mutually exclusive legacy,
CUBE-GPR, or CUBE-PredicateCell schemas. PredicateCell records the comparison
basis separately from U8 storage. `TGPR2T` consumes two contiguous source-only
`B.IOR` records with source arity 3+1 followed by one destination-bearing
`B.IOT`, and publishes an ordinary numeric U8 CUBE result. It is not an
implicit PredicateCell or mask conversion.

Issues [#162](https://github.com/PTO-ISA/pto-spec/issues/162),
[#152](https://github.com/PTO-ISA/pto-spec/issues/152), and
[#160](https://github.com/PTO-ISA/pto-spec/issues/160) preserve the detailed
interface alternatives and focused evidence. These amendments extend the
existing Tile operation family rather than creating parallel ADR owners.

## Decision 126: `TEXTRACT` uses two optional private-GPR offsets

`TEXTRACT` is selected by TEPL carrier `Mode=3, Function=2` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. The row offset is the unsigned low sixteen bits
of the selected PE's private `B.IOR.RegSrc0`; the column offset is the unsigned
low sixteen bits of `B.IOR.RegSrc1`. An omitted `B.IOR` supplies zero for both
offsets. When `B.IOR` is present, `RegSrc2` and `RegDst` MUST be zero.

`B.DIM` never supplies the offsets. Required nonzero `LB0` supplies destination
`ValidCol`; omitted `LB1` gives destination `ValidRow=1`; omitted `LB2` gives
destination physical `Col=ValidCol`; destination physical rows derive from
capacity, `Col`, and DataType. Before effects, `row_offset + ValidRow` MUST be
at most the source `ValidRow` and `column_offset + ValidCol` MUST be at most
the source `ValidCol`.

For every destination valid element `[r,c]`, the result is source element
`[row_offset+r,column_offset+c]`. The source and destination use the same
DataType. Every assigned Tile DataType except `HiF4X2` is supported; globally
reserved encodings and `HiF4X2` reject before effects. The selected assigned
`Layout` transformation governs destination placement. `PadValueOrByteId`
applies to destination physical elements outside its valid rectangle; omission
selects `Null` and explicit values select `Zero`, `Max`, `Min`, or `Null`.

`TEXTRACT` has no architectural ReLU, quantization, Fix-pipe, auxiliary Tile,
or target-specific overload. It is Local-only; source and destination use the
same `PE_MASK`, with mask zero a strict no-op. The source valid elements needed
by the extraction window MUST be defined. Complete preflight precedes a source
snapshot, and destination contents, padding definedness, and descriptor publish
atomically. The source persists and rejection has no architectural effect.

## Decision 127: `TINSERT` explicitly reads the old destination and writes a renamed result

`TINSERT` is selected by TEPL carrier `Mode=3, Function=3` and executes on the
`SFU` engine. Its architectural Tile operands are an old-destination source,
an insertion source, and one explicit newly allocated destination result. The
result begins as an exact snapshot of the old destination, after which the
insertion source valid rectangle replaces the result window beginning at the
selected row and column offsets. The old destination and insertion source both
persist.

The row offset is the unsigned low sixteen bits of the selected PE's private
`B.IOR.RegSrc0`; the column offset is the unsigned low sixteen bits of
`B.IOR.RegSrc1`. An omitted `B.IOR` supplies zero for both. When `B.IOR` is
present, `RegSrc2` and `RegDst` MUST be zero. `B.DIM` describes the result
geometry and MUST match the old-destination physical and valid shape; it never
supplies the offsets.

The old destination, insertion source, and result use one DataType. Every
assigned Tile DataType except `HiF4X2` is supported. Before effects,
`row_offset + insertion.ValidRow` MUST be at most `result.ValidRow` and
`column_offset + insertion.ValidCol` MUST be at most `result.ValidCol`.
Every insertion-source valid element MUST be defined. Every result element not
covered by the inserted rectangle, including its definedness, is preserved
from the old destination. `PadValueOrByteId` is not applicable because no
uncovered region is synthesized. An assigned `Layout` value may select the
defined source-to-result layout transformation; reserved values reject.

`TINSERT` has no architectural ReLU, quantization, Fix-pipe, auxiliary Tile,
or target-specific mode overload. It is Local-only. All three bindings use the
same `PE_MASK`; mask zero is a strict no-op. Complete preflight precedes both
source snapshots. The copied old state, inserted window, definedness, and new
destination descriptor publish atomically. Legal aliasing always observes old
source values; rejection has no architectural effect.

## Decision 128: `TIMG2COL` reads a feature-map descriptor and two logical matrix offsets

`TIMG2COL` is selected by TEPL carrier `Mode=3, Function=4` and executes on
the `SFU` engine. It reads one Local Matrix-location feature-map Tile and
writes one explicit newly allocated Local Matrix-location destination in the
standard Left-input representation. The source persists.

The source Tile carries a complete architectural feature-map descriptor. Its
layout is either `NC1HWC0`, with dimensions `N,C1,H,W,C0`, or `NDC1HWC0`,
with dimensions `N,D,C1,H,W,C0`. Every dimension is nonzero. The descriptor
also carries nonzero filter height and width, nonzero row and column strides,
nonzero row and column dilations, nonnegative left, right, top, and bottom
padding, a logical channel count no greater than `C1*C0`, and one typed
padding value. A descriptor requesting transposed IMG2COL is not assigned by
this PTO form and is illegal. The descriptor MUST be valid before execution;
`TIMG2COL` neither creates nor modifies it.

The destination row start `posM` is the unsigned low sixteen bits of the
selected PE's private `B.IOR.RegSrc0`; the destination-column start `posK` is
the unsigned low sixteen bits of `B.IOR.RegSrc1`. Omitted `B.IOR` supplies
zero for both. When present, `RegSrc2` and `RegDst` MUST be zero. Required
nonzero `B.DIM.LB0` supplies destination `ValidCol`; omitted `LB1` supplies
destination `ValidRow=1`; omitted `LB2` supplies destination physical
`Col=ValidCol`; physical rows derive from capacity, `Col`, and DataType.
`B.DIM` never supplies filter, stride, dilation, padding, `posM`, or `posK`.

Let `outH = floor((H + padTop + padBottom - dilationH*(filterH-1) - 1) /
strideH) + 1` and define `outW` analogously. Both values MUST be positive.
The logical im2col row extent is `N*D*outH*outW`, where `D=1` for
`NC1HWC0`; the packed column extent is `C1*filterH*filterW*C0`. The complete
destination rectangle beginning at `(posM,posK)` MUST fit those extents.

For result element `[r,c]`, `m=posM+r` selects `n`, `d`, `outRow`, and
`outCol` in that order. `k=posK+c` selects `c1`, `kernelRow`, `kernelCol`,
and `c0` from the packed column order. The corresponding source coordinates
are `inputRow=outRow*strideH + kernelRow*dilationH - padTop` and
`inputCol=outCol*strideW + kernelCol*dilationW - padLeft`. An out-of-range
input coordinate or a packed channel `c1*C0+c0` outside the logical channel
count yields the descriptor's padding value; otherwise the exact source
element is copied. Only actually referenced in-range source elements must be
defined.

Source and destination use the same DataType. This form supports exactly
`FP32`, `FP16`, `BF16`, `S32`, `S16`, `S8`, `U32`, `U16`, and `U8`; every
other assigned or reserved DataType rejects before effects. The feature-map
layout and padding value come only from the source descriptor. `B.DATR` may be
omitted; it supplies no secondary DataType, layout conversion, numeric mode,
or padding override, and every nondefault contribution is illegal.

`TIMG2COL` is Local-only and takes no `B.IOS`. Source and destination use the
same `PE_MASK`; nonzero partial masks are legal and mask zero is a strict
no-op. Complete descriptor, range, type, capacity, definedness, and allocation
preflight precedes a source snapshot. The complete destination payload,
padding definedness, and descriptor publish atomically, and rejection has no
architectural effect.

## Decision 068: `TMIN` is typed minimum with deterministic floating ties

`TMIN` is selected by TEPL carrier `Mode=0, Function=12`. It reads two ordered
Local source Tiles and writes one explicit renamed Local destination. Signed
integer DataTypes use signed numeric ordering, unsigned integer DataTypes use
unsigned numeric ordering, and floating DataTypes use the selected numeric
profile's minimum operation.

TMIN supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Other types
reject before effects. For supported floating types, one NaN selects the
non-NaN operand without changing its encoding; two NaNs produce the
destination canonical NaN; signaling NaN reports the selected profile's
invalid condition; equal-sign zero preserves that sign; and a mixed-sign zero
tie produces negative zero. Operand order does not change these results.
Source encodings invalid for the selected operation/profile reject before
effects.

The closed Local binary VEC schema requires nonzero `LB0=ValidCol`; omitted
`LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows
derive from capacity, `Col`, and DataType. Both sources and destination MUST
match physical and valid shape, row-major layout, and DataType, and all valid
source elements MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal.

TMIN takes no `B.IOR` or `B.IOS`, requires equal `PE_MASK` values, and mask
zero is a strict no-op. Sources persist, may be identical, and may alias the
destination. Payloads are snapshotted after all legality and value-encoding
checks; the complete result plus padding definedness publishes atomically, and
rejection has no architectural effect.

## Decision 069: `TCMP` produces a packed one-bit Local predicate Tile

`TCMP` is selected by TEPL carrier `Mode=0, Function=13`. It reads two ordered
Local numeric source Tiles and writes one explicit renamed Local predicate
destination. `B.DATR.CMode` maps `0=EQ`, `1=NE`, `2=LT`, `3=GT`, `4=LE`, and
`5=GE`; encodings 6 and 7 are reserved. Omission retains encoded zero and
therefore selects EQ.

Each logical comparison produces exactly one predicate bit. Logical element
index `i` occupies bit `i mod 8` of byte `floor(i/8)`, so lower logical indices
occupy lower bit positions. The destination is predicate-kind Tile storage,
not a numeric DataType, and retains the sources' logical `Row`, `Col`,
`ValidRow`, and `ValidCol`. Its allocated capacity MUST hold at least
`ceil(Row*Col/8)` bytes.

TCMP supports input types `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`.
Signed and unsigned ordered comparisons use their respective numeric ordering;
floating comparisons use the selected profile. With either floating operand
NaN, EQ/LT/LE/GT/GE produce zero and NE produces one; signaling NaN also
reports the selected profile's invalid condition. Positive and negative zero
compare equal, LE and GE are true, and strict relations are false. Source
encodings invalid for the selected operation/profile reject before effects.

Source dimensions use required nonzero `LB0=ValidCol`, omitted `LB1` default
`ValidRow=1`, omitted `LB2` default `Col=ValidCol`, and capacity-derived rows.
Both sources MUST match physical and valid shape, row-major layout, and
DataType. `CMode` and `PadValueOrByteId` are the only applicable `B.DATR`
fields. Pad omission is `Null`; `Zero` and `Min` write zero predicate bits
outside the valid rectangle; `Max` writes one bits; and `Null` leaves those
bits undefined. Explicit nondefault `Sat`, `Canonicalize`, secondary
`DataType`, `RMode`, or `Layout` is illegal.

TCMP takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. Sources persist and their
valid regions MUST be defined. Complete preflight precedes source snapshots;
the packed predicate payload, padding definedness, and destination descriptor
publish atomically, and rejection has no architectural effect.

## Decision 070: `TABS` is typed elementwise absolute value

`TABS` is selected by TEPL carrier `Mode=0, Function=15`. It reads one Local
source Tile and writes one explicit renamed Local destination. For signed
integer DataTypes, each result is the element-width two's-complement absolute
value: a negative input is negated modulo its width, so the most-negative
value retains its bit pattern. For unsigned integer DataTypes, the operation
is the identity. For floating DataTypes, TABS clears only the sign bit; this
maps negative zero to positive zero and preserves infinity, NaN class, and NaN
payload without raising an invalid condition solely because the operand is a
signaling NaN. Verification-carrier bits above the element width are zero.

TABS supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Other
DataTypes reject before effects. Its closed Local unary VEC schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`, using the selected DataType's values. Explicit
nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`, `RMode`, or
`Layout` is illegal.

TABS takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and treats mask zero as a strict no-op before reads,
allocation, or faults. The source persists and MAY alias the destination.
After complete preflight, the source payload is snapshotted and the typed
absolute-value result plus padding definedness publishes atomically. Rejection
leaves descriptors, payloads, and allocation state unchanged.

## Decision 071: `TNOT` complements only the selected integer element width

`TNOT` is selected by TEPL carrier `Mode=0, Function=16`. It reads one Local
source Tile and writes one explicit renamed Local destination. For an element
width `W` of 8, 16, 32, or 64 bits, each result is the low `W` bits of the
bitwise complement of the corresponding source element. Signedness does not
alter the operation. Verification-carrier bits above `W` are zero.

TNOT supports exactly `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`. Every floating, compact floating, exponent-only, and packed integer
DataType is unsupported and rejects before effects. Its closed Local unary
VEC schema requires nonzero `LB0=ValidCol`; omitted `LB1` gives
`ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows derive
from capacity, `Col`, and DataType. Source and destination MUST match in
physical and valid shape, row-major layout, and DataType, and every valid
source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`, using the selected integer DataType's numeric bounds.
Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`,
`RMode`, or `Layout` is illegal.

TNOT takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes the source snapshot; the
width-limited result plus padding definedness publishes atomically, and
rejection has no architectural effect.

## Decision 072: `TNEG` negates at the selected numeric element width

`TNEG` is selected by TEPL carrier `Mode=0, Function=17`. It reads one Local
source Tile and writes one explicit renamed Local destination. For signed and
unsigned integer DataTypes, each result is `0 - source` modulo the selected
8, 16, 32, or 64-bit element width; the most-negative signed value therefore
retains its bit pattern. For floating DataTypes, TNEG toggles only the sign
bit, preserving infinity, NaN class, and NaN payload without raising an
invalid condition solely because the operand is a signaling NaN. Positive and
negative zero exchange encodings. Verification-carrier bits above the element
width are zero.

TNEG supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Other
DataTypes reject before effects. Its closed Local unary VEC schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal.

TNEG takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes the source snapshot; the
typed result plus padding definedness publishes atomically, and rejection has
no architectural effect.

## Decision 073: `TEXP` is floating-only same-type natural exponential

`TEXP` is selected by TEPL carrier `Mode=0, Function=18` and executes on the
`SFU` engine without changing the TEPL carrier encoding. It reads one Local
floating source Tile and writes one explicit renamed Local destination of the
same DataType. Each valid destination element is the selected numeric
profile's same-type natural exponential `exp(source)`. The profile owns finite
approximation accuracy, rounding, overflow, underflow, inexact reporting, NaN
propagation, and canonical result requirements.

Independently of profile approximation, `exp(+0)` and `exp(-0)` are positive
one, `exp(+infinity)` is positive infinity, and `exp(-infinity)` is positive
zero. A quiet NaN produces the profile's quiet-NaN result; a signaling NaN
also reports the profile invalid condition and produces a quiet NaN.

TEXP supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
and `E5M2`. Integer, exponent-only, other compact floating, and packed
DataTypes reject before effects. Its closed Local unary SFU schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal; TEXP uses the selected
profile's fixed/default rounding behavior.

TEXP takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes source snapshot and SFU
evaluation; the result, numeric status, padding definedness, and destination
descriptor publish atomically. Rejection has no architectural effect.

## Decision 074: `TLOG` is floating-only same-type natural logarithm

`TLOG` is selected by TEPL carrier `Mode=0, Function=19` and executes on the
`SFU` engine without changing the TEPL carrier encoding. It reads one Local
floating source Tile and writes one explicit renamed Local destination of the
same DataType. Each valid destination element is the selected numeric
profile's same-type natural logarithm `log(source)`. The profile owns finite
approximation accuracy, rounding, underflow, inexact reporting, NaN
propagation, and canonical result requirements.

Independently of profile approximation, `log(+1)` is positive zero;
`log(+0)` and `log(-0)` are negative infinity and report divide-by-zero;
`log(+infinity)` is positive infinity; and every negative finite nonzero value
and negative infinity produce a quiet NaN and report invalid. A quiet NaN
produces the profile's quiet-NaN result; a signaling NaN additionally reports
invalid and produces a quiet NaN.

`E4M3` does not encode infinity. `TLOG` does not admit saturation, so an
`E4M3` positive or negative zero produces the canonical quiet NaN `0x7F` and
reports `DZ` without reporting `OF`.

TLOG supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
and `E5M2`. Integer, exponent-only, other compact floating, and packed
DataTypes reject before effects. Its closed Local unary SFU schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal; TLOG uses the selected
profile's fixed/default rounding behavior.

TLOG takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes source snapshot and SFU
evaluation; the result, numeric status, padding definedness, and destination
descriptor publish atomically. Rejection has no architectural effect.

## Decision 075: `TRECIP` is floating-only same-type reciprocal

`TRECIP` is selected by TEPL carrier `Mode=0, Function=20` and executes on the
`SFU` engine without changing the TEPL carrier encoding. It reads one Local
floating source Tile and writes one explicit renamed Local destination of the
same DataType. Each valid destination element is the selected numeric
profile's same-type reciprocal `1.0/source`. The profile owns finite
approximation accuracy, rounding, overflow, underflow, inexact reporting, NaN
propagation, and canonical result requirements.

Positive and negative zero produce positive and negative infinity respectively
and report divide-by-zero; they do not make the instruction illegal. Positive
and negative infinity produce positive and negative zero respectively. A quiet
NaN produces the profile's quiet-NaN result; a signaling NaN additionally
reports invalid and produces a quiet NaN.

`E4M3` does not encode infinity. `TRECIP` does not admit saturation, so either
`E4M3` signed zero produces the canonical quiet NaN `0x7F` and reports `DZ`
without reporting `OF`.

TRECIP supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`E4M3`, and `E5M2`. Integer, exponent-only, other compact floating, and packed
DataTypes reject before effects. Its closed Local unary SFU schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal; TRECIP uses the selected
profile's fixed/default rounding behavior.

TRECIP takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes source snapshot and SFU
evaluation; the result, numeric status, padding definedness, and destination
descriptor publish atomically. Rejection has no architectural effect.

## Decision 076: `TSQRT` is floating-only same-type square root

`TSQRT` is selected by TEPL carrier `Mode=0, Function=21` and executes on the
`SFU` engine without changing the TEPL carrier encoding. It reads one Local
floating source Tile and writes one explicit renamed Local destination of the
same DataType. Each valid destination element is the selected numeric
profile's same-type square root. The profile owns finite approximation
accuracy, rounding, underflow, inexact reporting, NaN propagation, and
canonical result requirements.

Square root preserves the sign of positive and negative zero, maps positive
infinity to positive infinity, and maps every negative finite nonzero value
and negative infinity to a quiet NaN while reporting invalid. A quiet NaN
produces the profile's quiet-NaN result; a signaling NaN additionally reports
invalid and produces a quiet NaN.

TSQRT supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`E4M3`, and `E5M2`. Integer, exponent-only, other compact floating, and packed
DataTypes reject before effects. Its closed Local unary SFU schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal; TSQRT uses the selected
profile's fixed/default rounding behavior.

TSQRT takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes source snapshot and SFU
evaluation; the result, numeric status, padding definedness, and destination
descriptor publish atomically. Rejection has no architectural effect.

## Decision 077: `TRSQRT` is floating-only same-type reciprocal square root

`TRSQRT` is selected by TEPL carrier `Mode=0, Function=22` and executes on the
`SFU` engine without changing the TEPL carrier encoding. It reads one Local
floating source Tile and writes one explicit renamed Local destination of the
same DataType. Each valid destination element is the selected numeric
profile's same-type reciprocal square root `1.0/sqrt(source)`. The profile
owns finite approximation accuracy, rounding, overflow, underflow, inexact
reporting, NaN propagation, and canonical result requirements; the operation
is one profile operation rather than two architecturally rounded instructions.

Positive and negative zero produce positive and negative infinity respectively
and report divide-by-zero; they do not make the instruction illegal. Positive
infinity produces positive zero. Every negative finite nonzero value and
negative infinity produce a quiet NaN and report invalid. A quiet NaN produces
the profile's quiet-NaN result; a signaling NaN additionally reports invalid
and produces a quiet NaN.

`E4M3` does not encode infinity. `TRSQRT` does not admit saturation, so either
`E4M3` signed zero produces the canonical quiet NaN `0x7F` and reports `DZ`
without reporting `OF`.

TRSQRT supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`E4M3`, and `E5M2`. Integer, exponent-only, other compact floating, and packed
DataTypes reject before effects. Its closed Local unary SFU schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal; TRSQRT uses the selected
profile's fixed/default rounding behavior.

TRSQRT takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes source snapshot and SFU
evaluation; the result, numeric status, padding definedness, and destination
descriptor publish atomically. Rejection has no architectural effect.

## Decision 078: `TRELU` is a same-type Local VEC rectifier

`TRELU` is selected by TEPL carrier `Mode=0, Function=23` and executes on the
`VEC` engine without changing the TEPL carrier encoding. It reads one Local
source Tile and writes one explicit renamed Local destination of the same
DataType. For a signed integer element, a negative value produces
element-width zero and a nonnegative value is preserved. For an unsigned
integer element, TRELU is the identity operation.

For a floating element, every negative finite value and negative infinity
produce positive zero; positive finite values and positive infinity are
preserved; and both positive and negative zero produce positive zero. A quiet
NaN produces the selected numeric profile's quiet-NaN result. A signaling NaN
also reports invalid and produces a quiet NaN. The selected profile owns NaN
payload propagation or canonicalization details.

TRELU supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`.
Exponent-only, other compact floating, packed, pointer, and every other
DataType reject before effects. Its closed Local unary VEC schema requires
nonzero `LB0=ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`; and physical rows derive from capacity, `Col`, and DataType.
Source and destination MUST match in physical and valid shape, row-major
layout, and DataType, and every valid source element MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null`. Explicit nondefault `CMode`, `Sat`, `Canonicalize`,
secondary `DataType`, `RMode`, or `Layout` is illegal.

TRELU takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete preflight precedes source snapshot and VEC
evaluation; the result, numeric status, padding definedness, and destination
descriptor publish atomically. Rejection has no architectural effect.

## Decision 079: `TSEL` consumes a packed one-bit predicate Tile

`TSEL` is selected by TEPL carrier `Mode=0, Function=26` and executes on the
`VEC` engine. It reads one Local predicate mask Tile and two Local numeric data
Tiles, then writes one explicit renamed Local numeric destination. For logical
element index `i`, mask bit `i mod 8` of byte `floor(i/8)` selects the true
source when one and the false source when zero. Lower logical indices occupy
lower bit positions. The mask MUST use predicate-kind storage produced under
the packed predicate contract; an ordinary numeric Tile is not a legal mask.

The two data sources and destination MUST have identical physical shape,
logical shape, valid shape, row-major layout, and DataType. The mask has the
same logical `Row`, `Col`, `ValidRow`, and `ValidCol`, uses packed predicate
storage with capacity of at least `ceil(Row*Col/8)` bytes, and has every
predicate bit in the valid region defined. Every valid element of both data
sources MUST also be defined. Selection copies the chosen source element's
encoding exactly; it performs no numeric conversion, rounding, saturation,
NaN canonicalization, or floating-status update.

TSEL supports data sources and destination of exactly `FP64`, `FP32`, `TF32`,
`HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`,
`U32`, `U16`, and `U8`. Every other numeric DataType and every non-predicate
mask reject before effects. Required nonzero `LB0` supplies `ValidCol`;
omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and data
Tile physical rows derive from capacity, `Col`, and DataType.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `00` selects `Zero`, `01` selects `Max`, `10` selects `Min`,
and `11` selects `Null` for destination elements outside the valid rectangle.
Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`,
`RMode`, or `Layout` is illegal.

TSEL takes no `B.IOR` or `B.IOS`. Every participating `B.IOT` binding MUST use
the same `PE_MASK`, and mask zero is a strict no-op. All three sources persist;
the two data sources MAY be identical and MAY alias the destination. Complete
preflight precedes predicate and data-source snapshots. The selected payload,
padding definedness, and destination descriptor publish atomically, and
rejection has no architectural effect.

## Decision 080: `TCVT` is the complete typed conversion and canonicalization boundary

`TCVT` is selected by TEPL carrier `Mode=0, Function=27` and executes on the
`VEC` engine. It reads one Local source Tile and writes one explicit renamed
Local destination. The DataType selected by `BSTART.VEC TCVT` is the source
type. An optional `B.DATR.DataType` is the destination type; when that field is
omitted, the destination type inherits the source type. An explicitly encoded
zero selects destination `FP64` and never means inheritance.

Every assigned Tile DataType may be a TCVT source or destination: `FP64`,
`FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `HiF8`, `E4M3`, `E5M2`, `E3M2`,
`E2M3`, `E2M1X2`, `E1M2X2`, `E8M0`, `HiF4X2`, `S64`, `S32`, `S16`, `S8`,
`S4X2`, `U64`, `U32`, `U16`, `U8`, and `U4X2`. Globally reserved DataType
codes reject before effects. `HiF4X2` is supported only by TCVT; using it with
another Tile operation is illegal unless a later architecture revision
explicitly assigns that support.

The source and destination have equal logical `Row`, `Col`, `ValidRow`, and
`ValidCol`, but their physical byte capacities and element packing follow
their own DataTypes and layouts. Packed-X2 formats retain one logical element
per nibble: even logical indices occupy the low nibble and odd logical indices
occupy the high nibble of the same byte. Required nonzero `LB0` supplies
`ValidCol`; omitted `LB1` gives `ValidRow=1`; omitted `LB2` gives
`Col=ValidCol`. Source and destination capacity MUST contain their complete
physical representations, and every valid source element MUST be defined.

`RMode` code zero selects the operation default; code one explicitly selects
RNE; codes two through seven select RTZ, RTM, RTP, RNA, RTO, and RHB
respectively. The operation default is RTZ for floating-to-integer conversion
and RNE for every other conversion that requires rounding. `Sat` omission or
zero disables saturation; `Sat=1` clamps an out-of-range finite result to the
destination type's minimum or maximum before encoding. Without saturation,
integer-to-integer narrowing is modulo the destination width; the selected
numeric profile defines floating overflow, invalid, NaN, infinity, subnormal,
inexact, and format-specific finite conversion results without leaving them
implementation-defined.

`Canonicalize=1` is legal only when the source carries the private CUBE output
representation. It converts that representation into the standard public
left-matrix Tile representation, including any DataType-dependent fractal
merge or split, and requires `Layout=NORM`. A private CUBE source requires
`Canonicalize=1`; an ordinary source requires `Canonicalize=0`.

With `Canonicalize=0`, `Layout=NORM` preserves logical row-major placement;
each of the other twelve assigned Layout codes applies its assigned complete
layout transformation. Every reserved Layout value rejects before effects.
`PadValueOrByteId` is also applicable: omission selects `Null`, while explicit
`00`, `01`, `10`, and `11` select `Zero`, `Max`, `Min`, and `Null` for the
destination region outside the valid rectangle. `CMode` is not applicable and
every explicit nonzero `CMode` is illegal.

TCVT takes no `B.IOR` or `B.IOS`, requires equal source and destination
`PE_MASK` values, and mask zero is a strict no-op. The source persists and MAY
alias the destination. Complete type, encoding, geometry, capacity, layout,
canonicalization, and source-definedness preflight precedes source snapshot
and destination allocation. Converted payload, numeric status, padding
definedness, representation state, and destination descriptor publish
atomically; rejection has no architectural effect.

## Decision 081: `TFMA` is one same-type fused elementwise multiply-add

`TFMA` is selected by TEPL carrier `Mode=0, Function=28` and executes on the
`VEC` engine. It reads Local multiplicand-left, multiplicand-right, and addend
Tiles and writes one explicit renamed Local destination. Each floating result
is one fused `left * right + addend` operation with no architecturally rounded
intermediate product and exactly one selected-profile rounding at the final
result. Each signed or unsigned integer result is the same expression modulo
the element width. Verification-carrier bits above an integer element width
are zero.

TFMA supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Every other
DataType rejects before effects. All three sources and the destination MUST
match physical shape, valid shape, row-major layout, and DataType, and every
valid source element MUST be defined.

For floating DataTypes, the selected numeric profile owns final rounding,
overflow, underflow, inexact, subnormal, NaN payload, and canonical-result
details while preserving fused evaluation. Signaling NaNs report invalid and
produce a quiet NaN. Zero multiplied by infinity, infinity multiplied by zero,
and an infinite product combined with an opposite-signed infinite addend also
report invalid and produce a quiet NaN. Other quiet NaNs propagate according
to the profile. TFMA does not consume an encoded `RMode`, `Sat`, or
`Canonicalize`; it uses the profile's fixed/default arithmetic rounding.

The closed Local ternary VEC schema requires nonzero `LB0=ValidCol`; omitted
`LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows
derive from capacity, `Col`, and DataType. `PadValueOrByteId` is the only
applicable `B.DATR` field. Omission selects `Null`; explicit `00`, `01`, `10`,
and `11` select `Zero`, `Max`, `Min`, and `Null`. Explicit nondefault `CMode`,
`Sat`, `Canonicalize`, secondary `DataType`, `RMode`, or `Layout` is illegal.

TFMA takes no `B.IOR` or `B.IOS`. Every participating `B.IOT` binding MUST use
the same `PE_MASK`, and mask zero is a strict no-op. Sources persist, may be
identical, and any source MAY alias the destination. Complete preflight
precedes snapshots of all three source payloads. The fused result, numeric
status, padding definedness, and destination descriptor publish atomically;
rejection has no architectural effect.
