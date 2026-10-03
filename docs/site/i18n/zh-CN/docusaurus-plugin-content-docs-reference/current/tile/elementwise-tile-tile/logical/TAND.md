<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TAND.asl -->
# TAND

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TAND.asl`

Compute the bitwise AND of corresponding integer elements.

## Normative identity {#PTO-INST-TILE-TAND}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tand-purpose role=purpose -->
## TAND 的作用

`TAND` 对两个 Local 整数 Tile 的对应元素计算按位与（AND），并把结果写入一个新分配的 Local 目标 Tile。按位与的规则是：仅当两个源的某一位都为 1 时结果该位才为 1。

设计要点：`TAND` 没有独立 opcode。它由 `BSTART.VEC` Mode 0 Function 6（TEPL 选择器 `0x006`）选中。其操作数合法性与执行遵循与 `TADD` 相同的封闭 Local 二元 Tile 契约，与 `TOR` 与 `TXOR` 只在位运算上不同。

<!-- PTO-READER-BLOCK: tile-tand-mechanism role=mechanism -->
## 元素与 Tile 机制

预检阶段先检查完整指令束：操作数模式、维度、`DataType`、布局、源已定义性以及目标容量。只有全部通过后，`ExecuteTileBinary` 才读取两个源，并对有效矩形 `ValidRow x ValidCol` 内的每个坐标计算 `left AND right`。

对于 8、16、32 或 64 位的元素位宽 `W`，结果为 AND 结果的低 `W` 位，`W` 以上的载体位为零。符号性不改变运算：`S8` 与 `U8` 产生相同的位。

设计要点：`TAND` 是原始载体操作。`TADD` 等算术操作要求每个源元素都是所选 `DataType` 的合法编码；`TAND` 跳过这种数值校验，按原样使用存储的位。位运算没有需要校验的数值含义，也不产生舍入、饱和或数值状态。

<!-- PTO-READER-BLOCK: tile-tand-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是左操作数，必须是已分配的现有 Local Tile。
- `source1` 是右操作数，其物理形状、有效形状和布局必须与 `source0` 相同。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选操作 `DataType`，形状与源一致。

一条终止 `B.IOT` 在同一个 `PE_MASK` 下绑定全部三个 Tile；不接受 `B.IOR` 与 `B.IOS`。`PE_MASK=0000` 是严格无操作，发生在读取、分配或故障之前。

设计要点：每个源都可以使用位宽相同、非打包的其他后备类型存储，其位按原样使用。例如，把 `FP32` 数据按 `U32` 读取并与 `0x7FFFFFFF` 相与，会清除每个符号位，得到绝对值的 `U32` 编码。

<!-- PTO-READER-BLOCK: tile-tand-effects role=effects -->
## 发布、已定义性与填充

两个源载荷都在第一次写目标之前被快照。任一源都可以与目标互为别名，两个源也可以指向同一个 Tile；结果总是按旧值计算。

目标描述符、有效区域结果、填充以及每个元素的已定义性作为一次提交发布。被拒绝的 `TAND` 不改变描述符、载荷与分配状态。

`ValidRow x ValidCol` 之外的元素接收所选 `PadValue`。`Zero` 写入零，`Max` 与 `Min` 写入该整数 `DataType` 的数值最大值与最小值；`Null`（省略 `B.DATR` 时的选择）使其保持未定义。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值。`TAND` 没有全局内存效果。

<!-- PTO-READER-BLOCK: tile-tand-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合为 `S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。浮点与打包操作类型会在效果之前被拒绝；如上所述，浮点数据仍可通过同位宽的整数操作类型处理。

默认布局为 `RowMajor`，显式 `Layout` 可选择 `CUBE_M16` 或 `CUBE_M32`。`CUBE_N8`、Shared Tile 以及混合布局均非法。 在 CUBE 布局中，64 位操作类型只在 `CUBE_M32` 中合法；`CUBE_M16` 会拒绝。

有效矩形内的每个源元素（存在 ExecutionMask 时为每个活动元素）都必须已定义，即使其编码不被校验。绑定格式错误、维度缺失或为零、源未定义或不匹配、布局不受支持、`DataType` 不受支持或目标容量无效时，会在效果之前引发 `Fault_TileLegality`。非默认的 `CMode`、`Sat`、`Canonicalize`、第二 `DataType` 或 `RMode` 均非法。

<!-- PTO-READER-BLOCK: tile-tand-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `DataType=U8` 时，左源行 `[0x0F, 0xF0, 0xFF]` 与右源行 `[0x3C, 0x3C, 0x81]` 产生目标行 `[0x0C, 0x30, 0x81]`。

宏形式 `TAND <Row=8, Col=64, U32>, T#1, T#2, ->T<2KB>` 把两个 `U32` Tile 的全部 8 x 64 个结果计算到新的 2 KB 目标中。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TAND <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TAND | TEPL | 0x006 | 6 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | ordered left Local source |
| source1 | ordered right Local source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TAND.asl -->
```asl
readonly func InstructionContractOperation_TAND() => TileOperation
begin
    return TileOperation_TAND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TAND, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TAND.asl -->
```asl
pure func InstructionContractDataTypeLegal_TAND(
    data_type: TileDataType) => boolean
begin
    return TileVecScalarIntegerDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TAND(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_AND,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TAND() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TAND(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_AND,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Physical Rows derive from TSize, Col, and DataType; Rows and Col are powers of two and contain ValidRow x ValidCol.

## Legality

- TAND is selected by TEPL carrier Mode 0 Function 6 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one newly allocated Local destination; B.IOR and B.IOS are not accepted.
- DataType is exactly S64, S32, S16, S8, U64, U32, U16, or U8; packed and floating formats reject before effects.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; PE_MASK=0000 is a strict no-op before reads, allocation, or faults.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Apply element-width bitwise AND to corresponding valid source elements; signedness does not change the bit operation and carrier bits above the selected width are zero.
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

- BSTART.VEC TAND, U8; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
