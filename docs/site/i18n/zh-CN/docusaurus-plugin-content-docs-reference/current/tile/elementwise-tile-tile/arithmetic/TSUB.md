<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl -->
# TSUB

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl`

Subtract corresponding right-source elements from left-source elements.

## Normative identity {#PTO-INST-TILE-TSUB}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tsub-purpose role=purpose -->
## TSUB 的作用

`TSUB` 将一个 Local Tile 与另一个 Local Tile 逐元素相减，并把差写入一个新分配的 Local 目标 Tile。它与 `TADD` 共用指令束模式、预检、填充和发布规则；只有元素运算和操作数顺序不同。

设计要点：`TSUB` 由 `BSTART.VEC` Mode 0 Function 1（TEPL 选择器 `0x001`）选中，没有独立 opcode。减法不满足交换律，因此绑定顺序本身具有含义：终止 `B.IOT` 的第一个源始终是被减数。

<!-- PTO-READER-BLOCK: tile-c-tsub-mechanism role=mechanism -->
## 元素与 Tile 机制

预检阶段先检查完整指令束：所选 `DataType`、布局、两个源描述符、源已定义性与编码、目标容量以及操作数模式。只有全部检查通过后，`ExecuteTileBinary` 才对有效矩形 `ValidRow x ValidCol` 内的每个坐标计算 `left - right`。

整数减法按位宽回绕。两个操作数先按 `DataType` 做符号扩展或零扩展，差再截断回元素位宽。例如对 `U8`，`3 - 5` 得到 `254`。

浮点减法使用所选 `DataType` 的数值配置档及其固定默认舍入。`TSUB` 拒绝任何非默认的 `RMode`、`Sat` 或 `CMode`，因此没有逐指令的舍入或饱和控制。

设计要点：在写入第一个目标元素之前，两个源都已被完整读取。因此即使目标与某个源别名，目标得到的仍是 `old left - old right`。

<!-- PTO-READER-BLOCK: tile-c-tsub-inputs-outputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是被减数，即左操作数，必须是已分配的现有 Local Tile。
- `source1` 是减数，即右操作数，其物理行数、物理列数、有效行数、有效列数和布局必须与 `source0` 相同。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选操作 `DataType`，形状与源一致。

三个 Tile 由同一条终止 `B.IOT` 绑定，并共享一个 `PE_MASK`。`PE_MASK=0000` 是严格无操作：不产生描述符、分配或载荷。

设计要点：源可以使用位宽相同、非打包的其他后备类型存储。此时这些位按所选 `DataType` 校验和解释，从而无需额外拷贝即可完成重解释读取。

<!-- PTO-READER-BLOCK: tile-c-tsub-effects role=effects -->
## 发布、已定义性与填充

目标描述符、有效区域内的差、填充以及每个元素的已定义性同时发布。被拒绝的指令束不会发布其中任何一项，两个源也保持不变。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero` 写入零；`Max` 与 `Min` 写入该 `DataType` 的最大与最小有限值；`Null` 使这些元素保持未定义。省略 `B.DATR` 选择 `Null`，而显式编码 `00` 选择 `Zero`。

`TSUB` 没有全局内存效果。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，而不是差。

<!-- PTO-READER-BLOCK: tile-c-tsub-constraints role=constraints -->
## 类型、布局与故障边界

ASL 合法性谓词 `TileVecArithmeticDataTypeSupported` 接受与 `TADD` 相同的 16 种类型：`FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16` 与 `U8`。打包四位格式不在其中。`TSUB` 所调用的浮点元素运算 `ScalarFPBinaryProfile` 只为 `FP64`、`FP32`、`FP16` 与 `BF16` 定义，因此 ASL 对 `TF32`、`HF32`、`E4M3` 或 `E5M2` 不给出元素结果。下方生成的合法性列表更窄，只列出 `S32`、`U32`、`FP32`、`S16`、`U16`、`FP16`、`BF16`、`S8` 与 `U8`。需要同时满足两者的代码应使用较窄列表中的类型。

默认布局为 `RowMajor`。显式 `Layout` 可以选择 `CUBE_M16` 或 `CUBE_M32`，所有操作数必须使用同一布局。`CUBE_N8`、Shared Tile 以及混合布局均非法。

绑定格式错误、维度缺失或为零、源未定义或不匹配、`DataType` 不受支持或目标容量无效时，会在任何目标效果之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: tile-c-tsub-example role=example -->
## 非规范演算示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

对 `S32`，左源行 `[10, -4]` 与右源行 `[3, 6]` 产生目标行 `[7, -10]`。交换两个源则得到 `[-7, 10]`。

以宏形式表示，一个 8 x 64 的 `S32` 减法写作 `TSUB <Row=8, Col=64, S32>, T#1, T#2, ->T<2KB>`，其中 `T#1` 是被减数，`T#2` 是减数。目标载荷为 8 x 64 x 4 = 2048 字节，恰好等于 2KB 容量。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TSUB <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSUB | TEPL | 0x001 | 1 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | minuend |
| source1 | subtrahend |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl -->
```asl
readonly func InstructionContractOperation_TSUB() => TileOperation
begin
    return TileOperation_TSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TSUB, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSUB(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TSUB(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_SUB,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TSUB() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TSUB(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_SUB,
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

- TSUB is BSTART.VEC Mode 0 Function 1 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S32, U32, FP32, S16, U16, FP16, BF16, S8, or U8.
- Only B.DATR PadValueOrByteId is applicable.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- Publish source-left minus source-right for each valid coordinate after complete preflight.
- Pad the remaining physical region using the selected PadValue; Null padding is undefined.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both sources are snapshotted before destination writes.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects.

## Examples

- BSTART.VEC TSUB, U64; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
