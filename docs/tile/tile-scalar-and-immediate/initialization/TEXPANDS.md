<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/initialization/TEXPANDS.asl -->
# TEXPANDS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/initialization/TEXPANDS.asl`

Broadcast one private-GPR scalar encoding across a newly allocated Local Tile.

## Normative identity {#PTO-INST-TILE-TEXPANDS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-texpands-purpose role=purpose -->
## What TEXPANDS does

`TEXPANDS` fills the valid rectangle of a newly allocated Local Tile with one scalar. It has no Tile source. It is selected by TEPL Mode 1 Function 27 (selector `0x03B`), executes on `VEC` as `BSTART.VEC TEXPANDS, DataType`, and has no standalone opcode.

Design point: `TEXPANDS` is the bridge from a scalar to a Tile. Tile-scalar operations such as `TSUBS` fix the Tile as the left operand. When a program needs the scalar on the left, or needs a constant Tile for a Tile-Tile operation, `TEXPANDS` builds that Tile once.

<!-- PTO-READER-BLOCK: tile-texpands-mechanism role=mechanism -->
## Scalar source and fill mechanism

The scalar comes from `B.IOR.RegSrc0`. Each participating PE resolves that selector in its own private GPR file, so each PE can fill its fragment with a different value. The bundle has no immediate field for the scalar.

`ExecuteTileFillScalar` narrows the 64-bit GPR value with `TileRawElementValue`, keeping only the low 8, 16, 32, or 64 bits that match the element width of the selected `DataType`. It writes that bit pattern to every coordinate in `ValidRow x ValidCol`.

Design point: the fill is a raw copy, not a conversion. There is no rounding, saturation, canonicalization, or numeric-status update, so a floating scalar must already be encoded in the selected type. This keeps the result independent of any numeric profile.

<!-- PTO-READER-BLOCK: tile-texpands-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `scalar0` is the per-PE scalar from `B.IOR.RegSrc0`. An explicit `B.IOR` must keep `RegSrc1`, `RegSrc2`, and `RegDst` zero.
- `destination0` is a newly allocated Local numeric Tile whose `DataType` is the selected `DataType`.

One terminating `B.IOT` binds only the destination and its `PE_MASK`. `B.IOS` and additional Tile bindings are illegal.

Design point: because there is no source Tile, there is no source definedness to check. `TEXPANDS` turns a register value into a Tile whose valid region is fully defined.

Design point: `PE_MASK=0000` is a strict no-op. It exits before any GPR read, descriptor read, allocation, fault, or status effect, so a bundle with no participating PE never reads a scalar register.

<!-- PTO-READER-BLOCK: tile-texpands-effects role=effects -->
## Publication, definedness, and padding

The destination payload, padding definedness, and descriptor are published as one unit. A rejected bundle has no architectural effect, and `TEXPANDS` has no global-memory effect.

Physical elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero`, `Max`, and `Min` define them; `Null`, the default when `B.DATR` is omitted, leaves them undefined.

Omitting `B.IOR` fills the valid region with the all-zero encoding of the selected type, which is `+0.0` for floating types. An explicit all-zero `B.IOR` is a distinct encoding that supplies the same value.

When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value instead of the scalar.

<!-- PTO-READER-BLOCK: tile-texpands-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted data-type set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`. Packed four-bit formats are excluded.

The layout is `RowMajor` by default. An explicit `B.DATR` `Layout` may select `CUBE_M16`, which allows at most 16 valid rows, or `CUBE_M32`, which allows at most 32. `Layout` and `PadValueOrByteId` are the only applicable `B.DATR` fields.

A malformed destination binding, `B.IOS`, a surplus `B.IOR` field, an unsupported `DataType`, a missing or zero dimension, or a capacity or allocation failure raises `Fault_TileLegality` or `Fault_TileAllocation` before any effect.

<!-- PTO-READER-BLOCK: tile-texpands-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

To fill an `FP32` Tile with 1.0, place the `FP32` encoding `0x3F800000` in `a2` and write `TEXPANDS <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, a2, ->T<2KB>`. The 7 x 60 = 420 valid elements hold `0x3F800000`, and the other 92 physical elements are defined as zero.

If `a2` instead holds the `FP64` encoding of 1.0, `0x3FF0000000000000`, its low 32 bits are zero and every valid element becomes `+0.0`, because no conversion is performed.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TEXPANDS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TEXPANDS | TEPL | 0x03B | 27 | 1 | ExecuteTileFillScalar |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

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
| destination0 | new Local numeric destination |
| scalar0 | per-participating-PE private-GPR scalar |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/initialization/TEXPANDS.asl -->
```asl
readonly func InstructionContractOperation_TEXPANDS() => TileOperation
begin
    return TileOperation_TEXPANDS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TEXPANDS, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR ScalarGPR, zero, zero, ->zero (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/initialization/TEXPANDS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TEXPANDS(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TEXPANDS(
    destination: TileIndex,
    scalar: Word) => boolean
begin
    return TileOperandsLegal_ExecuteTileFillScalar(
        destination,
        scalar);
end;

readonly func InstructionContractHandler_TEXPANDS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileFillScalar;
end;

func InstructionContractExecute_TEXPANDS(
    destination: TileIndex,
    scalar: Word)
begin
    assert InstructionContractOperandsLegal_TEXPANDS(
        destination,
        scalar);
    ExecuteTileFillScalar(
        destination,
        scalar);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol.
- Omitted B.IOR supplies the selected DataType all-zero encoding; explicit all-zero is distinct but supplies the same value.
- Omitted B.DATR selects PadValue=Null. Explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.

## Legality

- TEXPANDS is selected only by the TEPL raw carrier Mode 1 Function 27 and executes on VEC.
- Exactly one terminating Local B.IOT supplies no source and one newly allocated Local numeric destination. B.IOS and additional Tile bindings are illegal.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8; every other type rejects before effects.
- The destination uses selected RowMajor, CUBE_M16, or CUBE_M32 layout; CUBE_M16 valid_rows is at most 16 and CUBE_M32 valid_rows is at most 32, with physical geometry derived from the selected layout and capacity.
- Only RegSrc0 may be nonzero in B.IOR; Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields.
- PE_MASK=0000 is a strict no-op before GPR reads, allocation, faults, or destination effects.

## State effects

- Every valid destination element receives the scalar low element-width raw encoding without conversion.
- Padding definedness and destination descriptor publish atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, dimensions, attributes, type, scalar encoding, mask, capacity, and allocation preflight precedes the private-GPR scalar snapshot.

## Exceptions

- Malformed destination binding, B.IOS presence, surplus B.IOR fields, unsupported DataType, missing or zero dimensions, capacity failure, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation.

## Examples

- BSTART.VEC TEXPANDS, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP
