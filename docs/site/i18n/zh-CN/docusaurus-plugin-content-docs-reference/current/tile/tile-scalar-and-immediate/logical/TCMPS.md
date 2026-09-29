<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl -->
# TCMPS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/logical/TCMPS.asl`

Compare each valid Local Tile element with a scalar and produce one legacy Predicate, CUBE PredicateCell, or GPR carrier.

## Normative identity {#PTO-INST-TILE-TCMPS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcmps-purpose role=purpose -->
## TCMPS 的作用

`TCMPS` 把 Local 源 Tile 有效矩形内的每个元素与一个标量比较，并为每个元素产生一个谓词。它由 TEPL Mode 1 Function 13（选择器 `0x02D`）选中，规范写法为 `BSTART.VEC TCMPS, DataType`，没有独立 opcode。

设计要点：标量是指令束操作数，而不是 Tile。Tile-Tile 形式 `TCMP` 需要第二个形状相同的源 Tile，因此用它与单个阈值比较时，必须先构造一个填满该阈值的 Tile。`TCMPS` 直接从 GPR 读取阈值，因此不需要分配广播 Tile，也不需要使其成为已定义。

<!-- PTO-READER-BLOCK: tile-tcmps-mechanism role=mechanism -->
## 标量来源与比较机制

标量来自 `B.IOR.RegSrc0`。每个参与的 PE 在自己的私有 GPR 文件中解析该选择器。指令束中没有用于标量的立即数字段；省略 `B.IOR` 时标量为所选 `DataType` 的全零编码。

64 位 GPR 值由 `TileRawElementValue` 收窄：只保留与所选 `DataType` 元素位宽一致的低 8、16、32 或 64 位。不发生数值转换，因此浮点标量必须已经是所选类型的编码。

`B.DATR.CMode` 选择比较方式：编码 0、1、2、3、4、5 分别选择 EQ、NE、LT、GT、LE、GE。编码 6 与 7 保留并被拒绝。省略 `B.DATR` 时选择 EQ。

Tile 元素始终是左操作数，因此当 `source < scalar` 时 LT 为真。有符号与无符号整数分别按有符号值与无符号值比较。对浮点类型，任何 NaN 只使 NE 为真，信号 NaN 置无效状态，且 `+0.0` 等于 `-0.0`。

设计要点：所选 `DataType` 是操作类型。它决定标量收窄方式、比较方式以及谓词几何，而源保留自己的后备类型。因此位宽相同、非打包的源无需拷贝即可按另一种解释进行比较。

<!-- PTO-READER-BLOCK: tile-tcmps-inputs role=inputs-outputs -->
## 操作数角色与结果载体

- `source0` 是已存在的 Local 数值 Tile，并保持不变。
- `scalar0` 是逐 PE 标量，是每次比较的右操作数。
- `comparison` 是六种模式之一的 `CMode` 值。
- `destination0` 是新的谓词目标；当结果写入 GPR 时它不存在。

源布局从三种互斥的结果形式中选择一种：

- RowMajor 源：新的传统打包谓词 Tile。逻辑元素 `i = row x Col + column` 位于第 `floor(i / 8)` 字节的第 `i mod 8` 位，因此该 Tile 至少需要 `ceil(Row x Col / 8)` 字节。
- 带 `B.IOT` 目标的 `CUBE_M16` 或 `CUBE_M32` 源：新的 `U8` PredicateCell Tile，每个元素一个字节，其基准类型为操作 `DataType`。
- 不带 `B.IOT` 目标的 `CUBE_M16` 或 `CUBE_M32` 源：由 `B.IOR.RegDst` 指定的一个 GPR。对 8 位类型，`Sat` 选择低半或高半列。

设计要点：`PE_MASK=0000` 是严格无操作。它在任何 GPR 读取、描述符读取、分配、故障或状态效果之前退出，因此没有 PE 参与的指令束永远不会读取标量寄存器。

<!-- PTO-READER-BLOCK: tile-tcmps-effects role=effects -->
## 发布、已定义性与填充

所选载体作为一个整体发布：谓词载荷、其填充、任何数值状态以及目标描述符或 GPR 值同时变为可见。被拒绝的指令束没有任何架构效果。

`ValidRow x ValidCol` 之外的谓词位置遵循 `PadValue`：`Zero` 与 `Min` 写入零位，`Max` 写入值为一的位，默认的 `Null` 使其保持未定义。

设计要点：省略 `B.IOR` 时与所选类型的零比较。因此对有符号整数与浮点类型，`CMode` 为 LT 且不带标量的 `TCMPS` 就是符号测试；`-0.0` 与零相等，NaN 元素在 LT 与 GE 下都得到零。对无符号类型，LT 恒得到零，GE 恒得到一。

