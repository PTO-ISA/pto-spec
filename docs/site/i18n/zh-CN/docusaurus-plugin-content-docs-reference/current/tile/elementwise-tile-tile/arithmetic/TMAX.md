<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl -->
# TMAX

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl`

Maximum corresponding Local Tile elements under typed integer and floating ordering.

## Normative identity {#PTO-INST-TILE-TMAX}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tmax-purpose role=purpose -->
## TMAX 的作用

`TMAX` 逐元素比较两个 Local Tile，并把每对元素中较大的一个写入新分配的 Local 目标 Tile。它与 `TADD` 共用指令束模式、预检、填充和发布规则；元素运算是按类型进行的选择，而不是算术。

设计要点：`TMAX` 由 `BSTART.VEC` Mode 0 Function 11（TEPL 选择器 `0x00B`）选中，没有独立 opcode。其对应操作 `TMIN` 使用相同的选择规则，只有比较方向以及零值平局时所取的符号不同。

<!-- PTO-READER-BLOCK: tile-tmax-mechanism role=mechanism -->
## 元素与 Tile 机制

完整预检之后，`ExecuteTileBinary` 为有效矩形 `ValidRow x ValidCol` 内的每个坐标计算一个结果。结果总是两个源值之一或某个固定的特殊值，不发生舍入。

整数排序遵循 `DataType`。有符号类型按有符号值比较，无符号类型按无符号值比较；因此对 `U8`，字节 `0xFF` 是 255，会胜过 1，而对 `S8`，同一字节是 -1，会落败。

浮点排序先应用固定的特殊值规则：

- 若恰好一个操作数是 NaN，结果为另一个操作数，保持不变。
- 若两个操作数都是 NaN，结果为该 `DataType` 的规范 NaN。
- 若两个操作数都是零但符号不同，结果为正零。符号相同的两个零保持该符号。
- 否则选择数值较大的操作数。

设计要点：这些规则使结果与操作数顺序无关。交换 `source0` 与 `source1` 永远不会改变任何目标元素，即使涉及 NaN 与有符号零。信号 NaN 同样不会改变所选结果。

<!-- PTO-READER-BLOCK: tile-tmax-inputs-outputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是左比较源，必须是已分配的现有 Local Tile。
- `source1` 是右比较源，其物理行数、物理列数、有效行数、有效列数和布局必须与 `source0` 相同。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选操作 `DataType`，形状与源一致。

三个 Tile 由同一条终止 `B.IOT` 绑定，并共享一个 `PE_MASK`。`PE_MASK=0000` 是严格无操作。在第一次写目标之前，两个源都已被完整读取，因此任一源都可以与目标别名。

设计要点：源可以使用位宽相同、非打包的其他后备类型存储。此时这些位按所选 `DataType` 校验和排序。由于符号性决定顺序，把 `U8` 数据按 `S8` 读取可能改变胜出的元素。

<!-- PTO-READER-BLOCK: tile-tmax-effects role=effects -->
## 发布、已定义性与填充

目标描述符、有效区域内的结果、填充以及每个元素的已定义性同时发布。被拒绝的指令束不会发布其中任何一项，两个源也保持不变。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero` 写入零；`Max` 与 `Min` 写入该 `DataType` 的最大与最小有限值；`Null` 使这些元素保持未定义。省略 `B.DATR` 选择 `Null`，而显式编码 `00` 选择 `Zero`。

`TMAX` 没有全局内存效果。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，而不是所选值。

<!-- PTO-READER-BLOCK: tile-tmax-constraints role=constraints -->
## 类型、布局与故障边界

`TMAX` 恰好接受 `FP64`、`S64`、`U64`、`S32`、`U32`、`FP32`、`S16`、`U16`、`FP16`、`BF16`、`S8` 与 `U8`。每个被接受的类型都有可执行有序最大值结果。

默认布局为 `RowMajor`。显式 `Layout` 可以选择 `CUBE_M16` 或 `CUBE_M32`，所有操作数必须使用同一布局。`CUBE_N8`、Shared Tile 以及混合布局均非法。 在 CUBE 布局中，64 位操作类型只在 `CUBE_M32` 中合法；`CUBE_M16` 会拒绝。

每个有效源元素都必须已定义；对浮点类型，还必须是所选 `DataType` 的有效编码。绑定格式错误、维度缺失或为零、源不匹配、`DataType` 不受支持、编码无效或目标容量无效时，会在任何目标效果之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: tile-tmax-example role=example -->
## 非规范演算示例

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

对 `FP32`，左源行 `[1.5, NaN, -0.0, 2.0]` 与右源行 `[-3.0, 4.0, +0.0, NaN]` 产生目标行 `[1.5, 4.0, +0.0, 2.0]`。每个 NaN 都被忽略而取数值操作数，符号不同的零对产生正零。

以宏形式表示，一个 8 x 64 的 `FP32` 最大值运算写作 `TMAX <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>`。目标载荷为 8 x 64 x 4 = 2048 字节，恰好等于 2KB 容量。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TMAX <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMAX | TEPL | 0x00B | 11 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | left comparison source |
| source1 | right comparison source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl -->
```asl
readonly func InstructionContractOperation_TMAX() => TileOperation
begin
    return TileOperation_TMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TMAX, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl -->
```asl
pure func InstructionContractDataTypeLegal_TMAX(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TMAX(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_MAX,
        destination,
        source_left,
        source_right);
end;

pure func InstructionContractFloatingValue_TMAX(
    data_type: TileDataType,
    source_left: Word,
    source_right: Word) => (Word, boolean)
begin
    assert InstructionContractDataTypeLegal_TMAX(data_type);
    assert TileDataTypeIsFloating(data_type);
    return TileFloatingMinMaxValue(
        TileBinary_MAX,
        data_type,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TMAX() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TMAX(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_MAX,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For floating TMAX, one NaN selects the numeric operand, two NaNs select canonical NaN, signaling NaN reports invalid, and mixed signed zeros select positive zero.

## Legality

- TMAX is BSTART.VEC Mode 0 Function 11 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of FP64, S64, U64, S32, U32, FP32, S16, U16, FP16, BF16, S8, or U8.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Floating source encodings invalid for the selected operation reject before allocation or destination effects; PE_MASK zero is a strict no-op.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Select the typed elementwise maximum for every valid coordinate.
- Signed integers use signed ordering, unsigned integers use unsigned ordering, and supported floating carriers use deterministic NaN and signed-zero rules.
- Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted after complete legality and encoding preflight and before destination writes.
- Source aliasing and source-to-destination aliasing therefore observe pre-operation values.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, unsupported DataType, non-selected layout, invalid source encoding, or invalid destination capacity raises Fault_TileLegality before effects.
- A signaling NaN reports the selected numeric profile invalid condition without changing the deterministic selected result.

## Examples

- BSTART.VEC TMAX, FP32; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
