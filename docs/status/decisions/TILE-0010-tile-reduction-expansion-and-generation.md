---
{
  "id": "ADR-TILE-0010",
  "title": "Tile reduction, expansion, and generation",
  "title_zh": "Tile 归约、扩展与生成操作",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-21",
  "accepted": "2026-08-21",
  "rejected": null,
  "superseded": null,
  "baseline": "1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f",
  "target_releases": [
    "0.58.1",
    "0.58.2"
  ],
  "affected_ndf": [
    "PTO-B-DATR-FIELDS-001",
    "PTO-B-IOR-BINDING-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-CUBE-CELL-TRANSPORT-001",
    "PTO-TCI-CONTRACT-001",
    "PTO-TCOLARGMAX-CONTRACT-001",
    "PTO-TCOLARGMIN-CONTRACT-001",
    "PTO-TCOLEXPAND-CONTRACT-001",
    "PTO-TCOLEXPANDADD-CONTRACT-001",
    "PTO-TCOLEXPANDDIV-CONTRACT-001",
    "PTO-TCOLEXPANDEXPDIF-CONTRACT-001",
    "PTO-TCOLEXPANDMAX-CONTRACT-001",
    "PTO-TCOLEXPANDMIN-CONTRACT-001",
    "PTO-TCOLEXPANDMUL-CONTRACT-001",
    "PTO-TCOLEXPANDSUB-CONTRACT-001",
    "PTO-TCOLMAX-CONTRACT-001",
    "PTO-TCOLMIN-CONTRACT-001",
    "PTO-TCOLPROD-CONTRACT-001",
    "PTO-TCOLSUM-CONTRACT-001",
    "PTO-TCONCAT-CONTRACT-001",
    "PTO-THISTOGRAM-CONTRACT-001",
    "PTO-TROWARGMAX-CONTRACT-001",
    "PTO-TROWARGMIN-CONTRACT-001",
    "PTO-TROWEXPAND-CONTRACT-001",
    "PTO-TROWEXPANDADD-CONTRACT-001",
    "PTO-TROWEXPANDDIV-CONTRACT-001",
    "PTO-TROWEXPANDEXPDIF-CONTRACT-001",
    "PTO-TROWEXPANDMAX-CONTRACT-001",
    "PTO-TROWEXPANDMIN-CONTRACT-001",
    "PTO-TROWEXPANDMUL-CONTRACT-001",
    "PTO-TROWEXPANDSUB-CONTRACT-001",
    "PTO-TROWMAX-CONTRACT-001",
    "PTO-TROWMIN-CONTRACT-001",
    "PTO-TROWPROD-CONTRACT-001",
    "PTO-TROWSUM-CONTRACT-001",
    "PTO-TTRI-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-TILE-TCI",
    "PTO-TILE-TCOLARGMAX",
    "PTO-TILE-TCOLARGMIN",
    "PTO-TILE-TCOLEXPAND",
    "PTO-TILE-TCOLEXPANDADD",
    "PTO-TILE-TCOLEXPANDDIV",
    "PTO-TILE-TCOLEXPANDEXPDIF",
    "PTO-TILE-TCOLEXPANDMAX",
    "PTO-TILE-TCOLEXPANDMIN",
    "PTO-TILE-TCOLEXPANDMUL",
    "PTO-TILE-TCOLEXPANDSUB",
    "PTO-TILE-TCOLMAX",
    "PTO-TILE-TCOLMIN",
    "PTO-TILE-TCOLPROD",
    "PTO-TILE-TCOLSUM",
    "PTO-TILE-TCONCAT",
    "PTO-TILE-THISTOGRAM",
    "PTO-TILE-TROWARGMAX",
    "PTO-TILE-TROWARGMIN",
    "PTO-TILE-TROWEXPAND",
    "PTO-TILE-TROWEXPANDADD",
    "PTO-TILE-TROWEXPANDDIV",
    "PTO-TILE-TROWEXPANDEXPDIF",
    "PTO-TILE-TROWEXPANDMAX",
    "PTO-TILE-TROWEXPANDMIN",
    "PTO-TILE-TROWEXPANDMUL",
    "PTO-TILE-TROWEXPANDSUB",
    "PTO-TILE-TROWMAX",
    "PTO-TILE-TROWMIN",
    "PTO-TILE-TROWPROD",
    "PTO-TILE-TROWSUM",
    "PTO-TILE-TTRI"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-GOV-0006"
  ],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "not-required",
  "legacy_ids": [
    "PRD-097",
    "PRD-098",
    "PRD-099",
    "PRD-100",
    "PRD-101",
    "PRD-102",
    "PRD-103",
    "PRD-104",
    "PRD-105",
    "PRD-106",
    "PRD-107",
    "PRD-108",
    "PRD-109",
    "PRD-110",
    "PRD-111",
    "PRD-112",
    "PRD-113",
    "PRD-114",
    "PRD-115",
    "PRD-116",
    "PRD-117",
    "PRD-118",
    "PRD-119",
    "PRD-120",
    "PRD-121",
    "PRD-122",
    "PRD-123",
    "PRD-124",
    "PRD-125",
    "PRD-129",
    "PRD-130",
    "PRD-131",
    "PRD-132",
    "ADR-0082"
  ]
}
---
# ADR-TILE-0010: Tile reduction, expansion, and generation

## Context

ADR 0062 recorded a single repository-wide mnemonic audit. This record preserves the accepted decisions for this family as one decision-scoped owner. The former identifiers remain only in `legacy_ids` and the generated ADR index; current normative meaning is owned by the affected ASL/NDF clauses.

## Decisions

## Decision 097: `TROWSUM` reduces each valid row in increasing-column order

`TROWSUM` is selected by TEPL carrier `Mode=2, Function=0` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each source row `r` in increasing order, it
forms a left fold over source columns `0` through `ValidCol-1` in increasing
order, beginning with the selected DataType's positive/all-zero value. Each
profile-defined addition step produces the next accumulator, and the final
accumulator is written to destination element `[r,0]`.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Integer addition follows the selected
element-width result rule; floating addition, intermediate rounding,
exceptional values, and numeric status follow the selected profile at every
fold step.

