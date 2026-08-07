# ASL-Golden Instruction Reference Design

## Purpose

PTO instruction semantics, legality, decode behavior, and architectural effects
must have one machine-checkable origin. ASL is that origin. Markdown explains
the architecture to humans, but it must not restate normative ASL behavior in
hand-maintained copies.

The public instruction reference follows the reading order used by mature ISA
manuals: purpose, encoding variants, decode, assembler symbols, operation,
legality, operational information, and examples. Tile-operation pages also show
the complete block composition that produces the operation.

## Source-of-truth order

1. Mnemonic ASL files own instruction decode, legality, and operation semantics.
2. Machine-readable catalogs are deterministic projections of ASL instruction
   metadata and remain useful review and release artifacts.
3. Generated Markdown regions embed exact ASL excerpts and catalog-derived
   encoding tables.
4. Hand-written Markdown owns only explanation, rationale, examples, and
   programmer guidance outside generated regions.
5. MkDocs navigation is generated from the same instruction index used for the
   Markdown projections.

Any difference between these layers is a repository error. Generators must
support a fail-closed `--check` mode and must never silently accept stale output.

## Mirrored instruction trees

Every architectural mnemonic has exactly one ASL file and exactly one Markdown
page at a matching path below its surface root.

```text
asl/scalar/agu/LW.asl
docs/instructions/scalar/agu/LW.md

asl/block/operands/B.IOT.asl
docs/instructions/block/operands/B.IOT.md

asl/tile/tile-tile-elementwise/arithmetic/TADD.asl
docs/instructions/tile/tile-tile-elementwise/arithmetic/TADD.md
```

Multiple binary forms of one mnemonic remain together. Common types, state,
numeric helpers, and reusable algorithms live under explicit `common/`
directories and do not pretend to be instruction pages. Dispatch files route to
mnemonic entry points but do not duplicate mnemonic semantics.

Scalar pages are grouped by architectural uop class: AGU, ALU, AMO, BRU, FSU,
and SYS. Block pages retain the existing Block ISA name and group BSTART, BSTOP,
and B.* forms by overview, lifecycle, operands, attributes, execution, and
encoding roles.

Tile directories are derived from the `类型` and `子类型` columns of
`spec/encoding/PTO-ISA-Encoding.xlsx`. The stable English directory slugs are a
checked mapping of those spreadsheet labels. The generator must reject an
unknown category, missing mnemonic, duplicate mnemonic, or category drift.

## ASL documentation regions

Mnemonic ASL files expose stable documentation regions:

```asl
// DOC-BEGIN: decode
...
// DOC-END: decode

// DOC-BEGIN: operation
...
// DOC-END: operation
```

The Markdown generator copies these regions verbatim into generated fences:

```markdown
<!-- GENERATED-ASL-BEGIN: operation source=asl/.../TADD.asl -->
```asl
...
```
<!-- GENERATED-ASL-END: operation -->
```

Generated regions are never edited by hand. The checker proves that every
region names an existing ASL source, the source maps back to the page, and the
embedded bytes equal the current ASL bytes.

## Instruction page contract

Scalar and Block pages contain:

1. mnemonic and one-sentence purpose;
2. encoding variants;
3. embedded Decode ASL;
4. assembler syntax and symbols;
5. embedded Operation ASL;
6. legality, traps, architectural side effects, and ordering;
7. examples and operational information.

Tile pages add a block-composition section before Operation. It shows the exact
ordered composition from BSTART through BSTOP and classifies each header as
required, optional, defaulted, or forbidden. It also maps header occurrences to
operand roles and explains repeated B.IOT, B.IOS, and B.IOR ordering.

## Shape and capacity contract

`TSize` denotes one selected PE's capacity. PE_MASK determines how many equal
per-PE allocations are required; it does not partition a single payload.

For every ordinary Local or Shared tile:

```text
capacity_bits = DecodeTSize(TSize) * 8
row_bits      = columns * ElementBits(dtype)
rows          = capacity_bits / row_bits
```

`columns` must be nonzero and a power of two. Every architectural element width
is a power of two, so a legal row fits and divides the power-of-two capacity
exactly. Legality requires `valid_columns <= columns` and
`valid_rows <= rows`. `rows` is derived descriptor state and has no additional
instruction encoding.

Matrix operations require nonzero power-of-two M, N, and K. Each operand layout
determines its physical column count; that column count then uses the same
per-PE capacity formula. All dimension and capacity checks happen before
allocation, reads, writes, rename changes, consume effects, or faults caused by
later execution.

## Version-neutral normative text

Active ASL and active instruction/manual pages describe the current architecture
without embedding a release number. Historical ADRs, release notes, and release
manifests may retain version identifiers as historical facts, but they are not
active architecture definitions.

## Agent indexing contract

`AGENTS.md` and the instruction landing page direct agents to inspect:

1. `asl/<surface>/<classification>/<mnemonic>.asl` for normative behavior;
2. the mirrored Markdown page for explanation and examples;
3. generated catalogs only for inventory, encoding lookup, and automation.

The generated instruction index records mnemonic, surface, classification,
ASL path, Markdown path, encoding identity, and block-composition profile.

## Acceptance criteria

- Every active mnemonic maps one-to-one between ASL and Markdown.
- Markdown ASL regions are exact generated copies and stale copies reject.
- Scalar pages are grouped by uop class.
- Block naming remains Block ISA and every active BSTART/BSTOP/B.* mnemonic has
  its own page and ASL file.
- Tile classification exactly follows the encoding workbook.
- Every Tile page shows the complete block composition and embedded semantics.
- Ordinary Col and matrix M/N/K reject zero and non-power-of-two values.
- `rows` is derived from per-PE TSize, dtype, and physical columns and must cover
  `valid_rows`.
- One deterministic command regenerates catalogs, Markdown, and MkDocs nav;
  `--check` rejects all drift.
- Active ASL and normative instruction pages contain no release-version label.
