<!-- GENERATED FROM: asl/tile/irregular-and-complex/layout/TSCATTER.asl -->
# TSCATTER

**Normative ASL source:** `asl/tile/irregular-and-complex/layout/TSCATTER.asl`

Scatter values to distinct destination rows selected independently at each source coordinate.

## Normative identity {#PTO-INST-TILE-TSCATTER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tscatter-purpose role=purpose -->
## TSCATTER 的作用

`TSCATTER` 把每个源元素写入由索引 Tile 选择的目标行。列从不改变：源 `[r,c]` 写到目标 `[index[r,c], c]`。没有被任何索引选中的行保存零。

设计要点：`TSCATTER` 由 `BSTART.SFU` 以 TEPL Mode 3 Function 16（选择器 `0x070`）选中，没有独立 opcode。

<!-- PTO-READER-BLOCK: tile-c-tscatter-mechanism role=mechanism -->
## 操作机制

首先，每个物理目标元素（包括填充）都被设为值类型的全零载体，并标记为已定义。除 `E8M0`、`E6M2` 与 `RCPE6M2`（它们没有零编码）外，该载体就是正零或整数零。随后每个源元素被逐位复制到其所选目标元素。不读取任何先前的目标值。

设计要点：两个源坐标不得选择同一个目标元素。重复会被拒绝而不是按顺序处理，因此结果不依赖于访问源元素的顺序。

设计要点：所有索引都在任何写入之前检查。负索引、大于等于目标 ValidRow 的索引或重复的目标坐标都会拒绝该指令束，因此错误索引绝不会留下部分结果。[索引重排执行](../../model/execution/indexed-rearrangement.md)描述了这两个步骤。

<!-- PTO-READER-BLOCK: tile-c-tscatter-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `source0` 是持久的 Local 值源。
- `source1` 是持久的 Local 行索引源，类型为 `S16`、`U16`、`S32`、`U32`、`S64` 或 `U64`。
- `destination0` 是新分配并以零初始化的值目标。

值类型可以是任何非打包的 8、16、32 或 64 位类型：`FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`HiF8`、`E4M3`、`E5M2`、`E3M2`、`E2M3`、`E8M0`、`E6M2`、`RCPE6M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16` 或 `U8`。

两个源共用一个非零有效形状。目标 ValidCol 来自 `B.DIM` LB0，必须等于源 ValidCol；省略 LB0 时取架构默认值一，显式编码的零非法。目标 ValidRow 来自 LB1，默认为 1，可以不同于源 ValidRow。LB2 默认为 Col = ValidCol。

一条终止 `B.IOT` 同时携带两个源与目标；`B.IOS` 非法，任何选择子不全为零的 `B.IOR` 也非法（显式全零 `B.IOR` 只命名 GPR0，不消耗操作数，因此被接受）。三个操作数都必须通过通用描述符检查，该检查排除 CUBE 布局。`B.DATR` 只能携带 `Layout`；其编码为零的 `PadValueOrByteId` 表示类型化零初始化。

<!-- PTO-READER-BLOCK: tile-c-tscatter-effects role=effects -->
## 已定义性、填充与发布

两个源在完整预检之后、零初始化之前被快照。随后完整的目标载荷、物理已定义性与描述符作为一次操作发布。

每个物理目标元素都是已定义的，包括没有被任何索引选中的行以及有效区域之外的填充；它们都保存该值类型的全零载体。这与 `TGATHER` 不同，后者的填充保持未定义。

源 Tile 保持不变。`TSCATTER` 没有全局内存效果，不记录数值状态。

<!-- PTO-READER-BLOCK: tile-c-tscatter-constraints role=constraints -->
## 合法性、故障与顺序边界

绑定格式错误、`B.IOR`、`B.IOS`、不支持的值或索引类型、源形状为零或不匹配、目标列不匹配、索引为负或越界、目标坐标重复、源未定义、保留的 `Layout`，或目标容量不足，会在任何效果之前引发相应的 Tile 故障。

三个绑定使用相同的 `PE_MASK`；三位 PEMode 只能编码 `1000`、`0100`、`0010`、`0001`、`1100`、`1110`、`1111` 与 `0000`。`PE_MASK=0000` 在 `B.IOT` 的 size code 编码检查之后是严格无操作：不再进行 Tile 读取、索引与重复检查、分配、零初始化或操作故障，但非法的 `B.IOT` size code 仍会引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: tile-c-tscatter-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

U32 值源第 0 行保存 5、6，第 1 行保存 7、8。索引各行为 2、0 与 0、1。目标有 3 个有效行、2 个有效列。

第 0 列在第 2 行接收 5，在第 0 行接收 7。第 1 列在第 0 行接收 6，在第 1 行接收 8。目标各行为 7、6；然后 0、8；然后 5、0。若索引各行改为 2、0 与 2、1，则会拒绝该指令束，因为第 0 列的两个元素都选择了第 2 行。

以宏形式表示，以 `T#1` 为值源、`T#2` 为索引 Tile 的 8 x 16 U32 scatter 写作下面的形式。目标容纳 8 x 16 x 4 = 512 字节。

```text
TSCATTER <Row=8, Col=16, U32>, T#1, T#2, ->T<512B>
```
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TSCATTER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSCATTER | TEPL | 0x070 | 16 | 3 | TSCATTER |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new zero-initialized Local value destination |
| source0 | persistent Local value source |
| source1 | persistent Local S16, U16, S32, U32, S64, or U64 row-index source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/layout/TSCATTER.asl -->
```asl
readonly func InstructionContractOperation_TSCATTER() => TileOperation
begin
    return TileOperation_TSCATTER;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TSCATTER, ValueDataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT ValueSrc, IndexSrc, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/layout/TSCATTER.asl -->
```asl
readonly func InstructionContractOperandsLegal_TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    return TileOperandsLegal_TSCATTER(destination, source, indices);
end;

readonly func InstructionContractHandler_TSCATTER() => TileSemanticHandler
begin
    return TileHandler_TSCATTER;
end;

func InstructionContractExecute_TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    assert InstructionContractOperandsLegal_TSCATTER(
        destination,
        source,
        indices);
    TSCATTER(destination, source, indices);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero destination ValidCol; omitted LB1 selects destination ValidRow=1 and omitted LB2 selects physical Col=ValidCol.
- Omitted B.DATR retains row-major destination layout; an assigned legal Layout changes only destination physical placement. PadValueOrByteId is encoded zero and means typed positive or integer zero for this operation; every other B.DATR field remains zero.
- Before scatter writes, every physical destination element is initialized to the selected value DataType's positive or integer zero and is defined.

## Legality

- TSCATTER uses the TEPL encoding carrier Mode 3 Function 16, is canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent value source, one persistent row-index source, and one newly allocated destination; B.IOR and B.IOS are illegal.
- Every non-packed B8-NP, B16, B32, or B64 value pairs with every S16, U16, S32, U32, S64, or U64 index.
- The two sources have the same nonzero valid shape. Destination ValidCol equals source ValidCol and destination ValidRow is nonzero.
- Every signed index is nonnegative and every index is less than destination ValidRow. No two source coordinates may select the same destination coordinate [index[r,c],c].
- Both source valid rectangles are fully defined and validly encoded. All three bindings use the same PE_MASK; any nonzero subset is legal.

## State effects

- Initialize every physical destination coordinate to typed positive or integer zero.
- For every source coordinate [r,c], read k=index[r,c] and write source[r,c] bit-for-bit to destination[k,c].
- Both sources persist, no previous destination value is read, and rejection publishes no destination state.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, descriptor, type-pair, dimension, layout, capacity, index-range, duplicate-coordinate, and source-definedness preflight precedes source snapshots.
- Both sources are snapshotted before zero initialization and scatter evaluation; complete destination payload, physical definedness, and descriptor publish atomically.

## Exceptions

- Malformed bindings, B.IOR, B.IOS, unsupported value/index pair, zero or mismatched source shape, destination-column mismatch, negative or out-of-range index, duplicate destination coordinate, undefined source, invalid consumed encoding, reserved Layout, or insufficient destination capacity raises the applicable Tile fault before effects.
- PE_MASK=0000 is a strict no-op before Tile reads, index and duplicate checks, allocation, faults, zero initialization, or payload effects.

## Examples

- BSTART.SFU TSCATTER, U16; B.DIM LB0=2; B.DIM LB1=4; B.IOT ValueSrc, IndexSrc, mask=1111, <last>, ->Dst<2>; BSTOP
