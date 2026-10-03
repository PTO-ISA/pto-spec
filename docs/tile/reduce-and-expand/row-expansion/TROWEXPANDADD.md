<!-- GENERATED FROM: asl/tile/reduce-and-expand/row-expansion/TROWEXPANDADD.asl -->
# TROWEXPANDADD

**Normative ASL source:** `asl/tile/reduce-and-expand/row-expansion/TROWEXPANDADD.asl`

Add a selected row-broadcast element to a full-shape source with exact typed semantics.

## Normative identity {#PTO-INST-TILE-TROWEXPANDADD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trowexpandadd-purpose role=purpose -->
## What TROWEXPANDADD does

`TROWEXPANDADD` is a Tile reduce-and-expand operation executed by the `SFU` engine. It combines a full-shape source with one broadcast value per valid row: for each destination coordinate `[r,c]` it computes `source0[r,c] + BroadcastTile[r,BroadcastSlot]`, so the broadcast Tile contributes one value per valid row. It is selected by `TEPL` Mode 2 Function 5 (selector `0x045`) and has no standalone opcode.

Design point: a row expansion and the matching row reduction are inverse in shape: the reduction produces one value per valid row, while the expansion consumes one value per valid row and reuses it in every valid column, which is why the broadcast operand is a Tile rather than a scalar.

<!-- PTO-READER-BLOCK: tile-c-trowexpandadd-mechanism role=mechanism -->
## Operation mechanism

After complete preflight, `ExecuteTileExpand` computes each destination coordinate `[r,c]` independently as `source0[r,c] + BroadcastTile[r,BroadcastSlot]`, with `source0[r,c]` always the left operand and `BroadcastTile[r,BroadcastSlot]` always the right operand. Integer results stay at the element width; floating results, exceptional values, signed-zero behavior, and the per-element numeric-status flags are exactly those of the corresponding `TADD` typed operation.

Design point: the operand order is architectural rather than configurable, and every element's status is ORed into one transaction that publishes with the result.

<!-- PTO-READER-BLOCK: tile-c-trowexpandadd-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `source0` is the persistent Local full-shape source. Its logical valid geometry and layout must match the destination.

- `source1` is the persistent Local row-broadcast source. Only `BroadcastTile[r,BroadcastSlot]` supplies values; later valid columns are ignored and are not encoding-validated, and they must be defined only when no ExecutionMask is in force.

- `destination0` is a newly allocated Local Tile with the operation DataType and the `B.DIM`-derived geometry; `LB0` is required and supplies a nonzero `ValidCol`, omitted `LB1` selects `ValidRow` one, and omitted `LB2` selects `Col` equal to `ValidCol`. Its other physical coordinates are padding coordinates.

- All operands use the same layout, and only `RowMajor`, `CUBE_M16`, and `CUBE_M32` are admitted. The slot is logical column 0 for `RowMajor` and the `B.DATR.RMode`-selected operation-typed slot for `CUBE_M16` and `CUBE_M32`. A 64-bit CUBE operand requires the `CUBE_M32` double-CELL mapping; `CUBE_M16` rejects it.

- The operands share one `PE_MASK`. `PE_MASK=0000` is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

Design point: the broadcast source is checked only where it is consumed. Its valid row count must equal the destination's; without an ExecutionMask the whole broadcast valid region must be defined, and under an ExecutionMask only the `BroadcastTile[r,BroadcastSlot]` of a row with at least one active destination coordinate must be defined. The other broadcast elements are not encoding-validated.

Design point: an expansion does accept the shared Local CUBE ExecutionMask, unlike a reduction. Inactive destination coordinates take the mask's zero or merge value instead of a computed value and contribute no source read and no numeric status, and a masked full-shape source must match the mask's layout and both valid extents.

<!-- PTO-READER-BLOCK: tile-c-trowexpandadd-effects role=effects -->
## Definedness, padding, and publication

The destination is published as one unit: descriptor, every valid result, definedness, padding outside the valid rectangle, and accumulated numeric status appear together, and a rejected execution publishes none of them. Both source payloads are snapshotted before the first destination write, so a legal alias reads the old source values and the sources persist unchanged.

Physical destination coordinates outside the `ValidRow x ValidCol` valid region receive the selected `PadValue`. `Zero`, `Max`, and `Min` define those coordinates; `Null` leaves them undefined.

Design point: omitting `B.DATR` selects `Null`, while an explicit `PadValue` code `00` selects `Zero`. Omission and encoded zero differ, so a program that reads the whole physical destination must ask for `Zero`, `Max`, or `Min`.

<!-- PTO-READER-BLOCK: tile-c-trowexpandadd-constraints role=constraints -->
## Legality, fault, and order boundaries

The accepted operation types are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`, and the `BSTART` DataType is both the source operation DataType and the destination DataType. Each source backing may differ from it only through an equal-width, non-packed carrier view; raw bits are interpreted under the operation DataType without retagging or numeric conversion.

- Exactly one terminating Local `B.IOT` supplies the operands and one newly allocated Local destination; `B.IOR` and `B.IOS` are illegal.

- A malformed binding stream, a missing or zero dimension, an unsupported DataType, an unsupported or mixed layout, an undefined source element, a mismatched source geometry, or an invalid consumed operation-view encoding raises `Fault_TileLegality` before effects. An unrepresentable destination shape, insufficient `TSize`, an unavailable renamed destination, or exhausted Tile capacity raises `Fault_TileAllocation` before publication.

Design point: legality admits sixteen types, but the floating element step reaches `ScalarFPBinaryProfile`, which is defined only for `FP64`, `FP32`, `FP16`, and `BF16`. The ASL defines no element result for `TF32`, `HF32`, `E4M3`, and `E5M2`, so those four types cannot be used here even though legality accepts them.

Design point: for `CUBE_M32` and `CUBE_M16`, `B.DATR.RMode` is the unsigned `BroadcastByteOffset` and not a numeric rounding selector, `RowMajor` requires it to be zero, and the offset must be element-aligned and stay inside one `CELL` slice.

- An illegal CUBE byte offset, alignment, `CELL` slot, or valid-column selection raises `Fault_TileLegality` before the source snapshot, destination allocation or publication, numeric status, or payload effects; `PE_MASK=0000` skips this operation-specific selector check on its strict no-effect path.

<!-- PTO-READER-BLOCK: tile-c-trowexpandadd-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

For a small `TROWEXPANDADD` example, the full-shape rows `[1, 2]` and `[3, 4]` plus the broadcast column 0 values `[10, 20]` produce `[[11, 12], [23, 24]]`.

For an 8 x 64 `FP32` source whose valid region is 7 x 60 with `Zero` padding, the destination valid region is 7 x 60, so 420 elements are computed and 92 of the 512 coordinates receive the padding value.

In macro form the same operation is written `TROWEXPANDADD <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, T#2, ->T<2KB>`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TROWEXPANDADD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWEXPANDADD | TEPL | 0x045 | 5 | 2 | ExecuteTileExpand |

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
| source1 | persistent Local row broadcast source; only the selected BroadcastSlot supplies values through the BSTART operation view |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/row-expansion/TROWEXPANDADD.asl -->
```asl
readonly func InstructionContractOperation_TROWEXPANDADD() => TileOperation
begin
    return TileOperation_TROWEXPANDADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TROWEXPANDADD, DataType
B.DATR Layout, RMode=BroadcastByteOffset for CUBE_M16/M32, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/row-expansion/TROWEXPANDADD.asl -->
```asl
pure func InstructionContractDataTypeLegal_TROWEXPANDADD(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TROWEXPANDADD(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_ADD,
        TileAxis_Row,
        destination,
        source,
        broadcast);
end;

readonly func InstructionContractHandler_TROWEXPANDADD() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TROWEXPANDADD(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TROWEXPANDADD(
        destination,
        source,
        broadcast);
    ExecuteTileExpand(
        TileExpand_ADD,
        TileAxis_Row,
        destination,
        source,
        broadcast);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For every valid destination element, compute source0[r,c] + BroadcastTile[r,BroadcastSlot] at the selected element width.
- Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TADD typed operation.
- For CUBE_M32 and CUBE_M16, B.DATR.RMode[2:0] is the unsigned BroadcastByteOffset 0..7, not a numeric rounding selector. Omitted B.DATR selects offset zero. The offset is interpreted using the source operation DataType and selects a logical slot within the first CELL of the bound broadcast Tile; B.SUBVIEW selects a CELL/range before this in-CELL selection.

## Legality

- TROWEXPANDADD is selected by the TEPL raw encoding carrier Mode 2 Function 5; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent full-shape source, one persistent row broadcast source with at least one valid column, and one newly allocated Local destination.
- The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.
- The BSTART DataType is both the source operation DataType and destination DataType. Each source backing DataType may differ only through an equal-width non-packed carrier view; raw bits are interpreted under the operation DataType without retagging or numeric conversion.
- The broadcast source has ValidRows equal to destination.ValidRows and ValidColumns >= 1. Without ExecutionMask its entire valid region remains required to be defined; with ExecutionMask, only the selected BroadcastTile[r,BroadcastSlot] for a row with an active destination coordinate must be defined. Other columns supply no broadcast value.
- The full-shape source and destination have identical logical valid geometry and the selected layout; physical geometry is derived per layout.
- Without ExecutionMask, each source valid region remains fully defined. With ExecutionMask, only full-shape source coordinates consumed by active destinations and the selected broadcast element for each row with an active destination coordinate must be defined. Numeric encoding validation uses the source operation DataType for consumed full-shape elements and the selected broadcast element; unselected broadcast columns are not encoding-validated. Inactive rows contribute no source read, encoding validation, or numeric-status flags.
- Layout, PadValueOrByteId, and operation-specific RMode are applicable as encoded by the selected layout; RMode means BroadcastByteOffset only for CUBE_M16/M32 and must be zero for RowMajor. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.
- For CUBE_M32/CUBE_M16, the source-operation-typed BroadcastSlot is BroadcastByteOffset DIV ElementBytes. The offset must be less than the 4-byte lower-width M32 or 8-byte M16 per-row CELL slice (a b64 M32 group spans 8 bytes across the pair), aligned to ElementBytes, and select a slot below both TileCubeCellColumns(Layout, SourceOperationDataType) and BroadcastTile.ValidColumns. The selector addresses only the first logical CELL group of the bound broadcast Tile, including both planes for b64 M32; B.SUBVIEW selects a later CELL/range when needed. RowMajor requires RMode zero.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- For every valid destination element, compute source0[r,c] + operation-view BroadcastTile[r,BroadcastSlot] at the selected element width.
- Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TADD typed operation.
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

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType or EXPDIF pair, unsupported or mixed layout, undefined source element, mismatched source geometry, or invalid consumed arithmetic/EXPDIF operation-view encoding raises Fault_TileLegality before effects. Ignored extra broadcast elements remain defined but are not encoding-validated.
- An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.
- After existing bundle and B.SUBVIEW preparation succeeds, an illegal CUBE byte offset, alignment, CELL slot, or valid-column selection raises Fault_TileLegality before source snapshot, destination allocation or publication, numeric status, or payload effects. PE_MASK=0000 keeps the strict no-effect path and skips this operation-specific selector check.

## Examples

- BSTART.SFU TROWEXPANDADD, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
