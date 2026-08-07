# B.IOR Bundle Schema and Defaulting Design

## Status

Approved by the architecture owner on 2026-08-07 and tracked by
[PTO-ISA/pto-spec#51](https://github.com/PTO-ISA/pto-spec/issues/51).

## Goal

Make PTO v0.58 scalar bundle binding distinguish encoded header presence,
resolved operand presence, and register selector value. Selector zero is
`R0/zero`; it is never an absence marker.

## Scope

This change covers PTO direct operation bundles, their normative ASL model,
machine-readable catalogs, current documentation, generated projections, and
tests. LinxISA imports this PTO surface but keeps its decoupled programmable-body
B.IOR declaration stream as a separate Linx-only contract.

## Bundle Schema Resolution

The implementation MUST resolve an operation's operand schema after composing
all instructions in the bundle. `BSTART`, `B.FPATR`/`PostProcessConfig`, and
every other schema-contributing header participate. Each header instruction
MUST define the values used when that instruction or an optional operand is
omitted.

For the currently executable PTO direct-operation catalog:

- `address` and `scalar0` consume `B.IOR.RegSrc0`;
- `scalar1` consumes `B.IOR.RegSrc1`;
- no accepted direct operation consumes `RegSrc2` or `RegDst`;
- later operation families MAY extend this mapping only through an explicit
  catalog/schema change with executable tests.

The ASL model MUST derive consumed fields from the resolved operation schema,
not from whether a selector is zero and not from a fixed encoded source count.

## Encoding and Defaults

PTO direct operation bundles permit zero or one encoded `B.IOR` instruction.
If `B.IOR` is omitted, every schema-consumed register uses `R0/zero` unless the
selected operation explicitly defines another default. A present `B.IOR` MUST
encode zero in every field not consumed by the resolved schema.

All four encoded B.IOR selectors MUST be in the absolute GPR range `0..23`.
Selectors `24..31`, including the generic scalar temporary-queue encodings,
MUST be rejected before the B.IOR state is updated. Repeated source values and
source/destination aliases are legal.

A second encoded B.IOR in one PTO direct bundle MUST be rejected without
overwriting the first binding.

## Dynamic Semantics

Execution reads only schema-consumed operands. An omitted B.IOR supplies its
defaults without creating an encoded binding. A present consumed selector zero
reads architectural `R0/zero`; a present unconsumed nonzero selector is a bundle
legality fault.

`PE_MASK=0000` retains its strict no-effect rule. B.IOR may be omitted and
defaults applied, but the operation performs no register read, memory access,
allocation, rename, fault, consume, or lifetime update.

## Assembly and Disassembly

Canonical B.IOR operand text is schema-shaped and uses ABI aliases:

```text
R0=zero, R1=sp, R2..R9=a0..a7, R10=ra,
R11..R19=s0..s8, R20..R23=x0..x3
```

The assembler MAY also accept `R0..R23`. Numeric zero placeholders and relative
`T#n`/`U#n` spellings are invalid. Examples:

```asm
B.IOR a0
B.IOR zero
B.IOR a0, a0
B.IOR a0, ->a0
```

Disassembly MUST collect the complete bundle before rendering B.IOR operands.
If no B.IOR word is encoded, it emits no B.IOR line and consumers apply
defaults. If an all-zero B.IOR word is encoded, byte-exact disassembly preserves
that instruction and prints the schema-consumed `zero` operands. A standalone
decoder without bundle context MUST use a raw/unknown representation rather
than guessing arity.

`B.IOS` and destination-bearing `B.IOT` canonical text uses semantic per-PE
sizes (`128B` through `8KB`), not raw TSize bit strings.

## LinxISA Boundary

LinxISA MUST expose two separate contracts:

- imported PTO direct operations: complete-bundle schema resolution, defaults,
  absolute B.IOR GPRs, and at most one B.IOR;
- Linx-only decoupled programmable bodies: the Linx declaration stream may use
  multiple B.IOR records and repeated input/output registers.

The Linx projection MUST also remove active `C.B.IOS`, remove mask-only Shared
`B.IOT`, add the 32-bit PTO `B.IOS`, and preserve exact PTO scalar/command form
constraints and logical-field metadata.

## Verification

The change requires fail-closed tests for:

- all 24 absolute selectors and rejection of 24..31;
- omitted B.IOR defaults;
- consumed zero versus unconsumed zero;
- unconsumed nonzero rejection;
- second-B.IOR rejection without overwrite;
- repeated/aliased selectors;
- zero-mask omission with no dynamic effects;
- generated documentation and catalog projection freshness;
- exact PTO-to-Linx common-form parity after the Linx relock.