`LB0=ValidCol` is required and nonzero; omitted `LB1` gives source
`ValidRow=1`; omitted `LB2` gives source `Col=ValidCol`; and source physical
rows derive from source capacity, `Col`, and DataType. The source is row-major,
its complete valid rectangle MUST be defined, and
`ValidRow <= Row`, `ValidCol <= Col`. The destination valid shape is exactly
`source.ValidRow x 1`, its physical column count is exactly one, and its
physical row count derives from destination capacity and DataType and MUST be
at least `source.ValidRow`. The destination is row-major.

`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `Zero`, `Max`, and `Min` define destination physical elements
outside `source.ValidRow x 1` using the selected DataType, while `Null` leaves
them undefined. Explicit nondefault `CMode`, `Sat`, `Canonicalize`, secondary
`DataType`, `RMode`, or `Layout` is illegal. `B.IOR` and `B.IOS` are illegal.

The source and destination `B.IOT` bindings use the same `PE_MASK`; any PE
subset is legal and mask zero is a strict no-op before source reads,
allocation, or faults. The source persists. Complete descriptor, field, type,
dimension, capacity, mask, allocation, and source-definedness preflight
precedes the source snapshot. Numeric status, all reduction results, padding
definedness, and the destination descriptor publish atomically; rejection has
no architectural effect.

## Decision 098: `TROWMAX` applies typed maximum across each valid row

`TROWMAX` is selected by TEPL carrier `Mode=2, Function=1` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source row, the accumulator starts
with column zero and folds columns one through `ValidCol-1` in increasing
order using exactly the typed maximum operation defined for `TMAX`. The final
value is written to destination element `[r,0]`.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Signed and
unsigned integers use their respective numeric order. Floating one-NaN,
two-NaN, signaling-NaN status, canonical-NaN, and signed-zero tie behavior is
identical to Decision 067 in ADR-TILE-0008, including positive zero for a mixed-sign maximum tie.
Invalid source encodings reject before effects.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `ValidRow x 1` logical shape, one physical destination
column, capacity-derived destination rows, matching DataType, and bounds follow
Decision 097 in ADR-TILE-0010. `PadValueOrByteId` is the only applicable `B.DATR` field and follows
Decision 097 in ADR-TILE-0010 for every physical destination element outside the valid one-column
result. `B.IOR` and `B.IOS` are illegal.

Source and destination `B.IOT` bindings use the same `PE_MASK`; any PE subset
is legal and mask zero is a strict no-op before reads, allocation, or faults.
The source persists. Complete preflight precedes the source snapshot. Floating
invalid status, results, padding definedness, and the destination descriptor
publish atomically; rejection has no architectural effect.

## Decision 099: `TROWMIN` applies typed minimum across each valid row

`TROWMIN` is selected by TEPL carrier `Mode=2, Function=2` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source row, the accumulator starts
with column zero and folds columns one through `ValidCol-1` in increasing
order using exactly the typed minimum operation defined for `TMIN`. The final
value is written to destination element `[r,0]`.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Signed and
unsigned integers use their respective numeric order. Floating one-NaN,
two-NaN, signaling-NaN status, canonical-NaN, and signed-zero tie behavior is
identical to Decision 068 in ADR-TILE-0008, including negative zero for a mixed-sign minimum tie.
Invalid source encodings reject before effects.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `ValidRow x 1` logical shape, one physical destination
column, capacity-derived destination rows, matching DataType, and bounds follow
Decision 097 in ADR-TILE-0010. `PadValueOrByteId` is the only applicable `B.DATR` field and follows
Decision 097 in ADR-TILE-0010 for every physical destination element outside the valid one-column
result. `B.IOR` and `B.IOS` are illegal.

Source and destination `B.IOT` bindings use the same `PE_MASK`; any PE subset
is legal and mask zero is a strict no-op before reads, allocation, or faults.
The source persists. Complete preflight precedes the source snapshot. Floating
invalid status, results, padding definedness, and the destination descriptor
publish atomically; rejection has no architectural effect.

## Decision 100: `TROWPROD` reduces each valid row with typed multiplication

`TROWPROD` is selected by TEPL carrier `Mode=2, Function=3` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source row, it performs an
increasing-column left fold over columns zero through `ValidCol-1`. The
accumulator begins with the selected DataType's exact multiplicative identity
and every fold step uses exactly the typed multiplication operation defined for
`TMUL`; the final value is written to destination element `[r,0]`.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Integer multiplication follows the selected
element-width overflow rule. Floating multiplication, intermediate rounding,
exceptional values, and numeric status follow the selected profile at every
fold step.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `ValidRow x 1` logical shape, one physical destination
column, capacity-derived destination rows, matching DataType, and bounds follow
Decision 097 in ADR-TILE-0010. `PadValueOrByteId` is the only applicable `B.DATR` field and follows
Decision 097 in ADR-TILE-0010 for every physical destination element outside the valid one-column
result. `B.IOR` and `B.IOS` are illegal.

Source and destination `B.IOT` bindings use the same `PE_MASK`; any PE subset
is legal and mask zero is a strict no-op before reads, allocation, or faults.
The source persists. Complete preflight precedes the source snapshot. Numeric
status, results, padding definedness, and the destination descriptor publish
atomically; rejection has no architectural effect.

## Decision 101: `TROWEXPAND` broadcasts one one-column source across destination rows

`TROWEXPAND` is selected by TEPL carrier `Mode=2, Function=4` and executes on
the `SFU` engine. It reads exactly one Local source Tile and writes one explicit
newly allocated Local destination. The source has
`ValidRow == destination.ValidRow`, `ValidCol == 1`, and `Col == 1`. For every
valid destination element `[r,c]`, the operation copies the source element
`[r,0]` exactly. There is no second full-shape source operand and no otherwise
unread source payload.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Expansion copies element encodings without
conversion, rounding, saturation, canonicalization, or numeric-status change.

`LB0=destination.ValidCol` is required and nonzero; omitted `LB1` gives both
source and destination `ValidRow=1`; omitted `LB2` gives destination
`Col=ValidCol`; destination physical rows derive from capacity, `Col`, and
DataType. The destination is row-major and the complete one-column source valid
region MUST be defined. `PadValueOrByteId` is the only applicable `B.DATR`
field and follows Decision 097 in ADR-TILE-0010 over destination elements outside its valid rectangle.
`B.IOR` and `B.IOS` are illegal.

Source and destination `B.IOT` bindings use the same `PE_MASK`; any PE subset
is legal and mask zero is a strict no-op before reads, allocation, or faults.
The source persists. Complete preflight precedes the source snapshot. Valid
results, padding definedness, and the destination descriptor publish atomically;
rejection has no architectural effect.

## Decision 102: `TROWEXPANDADD` adds a one-column row broadcast source

`TROWEXPANDADD` is selected by TEPL carrier `Mode=2, Function=5` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local
one-column broadcast source, then writes one explicit newly allocated Local
destination. For every valid element `[r,c]`, the result is the selected
DataType's addition of `source0[r,c]` and `source1[r,0]`.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`; all others reject before effects. All operands use the same DataType.
Integer overflow and floating rounding, exceptional values, and numeric status
are exactly the typed addition rules of `TADD` for each element.

