<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TSHUF.asl -->
# TSHUF

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TSHUF.asl`

Shuffle raw 32-bit words across Local CUBE rows with an explicit control GPR.

## Normative identity {#PTO-INST-TILE-TSHUF}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tshuf-purpose role=purpose -->
## What TSHUF does

`TSHUF` moves elements between rows of a Local `CUBE_M16` or `CUBE_M32` Tile. Each row is a lane of a CUBE cell, and lanes are grouped into independent power-of-two segments. The column never changes.

Design point: `TSHUF` is selected by `BSTART.SFU` with TEPL Mode 3 Function 22 (selector `0x076`) and has no standalone opcode.

<!-- PTO-READER-BLOCK: tile-tshuf-mechanism role=mechanism -->
## Shuffle rule

The scalar control word gives the mode in bits 7 to 0, the segment code in bits 15 to 8, and the boundary flag in bits 23 to 16. Segment codes 0 to 4 select widths 2, 4, 8, 16, and 32.

The lane of row r is r modulo the cell rows, 16 or 32. For each element, a 5-bit value b comes from bits 4 to 0 of the control Tile word that covers that element. Within the segment, mode 0 reads lane `lane - b`, mode 1 reads `lane + b`, mode 2 reads `segment base + (local lane XOR b)`, and mode 3 reads `segment base + (b mod width)`.

When the candidate lane leaves the segment or its row is at or beyond the source ValidRow, boundary 0 keeps the element's own row and boundary 1 writes zero.

Design point: one control word covers each 32-bit word of a row, so every element packed in that word moves by the same b. The operation therefore shuffles raw 32-bit words between rows, and it never permutes bytes inside a word.

<!-- PTO-READER-BLOCK: tile-tshuf-inputs-outputs role=inputs-outputs -->
## Operands and descriptors

- `source0` is the data source: a numeric `CUBE_M16` or `CUBE_M32` Tile; a 64-bit carrier requires `CUBE_M32`. A 64-bit CUBE operand requires the `CUBE_M32` double-CELL mapping; `CUBE_M16` rejects it.
- `source1` is the control Tile: `U32`, the same layout and valid rows, one valid column per 32-bit word of a source row, and the same cell count.
- `scalar0` is the control word from one `B.IOR`; RegSrc1, RegSrc2, and RegDst are zero.
- `destination0` is fresh and keeps the source type, valid shape, and layout. It must differ from the source and the control Tile.

`B.DATR` may carry only a `Layout`. Bits 63 to 32 of the control word must be zero.

<!-- PTO-READER-BLOCK: tile-tshuf-effects role=effects -->
## Effects

Source and control snapshots come before publication. Every valid destination element becomes defined, and physical elements outside the valid region receive `Null` padding, which stays undefined.

Under an ExecutionMask, an inactive element reads no control word or source element and receives the mask's zero or merge value. The sources persist, and the operation has no memory or numeric-status effect.

<!-- PTO-READER-BLOCK: tile-tshuf-constraints role=constraints -->
## What is rejected

A mode above 3, a boundary above 1, a segment code above 4, segment code 4 with `CUBE_M16`, nonzero control bits 63 to 32, a mismatched descriptor, an aliasing destination, an undefined control word, or an undefined source element that will be read raises `Fault_TileLegality` before effects.

Design point: definedness is checked only for the element that will actually be read. With boundary 1, an out-of-segment element writes zero and reads nothing, so an undefined element that no lane selects does not make the bundle illegal.

<!-- PTO-READER-BLOCK: tile-tshuf-example role=example -->
## Concrete example

A `U32` `CUBE_M16` source has 4 valid rows and 1 valid column holding 1, 2, 3, 4. Every control Tile word has b = 1. The control word `0x00000302` selects mode 2, width 16, and boundary 0.

Mode 2 pairs lanes by XOR with 1, so the destination column is 2, 1, 4, 3. With mode 1 and boundary 1 (`0x00010301`), each row reads the next row: row 3 would read row 4, which is beyond the 4 valid rows, so the result is 2, 3, 4, 0. With boundary 0 (`0x00000301`), row 3 keeps its own value and the result is 2, 3, 4, 4.

In macro form, `T#1` is the data source, `T#2` is the control Tile, and `a0` holds the control word:

```text
TSHUF <U32>, T#1, T#2, a0, ->T<128B>
```
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TSHUF <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSHUF | TEPL | 0x076 | 22 | 3 | TSHUF |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| source1 | controls |
| scalar0 | shuffle-control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TSHUF.asl -->
```asl
readonly func InstructionContractOperation_TSHUF() => TileOperation
begin
    return TileOperation_TSHUF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TSHUF, DataType
B.DATR Layout (optional)
B.DIM LB0/LB1/LB2 (optional)
B.IOT source, controls, ->destination
B.IOR shuffle_control
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TSHUF.asl -->
```asl
readonly func InstructionContractHandler_TSHUF() => TileSemanticHandler
begin
    return TileHandler_TSHUF;
end;

pure func InstructionContractDataTypeLegal_TSHUF(
    data_type: TileDataType) => boolean
begin
    return TileCubeDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TSHUF(
    destination: TileIndex, source: TileIndex,
    controls: TileIndex, control: Word) => boolean
begin
    return TileOperandsLegal_TSHUF(destination, source, controls, control);
end;

func InstructionContractExecute_TSHUF(
    destination: TileIndex, source: TileIndex,
    controls: TileIndex, control: Word)
begin
    assert InstructionContractOperandsLegal_TSHUF(
        destination, source, controls, control);
    TSHUF(destination, source, controls, control);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- A nonzero PE mask requires exactly one B.IOR control input; RegSrc1, RegSrc2, and RegDst are zero.

## Legality

- TSHUF accepts Local CUBE_M16 data and Local CUBE_M32 data, including FP64/S64/U64 and U32 control Tiles with matching geometry.
- The control word selects UP, DOWN, BFLY, or IDX; segment and boundary fields are checked before execution.
- Raw 32-bit words are shuffled without byte permutation; M32 64-bit low and high words use independent controls and publish coherently.

## State effects

- Perform independent PTX-style word shuffles for each active CUBE row/group.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Source and control snapshots precede destination publication.

## Exceptions

- Reserved control encodings reject with Fault_TileLegality before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior.

## Examples

- BSTART.SFU TSHUF, U32; B.DATR Layout; B.IOT source, controls, ->destination; B.IOR a0; BSTOP
