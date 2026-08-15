<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TLOG.asl -->
# TLOG

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TLOG.asl`

Compute the same-type natural logarithm of every valid Local Tile element.

## Normative identity {#PTO-INST-TILE-TLOG}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TLOG <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TLOG | TEPL | 0x013 | 19 | 0 | ExecuteTileUnary |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TLOG.asl -->
```asl
readonly func InstructionContractOperation_TLOG() => TileOperation
begin
    return TileOperation_TLOG;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TLOG, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TLOG.asl -->
```asl
pure func InstructionContractDataTypeLegal_TLOG(
    data_type: TileDataType) => boolean
begin
    return TileUnaryDataTypeSupported(
        TileUnary_LOG,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TLOG(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_LOG,
        destination,
        source);
end;

readonly func InstructionContractHandler_TLOG() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TLOG(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TLOG(
        destination,
        source);
    ExecuteTileUnary(
        TileUnary_LOG,
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

- TLOG retains its TEPL raw Mode 0 carrier and executes canonically on the SFU engine.
- Exactly one terminating Local B.IOT supplies one persistent source and one newly allocated destination. B.IOR and B.IOS are illegal.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, or E5M2; every integer, exponent-only, other compact, packed, assigned-but-inapplicable, or reserved DataType rejects before effects.
- Source and destination match physical shape, valid shape, row-major layout, and DataType. Every valid source element is defined and has a valid encoding.
- PadValueOrByteId is the only applicable B.DATR field; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, numeric status, or payload effects.

## State effects

- For each valid element compute the selected profile's same-type natural logarithm.
- Accumulate all element status flags, apply selected physical padding, and publish payload, definedness, numeric status, and destination descriptor atomically; rejection leaves architectural state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, and allocation preflight precedes the source snapshot and profile evaluation.
- The complete source payload is snapshotted before destination publication, so source/destination aliasing observes the old source value.

## Exceptions

- Malformed Local bindings, B.IOR or B.IOS presence, missing or zero dimensions, unsupported DataType, undefined or invalid source encoding, descriptor mismatch, invalid capacity, or allocation failure raises the applicable Tile fault before effects.
- log(positive one) is positive zero; zero reports divide-by-zero and produces negative infinity where representable; negative nonzero values report invalid and produce quiet NaN; signaling NaN also records invalid.
- E4M3 has no infinity encoding and TLOG does not admit saturation, so zero produces canonical E4M3 quiet NaN 0x7F and records only divide-by-zero without overflow.

## Examples

- BSTART.SFU TLOG, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
