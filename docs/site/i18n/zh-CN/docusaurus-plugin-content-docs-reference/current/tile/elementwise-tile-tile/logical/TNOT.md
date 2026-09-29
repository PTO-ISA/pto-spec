<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TNOT.asl -->
# TNOT

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TNOT.asl`

Element-width bitwise complement over one Local integer Tile source.

## Normative identity {#PTO-INST-TILE-TNOT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tnot-purpose role=purpose -->
## TNOT 的作用

`TNOT` 翻转一个 Local 整数 Tile 中每个元素的每一位，并把结果写入一个新分配的 Local 目标 Tile。它就是按位取反。

设计要点：`TNOT` 没有独立 opcode。它由 `BSTART.VEC` Mode 0 Function 16（TEPL 选择器 `0x010`）选中，并与 `TABS`、`TNEG` 和 `TRELU` 共用封闭的一元指令束模式。

<!-- PTO-READER-BLOCK: tile-tnot-mechanism role=mechanism -->
## 元素与 Tile 机制

完整预检通过后，`ExecuteTileUnary` 读取源，并对有效矩形 `ValidRow x ValidCol` 内的每个坐标，恰好对所选的 8、16、32 或 64 位元素位宽取反。符号性不影响结果：`S8` 与 `U8` 都把 `0x0F` 映射为 `0xF0`。

设计要点：只对元素自身的 `W` 位取反，结果中 `W` 以上的载体位为零。模型用 64 位载体保存每个元素；若对整个载体取反，未使用的高位会变成 1。把结果限制在 `W` 位，可保证 8 位结果仍是 8 位值。

设计要点：`TNOT` 是位操作，因此不施加数值舍入、饱和或状态。`TABS`、`TNEG` 与 `TRELU` 也接受浮点类型，而 `TNOT` 只接受八种整数类型。

<!-- PTO-READER-BLOCK: tile-tnot-inputs-outputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是按位操作的源，必须是已分配的现有 Local Tile。
- `destination0` 是新分配的 Local Tile，其物理形状、有效形状、布局与 `DataType` 均与源相同。

一条终止 `B.IOT` 在同一个 `PE_MASK` 下绑定两个 Tile；`B.IOR` 与 `B.IOS` 非法。`PE_MASK=0000` 是严格无操作，发生在维度、源访问、模式检查或目标分配之前。

设计要点：`TNOT` 的一元合法性路径要求源后备 `DataType` 等于操作 `DataType`。它不使用 `TABS`、`TNEG` 与 `TRELU` 允许的同位宽重解释，因此以其他后备类型存储的源会在任何效果之前被拒绝。

<!-- PTO-READER-BLOCK: tile-tnot-effects role=effects -->
## 发布、已定义性与填充

源载荷在第一次写目标之前被快照，因此与目标互为别名的源按旧值读取。

目标描述符、有效区域结果、填充以及每个元素的已定义性同时发布；被拒绝的 `TNOT` 不产生任何架构效果。`ValidRow x ValidCol` 之外的元素接收所选 `PadValue`：`Zero`、`Max` 与 `Min` 为已定义值，而 `Null`（省略 `B.DATR` 时的值）使其保持未定义。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值。`TNOT` 没有全局内存效果。

<!-- PTO-READER-BLOCK: tile-tnot-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合为 `S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。浮点与打包格式会被拒绝。默认布局为 `RowMajor`，显式 `Layout` 可选择 `CUBE_M16` 或 `CUBE_M32`；`CUBE_N8`、Shared Tile 以及混合布局均非法。

绑定格式错误、维度缺失或为零、源状态未定义或不匹配、`DataType` 不受支持、布局非所选布局，或出现非默认的 `CMode`、`Sat`、`Canonicalize`、第二 `DataType` 或 `RMode` 时，会在任何效果之前引发 `Fault_TileLegality`。目标形状无法表示或 `TSize` 容量不足时，会在分配之前引发 `Fault_TileAllocation`。

<!-- PTO-READER-BLOCK: tile-tnot-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

当 `DataType=U16` 时，有效元素 `[0x0000, 0x00FF, 0xFFFF]` 变为 `[0xFFFF, 0xFF00, 0x0000]`。宏形式 `TNOT <Row=8, Col=64, U16>, T#1, ->T<1KB>` 把全部 8 x 64 个元素取反，写入新的 1 KB 目标。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TNOT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TNOT | TEPL | 0x010 | 16 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | bitwise source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TNOT.asl -->
```asl
readonly func InstructionContractOperation_TNOT() => TileOperation
begin
    return TileOperation_TNOT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TNOT, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TNOT.asl -->
```asl
pure func InstructionContractDataTypeLegal_TNOT(
    data_type: TileDataType) => boolean
begin
    return TileVecScalarIntegerDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TNOT(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_NOT,
        destination,
        source);
end;

pure func InstructionContractValue_TNOT(
    data_type: TileDataType,
    source: Word) => Word
begin
    let (result, -) = TileFixedUnaryValue(
        TileUnary_NOT,
        data_type,
        source);
    return result;
end;

readonly func InstructionContractHandler_TNOT() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TNOT(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_NOT, destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- TNOT complements exactly the selected 8-, 16-, 32-, or 64-bit element width and zero-extends the result to the Tile payload carrier.

## Legality

- TNOT is BSTART.VEC Mode 0 Function 16 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S64, S32, S16, S8, U64, U32, U16, or U8.
- Source and destination match physical shape, valid shape, selected layout, DataType, and PE_MASK; the source valid region is fully defined.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- PE_MASK zero is a strict no-op before dimensions, source access, schema checks, or destination allocation.

## State effects

- For every valid coordinate, complement exactly the selected integer element width and clear upper carrier bits.
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

- BSTART.VEC TNOT, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
