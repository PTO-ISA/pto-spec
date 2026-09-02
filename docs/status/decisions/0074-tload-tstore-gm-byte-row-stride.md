---
{
  "id": "ADR-0074",
  "title": "TLOAD/TSTORE GM Byte Row Stride",
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
  "baseline": "15dcfc52b2710c28cf7a50da23057b0fcb9fd7c3",
  "target_releases": [
    "0.58.3"
  ],
  "affected_ndf": [
    "PTO-ARCH-GM-ACCESS-001",
    "PTO-B-IOR-BINDING-001",
    "PTO-BSTART-TLOAD-CUBE-001",
    "PTO-BSTART-TLOAD-MEMORY-001",
    "PTO-BSTART-TSTORE-CUBE-001",
    "PTO-BSTART-TSTORE-MEMORY-001",
    "PTO-TLOAD-CUBE-001",
    "PTO-TLOAD-MEMORY-001",
    "PTO-TSTORE-CUBE-001",
    "PTO-TSTORE-MEMORY-001"
  ],
  "affected_units": [
    "PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-BSTART-TLOAD",
    "PTO-BLOCK-BSTART-TSTORE",
    "PTO-TILE-TLOAD",
    "PTO-TILE-TSTORE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/115",
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0074: TLOAD/TSTORE GM Byte Row Stride

- Issue: [#115](https://github.com/PTO-ISA/pto-spec/issues/115)
- Baseline: `15dcfc52b2710c28cf7a50da23057b0fcb9fd7c3`
- Requirement: `PTO-ARCH-GM-ACCESS-001`

## Decision

For `TLOAD` and `TSTORE`, `B.IOR.RegSrc0` selects the per-PE GM base byte
address and `B.IOR.RegSrc1` selects `row_stride_bytes`, the XLEN byte distance
between adjacent row starts. The encoding, selector domain, and PE-private GPR
resolution do not change.

For byte-sized or wider elements at `(row, column)`:

```text
byte_address = base_address
             + row * row_stride_bytes
             + column * element_size_bytes
```

The encoded stride is added as a byte quantity and is not multiplied by the
element size a second time.

Packed four-bit transfers use a byte-aligned row base:

```text
byte_address = base_address
             + row * row_stride_bytes
             + floor(column / 2)
nibble       = low when column is even, high when column is odd
```

An odd physical row width therefore leaves the unused high nibble of that
row's final byte outside the next row. `TSTORE` preserves the sibling nibble.

## Omission and zero

When the complete `B.IOR` instruction is omitted, the base defaults to zero
and the row stride defaults to the dense physical row width in bytes:

```text
ceil(physical_columns * element_bits / 8)
```

An encoded zero selector is present and reads the architectural zero GPR. A
selected GPR whose value is zero supplies a real zero byte stride. Neither case
selects the omission default.

`B.DIM.LB2` remains the physical column count in elements. It contributes to
the omitted dense default only through the DataType-dependent byte conversion;
it is not itself a byte stride.

## Scope and preserved behavior

- Local and Shared `TLOAD`/`TSTORE`, including `TSTORE.SPART`, use the same
  byte-row formula for every selected PE.
- Complete-footprint preflight, precise faults, restart, PTO-TSO events,
  source snapshots, destination publication, PE masks, and cross-PE conflict
  obligations are unchanged.
- Indexed TLSU uses its separately owned base-plus-element-row-stride and
  logical-index contract in ADR-0078; this dense TLOAD/TSTORE decision does not
  redefine that interface.
- `TPREFETCH` retains its separately owned logical-element row-stride contract;
  this decision does not change its encoding or address formula.
- No compiler, emulator, timing model, benchmark, or backend mechanism becomes
  normative through this decision.

## Compatibility and supersession

The instruction bits are unchanged, but element-stride and byte-stride binaries
are not semantically compatible for element widths other than one byte. This
decision supersedes only the TLOAD/TSTORE element-unit statements in ADR 0055
and ADR 0056 and the earlier issue resolutions in #76 and #89. Their encoding,
omission-versus-zero, per-PE GPR, mask, preflight, and ordering decisions remain
in force.

## Verification

Independent ASL points prove:

1. FP16 and FP32 two-dimensional load/store add encoded byte pitches exactly
   once;
2. packed four-bit rows restart nibble selection at each byte-strided row base;
3. omitted `B.IOR` derives the dense byte width while encoded zero remains zero;
4. four selected PEs resolve distinct private base and byte-stride GPR values;
5. Local, Shared full, and Shared partial paths retain complete preflight and
   no-partial-effect behavior; and
6. catalog roles, generated instruction documentation, NDF traceability, and
   release closure contain no stale TLOAD/TSTORE element-stride claim.
