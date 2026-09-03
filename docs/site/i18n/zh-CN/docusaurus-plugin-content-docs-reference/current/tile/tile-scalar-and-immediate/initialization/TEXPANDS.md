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

`TEXPANDS` 是一条由 `VEC` 执行、通过选择器编码的 Tile 操作。它把标量低元素位宽的原始编码复制到每个有效目标坐标；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-texpands-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数把标量低元素位宽的原始编码复制到每个有效目标坐标。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-texpands-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“新分配的 Local 数值目标”。
- `scalar0` 的精确契约角色是“每个参与 PE 的私有 GPR 标量”。

目标描述符采用所选的 RowMajor、CUBE_M16 或 CUBE_M32 布局，并遵循当前契约规定的逻辑形状。
`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-texpands-effects role=effects -->
## 发布、已定义性与填充

只有完整预检后才发布目标可见状态；契约规定原子发布时，载荷、描述符、已定义性、填充和状态同时可见。

有效矩形之外的物理坐标遵循契约选择的填充规则；适用时，`Null` 填充保持未定义。

该操作不产生 GM 内存效果；描述符、载荷、已定义性、填充和数值状态变化仅限于当前契约列出的项目。

<!-- PTO-READER-BLOCK: tile-texpands-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合为 `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-texpands-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TEXPANDS` 示例说明：FP32 标量 `1.0` 的原始编码原样复制到每个有效 FP32 目标元素。
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
