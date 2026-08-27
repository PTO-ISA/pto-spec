<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TUNPACK.asl -->
# TUNPACK

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TUNPACK.asl`

Extract and zero-extend a raw byte field from Local U32 CUBE words.

## Normative identity {#PTO-INST-TILE-TUNPACK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tunpack-purpose role=purpose -->
**使用场景。** `TUNPACK` 从每个 Local `U32` CUBE 字中提取一个连续的原始字节字段，并将该字段放入零扩展的 `U32` 结果中。

<!-- PTO-READER-BLOCK: tile-tunpack-mechanism role=mechanism -->
**工作方式。** 控制值的低字节给出源字节偏移，下一字节给出字节数；选中的字节向下复制到目标的第零字节位置，而结果的所有更高位保持为零。

<!-- PTO-READER-BLOCK: tile-tunpack-inputs-outputs role=inputs-outputs -->
**输入与结果。** `source` 是 Local `U32` `CUBE_M16` 或 `CUBE_M32` Tile，`unpack_control` 选择字段，`destination` 是具有匹配布局与几何形状的新 Local `U32` Tile。

<!-- PTO-READER-BLOCK: tile-tunpack-effects role=effects -->
**效果。** 控制信息与源数据校验先于完整定义的目标有效区域发布；源 Tile 保持不变，目标填充为 `Null`，且该操作不产生内存效果。

<!-- PTO-READER-BLOCK: tile-tunpack-constraints role=constraints -->
**拒绝条件。** 偏移必须在 `0` 到 `3` 之间，字节数必须在 `1` 到 `4` 之间，两者之和不得超过 `4`，控制位 `63:32` 必须为零，并且源与目标不得重叠；拒绝不会产生目标效果。

<!-- PTO-READER-BLOCK: tile-tunpack-example role=example -->
**具体示例。** 源字 `0x44332211` 与控制值 `0x00000201` 选择从字节偏移 `1` 开始的两个字节，得到 `0x00003322`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `layout-and-rearrangement`
- **Execution engine:** `SFU`

## Assembly

```asm
TUNPACK <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TUNPACK | TEPL | 0x078 | 24 | 3 | TUNPACK |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| scalar0 | unpack-control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/layout-and-rearrangement/layout/TUNPACK.asl -->
```asl
readonly func InstructionContractOperation_TUNPACK() => TileOperation
begin
    return TileOperation_TUNPACK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TUNPACK, U32
B.DATR Layout (optional)
B.DIM LB0/LB1/LB2 (optional)
B.IOT source, ->destination
B.IOR unpack_control
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/layout-and-rearrangement/layout/TUNPACK.asl -->
```asl
readonly func InstructionContractHandler_TUNPACK() => TileSemanticHandler
begin
    return TileHandler_TUNPACK;
end;

pure func InstructionContractDataTypeLegal_TUNPACK(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U32;
end;

readonly func InstructionContractOperandsLegal_TUNPACK(
    destination: TileIndex, source: TileIndex, control: Word) => boolean
begin
    return TileOperandsLegal_TUNPACK(destination, source, control);
end;

func InstructionContractExecute_TUNPACK(
    destination: TileIndex, source: TileIndex, control: Word)
begin
    assert InstructionContractOperandsLegal_TUNPACK(destination, source, control);
    TUNPACK(destination, source, control);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- A nonzero PE mask requires exactly one B.IOR control input; RegSrc1, RegSrc2, and RegDst are zero.

## Legality

- TUNPACK accepts only Local U32 CUBE_M16 or CUBE_M32 sources and a fresh matching destination.
- The control selects one contiguous byte field with offset 0..3 and count 1..4 within a U32 word.
- The result is zero-extended raw extraction.

## State effects

- Extract and zero-extend one byte field in each active CUBE word group.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Control and source validation precede destination publication.

## Exceptions

- Illegal offset/count fields reject with Fault_TileLegality before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior.

## Examples

- BSTART.SFU TUNPACK, U32; B.DATR Layout; B.DIM LB0; B.IOT source, ->destination; B.IOR a0; BSTOP
