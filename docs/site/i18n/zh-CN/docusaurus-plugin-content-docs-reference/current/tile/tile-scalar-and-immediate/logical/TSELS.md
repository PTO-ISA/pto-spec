<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/logical/TSELS.asl -->
# TSELS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/logical/TSELS.asl`

Select each result encoding from a Local Tile or scalar under one legacy Predicate, CUBE PredicateCell, or GPR mask carrier.

## Normative identity {#PTO-INST-TILE-TSELS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tsels-purpose role=purpose -->
## TSELS 的作用

`TSELS` 构造一个新的 Local Tile：对有效矩形内的每个元素，选择真值源 Tile 的元素或一个标量。谓词为一时选择 Tile 元素，为零时选择标量。它由 TEPL Mode 1 Function 26（选择器 `0x03A`）选中，规范写法为 `BSTART.VEC TSELS, DataType`，没有独立 opcode。

设计要点：假值备选是标量而不是 Tile。Tile-Tile 形式 `TSEL` 需要第二个源 Tile，因此用它把未选中的元素替换为同一个常量时，必须先构造一个填满该常量的 Tile。`TSELS` 直接从 GPR 获取该常量。

<!-- PTO-READER-BLOCK: tile-c-tsels-mechanism role=mechanism -->
## 选择机制

假值标量来自 `B.IOR` 源寄存器，在每个参与 PE 的私有 GPR 文件中解析。在下述 RowMajor 与 PredicateCell 形式中，省略 `B.IOR` 时标量为所选 `DataType` 的全零编码。

GPR 值由 `TileRawElementValue` 收窄为所选 `DataType` 的低元素位宽位。不发生数值转换。

设计要点：选择是原始拷贝。谓词为一时复制真值源的精确编码，为零时复制收窄后的标量位。两者都不按数值校验，也没有舍入、饱和、规范化或数值状态更新，因此选中 NaN 不会置无效状态。

完整预检在对谓词、真值源与标量做快照之前完成，并且只有在每个元素都选定之后才发布目标。

<!-- PTO-READER-BLOCK: tile-c-tsels-inputs-outputs role=inputs-outputs -->
## 操作数角色与掩码载体

- `source0` 是掩码，其载体取决于下述形式。
- `source1` 是真值源，是已存在的 Local 数值 Tile，并保持不变。
- `scalar0` 是逐 PE 假值标量。
- `destination0` 是新分配的 Local Tile，其 `DataType` 为所选 `DataType`。

三种互斥形式提供掩码：

- RowMajor：`B.IOT` 中的传统打包谓词 Tile，每个元素一位。假值标量为 `B.IOR.RegSrc0`。
- 带 PredicateCell 的 `CUBE_M16` 或 `CUBE_M32`：`B.IOT` 中的 `U8` PredicateCell，其基准类型等于操作 `DataType`。假值标量为 `B.IOR.RegSrc0`。
- 带 GPR 掩码的 `CUBE_M16` 或 `CUBE_M32`：一条只含源的 `B.IOR` 先携带掩码字，再携带假值标量，因此对一字掩码标量是第二个源，对 8 位类型的两字掩码标量是第三个源。

设计要点：`PE_MASK=0000` 是严格无操作。它在任何 GPR 读取、描述符读取、分配、故障或状态效果之前退出，因此没有 PE 参与的指令束永远不会读取标量寄存器。

<!-- PTO-READER-BLOCK: tile-c-tsels-effects role=effects -->
## 发布、已定义性与填充

