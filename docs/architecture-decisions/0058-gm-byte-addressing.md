# ADR 0058: GM byte addressing for regular and indexed TLSU

- **Status**: accepted
- **Date**: 2026-08-20
- **Deciders**: PTO ISA maintainers
- **Decision source**: [pto-spec issue 115](https://github.com/PTO-ISA/pto-spec/issues/115)
- **Requirements**: `PTO-REQ-TLSU-001`, `PTO-REQ-MEMORY-COMPLETION-001`,
  `PTO-REQ-MEMORY-TSO-001`, `PTO-REQ-BUNDLE-DISPATCH-001`

## Context

The earlier PTO v0 contract described `B.IOR.RegSrc1` for `TLOAD` and
`TSTORE` as a logical-element row stride. That interpretation multiplied the
encoded value by the transfer element width during address formation. The
compiler and current execution evidence instead use the encoded value as the
byte distance between adjacent GM row starts. The mismatch is silent for
eight-bit elements and changes addresses for wider types.

The same branch also retained an older indexed TLSU implementation that scaled
`MGATHER` and `MSCATTER` indices by the transfer element width and used an
index bit as a packed-nibble selector. The current PTO contract uses signed or
unsigned byte displacements for indexed TLSU. A pure byte displacement cannot
select one nibble of a packed four-bit transfer, because those operations
encode no independent low/high-nibble selector.

## Decision

### Regular two-dimensional GM transfers

`B.IOR.RegSrc0` supplies the GM base byte address and `B.IOR.RegSrc1`
supplies `row_stride_bytes`, the XLEN byte distance between adjacent row
starts. Every selected PE resolves both absolute selectors in its private GPR
file. The instruction encoding and selector domains do not change.

For row `r` and column `c`:

```text
row_base = base_address + r * row_stride_bytes
```

For byte-sized or wider transfer types:

```text
byte_address = row_base + c * element_size_bytes
```

For packed four-bit transfer types:

```text
byte_address = row_base + floor(c / 2)
nibble       = low when c is even, high when c is odd
```

Every packed row therefore starts at the low nibble of its byte-addressed row
base. For an odd physical column count, the unused high nibble at the end of
each row is preserved by `TSTORE`.

When the complete `B.IOR` instruction is omitted, regular `TLOAD`/`TSTORE`
use base zero and a dense byte stride:

```text
ceil(physical_columns * element_bits / 8)
```

An encoded `RegSrc1=zero`, or any selected GPR whose current value is zero,
is an explicit zero byte stride and does not select the dense default.
`B.DIM.LB2` remains an element-count physical-column field; only its omitted-
`B.IOR` default is converted to bytes.

### Indexed GM transfers

`MGATHER`, `MSCATTER`, `MGATHER_MASK`, `MSCATTER_MASK`, and `MGATHER_CAS`
interpret each IndexTile logical element as a byte displacement. Signed index
types are sign-extended, unsigned index types are zero-extended, and the XLEN
result is added directly to the GM base without transfer-type scaling.

Packed four-bit IndexTile types remain legal: each logical index element still
denotes a byte displacement after signed or unsigned extension. Packed
four-bit *transfer* types are illegal for indexed TLSU because a byte
displacement does not identify a low or high nibble. They reject during tile
legality before memory probes, events, allocation, or payload effects.

### Faults, ordering, and completion

All addresses wrap according to existing XLEN Word arithmetic and then pass
through the existing alignment, translation, and access probes. Byte units do
not waive transfer-type alignment. The complete footprint is preflighted
before effects, preserving precise restart behavior.

Within one regular transfer, the executable model visits rows and columns in
row-major order. Selected-PE accesses retain the existing absence of a
cross-PE order; software must avoid conflicting GM regions. Indexed scatter
duplicate-address ordering retains its existing atomic/non-atomic contract.

## Consequences

- Existing encodings do not change, but binaries that encoded logical-element
  row strides are not semantically compatible with this byte-stride decision.
- Local and Shared `TLOAD`/`TSTORE` use the same byte formula and PE-private
  selector resolution.
- Indexed TLSU no longer multiplies indices by the transfer element size.
- Packed regular transfers remain supported; packed indexed transfers are
  rejected until a future architecture decision adds an explicit sub-byte
  selector.
- Catalog roles, generated instruction text, ASL handlers, executable tests,
  evidence ledgers, and requirement traceability must use byte terminology.

## Supersession

This decision supersedes the element-unit portions of ADR 0033 and the earlier
`B.IOR` row-stride resolution recorded through issues 76 and 89. ADR 0033's
containing-byte layout, low/high nibble order, sibling preservation, memory
events, and precise preflight rules remain in force for regular packed
transfers.

## Verification

`tests/asl/tlsu-totality-tests.asl` covers FP32 two-dimensional load/store with
a 64-byte pitch, U32 indexed byte displacements that would fail under element
scaling, every packed regular transfer type, packed indexed-transfer
rejection, fault preflight, restart, and decoded TLSU selector closure.
`tests/asl/bundle-tests.asl` proves that decoded Shared `B.IOR.RegSrc1` reaches
the byte-stride address calculation for both load and store.
