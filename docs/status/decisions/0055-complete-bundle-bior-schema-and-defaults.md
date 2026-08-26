---
{
  "id": "ADR-0055",
  "title": "Complete-Bundle B.IOR Schema and Defaults",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "PTO ISA maintainers"
  ],
  "created": "2026-08-07",
  "accepted": "2026-08-07",
  "rejected": null,
  "superseded": null,
  "baseline": "8a77c9f0eab36cc41051519366ff163171f81463",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-B-IOR-BINDING-001",
    "PTO-BARG-CONTINUATION-001",
    "PTO-BSTART-CALL-DECISION-BINDING-001",
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
    "PTO-REQ-BUNDLE-STATE-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-IOR",
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
    "PTO-BLOCK-MODEL-DISPATCH-HISTOGRAM-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-NUMERIC-CONTROL",
    "PTO-BLOCK-MODEL-DISPATCH-QUANTIZATION-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
    "PTO-BLOCK-MODEL-DISPATCH-SORTING-SCHEMA",
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
    "PTO-BLOCK-MODEL-STATE-TYPES"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0055: Complete-Bundle B.IOR Schema and Defaults

> Superseded in part by ADR 0074: TLOAD/TSTORE `B.IOR.RegSrc1` and its dense
> omission default are byte quantities. Encoding, schema resolution, and the
> omission-versus-encoded-zero distinction below remain in force.

> Historical-evidence note: verification paths named below record the evidence used when this ADR was accepted; deleted aggregate checks are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

- **Date**: 2026-08-07
- **Deciders**: PTO ISA maintainers
- **Tracks**: issue #51

Current release inventory is governed by ASL and generated projections;
numeric inventories below are acceptance-time history, not the current active
decoder set.

## Context

The reissued PTO ISA 0.58 catalog encodes `B.IOR` with four five-bit fields,
but older prose treated selector zero as absence, rejected aliases, and rendered
all raw fields before the operation's final operand schema was known. That
model cannot distinguish three separate facts: whether a B.IOR word exists,
whether the completed bundle schema consumes a field, and which architectural
register a consumed field selects.

The mismatch is visible when other headers contribute to the schema. In
particular, Matrix PostProcessConfig is known only after `B.FPATR` and related
attributes are composed with `BSTART`. A disassembler that renders B.IOR from
the word alone can therefore guess the wrong arity. The same ambiguity made an
omitted instruction indistinguishable from an encoded selector zero.

## Decision

PTO direct-operation bundles allow zero or one encoded `B.IOR`. The active
operand schema is resolved after the complete bundle is collected from
`BSTART`, `B.FPATR`/PostProcessConfig, and every other schema-contributing
header. Each header defines the default contribution used when the header or
an optional operand is omitted.

The same completed-schema rule applies to the full direct-operation operand
record. Ordered B.IOT entries provide every required tile destination/source;
B.IOR provides consumed GPR inputs; B.DIM, B.DATR, and related headers provide
their named controls; remaining optional fields retain the selected
operation's explicit default. Consequently all 109 accepted direct tile
operations are schema-representable, while malformed or surplus bindings
remain fail-closed.

Encoded-instruction presence, schema operand presence, and selector value are
separate architectural concepts. If B.IOR is omitted, every consumed register
operand defaults to `R0/zero` unless its operation explicitly defines another
default. If B.IOR is present, selector zero is the real architectural zero
register. Fields not consumed by the resolved schema must be encoded as zero,
and execution reads only consumed fields.

For the current executable direct-operation catalog, register inputs bind to
`RegSrc0` and `RegSrc1` in architectural operand order. An `address`, when
present, is the first input; otherwise `scalar0` is first. No current direct
operation consumes `RegSrc2` or `RegDst`; adding such a consumer requires an
explicit catalog/schema change and executable evidence. ADR 0058 refines this
consumer statement for the complete ordered GPR schema and records the
operation-specific control decoding for `diagonal` and `flag0`.

TLOAD and TSTORE keep their existing instruction encoding, B.IOR layout,
opcode, selector, and instruction length. `RegSrc0` supplies the base address;
`RegSrc1` supplies row stride in elements. A two-dimensional access uses
`base + (row * row_stride + column) * element_size`, with packed four-bit
types selecting the byte and nibble from that same logical index. If B.IOR is
omitted, base defaults to `zero` and row stride defaults to resolved `LB2/Col`
for dense rows. If B.IOR is encoded with `RegSrc1=zero`, the stride is the real
zero-register value; the omission default does not apply.

All four B.IOR fields use absolute GPR selectors `0..23`. Values `24..31` are
reserved in this instruction even where the generic scalar selector namespace
assigns them another meaning. They reject during decoded operand legality,
before B.IOR state changes. Repeated inputs and source/destination aliases are
legal. A second B.IOR is a bundle-control fault and does not overwrite the
first binding.

Canonical text uses `zero/sp/a0..a7/ra/s0..s8/x0..x3`; an assembler may also
accept `R0..R23`. Numeric zero placeholders and relative register spellings are
not canonical B.IOR operands. Disassembly collects the full bundle before
rendering a schema-shaped operand list. No encoded word produces no line;
encoded all-zero produces a B.IOR line with the consumed `zero` operands. A
standalone decoder without bundle context emits a raw/unknown representation.

PTO does not define a decoupled programmable-body B.IOR declaration stream.
Multiple declaration records and relative dependency-register semantics are
outside the PTO instruction contract.

`PE_MASK=0000` remains a strict no-effect case. Schema defaults may be
resolved, but no register read, memory access, allocation, rename, fault,
consume, descriptor update, or lifetime update occurs.

## Consequences

- PTO v0.58 keeps the same B.IOR bit layout and form identity; only legality,
  schema resolution, canonical text, and dynamic defaulting change.
- Selector-range constraints become machine-readable command-catalog data and
  are inherited by generated decoders and downstream PTO projections.
- Because the binary-closure fingerprint includes decoded legality constraints,
  the reviewed 573-form envelope is rebound from
  `9155a78499c4908e0fdc7ac2a48159eacb5c1dfc78ea724dbedf689369430993` to
  `5f2855a4a9d8fe8fc2908a3940b9d9153f7232222fdd486a675217106142b4a3`.
  The B.IOR field positions, masks, matches, length, and TLOAD/TSTORE
  mode/function selectors do not change.
- The ASL bridge no longer requires an encoded B.IOR merely because an
  operation consumes a scalar/address operand.
- Shared TLOAD/TSTORE use the same unchanged base/row-stride B.IOR fields and
  omission defaults; an encoded Shared B.IOR still requires every unconsumed
  field to be zero.
- Historical documents remain evidence of the superseded design; current
  instruction and assembly pages use semantic sizes and schema-shaped GPR text.

## Supersession

This decision supersedes ADR 0032's and ADR 0036's narrow three-field bundle
bridge, and ADR 0052/ADR 0054 where they describe B.IOR absence, raw-field
assembly, duplicate-register legality, or mandatory scalar binding. ADR 0058
narrowly supersedes the complete-bundle consumer-resolution paragraph above;
the B.IOR encoding, omission-versus-zero distinction, and all other retained
decisions remain in force.

## Verification

The independent points under `tests/asl/block/operands/B.IOR/` cover selector
range, omission/defaults,
encoded-zero semantics, unused nonzero rejection, repeated selectors, second-
B.IOR preservation, and zero-mask no effects. `scripts/generate-asl-decoders`
projects the catalog constraints into the executable decoder;
`scripts/check-catalogs`, `scripts/check-binary-closure`, repository checks,
and the release manifest bind the decision to PTO 0.58 artifacts.
