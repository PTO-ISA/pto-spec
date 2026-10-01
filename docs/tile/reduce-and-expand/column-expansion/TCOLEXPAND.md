<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-expansion/TCOLEXPAND.asl -->
# TCOLEXPAND

**Normative ASL source:** `asl/tile/reduce-and-expand/column-expansion/TCOLEXPAND.asl`

Copy the first logical row of a column broadcast source bit-for-bit into a new Local destination.

## Normative identity {#PTO-INST-TILE-TCOLEXPAND}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcolexpand-purpose role=purpose -->
## What TCOLEXPAND does

`TCOLEXPAND` is a Tile reduce-and-expand operation executed by the `SFU` engine. It broadcasts one value per valid column of a Local source Tile down every valid row: for each destination coordinate `[r,c]` it copies `BroadcastTile[0,c]`. It is selected by `TEPL` Mode 2 Function 20 (selector `0x054`) and has no standalone opcode.

Design point: the broadcast source is an ordinary two-dimensional Tile whose later valid rows are ignored. The contract requires at least one valid row and exactly the destination's valid column count, so a full-shape Tile can be passed unchanged and only its first logical row supplies values.

<!-- PTO-READER-BLOCK: tile-tcolexpand-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, `ExecuteTileExpand` walks the destination valid rectangle in increasing row order and, inside each row, increasing column order. Each coordinate copies the raw operation-view bits of `BroadcastTile[0,c]`; the copy performs no conversion, rounding, saturation, canonicalization, or numeric-status update.

Design point: the copy is bit-for-bit through the operation view. A broadcast backing may differ from the operation DataType only through an equal-width, non-packed carrier view, so the copied bits are reinterpreted under the operation DataType.

<!-- PTO-READER-BLOCK: tile-tcolexpand-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the persistent Local broadcast source, bound once by the terminating `B.IOT`. Its logical row 0 supplies every value, its later valid rows are ignored and must be defined only when no ExecutionMask is in force, and its valid column count must equal the destination's.

- `destination0` is a newly allocated Local Tile with the operation DataType and the `B.DIM`-derived geometry; `LB0` is required and supplies a nonzero `ValidCol`, omitted `LB1` selects `ValidRow` one, and omitted `LB2` selects `Col` equal to `ValidCol`. Its other physical coordinates are padding coordinates.

- All operands use the same layout, and only `RowMajor`, `CUBE_M16`, and `CUBE_M32` are admitted.

- The operands share one `PE_MASK`. `PE_MASK=0000` is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

Design point: a broadcast copy has no full-shape source, so the destination geometry comes from the `B.DIM`-derived geometry instead of being copied from a second operand. The broadcast Tile only has to agree on the valid column count, and its valid row count may exceed one.

Design point: an expansion does accept the shared Local CUBE ExecutionMask, unlike a reduction. Inactive destination coordinates take the mask's zero or merge value instead of a computed value and contribute no source read and no numeric status, and a masked full-shape source must match the mask's layout and both valid extents.

<!-- PTO-READER-BLOCK: tile-tcolexpand-effects role=effects -->
## Publication, definedness, and padding

The destination is published as one unit: descriptor, every valid result, definedness, padding outside the valid rectangle, and accumulated numeric status appear together, and a rejected execution publishes none of them. The source payload is snapshotted before the first destination write, so a legal alias reads the old source values and the source persists unchanged.

Physical destination coordinates outside the `ValidRow x ValidCol` valid region receive the selected `PadValue`. `Zero`, `Max`, and `Min` define those coordinates; `Null` leaves them undefined.

Design point: omitting `B.DATR` selects `Null`, while an explicit `PadValue` code `00` selects `Zero`. Omission and encoded zero differ, so a program that reads the whole physical destination must ask for `Zero`, `Max`, or `Min`.

<!-- PTO-READER-BLOCK: tile-tcolexpand-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted operation types are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`, and the `BSTART` DataType is both the source operation DataType and the destination DataType. Each source backing may differ from it only through an equal-width, non-packed carrier view; raw bits are interpreted under the operation DataType without retagging or numeric conversion.

- Exactly one terminating Local `B.IOT` supplies the operands and one newly allocated Local destination; `B.IOR` and `B.IOS` are illegal.

- A malformed binding stream, a missing or zero dimension, an unsupported DataType, an unsupported or mixed layout, an undefined source element, a mismatched source geometry, or an invalid consumed operation-view encoding raises `Fault_TileLegality` before effects. An unrepresentable destination shape, insufficient `TSize`, an unavailable renamed destination, or exhausted Tile capacity raises `Fault_TileAllocation` before publication.

Design point: a broadcast copy validates no arithmetic encodings at all, so a copied element is never rejected as a non-canonical encoding of its type; only definedness, the descriptor, the carrier width, and the geometry are checked.

<!-- PTO-READER-BLOCK: tile-tcolexpand-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TCOLEXPAND` example, a broadcast source whose logical row 0 is `[10, 20]` fills both valid destination rows with `[10, 20]`, so a 2 x 2 destination holds `[[10, 20], [10, 20]]` even when its logical row 1 holds `[99, 99]`.

For an 8 x 64 `FP32` source whose valid region is 7 x 60 with `Zero` padding, the destination valid region is 7 x 60, so 420 elements are computed and 92 of the 512 coordinates receive the padding value.

In macro form the same operation is written `TCOLEXPAND <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, ->T<2KB>`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TCOLEXPAND <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLEXPAND | TEPL | 0x054 | 20 | 2 | ExecuteTileExpand |

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
| source0 | persistent Local column broadcast source; only row zero supplies values |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPAND.asl -->
```asl
readonly func InstructionContractOperation_TCOLEXPAND() => TileOperation
begin
    return TileOperation_TCOLEXPAND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCOLEXPAND, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPAND.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCOLEXPAND(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLEXPAND(
    destination: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_COPY,
        TileAxis_Column,
        destination,
        broadcast,
        broadcast);
end;

readonly func InstructionContractHandler_TCOLEXPAND() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TCOLEXPAND(
    destination: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLEXPAND(
        destination,
        broadcast);
    ExecuteTileExpand(
        TileExpand_COPY,
        TileAxis_Column,
        destination,
        broadcast,
        broadcast);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For every valid destination element, copy BroadcastTile[0,c] bit-for-bit.
- The copy performs no conversion, rounding, saturation, canonicalization, or numeric-status update.

## Legality

- TCOLEXPAND is selected by the TEPL raw encoding carrier Mode 2 Function 20; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent column broadcast source with at least one valid row and one newly allocated Local destination; no full-shape second source exists.
- The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.
- The destination DataType is the BSTART operation DataType. The broadcast source backing may differ only through an equal-width non-packed carrier view.
- The broadcast source has ValidRows >= 1 and ValidColumns equal to destination.ValidColumns; only logical row zero supplies values, while later valid rows remain defined but ignored.
- The destination geometry is the B.DIM-derived geometry.
- The source valid region is fully defined and Numeric in the selected RowMajor, CUBE_M16, or CUBE_M32 layout; COPY does not validate arithmetic encodings.
- Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

## State effects

- For every valid destination element, copy the raw operation-view bits of BroadcastTile[0,c] bit-for-bit.
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

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, unsupported or mixed layout, undefined source element, or mismatched source geometry raises Fault_TileLegality before effects. COPY forms do not validate numeric encodings.
- An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Examples

- BSTART.SFU TCOLEXPAND, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
