# Scalar ISA

This directory publishes the Scalar ISA reference used by PTO ISA 0.58.0. The
normative PTO/Linx scalar encoding ABI contains **474 accepted binary forms**.
The directory contains 1105 pages because it also includes register,
architecture, and source-reference material; page count, source mnemonic
count, and accepted binary form count are different measures.

## Two-layer architecture

The Linx ISA has two instruction layers:

- **Scalar layer** (documented here): 474 accepted binary forms covering
  integer, floating-point, memory, atomic, control-flow, and system operations.
  Organized as `misa_c` (compressed), `misa_f` (float), `misa_g` (general),
  `misa_h` (half-long), `misa_l` (long), `misa_s` (system).

- **Vector/tile layer** (not part of PTO Scalar ISA): Linx-only instructions with `V.`
  prefix plus block-start (`BSTART.*`) and block-control (`B.*`) instructions.
  The vector layer provides SIMD-style parallelism and is documented separately
  in the linx-isa superproject.

The scalar layer is the minimum required for general-purpose computation.
The vector/tile layer is an optional extension for accelerated workloads.

## Normative definition

The canonical PTO ISA 0.58 scalar definition is
`spec/catalog/scalar-forms.json`. Linx ISA 0.58 imports that catalog unchanged
as `isa/v0.58/state/pto_scalar_forms.json`. Alignment requires exact equality
of form identity, assembly spelling, length, encoding, operand field layout,
signedness, and legality constraints—not merely equal mnemonic counts.

The Scalar ISA is separate from the 109-operation Tile catalog.
`spec/evidence/source-locks/` records the provenance of imported source pages.
