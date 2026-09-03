<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDDIV.asl -->
# TCOLEXPANDDIV

**Normative ASL source:** `asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDDIV.asl`

Divide a full-shape source by a broadcast one-row vector with exact typed semantics.

## Normative identity {#PTO-INST-TILE-TCOLEXPANDDIV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcolexpanddiv-purpose role=purpose -->
## What TCOLEXPANDDIV does

`TCOLEXPANDDIV` is a selector-encoded Tile operation executed by `SFU`. It divides each full-shape element by the broadcast value from the same column; its current instruction contract owns the exact bundle form and publication boundary.

<!-- PTO-READER-BLOCK: tile-tcolexpanddiv-mechanism role=mechanism -->
## Element and Tile mechanism

After all descriptor and operand checks succeed, the owning ASL handler divides each full-shape element by the broadcast value from the same column. Source payloads are snapshotted before destination writes whenever the contract permits aliasing.

The handler uses the resolved valid region rather than treating physical padding as input data. Its operation-specific dtype, layout, rounding, saturation, and profile hooks remain the executable definition.

<!-- PTO-READER-BLOCK: tile-tcolexpanddiv-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `destination0` has the exact contract role **new Local same-type numeric destination**.
- `source0` has the exact contract role **persistent Local full-shape numeric source**.
- `source1` has the exact contract role **persistent Local one-row broadcast source**.

Participating source and destination descriptors use the selected RowMajor, CUBE_M16, or CUBE_M32 layout and the logical-shape relationships stated by the current contract.
Every source coordinate read by the operation must be defined before execution reaches destination publication.
`PE_MASK=0000` is a strict no-op before descriptor, allocation, payload, numeric-status, or memory effects.

<!-- PTO-READER-BLOCK: tile-tcolexpanddiv-effects role=effects -->
## Publication, definedness, and padding

Destination-visible state is published only after complete preflight; where the contract names atomic publication, payload, descriptor, definedness, padding, and status become visible together.

Physical coordinates outside the valid rectangle follow the contract-selected padding rule; `Null` padding remains undefined when that rule applies.

The operation has no GM memory effect; descriptor, payload, definedness, padding, and numeric-status changes are limited to those listed by the current contract.

<!-- PTO-READER-BLOCK: tile-tcolexpanddiv-constraints role=constraints -->
## Type, layout, and fault boundary

The exact accepted type or type-pair set is owned by the generated legality section below; this guide does not widen it.

The generated legality and exception sections below are authoritative for dtype pairs, layout, dimensions, capacity, definedness, padding controls, profile behavior, and fault class. Legality and allocation failures occur before partial architectural effects.

<!-- PTO-READER-BLOCK: tile-tcolexpanddiv-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TCOLEXPANDDIV` example, full-shape row `[8, 9]` divided by broadcast row `[2, 3]` produces `[4, 3]`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TCOLEXPANDDIV <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLEXPANDDIV | TEPL | 0x058 | 24 | 2 | ExecuteTileExpand |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDDIV.asl -->
```asl
readonly func InstructionContractOperation_TCOLEXPANDDIV() => TileOperation
begin
    return TileOperation_TCOLEXPANDDIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCOLEXPANDDIV, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDDIV.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCOLEXPANDDIV(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLEXPANDDIV(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_DIV,
        TileAxis_Column,
        destination,
        source,
        broadcast);
end;

readonly func InstructionContractHandler_TCOLEXPANDDIV() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TCOLEXPANDDIV(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLEXPANDDIV(
        destination,
        source,
        broadcast);
    ExecuteTileExpand(
        TileExpand_DIV,
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
- For every valid destination element, compute source0[r,c] / BroadcastTile[0,c] at the selected element width.
- Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TDIV typed operation.
- A selected zero integer broadcast element is illegal before effects; floating positive and negative zero use the floating profile.

## Legality

- TCOLEXPANDDIV is selected by the TEPL raw encoding carrier Mode 2 Function 24; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent full-shape source, one persistent one-row broadcast source, and one newly allocated Local destination.
- The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.
- The destination and both sources use exactly the selected DataType.
- The broadcast source has logical ValidRow equal to one and ValidCol equal to the destination; physical extents are derived from the selected layout.
- The full-shape source and destination have identical logical valid geometry and the selected layout; physical geometry is derived per layout.
- Every source is a fully defined numeric Tile in the selected RowMajor, CUBE_M16, or CUBE_M32 layout with valid numeric encodings.
- Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

## State effects

- For every valid destination element, compute source0[r,c] / BroadcastTile[0,c] at the selected element width.
- Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TDIV typed operation.
- A selected zero integer broadcast element is illegal before effects; floating positive and negative zero use the floating profile.
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

- BSTART.SFU TCOLEXPANDDIV, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
