<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TADD.asl -->
# TADD

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TADD.asl`

Add corresponding elements of two Local Tiles.

## Normative identity {#PTO-INST-TILE-TADD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tadd-purpose role=purpose -->
## TADD 的作用

`TADD` 将两个 Local Tile 逐元素相加，并把结果写入一个新分配的 Local 目标 Tile。它是 VEC 逐元素算术族的参考成员：`TSUB`、`TMUL`、`TMAX` 与 `TMIN` 复用同一指令束模式，只有元素运算不同。

设计要点：`TADD` 没有独立 opcode。它由 `BSTART.VEC` Mode 0 Function 0（TEPL 选择器 `0x000`）选中，形状、属性与操作数由随后的 `B.DIM`、`B.DATR` 和 `B.IOT` 命令提供。把操作身份放在一个选择器中、把配置放在共享的指令束命令中，使所有逐元素操作共用同一个译码器和同一套操作数模型。

<!-- PTO-READER-BLOCK: tile-tadd-mechanism role=mechanism -->
## 元素与 Tile 机制

执行分为两个阶段。预检阶段先检查完整指令束：所选 `DataType`、布局、两个源描述符、源已定义性、目标容量以及操作数模式。只有全部检查通过后，`ExecuteTileBinary` 才读取源，并对有效矩形 `ValidRow x ValidCol` 内的每个坐标计算 `left + right`。

设计要点：在写入第一个目标元素之前，两个源都已被完整读取。这让别名行为有明确定义：若某个源与目标是同一个 Tile，结果按旧的源值计算，与目标是另一个独立 Tile 时完全相同。

加法本身由所选 `DataType` 的数值配置档定义，包括舍入、溢出与特殊值。整数加法按位宽回绕；浮点加法使用配置档固定的默认舍入。`TADD` 拒绝任何非默认的 `RMode`、`Sat` 或 `CMode`，因此没有逐指令的舍入或饱和控制。

<!-- PTO-READER-BLOCK: tile-tadd-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是左加数，必须是已分配的现有 Local Tile。
- `source1` 是右加数，其物理行数、物理列数、有效行数、有效列数和布局必须与 `source0` 相同。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选操作 `DataType`，形状与源一致。

在没有 ExecutionMask 载体时，三个 Tile 由同一条终止 `B.IOT` 绑定，并共享一个 `PE_MASK`。每个被选中的 PE 在自己的分片上独立执行。

设计要点：`PE_MASK=0000` 是严格无操作。只要 `B.IOT` 编码本身格式正确，零参与会跳过模式、分配与描述符检查，不产生描述符、分配、载荷或数值状态。因此即使没有 PE 参与，指令束也不会被该操作的模式检查拒绝。

设计要点：源可以使用位宽相同、非打包的其他后备类型存储，例如以 `FP16` 读取 `U16` 数据。此时这些位按所选 `DataType` 校验和解释。这样无需额外拷贝即可完成重解释读取，而位宽不一致或打包四位载体仍然非法。

<!-- PTO-READER-BLOCK: tile-tadd-effects role=effects -->
## 发布、已定义性与填充

目标作为一个整体变为可见：描述符、有效区域内的和、有效矩形之外的填充以及每个元素的已定义性同时发布。任何观察者都看不到写了一半的 `TADD` 结果。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero` 写入零；`Max` 与 `Min` 写入该 `DataType` 的最大与最小有限值；`Null` 使这些元素保持未定义。

设计要点：省略 `B.DATR` 选择 `Null`，而显式编码 `00` 选择 `Zero`。省略与编码零在架构上是不同的：默认情况下有效矩形之外的元素保持未定义，因此之后需要这些物理元素具有已定义值的程序必须显式请求 `Zero`、`Max` 或 `Min`。

`TADD` 没有全局内存效果。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，而不是和。

<!-- PTO-READER-BLOCK: tile-tadd-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。打包四位格式不在其中。

默认布局为 `RowMajor`。显式 `Layout` 可以选择 `CUBE_M16` 或 `CUBE_M32`，使 `TADD` 能直接处理已按 CUBE 引擎排布的 Tile，而无需布局转换。所有操作数必须使用同一布局；`CUBE_N8`、Shared Tile 以及混合布局均非法。

有效矩形内的每个源元素（存在 ExecutionMask 时为每个活动元素）都必须已定义。缺少 `LB0`、`B.IOT` 格式错误、出现任何 `B.IOR` 或 `B.IOS`、形状或位宽不匹配、源元素未定义、`DataType` 不受支持或目标容量无效时，会在任何目标效果之前引发 `Fault_TileLegality`。下方生成的合法性与异常章节具有权威性。

<!-- PTO-READER-BLOCK: tile-tadd-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TADD` 示例说明：左源行 `[1, 2]` 与右源行 `[3, 4]` 产生目标行 `[4, 6]`。

对于物理形状为 8 x 64 的 `FP32` 部分 Tile，若有效区域为 7 x 60 且使用 `Zero` 填充，其宏形式写作 `TADD <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, T#2, ->T<2KB>`。计算 7 x 60 个和，8 x 64 目标中其余 92 个物理元素（第 7 行全部，以及第 0 至 6 行的第 60 至 63 列）被定义为零。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TADD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TADD | TEPL | 0x000 | 0 | 0 | ExecuteTileBinary |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TADD.asl -->
```asl
readonly func InstructionContractOperation_TADD() => TileOperation
begin
    return TileOperation_TADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TADD, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TADD.asl -->
```asl
pure func InstructionContractDataTypeLegal_TADD(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TADD(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_ADD,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TADD() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TADD(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_ADD,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol; an explicitly present zero dimension is illegal.
- Omitted B.DATR selects PadValue=Null and Layout=NORM (RowMajor). Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null respectively.
- The destination physical Rows are derived from TSize, Col, and DataType; Rows and Col are powers of two and contain ValidRow x ValidCol.

## Legality

- TADD is selected only by BSTART.VEC Mode 0 Function 0 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one newly allocated Local destination. B.IOR and B.IOS are not accepted; all participating Tiles use one PE_MASK and zero mask is a strict no-op.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- After complete preflight, add corresponding source elements and atomically publish the valid destination region.
- Physical destination elements outside ValidRow x ValidCol receive the selected PadValue; Null padding remains undefined while Zero, Max, and Min padding are defined.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted before the first destination write, so source/destination aliasing is read-before-write.

## Exceptions

- A missing LB0, malformed Local B.IOT, B.IOR or B.IOS presence, source shape or carrier-width mismatch, undefined source element, unsupported DataType, or invalid destination capacity raises Fault_TileLegality before destination effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.VEC TADD, U64; B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
