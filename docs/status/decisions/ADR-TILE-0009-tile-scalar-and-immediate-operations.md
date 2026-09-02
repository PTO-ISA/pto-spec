---
{
  "id": "ADR-TILE-0009",
  "title": "Tile scalar and immediate operations",
  "title_zh": "Tile 标量与立即数操作",
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
    "PTO-TADDS-CONTRACT-001",
    "PTO-TANDS-CONTRACT-001",
    "PTO-TCMPS-CONTRACT-001",
    "PTO-TDIVS-CONTRACT-001",
    "PTO-TEXPANDS-CONTRACT-001",
    "PTO-TMAXS-CONTRACT-001",
    "PTO-TMINS-CONTRACT-001",
    "PTO-TMULS-CONTRACT-001",
    "PTO-TORS-CONTRACT-001",
    "PTO-TREMS-CONTRACT-001",
    "PTO-TSELS-CONTRACT-001",
    "PTO-TSHLS-CONTRACT-001",
    "PTO-TSHRS-CONTRACT-001",
    "PTO-TSUBS-CONTRACT-001",
    "PTO-TXORS-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-TILE-TADDS",
    "PTO-TILE-TANDS",
    "PTO-TILE-TCMPS",
    "PTO-TILE-TDIVS",
    "PTO-TILE-TEXPANDS",
    "PTO-TILE-TMAXS",
    "PTO-TILE-TMINS",
    "PTO-TILE-TMULS",
    "PTO-TILE-TORS",
    "PTO-TILE-TREMS",
    "PTO-TILE-TSELS",
    "PTO-TILE-TSHLS",
    "PTO-TILE-TSHRS",
    "PTO-TILE-TSUBS",
    "PTO-TILE-TXORS"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-GOV-0006"
  ],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "not-required",
  "legacy_ids": [
    "PRD-082",
    "PRD-083",
    "PRD-084",
    "PRD-085",
    "PRD-086",
    "PRD-087",
    "PRD-088",
    "PRD-089",
    "PRD-090",
    "PRD-091",
    "PRD-092",
    "PRD-093",
    "PRD-094",
    "PRD-095",
    "PRD-096",
    "ADR-0081"
  ]
}
---
# ADR-TILE-0009: Tile scalar and immediate operations

## Context

ADR 0062 recorded a single repository-wide mnemonic audit. This record preserves the accepted decisions for this family as one decision-scoped owner. The former identifiers remain only in `legacy_ids` and the generated ADR index; current normative meaning is owned by the affected ASL/NDF clauses.

## Decisions

## Decision 082: `TADDS` consumes one typed scalar from the selected PE's private GPR

`TADDS` is selected by TEPL carrier `Mode=1, Function=0` and executes on the
`VEC` engine. It reads one Local source Tile, adds one scalar to every element
in the valid rectangle, and writes one explicit renamed Local destination.
The scalar is supplied by `B.IOR.RegSrc0`. For each PE selected by the common
`B.IOT.PE_MASK`, that selector is resolved in that PE's private GPR file.

The low `DataType` element width of the selected 64-bit GPR is the raw encoding
of one scalar element; GPR bits above that width do not participate. Floating
types therefore consume their ordinary bit encoding, signed integers consume
the low-width two's-complement encoding, and unsigned integers consume the
same bits as an unsigned value. Omitting `B.IOR` selects the zero register as
the operation-defined default. An explicitly present all-zero `B.IOR` is a
distinct encoded descriptor but supplies the same zero scalar. `RegSrc1`,
`RegSrc2`, and `RegDst` are unused and MUST be zero when a `B.IOR` is present.

TADDS supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Every other
DataType rejects before effects. The source and destination MUST match
physical and valid shape, row-major layout, and DataType. The selected numeric
profile defines addition, exceptional values, overflow, and fixed/default
rounding for that type; no scalar conversion or extension beyond the raw
low-width interpretation occurs.

The closed Local scalar-VEC schema requires nonzero `LB0=ValidCol`; omitted
`LB1` gives `ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows
derive from destination capacity, `Col`, and DataType. `PadValueOrByteId` is
the only applicable `B.DATR` field. Omission selects `Null`; explicit `00`,
`01`, `10`, and `11` select `Zero`, `Max`, `Min`, and `Null`. Explicit
nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`, `RMode`, or
`Layout` is illegal.

