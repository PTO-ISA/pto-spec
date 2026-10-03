<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl -->
# TMUL

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl`

Multiply corresponding elements of two Local Tiles.

## Normative identity {#PTO-INST-TILE-TMUL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tmul-purpose role=purpose -->
## TMUL 的作用

`TMUL` 将两个 Local Tile 逐元素相乘，并把积写入一个新分配的 Local 目标 Tile。它与 `TADD` 共用指令束模式、预检、填充和发布规则；只有元素运算不同。

设计要点：`TMUL` 由 `BSTART.VEC` Mode 0 Function 2（TEPL 选择器 `0x002`）选中，没有独立 opcode。由于操作身份放在选择器中，`TMUL` 复用与其他所有封闭二元逐元素操作相同的 `B.DIM`、`B.DATR` 和 `B.IOT` 命令。

<!-- PTO-READER-BLOCK: tile-tmul-mechanism role=mechanism -->
## 元素与 Tile 机制

预检阶段先检查完整指令束：所选 `DataType`、布局、两个源描述符、源已定义性与编码、目标容量以及操作数模式。只有全部检查通过后，`ExecuteTileBinary` 才对有效矩形 `ValidRow x ValidCol` 内的每个坐标计算 `left * right`。

整数乘法只保留积的低位。两个操作数先按 `DataType` 做符号扩展或零扩展，积再截断回元素位宽。例如对 `U16`，`300 * 300 = 90000` 得到 `24464`。

设计要点：目标与操作使用相同的 `DataType`，因此 `TMUL` 从不加宽。需要完整整数积的程序必须在相乘之前为操作数选择更宽的 `DataType`。

浮点乘法使用所选 `DataType` 的数值配置档及其固定默认舍入。`TMUL` 拒绝任何非默认的 `RMode`、`Sat` 或 `CMode`。在写入第一个目标元素之前，两个源都已被完整读取，因此源与目标别名的行为有明确定义。

<!-- PTO-READER-BLOCK: tile-tmul-inputs-outputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是左因子，必须是已分配的现有 Local Tile。
- `source1` 是右因子，其物理行数、物理列数、有效行数、有效列数和布局必须与 `source0` 相同。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选操作 `DataType`，形状与源一致。

三个 Tile 由同一条终止 `B.IOT` 绑定，并共享一个 `PE_MASK`。`PE_MASK=0000` 是严格无操作：不产生描述符、分配或载荷。

源可以使用位宽相同、非打包的其他后备类型存储。此时这些位按所选 `DataType` 校验和解释。

<!-- PTO-READER-BLOCK: tile-tmul-effects role=effects -->
## 发布、已定义性与填充

目标描述符、有效区域内的积、填充以及每个元素的已定义性同时发布。被拒绝的指令束不会发布其中任何一项，两个源也保持不变。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero` 写入零；`Max` 与 `Min` 写入该 `DataType` 的最大与最小有限值；`Null` 使这些元素保持未定义。省略 `B.DATR` 选择 `Null`，而显式编码 `00` 选择 `Zero`。

`TMUL` 没有全局内存效果。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，而不是积。

<!-- PTO-READER-BLOCK: tile-tmul-constraints role=constraints -->
## 类型、布局与故障边界

`TMUL` 恰好接受 `FP64`、`S64`、`U64`、`S32`、`U32`、`FP32`、`S16`、`U16`、`FP16` 与 `BF16`。每个被接受的浮点与整数类型都有可执行乘法结果。

默认布局为 `RowMajor`。显式 `Layout` 可以选择 `CUBE_M16` 或 `CUBE_M32`，所有操作数必须使用同一布局。`CUBE_N8`、Shared Tile 以及混合布局均非法。 在 CUBE 布局中，64 位操作类型只在 `CUBE_M32` 中合法；`CUBE_M16` 会拒绝。

绑定格式错误、维度缺失或为零、源未定义或不匹配、`DataType` 不受支持或目标容量无效时，会在任何目标效果之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: tile-tmul-example role=example -->
## 非规范演算示例

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

对 `U16`，左源行 `[3, 300]` 与右源行 `[5, 300]` 产生目标行 `[15, 24464]`。第二个积 90000 只保留其低 16 位。

以宏形式表示，一个 8 x 64 的 `FP32` 乘法写作 `TMUL <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>`。目标载荷为 8 x 64 x 4 = 2048 字节，恰好等于 2KB 容量。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TMUL <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMUL | TEPL | 0x002 | 2 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | left factor |
| source1 | right factor |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl -->
```asl
readonly func InstructionContractOperation_TMUL() => TileOperation
begin
    return TileOperation_TMUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TMUL, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl -->
```asl
pure func InstructionContractDataTypeLegal_TMUL(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TMUL(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_MUL,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TMUL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TMUL(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_MUL,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.

## Legality

- TMUL is BSTART.VEC Mode 0 Function 2 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of FP64, S64, U64, S32, U32, FP32, S16, U16, FP16, or BF16.
- Only B.DATR PadValueOrByteId is applicable.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Publish the elementwise products after complete preflight.
- Pad the remaining physical region using the selected PadValue; Null padding is undefined.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both sources are snapshotted before destination writes.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects.

## Examples

- BSTART.VEC TMUL, U64; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
