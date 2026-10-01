<!-- GENERATED FROM: asl/tile/reduce-and-expand/row-expansion/TROWEXPAND.asl -->
# TROWEXPAND

**Normative ASL source:** `asl/tile/reduce-and-expand/row-expansion/TROWEXPAND.asl`

Copy the selected row-broadcast element bit-for-bit into a new Local destination.

## Normative identity {#PTO-INST-TILE-TROWEXPAND}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trowexpand-purpose role=purpose -->
## What TROWEXPAND does

`TROWEXPAND` is a Tile reduce-and-expand operation executed by the `SFU` engine. It broadcasts one value per valid row of a Local source Tile down every valid column: for each destination coordinate `[r,c]` it copies `BroadcastTile[r,BroadcastSlot]`. It is selected by `TEPL` Mode 2 Function 4 (selector `0x044`) and has no standalone opcode.

Design point: the broadcast source is an ordinary two-dimensional Tile whose later valid columns are ignored. The contract requires exactly the destination's valid row count and at least one valid column, so a full-shape Tile can be passed unchanged and only the selected slot of each valid row supplies values.

<!-- PTO-READER-BLOCK: tile-c-trowexpand-mechanism role=mechanism -->
## Operation mechanism

After complete preflight, `ExecuteTileExpand` walks the destination valid rectangle in increasing row order and, inside each row, increasing column order. Each coordinate copies the raw operation-view bits of `BroadcastTile[r,BroadcastSlot]`; the copy performs no conversion, rounding, saturation, canonicalization, or numeric-status update.

Design point: the copy is bit-for-bit through the operation view. A broadcast backing may differ from the operation DataType only through an equal-width, non-packed carrier view, so the copied bits are reinterpreted under the operation DataType.

<!-- PTO-READER-BLOCK: tile-c-trowexpand-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `source0` is the persistent Local broadcast source, bound once by the terminating `B.IOT`. Its valid row count must equal the destination's, only the selected slot of each valid row supplies values, and the other valid columns are ignored and must be defined only when no ExecutionMask is in force.

- `destination0` is a newly allocated Local Tile with the operation DataType and the `B.DIM`-derived geometry; `LB0` is required and supplies a nonzero `ValidCol`, omitted `LB1` selects `ValidRow` one, and omitted `LB2` selects `Col` equal to `ValidCol`. Its other physical coordinates are padding coordinates.

- All operands use the same layout, and only `RowMajor`, `CUBE_M16`, and `CUBE_M32` are admitted. The slot is logical column 0 for `RowMajor` and the `B.DATR.RMode`-selected operation-typed slot for `CUBE_M16` and `CUBE_M32`.

- The operands share one `PE_MASK`. `PE_MASK=0000` is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

Design point: a broadcast copy has no full-shape source, so the destination geometry comes from the `B.DIM`-derived geometry instead of being copied from a second operand. The broadcast Tile only has to agree on the valid row count, and its valid column count may exceed one.

Design point: an expansion does accept the shared Local CUBE ExecutionMask, unlike a reduction. Inactive destination coordinates take the mask's zero or merge value instead of a computed value and contribute no source read and no numeric status, and a masked full-shape source must match the mask's layout and both valid extents.

<!-- PTO-READER-BLOCK: tile-c-trowexpand-effects role=effects -->
## Definedness, padding, and publication

The destination is published as one unit: descriptor, every valid result, definedness, padding outside the valid rectangle, and accumulated numeric status appear together, and a rejected execution publishes none of them. The source payload is snapshotted before the first destination write, so a legal alias reads the old source values and the source persists unchanged.

Physical destination coordinates outside the `ValidRow x ValidCol` valid region receive the selected `PadValue`. `Zero`, `Max`, and `Min` define those coordinates; `Null` leaves them undefined.

Design point: omitting `B.DATR` selects `Null`, while an explicit `PadValue` code `00` selects `Zero`. Omission and encoded zero differ, so a program that reads the whole physical destination must ask for `Zero`, `Max`, or `Min`.

<!-- PTO-READER-BLOCK: tile-c-trowexpand-constraints role=constraints -->
## Legality, fault, and order boundaries

The accepted operation types are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`, and the `BSTART` DataType is both the source operation DataType and the destination DataType. Each source backing may differ from it only through an equal-width, non-packed carrier view; raw bits are interpreted under the operation DataType without retagging or numeric conversion.

- Exactly one terminating Local `B.IOT` supplies the operands and one newly allocated Local destination; `B.IOR` and `B.IOS` are illegal.

- A malformed binding stream, a missing or zero dimension, an unsupported DataType, an unsupported or mixed layout, an undefined source element, a mismatched source geometry, or an invalid consumed operation-view encoding raises `Fault_TileLegality` before effects. An unrepresentable destination shape, insufficient `TSize`, an unavailable renamed destination, or exhausted Tile capacity raises `Fault_TileAllocation` before publication.

Design point: a broadcast copy validates no arithmetic encodings at all, so a copied element is never rejected as a non-canonical encoding of its type; only definedness, the descriptor, the carrier width, and the geometry are checked.

Design point: for `CUBE_M32` and `CUBE_M16`, `B.DATR.RMode` is the unsigned `BroadcastByteOffset` and not a numeric rounding selector, `RowMajor` requires it to be zero, and the offset must be element-aligned and stay inside one `CELL` slice.

- An illegal CUBE byte offset, alignment, `CELL` slot, or valid-column selection raises `Fault_TileLegality` before the source snapshot, destination allocation or publication, numeric status, or payload effects; `PE_MASK=0000` skips this operation-specific selector check on its strict no-effect path.

<!-- PTO-READER-BLOCK: tile-c-trowexpand-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

For a small `TROWEXPAND` example, a broadcast source whose logical column 0 is `[10, 20]` fills the two valid destination rows as `[10, 10]` and `[20, 20]`, so a 2 x 2 destination holds `[[10, 10], [20, 20]]` even when its logical column 1 holds `[99, 99]`.

For an 8 x 64 `FP32` source whose valid region is 7 x 60 with `Zero` padding, the destination valid region is 7 x 60, so 420 elements are computed and 92 of the 512 coordinates receive the padding value.

In macro form the same operation is written `TROWEXPAND <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, ->T<2KB>`.
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
| source0 | persistent Local row broadcast source; only the selected BroadcastSlot supplies values |

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
B.DATR Layout, RMode=BroadcastByteOffset for CUBE_M16/M32, PadValue (optional)
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
- For every valid destination element, copy BroadcastTile[r,BroadcastSlot] bit-for-bit.
- The copy performs no conversion, rounding, saturation, canonicalization, or numeric-status update.
- For CUBE_M32 and CUBE_M16, B.DATR.RMode[2:0] is the unsigned BroadcastByteOffset 0..7, not a numeric rounding selector. Omitted B.DATR selects offset zero. The offset is interpreted using the source operation DataType and selects a logical slot within the first CELL of the bound broadcast Tile; B.SUBVIEW selects a CELL/range before this in-CELL selection.

## Legality

- TROWEXPAND is selected by the TEPL raw encoding carrier Mode 2 Function 4; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent row broadcast source with at least one valid column and one newly allocated Local destination; no full-shape second source exists.
- The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.
- The destination DataType is the BSTART operation DataType. The broadcast source backing may differ only through an equal-width non-packed carrier view.
- The broadcast source has ValidRows equal to destination.ValidRows and ValidColumns >= 1. Without ExecutionMask its entire valid region remains required to be defined; with ExecutionMask, only the selected BroadcastTile[r,BroadcastSlot] for a row with an active destination coordinate must be defined. Other columns supply no broadcast value.
- The destination geometry is the B.DIM-derived geometry.
- Without ExecutionMask, the broadcast valid region remains fully defined. With ExecutionMask, only the selected BroadcastTile[r,BroadcastSlot] for each row with an active destination coordinate must be defined; an inactive row does not read or validate its selected element. COPY does not validate arithmetic encodings.
- Layout, PadValueOrByteId, and operation-specific RMode are applicable as encoded by the selected layout; RMode means BroadcastByteOffset only for CUBE_M16/M32 and must be zero for RowMajor. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.
- For CUBE_M32/CUBE_M16, the source-operation-typed BroadcastSlot is BroadcastByteOffset DIV ElementBytes. The offset must be less than the 4-byte M32 or 8-byte M16 per-row CELL slice, aligned to ElementBytes, and select a slot below both TileCubeCellColumns(Layout, SourceOperationDataType) and BroadcastTile.ValidColumns. The selector addresses only the first CELL of the bound broadcast Tile; B.SUBVIEW selects a later CELL/range when needed. RowMajor requires RMode zero.

## State effects

- For every valid destination element, copy the raw operation-view bits of BroadcastTile[r,BroadcastSlot] bit-for-bit.
- The copy performs no conversion, rounding, saturation, canonicalization, or numeric-status update.
- Apply the selected PadValue to physical destination coordinates outside the valid result rectangle.
- Publish the complete renamed destination atomically after every element succeeds.
- For CUBE_M32/M16 row expansion, splat the source-operation-typed BroadcastTile[r,BroadcastSlot] selected by B.DATR.RMode; RowMajor continues to use BroadcastTile[r,BroadcastSlot].

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
- After existing bundle and B.SUBVIEW preparation succeeds, an illegal CUBE byte offset, alignment, CELL slot, or valid-column selection raises Fault_TileLegality before source snapshot, destination allocation or publication, numeric status, or payload effects. PE_MASK=0000 keeps the strict no-effect path and skips this operation-specific selector check.

## Examples

- BSTART.SFU TROWEXPAND, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
