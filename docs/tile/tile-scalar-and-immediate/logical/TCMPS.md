<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl -->
# TCMPS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl`

Compare each valid Local Tile element with a scalar and produce one legacy Predicate, CUBE PredicateCell, or GPR carrier.

## Normative identity {#PTO-INST-TILE-TCMPS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcmps-purpose role=purpose -->
## What TCMPS does

`TCMPS` compares every element in the valid rectangle of a Local source Tile with one scalar and produces one predicate per element. It is selected by TEPL Mode 1 Function 13 (selector `0x02D`), written canonically as `BSTART.VEC TCMPS, DataType`, and has no standalone opcode.

Design point: the scalar is a bundle operand, not a Tile. The Tile-Tile form `TCMP` needs a second source Tile of the same shape, so comparing against one threshold that way first requires a Tile filled with it. `TCMPS` reads the threshold directly from a GPR, so no broadcast Tile has to be allocated or made defined.

<!-- PTO-READER-BLOCK: tile-tcmps-mechanism role=mechanism -->
## Scalar source and comparison mechanism

The scalar comes from `B.IOR.RegSrc0`. Each participating PE resolves that selector in its own private GPR file. The bundle has no immediate field for the scalar; when `B.IOR` is omitted the scalar is the all-zero encoding of the selected `DataType`.

The 64-bit GPR value is narrowed by `TileRawElementValue`: only the low 8, 16, 32, or 64 bits, matching the element width of the selected `DataType`, are kept. No numeric conversion happens, so a floating scalar must already be in the encoding of the selected type.

`B.DATR.CMode` selects the comparison: codes 0, 1, 2, 3, 4, and 5 select EQ, NE, LT, GT, LE, and GE. Codes 6 and 7 are reserved and rejected. Omitting `B.DATR` selects EQ.

The Tile element is always the left operand, so LT is true when `source < scalar`. Signed and unsigned integers compare as signed and unsigned values. For floating types, any NaN makes only NE true, a signaling NaN raises the invalid status, and `+0.0` equals `-0.0`.

Design point: the selected `DataType` is the operation type. It governs scalar narrowing, the comparison, and the predicate geometry, while the source keeps its own backing type. A same-width, non-packed source can therefore be compared under a different interpretation without a copy.

<!-- PTO-READER-BLOCK: tile-tcmps-inputs role=inputs-outputs -->
## Operand roles and result carriers

- `source0` is an existing Local numeric Tile. It persists unchanged.
- `scalar0` is the per-PE scalar, the right operand of every comparison.
- `comparison` is the six-mode `CMode` value.
- `destination0` is a new predicate destination, or is absent when the result goes to a GPR.

The source layout selects one of three mutually exclusive result forms:

- RowMajor source: a new legacy packed predicate Tile. Logical element `i = row x Col + column` is bit `i mod 8` of byte `floor(i / 8)`, so the Tile needs at least `ceil(Row x Col / 8)` bytes.
- `CUBE_M16` or `CUBE_M32` source with a `B.IOT` destination: a new `U8` PredicateCell Tile, one byte per element, whose basis is the operation `DataType`.
- `CUBE_M16` or `CUBE_M32` source without a `B.IOT` destination: one GPR named by `B.IOR.RegDst`. For an 8-bit type, `Sat` selects the Low or High column half.

Design point: `PE_MASK=0000` is a strict no-op. It exits before any GPR read, descriptor read, allocation, fault, or status effect, so a bundle with no participating PE never reads a scalar register.

<!-- PTO-READER-BLOCK: tile-tcmps-effects role=effects -->
## Publication, definedness, and padding

The selected carrier is published as one unit: the predicate payload, its padding, any numeric status, and the destination descriptor or GPR value become visible together. A rejected bundle has no architectural effect.

Predicate positions outside `ValidRow x ValidCol` follow `PadValue`: `Zero` and `Min` write zero bits, `Max` writes one bits, and `Null`, the default, leaves them undefined.

Design point: omitting `B.IOR` compares against zero of the selected type. For signed integer and floating types, `CMode` LT without a scalar is therefore a sign test; `-0.0` compares equal to zero, and a NaN element yields zero for both LT and GE. For unsigned types LT always yields zero and GE always yields one.

`TCMPS` has no global-memory effect. With an ExecutionMask on a CUBE form, inactive coordinates keep their old predicate (merge) or receive zero, and contribute no numeric status.

<!-- PTO-READER-BLOCK: tile-tcmps-constraints role=constraints -->
## Type, layout, and fault boundary

The operation `DataType` set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`. The PredicateCell form excludes `FP64`, `S64`, and `U64`, and the GPR form is further limited by the GPR predicate geometry.

`B.DATR` accepts `CMode`, `PadValueOrByteId`, and `Sat`; `Sat` is legal only in the 8-bit GPR form, and `Canonicalize` must stay zero. There is no `Layout` field: the layout comes from the source descriptor.

A malformed or mixed carrier schema, a missing dimension, a reserved `CMode`, an unsupported `DataType`, an undefined source element, a source or scalar encoding invalid for the operation type, insufficient predicate capacity, or an allocation failure rejects the bundle before any effect.

<!-- PTO-READER-BLOCK: tile-tcmps-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For an `S32` example with `CMode` GT, a source row `[1, 3]` and scalar `2` produce predicates `[0, 1]`.

For a RowMajor `FP32` source with 8 x 64 = 512 elements, `TCMPS <Row=8, Col=64, FP32, GT>, T#1, a2, ->U<128B>` writes 512 predicate bits, which fill 64 bytes. Element row 1, column 3 has logical index 67 and lands in byte 8, bit 3.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TCMPS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCMPS | TEPL | 0x02D | 13 | 1 | ExecuteTileCompareScalar |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.DATR.CMode (`PTO-FIELD-BLOCK-CMODE`)