`B.IOS` is illegal. The source and destination `B.IOT` bindings use the same
`PE_MASK`; mask zero is a strict no-op before GPR reads, source reads,
allocation, or faults. The source persists and MAY alias the destination.
Complete descriptor, schema, field, type, dimension, capacity, GPR-binding,
mask, allocation, and source-definedness preflight precedes the source and
scalar snapshots. Valid results, numeric status, padding definedness, and the
destination descriptor publish atomically; rejection has no architectural
effect.

## Decision 083: `TSUBS` performs ordered Tile-minus-scalar subtraction

`TSUBS` is selected by TEPL carrier `Mode=1, Function=1` and executes on the
`VEC` engine. For each element in the valid rectangle it computes
`source - scalar`; the scalar is never the left operand. It reads one Local
source Tile and writes one explicit renamed Local destination.

The scalar is supplied by `B.IOR.RegSrc0`, resolved independently in each
selected PE's private GPR file. The low selected-DataType element width is the
raw encoding of one scalar element and higher GPR bits do not participate.
Floating encodings, low-width two's-complement signed integers, and unsigned
integers are interpreted according to the selected DataType. Omitting
`B.IOR` selects the zero register as the operation-defined default; an
explicit all-zero `B.IOR` remains a distinct encoded descriptor but supplies
the same zero scalar. `RegSrc1`, `RegSrc2`, and `RegDst` are unused and MUST be
zero when a descriptor is present.