`source0` and the destination have identical physical shape, valid shape, and
row-major layout. `source1.ValidRow` equals their `ValidRow`, while
`source1.ValidCol == source1.Col == 1`; its physical rows derive from capacity.
Dimension defaults and bounds follow Decision 082 in ADR-TILE-0009. Both source valid regions MUST be
defined. `PadValueOrByteId` is the only applicable `B.DATR` field and applies
to every physical destination element outside the valid rectangle. `B.IOR`
and `B.IOS` are illegal.

All three `B.IOT` bindings use the same `PE_MASK`; partial masks are legal and
mask zero is a strict no-op before reads, allocation, or faults. Both sources
persist. Any otherwise legal source/destination alias uses read-old/write-new
behavior, with both source payloads snapshotted after complete preflight.
Numeric status, valid results, padding definedness, and the destination
descriptor publish atomically; rejection has no architectural effect.

## Decision 103: `TROWEXPANDSUB` subtracts a one-column row broadcast source

`TROWEXPANDSUB` is selected by TEPL carrier `Mode=2, Function=6` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local
one-column broadcast source, then writes one explicit newly allocated Local
destination. Operand order is fixed: for every valid `[r,c]`, the result is
`source0[r,c] - source1[r,0]` under the selected DataType. The reverse
subtraction is not an alias or alternate form.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
Decision 102 in ADR-TILE-0010. Integer overflow and floating rounding, exceptional values, signed
zeros, and numeric status are exactly the typed subtraction rules of `TSUB`
for each element.

## Decision 104: `TROWEXPANDMUL` multiplies by a one-column row broadcast source

`TROWEXPANDMUL` is selected by TEPL carrier `Mode=2, Function=7` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local
one-column broadcast source, then writes one explicit newly allocated Local
destination. For every valid `[r,c]`, the result is the selected DataType's
multiplication of `source0[r,c]` and `source1[r,0]`.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
Decision 102 in ADR-TILE-0010. Integer overflow and floating rounding, exceptional values, and
numeric status are exactly the typed multiplication rules of `TMUL` for each
element.

## Decision 105: `TROWEXPANDDIV` divides by a one-column row broadcast source

`TROWEXPANDDIV` is selected by TEPL carrier `Mode=2, Function=8` and executes
on the `SFU` engine. It reads one full-shape Local numerator source and one
Local one-column broadcast denominator source, then writes one explicit newly
allocated Local destination. Operand order is fixed: for every valid `[r,c]`,
the result is `source0[r,c] / source1[r,0]` under the selected DataType.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
Decision 102 in ADR-TILE-0010. Signed, unsigned, and floating division semantics follow Decision 060 in ADR-TILE-0008.
Any selected row whose integer broadcast denominator is zero causes Illegal
Block Exception before source snapshots, allocation publication, status, or
destination effects. Floating positive or negative zero is processed by the
selected floating profile and is not a block-legality failure.

## Decision 106: `TROWEXPANDMAX` takes typed maximum with a row broadcast source

`TROWEXPANDMAX` is selected by TEPL carrier `Mode=2, Function=9` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local
one-column broadcast source, then writes one explicit newly allocated Local
destination. For every valid `[r,c]`, the result is
`max(source0[r,c], source1[r,0])` under the selected DataType.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
Decision 102 in ADR-TILE-0010. Signed and unsigned ordering and floating one-NaN, two-NaN,
signaling-NaN, canonical-NaN, and signed-zero tie behavior follow Decision 067 in ADR-TILE-0008;
mixed-sign zero maximum produces positive zero.

## Decision 107: `TROWEXPANDMIN` takes typed minimum with a row broadcast source

`TROWEXPANDMIN` is selected by TEPL carrier `Mode=2, Function=10` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local
one-column broadcast source, then writes one explicit newly allocated Local
destination. For every valid `[r,c]`, the result is
`min(source0[r,c], source1[r,0])` under the selected DataType.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
Decision 102 in ADR-TILE-0010. Signed and unsigned ordering and floating one-NaN, two-NaN,
signaling-NaN, canonical-NaN, and signed-zero tie behavior follow Decision 068 in ADR-TILE-0008;
mixed-sign zero minimum produces negative zero.

## Decision 108: `TROWEXPANDEXPDIF` exponentiates a typed row-broadcast difference

`TROWEXPANDEXPDIF` is selected by TEPL carrier `Mode=2, Function=11` and
executes on the `SFU` engine. It reads one full-shape Local source and one
Local one-column broadcast source, then writes one explicit newly allocated
Local destination. For every valid `[r,c]`, it first computes the selected
same-type subtraction `difference = source0[r,c] - source1[r,0]` and then
writes the selected same-type natural exponential `exp(difference)`. Publishing
the raw subtraction result without the exponential is not conforming.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, and `E5M2`; every integer, exponent-only, compact, packed, or
reserved DataType encoding rejects before effects. All operands use the same
DataType. The subtraction stage follows the typed `TSUB` rules and the
exponential stage follows the typed `TEXP` rules. Each stage applies the
selected profile's rounding and numeric-status behavior; accumulated status is
part of the single architectural transaction. Signed zeros, infinities, quiet
and signaling NaNs, overflow, underflow, and inexact results follow those two
typed operations in sequence.

Exact source and destination geometry, row-major layout, dimension defaults,
source definedness, `PadValueOrByteId` applicability, prohibited `B.IOR` and
`B.IOS`, equal and zero mask rules, source persistence, legal alias snapshot
behavior, complete preflight, rollback, and atomic publication follow Decision 102 in ADR-TILE-0010.

## Decision 109: `TROWARGMAX` returns the lowest column index of each row maximum

`TROWARGMAX` is selected by TEPL carrier `Mode=2, Function=12` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. Each nonempty valid source row is scanned from
column zero through `ValidCol-1` in increasing order. Values are compared with
the selected DataType's `TMAX` rules. The destination element `[r,0]` is the
`U32` encoding of the winning column index. When multiple elements represent
the same maximum, the lowest column index wins.

The exact supported source DataTypes are `FP64`, `FP32`, `TF32`, `HF32`,
`FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; all others reject before effects. The destination DataType is
always `U32` and is independent of the selected source DataType. Signed,
unsigned, and floating ordering, one-NaN and two-NaN behavior, signaling-NaN
invalid status, canonical NaNs, and signed-zero preference follow `TMAX`.
Selecting a later value because it is the preferred maximum updates the index;
an equal value that does not replace the current maximum preserves the earlier
index.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `ValidRow x 1` logical shape, one physical destination
column, capacity-derived destination rows, and `PadValueOrByteId` application
to U32 destination padding follow Decision 097 in ADR-TILE-0010. `B.IOR` and `B.IOS` are illegal.
Source and destination `B.IOT` bindings use the same `PE_MASK`; any subset is
legal and mask zero is a strict no-op before reads, allocation, or faults. The
source persists. Complete preflight precedes the source snapshot. Numeric
status, U32 indices, padding definedness, and the destination descriptor
publish atomically; rejection has no architectural effect.

## Decision 110: `TROWARGMIN` returns the lowest column index of each row minimum

`TROWARGMIN` is selected by TEPL carrier `Mode=2, Function=13` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. Each nonempty valid source row is scanned from
column zero through `ValidCol-1` in increasing order. Values are compared with
the selected DataType's `TMIN` rules. The destination element `[r,0]` is the
`U32` encoding of the winning column index. When multiple elements represent
the same minimum, the lowest column index wins.

The exact supported source DataTypes are `FP64`, `FP32`, `TF32`, `HF32`,
`FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; all others reject before effects. The destination DataType is
always `U32` and is independent of the selected source DataType. Signed,
unsigned, and floating ordering, one-NaN and two-NaN behavior, signaling-NaN
invalid status, canonical NaNs, and signed-zero preference follow `TMIN`.
Selecting a later value because it is the preferred minimum updates the index;
an equal value that does not replace the current minimum preserves the earlier
index.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `ValidRow x 1` logical shape, one physical destination
column, capacity-derived destination rows, and `PadValueOrByteId` application
to U32 destination padding follow Decision 097 in ADR-TILE-0010. `B.IOR` and `B.IOS` are illegal.
Source and destination `B.IOT` bindings use the same `PE_MASK`; any subset is
legal and mask zero is a strict no-op before reads, allocation, or faults. The
source persists. Complete preflight precedes the source snapshot. Numeric
status, U32 indices, padding definedness, and the destination descriptor
publish atomically; rejection has no architectural effect.

## Decision 111: `TCOLSUM` reduces each valid column with typed addition

`TCOLSUM` is selected by TEPL carrier `Mode=2, Function=16` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source column, it performs an
increasing-row left fold over rows zero through `ValidRow-1`. The accumulator
begins with the selected DataType's exact additive identity and every fold step
uses exactly the typed addition operation defined for `TADD`; the final value
is written to destination element `[0,c]`. Tree reduction, scratch storage, and
implementation scheduling do not change this architectural order and are not
instruction operands.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Integer addition follows the selected
element-width overflow rule. Floating addition, intermediate rounding,
exceptional values, and numeric status follow the selected profile at every
fold step.

`LB0=source.ValidCol` is required and nonzero; omitted `LB1` gives
`source.ValidRow=1`; omitted `LB2` gives `source.Col=source.ValidCol`; source
physical rows derive from capacity. The source is row-major and its complete
valid rectangle MUST be defined. The destination has `ValidRow=1`,
`ValidCol=source.ValidCol`, `Col=source.Col`, and capacity-derived physical
rows. `PadValueOrByteId` is the only applicable `B.DATR` field and applies to
every physical destination element outside that one-row valid rectangle.
`B.IOR` and `B.IOS` are illegal.

Source and destination `B.IOT` bindings use the same `PE_MASK`; any PE subset
is legal and mask zero is a strict no-op before reads, allocation, or faults.
The source persists. Complete preflight precedes the source snapshot. Numeric
status, results, padding definedness, and the destination descriptor publish
atomically; rejection has no architectural effect.

## Decision 112: `TCOLMAX` reduces each valid column with typed maximum

`TCOLMAX` is selected by TEPL carrier `Mode=2, Function=17` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source column, the accumulator is
initialized from source row zero and rows one through `ValidRow-1` are folded
in increasing order with exactly the typed maximum operation defined for
`TMAX`. The final value is written to destination element `[0,c]`. The first
element is evaluated exactly once.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Signed and unsigned ordering and floating
one-NaN, two-NaN, signaling-NaN, canonical-NaN, and signed-zero behavior
follow `TMAX`; mixed-sign zero maximum produces positive zero.

Source dimensions, defaults, row-major layout, complete source definedness,
destination `1 x source.ValidCol` valid shape, destination physical shape,
`PadValueOrByteId` applicability, prohibited `B.IOR`/`B.IOS`, equal and zero
mask rules, source persistence, snapshot behavior, complete preflight,
numeric-status transaction, rollback, and atomic publication follow Decision 111 in ADR-TILE-0010.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Reductions, broadcasts, expansions, generators, concatenation, and histograms reshape data and often depend on traversal order. Without explicit fold order, tie rules, source shape, destination geometry, padding, and status publication, equivalent implementations could produce observably different Tiles.

归约、广播、扩展、生成、拼接和 histogram 会重塑数据，并常依赖遍历顺序。若不明确 fold 顺序、平局规则、源形状、目的几何、padding 和状态发布，等价实现可能产生可观察差异的 Tile。

### Detailed decision / 详细决策

The numbered decisions define row and column reductions with fixed traversal and tie behavior; row/column broadcast operations with exact source and destination shapes; scalar and structured generators; horizontal concatenation; triangular and sequence generation; and cumulative byte histograms. Common rules close applicable attributes, prohibited binders, masks, capacity, definedness, source snapshots, rollback, and atomic destination/status publication.

编号决策定义具有固定遍历与平局行为的行列归约、具有精确源/目的形状的行列广播、标量与结构化生成、水平拼接、三角与序列生成以及累计字节 histogram。通用规则闭合适用属性、禁止绑定、掩码、容量、已定义性、源快照、回滚及目的/状态原子发布。

### What changed / 改动内容

#### English

- Closed order-sensitive reduction, tie handling, index publication, and arg-reduction result ordering.
- Defined shape-transforming expansion, generation, concatenation, and histogram operations as complete transactions.
- Required destination shape, source coverage, and publication checks to finish before any output becomes visible.

#### 中文

- 闭合顺序敏感的归约与 arg-reduction 结果。
- 定义改变形状的扩展、生成、拼接和 histogram 事务。

### Scope and boundaries / 范围与边界

Only the listed operations and exact DataType/layout sets are covered. The record does not authorize alternative reduction order, extra axes, implicit temporary Tiles, or unlisted generator modes.

本记录仅覆盖所列操作及精确 DataType/布局集合；不授权替代归约顺序、额外轴、隐式临时 Tile 或未列生成模式。

## Decision 129: `TFILLPAD` materializes padding from one private-GPR scalar

`TFILLPAD` is selected by TEPL carrier `Mode=3, Function=5` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. The destination physical `Rows` and `Col` MUST
be at least the source physical `Rows` and `Col`, and its `ValidRow` and
`ValidCol` MUST be at least the source valid dimensions. Equality is the
ordinary form; larger destination dimensions are the expand form. Separate
`TFILLPAD_INPLACE` and `TFILLPAD_EXPAND` encodings are not assigned. A
same-Tile source/result binding is the in-place lowering and retains
read-old/write-new behavior.

For every destination logical coordinate, `TFILLPAD` copies the corresponding
source element when the coordinate lies inside the source valid rectangle.
Every other element of the destination physical Tile is written with one
typed padding scalar. The destination descriptor retains its configured valid
and physical dimensions; the operation makes the complete physical payload
defined.

The padding scalar is supplied exclusively by `B.IOR.RegSrc0`, resolved from
the selected PE's private GPR file. Its low selected-DataType element width is
used as the raw scalar encoding and higher GPR bits do not participate.
Omitting `B.IOR` selects the zero register as the operation-defined default;
an explicitly present all-zero `B.IOR` is a distinct descriptor but supplies
the same zero value. `RegSrc1`, `RegSrc2`, and `RegDst` are unused and MUST be
zero. Standard `Zero`, `Max`, and `Min` constants and arbitrary custom pad
constants are software-selected scalar encodings; they are not selected by
`B.DATR.PadValueOrByteId`. `PadValueOrByteId` is inapplicable to `TFILLPAD`
and every nonzero encoded value is illegal before effects.

The exact supported DataTypes are `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`E4M3`, `E5M2`, `S32`, `S16`, `S8`, `U32`, `U16`, and `U8`. Every other
DataType rejects before effects. Source and destination use the same selected
DataType. Assigned `Layout` values govern physical destination placement
without changing the logical copy-and-fill rule; every other explicit
nondefault data attribute is illegal.

`B.IOS` is illegal. Source and destination `B.IOT` bindings use the same
`PE_MASK`; any subset is legal and mask zero is a strict no-op before GPR or
Tile reads, allocation, or faults. The source persists. Complete descriptor,
schema, type, layout, dimension, capacity, GPR-binding, mask, allocation, and
source-valid-region definedness preflight precedes the source and scalar
snapshots. The full physical payload and destination descriptor publish
atomically; rejection has no architectural effect.

## Decision 130: `TCI` generates one typed single-row integer sequence

`TCI` is selected by TEPL carrier `Mode=3, Function=6` and executes on the
`SFU` engine. It writes one explicit newly allocated Local destination whose
`ValidRow` MUST equal one and whose `ValidCol` MUST be nonzero. Physical `Col`
defaults to `ValidCol` when `LB2` is omitted and MUST be at least
`ValidCol`; physical rows continue to derive from capacity. Only the first
valid row is part of the generated sequence. Other physical elements remain
padding with `Null` definedness.

`B.IOR.RegSrc0` supplies the start value and `RegSrc1` supplies the direction.
Both are read from the selected PE's private GPR file. The low selected
DataType width of `RegSrc0` is the raw start encoding and higher bits do not
participate. `RegSrc1` MUST contain exactly zero for ascending or one for
descending. `RegSrc2` and `RegDst` are unused and MUST be zero. Omitting
`B.IOR` supplies start zero and ascending direction. An explicitly present
all-zero `B.IOR` remains a distinct descriptor but supplies the same values.

For column `k` in `0..ValidCol-1`, ascending TCI writes `start+k` and
descending TCI writes `start-k`. Addition and subtraction wrap modulo the
selected element width. Sequence position is the contiguous logical column
index and does not include physical row-stride gaps.

The exact supported DataTypes are `S32`, `S16`, `U32`, and `U16`; every other
DataType rejects before effects. The destination is row-major. Every explicit
nondefault `B.DATR` field is illegal, including `PadValueOrByteId`, and
`B.IOS` is illegal.

The destination `B.IOT` may use any `PE_MASK`; mask zero is a strict no-op
before GPR reads, allocation, or faults. Complete schema, type, dimension,
capacity, GPR-value, mask, and allocation preflight precedes the GPR
snapshots. The valid sequence and destination descriptor publish atomically;
rejection has no architectural effect.

## Decision 131: `TTRI` generates a typed triangular matrix

`TTRI` is selected by TEPL carrier `Mode=3, Function=7` and executes on the
`SFU` engine. It writes one explicit newly allocated Local destination with
nonzero `ValidRow` and `ValidCol`. Physical `Col` defaults from `LB2` when it
is omitted and MUST be at least `ValidCol`; physical rows derive from the
allocated capacity. The destination uses row-major layout.

`B.IOR.RegSrc0` supplies a signed XLEN diagonal displacement in the inclusive
range `-65535..65535`. `RegSrc1` supplies the orientation and MUST contain
exactly zero for lower-triangular generation or one for upper-triangular
generation. `RegSrc2` and `RegDst` are unused and MUST be zero. Omitting
`B.IOR` supplies diagonal zero and lower orientation. An explicitly present
all-zero `B.IOR` remains a distinct descriptor but supplies the same values.

For every valid logical coordinate `[r,c]`, lower-triangular generation writes
typed one exactly when `c <= r + diagonal` and typed zero otherwise.
Upper-triangular generation writes typed one exactly when
`c >= r + diagonal` and typed zero otherwise. The signed boundary comparison
does not wrap at the Tile edges; extreme diagonal values therefore naturally
produce all-zero or all-one valid regions. Elements outside the valid
rectangle remain padding with `Null` definedness.

The exact supported DataTypes are `FP32`, `FP16`, `S32`, `S16`, `U32`, and
`U16`; every other DataType rejects before effects. Floating destinations use
the selected format's exact positive-zero and positive-one encodings. Every
explicit nondefault `B.DATR` field is illegal, including
`PadValueOrByteId`, and `B.IOS` is illegal.

The destination `B.IOT` may use any `PE_MASK`; mask zero is a strict no-op
before GPR reads, allocation, or faults. Complete schema, type, dimension,
capacity, GPR-value, mask, and allocation preflight precedes generation. The
valid payload and destination descriptor publish atomically; rejection has no
architectural effect.

## Decision 132: `THISTOGRAM` produces U32 cumulative byte histograms

`THISTOGRAM` is selected by TEPL carrier `Mode=3, Function=8` and executes on
the `SFU` engine. It reads one Local source Tile and one Local prefix-filter
Tile and writes one explicit newly allocated Local destination. The source
DataType is selected by `BSTART` and MUST be `U16` or `U32`. The destination
DataType is fixed to `U32`. `B.DATR` is therefore mandatory and MUST encode
destination `U32`; an omitted `B.DATR` retains its reset `FP64` DataType and
is illegal. Its `PadValueOrByteId` field is reinterpreted as `ByteId` values
zero through three. Every other nondefault `B.DATR` field is illegal.

The destination has `ValidRow = source.ValidRow` and `ValidCol = 256`, uses
row-major layout, has physical `Col >= 256`, and has enough capacity for all
valid output rows. For each valid source row, the operation forms 256 exact
counts and writes their inclusive prefix sum: destination `[row,k]` is the
number of accepted source elements in that row whose selected byte is less
than or equal to `k`. Because source `ValidCol` is bounded by the architectural
dimension encoding, each per-row count fits in `U32` without overflow.
Elements outside the destination valid rectangle remain padding with `Null`
definedness.

For a `U16` source, `ByteId=1` selects the high byte without filtering and
`ByteId=0` selects the low byte after requiring the element's high byte to
equal filter element `[row,0]`. Values two and three are illegal. The filter
Tile has DataType `U8`; for `ByteId=0` it has `ValidRow >= source.ValidRow`
and `ValidCol >= 1` and every consumed `[row,0]` element is defined.

For a `U32` source, `ByteId=3` selects the highest byte without filtering.
`ByteId=2`, one, and zero respectively require one, two, and three defined
global prefix bytes from filter elements `[0,0]`, `[1,0]`, and `[2,0]` and
select the next lower source byte only when all required higher bytes match.
The filter Tile has DataType `U8`, `ValidCol >= 1`, and at least the required
number of valid rows. Its physical row stride and unused columns do not add
semantic filter inputs.

The filter binding remains structurally present for the two unfiltered modes,
but its payload and shape are not read in those modes. Source and filter
Tiles persist. Source and destination use row-major layout; filter accesses
use its assigned logical layout. `B.IOS` is illegal. All participating
`B.IOT` bindings use the same `PE_MASK`; any subset is legal and mask zero is
a strict no-op before Tile reads, allocation, or faults. Complete schema,
type, shape, capacity, byte-selector, mask, allocation, and consumed-source
definedness preflight precedes source snapshots. The U32 cumulative payload
and destination descriptor publish atomically; rejection has no architectural
effect.

## Decision 125: `TCONCAT` is fixed horizontal concatenation along columns

`TCONCAT` is selected by TEPL carrier `Mode=3, Function=0` and executes on the
`SFU` engine. It reads two ordered Local source Tiles and writes one explicit
newly allocated Local destination. It has no architectural axis operand. The
left source precedes the right source along the column dimension.

The two sources and destination MUST use the same DataType and row-major
layout. Both sources MUST have the same nonzero `ValidRow`. The destination
has that same `ValidRow` and has `ValidCol = left.ValidCol + right.ValidCol`.
For every valid row, destination columns below `left.ValidCol` are copied from
the left source; following columns are copied from the right source in order.
Vertical row concatenation is not an assigned `TCONCAT` form.

`TCONCAT` supports every assigned Tile DataType except `HiF4X2`. The globally
reserved DataType encodings and `HiF4X2` MUST raise Illegal Block Exception
before source reads, destination allocation, or any other architectural
effect. This is the common `MOVE24` type domain used by representation-
preserving Tile rearrangement operations.

`B.DATR.Layout` retains its physical-layout-transform meaning and MUST NOT be
interpreted as a concatenation-axis selector. No indexed or variable-per-row
concatenation form is part of this instruction. The complete valid regions of
both sources are required defined before effects. Both source payloads are
snapshotted before destination writes, and the destination descriptor and
contents publish atomically after complete preflight. The sources persist;
rejection has no architectural effect.

## Decision 115: `TCOLEXPAND` broadcasts one one-row source down destination columns

`TCOLEXPAND` is selected by TEPL carrier `Mode=2, Function=20` and executes on
the `SFU` engine. It reads exactly one Local source Tile representing one row
and writes one explicit newly allocated Local destination. For every valid
destination element `[r,c]`, the operation copies source element `[0,c]`
bit-for-bit. There is no second full-shape source operand and no numeric
transformation.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Copying does not update numeric status.

`LB0=destination.ValidCol` is required and nonzero; omitted `LB1` gives
`destination.ValidRow=1`; omitted `LB2` gives
`destination.Col=destination.ValidCol`; destination physical rows derive from
capacity. The source has `ValidRow=1`, `ValidCol=destination.ValidCol`, and
`Col=destination.Col`; its physical rows also derive from capacity. Source and
destination are row-major and the complete valid source row MUST be defined.

`PadValueOrByteId` is the only applicable `B.DATR` field and applies to every
physical destination element outside its valid rectangle. `B.IOR` and `B.IOS`
are illegal. Source and destination `B.IOT` bindings use the same `PE_MASK`;
any PE subset is legal and mask zero is a strict no-op before reads,
allocation, or faults. The source persists. Complete preflight precedes the
source snapshot. Results, padding definedness, and the destination descriptor
publish atomically; rejection has no architectural effect.

## Decision 116: `TCOLEXPANDADD` adds a one-row column broadcast source

`TCOLEXPANDADD` is selected by TEPL carrier `Mode=2, Function=21` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local one-row
broadcast source, then writes one explicit newly allocated Local destination.
For every valid element `[r,c]`, the result is the selected DataType's addition
of `source0[r,c]` and `source1[0,c]`.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`; all others reject before effects. All operands use the same DataType.
Integer overflow and floating rounding, exceptional values, and numeric status
are exactly the typed addition rules of `TADD` for each element.

