---
{
  "id": "ADR-TILE-0011",
  "title": "Tile conversion, layout, and partial operations",
  "title_zh": "Tile 转换、布局与部分区域操作",
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
    "PTO-TDEQUANT-CONTRACT-001",
    "PTO-TGATHER-CONTRACT-001",
    "PTO-TMRGSORT-CONTRACT-001",
    "PTO-TQUANT-CONTRACT-001",
    "PTO-TSCATTER-CONTRACT-001",
    "PTO-TSORT-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-TILE-TDEQUANT",
    "PTO-TILE-TGATHER",
    "PTO-TILE-TMRGSORT",
    "PTO-TILE-TQUANT",
    "PTO-TILE-TSCATTER",
    "PTO-TILE-TSORT"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-GOV-0006"
  ],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "not-required",
  "legacy_ids": [
    "PRD-133",
    "PRD-134",
    "PRD-135",
    "PRD-136",
    "PRD-137",
    "PRD-138",
    "PRD-139",
    "PRD-140",
    "PRD-141",
    "PRD-142",
    "PRD-143",
    "ADR-0083"
  ]
}
---
# ADR-TILE-0011: Tile conversion, layout, and partial operations

## Context

ADR 0062 recorded a single repository-wide mnemonic audit. This record preserves the accepted decisions for this family as one decision-scoped owner. The former identifiers remain only in `legacy_ids` and the generated ADR index; current normative meaning is owned by the affected ASL/NDF clauses.

## Decisions

## Decision 133: `TQUANT` is the encoded single-destination affine quantizer

`TQUANT` is selected by TEPL carrier `Mode=3, Function=10` and executes on
the `SFU` engine. The architectural selector has one Local source Tile, one
newly allocated Local destination Tile, and two per-PE scalar inputs. It does
not directly expose parameter Tiles or auxiliary result Tiles. Quantization
interfaces that require row-varying parameters, shared exponents, maxima,
scaling Tiles, or other auxiliary results are compound software lowerings and
do not add operands or results to this selector.

The source DataType is exactly `FP32`. The destination DataType is exactly
`S8` or `U8`. `BSTART` supplies the source DataType and a mandatory `B.DATR`
supplies the destination DataType. Source and destination have the same
nonzero valid shape and use row-major layout. When present, `B.IOR.RegSrc0`
supplies the raw `FP32` quantization multiplier and `B.IOR.RegSrc1` supplies
the zero point in the selected destination integer encoding. `RegSrc2` and
`RegDst` are unused and must select `zero`. Omitting `B.IOR` supplies the
operation defaults multiplier `1.0` and zero point zero. An explicitly encoded
all-zero `B.IOR` instead reads the `zero` register for both inputs and is
illegal because its multiplier is `0.0`. Every nondefault multiplier must be
finite, positive, and nonzero. The zero point must be in `S8` range for an
`S8` destination and in `U8` range for a `U8` destination.

For each valid source element `x`, the unbounded quantized value is
`x * multiplier + zero_point`. `B.DATR.RMode` selects the rounding rule and
defaults to round-to-nearest-even. With `Sat=1`, the rounded value is clamped
to the destination range; with `Sat=0`, conversion uses the selected integer
width's modulo result. Floating exceptional inputs and numeric status follow
the numeric conversion profile before the selected saturation rule.
`Canonicalize` and `PadValueOrByteId` are inapplicable and must be zero.
Elements outside the destination valid region remain Null padding.

`B.IOS` is illegal. Source and destination `B.IOT` bindings use the same
`PE_MASK`; any subset is legal and mask zero is a strict no-op before GPR or
Tile reads, allocation, or faults. The source persists. Complete descriptor,
scalar, type, shape, layout, and capacity preflight precedes the source
snapshot. Numeric status, destination payload, definedness, padding, and the
destination descriptor publish atomically; rejection has no architectural
effect.

## Decision 134: `TDEQUANT` is the encoded single-destination affine dequantizer

`TDEQUANT` is selected by TEPL carrier `Mode=3, Function=11` and executes on
the `SFU` engine. The architectural selector has one Local source Tile, one
newly allocated Local destination Tile, and two per-PE scalar inputs. It does
not directly consume row-varying parameter Tiles. Interfaces that use scale
or zero-point Tiles are compound software lowerings and do not change this
selector's operand arity.

