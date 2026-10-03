<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDEXPDIF.asl -->
# TCOLEXPANDEXPDIF

**Normative ASL source:** `asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDEXPDIF.asl`

Exponentiate the SrcDataType difference using the selected column broadcast element.

## Normative identity {#PTO-INST-TILE-TCOLEXPANDEXPDIF}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcolexpandexpdif-purpose role=purpose -->
## What TCOLEXPANDEXPDIF does

`TCOLEXPANDEXPDIF` is a Tile reduce-and-expand operation executed by the `SFU` engine. It combines a full-shape source with one broadcast value per valid column: for each destination coordinate `[r,c]` it computes `exp(source0[r,c] - BroadcastTile[0,c])`, so the broadcast Tile contributes one value per valid column. It is selected by `TEPL` Mode 2 Function 27 (selector `0x05B`) and has no standalone opcode.

Design point: a column expansion and the matching column reduction are inverse in shape: the reduction produces one value per valid column, while the expansion consumes one value per valid column and reuses it in every valid row, which is why the broadcast operand is a Tile rather than a scalar.

<!-- PTO-READER-BLOCK: tile-tcolexpandexpdif-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, `ExecuteTileExpand` computes each destination coordinate `[r,c]` as `exp(source0[r,c] - BroadcastTile[0,c])`, interpreting both operands as `SrcDataType`. For a same-type pair the subtraction and the exponential run in that type; for mixed `FP16` or `BF16` to `FP32` pairs both values are widened exactly to `FP32` first.

Design point: widening `FP16` or `BF16` to `FP32` is exact, so it is an interpretation step rather than a conversion and adds no conversion status. The difference is rounded once, at `FP32` precision, and the two stages OR their status into one transaction.

<!-- PTO-READER-BLOCK: tile-tcolexpandexpdif-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the persistent Local full-shape source. Its logical valid geometry and layout must match the destination.

- `source1` is the persistent Local column-broadcast source. Only `BroadcastTile[0,c]` supplies values; later valid rows are ignored and are not encoding-validated, and they must be defined only when no ExecutionMask is in force.

- `destination0` is a newly allocated Local Tile whose backing type is `DstDataType`; no destination alias and no source descriptor retag is introduced.

- All operands use the same layout, and only `RowMajor`, `CUBE_M16`, and `CUBE_M32` are admitted.

- The operands share one `PE_MASK`. `PE_MASK=0000` is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

Design point: the broadcast source is checked only where it is consumed. Its valid column count must equal the destination's; without an ExecutionMask the whole broadcast valid region must be defined, and under an ExecutionMask only the `BroadcastTile[0,c]` of a column with at least one active destination coordinate must be defined. The other broadcast elements are not encoding-validated.

Design point: an expansion does accept the shared Local CUBE ExecutionMask, unlike a reduction. Inactive destination coordinates take the mask's zero or merge value instead of a computed value and contribute no source read and no numeric status, and a masked full-shape source must match the mask's layout and both valid extents.

<!-- PTO-READER-BLOCK: tile-tcolexpandexpdif-effects role=effects -->
## Publication, definedness, and padding

The destination is published as one unit: descriptor, every valid result, definedness, padding outside the valid rectangle, and accumulated numeric status appear together, and a rejected execution publishes none of them. Both source payloads are snapshotted before the first destination write, so a legal alias reads the old source values and the sources persist unchanged.

Physical destination coordinates outside the `ValidRow x ValidCol` valid region receive the selected `PadValue`. `Zero`, `Max`, and `Min` define those coordinates; `Null` leaves them undefined.

Design point: omitting `B.DATR` selects `Null`, while an explicit `PadValue` code `00` selects `Zero`. Omission and encoded zero differ, so a program that reads the whole physical destination must ask for `Zero`, `Max`, or `Min`.

<!-- PTO-READER-BLOCK: tile-tcolexpandexpdif-constraints role=constraints -->
## Type, layout, and fault boundary

`TROWEXPANDEXPDIF` and `TCOLEXPANDEXPDIF` accept exactly `(FP64,FP64)`, `(FP32,FP32)`, `(FP16,FP16)`, `(BF16,BF16)`, `(FP16,FP32)`, and `(BF16,FP32)` as `(SrcDataType,DstDataType)` pairs. `BSTART` selects `SrcDataType`; an omitted `B.DATR` or `DTYPE_NONE` makes `DstDataType` inherit it.

Design point: an encoded `DataType` of zero names `FP64` and is never absence, so inheritance needs the separate `DTYPE_NONE` sentinel; a program that wants the source type must omit `B.DATR` or encode `DTYPE_NONE` deliberately.

- Exactly one terminating Local `B.IOT` supplies the operands and one newly allocated Local destination; `B.IOR` and `B.IOS` are illegal.

- A malformed binding stream, a missing or zero dimension, an unsupported DataType, an unsupported or mixed layout, an undefined source element, a mismatched source geometry, or an invalid consumed operation-view encoding raises `Fault_TileLegality` before effects. An unrepresentable destination shape, insufficient `TSize`, an unavailable renamed destination, or exhausted Tile capacity raises `Fault_TileAllocation` before publication.

Design point: the exponential stage accepts `FP64`, `FP32`, `FP16`, and `BF16`, and every legal pair maps onto those executable types. A 64-bit CUBE form requires `CUBE_M32`.

<!-- PTO-READER-BLOCK: tile-tcolexpandexpdif-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TCOLEXPANDEXPDIF` example, the full-shape rows `[1, 2]` and `[3, 4]` minus the broadcast row 0 `[1, 2]` give the differences `[[0, 0], [2, 2]]`, so the destination holds `[[1, 1], [e^2, e^2]]`.

For an 8 x 64 `FP32` source whose valid region is 7 x 60 with `Zero` padding, the destination valid region is 7 x 60, so 420 elements are computed and 92 of the 512 coordinates receive the padding value.

In macro form the same operation is written `TCOLEXPANDEXPDIF <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, T#2, ->T<2KB>`.
<!-- SUPPLEMENTARY-END -->

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

### DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | assigned | E6M2 |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | assigned | RCPE6M2 |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local DstDataType destination |
| source0 | persistent Local full-shape numeric source |
| source1 | persistent Local column broadcast source interpreted through SrcDataType; only row zero supplies values |

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
B.DATR Layout, DataType, PadValue (optional)
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
    return data_type == TileDataType_FP64 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_FP32;
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
- Omitted B.DATR selects DstDataType=SrcDataType and PadValue=Null. When B.DATR is present, DTYPE_NONE inherits SrcDataType, a concrete DataType selects DstDataType, and encoded DataType zero selects FP64 and is never absence. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.

## Legality

- TROWEXPANDEXPDIF and TCOLEXPANDEXPDIF accept exactly (FP64,FP64), (FP16,FP16), (BF16,BF16), (FP32,FP32), (FP16,FP32), and (BF16,FP32) as (SrcDataType,DstDataType) pairs.
- BSTART DataType selects SrcDataType; omitted B.DATR or explicit DataType=DTYPE_NONE selects DstDataType=SrcDataType, while a concrete B.DATR DataType selects DstDataType. Each source backing may differ from SrcDataType only through an equal-width non-packed carrier view; raw bits are interpreted as SrcDataType without retagging or numeric conversion.
- Mixed FP16/BF16 to FP32 widens the operation-view source bits exactly to FP32 before FP32 subtraction and FP32 exponential. Same-type pairs retain their selected type.
- The destination is newly allocated with DstDataType; no destination alias or source descriptor retag is introduced.
- The broadcast source has ValidRows >= 1 and ValidColumns equal to destination.ValidColumns; only BroadcastTile[0,c] supplies the column value, while later valid rows remain defined but are ignored.
- The full-shape source and destination have identical logical valid geometry and the selected layout; physical geometry is derived per layout.
- All source valid regions are fully defined and Numeric in the selected RowMajor, CUBE_M16, or CUBE_M32 layout. Full-shape and selected broadcast operation-view payloads must have valid SrcDataType encodings; ignored extra broadcast elements need definedness but are not encoding-validated.
- Layout, PadValueOrByteId, and DataType are the only applicable nonzero B.DATR fields. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.
- FP64 source and FP64 destination form an accepted same-type pair; mixed FP64 type pairs are not added.

## State effects

- For each destination [r,c], interpret source0[r,c] and BroadcastTile[0,c] as SrcDataType. For mixed FP16/BF16 to FP32 pairs, widen both exactly to FP32, then subtract and exponentiate at FP32; same-type pairs retain the existing sequence.
- The subtraction and exponential stages apply in sequence and their numeric-status flags are accumulated into one transaction.
- Apply the selected PadValue to physical destination coordinates outside the valid result rectangle.
- Publish the complete renamed destination atomically after every element succeeds.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, source/destination type-pair, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes every source snapshot.
- All source payloads are snapshotted before result construction; sources persist and same-type legal aliases use read-old/write-new behavior.
- Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType or EXPDIF pair, unsupported or mixed layout, undefined source element, mismatched source geometry, or invalid consumed arithmetic/EXPDIF operation-view encoding raises Fault_TileLegality before effects. Ignored extra broadcast elements remain defined but are not encoding-validated.
- An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Examples

- BSTART.SFU TCOLEXPANDEXPDIF, SrcDataType; B.DATR Layout, DataType, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
