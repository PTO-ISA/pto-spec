<!-- GENERATED FROM: asl/tile/layout-and-rearrangement/layout/TPACK.asl -->
# TPACK

**Normative ASL source:** `asl/tile/layout-and-rearrangement/layout/TPACK.asl`

Pack selected raw byte prefixes from 8/16/32-bit and M32 64-bit Local CUBE source carriers into U8/U16/U32/U64 destination words.

## Normative identity {#PTO-INST-TILE-TPACK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tpack-purpose role=purpose -->
## TPACK 的作用

`TPACK` 把两个 Local CUBE 源中对应 32 位字的低字节字段拼接成一个目标字。它重排原始字节，不执行任何数值转换。

设计要点：`TPACK` 由 `BSTART.SFU` 以 TEPL Mode 3 Function 23（选择器 `0x077`）选中。`BSTART` 类型 `U8`、`U16`、`U32` 或 `U64` 是目标类型；它不必与源类型一致。

<!-- PTO-READER-BLOCK: tile-tpack-mechanism role=mechanism -->
## 打包规则

每个源行按原始字读取：该行的有效字节数 `ValidCol x element bits / 8`（向上取整）被分组为 32 位字，最后一个字可以是部分字。

控制字在位 7 到 0 给出 n0，在位 15 到 8 给出 n1。对每行的第 w 个字，目标字节 0 到 n0-1 接收 `source0` 第 w 个字的低 n0 个字节，接下来的 n1 个字节接收 `source1` 第 w 个字的低 n1 个字节，其余每个目标字节为零。

设计要点：只读取被选中的字节。参与的字中每个被选字节必须位于其字的有效字节内，并属于已定义的元素；未选中的字节（包括物理填充）从不被读取，因此它们的已定义性无关紧要。

<!-- PTO-READER-BLOCK: tile-tpack-inputs-outputs role=inputs-outputs -->
## 输入与结果

- `source0` 与 `source1` 是 Local 数值 CUBE Tile，元素为非打包 8、16、32 位或 M32 64 位。它们共用一个布局、相同有效行数与每行相同 raw 32 位 word 数；类型可以不同。
- `scalar0` 是来自一条 `B.IOR` 的打包控制字；RegSrc1、RegSrc2 与 RegDst 为零。
- `destination0` 是新的。U8/U16/U32 每个 raw word 分别生成 4/2/1 个元素。U64 要求 `CUBE_M32`、偶数 raw-word 数以及每个完整低/高 pair 一个逻辑列。

设计要点：目标形状由源描述符推导，而不是来自 `B.DIM`。因此宏形式没有形状字段，静态反汇编器无法打印 Row 或 Col。

<!-- PTO-READER-BLOCK: tile-tpack-effects role=effects -->
## 效果

控制与源验证都在发布之前完成。每对源字产生一个完整的目标字，每个有效目标元素都变为已定义，填充为 `Null`。

存在 ExecutionMask 时，raw word 分别受控。对 U64，低、高 word 掩码位可以不同；每个活动半部独立打包，两个半部再合成一个一致的 64 位发布，非活动半部由 ZERO 或 MERGE 提供。

<!-- PTO-READER-BLOCK: tile-tpack-constraints role=constraints -->
## 被拒绝的情况

每个字段宽度必须在 `1` 到 `3` 之间，两者之和不得超过 `4`，控制位 `63:32` 必须为零。不支持的存储、布局或源位宽、字数不相等、目标与源别名，或被选字节未定义，同样会在任何目标效果之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: tile-tpack-example role=example -->
## 具体示例

对于对应的源字 `0x00001234` 与 `0x00ABCDEF`，控制值 `0x00000202` 从每个源中选择两个低字节。目标字节为 `0x34`、`0x12`、`0xEF`、`0xCD`，即字 `0xCDEF1234`。

当 `U32` `CUBE_M16` 源有 8 个有效行、8 个有效列时，每行有 32 字节，即 8 个字。因此 `U32` 目标有 8 个有效行、8 个有效列；`U16` 目标则有 16 个有效列。

```text
TPACK <U32>, T#1, T#2, a0, ->T<2KB>
```
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
BSTART.SFU TPACK, U8/U16/U32/U64
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
    return data_type == TileDataType_U8 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U64;
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

- TPACK accepts Local Numeric CUBE_M16 or CUBE_M32 source backing with non-packed 8/16/32-bit or M32 64-bit elements; source layouts and valid rows match and RawWordSlotsPerRow is equal.
- BSTART selects U8, U16, U32, or U64 for the fresh destination. The control selects low-byte prefixes of 1..3 bytes per source word with total width at most four.
- Only selected source bytes are read. Each selected byte is logically valid and its containing element is defined; each paired 32-bit word produces one zero-filled result word; U64 joins complete low/high pairs and rejects odd tails.

## State effects

- Pair corresponding 32-bit raw-word slots independently in each row, assemble the selected low-byte prefixes, and zero every unselected destination byte.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Control and source validation precede destination publication.

## Exceptions

- Unsupported storage, layout, or backing width; unequal raw-word counts; an out-of-span or undefined selected byte; or illegal field widths reject with Fault_TileLegality before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior.

## Examples

- BSTART.SFU TPACK, U8/U16/U32/U64; B.DATR Layout; B.IOT source0, source1, ->destination; B.IOR a0; BSTOP