The source DataType is exactly `S8` or `U8`; the destination DataType is
exactly `FP32`. `BSTART` supplies the source DataType and a mandatory
`B.DATR` supplies destination `FP32`. Source and destination have the same
nonzero valid shape and use row-major layout. When present, `B.IOR.RegSrc0`
supplies the raw `FP32` dequantization multiplier and `B.IOR.RegSrc1`
supplies the zero point in the source integer encoding. `RegSrc2` and
`RegDst` are unused and must select `zero`. Omitting `B.IOR` supplies the
operation defaults multiplier `1.0` and zero point zero. An explicitly encoded
all-zero `B.IOR` instead reads the `zero` register and is illegal because its
multiplier is `0.0`. Every nondefault multiplier must be finite, positive, and
nonzero. The zero point must be in the selected source type's range.

For each valid source element `q`, the destination is the `FP32` result of
`(q - zero_point) * multiplier`. `B.DATR.RMode` selects floating rounding and
defaults to round-to-nearest-even. `Sat`, `Canonicalize`, and
`PadValueOrByteId` are inapplicable and must be zero. Numeric status follows
the floating conversion and multiplication profile. Elements outside the
destination valid region remain Null padding.

`B.IOS` is illegal. Source and destination `B.IOT` bindings use the same
`PE_MASK`; any subset is legal and mask zero is a strict no-op before GPR or
Tile reads, allocation, or faults. The source persists. Complete descriptor,
scalar, type, shape, layout, and capacity preflight precedes the source
snapshot. Numeric status, destination payload, definedness, padding, and the
destination descriptor publish atomically; rejection has no architectural
effect.

## Decision 135: `TSORT` stably sorts independent row groups and returns indices

`TSORT` is selected by TEPL carrier `Mode=3, Function=12` and executes on the
`SFU` engine. It reads one Local source Tile and atomically creates two
distinct Local destinations: a value destination with the source DataType and
a `U32` index destination. All three Tiles have the same nonzero valid shape
and use row-major layout.

Each source row is partitioned from column zero into independent consecutive
groups of `sort_width` elements. The final group contains only its remaining
valid elements and never reads padding. Each group is stably sorted by the
selected DataType. The value destination receives the reordered values; the
index destination receives each value's original zero-based column offset
within that group. Equal values preserve source order. `descending=0` sorts
ascending and `descending=1` sorts descending. Numeric values precede NaNs in
both directions; NaNs preserve source order. Signaling-NaN observation sets
the selected numeric invalid status, and signed zeros compare equal so their
source order is preserved.

The exact supported value DataTypes are `FP32` and `FP16`. `B.DATR` is
inapplicable and every field must remain zero. `B.DIM LB0` supplies
`sort_width` in `1..64`; omission and an encoded zero both select the
operation default `32`, while nonzero values outside `1..64` are illegal.
When present, `B.IOR.RegSrc0` supplies `descending` and must contain exactly
zero or one. Omitting `B.IOR` selects ascending order. `RegSrc1`, `RegSrc2`,
and `RegDst` are unused and must select `zero`.

`B.IOS` is illegal. All source and destination `B.IOT` bindings use the same
`PE_MASK`; any subset is legal and mask zero is a strict no-op before reads,
allocation, comparison status, or faults. The source persists. Complete
descriptor, control, type, shape, layout, capacity, distinct-destination, and
definedness preflight precedes the source snapshot. Both destination payloads,
definedness, Null padding, numeric status, and descriptors publish as one
atomic transaction; rejection has no architectural effect.

## Decision 136: `TMRGSORT` stably merges two single-row sorted value streams

`TMRGSORT` is selected by TEPL carrier `Mode=3, Function=13` and executes on
the `SFU` engine. The architectural selector reads exactly two Local source
Tiles and creates one newly allocated Local destination. Interfaces that merge
three or four lists, merge packed records, return per-list consumption counts,
use temporary Tiles, stop on exhaustion, or merge four blocks from one Tile
are compound software lowerings and do not add operands or results to this
selector.

Each source is a nonempty single-row, row-major, already-sorted value stream.
The destination is single-row and row-major, with `ValidCol` equal to the sum
of both source `ValidCol` values. Source and destination share one DataType.
The exact supported DataTypes are `FP32` and `FP16`. `descending=0` requires
ascending sources and produces an ascending merge; `descending=1` requires
descending sources and produces a descending merge. If either source stream
is not sorted in the selected order, the complete block is illegal before any
architectural effect.

Equal values select the left source first. Numeric values precede NaNs in both
directions; NaNs preserve their source order and left-source precedence.
Signaling-NaN observation sets numeric invalid status, and signed zeros compare
equal. Both sources persist.

`B.DATR` is inapplicable and every field must remain zero. When present,
`B.IOR.RegSrc0` supplies `descending` and must contain exactly zero or one.
Omitting `B.IOR` selects ascending order. `RegSrc1`, `RegSrc2`, and `RegDst`
are unused and must select `zero`. `B.IOS` is illegal. All source and
destination `B.IOT` bindings use the same `PE_MASK`; any subset is legal and
mask zero is a strict no-op before source reads, sortedness checks, allocation,
numeric status, or faults.

Complete descriptor, control, type, shape, layout, capacity, definedness, and
input-order preflight precedes source snapshots. Destination payload,
definedness, Null padding, numeric status, and descriptor publish atomically;
rejection has no architectural effect.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Quantization, sorting, transpose, gather/scatter, and partial-region combination have operation-specific operand arity and shape effects that cannot be inferred from the generic Tile carrier. They also require deterministic index, stability, overlap, and multi-destination publication rules.

量化、排序、转置、gather/scatter 和部分区域组合具有无法从通用 Tile 载体推断的操作特定元数与形状效果，还需要确定的索引、稳定性、重叠和多目的发布规则。

### Detailed decision / 详细决策

The decisions close affine quantize/dequantize scalar parameters and types; stable row-group sort and two-stream merge; logical transpose; row-index gather/scatter; and origin-anchored partial add/multiply/min/max. Each contract fixes operand roles, shape/capacity checks, index legality, masks, aliases, applicable attributes, source snapshots, and atomic publication of every destination and numeric status.

相关决策闭合 affine quantize/dequantize 的标量参数与类型、稳定行组排序与双流归并、逻辑转置、行索引 gather/scatter，以及原点对齐的部分 add/multiply/min/max。每个契约固定操作数角色、形状/容量检查、索引合法性、掩码、别名、适用属性、源快照以及所有目的和数值状态的原子发布。

### What changed / 改动内容

#### English

- Defined complete schemas for conversion, sorting, layout, indexed, and partial-region selectors.
- Closed stability, index, overlap, multi-result, preflight, and rollback behavior.

#### 中文

- 为转换、排序、布局、索引和部分区域 selector 定义完整模式。
- 闭合稳定性、索引、重叠、多结果、预检和回滚行为。

### Scope and boundaries / 范围与边界

The selectors keep the exact operand counts and types recorded in their decisions. Compound software lowerings, extra parameter Tiles, auxiliary results, and unlisted layout modes do not become architectural operands or effects.

这些 selector 保持各自决策记录的精确操作数数量与类型。复合软件 lowering、额外参数 Tile、辅助结果和未列布局模式不会成为架构操作数或效果。

## Decision 137: `TTRANS` is a logical two-dimensional transpose

`TTRANS` is selected by TEPL carrier `Mode=3, Function=14` and executes on
the `SFU` engine. It reads one Local source Tile and creates one newly
allocated Local destination. For every source valid coordinate `[r,c]`, the
destination coordinate `[c,r]` receives the same logical element bit-for-bit.
The destination therefore has `ValidRow=source.ValidCol` and
`ValidCol=source.ValidRow`. The complete valid source rectangle must be
defined. The source persists.

Required nonzero `B.DIM LB0` supplies destination `ValidCol`; omitted `LB1`
supplies destination `ValidRow=1`; omitted `LB2` supplies destination physical
`Col=ValidCol`; physical rows derive from destination capacity, physical
columns, and DataType. The resulting destination dimensions must equal the
transposed source dimensions before effects. Source and destination use the
same DataType. Every assigned Tile DataType except `HiF4X2` is supported;
globally reserved encodings and `HiF4X2` reject before effects.

The source is addressed through its architectural layout. An assigned
`B.DATR.Layout` transformation governs destination physical placement without
changing the logical transpose. Every reserved Layout code rejects before
effects. `DataType`, `PadValueOrByteId`, `CMode`, `RMode`, `Sat`, and
`Canonicalize` are inapplicable and must remain at their operation-default
values. Physical destination elements outside the transposed valid rectangle
remain Null padding.

`TTRANS` has no architectural temporary-Tile operand and does not define a
separate convolution-layout conversion. A backend scratch Tile or a compound
format-conversion interface is a lowering detail and does not change the
selector's one-source, one-destination schema. `B.IOR` and `B.IOS` are
illegal. Source and destination `B.IOT` bindings use the same `PE_MASK`; any
subset is legal and mask zero is a strict no-op before reads, allocation, or
faults.

Complete schema, descriptor, type, dimension, layout, capacity, allocation,
mask, and source-definedness preflight precedes the source snapshot.
Destination payload, definedness, Null padding, and descriptor publish
atomically; rejection has no architectural effect.

## Decision 139: `TSCATTER` uses each index as a destination-row selector

`TSCATTER` is selected by TEPL carrier `Mode=3, Function=16` and executes on
the `SFU` engine. It reads one Local value source and one Local index source,
then creates one newly allocated Local destination. The two sources have the
same nonzero valid shape. The destination has the same `ValidCol` and a
nonzero `ValidRow` large enough for every selected row. For every source
coordinate `[r,c]`, the selected index value `k=index[r,c]` names a logical
destination row and the operation writes `destination[k,c]=source[r,c]`.

The index Tile DataType and value DataType pair is restricted by element
width. `FP32`, `S32`, and `U32` values use `S32` or `U32` indices. `FP16`,
`BF16`, `S16`, and `U16` values use `S16` or `U16` indices. `S8` and `U8`
values also use `S16` or `U16` indices. A signed index must be nonnegative,
and every index must be less than `destination.ValidRow`. Two source elements
must not select the same destination coordinate; duplicate destinations make
the complete block illegal before effects.

Required nonzero `B.DIM LB0` supplies destination `ValidCol`; omitted `LB1`
supplies `ValidRow=1`; omitted `LB2` supplies destination physical
`Col=ValidCol`; physical rows derive from capacity. `destination.ValidCol`
must equal both source `ValidCol` values, while both sources have equal
`ValidRow`. The complete valid rectangles of both sources must be defined.

An assigned `B.DATR.Layout` transformation governs destination physical
placement without changing row-index semantics. `DataType`, `CMode`, `RMode`,
`Sat`, and `Canonicalize` are inapplicable. `PadValueOrByteId` is fixed to
encoded zero for this operation: before applying the scatter writes, every
physical destination element is initialized to the selected value DataType's
positive or integer zero. Thus valid positions not selected by an index and
physical padding are defined zero rather than preserved old contents.

`B.IOR` and `B.IOS` are illegal. All three `B.IOT` bindings use the same
`PE_MASK`; any subset is legal and mask zero is a strict no-op before Tile
reads, index and duplicate checks, allocation, or faults. Both sources
persist. The destination is a renamed result and never reads a previous
destination value.

Complete schema, descriptor, type-pair, shape, layout, capacity, index-range,
duplicate-destination, definedness, mask, and allocation preflight precedes
source snapshots. Zero initialization, scattered payload, definedness, and
destination descriptor publish atomically; rejection has no architectural
effect.

## Decision 138: `TGATHER` uses each index as a source-row selector

`TGATHER` is selected by TEPL carrier `Mode=3, Function=15` and executes on
the `SFU` engine. It reads one Local value source and one Local index source,
then creates one newly allocated Local destination. The index source and
destination have the same nonzero valid shape. The value source has at least
the destination `ValidCol` columns. For every destination coordinate `[r,c]`,
the selected index value `k=index[r,c]` names a logical source row and the
result is `destination[r,c]=source[k,c]`.

The index Tile DataType is exactly `S32` or `U32`. A signed index must be
nonnegative, and every index must be less than `source.ValidRow`. An invalid
index makes the complete block illegal before source reads or destination
effects; indices never wrap, clamp, or produce an implementation-defined
value. The complete index valid rectangle and every selected value-source
element must be defined.

The exact value DataTypes are `FP32`, `FP16`, `S32`, `S16`, `U32`, and
`U16`. Source and destination use the same value DataType. Required nonzero
`B.DIM LB0` supplies destination `ValidCol`; omitted `LB1` supplies
`ValidRow=1`; omitted `LB2` supplies destination physical `Col=ValidCol`;
physical rows derive from capacity. The dimensions must match the index Tile
and fit the source column extent before effects.

An assigned `B.DATR.Layout` transformation governs destination physical
placement without changing row-index semantics. `DataType`,
`PadValueOrByteId`, `CMode`, `RMode`, `Sat`, and `Canonicalize` are
inapplicable and must remain at their operation-default values. Destination
physical elements outside the valid rectangle remain Null padding.

The selector has no architectural mask-pattern or temporary-Tile operand.
Mask-pattern gather and scratch-Tile interfaces are compound lowerings and do
not change the encoded three-Tile schema. `B.IOR` and `B.IOS` are illegal.
All three `B.IOT` bindings use the same `PE_MASK`; any subset is legal and
mask zero is a strict no-op before Tile reads, index checks, allocation, or
faults. Both sources persist.

Complete schema, descriptor, type, shape, layout, capacity, index-range,
definedness, mask, and allocation preflight precedes source snapshots.
Destination payload, definedness, Null padding, and descriptor publish
atomically; rejection has no architectural effect.

## Decision 140: `TPARTADD` combines two origin-anchored partial rectangles

`TPARTADD` is selected by TEPL carrier `Mode=3, Function=17` and executes on
the `SFU` engine. It reads two Local sources and creates one newly allocated
Local destination. All three Tiles use one DataType and row-major layout. Each
source valid rectangle is anchored at logical coordinate `[0,0]` and must fit
within the destination valid rectangle. At least one source valid rectangle
must equal the complete destination valid rectangle, so every destination
coordinate is covered by at least one source.

For each destination valid coordinate, if both sources cover that coordinate,
the result is their selected-DataType addition. If exactly one source covers
the coordinate, that source element is copied bit-for-bit. No coordinate may
be uncovered. Integer addition wraps modulo the selected element width;
floating addition, rounding, exceptional values, and numeric status follow the
same typed rules as `TADD`.

The exact supported DataTypes are `FP32`, `FP16`, `BF16`, `S32`, `S16`,
`S8`, `U32`, `U16`, and `U8`. Required nonzero `B.DIM LB0` supplies
destination `ValidCol`; omitted `LB1` supplies `ValidRow=1`; omitted `LB2`
supplies physical `Col=ValidCol`; physical rows derive from capacity. Source
physical shapes may differ, but their row-major descriptors and complete valid
rectangles must be legal and defined.

`B.DATR`, `B.IOR`, and `B.IOS` are illegal. Destination physical elements
outside its valid rectangle remain Null padding. All three `B.IOT` bindings
use the same `PE_MASK`; any subset is legal and mask zero is a strict no-op
before reads, allocation, numeric status, or faults. Both sources persist and
may alias each other or the destination because source payloads are
snapshotted before any result write.

Complete schema, descriptor, type, shape, coverage, capacity, definedness,
mask, and allocation preflight precedes source snapshots. Destination payload,
definedness, Null padding, numeric status, and descriptor publish atomically;
rejection has no architectural effect.

## Decision 142: `TPARTMAX` combines two origin-anchored partial rectangles

`TPARTMAX` is selected by TEPL carrier `Mode=3, Function=19` and executes on
the `SFU` engine. It reads two Local sources and creates one newly allocated
Local destination. All three Tiles use one DataType and row-major layout. Each
source valid rectangle is anchored at logical coordinate `[0,0]` and must fit
within the destination valid rectangle. At least one source valid rectangle
must equal the complete destination valid rectangle, so every destination
coordinate is covered by at least one source.

For each destination valid coordinate, if both sources cover that coordinate,
the result is their selected-DataType maximum. If exactly one source covers the
coordinate, that source element is copied bit-for-bit. No coordinate may be
uncovered. Signed integers use signed ordering and unsigned integers use
unsigned ordering. Floating one-NaN, two-NaN, signaling-NaN, canonical-NaN,
and signed-zero behavior follows `TMAX` exactly; a mixed-sign zero maximum is
positive zero.

The exact supported DataTypes are `FP32`, `FP16`, `BF16`, `S32`, `S16`,
`S8`, `U32`, `U16`, and `U8`. Required nonzero `B.DIM LB0` supplies
destination `ValidCol`; omitted `LB1` supplies `ValidRow=1`; omitted `LB2`
supplies physical `Col=ValidCol`; physical rows derive from capacity. Source
physical shapes may differ, but their row-major descriptors and complete valid
rectangles must be legal and defined.

`B.DATR`, `B.IOR`, and `B.IOS` are illegal. Destination physical elements
outside its valid rectangle remain Null padding. All three `B.IOT` bindings
use the same `PE_MASK`; any subset is legal and mask zero is a strict no-op
before reads, allocation, numeric status, or faults. Both sources persist and
may alias each other or the destination because source payloads are
snapshotted before any result write.

