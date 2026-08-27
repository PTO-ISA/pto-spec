<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TPERMUTE.asl -->
# TPERMUTE

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TPERMUTE.asl`

Permute raw bytes from two Local CUBE sources by a Local U8 index Tile.

## Normative identity {#PTO-INST-TILE-TPERMUTE}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tpermute-purpose role=purpose -->
**使用场景。** `TPERMUTE` 在每个 CUBE CELL 内提供一个双源字节表，使每个有效目标字节都能独立选择，而无需对载荷作数值解释。

<!-- PTO-READER-BLOCK: tile-tpermute-mechanism role=mechanism -->
**工作方式。** 查找在每个 CUBE CELL 处重新开始：对于 `CUBE_M32`，每个源的表宽为 `4` 字节；对于 `CUBE_M16`，表宽为 `8` 字节。小于该宽度的索引选择 `source0` 中同一 CELL 的字节，随后相同大小的索引范围选择 `source1` 中同一 CELL 的字节。

<!-- PTO-READER-BLOCK: tile-tpermute-inputs-outputs role=inputs-outputs -->
**输入与结果。** 两个 Local 数据源采用相同的受支持非 64 位 dtype、CUBE 布局和几何形状；匹配的 Local `U8` 索引 Tile 为每个有效目标字节提供一个索引，目标则是新 Tile。

<!-- PTO-READER-BLOCK: tile-tpermute-effects role=effects -->
**效果。** 所有索引及其选中的源字节均在完整目标有效区域发布前完成校验和读取；源 Tile 与索引 Tile 保持不变，目标填充为 `Null`，且该操作不产生内存效果。

<!-- PTO-READER-BLOCK: tile-tpermute-constraints role=constraints -->
**拒绝条件。** 每个索引必须小于每个 CELL 的合并边界：`CUBE_M32` 为 `8`，`CUBE_M16` 为 `16`。索引越界、选中的字节未定义、布局、dtype 或几何形状不匹配、索引 Tile 与任一源重叠，或目标与任一输入重叠，都会在目标产生任何效果前被拒绝。

<!-- PTO-READER-BLOCK: tile-tpermute-example role=example -->
**具体示例。** 对于一个 `CUBE_M32` 行，源字分别为 `0x04030201` 和 `0x08070605` 时，字节索引 `[0, 4, 1, 5]` 生成目标字 `0x06020501`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TPERMUTE <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TPERMUTE | TEPL | 0x075 | 21 | 3 | TPERMUTE |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source0 |
| source1 | source1 |
| source2 | indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TPERMUTE.asl -->
```asl
readonly func InstructionContractOperation_TPERMUTE() => TileOperation
begin
    return TileOperation_TPERMUTE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TPERMUTE, DataType
B.DATR Layout (optional)
B.DIM LB0/LB1/LB2 (optional)
B.IOT source0, source1
B.IOT indices, ->destination
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TPERMUTE.asl -->
```asl
readonly func InstructionContractHandler_TPERMUTE() => TileSemanticHandler
begin
    return TileHandler_TPERMUTE;
end;

pure func InstructionContractDataTypeLegal_TPERMUTE(
    data_type: TileDataType) => boolean
begin
    return TileCubeDataTypeSupported(data_type) &&
           TileElementBits(data_type) != 64;
end;

readonly func InstructionContractOperandsLegal_TPERMUTE(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, indices: TileIndex) => boolean
begin
    return TileOperandsLegal_TPERMUTE(destination, source0, source1, indices);
end;

func InstructionContractExecute_TPERMUTE(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, indices: TileIndex)
begin
    assert InstructionContractOperandsLegal_TPERMUTE(
        destination, source0, source1, indices);
    TPERMUTE(destination, source0, source1, indices);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.DATR has no effect other than selecting CUBE_M16 or CUBE_M32; padding and numeric fields remain zero.
- A nonzero PE mask requires two ordered B.IOT bindings and no B.IOR.

## Legality

- TPERMUTE accepts only Local CUBE_M16 or CUBE_M32 data Tiles with matching dtype and geometry.
- indices is Local U8 with the same CUBE layout and supplies one byte index for every valid destination byte.
- The destination is fresh; source0 and source1 may alias, while indices is distinct from both sources.
- Raw bytes are rearranged without numerical conversion.

## State effects

- Perform per-row two-source raw-byte table lookup and publish only the destination valid region.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- All index legality and source reads precede destination publication.

## Exceptions

- Illegal raw indices reject before any destination effect with Fault_TileLegality.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior.

## Examples

- BSTART.SFU TPERMUTE, U32; B.DATR Layout; B.IOT source0, source1; B.IOT indices, ->destination; BSTOP
