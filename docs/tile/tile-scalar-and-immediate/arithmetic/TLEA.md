<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl -->
# TLEA

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl`

Extend logical element indices to 64 bits and explicitly scale them to byte offsets.

## Normative identity {#PTO-INST-TILE-TLEA}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tlea-purpose role=purpose -->
## What TLEA does

`TLEA` turns a Local Tile of logical element indices into a new Local Tile of byte offsets. It is selected by TEPL Mode 1 Function 14 (selector `0x02E`), with the canonical header `BSTART.VEC TLEA, SrcDataType`, and has no standalone opcode.

Design point: the result is an offset Tile, not an address Tile. `TLEA` does not read a base register or access memory. A later indexed memory operation such as [`MGATHER`](../../memory-and-data-movement/irregular/MGATHER.md) combines its own base address with byte displacements.

<!-- PTO-READER-BLOCK: tile-tlea-mechanism role=mechanism -->
## Extension before byte scaling

Each participating PE reads `element_bits` from its private GPR selected by `B.IOR.RegSrc0`. The only accepted values are 8, 16, 32, and 64, so the scale factor in bytes is respectively 1, 2, 4, or 8. The GPR value describes the indexed element width; it is not added to the result.

For every active coordinate, a signed `S32` or `S64` index is first sign-extended to `S64`, while an unsigned `U32` or `U64` index is first zero-extended to `U64`. The extended 64-bit value is then multiplied by `element_bits / 8`, and the low 64 result bits are retained. The destination type follows the source signedness: signed inputs produce `S64`, and unsigned inputs produce `U64`.

Design point: extension precedes scaling so a negative `S32` index remains a negative 64-bit displacement. For example, `S32(-1)` at 32 bits per element becomes the 64-bit bit pattern `0xFFFFFFFFFFFFFFFF` before multiplication by 4, producing `0xFFFFFFFFFFFFFFFC`. This is fixed-width bit-vector multiplication modulo 2^64; it does not depend on C or C++ signed-overflow behavior.

By contrast, a `U32` row `[0, 1, 2]` with `element_bits=32` produces byte offsets `[0, 4, 8]`. Passing those values to an indexed operation keeps the unit boundary clear: `TLEA` performs logical-index-to-byte conversion, while `MGATHER` owns base-address addition and memory access.

<!-- PTO-READER-BLOCK: tile-tlea-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the persistent Local index Tile with backing type exactly `S32`, `U32`, `S64`, or `U64`.
- `scalar0` is the required per-PE element width from `B.IOR.RegSrc0`. `RegSrc1`, `RegSrc2`, and `RegDst` remain zero apart from the existing ExecutionMask binding extension.
- `destination0` is a newly allocated Local byte-offset Tile with corresponding `S64` or `U64` elements.

One terminating `B.IOT` binds the source and renamed destination. Source and destination have the same logical `ValidRow x ValidCol` shape and the same layout, but their physical descriptors are checked independently. This matters when 32-bit indices expand into 64-bit offsets and when a legal CUBE destination needs different capacity or physical column geometry from its source.

`PE_MASK=0000` is a strict no-op before GPR reads, descriptor reads, allocation, source snapshots, or faults. Otherwise, all legality and allocation checks finish before the source is snapshotted, so direct `S64` or `U64` source-destination aliasing reads the old payload.

<!-- PTO-READER-BLOCK: tile-tlea-effects role=effects -->
## Publication, masks, and padding

After preflight and the source snapshot, the destination descriptor, active-coordinate results, padding, and definedness become visible together. The source persists unchanged, no numeric status is updated, and rejection leaves no destination effect.

For `CUBE_M32`, inactive ExecutionMask coordinates follow the existing ZERO or MERGE rule and do not read the corresponding source element. One mask bit governs the complete 64-bit logical result, including both physical CELL planes. MERGE obtains its value through the operation's established destination-mask source; ZERO supplies the destination type's zero encoding.

Physical elements outside the logical valid rectangle receive the selected `PadValue`. Omitting `B.DATR` selects `Null` and `RowMajor`; the only explicit CUBE layout is `CUBE_M32`. Padding is separate from ExecutionMask handling inside the valid rectangle.

<!-- PTO-READER-BLOCK: tile-tlea-constraints role=constraints -->
## Type, layout, and fault boundary

The source operation type and backing type must match exactly and be one of `S32`, `U32`, `S64`, or `U64`. Packed four-bit types, floating types, narrower integers, Shared Tiles, and `CUBE_N8` are excluded. The scalar element width must be exactly 8, 16, 32, or 64 bits; zero and every other GPR value reject for an active block.

`RowMajor` and `CUBE_M32` use the same logical shape while allowing independent legal source and destination physical descriptors. Every TLEA destination is 64-bit, so its CUBE_M32 descriptor uses two complete CELLs per logical column; a 32-bit CUBE_M32 source may use one. `CUBE_M16` is therefore illegal even when the source index type is 32-bit.

The low-64-bit product never raises an overflow fault. `TLEA` also introduces no memory-access fault because it emits byte offsets only; any later base-address arithmetic, address validation, or memory event belongs to the consuming memory instruction.

<!-- PTO-READER-BLOCK: tile-tlea-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a `U32` source row `[0, 1, 2]` and `element_bits=32`, zero-extension yields the same three 64-bit values and multiplication by 4 yields a `U64` row `[0, 4, 8]`. If an `MGATHER` later uses base address `0x1000`, its memory addresses are `0x1000`, `0x1004`, and `0x1008`; that base addition is performed by `MGATHER`, not by `TLEA`.

For an `S32` source row `[-1, 0, 1]` with the same element width, sign-extension followed by modulo-2^64 multiplication yields the `S64` bit patterns `[0xFFFFFFFFFFFFFFFC, 0x0000000000000000, 0x0000000000000004]`. The first result represents a byte displacement of -4 without invoking host-language signed overflow.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TLEA <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TLEA | TEPL | 0x02E | 14 | 1 | TLEA |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.IOR.RegSrc0 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local S64/U64 byte-offset destination |
| source0 | persistent Local S32/U32/S64/U64 element indices |
| scalar0 | per-PE element width in bits |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl -->
```asl
readonly func InstructionContractOperation_TLEA() => TileOperation
begin
    return TileOperation_TLEA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TLEA, SrcDataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=DstCol (optional)
