<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl -->
# TSQRT

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl`

Compute the same-type square root of every valid Local Tile element.

## Normative identity {#PTO-INST-TILE-TSQRT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tsqrt-purpose role=purpose -->
## What TSQRT does

`TSQRT` computes a same-type square root for every valid element and publishes a new Local destination.

<!-- PTO-READER-BLOCK: tile-c-tsqrt-mechanism role=mechanism -->
## Operation mechanism

The operation evaluates only the valid rectangle using the mnemonic-selected typed element rule.

Floating results and element status follow the active named numeric profile; the portable contract owns selection, shape, publication, and fault order.

<!-- PTO-READER-BLOCK: tile-c-tsqrt-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `destination0` identifies a newly allocated destination.

- `source0` supplies a persistent source Tile.

- The closed applicable DataType set is `FP16`, `FP32`, `BF16`.

- Data Tiles use row-major layout unless this mnemonic explicitly selects another permitted layout.

- `LB0`, `LB1`, and `LB2` complete the valid and physical shape according to this mnemonic’s contract; every required valid extent is nonzero.

<!-- PTO-READER-BLOCK: tile-c-tsqrt-effects role=effects -->
## Definedness, padding, and publication

All source descriptors and payloads are validated and snapshotted before destination publication.

The complete destination payload, descriptor, definedness, padding state, and applicable numeric status publish atomically; rejection publishes none.

Null padding leaves physical coordinates outside the valid rectangle undefined; an explicit non-Null PadValue defines those coordinates with the selected typed value.

Source Tiles persist and are not modified by successful execution.

<!-- PTO-READER-BLOCK: tile-c-tsqrt-constraints role=constraints -->
## Legality, fault, and order boundaries

Complete binding schema, dimensions, DataType, layout, source definedness, numeric encoding, destination capacity, and allocation are preflighted before effects.

A failed legality or allocation check raises the applicable Tile fault without partial destination, status, or memory effects.

`PE_MASK=0000` is a strict no-op before operand reads, allocation, faults, numeric status, or payload effects.

<!-- PTO-READER-BLOCK: tile-c-tsqrt-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

`TSQRT <bundle operands>` performs complete preflight and source snapshotting before atomically publishing the mnemonic-defined result and padding state.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TSQRT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSQRT | TEPL | 0x015 | 21 | 0 | ExecuteTileUnary |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl -->
```asl
readonly func InstructionContractOperation_TSQRT() => TileOperation
begin
    return TileOperation_TSQRT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TSQRT, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSQRT(
    data_type: TileDataType) => boolean
begin
    return TileUnaryDataTypeSupported(
        TileUnary_SQRT,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TSQRT(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_SQRT,
        destination,
        source);
end;

readonly func InstructionContractHandler_TSQRT() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TSQRT(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TSQRT(
        destination,
        source);
    ExecuteTileUnary(
        TileUnary_SQRT,
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

- TSQRT retains its TEPL raw Mode 0 carrier and executes canonically on the SFU engine.
- Exactly one terminating Local B.IOT supplies one persistent source and one newly allocated destination. B.IOR and B.IOS are illegal.
- The selected DataType is exactly FP16, FP32, or BF16; every integer, exponent-only, other compact, packed, assigned-but-inapplicable, or reserved DataType rejects before effects.
- PadValueOrByteId is the only applicable B.DATR field; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, numeric status, or payload effects.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- For each valid element compute the selected profile's same-type square root.
- Accumulate all element status flags, apply selected physical padding, and publish payload, definedness, numeric status, and destination descriptor atomically; rejection leaves architectural state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, and allocation preflight precedes the source snapshot and profile evaluation.
- The complete source payload is snapshotted before destination publication, so source/destination aliasing observes the old source value.

## Exceptions

- Malformed Local bindings, B.IOR or B.IOS presence, missing or zero dimensions, unsupported DataType, undefined or invalid source encoding, descriptor mismatch, invalid capacity, or allocation failure raises the applicable Tile fault before effects.
- Square root preserves signed zero and positive infinity; a negative nonzero value reports invalid and produces quiet NaN; signaling NaN also records invalid.

## Examples

- BSTART.SFU TSQRT, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