Complete schema, descriptor, type, shape, coverage, capacity, source-encoding,
definedness, mask, and allocation preflight precedes source snapshots.
Destination payload, definedness, Null padding, numeric status, and descriptor
publish atomically; rejection has no architectural effect.

## Decision 143: `TPARTMIN` combines two origin-anchored partial rectangles

`TPARTMIN` is selected by TEPL carrier `Mode=3, Function=20` and executes on
the `SFU` engine. It reads two Local sources and creates one newly allocated
Local destination. All three Tiles use one DataType and row-major layout. Each
source valid rectangle is anchored at logical coordinate `[0,0]` and must fit
within the destination valid rectangle. At least one source valid rectangle
must equal the complete destination valid rectangle, so every destination
coordinate is covered by at least one source.

For each destination valid coordinate, if both sources cover that coordinate,
the result is their selected-DataType minimum. If exactly one source covers the
coordinate, that source element is copied bit-for-bit. No coordinate may be
uncovered. Signed integers use signed ordering and unsigned integers use
unsigned ordering. Floating one-NaN, two-NaN, signaling-NaN, canonical-NaN,
and signed-zero behavior follows `TMIN` exactly; a mixed-sign zero minimum is
negative zero.

The exact supported DataTypes are `FP32`, `FP16`, `BF16`, `S32`, `S16`,
`S8`, `U32`, `U16`, and `U8`. Required nonzero `B.DIM LB0` supplies
destination `ValidCol`; omitted `LB1` supplies `ValidRow=1`; omitted `LB2`
supplies physical `Col=ValidCol`; physical rows derive from capacity. Source
physical shapes may differ, but their row-major descriptors and complete valid
rectangles must be legal and defined.

`B.DATR`, `B.IOR`, and `B.IOS` are illegal. Destination physical elements
outside its valid rectangle remain Null padding. All three `B.IOT` bindings
use the same `PE_MASK`; any subset is legal and mask zero is a strict no-op
before reads, allocation, numeric status, or faults. Both sources persist and
may alias each other or the destination because source payloads are
snapshotted before any result write.

Complete schema, descriptor, type, shape, coverage, capacity, source-encoding,
definedness, mask, and allocation preflight precedes source snapshots.
Destination payload, definedness, Null padding, numeric status, and descriptor
publish atomically; rejection has no architectural effect.

## Decision 141: `TPARTMUL` combines two origin-anchored partial rectangles

`TPARTMUL` is selected by TEPL carrier `Mode=3, Function=18` and executes on
the `SFU` engine. It reads two Local sources and creates one newly allocated
Local destination. All three Tiles use one DataType and row-major layout. Each
source valid rectangle is anchored at logical coordinate `[0,0]` and must fit
within the destination valid rectangle. At least one source valid rectangle
must equal the complete destination valid rectangle, so every destination
coordinate is covered by at least one source.

For each destination valid coordinate, if both sources cover that coordinate,
the result is their selected-DataType multiplication. If exactly one source
covers the coordinate, that source element is copied bit-for-bit. No
coordinate may be uncovered. Integer multiplication wraps modulo the selected
element width; floating multiplication, rounding, exceptional values, signed
zeros, and numeric status follow the same typed rules as `TMUL`.

The exact supported DataTypes are `FP32`, `FP16`, `BF16`, `S32`, `S16`,
`S8`, `U32`, `U16`, and `U8`. Required nonzero `B.DIM LB0` supplies
destination `ValidCol`; omitted `LB1` supplies `ValidRow=1`; omitted `LB2`
supplies physical `Col=ValidCol`; physical rows derive from capacity. Source
physical shapes may differ, but their row-major descriptors and complete valid
rectangles must be legal and defined.

`B.DATR`, `B.IOR`, and `B.IOS` are illegal. Destination physical elements
outside its valid rectangle remain Null padding. All three `B.IOT` bindings
use the same `PE_MASK`; any subset is legal and mask zero is a strict no-op
before reads, allocation, numeric status, or faults. Both sources persist and
may alias each other or the destination because source payloads are
snapshotted before any result write.

Complete schema, descriptor, type, shape, coverage, capacity, definedness,
mask, and allocation preflight precedes source snapshots. Destination payload,
definedness, Null padding, numeric status, and descriptor publish atomically;
rejection has no architectural effect.
