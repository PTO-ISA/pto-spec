---
{
  "id": "ADR-0112",
  "title": "Tile operation type roles and source reinterpretation",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["PTO ISA maintainers"],
  "created": "2026-08-30",
  "accepted": "2026-08-30",
  "rejected": null,
  "superseded": null,
  "baseline": "0d3365264eee82827214e7240c8aeaf270a6f94a",
  "target_releases": ["0.58.5"],
  "release_boundary": true,
  "affected_ndf": [
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
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/162",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0112: Tile operation type roles and source reinterpretation

## Context

Issue #162 exposes a boundary between the C++/PTO programming model and the
PTO ISA/ASL model. The programming model can form a zero-instruction typed
reinterpretation of a Tile view, while the current runtime descriptor retains
the DataType of the last producing instruction. If the ISA model requires an
exact source-descriptor DataType match, a sequence such as:

```text
TADD.BF16  T#2, T#3 -> T#1
TANDS.U16  T#1, scalar -> T#4
TMULS.BF16 T#4, scalar -> T#5
```

cannot be represented even though each operation can legally interpret the
same-width stored carrier. A zero-instruction reinterpretation cannot be
observed by ASL unless it changes architectural state or is encoded in the
instruction stream. This ADR chooses the non-architectural, zero-instruction
boundary and therefore makes source-language reinterpretation provenance
unobservable to ISA/ASL.

This record is scoped to operation type roles and source carrier
reinterpretation. It does not redefine unrelated mask, allocation,
completion, restart, definedness, padding, numeric-status, or publication
contracts.

## Decision

### Type roles

For an operation with one effective operation type, the operation type is the
current execution interpretation and the result backing type:

```text
operation_type = source interpretation type
operation_type = execution type
operation_type = destination backing dtype
```

The source Tile descriptor's stored/backing dtype does not have to equal
`operation_type`. The source is readable when its stored representation can be
interpreted as the operation type under the rules below.

For a source with BF16 backing storage consumed by `TANDS.U16`, the operation
reads the source as raw U16 carrier bits and produces a new U16-backed
 destination. It does not preserve BF16 as the destination type merely
because the source was BF16-backed.

For a later BF16 consumer, the C++/PTO IR is responsible for an explicit
reinterpretation of the produced Tile view. That reinterpretation is not an
ISA instruction, has no ASL-visible provenance, and performs no data movement.
ASL validates only the operation and the physical Tile state it can observe.

### Source readability

A source Tile is readable under an operation type when all of the following
hold:

- the source stored carrier has the same element bit width as the operation
  type;
- the operation's required physical and valid geometry is representable by
  that carrier interpretation;
- layout and storage kind satisfy the operation's existing applicability
  rules;
- the required source bytes and element definedness are present; and
- any operation-specific legality is satisfied under the operation type.

The rule is about physical carrier compatibility, not reinterpretation
provenance. ASL must not attempt to determine whether source-language code
previously emitted `reinterpret_tile`.

For numeric operations, encoding validity, signedness, exceptional values,
rounding, and numeric status are evaluated using the operation type. A BF16
consumer therefore validates a U16-backed source as BF16, not as U16.

For raw logical and carrier operations, payload bits are consumed and
produced as raw carrier data. They do not reject a source because its bits are
not a valid numeric encoding for the source descriptor's backing dtype.

### Covered ordinary operation families

This rule applies to the ordinary non-specialized Tile numeric, logical, and
shift consumers in this first landing:

- tile-tile numeric operations: `TADD`, `TSUB`, `TMUL`, `TDIV`, `TREM`,
  `TMAX`, and `TMIN`;
- tile-scalar numeric operations: `TADDS`, `TSUBS`, `TMULS`, `TDIVS`,
  `TREMS`, `TMAXS`, and `TMINS`;
- unary/transcendental numeric consumers: `TABS`, `TNEG`, `TRELU`, `TRECIP`,
  `TRSQRT`, `TSQRT`, `TEXP`, and `TLOG`;
- raw logical operations: `TAND`, `TANDS`, `TOR`, `TORS`, `TXOR`, and
  `TXORS`; and
- shifts: `TSHL`, `TSHLS`, `TSHR`, and `TSHRS`.

For shifts, the value source may be a floating or integer carrier when its
width matches the selected operation type. The shift-count source must be an
integer carrier with the required width. The shift operation does not require
the value source descriptor dtype to equal the operation type.

Predicate-producing operations, predicate-consuming operations, fused or
specialized matrix/cube operations, reductions, quantization/dequantization,
and other operation families not listed above retain their existing contracts
and are not silently broadened by this ADR.

### TCVT

`TCVT` has two independent operation type roles:

```text
source_operation_type       = source interpretation type
destination_operation_type  = destination result/backing type
```

The source Tile backing dtype need not equal `source_operation_type`, but the
stored source representation must have the same carrier width and must be
validated under `source_operation_type` before conversion.

The newly allocated destination backing dtype must equal
`destination_operation_type`. Destination layout, shape, capacity, and
encoding rules continue to follow the existing TCVT contract for the selected
source/destination type pair.

### Layout and carrier operations

For pure layout/carrier operations, the operation DataType identifies the
carrier/execution width and does not replace the source semantic/backing type.
The newly allocated destination inherits the source backing dtype:

```text
operation_type       = carrier/execution type
source backing dtype = preserved
 destination backing dtype = source backing dtype
```

The source and destination must still satisfy the operation's existing
geometry, layout, storage-kind, definedness, capacity, and allocation rules.
The operation performs no numeric conversion and does not apply numeric
encoding legality to the transported raw payload.

For a multi-source pure layout operation, all data sources must be carrier
width compatible. Where one logical destination type is required, the data
sources must agree on the backing dtype; auxiliary index/control sources keep
their operation-specific integer carrier rules.

This rule allows a C++/PTO IR layout move of a BF16 Tile to use an ISA U16
carrier without requiring a user-visible reinterpret solely for the move, while
preserving BF16 as the destination backing type.

Packed/lanewise formats whose physical carrier grid is not element-width
preserving, including `E1M2X2`, `E2M1X2`, `E4M3X2`, and `U4X2`, are outside this
first landing. E8M0 is allowed as an 8-bit raw carrier; raw operations may
modify its bits, and later consumers observe those bits without an implicit
repair of scale semantics.

### Destination and alias boundary

This ADR does not add alias or reuse semantics. For issue #162's first
landing, every operation destination is a newly allocated Tile selected by the
existing B.IOT destination mechanism. No new alias bit, descriptor retagging,
in-place raw mutation, or source/destination alias encoding is introduced.

Source persistence, source snapshots, atomic publication, and rejection with
no architectural effects remain unchanged. Any future typed-view alias or
same-storage write/version semantics requires a separate architecture
 decision and issue.

## Compatibility and protected behavior

The following existing behavior remains protected unless an affected owner
must be mechanically updated to express this decision:

- operation selectors, instruction encodings, and B.IOT binding grammar;
- mask and zero-mask behavior;
- physical and valid shape rules not directly implied by carrier width;
- layout and storage-kind applicability;
- source definedness and padding definedness;
- destination capacity and allocation faults;
- source snapshot and atomic destination publication;
- numeric status transaction and existing operation-specific numeric rules;
- restart/completion and precise fault ordering; and
- all specialized operation contracts excluded above.

ADR-0080 and ADR-0081 remain in force for their unaffected decisions. This ADR
overrides only their conflicting exact source/destination DataType clauses for
the operation families explicitly covered here.

## Implementation boundary

The authoritative implementation owners are expected to update the common
source-readability/type-role helpers before or together with instruction
contracts. The implementation must not create an ASL-visible reinterpret
instruction or a hidden view table.

The primary owner surfaces are:

- `asl/tile/model/legality/dtype-layout.asl`;
- `asl/tile/model/legality/operand-schema.asl`;
- `asl/tile/model/legality/layout-rearrangement.asl`;
- `asl/tile/model/legality/memory-schema.asl`;
- `asl/tile/model/execution/elementwise.asl`;
- `asl/tile/model/execution/unary.asl`;
- `asl/tile/model/execution/rearrangement.asl`;
- `asl/tile/model/numeric/formats.asl`;
- `asl/block/model/dispatch/destination-shape.asl`;
- `asl/block/model/dispatch/tcvt-schema.asl`;
- `asl/block/model/dispatch/tcvt-destination.asl`; and
- the affected instruction ASL/NDF owners named in the frontmatter.

Generated Markdown, catalogs, AVS, ADR index, readiness, and traceability
surfaces remain projections of these authoritative sources.

## Acceptance evidence

The implementation must provide focused executable evidence for:

1. a BF16-backed source consumed by `TANDS.U16` and published as a U16-backed
   new destination;
2. a U16-backed source consumed by `TMULS.BF16`, with source encoding checked
   under BF16;
3. raw `TAND`/`TANDS`/`TOR`/`TORS`/`TXOR`/`TXORS` and shift cases with
   same-width cross-category carriers;
4. a floating value carrier plus an integer shift-count carrier;
5. TCVT with a source backing dtype different from its source operation type
   and a destination backing dtype equal to its destination type;
6. a BF16 layout transport using a U16 carrier while preserving BF16 as the
   destination backing dtype;
7. E8M0 raw-carrier behavior;
8. width mismatch, unsupported layout, undefined source, invalid numeric
   encoding, insufficient capacity, and other pre-existing fault classes; and
9. explicit proof that #162 does not add alias/reuse or packed-format behavior.

## Implementation readiness

ADR-0112 is accepted based on the explicit architecture confirmation for this
design. The implementation must keep all affected generated projections aligned
with the authoritative ASL/NDF owners. Executor dispatch remains a separate
workflow action and is intentionally not started by this decision record.
