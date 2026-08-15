<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDEXPDIF.asl -->
# TCOLEXPANDEXPDIF

**Normative ASL source:** `asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDEXPDIF.asl`

Exponentiate the typed difference between a full-shape source and a broadcast one-row vector.

## Normative identity {#PTO-INST-TILE-TCOLEXPANDEXPDIF}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TCOLEXPANDEXPDIF <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLEXPANDEXPDIF | TEPL | 0x05B | 27 | 2 | ExecuteTileExpand |

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
| destination0 | new Local same-type numeric destination |
| source0 | persistent Local full-shape numeric source |
| source1 | persistent Local one-row broadcast source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDEXPDIF.asl -->
```asl
readonly func InstructionContractOperation_TCOLEXPANDEXPDIF() => TileOperation
begin
    return TileOperation_TCOLEXPANDEXPDIF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCOLEXPANDEXPDIF, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDEXPDIF.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCOLEXPANDEXPDIF(
    data_type: TileDataType) => boolean
begin
    return TileUnaryDataTypeSupported(
        TileUnary_EXP,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLEXPANDEXPDIF(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_EXPDIF,
        TileAxis_Column,
        destination,
        source,
        broadcast);
end;

readonly func InstructionContractHandler_TCOLEXPANDEXPDIF() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TCOLEXPANDEXPDIF(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLEXPANDEXPDIF(
        destination,
        source,
        broadcast);
    ExecuteTileExpand(
        TileExpand_EXPDIF,
        TileAxis_Column,
        destination,
        source,
        broadcast);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For every valid destination element, first compute typed source0 - BroadcastTile[0,c], then compute the same-type natural exponential.
- The subtraction and exponential stages apply in sequence and their numeric-status flags are accumulated into one transaction.

## Legality

- TCOLEXPANDEXPDIF is selected by the TEPL raw encoding carrier Mode 2 Function 27; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent full-shape source, one persistent one-row broadcast source, and one newly allocated Local destination.
- Only the eight architectural floating DataTypes are legal because EXPDIF composes typed TSUB and typed natural TEXP.
- The destination and both sources use exactly the selected DataType.
- The broadcast source has ValidRow equal to one and ValidCol and physical Col equal to the destination.
- The full-shape source and destination have identical physical and valid geometry equal to the B.DIM-derived geometry.
- Every source is a fully defined row-major numeric Tile with valid numeric encodings.
- PadValueOrByteId is the only applicable B.DATR field. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

## State effects

- For every valid destination element, first compute typed source0 - BroadcastTile[0,c], then compute the same-type natural exponential.
- The subtraction and exponential stages apply in sequence and their numeric-status flags are accumulated into one transaction.
- Apply the selected PadValue to physical destination coordinates outside the valid result rectangle.
- Publish the complete renamed destination atomically after every element succeeds.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes every source snapshot.
- All source payloads are snapshotted before result construction; sources persist and legal aliases use read-old/write-new behavior.
- Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, non-row-major source, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.
- An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Examples

- BSTART.SFU TCOLEXPANDEXPDIF, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
