<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TSHL.asl -->
# TSHL

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TSHL.asl`

Shift corresponding integer elements left by element-width-masked counts.

## Normative identity {#PTO-INST-TILE-TSHL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tshl-purpose role=purpose -->
## TSHL 的作用

`TSHL` 把一个 Local 整数值 Tile 的每个元素左移，移位量取自第二个 Local 整数 Tile 的对应元素。结果写入一个新分配的 Local 目标 Tile。每个元素都有自己的移位计数。

设计要点：`TSHL` 没有独立 opcode。它由 `BSTART.VEC` Mode 0 Function 9（TEPL 选择器 `0x009`）选中，其操作数合法性与执行遵循与 `TADD` 相同的封闭 Local 二元 Tile 契约。

<!-- PTO-READER-BLOCK: tile-c-tshl-mechanism role=mechanism -->
## 元素与 Tile 机制

完整预检通过后，`ExecuteTileBinary` 读取两个源，并处理有效矩形 `ValidRow x ValidCol` 内的每个坐标。对于 8、16、32 或 64 位的元素位宽 `W`，移位计数是 `source1` 元素低 `log2(W)` 位的无符号值：8 位类型取 3 位，16 位取 4 位，32 位取 5 位，64 位取 6 位。其余计数位被忽略。

目标元素为 `source0` 左移该计数后的低 `W` 位；移出第 `W-1` 位的位被丢弃，右侧补零。符号性不改变运算。结果中 `W` 以上的载体位为零。

设计要点：把计数掩码为 `log2(W)` 位，使每个计数都落在 0 到 `W-1` 范围内。不存在越界计数，也无需故障或特殊情况。大于或等于 `W` 的计数按 `W` 取模回绕，负的有符号计数同样使用其低位。

设计要点：`TSHL` 是原始载体操作。值源不作为数值校验，移位也不产生舍入、饱和或数值状态。左移对有符号与无符号类型是同一种位操作，因此一条规则适用于全部八种整数类型。

<!-- PTO-READER-BLOCK: tile-c-tshl-inputs-outputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是整数值源，必须是已分配的现有 Local Tile。
- `source1` 是整数移位计数源，其物理形状、有效形状和布局必须与 `source0` 相同。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选操作 `DataType`，形状与源一致。

一条终止 `B.IOT` 在同一个 `PE_MASK` 下绑定全部三个 Tile；不接受 `B.IOR` 与 `B.IOS`。`PE_MASK=0000` 是严格无操作，发生在读取、分配或故障之前。

设计要点：`source0` 可以使用任意位宽相同、非打包的后备类型存储，其位按原样使用。合法性检查会单独要求 `source1` 存储的后备 `DataType` 为整数类型，与操作 `DataType` 无关。因此同位宽的浮点计数 Tile（例如在 `U32` 移位中使用 `FP32` 计数）会被拒绝，而 `source0` 没有这项检查。

<!-- PTO-READER-BLOCK: tile-c-tshl-effects role=effects -->
## 发布、已定义性与填充

两个源载荷都在第一次写目标之前被快照。任一源都可以与目标互为别名，两个源也可以指向同一个 Tile；结果按旧值计算。

目标描述符、有效区域结果、填充以及每个元素的已定义性作为一次提交发布。被拒绝的 `TSHL` 不改变描述符、载荷与分配状态。

`ValidRow x ValidCol` 之外的元素接收所选 `PadValue`。`Zero`、`Max` 与 `Min` 为已定义值，其中 `Max` 与 `Min` 使用该整数 `DataType` 的边界；`Null`（省略 `B.DATR` 时的选择）使其保持未定义。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值。`TSHL` 没有全局内存效果。

<!-- PTO-READER-BLOCK: tile-c-tshl-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合为 `S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。浮点与打包操作类型会在效果之前被拒绝。

默认布局为 `RowMajor`，显式 `Layout` 可选择 `CUBE_M16` 或 `CUBE_M32`。`CUBE_N8`、Shared Tile 以及混合布局均非法。 在 CUBE 布局中，64 位操作类型只在 `CUBE_M32` 中合法；`CUBE_M16` 会拒绝。

有效矩形内的每个源元素（存在 ExecutionMask 时为每个活动元素）都必须已定义。绑定格式错误、维度缺失或为零、源未定义或不匹配、计数后备类型不是整数、布局不受支持、`DataType` 不受支持或目标容量无效时，会在效果之前引发 `Fault_TileLegality`。非默认的 `CMode`、`Sat`、`Canonicalize`、第二 `DataType` 或 `RMode` 均非法。

<!-- PTO-READER-BLOCK: tile-c-tshl-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

当 `DataType=U8` 时，值行 `[0x81, 0x01, 0x01]` 与计数行 `[1, 7, 9]` 产生 `[0x02, 0x80, 0x02]`。计数 9 被掩码为低 3 位，即 1。

宏形式 `TSHL <Row=8, Col=64, S32>, T#1, T#2, ->T<2KB>` 按 `T#2` 中的计数移位 `S32` 值 Tile `T#1` 的全部 8 x 64 个元素。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TSHL <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSHL | TEPL | 0x009 | 9 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | integer value source |
| source1 | integer shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TSHL.asl -->
```asl
readonly func InstructionContractOperation_TSHL() => TileOperation
begin
    return TileOperation_TSHL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TSHL, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Value, ShiftCount, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TSHL.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSHL(
    data_type: TileDataType) => boolean
begin
    return TileBinaryDataTypeSupported(TileBinary_SHL, data_type);
end;

readonly func InstructionContractOperandsLegal_TSHL(
    destination: TileIndex,
    value_source: TileIndex,
    count_source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_SHL,
        destination,
        value_source,
        count_source);
end;

readonly func InstructionContractHandler_TSHL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TSHL(
    destination: TileIndex,
    value_source: TileIndex,
    count_source: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_SHL,
        destination,
        value_source,
        count_source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Physical Rows derive from TSize, Col, and DataType; Rows and Col are powers of two and contain ValidRow x ValidCol.

## Legality

- TSHL is selected by TEPL carrier Mode 0 Function 9 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies ordered value and shift-count sources plus one newly allocated Local destination; B.IOR and B.IOS are not accepted.
- DataType is exactly S64, S32, S16, S8, U64, U32, U16, or U8; packed and floating formats reject before effects.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; PE_MASK=0000 is a strict no-op before reads, allocation, or faults.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- For element width W, use the unsigned low log2(W) bits of source1 as the count and store the low W bits of source0 shifted left; signedness does not alter the operation and carrier bits above W are zero.
- Either source may alias the destination with read-old/write-new behavior, and both sources may name the same Tile.
- Publish the complete valid result and selected physical padding definedness as one destination commit; rejection leaves descriptors, payloads, and allocation state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted after complete preflight and before the first destination write.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, an unsupported layout, an unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects.
- Explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal before source snapshots or destination allocation.

## Examples

- BSTART.VEC TSHL, U8; B.DIM LB0=ValidCol; B.IOT Value, ShiftCount, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
