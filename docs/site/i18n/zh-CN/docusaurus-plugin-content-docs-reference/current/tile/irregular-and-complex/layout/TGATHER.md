<!-- GENERATED FROM: asl/tile/irregular-and-complex/layout/TGATHER.asl -->
# TGATHER

**Normative ASL source:** `asl/tile/irregular-and-complex/layout/TGATHER.asl`

Gather values from source rows selected independently at each destination coordinate.

## Normative identity {#PTO-INST-TILE-TGATHER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tgather-purpose role=purpose -->
## TGATHER 的作用

`TGATHER` 为每个目标元素读取由索引 Tile 选择的源行，从而构建一个新的 Local Tile。列从不改变：目标 `[r,c]` 接收源 `[index[r,c], c]`。

设计要点：`TGATHER` 由 `BSTART.SFU` 以 TEPL Mode 3 Function 15（选择器 `0x06F`）选中，没有独立 opcode。

<!-- PTO-READER-BLOCK: tile-tgather-mechanism role=mechanism -->
## 索引规则

每个索引元素在有符号索引已被检查为非负之后，按其低 16、32 或 64 位读作无符号行号。所选源元素被逐位复制；不执行任何数值转换，也不会因为不寻常的浮点编码而拒绝。

设计要点：索引选择逻辑源行，从不展平、回绕、钳位或选择另一列。因此源的有效列数至少要与目标相同，但可以更多。

设计要点：所有索引都在任何写入之前检查。负索引、大于等于源 ValidRow 的索引、未定义的索引或未定义的所选源元素都会拒绝该指令束，因此错误索引绝不会留下部分结果。[索引重排合法性](../../model/legality/indexed-rearrangement.md)拥有这些检查。

<!-- PTO-READER-BLOCK: tile-tgather-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `source0` 是持久的 Local 值源。
- `source1` 是持久的 Local 行索引源，类型为 `S16`、`U16`、`S32`、`U32`、`S64` 或 `U64`。
- `destination0` 是新分配的值目标，类型与 `source0` 相同。

值类型可以是任何非打包的 8、16、32 或 64 位类型：HiF8、E4M3、E5M2、E3M2、E2M3、E8M0、E6M2、RCPE6M2、S8、U8、FP16、BF16、S16、U16、FP32、TF32、HF32、S32、U32、FP64、S64 或 U64。

`B.DIM` LB0 给出目标 ValidCol；省略 LB0 时取架构默认值一，显式编码的零非法。LB1 默认使 ValidRow 为 1，LB2 默认为 Col = ValidCol。索引与目标的有效形状必须相等且非零。

一条终止 `B.IOT` 同时携带两个源与目标；`B.IOS` 非法，任何选择子不全为零的 `B.IOR` 也非法（显式全零 `B.IOR` 只命名 GPR0，不消耗操作数，因此被接受）。三个操作数都必须通过通用描述符检查，该检查排除 CUBE 布局。`B.DATR` 只能携带 `Layout`，它只改变目标的物理摆放。

<!-- PTO-READER-BLOCK: tile-tgather-effects role=effects -->
## 发布与已定义性

完整预检之后，两个源都被快照。随后完整的目标载荷、已定义性、`Null` 填充与描述符作为一次操作发布。每个有效目标元素都变为已定义，有效区域之外的物理元素保持未定义。

两个源都保持不变。`TGATHER` 没有全局内存效果，不记录数值状态；被拒绝的指令束不发布任何目标状态。

<!-- PTO-READER-BLOCK: tile-tgather-constraints role=constraints -->
## 合法性与故障边界

绑定格式错误、`B.IOR`、`B.IOS`、不支持的值或索引类型、有效形状为零或不匹配、源列数不足、索引为负、越界或未定义、所选源元素未定义、保留的 `Layout`，或目标容量不足，会在任何效果之前引发相应的 Tile 故障。

三个绑定使用相同的 `PE_MASK`；三位 PEMode 只能编码 `1000`、`0100`、`0010`、`0001`、`1100`、`1110`、`1111` 与 `0000`。`PE_MASK=0000` 在 `B.IOT` 的 size code 编码检查之后是严格无操作：不再进行 Tile 读取、索引检查、分配或操作故障，但非法的 `B.IOT` size code 仍会引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: tile-tgather-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

