<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TDIV.asl -->
# TDIV

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TDIV.asl`

Divide corresponding Local Tile elements under the selected numeric profile.

## Normative identity {#PTO-INST-TILE-TDIV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tdiv-purpose role=purpose -->
## TDIV 的作用

`TDIV` 将一个 Local Tile 逐元素除以另一个 Local Tile，并把商写入一个新分配的 Local 目标 Tile。它与 `TADD` 共用指令束模式、填充和发布规则，但增加了除零检查，并在 `SFU` 引擎上执行。

设计要点：`TDIV` 保留 TEPL 载体 Mode 0 Function 3（选择器 `0x003`），没有独立 opcode。其规范头部写作 `BSTART.SFU TDIV, DataType`。`BSTART.SFU` 是 `BSTART.TEPL` 的别名，不增加任何编码位，因此引擎名只改变汇编拼写，而不改变二进制编码。

<!-- PTO-READER-BLOCK: tile-tdiv-mechanism role=mechanism -->
## 元素与 Tile 机制

完整预检之后，`ExecuteTileBinary` 对有效矩形 `ValidRow x ValidCol` 内的每个坐标计算 `numerator / denominator`。规则取决于 `DataType` 的种类：

- 有符号整数使用有符号除法，商向零截断。例如 `-7 / 2` 得到 `-3`。
- 无符号整数使用无符号除法。例如 `7 / 2` 得到 `3`。
- 浮点类型使用浮点除法配置档及其固定默认舍入。

有效除数矩形内任何位置出现整数零都属于合法性错误。预检会检查每个有效除数元素（存在 ExecutionMask 时为每个活动元素），并在任何源快照或目标效果之前引发 `Fault_TileLegality`。除数的填充区不会被读取。

设计要点：整数 `DataType` 没有可以表示 `x / 0` 的无穷或 NaN 编码。`TDIV` 不去虚构一个值，而是拒绝整个指令束，因此程序永远不会收到静默错误的整数商。可能除以零的程序必须在发出 `TDIV` 之前替换这些除数，或用 ExecutionMask 将其排除。

浮点零除数不是合法性错误。结果由浮点配置档定义：非零值除以零得到带组合符号的无穷，`0 / 0` 与 `inf / inf` 得到静默 NaN，有限值除以无穷得到有符号零。

<!-- PTO-READER-BLOCK: tile-tdiv-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是被除数，必须是已分配的现有 Local Tile。
- `source1` 是除数，其物理行数、物理列数、有效行数、有效列数和布局必须与 `source0` 相同。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选操作 `DataType`，形状与源一致。

三个 Tile 由同一条终止 `B.IOT` 绑定，并共享一个 `PE_MASK`。`PE_MASK=0000` 是严格无操作，发生在任何读取、检查或分配之前。源可以使用位宽相同、非打包的其他后备类型存储；此时这些位按所选 `DataType` 校验和解释。

<!-- PTO-READER-BLOCK: tile-tdiv-effects role=effects -->
## 发布、已定义性与填充

只有在全部合法性检查与整数零检查通过之后，两个源才被快照，因此与目标别名的源会在被覆盖之前读取。目标描述符、有效区域内的商、填充以及每个元素的已定义性同时发布。被拒绝的指令束不会改变描述符、载荷或分配状态。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero` 写入零；`Max` 与 `Min` 写入该 `DataType` 的最大与最小有限值；`Null` 使这些元素保持未定义。省略 `B.DATR` 选择 `Null`，而显式编码 `00` 选择 `Zero`。

`TDIV` 没有全局内存效果。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，而不是商。

<!-- PTO-READER-BLOCK: tile-tdiv-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合与 `TADD` 相同：`FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16` 与 `U8`。打包四位格式不在其中。`TDIV` 所调用的浮点元素运算 `ScalarFPBinaryProfile` 只为 `FP64`、`FP32`、`FP16` 与 `BF16` 定义，因此 ASL 对 `TF32`、`HF32`、`E4M3` 或 `E5M2` 不给出元素结果。

默认布局为 `RowMajor`。显式 `Layout` 可以选择 `CUBE_M16` 或 `CUBE_M32`，所有操作数必须使用同一布局。`CUBE_N8`、Shared Tile 以及混合布局均非法。`TDIV` 拒绝非默认的 `RMode`、`Sat` 与 `CMode`。

整数零除数、绑定格式错误、维度缺失或为零、源未定义或不匹配、`DataType` 不受支持或目标容量无效时，会在任何目标效果之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: tile-tdiv-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

对 `S32`，被除数行 `[7, -7, 9]` 与除数行 `[2, 2, -3]` 产生目标行 `[3, -3, -3]`。若任何有效除数元素为 `0`，该指令束会改为引发故障，且不产生目标。

对 `FP32`，被除数行 `[1.0, -1.0, 0.0]` 与除数行 `[0.0, 0.0, 0.0]` 产生 `[+inf, -inf, NaN]`，不引发故障。

以宏形式表示，一个 8 x 64 的 `FP32` 除法写作 `TDIV <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>`，其中 `T#1` 是被除数，`T#2` 是除数。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TDIV <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TDIV | TEPL | 0x003 | 3 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | ordered numerator |
| source1 | ordered denominator |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TDIV.asl -->
```asl
readonly func InstructionContractOperation_TDIV() => TileOperation
begin
    return TileOperation_TDIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TDIV, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Numerator, Denominator, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TDIV.asl -->
```asl
pure func InstructionContractDataTypeLegal_TDIV(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TDIV(
    destination: TileIndex,
    numerator: TileIndex,
    denominator: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_DIV,
        destination,
        numerator,
        denominator);
end;

readonly func InstructionContractHandler_TDIV() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TDIV(
    destination: TileIndex,
    numerator: TileIndex,
    denominator: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_DIV,
        destination,
        numerator,
        denominator);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and nonzero; omitted LB1 selects ValidRow=1 and omitted LB2 selects Col=ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- The numeric profile owns fixed rounding, floating exceptional values, and floating positive or negative zero division.

## Legality

- TDIV retains TEPL carrier Mode 0 Function 3 but is canonically classified as SFU.
- Exactly one terminating Local B.IOT supplies ordered numerator and denominator sources plus one new Local destination; B.IOR and B.IOS are illegal and PE_MASK zero is a strict no-op.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- Only B.DATR PadValueOrByteId is applicable.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- Signed integers use signed division, unsigned integers use unsigned division, and floating values use the selected floating division profile.
- The valid quotient and selected physical padding publish atomically; rejection leaves descriptor, payload, and allocation state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted after all legality and integer-zero checks, so aliasing is read-before-write.

## Exceptions

- An integer zero in the valid denominator rectangle raises Fault_TileLegality before source snapshots, allocation publication, or destination effects; denominator padding is not read.
- Malformed bindings, unsupported types, undefined inputs, mismatched descriptors, or invalid capacity reject before effects; floating zero is handled by the selected numeric profile.

## Examples

- BSTART.SFU TDIV, S64; B.DIM LB0=ValidCol; B.IOT Numerator, Denominator, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
