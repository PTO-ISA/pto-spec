<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TPACK.asl -->
# TPACK

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TPACK.asl`

Pack two low-order raw byte fields into Local U32 CUBE words.

## Normative identity {#PTO-INST-TILE-TPACK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tpack-purpose role=purpose -->
**使用场景。** `TPACK` 将两个对应的 Local `U32` CUBE 字中的低位字节字段拼接起来，适用于按原始存储形式重排字段而不进行数值转换的场景。

<!-- PTO-READER-BLOCK: tile-tpack-mechanism role=mechanism -->
**工作方式。** 对于每个活动字位置，`source0` 中选定的低位字节占据目标的低位字节，`source1` 中选定的低位字节紧随其后，目标中其余所有位均为零。

<!-- PTO-READER-BLOCK: tile-tpack-inputs-outputs role=inputs-outputs -->
**输入与结果。** `source0` 和 `source1` 是布局与几何形状匹配的 Local `U32` `CUBE_M16` 或 `CUBE_M32` Tile，`pack_control` 提供两个字段宽度，`destination` 是具有匹配布局与几何形状的新 Tile。

<!-- PTO-READER-BLOCK: tile-tpack-effects role=effects -->
**效果。** 完整的控制信息与源数据校验先于完整定义的目标有效区域发布；源 Tile 保持不变，目标填充为 `Null`，且该操作不产生内存效果。

<!-- PTO-READER-BLOCK: tile-tpack-constraints role=constraints -->
**拒绝条件。** 每个字段宽度必须在 `1` 到 `3` 之间，两者之和不得超过 `4`，控制位 `63:32` 必须为零，并且目标不得与任一源重叠；任何拒绝都发生在目标产生效果之前。

<!-- PTO-READER-BLOCK: tile-tpack-example role=example -->
**具体示例。** 对于对应的源字 `0x00001234` 和 `0x00ABCDEF`，控制值 `0x00000202` 从每个源中选择两个低位字节，得到 `0xCDEF1234`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TPACK <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TPACK | TEPL | 0x077 | 23 | 3 | TPACK |

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
| scalar0 | pack-control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TPACK.asl -->
```asl
readonly func InstructionContractOperation_TPACK() => TileOperation
begin
    return TileOperation_TPACK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TPACK, U32
B.DATR Layout (optional)
B.DIM LB0/LB1/LB2 (optional)
B.IOT source0, source1, ->destination
B.IOR pack_control
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TPACK.asl -->
```asl
readonly func InstructionContractHandler_TPACK() => TileSemanticHandler
begin
    return TileHandler_TPACK;
end;

pure func InstructionContractDataTypeLegal_TPACK(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U32;
end;

readonly func InstructionContractOperandsLegal_TPACK(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, control: Word) => boolean
begin
    return TileOperandsLegal_TPACK(destination, source0, source1, control);
end;

func InstructionContractExecute_TPACK(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, control: Word)
begin
    assert InstructionContractOperandsLegal_TPACK(
        destination, source0, source1, control);
    TPACK(destination, source0, source1, control);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- A nonzero PE mask requires exactly one B.IOR control input; RegSrc1, RegSrc2, and RegDst are zero.

## Legality

- TPACK accepts only Local U32 CUBE_M16 or CUBE_M32 sources and a fresh matching destination.
- The control selects two low-order byte fields with widths 1..3 whose sum is at most four.
- The result is raw zero-filled field assembly with no numeric conversion.

## State effects

- Pack corresponding source U32 words independently in every active CUBE word group.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Control and source validation precede destination publication.

## Exceptions

- Illegal field widths reject with Fault_TileLegality before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior.

## Examples

- BSTART.SFU TPACK, U32; B.DATR Layout; B.IOT source0, source1, ->destination; B.IOR a0; BSTOP
