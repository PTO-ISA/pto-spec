<!-- GENERATED FROM: asl/tile/reduce-and-expand/row-expansion/TROWEXPAND.asl -->
# TROWEXPAND

**Normative ASL source:** `asl/tile/reduce-and-expand/row-expansion/TROWEXPAND.asl`

Broadcast one one-column vector source bit-for-bit into a new Local destination.

## Normative identity {#PTO-INST-TILE-TROWEXPAND}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trowexpand-purpose role=purpose -->
## What TROWEXPAND does

`TROWEXPAND` broadcasts one-column values bit-for-bit across each valid row.

<!-- PTO-READER-BLOCK: tile-c-trowexpand-mechanism role=mechanism -->
## Operation mechanism

The broadcast source has one valid column; its physical column extent is derived from the selected layout, and its row value is reused across every valid destination column.

TROWEXPAND has no full-shape source Tile. Its only input Tile is the one-column broadcast source, which is snapshotted before bit-copy construction.

<!-- PTO-READER-BLOCK: tile-c-trowexpand-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `destination0` identifies a newly allocated destination.

- `source0` supplies a persistent source Tile.

- The closed applicable DataType set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`.

- Data Tiles use row-major layout unless this mnemonic explicitly selects another permitted layout.

- `LB0`, `LB1`, and `LB2` complete the valid and physical shape according to this mnemonic’s contract; every required valid extent is nonzero.

<!-- PTO-READER-BLOCK: tile-c-trowexpand-effects role=effects -->
## Definedness, padding, and publication

All source descriptors and payloads are validated and snapshotted before destination publication.

The copied bit payload, destination descriptor, definedness, and padding state publish atomically; TROWEXPAND performs no numeric-profile evaluation or numeric-status update.

Null padding leaves physical coordinates outside the valid rectangle undefined; an explicit non-Null PadValue defines those coordinates with the selected typed value.

Source Tiles persist and are not modified by successful execution.

<!-- PTO-READER-BLOCK: tile-c-trowexpand-constraints role=constraints -->
## Legality, fault, and order boundaries

Complete binding schema, dimensions, DataType, layout, source definedness, numeric encoding, destination capacity, and allocation are preflighted before effects.

A failed legality or allocation check raises the applicable Tile fault without partial destination, status, or memory effects.

`PE_MASK=0000` is a strict no-op before operand reads, allocation, faults, numeric status, or payload effects.

<!-- PTO-READER-BLOCK: tile-c-trowexpand-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

`TROWEXPAND <bundle operands>` performs complete preflight and source snapshotting before atomically publishing the mnemonic-defined result and padding state.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TROWEXPAND <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWEXPAND | TEPL | 0x044 | 4 | 2 | ExecuteTileExpand |

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
| source0 | persistent Local one-column broadcast source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/row-expansion/TROWEXPAND.asl -->
```asl
readonly func InstructionContractOperation_TROWEXPAND() => TileOperation
begin
    return TileOperation_TROWEXPAND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TROWEXPAND, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/row-expansion/TROWEXPAND.asl -->
```asl
pure func InstructionContractDataTypeLegal_TROWEXPAND(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TROWEXPAND(
    destination: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_COPY,
        TileAxis_Row,
        destination,
        broadcast,
        broadcast);
end;

readonly func InstructionContractHandler_TROWEXPAND() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TROWEXPAND(
    destination: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TROWEXPAND(
        destination,
        broadcast);
    ExecuteTileExpand(
        TileExpand_COPY,
        TileAxis_Row,
        destination,
        broadcast,
        broadcast);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For every valid destination element, copy BroadcastTile[r,0] bit-for-bit.
- The copy performs no conversion, rounding, saturation, canonicalization, or numeric-status update.

## Legality

- TROWEXPAND is selected by the TEPL raw encoding carrier Mode 2 Function 4; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent one-column source and one newly allocated Local destination; no full-shape second source exists.
- The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.
- The destination DataType equals the broadcast source DataType.
- The broadcast source has ValidRow equal to the destination and logical orthogonal valid extent equal to one; physical extents are derived from the selected layout.
- The destination geometry is the B.DIM-derived geometry.
- Every source is a fully defined numeric Tile in the selected RowMajor, CUBE_M16, or CUBE_M32 layout with valid numeric encodings.
- Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

## State effects

- For every valid destination element, copy BroadcastTile[r,0] bit-for-bit.
- The copy performs no conversion, rounding, saturation, canonicalization, or numeric-status update.
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

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, unsupported, mixed, or mismatched source layout, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.
- An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Examples

- BSTART.SFU TROWEXPAND, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
