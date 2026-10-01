<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TUNPACK.asl -->
# TUNPACK

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TUNPACK.asl`

Extract selected byte fields from 8/16/32-bit Local CUBE source carriers into U8/U16/U32 destination words.

## Normative identity {#PTO-INST-TILE-TUNPACK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tunpack-purpose role=purpose -->
## TUNPACK 的作用

`TUNPACK` 从 Local CUBE 源的每个参与的 32 位字中提取一个连续的字节字段，并把它放入目标字的低字节。它重排原始字节，不执行任何数值转换。

设计要点：`TUNPACK` 由 `BSTART.SFU` 以 TEPL Mode 3 Function 24（选择器 `0x078`）选中。`BSTART` 类型 `U8`、`U16` 或 `U32` 是目标类型；源后备类型不必与之相同。

<!-- PTO-READER-BLOCK: tile-tunpack-mechanism role=mechanism -->
## 提取规则

控制字在位 7 到 0 给出字节偏移，在位 15 到 8 给出字节数。对每行的第 w 个字，目标字节 0 到 count-1 接收从 `4w + offset` 开始的源字节，其余每个目标字节为零。

设计要点：跨度规则对每个字都检查，包括部分的最后一个字，无论 ExecutionMask 是否使其为活动。`offset + count` 必须落在每个字的有效字节之内，因此字段绝不会读到行的有效数据之外。

只读取被选中的字节，参与的字中每个被选字节都必须属于已定义的元素。未选中的有效字节与物理填充从不被读取。

<!-- PTO-READER-BLOCK: tile-tunpack-inputs-outputs role=inputs-outputs -->
## 输入与结果

- `source0` 是 Local 数值 `CUBE_M16` 或 `CUBE_M32` Tile，元素为非打包的 8、16 或 32 位。
- `scalar0` 是来自一条 `B.IOR` 的解包控制字；RegSrc1、RegSrc2 与 RegDst 为零。
- `destination0` 是新的，类型为 `BSTART` 类型，布局与有效行与源相同，有效列数为 `words per row x elements per word`：`U8` 为 4，`U16` 为 2，`U32` 为 1。

与 `TPACK` 相同，目标形状由源描述符推导，而不是来自 `B.DIM`。

<!-- PTO-READER-BLOCK: tile-tunpack-effects role=effects -->
## 效果

控制与源验证都在发布之前完成。每个参与的源字产生一个完整的目标字，每个有效目标元素都变为已定义，填充为 `Null`。

存在 ExecutionMask 时，位于 (row, word index) 的一个掩码位控制整个目标字组；非活动组不读取任何源字节，并接收该掩码规定的零值或合并值。源保持不变，该操作没有内存或数值状态效果。

<!-- PTO-READER-BLOCK: tile-tunpack-constraints role=constraints -->
## 被拒绝的情况

偏移必须为 0 到 3，字节数为 1 到 4，且 `offset + count` 不超过 4；控制位 `63:32` 必须为零。不支持的存储、布局或源位宽、字段超出某个字的有效字节、目标与源别名，或被选字节未定义，都会在任何效果之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: tile-tunpack-example role=example -->
## 具体示例

源字 `0x44332211` 与控制值 `0x00000201` 选择从字节偏移 `1` 开始的两个字节，即 `0x22` 与 `0x33`。目标字为 `0x00003322`。

一个有 6 个有效列的 `U8` `CUBE_M16` 源每行有 6 个有效字节：字 0 有 4 个，字 1 有 2 个。控制值 `0x00000200`（偏移 0，字节数 2）合法，`U16` 目标得到 2 x 2 = 4 个有效列。控制值 `0x00000201` 会被拒绝，因为偏移 1 加字节数 2 超过了字 1 的 2 个有效字节。

```text
TUNPACK <U16>, T#1, a0, ->T<128B>
```
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
BSTART.SFU TUNPACK, U8/U16/U32
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
    return data_type == TileDataType_U8 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_U32;
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

- TUNPACK accepts Local Numeric CUBE_M16 or CUBE_M32 source backing with non-packed 8/16/32-bit elements.
- BSTART selects exactly U8, U16, or U32 for the fresh destination. The control selects a contiguous byte field within each independent 32-bit source word.
- Only selected source bytes are read. Every selected interval is inside its word logical valid-byte span and every selected byte has a defined containing element; each participating word produces one complete zero-filled destination word.

## State effects

- Extract the selected byte field independently from each participating 32-bit raw-word slot, zero-fill the remainder, and publish one complete destination word per source word.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Control and source validation precede destination publication.

## Exceptions

- Unsupported storage, layout, or backing width; a selected interval outside a source word logical valid-byte span; an undefined selected byte; or illegal offset/count fields reject with Fault_TileLegality before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior.

## Examples

- BSTART.SFU TUNPACK, U8/U16/U32; B.DATR Layout; B.DIM LB0; B.IOT source, ->destination; B.IOR a0; BSTOP
