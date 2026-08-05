# Compatibility appendices

`scalar/` is the pinned Linx scalar micro-ISA compatibility snapshot for
DavinciOO. It documents the **scalar layer** of the Linx ISA (499 instructions)
as inherited by the PTO execution environment.

## Two-layer architecture

The Linx ISA has two instruction layers:

- **Scalar layer** (documented here): 499 instructions covering integer,
  floating-point, memory, atomic, control-flow, and system operations.
  Organized as `misa_c` (compressed), `misa_f` (float), `misa_g` (general),
  `misa_h` (half-long), `misa_l` (long), `misa_s` (system).

- **Vector/tile layer** (NOT documented here): ~184 instructions with `V.`
  prefix plus block-start (`BSTART.*`) and block-control (`B.*`) instructions.
  The vector layer provides SIMD-style parallelism and is documented separately
  in the linx-isa superproject.

The scalar layer is the minimum required for general-purpose computation.
The vector/tile layer is an optional extension for accelerated workloads.

## Source

These pages are sourced from the Linx ISA v0.57 specification in the
[linx-isa](https://github.com/LinxISA/linx-isa) superproject. The canonical
scalar instruction catalog is at `isa/v0.57/linxisa-v0.57.json`.

It is not part of the 109-operation Tile catalog and does not add
PTO Tile operations. `spec/evidence/source-locks/` records the provenance
of these snapshots.
