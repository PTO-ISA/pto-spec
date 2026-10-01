<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl -->
# TFMA

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl`

Fused typed elementwise multiply-add over three Local Tile sources.

## Normative identity {#PTO-INST-TILE-TFMA}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tfma-purpose role=purpose -->
## TFMA 的作用

`TFMA` 在三个 Local Tile 上逐元素计算 `left * right + addend`，并把结果写入一个新分配的 Local 目标 Tile。与 `TADD` 不同，它读取三个源。

设计要点：`TFMA` 由 `BSTART.VEC` Mode 0 Function 28（TEPL 选择器 `0x01C`）选中，没有独立 opcode。一条 `B.IOT` 最多携带两个源，因此 `TFMA` 使用两条 `B.IOT` 绑定：第一条携带两个乘数，第二条携带加数和目标。

<!-- PTO-READER-BLOCK: tile-tfma-mechanism role=mechanism -->
## 元素与 Tile 机制

完整预检之后，三个源都被快照，有效矩形 `ValidRow x ValidCol` 内的每个坐标独立计算。

对浮点类型，该运算是融合的。精确积 `left * right` 不经舍入就与 `addend` 相加，只有最终和被舍入，使用配置档固定的默认舍入（就近舍入到偶数）。

设计要点：融合运算只舍入一次，而 `TMUL` 后接 `TADD` 会舍入两次。因此两种序列可能得到不同结果；下方演算示例展示了一个分开计算会完全丢失答案的情形。

对整数类型，结果是 `left * right + addend` 对元素位宽取模，位宽之上的载体位为零。整数不产生状态标志。

某些浮点输入会产生静默 NaN 并记录无效标志：任一操作数为信号 NaN、零乘无穷、无穷乘零，以及无穷积与符号相反的无穷相加。所有元素的状态标志按位或累积，并在结果发布时记录；它们从不引起同步陷入。

<!-- PTO-READER-BLOCK: tile-tfma-inputs-outputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是左乘数，绑定为第一条 `B.IOT` 的第一个源。
- `source1` 是右乘数，绑定为第一条 `B.IOT` 的第二个源。
- `source2` 是加数，绑定为第二条即终止 `B.IOT` 的源。
- `destination0` 是新分配的 Local Tile，由第二条 `B.IOT` 绑定。

第一条 `B.IOT` 不得带目标或终止标记；第二条必须携带目标并终止序列。所有参与的 `B.IOT` 绑定必须使用同一个 `PE_MASK`，`PE_MASK=0000` 是严格无操作。

设计要点：四个 Tile 的后备 `DataType`、形状和布局必须完全相同。与 `TADD` 不同，`TFMA` 不接受以不同后备类型存储的同位宽源，因此不会对任何源做重解释。

<!-- PTO-READER-BLOCK: tile-tfma-effects role=effects -->
## 发布、已定义性与填充

目标描述符、有效区域内的结果、填充、每个元素的已定义性以及累积的数值状态作为一次操作发布。被拒绝的指令束没有任何架构效果，三个源也保持不变。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero` 写入零；`Max` 与 `Min` 写入该 `DataType` 的最大与最小有限值；`Null` 使这些元素保持未定义。省略 `B.DATR` 选择 `Null`，而显式编码 `00` 选择 `Zero`。

重复的源以及与目标别名的源都观察到完整的操作前值。`TFMA` 没有全局内存效果。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，且不贡献状态。

<!-- PTO-READER-BLOCK: tile-tfma-constraints role=constraints -->
## 类型、布局与故障边界

ASL 合法性谓词 `TileFusedMultiplyAddDataTypeSupported` 接受 16 种类型：`FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16` 与 `U8`。下方生成的合法性列表更窄，只列出 `FP16`、`FP32` 与 `BF16`。`TFMA` 所调用的浮点元素运算 `ScalarFPFusedProfile` 只为 `FP64`、`FP32` 与 `FP16` 定义，因此 ASL 对 `TF32`、`HF32`、`BF16`、`E4M3` 或 `E5M2` 不给出元素结果。需要同时满足两者的代码应使用 `FP16` 或 `FP32`。

默认布局为 `RowMajor`。显式 `Layout` 可以选择 `CUBE_M16` 或 `CUBE_M32`，所有操作数必须使用同一布局。`CUBE_N8`、Shared Tile 以及混合布局均非法。`TFMA` 拒绝非默认的 `RMode`、`Sat`、`CMode` 与 `Canonicalize`。

绑定格式错误或多余、出现 `B.IOR` 或 `B.IOS`、掩码不相等、维度错误、`DataType` 不受支持、布局不匹配、源未定义或浮点编码无效时，会引发 `Fault_TileLegality`。目标形状无法表示或容量不足时，会引发 `Fault_TileAllocation`。两种故障都发生在任何目标效果之前。

