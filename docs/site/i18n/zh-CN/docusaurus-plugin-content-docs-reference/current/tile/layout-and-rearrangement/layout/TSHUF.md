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
## TSHUF 的作用

`TSHUF` 在 Local `CUBE_M16` 或 `CUBE_M32` Tile 的行之间移动元素。每一行是 CUBE cell 的一个通道，通道被分成相互独立的 2 的幂大小的段。列从不改变。

设计要点：`TSHUF` 由 `BSTART.SFU` 以 TEPL Mode 3 Function 22（选择器 `0x076`）选中，没有独立 opcode。

<!-- PTO-READER-BLOCK: tile-tshuf-mechanism role=mechanism -->
## 洗牌规则

标量控制字在位 7 到 0 给出模式，在位 15 到 8 给出段代码，在位 23 到 16 给出边界标志。段代码 0 到 4 选择宽度 2、4、8、16 与 32。

第 r 行的通道是 r 对 cell 行数（16 或 32）取模。对每个元素，5 位值 b 来自覆盖该元素的控制 Tile 字的位 4 到 0。在段内，模式 0 读取通道 `lane - b`，模式 1 读取 `lane + b`，模式 2 读取 `segment base + (local lane XOR b)`，模式 3 读取 `segment base + (b mod width)`。

当候选通道离开该段，或其所在行大于等于源 ValidRow 时，边界 0 保留元素自身行的值，边界 1 写入零。

设计要点：一行中每个 32 位字由一个控制字覆盖，因此打包在该字中的所有元素按同一个 b 移动。于是该操作在行之间洗牌原始 32 位字，从不在字内部置换字节。

<!-- PTO-READER-BLOCK: tile-tshuf-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

- `source0` 是数据源：数值 `CUBE_M16` 或 `CUBE_M32` Tile；64 位载体要求 `CUBE_M32`。 64 位 CUBE 操作数要求 `CUBE_M32` double-CELL 映射；`CUBE_M16` 会拒绝。
- `source1` 是控制 Tile：`U32`，布局与有效行相同，源行的每个 32 位字对应一个有效列，cell 数量相同。
- `scalar0` 是来自一条 `B.IOR` 的控制字；RegSrc1、RegSrc2 与 RegDst 为零。
- `destination0` 是新的，保持源类型、有效形状与布局。它必须不同于源与控制 Tile。

`B.DATR` 只能携带 `Layout`。控制字的位 63 到 32 必须为零。

<!-- PTO-READER-BLOCK: tile-tshuf-effects role=effects -->
## 效果

源与控制快照都在发布之前完成。每个有效目标元素都变为已定义，有效区域之外的物理元素接收 `Null` 填充并保持未定义。

存在 ExecutionMask 时，非活动元素不读取任何控制字或源元素，并接收该掩码规定的零值或合并值。源保持不变，该操作没有内存或数值状态效果。

<!-- PTO-READER-BLOCK: tile-tshuf-constraints role=constraints -->
## 被拒绝的情况

模式大于 3、边界大于 1、段代码大于 4、`CUBE_M16` 下的段代码 4、控制字位 63 到 32 非零、描述符不匹配、目标别名、控制字未定义，或将被读取的源元素未定义，都会在任何效果之前引发 `Fault_TileLegality`。

设计要点：只对实际将被读取的元素检查已定义性。边界为 1 时，越出段的元素写入零且不读取任何内容，因此没有任何通道选中的未定义元素不会使该指令束非法。

<!-- PTO-READER-BLOCK: tile-tshuf-example role=example -->
## 具体示例

一个 `U32` `CUBE_M16` 源有 4 个有效行、1 个有效列，保存 1、2、3、4。每个控制 Tile 字的 b = 1。控制字 `0x00000302` 选择模式 2、宽度 16 与边界 0。

模式 2 按与 1 异或来配对通道，因此目标列为 2、1、4、3。模式 1 且边界为 1（`0x00010301`）时，每行读取下一行：第 3 行将读取第 4 行，而它超出了 4 个有效行，因此结果为 2、3、4、0。边界为 0（`0x00000301`）时，第 3 行保留自身的值，结果为 2、3、4、4。

以宏形式表示，`T#1` 是数据源，`T#2` 是控制 Tile，`a0` 保存控制字：

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