B.IOT IndexTile, mask=PE_MASK, <last>, ->ByteOffsetTile<TSize>
B.IOR ElementBitsGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl -->
```asl
pure func InstructionContractDataTypeLegal_TLEA(data_type: TileDataType)
    => boolean
begin
    return TileLEAIndexDataTypeLegal(data_type);
end;

readonly func InstructionContractHandler_TLEA() => TileSemanticHandler
begin
    return TileHandler_TLEA;
end;

func InstructionContractExecute_TLEA(
    destination: TileIndex, source: TileIndex, element_bits: Word)
begin
    assert TileOperandsLegal_TLEA(destination, source, element_bits);
    TLEA(destination, source, element_bits);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies ValidCol; omitted LB1 selects one and omitted LB2 selects destination physical Col equal to ValidCol.
- B.IOR is required and RegSrc0 supplies element width in bits; there is no implicit width or base address.
- Omitted B.DATR selects PadValue=Null and RowMajor; Layout 29/31 select CUBE_M32/CUBE_M16.

## Legality

- TEPL Mode 1 Function 14 (selector 0x02E) accepts exactly S32, U32, S64 and U64 source operation/backing types.
- The scalar element width is exactly 8, 16, 32 or 64 bits; packed four-bit widths reject.
- One terminating Local B.IOT supplies one index source and a renamed destination; B.IOR is required and unused selectors/destination encode zero, subject to explicit ExecutionMask binding extensions.
- Source and destination have matching logical valid shape and RowMajor/CUBE_M32 layout, with independent physical capacity and geometry; Shared and CUBE_N8 reject.
- B.DATR accepts padding/layout and existing applicable ExecutionMask controls; numeric conversion controls are not applicable.
- PE_MASK=0000 is a strict no-op before reads, allocation and faults.
- Local CUBE_M32 S64/U64 output uses the issue #371 double-CELL mapping; RowMajor is also legal and CUBE_M16 b64 output is not assigned.

## State effects

- Signed inputs sign-extend to S64 and unsigned inputs zero-extend to U64 before multiplication by element_bits/8; retain the low 64 bits.
- TLEA generates byte offsets only, without BaseGPR addition, memory events or numeric-status updates.
- Inactive Local CUBE ExecutionMask coordinates follow existing MERGE/ZERO without source reads; direct S64/U64 aliasing reads old source payloads.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete legality/allocation preflight and source snapshots precede atomic destination publication.

## Exceptions

- Unsupported index types, element widths, layout, descriptor, schema or logical-shape mismatch rejects before effects; insufficient destination capacity follows Fault_TileAllocation.
- No overflow, memory-access or numeric-status fault is introduced.

## Examples

- BSTART.VEC TLEA, S32; B.DIM LB0=ValidCol; B.IOT IndexTile, mask=PE_MASK, <last>, ->ByteOffsetTile<TSize>; B.IOR ElementBitsGPR, zero, zero, ->zero; BSTOP
