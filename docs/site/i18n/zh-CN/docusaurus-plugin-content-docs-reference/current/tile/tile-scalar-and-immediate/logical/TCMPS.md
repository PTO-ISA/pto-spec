<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl -->
# TCMPS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl`

Compare each valid Local Tile element with one private-GPR scalar and produce a packed predicate Tile.

## Normative identity {#PTO-INST-TILE-TCMPS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcmps-purpose role=purpose -->
## TCMPS 的作用

`TCMPS` 是一条由 `VEC` 执行、通过选择器编码的 Tile 操作。它按照 `CMode` 把每个有效数值元素与一个私有 GPR 标量比较，并紧凑存放谓词；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-tcmps-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数按照 `CMode` 把每个有效数值元素与一个私有 GPR 标量比较，并紧凑存放谓词。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-tcmps-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“新分配的紧凑 Local 谓词目标”。
- `source0` 的精确契约角色是“持久 Local 数值源”。
- `scalar0` 的精确契约角色是“每个参与 PE 的私有 GPR 标量”。
- `comparison` 的精确契约角色是“六模式比较”。

参与操作的源与目标描述符采用当前契约规定的行优先布局和形状关系。
操作读取的每个源坐标都必须在目标发布前处于已定义状态。
`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-tcmps-effects role=effects -->
## 发布、已定义性与填充

只有完整预检后才发布目标可见状态；契约规定原子发布时，载荷、描述符、已定义性、填充和状态同时可见。

有效矩形之外的物理坐标遵循契约选择的填充规则；适用时，`Null` 填充保持未定义。

该操作不产生 GM 内存效果；描述符、载荷、已定义性、填充和数值状态变化仅限于当前契约列出的项目。

<!-- PTO-READER-BLOCK: tile-tcmps-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-tcmps-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TCMPS` 示例说明：在大于模式下，`[1, 3]` 与标量 `2` 比较后产生 `[0, 1]`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TCMPS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCMPS | TEPL | 0x02D | 13 | 1 | ExecuteTileCompareScalar |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.DATR.CMode (`PTO-FIELD-BLOCK-CMODE`)

Selects the comparison relation used by TCMP and TCMPS.

**Encoded zero:** Code zero selects equality comparison.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | EQ |
| 1 | assigned | NE |
| 2 | assigned | LT |
| 3 | assigned | GT |
| 4 | assigned | LE |
| 5 | assigned | GE |
| 6 | reserved | future extension |
| 7 | reserved | future extension |

**Reserved-value behavior:** Codes 6 and 7 are reserved and reject before architectural effects.

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
| destination0 | new packed Local predicate destination |
| source0 | persistent Local numeric source |
| scalar0 | per-participating-PE private-GPR scalar |
| comparison | six-mode comparison |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl -->
```asl
readonly func InstructionContractOperation_TCMPS() => TileOperation
begin
    return TileOperation_TCMPS;
end;

pure func InstructionContractComparisonCodeLegal_TCMPS(
    comparison_code: bits(3)) => boolean
begin
    return UInt(comparison_code) <= 5;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TCMPS, DataType
B.DATR CMode, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->Predicate<TSize>
B.IOR ScalarGPR, zero, zero, ->zero (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCMPS(
    data_type: TileDataType) => boolean
begin
    return TileCompareDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCMPS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word,
    comparison: TileComparison) => boolean
begin
    return TileOperandsLegal_ExecuteTileCompareScalar(
        destination,
        source,
        scalar,
        comparison);
end;

readonly func InstructionContractHandler_TCMPS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileCompareScalar;
end;

func InstructionContractExecute_TCMPS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word,
    comparison: TileComparison)
begin
    assert InstructionContractOperandsLegal_TCMPS(
        destination,
        source,
        scalar,
        comparison);
    ExecuteTileCompareScalar(
        destination,
        source,
        scalar,
        comparison);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- CMode codes 0, 1, 2, 3, 4, and 5 select EQ, NE, LT, GT, LE, and GE; codes 6 and 7 are reserved. Omitted B.DATR selects EQ.
- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.
- Omitted B.IOR supplies the selected source DataType all-zero scalar encoding. Omitted PadValue selects Null predicate padding.

## Legality

- TCMPS is selected only by the TEPL raw carrier Mode 1 Function 13 and executes on VEC.
- Exactly one terminating Local B.IOT supplies one persistent numeric source and one new packed predicate destination. B.IOS and additional Tile bindings are illegal.
- The source DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- The source is row-major and completely defined. The predicate destination has matching logical geometry and capacity of at least ceil(Row*Col/8) bytes.
- Only CMode and PadValueOrByteId are applicable in B.DATR. When B.IOR is present, only RegSrc0 may be nonzero.
- PE_MASK=0000 is a strict no-op before GPR, source, allocation, status, or payload checks.

## State effects

- Logical element i publishes its comparison result in bit i mod 8 of byte floor(i/8), with low logical indices in low bits.
- Zero and Min padding write zero predicate bits, Max writes one bits, and Null leaves padding undefined.
- Packed payload, padding definedness, numeric status, and destination descriptor publish atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, dimensions, attributes, type, source, scalar, predicate capacity, mask, and allocation preflight precedes source and scalar snapshots.
- The source payload and scalar are snapshotted before packed destination publication.

## Exceptions

- Malformed bindings, B.IOS presence, surplus B.IOR fields, reserved CMode, unsupported DataType, undefined or invalid source encoding, predicate capacity failure, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.
- Signaling floating NaN records invalid only with the atomically published predicate destination.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation.

## Examples

- BSTART.VEC TCMPS, DataType; B.DATR CMode, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->Predicate<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP
