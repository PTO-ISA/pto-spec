<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TRECIP.asl -->
# TRECIP

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TRECIP.asl`

Compute the same-type reciprocal of every valid Local Tile element.

## Normative identity {#PTO-INST-TILE-TRECIP}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TRECIP <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TRECIP | TEPL | 0x014 | 20 | 0 | ExecuteTileUnary |

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

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local floating destination |
| source0 | persistent Local floating source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TRECIP.asl -->
```asl
readonly func InstructionContractOperation_TRECIP() => TileOperation
begin
    return TileOperation_TRECIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TRECIP, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TRECIP.asl -->
```asl
pure func InstructionContractDataTypeLegal_TRECIP(
    data_type: TileDataType) => boolean
begin
    return TileUnaryDataTypeSupported(
        TileUnary_RECIP,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TRECIP(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_RECIP,
        destination,
        source);
end;

readonly func InstructionContractHandler_TRECIP() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TRECIP(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TRECIP(
        destination,
        source);
    ExecuteTileUnary(
        TileUnary_RECIP,
        destination,
        source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- The selected numeric profile supplies the operation-fixed approximation, rounding, exceptional result, and exact NV/DZ/OF/UF/NX status vector.

## Legality

- TRECIP retains its TEPL raw Mode 0 carrier and executes canonically on the SFU engine.
- Exactly one terminating Local B.IOT supplies one persistent source and one newly allocated destination. B.IOR and B.IOS are illegal.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, or E5M2; every integer, exponent-only, other compact, packed, assigned-but-inapplicable, or reserved DataType rejects before effects.
- Source and destination match physical shape, valid shape, row-major layout, and DataType. Every valid source element is defined and has a valid encoding.
- PadValueOrByteId is the only applicable B.DATR field; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, numeric status, or payload effects.

## State effects

- For each valid element compute the selected profile's same-type reciprocal.
- Accumulate all element status flags, apply selected physical padding, and publish payload, definedness, numeric status, and destination descriptor atomically; rejection leaves architectural state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, and allocation preflight precedes the source snapshot and profile evaluation.
- The complete source payload is snapshotted before destination publication, so source/destination aliasing observes the old source value.

## Exceptions

- Malformed Local bindings, B.IOR or B.IOS presence, missing or zero dimensions, unsupported DataType, undefined or invalid source encoding, descriptor mismatch, invalid capacity, or allocation failure raises the applicable Tile fault before effects.
- Floating zero is legal, reports divide-by-zero, and produces signed infinity where representable; signed infinity produces signed zero; signaling NaN records invalid and every NaN produces a quiet-NaN result.
- E4M3 has no infinity encoding and TRECIP does not admit saturation, so either signed zero produces canonical E4M3 quiet NaN 0x7F and records only divide-by-zero without overflow.

## Examples

- BSTART.SFU TRECIP, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
