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
**Why use it.** `TSHUF` moves raw 32-bit word groups among rows inside independent power-of-two CUBE segments, avoiding a separate predicate or numerical conversion step.

<!-- PTO-READER-BLOCK: tile-tshuf-mechanism role=mechanism -->
**How it works.** The scalar control selects `UP`, `DOWN`, `BFLY`, or `IDX`; each `U32` control Tile word supplies its row operand in bits `[4:0]`, while bits `[31:5]` are accepted and ignored; the boundary choice keeps the current word (`SELF`) or writes zero (`ZERO`) when the selected row is unavailable.

<!-- PTO-READER-BLOCK: tile-tshuf-inputs-outputs role=inputs-outputs -->
**Inputs and result.** `source` and the fresh `destination` share a supported non-64-bit dtype, Local `CUBE_M16` or `CUBE_M32` layout, and geometry; the Local `U32` `controls` Tile matches their layout, valid rows, and CUBE CELL count, while its valid columns equal the number of 32-bit word groups in each data row.

<!-- PTO-READER-BLOCK: tile-tshuf-effects role=effects -->
**Effects.** Source and control Tiles are snapshotted before the complete valid destination region is published; both inputs persist, destination padding is `Null`, and the operation has no memory effect.

<!-- PTO-READER-BLOCK: tile-tshuf-constraints role=constraints -->
**What is rejected.** Scalar controls with `mode > 3`, `segment_code > 4`, `boundary > 1`, or nonzero bits `63:32` reject, as do unsupported dtype or layout, undefined input data, mismatched geometry, and destination aliasing; segment width `32` is available only with `CUBE_M32`.

<!-- PTO-READER-BLOCK: tile-tshuf-example role=example -->
**Concrete example.** In `BFLY` mode with segment width `16` and per-row operand `1`, source rows `[1, 2, 3, 4]` publish `[2, 1, 4, 3]` for the corresponding word group.
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
    return TileCubeDataTypeSupported(data_type) &&
           TileElementBits(data_type) != 64;
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

- TSHUF accepts Local CUBE_M16 or CUBE_M32 data and U32 control Tiles with matching geometry.
- The control word selects UP, DOWN, BFLY, or IDX; segment and boundary fields are checked before execution.
- Raw 32-bit words are shuffled without byte permutation.

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
