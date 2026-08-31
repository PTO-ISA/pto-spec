<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/logical/TSELS.asl -->
# TSELS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/logical/TSELS.asl`

Select each result encoding from a Local Tile or private-GPR scalar under one packed predicate Tile.

## Normative identity {#PTO-INST-TILE-TSELS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tsels-purpose role=purpose -->
## TSELS 的作用

`TSELS` 在打包谓词 Tile 控制下，从 Tile 源或逐 PE 标量选择结果。

<!-- PTO-READER-BLOCK: tile-c-tsels-mechanism role=mechanism -->
## 操作机制

谓词位为零时选择假输入，为一时选择真输入；选中的载体位会原样复制，不执行数值转换。

<!-- PTO-READER-BLOCK: tile-c-tsels-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `destination0` 标识新分配的目的 Tile。

- `source0` 提供打包谓词 Tile。

- `source1` 提供持久源 Tile。

- `scalar0` 提供逐 PE 标量操作数。

- 封闭的适用 DataType 集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。

- 除非该助记符显式选择其他允许布局，数据 Tile 使用行主序布局。

- `LB0`、`LB1`、`LB2` 按该助记符契约补全有效形状与物理形状；所有必需有效范围都必须非零。

<!-- PTO-READER-BLOCK: tile-c-tsels-effects role=effects -->
## 已定义性、填充与发布

所有源描述符与载荷都会在目标发布前完成验证和快照。

完整目标载荷、描述符、已定义性、填充状态与适用数值状态会原子发布；拒绝路径不发布任何部分。

Null 填充让有效矩形外的物理坐标保持未定义；显式非 Null 填充值会用选定带类型的值定义这些位置。

源 Tile 在成功执行后保持不变。

<!-- PTO-READER-BLOCK: tile-c-tsels-constraints role=constraints -->
## 合法性、故障与顺序边界

完整绑定模式、维度、DataType、布局、源已定义性、数值编码、目标容量与分配都会在效果前预检。

合法性或分配检查失败会引发相应 Tile 故障，不留下部分目标、状态或内存效果。

`PE_MASK=0000` 是严格无操作，发生在操作数读取、分配、故障、数值状态或载荷效果之前。

<!-- PTO-READER-BLOCK: tile-c-tsels-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

`TSELS <bundle operands>` 先完成完整预检与源快照，再原子发布助记符定义的结果与填充状态。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TSELS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSELS | TEPL | 0x03A | 26 | 1 | ExecuteTileSelectScalar |

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
| source0 | packed Local predicate mask |
| source1 | persistent Local source selected by one |
| scalar0 | per-participating-PE scalar selected by zero |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/logical/TSELS.asl -->
```asl
readonly func InstructionContractOperation_TSELS() => TileOperation
begin
    return TileOperation_TSELS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TSELS, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT PredicateCell, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize> OR GPR predicate form without PredicateCell
B.IOR predicate-GPR source and optional scalar-false source
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/logical/TSELS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSELS(
    data_type: TileDataType) => boolean
begin
    return TileSelectDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TSELS(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    scalar_false: Word) => boolean
begin
    return TileOperandsLegal_ExecuteTileSelectScalar(
        destination,
        predicate,
        source_true,
        scalar_false);
end;

readonly func InstructionContractHandler_TSELS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileSelectScalar;
end;

func InstructionContractExecute_TSELS(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    scalar_false: Word)
begin
    assert InstructionContractOperandsLegal_TSELS(
        destination,
        predicate,
        source_true,
        scalar_false);
    ExecuteTileSelectScalar(
        destination,
        predicate,
        source_true,
        scalar_false);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol.
- Omitted B.IOR supplies the selected DataType all-zero false scalar; explicit all-zero is distinct but supplies the same value. TSELS is a raw-carrier operation: predicate-one copies SrcTrue carrier bits, predicate-zero copies the scalar's low physical carrier bits, preserves the concrete DataType, does not require TileNumericEncodingValid for selected source or scalar payloads, and performs no conversion or numeric-status update.
- Omitted B.DATR selects PadValue=Null. Explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.

## Legality

- TSELS is selected only by the TEPL raw carrier Mode 1 Function 26 and executes on VEC.
- Exactly one terminating Local B.IOT supplies packed Predicate, numeric SrcTrue, and one newly allocated numeric destination. B.IOS and additional Tile bindings are illegal.
- The data DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8; every other type rejects before effects.
- Predicate uses packed predicate-kind storage with matching logical geometry and every valid bit defined. SrcTrue and destination match physical shape, valid shape, row-major layout, and DataType; numeric encoding validity is not required for selected source or scalar carrier payloads.
- Only RegSrc0 may be nonzero in B.IOR and only PadValueOrByteId is applicable in B.DATR.
- PE_MASK=0000 is a strict no-op before GPR, predicate, source, allocation, or payload checks.
- CUBE forms accept exactly one explicit predicate carrier. CellReg mask is the first B.IOT PredicateCell source and may still use scalar-false B.IOR; GPR mask uses predicate-specific B.IOR and may use the independent scalar-false source. Presence of B.IOR alone never selects the carrier.

## State effects

- Predicate bit one copies the exact SrcTrue element encoding and bit zero copies the normalized low-width scalar encoding.
- Selection performs no rounding, saturation, canonicalization, or numeric-status update.
- Selected payload, padding definedness, and destination descriptor publish atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, dimensions, attributes, predicate-kind, source-definedness, scalar encoding, mask, capacity, and allocation preflight precedes snapshots.
- Predicate bits, true-source payload, and scalar are snapshotted before destination publication.

## Exceptions

- Malformed binding order, B.IOS presence, surplus B.IOR fields, unsupported type, ordinary numeric mask storage, undefined predicate or true-source data, shape mismatch, capacity failure, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.
- Selection copies exact encodings and does not itself raise floating invalid for a selected NaN.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation.
- CUBE forms accept exactly one explicit predicate carrier. CellReg mask is the first B.IOT PredicateCell source and may still use scalar-false B.IOR; GPR mask uses predicate-specific B.IOR and may use the independent scalar-false source. Presence of B.IOR alone never selects the carrier.

## Examples

- BSTART.VEC TSELS, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT Predicate, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarFalseGPR, zero, zero, ->zero (optional); BSTOP
