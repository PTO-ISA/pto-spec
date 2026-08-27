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
**使用场景。** `TSHUF` 在彼此独立、宽度为二次幂的 CUBE CELL 分段内跨行移动原始 32 位字组，无需另设谓词步骤或数值转换步骤。

<!-- PTO-READER-BLOCK: tile-tshuf-mechanism role=mechanism -->
**工作方式。** 标量控制值选择 `UP`、`DOWN`、`BFLY` 或 `IDX`；每个 `U32` 控制 Tile 字通过位 `[4:0]` 提供其行操作数，而位 `[31:5]` 会被接受但忽略；当所选行不可用时，边界选项决定保留当前字（`SELF`）还是写入零（`ZERO`）。

<!-- PTO-READER-BLOCK: tile-tshuf-inputs-outputs role=inputs-outputs -->
**输入与结果。** `source` 与新的 `destination` 采用相同的受支持非 64 位 dtype、Local `CUBE_M16` 或 `CUBE_M32` 布局及几何形状；Local `U32` `controls` Tile 与两者具有相同的布局、有效行数和 CUBE CELL 数，而其有效列数等于每个数据行中 32 位字组的数量。

<!-- PTO-READER-BLOCK: tile-tshuf-effects role=effects -->
**效果。** 源 Tile 与控制 Tile 均在完整目标有效区域发布前完成快照；两个输入保持不变，目标填充为 `Null`，且该操作不产生内存效果。

<!-- PTO-READER-BLOCK: tile-tshuf-constraints role=constraints -->
**拒绝条件。** 标量控制值中 `mode > 3`、`segment_code > 4`、`boundary > 1` 或位 `63:32` 非零时会被拒绝；不受支持的 dtype 或布局、未定义的输入数据、几何形状不匹配以及目标重叠同样会被拒绝。分段宽度 `32` 仅适用于 `CUBE_M32`。

<!-- PTO-READER-BLOCK: tile-tshuf-example role=example -->
**具体示例。** 在 `BFLY` 模式下，分段宽度为 `16`、逐行操作数为 `1` 时，源行 `[1, 2, 3, 4]` 为对应字组发布结果 `[2, 1, 4, 3]`。
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
