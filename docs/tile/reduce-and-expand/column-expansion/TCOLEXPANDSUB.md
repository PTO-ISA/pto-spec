<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDSUB.asl -->
# TCOLEXPANDSUB

**Normative ASL source:** `asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDSUB.asl`

Subtract a first-row column-broadcast source from a full-shape source with exact typed semantics.

## Normative identity {#PTO-INST-TILE-TCOLEXPANDSUB}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcolexpandsub-purpose role=purpose -->
## What TCOLEXPANDSUB does

`TCOLEXPANDSUB` is a Tile reduce-and-expand operation executed by the `SFU` engine. It combines a full-shape source with one broadcast value per valid column: for each destination coordinate `[r,c]` it computes `source0[r,c] - BroadcastTile[0,c]`, so the broadcast Tile contributes one value per valid column. It is selected by `TEPL` Mode 2 Function 22 (selector `0x056`) and has no standalone opcode.

Design point: a column expansion and the matching column reduction are inverse in shape: the reduction produces one value per valid column, while the expansion consumes one value per valid column and reuses it in every valid row, which is why the broadcast operand is a Tile rather than a scalar.

<!-- PTO-READER-BLOCK: tile-tcolexpandsub-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, `ExecuteTileExpand` computes each destination coordinate `[r,c]` independently as `source0[r,c] - BroadcastTile[0,c]`, with `source0[r,c]` always the left operand and `BroadcastTile[0,c]` always the right operand. Integer results stay at the element width; floating results, exceptional values, signed-zero behavior, and the per-element numeric-status flags are exactly those of the corresponding `TSUB` typed operation.

Design point: the operand order is architectural rather than configurable, and every element's status is ORed into one transaction that publishes with the result.

<!-- PTO-READER-BLOCK: tile-tcolexpandsub-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the persistent Local full-shape source. Its logical valid geometry and layout must match the destination.

- `source1` is the persistent Local column-broadcast source. Only `BroadcastTile[0,c]` supplies values; later valid rows are ignored and are not encoding-validated, and they must be defined only when no ExecutionMask is in force.

- `destination0` is a newly allocated Local Tile with the operation DataType and the `B.DIM`-derived geometry; `LB0` is required and supplies a nonzero `ValidCol`, omitted `LB1` selects `ValidRow` one, and omitted `LB2` selects `Col` equal to `ValidCol`. Its other physical coordinates are padding coordinates.

- All operands use the same layout, and only `RowMajor`, `CUBE_M16`, and `CUBE_M32` are admitted.

- The operands share one `PE_MASK`. `PE_MASK=0000` is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

Design point: the broadcast source is checked only where it is consumed. Its valid column count must equal the destination's; without an ExecutionMask the whole broadcast valid region must be defined, and under an ExecutionMask only the `BroadcastTile[0,c]` of a column with at least one active destination coordinate must be defined. The other broadcast elements are not encoding-validated.

Design point: an expansion does accept the shared Local CUBE ExecutionMask, unlike a reduction. Inactive destination coordinates take the mask's zero or merge value instead of a computed value and contribute no source read and no numeric status, and a masked full-shape source must match the mask's layout and both valid extents.

<!-- PTO-READER-BLOCK: tile-tcolexpandsub-effects role=effects -->
## Publication, definedness, and padding

The destination is published as one unit: descriptor, every valid result, definedness, padding outside the valid rectangle, and accumulated numeric status appear together, and a rejected execution publishes none of them. Both source payloads are snapshotted before the first destination write, so a legal alias reads the old source values and the sources persist unchanged.

Physical destination coordinates outside the `ValidRow x ValidCol` valid region receive the selected `PadValue`. `Zero`, `Max`, and `Min` define those coordinates; `Null` leaves them undefined.

Design point: omitting `B.DATR` selects `Null`, while an explicit `PadValue` code `00` selects `Zero`. Omission and encoded zero differ, so a program that reads the whole physical destination must ask for `Zero`, `Max`, or `Min`.

