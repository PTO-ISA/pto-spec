<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TABS.asl -->
# TABS

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TABS.asl`

Typed elementwise absolute value over one Local Tile source.

## Normative identity {#PTO-INST-TILE-TABS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tabs-purpose role=purpose -->
## TABS 的作用

`TABS` 对一个 Local Tile 的每个元素取绝对值，并把结果写入一个新分配的 Local 目标 Tile。"绝对值"的含义取决于所选 `DataType`：有符号整数、无符号整数与浮点类型各有各的规则。

设计要点：`TABS` 没有独立 opcode。它由 `BSTART.VEC` Mode 0 Function 15（TEPL 选择器 `0x00F`）选中。它与 `TNOT`、`TNEG` 和 `TRELU` 共用封闭的一元指令束模式：一条终止 `B.IOT`、一个源和一个新目标。这四个操作的可接受 `DataType` 集合与逐元素变换仍各不相同，且 `TNOT` 还要求源后备类型完全一致。

<!-- PTO-READER-BLOCK: tile-tabs-mechanism role=mechanism -->
## 元素与 Tile 机制

预检阶段先检查完整指令束：操作数模式、维度、`DataType`、布局、源已定义性、源编码以及目标容量。只有全部通过后，`ExecuteTileUnary` 才读取源，并变换有效矩形 `ValidRow x ValidCol` 内的每个坐标。

- 有符号整数类型：负元素按元素位宽取模求负，其余元素不变。最小负值没有对应的正值，因此保持原位模式：`S8` `0x80`（-128）仍为 `0x80`。
- 无符号整数类型：`TABS` 是恒等操作。
- 浮点类型：`TABS` 只清除符号位。负零变为正零，负无穷变为正无穷，NaN 保持其类别与载荷。

设计要点：浮点 `TABS` 是符号位操作而非算术操作。因此即使遇到信号 NaN，它也从不报告无效条件，且从不改变指数位或尾数位。

设计要点：执行前源仍会作为数值被校验。有效区域内的每个元素（存在 ExecutionMask 时为每个活动元素）都必须是所选 `DataType` 的合法编码。例如，低 13 位尾数不为零的 `TF32` 元素会被拒绝。`TAND` 等原始载体操作不做这种检查。

<!-- PTO-READER-BLOCK: tile-tabs-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是取绝对值的源，必须是已分配的现有 Local Tile。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选操作 `DataType`，物理形状、有效形状和布局与源一致。

一条终止 `B.IOT` 在同一个 `PE_MASK` 下绑定两个 Tile；`B.IOR` 与 `B.IOS` 非法。只要 `B.IOT` 编码本身格式正确，`PE_MASK=0000` 就是严格无操作：不读取任何源，也不分配目标。

设计要点：源可以使用位宽相同、非打包的其他后备类型存储，例如把 `U16` 数据按 `FP16` 处理。这些位按所选 `DataType` 校验和解释，因此重解释式的取绝对值无需额外拷贝。

<!-- PTO-READER-BLOCK: tile-tabs-effects role=effects -->
## 发布、已定义性与填充

源载荷在预检之后、第一次写目标之前被快照。若源与目标互为别名，结果按旧的源值计算。

目标描述符、有效区域结果、填充以及每个元素的已定义性同时发布。被拒绝的 `TABS` 不产生任何架构效果。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero`、`Max` 与 `Min` 写入已定义值；`Null`（省略 `B.DATR` 时的选择）使这些元素保持未定义。

`TABS` 没有全局内存效果。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，而不是绝对值。

<!-- PTO-READER-BLOCK: tile-tabs-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。打包四位格式不在其中。

默认布局为 `RowMajor`。显式 `Layout` 可以选择 `CUBE_M16` 或 `CUBE_M32`；`CUBE_N8`、Shared Tile 以及混合布局均非法。非默认的 `CMode`、`Sat`、`Canonicalize`、第二 `DataType` 或 `RMode` 均非法。

绑定格式错误、维度缺失或为零、源状态未定义或不匹配、`DataType` 不受支持、布局非所选布局，或浮点源编码无效时，会在任何效果之前引发 `Fault_TileLegality`。目标形状无法表示或 `TSize` 容量不足时，会在分配之前引发 `Fault_TileAllocation`。下方生成的合法性与异常章节具有权威性。

<!-- PTO-READER-BLOCK: tile-tabs-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `DataType=S8` 时，有效元素 `[-2, 3, -128]` 变为 `[2, 3, -128]`。当 `DataType=FP16` 时，编码 `0x8000`（负零）变为 `0x0000`，`0xFC00`（负无穷）变为 `0x7C00`。

宏形式 `TABS <Row=8, Col=64, S8>, T#1, ->T<512B>` 把一个 `S8` Tile 的全部 8 x 64 个结果计算到新的 512 字节目标中。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TABS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TABS | TEPL | 0x00F | 15 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | absolute-value source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TABS.asl -->
```asl
readonly func InstructionContractOperation_TABS() => TileOperation
begin
    return TileOperation_TABS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TABS, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TABS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TABS(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TABS(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_ABS,
        destination,
        source);
end;

pure func InstructionContractValue_TABS(
    data_type: TileDataType,
    source: Word) => Word
begin
    let (result, -) = TileFixedUnaryValue(
        TileUnary_ABS,
        data_type,
        source);
    return result;
end;

readonly func InstructionContractHandler_TABS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TABS(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_ABS, destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Signed integers use modulo-width absolute value, including retaining the minimum signed bit pattern; unsigned integers are unchanged. Floating values clear only the sign bit, including zeros, infinities, and NaN payloads, without reporting invalid solely for TABS.

## Legality

- TABS is BSTART.VEC Mode 0 Function 15 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- Source and destination match physical shape, valid shape, selected layout, DataType, and PE_MASK; the source valid region is fully defined.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Floating source encodings invalid for the selected DataType reject before allocation or destination effects; PE_MASK zero is a strict no-op.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- For every valid coordinate, compute signed modulo-width absolute value, unsigned identity, or floating sign-bit clearing according to DataType.
- Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The source payload is snapshotted after complete schema, dimension, DataType, layout, definedness, encoding, mask, and destination-capacity preflight and before destination writes.
- Source-to-destination aliasing therefore observes the complete pre-operation source payload.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched source state, unsupported DataType, non-selected layout, or invalid floating source encoding raises Fault_TileLegality before effects; an unrepresentable destination shape or insufficient TSize capacity raises Fault_TileAllocation before allocation.
- This operation introduces no memory fault and reports no floating invalid condition solely from its value transform.

## Examples

- BSTART.VEC TABS, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
