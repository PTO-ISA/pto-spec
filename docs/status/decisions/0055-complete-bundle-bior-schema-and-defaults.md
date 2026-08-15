# ADR 0055: Complete-Bundle B.IOR Schema and Defaults

> Historical-evidence note: verification paths named below record the evidence used when this ADR was accepted; deleted aggregate checks are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

- **Status**: accepted
- **Date**: 2026-08-07
- **Deciders**: PTO ISA maintainers
- **Tracks**: issue #51

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