TSUBS supports exactly `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`,
`E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. Every other
DataType rejects before effects. Source and destination MUST match physical
and valid shape, row-major layout, and DataType. The selected numeric profile
defines subtraction, exceptional values, overflow, and fixed/default rounding
for that type; no scalar conversion or extension beyond the raw low-width
interpretation occurs.

The closed Local scalar-VEC schema and dimension defaults are identical to
Decision 082 in ADR-TILE-0009. `PadValueOrByteId` is the only applicable `B.DATR` field: omission is
`Null`, and explicit `00`, `01`, `10`, and `11` are `Zero`, `Max`, `Min`, and
`Null`. Every other explicit nondefault data attribute is illegal.

`B.IOS` is illegal. Source and destination bindings use the same `PE_MASK`,
and mask zero is a strict no-op before the private GPR read. The source
persists and MAY alias the destination. Complete preflight precedes source and
scalar snapshots; valid results, numeric status, padding definedness, and the
destination descriptor publish atomically. Rejection has no architectural
effect.

## Decision 084: `TMULS` performs typed elementwise Tile-times-scalar multiplication

`TMULS` is selected by TEPL carrier `Mode=1, Function=2` and executes on the
`VEC` engine. It reads one Local source Tile, multiplies each valid element by
one scalar, and writes one explicit renamed Local destination. Signed and
unsigned integer results are modulo the element width. Floating results and
status follow the selected numeric profile and its fixed/default rounding.

The scalar-binding, low-width raw DataType encoding, per-selected-PE private
GPR lookup, omitted versus explicit-zero `B.IOR`, unused `B.IOR` fields,
16-type set, dimension defaults, Local-only bindings, equal and zero mask
rules, source persistence and aliasing, `PadValue` behavior, prohibited data
attributes, complete preflight, and atomic publication are exactly those in
Decision 082 in ADR-TILE-0009. No additional scalar conversion, saturation, or encoded rounding
control is defined.

## Decision 085: `TDIVS` is ordered SFU Tile-divided-by-scalar division

`TDIVS` retains TEPL carrier `Mode=1, Function=3`, selector `0x023`, but its
semantic engine is `SFU` because division requires complex execution hardware.
Canonical block assembly uses `BSTART.SFU TDIVS, DataType`; the raw carrier
encoding is unchanged. For every valid element it computes `source / scalar`,
never `scalar / source`.

The scalar binding and raw low-width DataType interpretation follow Decision 082 in ADR-TILE-0009.
An integer scalar encoding of zero causes Illegal Block Exception before
source snapshot, destination allocation publication, or any architectural
effect. A floating positive or negative zero scalar is not a block-legality
failure; quotient and numeric status follow the selected floating profile.
The profile also owns signed minimum divided by negative one and all floating
NaN, infinity, overflow, underflow, inexact, and rounding behavior.

TDIVS supports the same exact 16 DataTypes, dimensions/defaults, Local Tile
schema, `PadValue`, prohibited fields, masks, persistence, aliasing, preflight,
and atomic publication as Decision 082 in ADR-TILE-0009. Omitting `B.IOR` supplies zero: therefore an
omitted scalar is illegal for every integer TDIVS type and is floating
division by positive zero for every floating type. This is an architectural
default, not permission to read an absent or uninitialized register.

## Decision 086: `TREMS` is SFU divisor-signed Tile-modulo-scalar

`TREMS` retains TEPL carrier `Mode=1, Function=4`, selector `0x024`, but its
semantic engine is `SFU`. Canonical assembly uses
`BSTART.SFU TREMS, DataType` without changing the raw encoding. It computes
modulo with ordered operands `source mod scalar`, not a truncation-toward-zero
language remainder. For signed integers, `q=floor(source/scalar)` and
`result=source-q*scalar`, so every nonzero result has the scalar divisor's
sign. Unsigned types use ordinary unsigned modulo; floating types use the
profile's divisor-signed modulo definition.

The scalar binding, raw low-width DataType interpretation, per-PE private GPR
lookup, exact 16-type set, dimensions/defaults, padding, Local-only bindings,
masks, persistence, aliases, and transaction rules follow Decision 082 in ADR-TILE-0009. Integer
scalar zero raises Illegal Block Exception before effects. Floating positive
or negative zero is not a block-legality failure; result and numeric status
are profile-defined. Consequently an omitted `B.IOR` supplies an illegal zero
divisor for integer TREMS and a legal positive-zero divisor for floating
TREMS. The profile also owns signed overflow boundaries and floating special
values; no encoded rounding or saturation control is consumed.

## Decision 087: `TANDS` is integer-only raw element-width AND with a scalar

`TANDS` is selected by TEPL carrier `Mode=1, Function=6` and executes on the
`VEC` engine. For each valid element it computes the raw bitwise AND of the
source element and scalar. Signedness does not change the bit operation. The
exact supported DataTypes are `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`,
and `U8`; every floating, compact, exponent-only, and packed encoding rejects
before effects.

`B.IOR.RegSrc0` supplies the scalar from each selected PE's private GPR. Only
the selected integer element width participates; upper GPR bits are ignored.
Omitting `B.IOR` supplies zero and therefore makes every valid destination
element zero. An explicit all-zero descriptor is distinct but numerically
identical; its unused fields MUST be zero.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero masks, persistence, aliasing, complete
preflight, and atomic publication follow Decision 082 in ADR-TILE-0009. `PadValueOrByteId` is the
only applicable `B.DATR` field, with omission `Null` and explicit
`Zero`/`Max`/`Min`/`Null`; `Max` and `Min` use the selected integer type.
TANDS has no rounding, saturation, or numeric-status effect.

## Decision 088: `TORS` is integer-only raw element-width OR with a scalar

`TORS` is selected by TEPL carrier `Mode=1, Function=7` and executes on the
`VEC` engine. For each valid element it computes the raw bitwise OR of the
source element and scalar. Signedness does not change the bit operation. The
exact supported DataTypes are `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`,
and `U8`; every floating, compact, exponent-only, and packed encoding rejects
before effects.

`B.IOR.RegSrc0` supplies the scalar from each selected PE's private GPR. Only
the selected integer element width participates; upper GPR bits are ignored.
Omitting `B.IOR` supplies zero and therefore leaves every valid source element
unchanged. An explicit all-zero descriptor is distinct but numerically
identical; its unused fields MUST be zero.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero mask rules, persistence, aliasing,
complete preflight, and atomic publication follow Decision 082 in ADR-TILE-0009.
`PadValueOrByteId` is the only applicable `B.DATR` field, with omission `Null`
and explicit `Zero`/`Max`/`Min`/`Null`; `Max` and `Min` use the selected integer
type. TORS has no rounding, saturation, or numeric-status effect.

## Decision 089: `TXORS` is integer-only raw element-width XOR with a scalar

`TXORS` is selected by TEPL carrier `Mode=1, Function=8` and executes on the
`VEC` engine. For each valid element it computes the raw bitwise XOR of the
source element and scalar. Signedness does not change the bit operation. The
exact supported DataTypes are `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`,
and `U8`; every floating, compact, exponent-only, and packed encoding rejects
before effects.

`B.IOR.RegSrc0` supplies the scalar from each selected PE's private GPR. Only
the selected integer element width participates; upper GPR bits are ignored.
Omitting `B.IOR` supplies zero and therefore leaves every valid source element
unchanged. An explicit all-zero descriptor is distinct but numerically
identical; its unused fields MUST be zero.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero mask rules, persistence, aliasing,
complete preflight, and atomic publication follow Decision 082 in ADR-TILE-0009.
`PadValueOrByteId` is the only applicable `B.DATR` field, with omission `Null`
and explicit `Zero`/`Max`/`Min`/`Null`; `Max` and `Min` use the selected integer
type. TXORS has no rounding, saturation, or numeric-status effect.

## Decision 090: `TSHLS` uses an element-width-masked scalar shift count

`TSHLS` is selected by TEPL carrier `Mode=1, Function=9` and executes on the
`VEC` engine. It reads one Local integer source Tile and one scalar from
`B.IOR.RegSrc0`, then writes one explicit renamed Local destination. For an
element width `W` of 8, 16, 32, or 64 bits, the shift count is the unsigned
value of the scalar's low `log2(W)` bits. Each destination element is the low
`W` bits of `source << count`; verification-carrier bits above `W` are zero.
Signedness does not change the raw shift.

The exact supported DataTypes are `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; every other DataType rejects before effects. The scalar is
read from each selected PE's private GPR. Omitting `B.IOR` supplies zero and
therefore makes TSHLS an identity operation over the valid region. An explicit
all-zero descriptor is distinct but numerically identical; unused `B.IOR`
fields MUST be zero.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero mask rules, persistence, aliasing,
`PadValueOrByteId`, complete preflight, and atomic publication follow Decision 082 in ADR-TILE-0009.
TSHLS has no rounding, saturation, or numeric-status effect.

## Decision 091: `TSHRS` follows integer signedness with a masked scalar count

`TSHRS` is selected by TEPL carrier `Mode=1, Function=10` and executes on the
`VEC` engine. It reads one Local integer source Tile and one scalar from
`B.IOR.RegSrc0`, then writes one explicit renamed Local destination. For an
element width `W` of 8, 16, 32, or 64 bits, the shift count is the unsigned
value of the scalar's low `log2(W)` bits. Signed DataTypes use arithmetic right
shift with sign fill; unsigned DataTypes use logical right shift with zero
fill. The low `W` result bits are stored and verification-carrier bits above
`W` are zero.

The exact supported DataTypes are `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; every other DataType rejects before effects. The scalar is
read from each selected PE's private GPR. Omitting `B.IOR` supplies zero and
therefore makes TSHRS an identity operation over the valid region. An explicit
all-zero descriptor is distinct but numerically identical; unused `B.IOR`
fields MUST be zero.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero mask rules, persistence, aliasing,
`PadValueOrByteId`, complete preflight, and atomic publication follow Decision 082 in ADR-TILE-0009.
TSHRS has no rounding, saturation, or numeric-status effect.

## Decision 092: `TMAXS` is typed maximum between each element and a scalar

`TMAXS` is selected by TEPL carrier `Mode=1, Function=11` and executes on the
`VEC` engine. It reads one Local source Tile and one scalar from
`B.IOR.RegSrc0`, then writes one explicit renamed Local destination. Signed
integer DataTypes use signed numeric ordering, unsigned integer DataTypes use
unsigned numeric ordering, and floating DataTypes use the selected numeric
profile's maximum operation.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`; all others reject before effects. The scalar is the raw low element-width
encoding from each selected PE's private GPR; upper bits are ignored. Omitting
`B.IOR` supplies the selected type's all-zero encoding, including positive
zero for floating types. Explicit all-zero is distinct but numerically
identical; unused `B.IOR` fields MUST be zero.

For floating types, one NaN selects the non-NaN operand without changing its
encoding; two NaNs produce the destination canonical NaN; signaling NaN
reports the profile's invalid condition; equal-sign zero preserves that sign;
and a mixed-sign zero tie produces positive zero. Source encodings invalid for
the selected profile reject before effects.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero mask rules, persistence, aliasing,
`PadValueOrByteId`, complete preflight, numeric-status transaction, and atomic
publication follow Decision 082 in ADR-TILE-0009 and Decision 067 in ADR-TILE-0008.

## Decision 093: `TMINS` is typed minimum between each element and a scalar