<!-- PTO-READER-BLOCK: tile-tfma-example role=example -->
## 非规范演算示例

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

对 `FP16`，取 `left = right = 1.0009765625`，`addend = -1.001953125`。精确积为 `1.001953125 + 2^-20`，因此 `TFMA` 返回 `2^-20`，它在 `FP16` 中可精确表示。若单独使用 `TMUL`，积会被舍入为 `1.001953125`，随后的 `TADD` 将返回 `0`。

以宏形式表示，一个 8 x 64 的 `FP16` 融合乘加写作 `TFMA <Row=8, Col=64, FP16>, T#1, T#2, T#3, ->T<1KB>`，其中 `T#1` 与 `T#2` 是乘数，`T#3` 是加数。目标载荷为 8 x 64 x 2 = 1024 字节。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TFMA <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TFMA | TEPL | 0x01C | 28 | 0 | TFMA |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new renamed Local destination |
| source0 | left multiplicand Local source |
| source1 | right multiplicand Local source |
| source2 | fused addend Local source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl -->
```asl
readonly func InstructionContractOperation_TFMA() => TileOperation
begin
    return TileOperation_TFMA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TFMA, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK
B.IOT SrcAddend, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl -->
```asl
pure func InstructionContractDataTypeLegal_TFMA(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TFMA(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    addend: TileIndex) => boolean
begin
    return TileOperandsLegal_TFMA(
        destination,
        source_left,
        source_right,
        addend);
end;

func InstructionContractValue_TFMA(
    data_type: TileDataType,
    left: Word,
    right: Word,
    addend: Word) => (Word, bits(5))
begin
    return TileFixedFusedMultiplyAddValue(
        data_type,
        left,
        right,
        addend);
end;

readonly func InstructionContractHandler_TFMA() => TileSemanticHandler
begin
    return TileHandler_TFMA;
end;

func InstructionContractExecute_TFMA(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    addend: TileIndex)
begin
    TFMA(
        destination,
        source_left,
        source_right,
        addend);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol. Physical rows derive exactly from TSize, Col, and DataType.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- TFMA uses the selected numeric profile's fixed/default arithmetic rounding. It does not consume encoded RMode, Sat, or Canonicalize fields.

## Legality

- TFMA is selected by the TEPL encoding carrier Mode 0 Function 28, canonically assembled with BSTART.VEC, and has no standalone opcode.
- Exactly two ordered Local B.IOT bindings are required: the first supplies two multiplicands without a destination or last marker; the second supplies the addend and one new destination and terminates the sequence.
- DataType is exactly one of FP16, FP32, or BF16.
- All three sources and the destination match physical shape, valid shape, selected layout, DataType, and PE_MASK; every valid source element is defined.
- Only B.DATR PadValueOrByteId is applicable. Explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- B.IOR and B.IOS are illegal. All participating B.IOT masks are equal; PE_MASK zero is a strict no-op before source reads, allocation, arithmetic, flags, padding, or descriptor effects.

## State effects

- For floating DataTypes, each valid destination element is one fused left multiplied by right plus addend operation with no rounded intermediate product and one final profile rounding.
- For signed and unsigned integer DataTypes, each valid destination element is left multiplied by right plus addend modulo the element width; carrier bits above that width are zero.
- The selected PadValue defines or leaves undefined the physical destination region outside ValidRow by ValidCol without changing any source descriptor or source payload.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, dimension, DataType, layout, source-definedness, source-encoding, PE_MASK, destination-name, and capacity preflight precedes all three source snapshots.
- Duplicate sources and any source-to-destination alias observe complete pre-operation source payloads. Sources persist after both successful and rejected blocks.
- The complete result payload, selected padding definedness, sticky numeric flags, and renamed destination descriptor publish as one architectural operation; rejection has no architectural effect.

## Exceptions

- Malformed or surplus bindings, B.IOR or B.IOS, unequal masks, missing or invalid dimensions, unsupported DataType, non-selected layout, undefined source elements, mismatched descriptors, or invalid floating encodings raise Fault_TileLegality before effects.
- An unrepresentable destination shape, unavailable renamed destination, insufficient per-PE TSize, or exhausted architectural Tile capacity raises Fault_TileAllocation before allocation.
- A signaling NaN, zero multiplied by infinity, infinity multiplied by zero, or an infinite product added to an opposite-signed infinity produces a quiet NaN and records floating invalid without a synchronous trap.

## Examples

- BSTART.VEC TFMA, FP32; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK; B.IOT SrcAddend, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