`TCMPS` 没有全局内存效果。在 CUBE 形式上使用 ExecutionMask 时，非活动坐标保留旧谓词（合并）或接收零，并且不产生数值状态。

<!-- PTO-READER-BLOCK: tile-tcmps-constraints role=constraints -->
## 类型、布局与故障边界

操作 `DataType` 集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。PredicateCell 形式不包括 `FP64`、`S64` 与 `U64`，GPR 形式还受 GPR 谓词几何的进一步限制。

`B.DATR` 接受 `CMode`、`PadValueOrByteId` 与 `Sat`；`Sat` 只在 8 位 GPR 形式中合法，`Canonicalize` 必须保持为零。没有 `Layout` 字段：布局来自源描述符。

载体模式格式错误或混用、维度缺失、`CMode` 为保留值、`DataType` 不受支持、源元素未定义、源或标量编码对操作类型无效、谓词容量不足或分配失败时，指令束会在任何效果之前被拒绝。

<!-- PTO-READER-BLOCK: tile-tcmps-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以 `CMode` 为 GT 的 `S32` 为例：源行 `[1, 3]` 与标量 `2` 产生谓词 `[0, 1]`。

对 8 x 64 = 512 个元素的 RowMajor `FP32` 源，`TCMPS <Row=8, Col=64, FP32, GT>, T#1, a2, ->U<128B>` 写入 512 个谓词位，占满 64 字节。第 1 行第 3 列的元素逻辑索引为 67，位于第 8 字节第 3 位。
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
| destination0 | legacy packed Predicate or CUBE PredicateCell destination; absent for GPR producer |
| source0 | persistent Local numeric source |
| scalar0 | per-participating-PE compare scalar |
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
B.DATR CMode, PadValue, SatMode (U8 GPR form only)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->PredicateCell<TSize> OR no destination
B.IOR scalar-compare source and optional predicate-GPR destination
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
- Omitted B.IOR supplies the selected operation DataType all-zero scalar encoding. Omitted PadValue selects Null predicate padding.

## Legality

- TCMPS selects TEPL Mode 1 Function 13 and executes on VEC. PE_MASK=0000 is a strict no-op before GPR, source, allocation, status, or payload checks.
- Legacy RowMajor form uses one terminating B.IOT with source and new packed Predicate destination; one optional B.IOR supplies the compare scalar, and the source backing DataType is checked independently; exact backing/operation type identity is legal, while a cross-type source/backing pair requires equal width and a non-four-bit carrier.
- CUBE_M16/M32 PredicateCell form uses one terminating B.IOT with source and new U8 PredicateCell destination whose basis is the operation DataType plus an optional scalar-source B.IOR; omission selects the operation-type zero. The source backing DataType is checked independently; exact backing/operation type identity is legal, while a cross-type source/backing pair requires equal width and a non-four-bit carrier, and the operation type is exactly one of FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S32, S16, S8, U32, U16, or U8.
- CUBE_M16/M32 GPR form uses one source-only B.IOT and one B.IOR carrying the scalar source plus one destination GPR. The operation type is a 32-bit or 16-bit type from the closed CUBE domain, plus U8; the source backing DataType is checked independently; exact backing/operation type identity is legal, while a cross-type source/backing pair requires equal width and a non-four-bit carrier and U8 Sat selects Low or High columns derived from the operation type.
- Legacy, PredicateCell, and GPR forms are complete and mutually exclusive. CMode and PadValue apply to all; Sat is nonzero only for U8 GPR selection; Canonicalize remains zero.

## State effects

- Each valid comparison publishes through the selected carrier under the operation type: legacy low-first packed bit, canonical PredicateCell byte, or GPR predicate bit.
- Zero and Min padding write zero predicate bits, Max writes one bits, and Null leaves padding undefined.
- Selected carrier payload, padding, numeric status, and descriptor or GPR result publish atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, dimensions, attributes, type, source, scalar, predicate capacity, mask, and allocation preflight precedes source and scalar snapshots.
- The source payload and scalar are snapshotted before packed destination publication.

## Exceptions

- Malformed or mixed carrier schemas, missing dimensions, reserved CMode, unsupported DataType, undefined or operation-type-invalid source/scalar data, insufficient PredicateCell capacity, or allocation failure rejects before effects.
- Signaling floating NaN status publishes atomically with the selected GPR or PredicateCell result.

## Examples

- BSTART.VEC TCMPS, DataType; B.DATR CMode, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->Predicate<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP
