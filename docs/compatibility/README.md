# Compatibility appendices

`scalar/` is the pinned 1105-page Linx scalar micro-ISA compatibility snapshot
for DavinciOO. The normative PTO/Linx scalar encoding ABI contains **474
accepted forms**. Page count, source mnemonic count, and accepted binary form
count are different measures and must not be substituted for one another.

## Two-layer architecture

The Linx ISA has two instruction layers:

- **Scalar layer** (documented here): 474 accepted binary forms covering
  integer, floating-point, memory, atomic, control-flow, and system operations.
  Organized as `misa_c` (compressed), `misa_f` (float), `misa_g` (general),
  `misa_h` (half-long), `misa_l` (long), `misa_s` (system).

- **Vector/tile layer** (NOT documented here): ~184 instructions with `V.`
  prefix plus block-start (`BSTART.*`) and block-control (`B.*`) instructions.
  The vector layer provides SIMD-style parallelism and is documented separately
  in the linx-isa superproject.

The scalar layer is the minimum required for general-purpose computation.
The vector/tile layer is an optional extension for accelerated workloads.

## Source

These pages are sourced from the Linx ISA v0.57.1 scalar baseline in the
[linx-isa](https://github.com/LinxISA/linx-isa) superproject. The canonical
PTO 0.58 catalog is `spec/catalog/scalar-forms.json`; Linx ISA 0.58 imports
that catalog unchanged as `isa/v0.58/state/pto_scalar_forms.json`. Alignment
requires exact equality of form identity, assembly spelling, length, encoding,
operand field layout, signedness, and legality constraints—not merely equal
mnemonic counts.

It is not part of the 109-operation Tile catalog and does not add
PTO Tile operations. `spec/evidence/source-locks/` records the provenance
of these snapshots.