Selects the comparison relation used by TCMP and TCMPS.

**Encoded zero:** Code zero selects equality comparison.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | EQ |
| 1 | assigned | NE |
| 2 | assigned | LT |
| 3 | assigned | GT |
| 4 | assigned | LE |
| 5 | assigned | GE |
| 6 | reserved | future extension |
| 7 | reserved | future extension |

**Reserved-value behavior:** Codes 6 and 7 are reserved and reject before architectural effects.

### B.DATR.PadValueOrByteId (`PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID`)

Carries the operation-selected PadValue or ByteId union field.

**Encoded zero:** For PadValue operations code zero selects Zero; for ByteId operations it selects ByteId zero.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | Zero-or-ByteId0 |
| 1 | assigned | Max-or-ByteId1 |
| 2 | assigned | Min-or-ByteId2 |
| 3 | assigned | Null-or-ByteId3 |

**Reserved-value behavior:** All four encodings are assigned; the selected operation separately validates whether the field is PadValue, ByteId, or inapplicable.

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
| destination0 | legacy packed Predicate or CUBE PredicateCell destination; absent for GPR producer |
| source0 | persistent Local numeric source |
| scalar0 | per-participating-PE compare scalar |
| comparison | six-mode comparison |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl -->
```asl
readonly func InstructionContractOperation_TCMPS() => TileOperation
begin
    return TileOperation_TCMPS;
end;

pure func InstructionContractComparisonCodeLegal_TCMPS(
    comparison_code: bits(3)) => boolean
begin
    return UInt(comparison_code) <= 5;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TCMPS, DataType
B.DATR CMode, PadValue, SatMode (U8 GPR form only)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->PredicateCell<TSize> OR no destination
B.IOR scalar-compare source and optional predicate-GPR destination
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCMPS(
    data_type: TileDataType) => boolean
begin
    return TileCompareDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCMPS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word,
    comparison: TileComparison) => boolean
begin
    return TileOperandsLegal_ExecuteTileCompareScalar(
        destination,
        source,
        scalar,
        comparison);
end;

readonly func InstructionContractHandler_TCMPS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileCompareScalar;
end;

func InstructionContractExecute_TCMPS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word,
    comparison: TileComparison)
begin
    assert InstructionContractOperandsLegal_TCMPS(
        destination,
        source,
        scalar,
        comparison);
    ExecuteTileCompareScalar(
        destination,
        source,
        scalar,
        comparison);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- CMode codes 0, 1, 2, 3, 4, and 5 select EQ, NE, LT, GT, LE, and GE; codes 6 and 7 are reserved. Omitted B.DATR selects EQ.
- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.
- Omitted B.IOR supplies the selected operation DataType all-zero scalar encoding. Omitted PadValue selects Null predicate padding.

## Legality

- TCMPS selects TEPL Mode 1 Function 13 and executes on VEC. PE_MASK=0000 is a strict no-op before GPR, source, allocation, status, or payload checks.
- Legacy RowMajor form uses one terminating B.IOT with source and new packed Predicate destination; one optional B.IOR supplies the compare scalar, and the source backing DataType is checked independently; exact backing/operation type identity is legal, while a cross-type source/backing pair requires equal width and a non-four-bit carrier.
- CUBE_M16/M32 PredicateCell form uses one terminating B.IOT with source and new U8 PredicateCell destination whose basis is the operation DataType plus an optional scalar-source B.IOR; omission selects the operation-type zero. The source backing DataType is checked independently; exact backing/operation type identity is legal, while a cross-type source/backing pair requires equal width and a non-four-bit carrier, and the operation type is exactly one of FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S32, S16, S8, U32, U16, or U8.
- CUBE_M16/M32 GPR form uses one source-only B.IOT and one B.IOR carrying the scalar source plus one destination GPR. The operation type is a 32-bit or 16-bit type from the closed CUBE domain, plus U8; the source backing DataType is checked independently; exact backing/operation type identity is legal, while a cross-type source/backing pair requires equal width and a non-four-bit carrier and U8 Sat selects Low or High columns derived from the operation type.
- Legacy, PredicateCell, and GPR forms are complete and mutually exclusive. CMode and PadValue apply to all; Sat is nonzero only for U8 GPR selection; Canonicalize remains zero.

## State effects

- Each valid comparison publishes through the selected carrier under the operation type: legacy low-first packed bit, canonical PredicateCell byte, or GPR predicate bit.
- Zero and Min padding write zero predicate bits, Max writes one bits, and Null leaves padding undefined.
- Selected carrier payload, padding, numeric status, and descriptor or GPR result publish atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, dimensions, attributes, type, source, scalar, predicate capacity, mask, and allocation preflight precedes source and scalar snapshots.
- The source payload and scalar are snapshotted before packed destination publication.

## Exceptions

- Malformed or mixed carrier schemas, missing dimensions, reserved CMode, unsupported DataType, undefined or operation-type-invalid source/scalar data, insufficient PredicateCell capacity, or allocation failure rejects before effects.
- Signaling floating NaN status publishes atomically with the selected GPR or PredicateCell result.

## Examples

- BSTART.VEC TCMPS, DataType; B.DATR CMode, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->Predicate<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP
