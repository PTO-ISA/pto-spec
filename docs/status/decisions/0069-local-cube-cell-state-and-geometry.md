---
{
  "id": "ADR-0069",
  "title": "Local CUBE CELL State and Geometry",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-20",
  "accepted": "2026-08-20",
  "rejected": null,
  "superseded": null,
  "baseline": "0b8ce516ffe998b24c4bae4c1a9dbca2e0d76510",
  "target_releases": [
    "0.58.3"
  ],
  "affected_ndf": [
    "PTO-CUBE-CELL-STATE-001"
  ],
  "affected_units": [
    "PTO-TILE-MODEL-SHAPE-CUBE-CELL"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/102",
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0069: Local CUBE CELL State and Geometry

- Issue: [#102](https://github.com/PTO-ISA/pto-spec/issues/102)
- Umbrella: [#72](https://github.com/PTO-ISA/pto-spec/pull/72)
- Baseline: `0b8ce516ffe998b24c4bae4c1a9dbca2e0d76510`
- Requirement: `PTO-CUBE-CELL-STATE-001`

## Decision

Local Tile descriptors gain three persistent CUBE layouts:

- `CUBE_M16` for A, C, and D storage with a sixteen-row CELL class;
- `CUBE_M32` for A, C, and D storage with a thirty-two-row CELL class; and
- `CUBE_N8` for B storage with an eight-column CELL class.

The layout is architectural descriptor state. It survives successful bundle
completion and is consumed by later CUBE Matrix operations. It is not a
temporary transfer hint and is not inferred from an instruction mnemonic.

Shared Tiles remain ordinary two-dimensional descriptors. Shared layout state
and Matrix operand roles are owned by separate decisions.

## CELL geometry

One CELL is exactly 128 bytes. Its logical geometry is derived from the layout
and element width:

| Layout | b32 | b16 | b8 | b4 |
| --- | --- | --- | --- | --- |
| `CUBE_N8` | K4 x N8 | K8 x N8 | K16 x N8 | K32 x N8 |
| `CUBE_M32` | M32 x X1 | M32 x X2 | M32 x X4 | M32 x X8 |
| `CUBE_M16` | M16 x X2 | M16 x X4 | M16 x X8 | M16 x X16 |

For A, X denotes K. For C and D, X denotes N. For B, K is the
within-CELL reduction dimension and N is the fixed eight-column dimension.

`CUBE_M16` b4 uses this two-word ordering for each M row:

```text
word 0: x0 x1 x2 x3 x8  x9  x10 x11
word 1: x4 x5 x6 x7 x12 x13 x14 x15
```

All other rows use the width-parametric CELL mapping with the X or K direction
as the fast logical direction. `HiF4X2` and every b64 dtype are illegal CUBE
CELL types.

## Descriptor and capacity

Valid M, N, and K are positive logical dimensions independent of `TSize`.
`TSize` is the selected PE's byte capacity; it is not a logical dimension and
does not force a valid dimension to be a power of two.

The descriptor derives and retains the aligned storage dimensions, repeat
counts, CELL count, and required bytes. B uses K-fast and N-slow CELL order:

```text
cell_index(n_cell, k_cell) = n_cell * K_repeat + k_cell
```

Required bytes must not exceed the selected per-PE `TSize`. Unused capacity is
legal and does not enlarge the valid region. No new encoded storage-dimension
field is introduced.

## Valid region and padding

Only positions inside the valid region are architectural matrix elements.
Physical CELL positions outside that region contain the resolved PadValue.
Matrix execution ignores padding positions and cannot publish them as valid
results.

Changing only a valid extent within unchanged derived geometry does not
reinterpret payload bytes. A layout, dtype, or valid-geometry change that
changes the derived CELL geometry requires a new physical Tile allocation.

## Allocation, reset, and faults

Complete layout, dtype, geometry, capacity, and PadValue legality precedes
descriptor or payload effects. Rejected configuration preserves the previous
Tile. Successful reconfiguration allocates and publishes one new descriptor
and payload state atomically.

Reset and release clear the persistent layout and every derived CELL field.
Trap entry does not manufacture or reinterpret CUBE state; retry observes the
same live Tile state that existed before the fault.

## Protected behavior

- Ordinary Tile descriptors and indexing remain unchanged.
- `TSize` remains a per-PE encoded capacity.
- Fixed PE identities and zero-mask strict no-op behavior remain unchanged.
- CUBE layout does not widen an operation's legal dtype profile.

## Explicit exclusions

This decision allocates no `B.DATR` conversion encoding and defines no
TLOAD/TSTORE conversion, Matrix operand binding, cooperative Shared execution,
transpose control, accumulator identity, or post-process output behavior.

## Implementation and verification evidence

The accepted implementation, generated documentation, and independent tests prove:

1. every b32/b16/b8/b4 layout row and the M16-b4 interleave;
2. K-fast/N-slow multi-CELL order and partial K/N tails;
3. valid dimensions independent of exact `TSize` capacity;
4. PadValue in every physical position outside the valid region;
5. `HiF4X2`, b64, zero dimension, and insufficient-capacity rejection before
   effects;
6. new allocation for changed geometry and preservation after failed change;
7. reset, release, and retry behavior; and
8. no change to ordinary Tile behavior.

This decision became executable through the implementation linked in the ADR
frontmatter. Release closure remains commit-scoped and is not implied by the
accepted ADR status.
