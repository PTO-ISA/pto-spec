<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/initialization/TEXPANDS.asl -->
# TEXPANDS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/initialization/TEXPANDS.asl`

Broadcast one private-GPR scalar encoding across a newly allocated Local Tile.

## Normative identity {#PTO-INST-TILE-TEXPANDS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-texpands-purpose role=purpose -->
## TEXPANDS 的作用

`TEXPANDS` 用一个标量填充新分配 Local Tile 的有效矩形。它没有 Tile 源。它由 TEPL Mode 1 Function 27（选择器 `0x03B`）选中，以 `BSTART.VEC TEXPANDS, DataType` 在 `VEC` 上执行，没有独立 opcode。

设计要点：`TEXPANDS` 是从标量到 Tile 的桥梁。`TSUBS` 等 Tile-标量操作把 Tile 固定为左操作数。当程序需要标量位于左侧，或需要为 Tile-Tile 操作提供常量 Tile 时，由 `TEXPANDS` 一次性构造该 Tile。

<!-- PTO-READER-BLOCK: tile-texpands-mechanism role=mechanism -->
## 标量来源与填充机制

标量来自 `B.IOR.RegSrc0`。每个参与的 PE 在自己的私有 GPR 文件中解析该选择器，因此每个 PE 可以用不同的值填充自己的分片。指令束中没有用于标量的立即数字段。

`ExecuteTileFillScalar` 用 `TileRawElementValue` 收窄 64 位 GPR 值，只保留与所选 `DataType` 元素位宽一致的低 8、16、32 或 64 位，并把该位模式写入 `ValidRow x ValidCol` 内的每个坐标。

设计要点：填充是原始拷贝而不是转换。没有舍入、饱和、规范化或数值状态更新，因此浮点标量必须已按所选类型编码。这使结果不依赖任何数值配置档。

<!-- PTO-READER-BLOCK: tile-texpands-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `scalar0` 是来自 `B.IOR.RegSrc0` 的逐 PE 标量。显式 `B.IOR` 必须使 `RegSrc1`、`RegSrc2` 和 `RegDst` 保持为零。
- `destination0` 是新分配的 Local 数值 Tile，其 `DataType` 为所选 `DataType`。

一条终止 `B.IOT` 只绑定目标及其 `PE_MASK`。`B.IOS` 与额外的 Tile 绑定均非法。

设计要点：由于没有源 Tile，也就没有需要检查的源已定义性。`TEXPANDS` 把寄存器值变为一个有效区域完全已定义的 Tile。

设计要点：`PE_MASK=0000` 是严格无操作。它在任何 GPR 读取、描述符读取、分配、故障或状态效果之前退出，因此没有 PE 参与的指令束永远不会读取标量寄存器。

<!-- PTO-READER-BLOCK: tile-texpands-effects role=effects -->
## 发布、已定义性与填充

目标载荷、填充已定义性与描述符作为一个整体发布。被拒绝的指令束没有任何架构效果，`TEXPANDS` 也没有全局内存效果。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero`、`Max` 与 `Min` 定义这些元素；省略 `B.DATR` 时默认的 `Null` 使其保持未定义。

省略 `B.IOR` 时用所选类型的全零编码填充有效区域，对浮点类型即 `+0.0`。显式的全零 `B.IOR` 是不同的编码，但提供相同的值。

存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，而不是标量。

<!-- PTO-READER-BLOCK: tile-texpands-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。打包四位格式不在其中。

默认布局为 `RowMajor`。显式 `B.DATR` `Layout` 可以选择 `CUBE_M16`（最多 16 个有效行）或 `CUBE_M32`（最多 32 个有效行）。`Layout` 与 `PadValueOrByteId` 是唯一适用的 `B.DATR` 字段。

目标绑定格式错误、出现 `B.IOS`、`B.IOR` 字段多余、`DataType` 不受支持、维度缺失或为零、容量或分配失败时，会在任何效果之前引发 `Fault_TileLegality` 或 `Fault_TileAllocation`。

<!-- PTO-READER-BLOCK: tile-texpands-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

若要用 1.0 填充 `FP32` Tile，应把 `FP32` 编码 `0x3F800000` 放入 `a2`，并写作 `TEXPANDS <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, a2, ->T<2KB>`。7 x 60 = 420 个有效元素保存 `0x3F800000`，其余 92 个物理元素被定义为零。

如果 `a2` 保存的是 1.0 的 `FP64` 编码 `0x3FF0000000000000`，其低 32 位为零，每个有效元素都会变为 `+0.0`，因为不执行任何转换。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TEXPANDS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TEXPANDS | TEPL | 0x03B | 27 | 1 | ExecuteTileFillScalar |

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

### B.IOR.RegSrc0 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local numeric destination |
| scalar0 | per-participating-PE private-GPR scalar |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/initialization/TEXPANDS.asl -->
```asl
readonly func InstructionContractOperation_TEXPANDS() => TileOperation
begin
    return TileOperation_TEXPANDS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TEXPANDS, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR ScalarGPR, zero, zero, ->zero (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/initialization/TEXPANDS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TEXPANDS(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TEXPANDS(
    destination: TileIndex,
    scalar: Word) => boolean
begin
    return TileOperandsLegal_ExecuteTileFillScalar(
        destination,
        scalar);
end;

readonly func InstructionContractHandler_TEXPANDS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileFillScalar;
end;

func InstructionContractExecute_TEXPANDS(
    destination: TileIndex,
    scalar: Word)
begin
    assert InstructionContractOperandsLegal_TEXPANDS(
        destination,
        scalar);
    ExecuteTileFillScalar(
        destination,
        scalar);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol.
- Omitted B.IOR supplies the selected DataType all-zero encoding; explicit all-zero is distinct but supplies the same value.
- Omitted B.DATR selects PadValue=Null. Explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.

## Legality

- TEXPANDS is selected only by the TEPL raw carrier Mode 1 Function 27 and executes on VEC.
- Exactly one terminating Local B.IOT supplies no source and one newly allocated Local numeric destination. B.IOS and additional Tile bindings are illegal.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8; every other type rejects before effects.
- The destination uses selected RowMajor, CUBE_M16, or CUBE_M32 layout; CUBE_M16 valid_rows is at most 16 and CUBE_M32 valid_rows is at most 32, with physical geometry derived from the selected layout and capacity.
- Only RegSrc0 may be nonzero in B.IOR; Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields.
- PE_MASK=0000 is a strict no-op before GPR reads, allocation, faults, or destination effects.

## State effects

- Every valid destination element receives the scalar low element-width raw encoding without conversion.
- Padding definedness and destination descriptor publish atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, dimensions, attributes, type, scalar encoding, mask, capacity, and allocation preflight precedes the private-GPR scalar snapshot.

## Exceptions

- Malformed destination binding, B.IOS presence, surplus B.IOR fields, unsupported DataType, missing or zero dimensions, capacity failure, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation.

## Examples

- BSTART.VEC TEXPANDS, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP
