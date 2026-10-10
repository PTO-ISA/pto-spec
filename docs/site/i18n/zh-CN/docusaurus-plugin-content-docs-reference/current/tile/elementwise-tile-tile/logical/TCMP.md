<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TCMP.asl -->
# TCMP

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TCMP.asl`

Compare two Local numeric Tiles and produce one legacy Predicate, CUBE PredicateCell, or GPR carrier.

## Normative identity {#PTO-INST-TILE-TCMP}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcmp-purpose role=purpose -->
## TCMP 的作用

`TCMP` 比较两个 Local 数值 Tile 的对应元素，并为每个元素产生一个真或假的结果。这些结果构成一个谓词：一个可供 `TSEL` 等后续操作使用的掩码。比较模式由 `CMode` 选择，为 `EQ`、`NE`、`LT`、`GT`、`LE` 或 `GE` 之一。

设计要点：`TCMP` 没有独立 opcode。它由 `BSTART.VEC` Mode 0 Function 13（TEPL 选择器 `0x00D`）选中。`CMode` 编码 0 至 5 依次选择 `EQ`、`NE`、`LT`、`GT`、`LE` 与 `GE`；编码 6 与 7 保留。省略 `B.DATR` 时 `CMode` 保持为零，因此默认比较为 `EQ`。

<!-- PTO-READER-BLOCK: tile-tcmp-mechanism role=mechanism -->
## 元素与 Tile 机制

完整预检通过后，`TCMP` 快照两个源，并在所选操作 `DataType` 下比较有效矩形 `ValidRow x ValidCol` 内的每个坐标。

- 有符号整数类型使用有符号序，无符号整数类型使用无符号序。
- 浮点类型使用数值序。正零与负零比较相等。
- 若任一浮点操作数为 NaN，`NE` 为真，其余模式均为假。信号 NaN 还会记录无效条件。

设计要点：与 `TAND` 或 `TSEL` 等原始载体操作不同，`TCMP` 必须解释数值才能排序。因此它比较的每个源元素都必须是操作 `DataType` 的合法编码，无效编码会在任何效果之前被拒绝。

设计要点：所选 `BSTART.VEC` `DataType` 就是比较类型，每个源的后备类型分别检查。源可以使用位宽相同、非打包的其他后备类型；此时其位按操作类型比较。源描述符不会被重新标记。

<!-- PTO-READER-BLOCK: tile-tcmp-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是左数值源，`source1` 是右数值源。`LT` 判断左值是否小于右值。
- `comparison` 是 `CMode` 关系。
- `destination0` 在传统形式与 PredicateCell 形式中接收谓词。GPR 形式中没有该操作数。

谓词只在三种互斥载体之一中发布。`RowMajor` 源选择传统形式。`CUBE_M16` 或 `CUBE_M32` 源在 `B.IOT` 指定目标时选择 PredicateCell 形式，在改为绑定仅含目标的 `B.IOR` 时选择 GPR 形式。`B.DATR` 的 `Layout` 字段必须保持为零。 64 位 CUBE 操作数要求 `CUBE_M32` double-CELL 映射；`CUBE_M16` 会拒绝。

| 形式 | 源布局 | 结果载体 |
| --- | --- | --- |
| 传统 | `RowMajor` | 新的打包 Predicate Tile：每个元素一位，元素 `i` 位于字节 `floor(i/8)` 的第 `i mod 8` 位 |
| PredicateCell | `CUBE_M16` 或 `CUBE_M32` | 新的 `U8` PredicateCell Tile：每个元素一个规范字节，取值 `0x00` 或 `0x01` |
| GPR | `CUBE_M16` 或 `CUBE_M32` | 通过仅含目标的 `B.IOR` 写入的一个 64 位 GPR |

设计要点：PredicateCell 记录其基准类型，即产生它的比较所用的操作 `DataType`。把 PredicateCell 用作选择子的 `TSEL` 要求该基准等于自身的操作 `DataType`，因此为某种元素类型构造的选择子用于另一种类型的数据时会被拒绝。通用 ExecutionMask 使用不做这项基准检查。

在 GPR 形式中，操作类型决定掩码字的位域几何。对 8 位操作类型，`Sat` 选择谓词列的 Low 或 High 半部分；对更宽的类型，`Sat` 必须为零。

<!-- PTO-READER-BLOCK: tile-tcmp-effects role=effects -->
## 发布、已定义性与填充

载荷、谓词填充、数值状态、描述符或 GPR 结果以及已定义性同时发布。被拒绝的 `TCMP` 不改变任何架构状态。由于两个源先被快照，相同的源以及与目标互为别名的源都读取旧值。

有效矩形之外的谓词位置遵循 `PadValue`。`Zero` 与 `Min` 写入假，`Max` 写入真，而 `Null`（省略 `B.DATR` 时的默认值）按载体不同使其未定义或未规定。

CUBE 形式可以使用显式 ExecutionMask。活动坐标正常比较。非活动坐标在 MERGE 下保留旧的谓词位或单元，在 ZERO 下写入零，且不贡献数值状态。`TCMP` 没有全局内存效果。

<!-- PTO-READER-BLOCK: tile-tcmp-constraints role=constraints -->
## 类型、布局与故障边界

操作类型集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。传统 RowMajor 接受完整集合。PredicateCell 与 GPR CUBE 形式也接受 `FP64`、`S64` 与 `U64`，但数值源必须使用 `CUBE_M32` double-CELL 描述符；`CUBE_M16` 拒绝这些 64 位 basis 类型。GPR 形式还要求有效形状符合由类型推导的掩码几何。

`PE_MASK=0000` 是严格无操作，发生在任何模式、源、分配、GPR 或状态检查之前。否则，载体模式格式错误或混用、维度缺失、`CMode` 为保留值、`DataType` 不受支持、形状、布局或位宽不匹配、源数据未定义或无效、目标容量不足或分配失败时，会在读取源或产生效果之前被拒绝。非零的 `Canonicalize`、第二 `DataType`、`RMode` 或 `Layout` 均非法。

<!-- PTO-READER-BLOCK: tile-tcmp-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `DataType=S32` 且 `CMode=LT` 时，左源行 `[1, 3, -5]` 与右源行 `[2, 3, 4]` 产生谓词值 `[1, 0, 1]`。在 `DataType=U32` 下，相同的位把 `-5` 当作 `0xFFFFFFFB` 比较，因此第三个结果变为 0。

宏形式 `TCMP <Row=8, Col=64, FP32, LT>, T#1, T#2, ->U<512B>` 比较两个 `RowMajor` `FP32` Tile，结果写入新的打包 Predicate Tile `U#1`。其 512 个谓词位占用 64 字节。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TCMP <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCMP | TEPL | 0x00D | 13 | 0 | ExecuteTileCompare |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | legacy packed Predicate or CUBE PredicateCell destination; absent for GPR producer |
| source0 | ordered left Local numeric source |
| source1 | ordered right Local numeric source |
| comparison | EQ, NE, LT, GT, LE, or GE selected by CMode |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TCMP.asl -->
```asl
readonly func InstructionContractOperation_TCMP() => TileOperation
begin
    return TileOperation_TCMP;
end;

pure func InstructionContractComparisonCodeLegal_TCMP(
    comparison_code: bits(3)) => boolean
begin
    return UInt(comparison_code) <= 5;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TCMP, DataType
B.DATR CMode, PadValue, SatMode (U8 GPR form only)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->PredicateCell<TSize> OR no destination
B.IOR predicate-GPR destination (GPR form only)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TCMP.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCMP(
    data_type: TileDataType) => boolean
begin
    return TileCompareDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCMP(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    comparison: TileComparison) => boolean
begin
    return TileOperandsLegal_ExecuteTileCompare(
        destination,
        source_left,
        source_right,
        comparison);
end;

readonly func InstructionContractHandler_TCMP() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileCompare;
end;

func InstructionContractExecute_TCMP(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    comparison: TileComparison)
begin
    assert InstructionContractOperandsLegal_TCMP(
        destination,
        source_left,
        source_right,
        comparison);
    ExecuteTileCompare(
        destination,
        source_left,
        source_right,
        comparison);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- CMode codes 0, 1, 2, 3, 4, and 5 select EQ, NE, LT, GT, LE, and GE. Codes 6 and 7 are reserved. Omitted B.DATR retains CMode zero and therefore selects EQ.
- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.
- Omitted B.DATR selects predicate PadValue=Null. Explicit PadValue 00 and 10 write zero padding bits, 01 writes one padding bits, and 11 leaves padding bits undefined.

## Legality

- TCMP selects VEC Mode 0 Function 13. PE_MASK=0000 is a strict no-op before schema, descriptor, source, allocation, GPR, status, or payload checks.
- Legacy RowMajor form uses one terminating B.IOT with two numeric sources and one new packed Predicate destination; B.IOR is absent, the existing sixteen-type operation domain remains unchanged, and each source backing DataType is checked independently; exact backing/operation type identity is legal, while cross-type source/backing pairs require equal width and non-four-bit carriers.
- CUBE_M16/M32 PredicateCell form uses one terminating B.IOT with two numeric sources and one new U8 PredicateCell destination tagged with the operation DataType; B.IOR is absent, each source backing DataType is checked independently; exact backing/operation type identity is legal, while cross-type source/backing pairs require equal width and non-four-bit carriers, and the operation type is exactly one of FP64, S64, U64 (these three only for CUBE_M32), FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S32, S16, S8, U32, U16, or U8.
- CUBE_M16/M32 GPR form uses one terminating source-only B.IOT plus one destination-only B.IOR. The operation type is a 32-bit or 16-bit type from the closed CUBE domain, plus U8, or FP64/S64/U64 for CUBE_M32; each source backing DataType is checked independently; exact backing/operation type identity is legal, while cross-type source/backing pairs require equal width and non-four-bit carriers; one 64-bit GPR is written atomically, and U8 Sat selects Low or High predicate columns derived from the operation type.
- Legacy, PredicateCell, and GPR carriers are complete and mutually exclusive. CMode and PadValue apply to every form; Sat is nonzero only for U8 GPR selection; Canonicalize, secondary DataType, RMode, and Layout remain zero.
- Predicate padding is Zero/Min=0, Max=1, and Null unspecified or undefined according to the selected GPR/PredicateCell carrier.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Compare corresponding valid source elements under the selected operation type's signed, unsigned, or floating relation.
- Publish exactly one selected predicate carrier: legacy packed bits, canonical PredicateCell bytes 0x00/0x01 with basis tag, or one 64-bit GPR predicate word.
- Payload, predicate padding, numeric status, descriptor/GPR result, and definedness publish atomically; rejection leaves all architectural state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, field, type, geometry, layout, definedness, encoding, mask, and packed-capacity preflight precedes source snapshots and destination allocation.
- Both source payloads are snapshotted before comparison, so identical sources and logical source/destination aliases observe read-old values.

## Exceptions

- Malformed or mixed carrier schemas, missing dimensions, reserved CMode, unsupported DataType, mismatched CUBE physical shape/layout or incompatible source width, undefined or invalid source data, insufficient destination capacity, or allocation failure rejects before source reads or effects.
- A signaling floating NaN records invalid status only with the atomically published GPR or PredicateCell result.

## Examples

- BSTART.VEC TCMP, U64; B.DATR EQ, Null (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->Predicate<TSize>; BSTOP
