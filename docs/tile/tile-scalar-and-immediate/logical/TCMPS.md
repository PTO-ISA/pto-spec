<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl -->
# TCMPS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl`

Compare each valid Local Tile element with one private-GPR scalar and produce a packed predicate Tile.

## Normative identity {#PTO-INST-TILE-TCMPS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

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
| destination0 | new packed Local predicate destination |
| source0 | persistent Local numeric source |
| scalar0 | per-participating-PE private-GPR scalar |
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
B.DATR CMode, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->Predicate<TSize>
B.IOR ScalarGPR, zero, zero, ->zero (optional)
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
- Omitted B.IOR supplies the selected source DataType all-zero scalar encoding. Omitted PadValue selects Null predicate padding.

## Legality

- TCMPS is selected only by the TEPL raw carrier Mode 1 Function 13 and executes on VEC.
- Exactly one terminating Local B.IOT supplies one persistent numeric source and one new packed predicate destination. B.IOS and additional Tile bindings are illegal.
- The source DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8; every other type rejects before effects.
- The source is row-major and completely defined. The predicate destination has matching logical geometry and capacity of at least ceil(Row*Col/8) bytes.
- Only CMode and PadValueOrByteId are applicable in B.DATR. When B.IOR is present, only RegSrc0 may be nonzero.
- PE_MASK=0000 is a strict no-op before GPR, source, allocation, status, or payload checks.

## State effects

- Logical element i publishes its comparison result in bit i mod 8 of byte floor(i/8), with low logical indices in low bits.
- Zero and Min padding write zero predicate bits, Max writes one bits, and Null leaves padding undefined.
- Packed payload, padding definedness, numeric status, and destination descriptor publish atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, dimensions, attributes, type, source, scalar, predicate capacity, mask, and allocation preflight precedes source and scalar snapshots.
- The source payload and scalar are snapshotted before packed destination publication.

## Exceptions

- Malformed bindings, B.IOS presence, surplus B.IOR fields, reserved CMode, unsupported DataType, undefined or invalid source encoding, predicate capacity failure, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.
- Signaling floating NaN records invalid only with the atomically published predicate destination.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation.

## Examples

- BSTART.VEC TCMPS, DataType; B.DATR CMode, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->Predicate<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