`source0` and the destination have identical physical shape, valid shape, and
row-major layout. `source1.ValidRow == 1`, while `source1.ValidCol` and
`source1.Col` equal the corresponding destination values; its physical rows
derive from capacity. Dimension defaults and bounds follow Decision 082 in ADR-TILE-0009. Both
source valid regions MUST be defined. `PadValueOrByteId` is the only applicable
`B.DATR` field and applies to every physical destination element outside the
valid rectangle. `B.IOR` and `B.IOS` are illegal.

All three `B.IOT` bindings use the same `PE_MASK`; partial masks are legal and
mask zero is a strict no-op before reads, allocation, or faults. Both sources
persist. Any otherwise legal source/destination alias uses read-old/write-new
behavior, with both source payloads snapshotted after complete preflight.
Numeric status, valid results, padding definedness, and the destination
descriptor publish atomically; rejection has no architectural effect.

## Decision 117: `TCOLEXPANDSUB` subtracts a one-row column broadcast source

`TCOLEXPANDSUB` is selected by TEPL carrier `Mode=2, Function=22` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local one-row
broadcast source, then writes one explicit newly allocated Local destination.
Operand order is fixed: for every valid `[r,c]`, the result is
`source0[r,c] - source1[0,c]` under the selected DataType. The reverse
subtraction is not an alias or alternate form.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
Decision 116 in ADR-TILE-0010. Integer overflow and floating rounding, exceptional values, signed
zeros, and numeric status are exactly the typed subtraction rules of `TSUB`
for each element.

## Decision 118: `TCOLEXPANDMUL` multiplies by a one-row column broadcast source

`TCOLEXPANDMUL` is selected by TEPL carrier `Mode=2, Function=23` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local one-row
broadcast source, then writes one explicit newly allocated Local destination.
For every valid `[r,c]`, it multiplies `source0[r,c]` by `source1[0,c]` under
the selected DataType.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
Decision 116 in ADR-TILE-0010. Integer overflow and floating rounding, exceptional values, signed
zeros, and numeric status are exactly the typed multiplication rules of
`TMUL` for each element.

## Decision 119: `TCOLEXPANDDIV` divides by a one-row column broadcast source

`TCOLEXPANDDIV` is selected by TEPL carrier `Mode=2, Function=24` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local one-row
broadcast source, then writes one explicit newly allocated Local destination.
Operand order is fixed: for every valid `[r,c]`, the result is
`source0[r,c] / source1[0,c]` under the selected DataType. The reverse quotient
is not an alias or alternate form.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
Decision 116 in ADR-TILE-0010. Signed, unsigned, and floating division and numeric status follow
Decision 060 in ADR-TILE-0008. A zero integer broadcast element causes an Illegal Block Exception
before effects; floating positive and negative zero are legal and follow the
selected floating profile.

## Decision 120: `TCOLEXPANDMAX` takes maximum with a one-row broadcast source

`TCOLEXPANDMAX` is selected by TEPL carrier `Mode=2, Function=25` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local one-row
broadcast source, then writes one explicit newly allocated Local destination.
For every valid `[r,c]`, the result is exactly the typed maximum of
`source0[r,c]` and `source1[0,c]`.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
Decision 116 in ADR-TILE-0010. Signed and unsigned ordering and floating NaN, signaling-NaN,
canonical-NaN, signed-zero, and numeric-status behavior follow `TMAX` exactly;
mixed-sign zero maximum produces positive zero.

## Decision 121: `TCOLEXPANDMIN` takes minimum with a one-row broadcast source

`TCOLEXPANDMIN` is selected by TEPL carrier `Mode=2, Function=26` and executes
on the `SFU` engine. It reads one full-shape Local source and one Local one-row
broadcast source, then writes one explicit newly allocated Local destination.
For every valid `[r,c]`, the result is exactly the typed minimum of
`source0[r,c]` and `source1[0,c]`.

The supported DataTypes, exact source and destination geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR`/`B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, and atomic publication follow
Decision 116 in ADR-TILE-0010. Signed and unsigned ordering and floating NaN, signaling-NaN,
canonical-NaN, signed-zero, and numeric-status behavior follow `TMIN` exactly;
mixed-sign zero minimum produces negative zero.

## Decision 122: `TCOLEXPANDEXPDIF` exponentiates a typed column-broadcast difference

`TCOLEXPANDEXPDIF` is selected by TEPL carrier `Mode=2, Function=27` and
executes on the `SFU` engine. It reads one full-shape Local source and one
Local one-row broadcast source, then writes one explicit newly allocated
Local destination. For every valid `[r,c]`, it first computes the selected
same-type subtraction `difference = source0[r,c] - source1[0,c]` and then
writes the selected same-type natural exponential `exp(difference)`. Publishing
the raw subtraction result without the exponential is not conforming.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, and `E5M2`; every integer, exponent-only, compact, packed, or
reserved DataType encoding rejects before effects. All operands use the same
DataType. The subtraction stage follows the typed `TSUB` rules and the
exponential stage follows the typed `TEXP` rules. Each stage applies the
selected profile's rounding and numeric-status behavior; accumulated status is
part of the single architectural transaction. Signed zeros, infinities, quiet
and signaling NaNs, overflow, underflow, and inexact results follow those two
typed operations in sequence.