<!-- PTO-READER-BLOCK: tile-tcolexpandsub-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted operation types are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`, and the `BSTART` DataType is both the source operation DataType and the destination DataType. Each source backing may differ from it only through an equal-width, non-packed carrier view; raw bits are interpreted under the operation DataType without retagging or numeric conversion.

- Exactly one terminating Local `B.IOT` supplies the operands and one newly allocated Local destination; `B.IOR` and `B.IOS` are illegal.

- A malformed binding stream, a missing or zero dimension, an unsupported DataType, an unsupported or mixed layout, an undefined source element, a mismatched source geometry, or an invalid consumed operation-view encoding raises `Fault_TileLegality` before effects. An unrepresentable destination shape, insufficient `TSize`, an unavailable renamed destination, or exhausted Tile capacity raises `Fault_TileAllocation` before publication.

Design point: legality admits sixteen types, but the floating element step reaches `ScalarFPBinaryProfile`, which is defined only for `FP64`, `FP32`, `FP16`, and `BF16`. The ASL defines no element result for `TF32`, `HF32`, `E4M3`, and `E5M2`, so those four types cannot be used here even though legality accepts them.

<!-- PTO-READER-BLOCK: tile-tcolexpandsub-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TCOLEXPANDSUB` example, the full-shape rows `[5, 7]` and `[8, 9]` minus the broadcast row 0 `[2, 3]` produce `[[3, 4], [6, 6]]`.

For an 8 x 64 `FP32` source whose valid region is 7 x 60 with `Zero` padding, the destination valid region is 7 x 60, so 420 elements are computed and 92 of the 512 coordinates receive the padding value.

In macro form the same operation is written `TCOLEXPANDSUB <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, T#2, ->T<2KB>`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TCOLEXPANDSUB <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLEXPANDSUB | TEPL | 0x056 | 22 | 2 | ExecuteTileExpand |

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
| source1 | persistent Local column broadcast source; only row zero supplies values through the BSTART operation view |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDSUB.asl -->
```asl
readonly func InstructionContractOperation_TCOLEXPANDSUB() => TileOperation
begin
    return TileOperation_TCOLEXPANDSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCOLEXPANDSUB, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDSUB.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCOLEXPANDSUB(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLEXPANDSUB(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_SUB,
        TileAxis_Column,
        destination,
        source,
        broadcast);
end;

readonly func InstructionContractHandler_TCOLEXPANDSUB() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TCOLEXPANDSUB(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLEXPANDSUB(
        destination,
        source,
        broadcast);
    ExecuteTileExpand(
        TileExpand_SUB,
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
- For every valid destination element, compute source0[r,c] - BroadcastTile[0,c] at the selected element width.
- Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TSUB typed operation.

## Legality

- TCOLEXPANDSUB is selected by the TEPL raw encoding carrier Mode 2 Function 22; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent full-shape source, one persistent column broadcast source with at least one valid row, and one newly allocated Local destination.
- The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.
- The BSTART DataType is both the source operation DataType and destination DataType. Each source backing DataType may differ only through an equal-width non-packed carrier view; raw bits are interpreted under the operation DataType without retagging or numeric conversion.
- The broadcast source has ValidRows >= 1 and ValidColumns equal to destination.ValidColumns; only BroadcastTile[0,c] supplies values, while later valid rows remain defined but ignored.
- The full-shape source and destination have identical logical valid geometry and the selected layout; physical geometry is derived per layout.
- All source valid regions are fully defined and Numeric in the selected RowMajor, CUBE_M16, or CUBE_M32 layout. Full-shape and selected broadcast operation-view payloads must have valid encodings; ignored extra broadcast elements need definedness but are not encoding-validated.
- Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

## State effects

- For every valid destination element, compute source0[r,c] - operation-view BroadcastTile[0,c] at the selected element width.
- Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TSUB typed operation.
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

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType or EXPDIF pair, unsupported or mixed layout, undefined source element, mismatched source geometry, or invalid consumed arithmetic/EXPDIF operation-view encoding raises Fault_TileLegality before effects. Ignored extra broadcast elements remain defined but are not encoding-validated.
- An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Examples

- BSTART.SFU TCOLEXPANDSUB, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