目标载荷、填充已定义性与描述符作为一个整体发布。被拒绝的指令束没有任何架构效果，`TSELS` 也没有全局内存效果。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero`、`Max` 与 `Min` 定义这些元素；省略 `B.DATR` 时默认的 `Null` 使其保持未定义。

在 CUBE 形式上使用 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，而不是被选中的值。

<!-- PTO-READER-BLOCK: tile-c-tsels-constraints role=constraints -->
## 类型、布局与故障边界

操作 `DataType` 集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。CUBE 形式受进一步限制：PredicateCell 形式不包括 `FP64`、`S64` 与 `U64`，且其基准类型必须等于操作类型；GPR 形式受 GPR 谓词几何限制。

真值源可以使用位宽相同、非打包的其他后备类型；目标始终使用操作 `DataType`。`PadValueOrByteId` 是唯一适用的 `B.DATR` 字段，布局来自源描述符。

掩码字节与真值源元素在每个活动坐标上都必须已定义，PredicateCell 字节必须是规范的 `0x00` 或 `0x01`。载体模式格式错误或混用、PredicateCell 基准类型错误、形状或布局不匹配、容量不足或分配失败时，指令束会在任何效果之前被拒绝。

<!-- PTO-READER-BLOCK: tile-c-tsels-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

以 `FP32` 为例：真值源行 `[-1.5, 2.0]` 与谓词 `[0, 1]`，在省略标量时产生 `[+0.0, 2.0]`：第一个元素取全零标量，第二个元素被复制。

与 `TCMPS` 配合可把负数钳位到零：`TCMPS <Row=8, Col=64, FP32, GE>, T#1, ->U<128B>` 标记不小于零的元素，随后 `TSELS <Row=8, Col=64, FP32>, U#1, T#1, ->T<2KB>` 保留它们，并把 512 个元素中的其余元素替换为 `+0.0`。NaN 元素不会被标记，因此也变为 `+0.0`。
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
| destination0 | new RowMajor or CUBE numeric destination |
| source0 | legacy packed Predicate, CUBE PredicateCell, or GPR mask role |
| source1 | persistent source selected by predicate one |
| scalar0 | independent scalar selected by predicate zero |

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
- Omitted B.IOR supplies the selected operation DataType all-zero false scalar; explicit all-zero is distinct but supplies the same value. TSELS is a raw-carrier operation: predicate-one copies SrcTrue backing bits, predicate-zero copies the scalar's normalized low physical bits, publishes the destination with the operation DataType, does not require TileNumericEncodingValid for selected source or scalar payloads, and performs no conversion or numeric-status update.
- Omitted B.DATR selects PadValue=Null. Explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.

## Legality

- TSELS selects TEPL Mode 1 Function 26 and executes on VEC. PE_MASK=0000 is a strict no-op before GPR, predicate, source, allocation, or payload checks.
- Legacy RowMajor form uses one terminating B.IOT with packed Predicate, SrcTrue, and one new destination; one B.IOR source supplies scalar-false or omission selects the operation-type zero, and the source backing is checked independently; exact backing/operation type identity is legal, while a cross-type source/backing pair requires equal width and a non-four-bit carrier.
- CUBE_M16/M32 PredicateCell form uses one terminating B.IOT with a descriptor-valid PredicateCell whose basis equals the operation DataType and whose ExecutionMask-active bytes are defined and canonical, SrcTrue, and one new CUBE destination plus an optional scalar-false B.IOR source; omission selects the operation-type zero. The true-source backing is checked independently; exact backing/operation type identity is legal, while a cross-type source/backing pair requires equal width and a non-four-bit carrier.
- CUBE_M16/M32 GPR form uses one B.IOT with SrcTrue and one new CUBE destination. One source-only B.IOR carries the complete predicate mask followed by the independent scalar-false source: two sources for one-word masks and three for U8's two-word mask. The operation type is a 32-bit or 16-bit type from the closed CUBE domain, plus U8; the true-source backing is checked independently; exact backing/operation type identity is legal, while a cross-type source/backing pair requires equal width and a non-four-bit carrier.
- Legacy, PredicateCell, and GPR forms are complete and mutually exclusive. PadValueOrByteId is the only applicable B.DATR field.

## State effects

- Predicate bit one copies the exact SrcTrue backing encoding and bit zero copies the normalized operation-type scalar encoding.
- Selection performs no rounding, saturation, canonicalization, or numeric-status update.
- Selected payload, padding definedness, and destination descriptor publish atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, dimensions, attributes, predicate-kind, source-definedness, scalar encoding, mask, capacity, and allocation preflight precedes snapshots.
- Predicate bits, true-source payload, and scalar are snapshotted before destination publication.

## Exceptions

- Malformed or mixed carrier schemas, unsupported type, wrong operation-type PredicateCell basis, noncanonical or undefined ExecutionMask-active predicate bytes, undefined active source data, shape/layout mismatch, insufficient destination capacity, or allocation failure rejects before effects.
- TSELS copies raw carrier encodings and does not itself raise floating invalid for a selected NaN payload.

## Examples

- BSTART.VEC TSELS, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT Predicate, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarFalseGPR, zero, zero, ->zero (optional); BSTOP
