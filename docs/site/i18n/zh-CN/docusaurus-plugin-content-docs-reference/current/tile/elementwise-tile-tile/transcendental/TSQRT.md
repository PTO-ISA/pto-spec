<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl -->
# TSQRT

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl`

Compute the same-type square root of every valid Local Tile element.

## Normative identity {#PTO-INST-TILE-TSQRT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tsqrt-purpose role=purpose -->
## TSQRT 的作用

`TSQRT` 对一个 Local 浮点 Tile 的每个元素计算平方根 `sqrt(x)`，并把结果写入一个新分配的同类型 Local 目标 Tile。与 `TADD` 不同，它只读取一个源，只接受浮点类型，并在 `SFU` 引擎上执行。

设计要点：`TSQRT` 保留 TEPL 载体 Mode 0 Function 21（选择器 `0x015`），没有独立 opcode。其规范头部写作 `BSTART.SFU TSQRT, DataType`。`BSTART.SFU` 是 `BSTART.TEPL` 的别名，不增加任何编码位，因此引擎名只改变汇编拼写。

<!-- PTO-READER-BLOCK: tile-c-tsqrt-mechanism role=mechanism -->
## 元素与 Tile 机制

完整预检之后，`ExecuteTileUnary` 为有效矩形 `ValidRow x ValidCol` 内的每个坐标计算一个结果。每个元素先与一张固定的特殊输入表比对。只有普通有限输入才会进入数值配置档的近似计算，其结果按固定默认舍入舍入到该 `DataType`。

`TSQRT` 的特殊输入表如下：

- 正零与负零原样返回，因此 `sqrt(-0)` 为 `-0`。
- `+inf` 保持为 `+inf`。
- 任何负的非零值（包括 `-inf`）记录 NV 并产生规范静默 NaN。
- 任何 NaN 产生规范静默 NaN；信号 NaN 还会记录 NV。

设计要点：`-0` 不被视为负数。它原样通过且不引发任何标志，因此零的符号在运算后得以保留，而真正的负输入则被报告为无效。

每个元素用五个标志 NV、DZ、OF、UF 与 NX（无效、除以零、上溢、下溢与不精确）报告状态。所有活动元素的标志按位或累积，并在目标发布时记录。记录标志从不引发故障。

<!-- PTO-READER-BLOCK: tile-c-tsqrt-inputs-outputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是持久的 Local 浮点源，不会被修改。
- `destination0` 是新分配的 Local Tile，其后备 `DataType` 为所选操作 `DataType`，形状与布局与源一致。

两个 Tile 由同一条终止 `B.IOT` 绑定，并共享一个 `PE_MASK`。`PE_MASK=0000` 是严格无操作，发生在描述符读取、分配、故障、数值状态或载荷效果之前。

设计要点：完整的源在目标发布之前被快照，因此目标可以与源别名，并且仍然得到按旧值计算的结果。源可以使用位宽相同、非打包的其他后备类型存储，例如以 `FP16` 读取 `U16` 数据；此时这些位按所选 `DataType` 校验。

<!-- PTO-READER-BLOCK: tile-c-tsqrt-effects role=effects -->
## 发布、已定义性与填充

目标描述符、有效区域内的结果、填充、每个元素的已定义性以及累积的数值状态同时发布。被拒绝的指令束不改变架构状态。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero` 写入零；`Max` 与 `Min` 写入该 `DataType` 的最大与最小有限值；`Null` 使这些元素保持未定义。省略 `B.DATR` 选择 `Null`，而显式编码 `00` 选择 `Zero`。

`TSQRT` 没有全局内存效果。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，且不贡献状态。

<!-- PTO-READER-BLOCK: tile-c-tsqrt-constraints role=constraints -->
## 类型、布局与故障边界

ASL 合法性谓词 `TileFloatingElementwiseDataTypeSupported` 接受 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3` 与 `E5M2`。下方生成的合法性列表只列出 `FP16`、`FP32` 与 `BF16`，且有限值参考近似只为这三种类型定义，因此代码应使用其中之一。整数与打包类型会被拒绝。

默认布局为 `RowMajor`。显式 `Layout` 可以选择 `CUBE_M16` 或 `CUBE_M32`，两个操作数必须使用同一布局。`CUBE_N8`、Shared Tile 以及混合布局均非法。`TSQRT` 拒绝非默认的 `RMode`、`Sat` 与 `CMode`。

绑定格式错误、出现 `B.IOR` 或 `B.IOS`、维度缺失或为零、`DataType` 不受支持、源未定义或源编码无效、描述符不匹配或容量无效时，会在任何目标效果之前引发相应的 Tile 故障。特殊浮点输入从不引发故障，而是产生上表中的结果。

<!-- PTO-READER-BLOCK: tile-c-tsqrt-example role=example -->
## 非规范演算示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

对 `FP32`，源行 `[4.0, -0.0, -1.0, +inf]` 产生目标行 `[2.0, -0.0, NaN, +inf]`，记录的状态包含 NV。

以宏形式表示，一个 8 x 64 的 `FP32` 运算写作 `TSQRT <Row=8, Col=64, FP32>, T#1, ->T<2KB>`，其中 `T#1` 是源。目标载荷为 8 x 64 x 4 = 2048 字节，恰好等于 2KB 容量。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TSQRT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSQRT | TEPL | 0x015 | 21 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.DATR.PadValueOrByteId (`PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID`)

Carries the operation-selected PadValue or ByteId union field.

**Encoded zero:** For PadValue operations code zero selects Zero; for ByteId operations it selects ByteId zero.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | Zero-or-ByteId0 |
| 1 | assigned | Max-or-ByteId1 |
| 2 | assigned | Min-or-ByteId2 |
| 3 | assigned | Null-or-ByteId3 |

**Reserved-value behavior:** All four encodings are assigned; the selected operation separately validates whether the field is PadValue, ByteId, or inapplicable.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local floating destination |
| source0 | persistent Local floating source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl -->
```asl
readonly func InstructionContractOperation_TSQRT() => TileOperation
begin
    return TileOperation_TSQRT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TSQRT, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSQRT(
    data_type: TileDataType) => boolean
begin
    return TileUnaryDataTypeSupported(
        TileUnary_SQRT,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TSQRT(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_SQRT,
        destination,
        source);
end;

readonly func InstructionContractHandler_TSQRT() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TSQRT(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TSQRT(
        destination,
        source);
    ExecuteTileUnary(
        TileUnary_SQRT,
        destination,
        source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null and Layout=NORM (RowMajor). Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- The selected numeric profile supplies the operation-fixed approximation, rounding, exceptional result, and exact NV/DZ/OF/UF/NX status vector.

## Legality

- TSQRT retains its TEPL raw Mode 0 carrier and executes canonically on the SFU engine.
- Exactly one terminating Local B.IOT supplies one persistent source and one newly allocated destination. B.IOR and B.IOS are illegal.
- The selected DataType is exactly FP16, FP32, or BF16; every integer, exponent-only, other compact, packed, assigned-but-inapplicable, or reserved DataType rejects before effects.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, numeric status, or payload effects.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- For each valid element compute the selected profile's same-type square root.
- Accumulate all element status flags, apply selected physical padding, and publish payload, definedness, numeric status, and destination descriptor atomically; rejection leaves architectural state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, and allocation preflight precedes the source snapshot and profile evaluation.
- The complete source payload is snapshotted before destination publication, so source/destination aliasing observes the old source value.

## Exceptions

- Malformed Local bindings, B.IOR or B.IOS presence, missing or zero dimensions, unsupported DataType, undefined or invalid source encoding, descriptor mismatch, invalid capacity, or allocation failure raises the applicable Tile fault before effects.
- Square root preserves signed zero and positive infinity; a negative nonzero value reports invalid and produces quiet NaN; signaling NaN also records invalid.

## Examples

- BSTART.SFU TSQRT, DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