U32 值源有 3 个有效行、2 个有效列：第 0 行为 10、11；第 1 行为 20、21；第 2 行为 30、31。U16 索引 Tile 有 2 行：2、0 与 1、1。

目标 `[0,0]` 读取源 `[2,0]` = 30，`[0,1]` 读取源 `[0,1]` = 11。第 1 行读取源 `[1,0]` 与 `[1,1]`，即 20 与 21。任何位置出现索引 3 都会拒绝该指令束，因为源只有 3 个有效行。

以宏形式表示，以 `T#1` 为值源、`T#2` 为索引 Tile 的 8 x 16 U32 gather 写作下面的形式。目标容纳 8 x 16 x 4 = 512 字节。

```text
TGATHER <Row=8, Col=16, U32>, T#1, T#2, ->T<512B>
```
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TGATHER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGATHER | TEPL | 0x06F | 15 | 3 | TGATHER |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local value destination |
| source0 | persistent Local value source |
| source1 | persistent Local S16, U16, S32, U32, S64, or U64 row-index source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/layout/TGATHER.asl -->
```asl
readonly func InstructionContractOperation_TGATHER() => TileOperation
begin
    return TileOperation_TGATHER;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TGATHER, ValueDataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT ValueSrc, IndexSrc, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/layout/TGATHER.asl -->
```asl
readonly func InstructionContractOperandsLegal_TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    return TileOperandsLegal_TGATHER(destination, source, indices);
end;

readonly func InstructionContractHandler_TGATHER() => TileSemanticHandler
begin
    return TileHandler_TGATHER;
end;

func InstructionContractExecute_TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    assert InstructionContractOperandsLegal_TGATHER(
        destination,
        source,
        indices);
    TGATHER(destination, source, indices);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero destination ValidCol; omitted LB1 selects destination ValidRow=1 and omitted LB2 selects physical Col=ValidCol.
- Omitted B.DATR retains row-major destination layout; an assigned legal Layout changes only destination physical placement. PadValueOrByteId, secondary DataType, CMode, RMode, Sat, and Canonicalize remain zero.
- Physical destination coordinates outside the valid rectangle are undefined Null padding.

## Legality

- TGATHER uses the TEPL encoding carrier Mode 3 Function 15, is canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent value source, one persistent row-index source, and one newly allocated destination; B.IOR and B.IOS are illegal.
- Value source and destination use the same one of HiF8, E4M3, E5M2, E3M2, E2M3, E8M0, S8, U8, FP16, BF16, S16, U16, FP32, TF32, HF32, S32, U32, FP64, S64, or U64. The index source is exactly S16, U16, S32, U32, S64, or U64.
- Index and destination valid shapes are equal and nonzero. The value source has at least destination ValidCol columns.
- Every signed index is nonnegative and every index is less than source ValidRow. The complete index rectangle and every selected source[value,row,column] element are defined and validly encoded.
- All three bindings use the same PE_MASK; any nonzero subset is legal.

## State effects

- For every destination coordinate [r,c], read k=index[r,c] and copy source[k,c] bit-for-bit to destination[r,c].
- Indices select logical source rows and never flatten, wrap, clamp, or select another column.
- Both sources persist and rejection publishes no destination state.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, descriptor, type, dimension, layout, capacity, index-range, and referenced-definedness preflight precedes source snapshots.
- Both source payloads are snapshotted before result construction; complete destination payload, definedness, Null padding, and descriptor publish atomically.

## Exceptions

- Malformed bindings, B.IOR, B.IOS, unsupported value or index DataType, zero or mismatched valid shape, insufficient source columns, negative or out-of-range index, undefined index, undefined selected source element, invalid consumed encoding, reserved Layout, or insufficient destination capacity raises the applicable Tile fault before effects.
- PE_MASK=0000 is a strict no-op before Tile reads, index checks, allocation, faults, or payload effects.

## Examples

- BSTART.SFU TGATHER, U16; B.DIM LB0=2; B.DIM LB1=2; B.IOT ValueSrc, IndexSrc, mask=1111, <last>, ->Dst<2>; BSTOP