`TMINS` is selected by TEPL carrier `Mode=1, Function=12` and executes on the
`VEC` engine. It reads one Local source Tile and one scalar from
`B.IOR.RegSrc0`, then writes one explicit renamed Local destination. Signed
integer DataTypes use signed numeric ordering, unsigned integer DataTypes use
unsigned numeric ordering, and floating DataTypes use the selected numeric
profile's minimum operation.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`; all others reject before effects. The scalar is the raw low element-width
encoding from each selected PE's private GPR; upper bits are ignored. Omitting
`B.IOR` supplies the selected type's all-zero encoding, including positive
zero for floating types. Explicit all-zero is distinct but numerically
identical; unused `B.IOR` fields MUST be zero.

For floating types, one NaN selects the non-NaN operand without changing its
encoding; two NaNs produce the destination canonical NaN; signaling NaN
reports the profile's invalid condition; equal-sign zero preserves that sign;
and a mixed-sign zero tie produces negative zero. Source encodings invalid for
the selected profile reject before effects.

Dimensions/defaults, row-major matching geometry, source definedness,
Local-only bindings, equal and zero mask rules, persistence, aliasing,
`PadValueOrByteId`, complete preflight, numeric-status transaction, and atomic
publication follow Decision 082 in ADR-TILE-0009 and Decision 068 in ADR-TILE-0008.

## Decision 094: `TCMPS` produces a packed predicate Tile from a scalar comparison

`TCMPS` is selected by TEPL carrier `Mode=1, Function=13` and executes on the
`VEC` engine. It reads one Local numeric source Tile and one scalar from
`B.IOR.RegSrc0`, then writes one explicit renamed Local predicate destination.
`B.DATR.CMode` maps `0=EQ`, `1=NE`, `2=LT`, `3=GT`, `4=LE`, and `5=GE`;
encodings 6 and 7 are reserved. Omission retains encoded zero and selects EQ.

Each logical comparison produces exactly one predicate bit. Logical element
index `i` occupies bit `i mod 8` of byte `floor(i/8)`, with lower logical
indices in lower bit positions. The destination is predicate-kind Tile
storage, not a numeric DataType. It retains the source logical `Row`, `Col`,
`ValidRow`, and `ValidCol`, and its capacity MUST hold at least
`ceil(Row*Col/8)` bytes.