Exact source and destination geometry, one-row broadcast geometry, row-major
layout, dimension defaults, source definedness, `PadValueOrByteId`
applicability, prohibited `B.IOR` and `B.IOS`, equal and zero mask rules, source
persistence, legal alias snapshot behavior, complete preflight, rollback, and
atomic publication follow Decision 116 in ADR-TILE-0010.

## Decision 123: `TCOLARGMAX` returns the lowest row index of each column maximum

`TCOLARGMAX` is selected by TEPL carrier `Mode=2, Function=28` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. Each nonempty valid source column is scanned from
row zero through `ValidRow-1` in increasing order. Values are compared with
the selected DataType's `TMAX` rules. Destination element `[0,c]` is the `U32`
encoding of the winning row index. When multiple elements represent the same
maximum, the lowest row index wins.

The exact supported source DataTypes are `FP64`, `FP32`, `TF32`, `HF32`,
`FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; all others reject before effects. The destination DataType is
always `U32` and is independent of the selected source DataType. Signed,
unsigned, and floating ordering, one-NaN and two-NaN behavior, signaling-NaN
invalid status, canonical NaNs, and signed-zero preference follow `TMAX`.
Selecting a later value because it is the preferred maximum updates the index;
an equal value that does not replace the current maximum preserves the earlier
index.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `1 x source.ValidCol` logical shape, destination
physical `Col=source.Col`, capacity-derived destination rows, and
`PadValueOrByteId` application to U32 destination padding follow Decision 111 in ADR-TILE-0010.
`B.IOR` and `B.IOS` are illegal. Source and destination `B.IOT` bindings use
the same `PE_MASK`; any subset is legal and mask zero is a strict no-op before
reads, allocation, or faults. The source persists. Complete preflight precedes
the source snapshot. Numeric status, U32 indices, padding definedness, and the
destination descriptor publish atomically; rejection has no architectural
effect.

## Decision 124: `TCOLARGMIN` returns the lowest row index of each column minimum

`TCOLARGMIN` is selected by TEPL carrier `Mode=2, Function=29` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. Each nonempty valid source column is scanned from
row zero through `ValidRow-1` in increasing order. Values are compared with
the selected DataType's `TMIN` rules. Destination element `[0,c]` is the `U32`
encoding of the winning row index. When multiple elements represent the same
minimum, the lowest row index wins.

The exact supported source DataTypes are `FP64`, `FP32`, `TF32`, `HF32`,
`FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; all others reject before effects. The destination DataType is
always `U32` and is independent of the selected source DataType. Signed,
unsigned, and floating ordering, one-NaN and two-NaN behavior, signaling-NaN
invalid status, canonical NaNs, and signed-zero preference follow `TMIN`.
Selecting a later value because it is the preferred minimum updates the index;
an equal value that does not replace the current minimum preserves the earlier
index.

Source dimensions, defaults, row-major layout, complete valid-region
definedness, destination `1 x source.ValidCol` logical shape, destination
physical `Col=source.Col`, capacity-derived destination rows, and
`PadValueOrByteId` application to U32 destination padding follow Decision 111 in ADR-TILE-0010.
`B.IOR` and `B.IOS` are illegal. Source and destination `B.IOT` bindings use
the same `PE_MASK`; any subset is legal and mask zero is a strict no-op before
reads, allocation, or faults. The source persists. Complete preflight precedes
the source snapshot. Numeric status, U32 indices, padding definedness, and the
destination descriptor publish atomically; rejection has no architectural
effect.

## Decision 113: `TCOLMIN` reduces each valid column with typed minimum

`TCOLMIN` is selected by TEPL carrier `Mode=2, Function=18` and executes on the
`SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source column, the accumulator is
initialized from source row zero and rows one through `ValidRow-1` are folded
in increasing order with exactly the typed minimum operation defined for
`TMIN`. The final value is written to destination element `[0,c]`. The first
element is evaluated exactly once.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Signed and unsigned ordering and floating
one-NaN, two-NaN, signaling-NaN, canonical-NaN, and signed-zero behavior
follow `TMIN`; mixed-sign zero minimum produces negative zero.

Source dimensions, defaults, row-major layout, complete source definedness,
destination `1 x source.ValidCol` valid shape, destination physical shape,
`PadValueOrByteId` applicability, prohibited `B.IOR`/`B.IOS`, equal and zero
mask rules, source persistence, snapshot behavior, complete preflight,
numeric-status transaction, rollback, and atomic publication follow Decision 111 in ADR-TILE-0010.

## Decision 114: `TCOLPROD` reduces each valid column with typed multiplication

`TCOLPROD` is selected by TEPL carrier `Mode=2, Function=19` and executes on
the `SFU` engine. It reads one Local source Tile and writes one explicit newly
allocated Local destination. For each valid source column, it performs an
increasing-row left fold over rows zero through `ValidRow-1`. The accumulator
begins with the selected DataType's exact multiplicative identity and every
fold step uses exactly the typed multiplication operation defined for `TMUL`;
the final value is written to destination element `[0,c]`.

The exact supported source and destination DataTypes are `FP64`, `FP32`,
`TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`,
`U64`, `U32`, `U16`, and `U8`; all others reject before effects. Source and
destination use the same DataType. Integer multiplication follows the selected
element-width overflow rule. Floating multiplication, intermediate rounding,
exceptional values, and numeric status follow the selected profile at every
fold step.

Source dimensions, defaults, row-major layout, complete source definedness,
destination `1 x source.ValidCol` valid shape, destination physical shape,
`PadValueOrByteId` applicability, prohibited `B.IOR`/`B.IOS`, equal and zero
mask rules, source persistence, snapshot behavior, complete preflight,
numeric-status transaction, rollback, and atomic publication follow Decision 111 in ADR-TILE-0010.
