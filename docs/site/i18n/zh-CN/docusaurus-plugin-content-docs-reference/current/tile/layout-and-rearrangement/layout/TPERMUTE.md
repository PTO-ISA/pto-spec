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
## TPERMUTE 的作用

`TPERMUTE` 根据一个 `U8` 索引 Tile，从两个数据源的某个字节构建每个目标字节。它作用于 Local `CUBE_M16` 或 `CUBE_M32` Tile 的原始字节，不执行任何数值转换。

设计要点：`TPERMUTE` 由 `BSTART.SFU` 以 TEPL Mode 3 Function 21（选择器 `0x075`）选中，没有独立 opcode。

<!-- PTO-READER-BLOCK: tile-tpermute-mechanism role=mechanism -->
## 字节选择规则

cell 的行字节数在 `CUBE_M16` 下为 8，在 `CUBE_M32` 下为 4。每行的有效字节按该大小划分为段，每个目标字节读取同一行、同一字节位置上的一个索引字节。

小于行字节数的索引 v 选择 `source0` 的字节 `segment base + v`。从行字节数到两倍行字节数之间的索引选择 `source1` 的字节 `segment base + v - row bytes`。

设计要点：字节只能在本行、本段内移动。大于等于两倍行字节数的索引是非法的而不会回绕，因此每个被接受的索引都恰好指向一个源字节。

设计要点：每个活动目标字节都在任何效果之前检查：其索引字节必须已定义且在范围内，所选源字节必须已定义。错误索引以 `Fault_TileLegality` 拒绝，不留下部分目标。[布局重排合法性](../../model/legality/layout-rearrangement.md)拥有这些检查。

<!-- PTO-READER-BLOCK: tile-tpermute-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

- `source0` 与 `source1` 是数据源。它们与目标共用同一类型、有效形状与布局，并且可以是同一个 Tile。
- `source2` 是索引 Tile：`U8`，布局与有效行相同，每个有效目标字节对应一个有效列，cell 数量相同。它必须不同于两个数据源。
- `destination0` 是新的，保持源类型、有效形状与布局。它必须不同于每个源。

数据类型可以是除 64 位类型之外的任何 CUBE 类型。第一条 `B.IOT` 携带 `source0` 与 `source1`；第二条携带索引 Tile 与目标。只有当 GPR 携带 ExecutionMask 时才出现 `B.IOR`，`B.DATR` 只能携带 `Layout`。

<!-- PTO-READER-BLOCK: tile-tpermute-effects role=effects -->
## 效果

所有索引检查与源读取都在发布之前完成。每个有效目标元素都变为已定义，有效区域之外的物理元素接收 `Null` 填充并保持未定义。

存在 ExecutionMask 时，非活动目标元素不读取任何索引或源字节，并接收该掩码规定的零值或合并值。源保持不变，该操作没有内存或数值状态效果。

<!-- PTO-READER-BLOCK: tile-tpermute-constraints role=constraints -->
## 被拒绝的情况

非 CUBE_M16/M32 布局、64 位类型、类型、形状、布局或 cell 数量不匹配、索引 Tile 不是 `U8` 或与数据源别名、目标与源别名、索引越界或未定义，或所选源字节未定义，都会在任何目标效果之前引发 `Fault_TileLegality`。

绑定结构格式错误会引发 `Fault_BundleControl`；[cell 重排模式](../../../block/model/dispatch/cell-rearrangement-schema.md)拥有该检查。

<!-- PTO-READER-BLOCK: tile-tpermute-example role=example -->
## 具体示例

取一个 `U8` `CUBE_M32` 行，有 4 个有效字节，因此行字节数为 4，合法索引为 0 到 7。`source0` 保存字节 `0x01`、`0x02`、`0x03`、`0x04`（字 `0x04030201`），`source1` 保存 `0x05` 到 `0x08`（字 `0x08070605`）。

索引字节 `[0, 4, 1, 5]` 依次选择 `source0` 字节 0、`source1` 字节 0、`source0` 字节 1 与 `source1` 字节 1。目标字节为 `0x01`、`0x05`、`0x02`、`0x06`，即字 `0x06020501`。索引 8 会拒绝该指令束。

以宏形式表示，`T#1` 与 `T#2` 是数据源，`T#3` 是索引 Tile：

```text
TPERMUTE <U8>, T#1, T#2, T#3, ->T<128B>
```
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