The exact supported source DataTypes are `FP64`, `FP32`, `TF32`, `HF32`,
`FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; all others reject before effects. Signed and unsigned ordered
comparisons use their respective numeric ordering. Floating comparison rules,
including unordered NaN results, signaling-NaN invalid status, and signed-zero
equality, follow Decision 069 in ADR-TILE-0008. The scalar is the raw low source-element-width
encoding from each selected PE's private GPR; upper bits are ignored. Omitted
`B.IOR` supplies the selected source type's all-zero encoding.

Source dimensions/defaults and row-major layout follow Decision 082 in ADR-TILE-0009. `CMode` and
`PadValueOrByteId` are the only applicable `B.DATR` fields. Pad omission is
`Null`; `Zero` and `Min` write zero predicate bits outside the valid rectangle,
`Max` writes one bits, and `Null` leaves those bits undefined. TCMPS rejects
`B.IOS`, uses Local-only bindings with equal masks, and treats mask zero as a
strict no-op before private GPR reads. Complete preflight precedes the source
snapshot; packed payload, padding definedness, numeric status, and destination
descriptor publish atomically.

## Decision 095: `TSELS` selects a Tile element or scalar using packed predicates

`TSELS` is selected by TEPL carrier `Mode=1, Function=26` and executes on the
`VEC` engine. It reads one Local packed-predicate mask Tile, one Local numeric
true-source Tile, and one scalar false alternative from `B.IOR.RegSrc0`, then
writes one explicit renamed Local numeric destination. For logical element
index `i`, bit `i mod 8` of mask byte `floor(i/8)` selects the true-source
element when one and the scalar when zero. Lower logical indices occupy lower
bit positions. An ordinary numeric Tile is not a legal mask.

The true source and destination MUST have identical physical shape, logical
shape, valid shape, row-major layout, and DataType. The mask has the same
logical and valid geometry, predicate-kind storage, capacity of at least
`ceil(Row*Col/8)` bytes, and every valid predicate bit defined. Every valid
true-source element MUST be defined. Selection copies either the source
element encoding or the raw low element-width scalar encoding exactly; upper
GPR bits are ignored and no conversion, rounding, saturation, NaN
canonicalization, or numeric-status update occurs.

The exact supported numeric DataTypes are `FP64`, `FP32`, `TF32`, `HF32`,
`FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`,
`U16`, and `U8`; every other numeric type rejects before effects. Omitting
`B.IOR` supplies the selected type's all-zero encoding. Explicit all-zero is
distinct but numerically identical; unused `B.IOR` fields MUST be zero.

Dimensions/defaults, Local-only bindings, equal and zero mask rules,
source persistence, allowed true-source/destination aliasing,
`PadValueOrByteId`, complete predicate/data/scalar preflight, padding
definedness, and atomic destination publication follow Decision 079 in ADR-TILE-0008 and Decision 082 in ADR-TILE-0009.
The predicate mask cannot alias the numeric destination because their storage
kinds differ.

## Decision 096: `TEXPANDS` broadcasts one typed scalar into a new Local Tile

`TEXPANDS` is selected by TEPL carrier `Mode=1, Function=27` and executes on
the `VEC` engine. It has no Tile source. It reads one scalar from
`B.IOR.RegSrc0` and writes one explicit newly allocated Local destination. For
every element inside `ValidRow x ValidCol`, the destination receives the raw
low element-width encoding from the selected PE's private GPR. GPR bits above
the selected DataType width are ignored; no numeric conversion, rounding,
saturation, canonicalization, or numeric-status update occurs.

The exact supported DataTypes are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`,
`BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and
`U8`; all other DataTypes reject before effects. Omitting `B.IOR` supplies the
selected type's all-zero encoding, including positive zero for floating
types. An explicitly present all-zero `B.IOR` is a distinct encoded descriptor
but supplies the same value. `RegSrc1`, `RegSrc2`, and `RegDst` are unused and
MUST be zero when `B.IOR` is present.

The closed Local schema requires nonzero `LB0=ValidCol`; omitted `LB1` gives
`ValidRow=1`; omitted `LB2` gives `Col=ValidCol`; and physical rows derive from
destination capacity, `Col`, and DataType. The destination is row-major and
MUST satisfy `ValidRow <= Row` and `ValidCol <= Col`.
`PadValueOrByteId` is the only applicable `B.DATR` field. Omission selects
`Null`; explicit `Zero`, `Max`, and `Min` define every physical destination
element outside the valid rectangle with the selected DataType's corresponding
value, while `Null` leaves those elements undefined. Explicit nondefault
`CMode`, `Sat`, `Canonicalize`, secondary `DataType`, `RMode`, or `Layout` is
illegal.

`B.IOS` is illegal. The destination `B.IOT.PE_MASK` may select any subset of
the four PEs; mask zero is a strict no-op before GPR reads, allocation, or
faults. Complete descriptor, field, type, dimension, capacity, GPR-binding,
mask, and allocation preflight precedes scalar reads. Padding definedness and
the destination descriptor publish atomically; rejection has no architectural
effect.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Tile-scalar forms are not simple aliases of Tile-Tile operations: scalar values come from PE-private GPRs or omission defaults, use type-dependent interpretation, and introduce different zero-divisor, shift-count, comparison, and broadcast rules.

Tile-scalar 形式并非 Tile-Tile 操作的简单别名：标量值来自 PE 私有 GPR 或省略默认值，采用类型相关解释，并引入不同的零除数、移位计数、比较和广播规则。

### Detailed decision / 详细决策

The decisions close arithmetic, division/remainder, bitwise, shifts, min/max, comparison, select, and scalar expansion. Each operation defines its engine, scalar binding/default, supported element types, valid and physical shape, padding fields, same-mask rule, zero-mask no-op, source persistence, descriptor/capacity preflight, and atomic publication.

相关决策闭合算术、除法/余数、位运算、移位、min/max、比较、选择和标量扩展。每个操作都定义执行引擎、标量绑定/默认值、受支持元素类型、有效与物理形状、padding 字段、同掩码规则、掩码零无操作、源持久性、描述符/容量预检和原子发布。

### What changed / 改动内容

#### English

- Defined the scalar source, omission defaults, and typed interpretation for every listed selector.
- Closed per-operation legality and transaction behavior across all selected PEs.

#### 中文

- 为每个所列 selector 定义标量来源、省略默认值和 typed 解释。
- 闭合所有所选 PE 上的逐操作合法性与事务行为。

### Scope and boundaries / 范围与边界

This ADR does not turn scalar forms into extra-operand Tile-Tile forms or add Shared operands. Numerical cases delegated by the existing decisions remain with their numeric owners.

本 ADR 不把标量形式变成额外操作数的 Tile-Tile 形式，也不增加 Shared 操作数。既有决策委托的数值情况仍由相应 numeric owner 管理。
