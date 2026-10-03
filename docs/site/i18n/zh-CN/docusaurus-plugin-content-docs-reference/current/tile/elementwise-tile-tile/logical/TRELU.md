<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TRELU.asl -->
# TRELU

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TRELU.asl`

Same-type elementwise rectifier over one Local Tile source.

## Normative identity {#PTO-INST-TILE-TRELU}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trelu-purpose role=purpose -->
## TRELU 的作用

`TRELU` 对一个 Local Tile 的每个元素应用整流函数 `max(x, 0)`，并把结果写入一个新分配的、`DataType` 相同的 Local 目标 Tile。负值与零变为零，正值原样通过，浮点 NaN 按下文所述被替换。

设计要点：`TRELU` 没有独立 opcode。它由 `BSTART.VEC` Mode 0 Function 23（TEPL 选择器 `0x017`）选中，并与 `TABS`、`TNOT` 和 `TNEG` 共用封闭的一元指令束模式。

<!-- PTO-READER-BLOCK: tile-c-trelu-mechanism role=mechanism -->
## 元素与 Tile 机制

完整预检通过后，`ExecuteTileUnary` 读取源，并变换有效矩形 `ValidRow x ValidCol` 内的每个坐标。规则取决于所选 `DataType`。

- 有符号整数类型：负元素变为零，非负元素不变。
- 无符号整数类型：`TRELU` 是恒等操作，因为没有负元素。
- 浮点类型：负有限值、负无穷、负零以及正零都变为正零。正有限值与正无穷不变。
- 浮点 NaN：静默 NaN 或信号 NaN 都变为数值配置档的静默 NaN。信号 NaN 还会记录无效条件。

设计要点：`TABS` 与 `TNEG` 只修改符号位，而 `TRELU` 用 `TileNumericValueClass` 对每个浮点值分类。两类 NaN 都映射为配置档静默 NaN，因此 NaN 载荷不会保留，信号 NaN 会报告无效。无效状态只在完整合法性预检之后记录，并与发布的结果一起出现。

设计要点：两种符号的零都映射为正零编码，因此 `TRELU` 计算出的元素永远不会是负零。

<!-- PTO-READER-BLOCK: tile-c-trelu-inputs-outputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是整流的源，必须是已分配的现有 Local Tile。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选操作 `DataType`，物理形状、有效形状和布局与源一致。

一条终止 `B.IOT` 在同一个 `PE_MASK` 下绑定两个 Tile；`B.IOR` 与 `B.IOS` 非法。只要 `B.IOT` 编码本身格式正确，`PE_MASK=0000` 就是严格无操作。

源可以使用位宽相同、非打包的其他后备类型。此时其位按所选 `DataType` 校验和解释。有效区域内的每个元素（存在 ExecutionMask 时为每个活动元素）都必须已定义，且是该类型的合法编码。

<!-- PTO-READER-BLOCK: tile-c-trelu-effects role=effects -->
## 发布、已定义性与填充

源载荷在第一次写目标之前被快照，因此与目标互为别名的源按旧值读取。

目标描述符、有效区域结果、填充、每个元素的已定义性以及任何无效状态同时发布。被拒绝的 `TRELU` 不产生任何架构效果。

`ValidRow x ValidCol` 之外的元素接收所选 `PadValue`。`Zero`、`Max` 与 `Min` 为已定义值；`Null`（省略 `B.DATR` 时的选择）使其保持未定义。

存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，且不贡献任何状态。`TRELU` 没有全局内存效果。

<!-- PTO-READER-BLOCK: tile-c-trelu-constraints role=constraints -->
## 类型、布局与故障边界

`TRELU` 恰好接受 `FP64`、`S64`、`U64`、`FP16`、`BF16`、`FP32` 与 `S32`。每个被接受的类型都有可执行 ReLU 结果。

默认布局为 `RowMajor`，显式 `Layout` 可选择 `CUBE_M16` 或 `CUBE_M32`。`CUBE_N8`、Shared Tile 以及混合布局均非法。非默认的 `CMode`、`Sat`、`Canonicalize`、第二 `DataType` 或 `RMode` 均非法。 在 CUBE 布局中，64 位操作类型只在 `CUBE_M32` 中合法；`CUBE_M16` 会拒绝。

绑定格式错误、维度缺失或为零、源状态未定义或不匹配、`DataType` 不受支持、布局非所选布局，或浮点源编码无效时，会在任何效果之前引发 `Fault_TileLegality`。目标形状无法表示或 `TSize` 容量不足时，会在分配之前引发 `Fault_TileAllocation`。

<!-- PTO-READER-BLOCK: tile-c-trelu-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

当 `DataType=S32` 时，有效元素 `[-7, 0, 9]` 变为 `[0, 0, 9]`。当 `DataType=FP16` 时，`0xC000`（-2.0）与 `0x8000`（负零）都变为 `0x0000`，而 `0x3C00`（1.0）保持不变。

宏形式 `TRELU <Row=8, Col=64, FP16>, T#1, ->T<1KB>` 把一个 `FP16` Tile 的全部 8 x 64 个元素整流，写入新的 1 KB 目标。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TRELU <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TRELU | TEPL | 0x017 | 23 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | rectifier source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TRELU.asl -->
```asl
readonly func InstructionContractOperation_TRELU() => TileOperation
begin
    return TileOperation_TRELU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TRELU, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TRELU.asl -->
```asl
pure func InstructionContractDataTypeLegal_TRELU(
    data_type: TileDataType) => boolean
begin
    return TileTReluDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TRELU(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_RELU,
        destination,
        source);
end;

pure func InstructionContractValue_TRELU(
    data_type: TileDataType,
    source: Word) => (Word, boolean)
begin
    return TileFixedUnaryValue(
        TileUnary_RELU,
        data_type,
        source);
end;

readonly func InstructionContractHandler_TRELU() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TRELU(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_RELU, destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Signed negative integers become zero and unsigned integers are unchanged. Floating negative finite values, negative infinity, and both signed zeros become positive zero; positive values and positive infinity are preserved; NaNs become the profile quiet NaN and signaling NaN reports invalid.

## Legality

- TRELU is BSTART.VEC Mode 0 Function 23 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of FP64, S64, U64, FP16, BF16, FP32, or S32.
- Source and destination match physical shape, valid shape, selected layout, DataType, and PE_MASK; the source valid region is fully defined.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Floating source encodings invalid for the selected DataType reject before allocation or destination effects; PE_MASK zero is a strict no-op.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- For every valid coordinate, apply the same-type integer or floating rectifier selected by DataType.
- Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The source payload is snapshotted after complete schema, dimension, DataType, layout, definedness, encoding, mask, and destination-capacity preflight and before destination writes.
- Source-to-destination aliasing therefore observes the complete pre-operation source payload.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched source state, unsupported DataType, non-selected layout, or invalid floating source encoding raises Fault_TileLegality before effects; an unrepresentable destination shape or insufficient TSize capacity raises Fault_TileAllocation before allocation.
- For TRELU, a signaling NaN publishes the profile quiet NaN and records the selected numeric-profile invalid condition only after complete legality preflight.

## Examples

- BSTART.VEC TRELU, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
