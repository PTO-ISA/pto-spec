<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TSEL.asl -->
# TSEL

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TSEL.asl`

Select exact element encodings under one legacy Predicate, CUBE PredicateCell, or GPR mask carrier.

## Normative identity {#PTO-INST-TILE-TSEL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tsel-purpose role=purpose -->
## TSEL 的作用

`TSEL` 在谓词控制下从两个源 Tile 之一选取每个元素，构造一个新的 Local Tile。谓词为 1 处取 `SrcTrue` 的元素，为 0 处取 `SrcFalse` 的元素。谓词通常由 `TCMP` 产生。

设计要点：`TSEL` 没有独立 opcode。它由 `BSTART.VEC` Mode 0 Function 26（TEPL 选择器 `0x01A`）选中。`PadValueOrByteId` 是唯一适用的 `B.DATR` 字段。

<!-- PTO-READER-BLOCK: tile-c-tsel-mechanism role=mechanism -->
## 操作机制

完整预检通过后，`TSEL` 快照谓词与两个数据源。对有效矩形 `ValidRow x ValidCol` 内的每个坐标，它读取谓词，并把所选源元素的精确位拷贝到目标。

设计要点：`TSEL` 是原始载体操作。它不要求被选载荷是操作 `DataType` 的合法编码，也不做转换、舍入、饱和、规范化或数值状态更新。被选中的 NaN 保留其载荷，信号 NaN 也不会引发无效。在两个值之间做选择不需要算术，因此目标保存的正是被选中的位。

设计要点：所选操作 `DataType` 仍然有作用。它是目标后备类型，并决定每个源后备类型必须匹配的元素位宽。在 PredicateCell 形式中它必须等于 PredicateCell 基准，在 GPR 形式中它决定掩码字几何。数值编码校验留给之后解释这些值的操作。

<!-- PTO-READER-BLOCK: tile-c-tsel-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `source0` 是谓词：打包 Predicate Tile、CUBE PredicateCell Tile，或第一个掩码 GPR。
- `source1` 是 `SrcTrue`，即谓词为 1 处选中的 Tile。
- `source2` 是 `SrcFalse`，即谓词为 0 处选中的 Tile。
- `destination0` 是新分配的 `RowMajor` 或 CUBE 数值 Tile，其 `DataType` 为所选操作 `DataType`。

`TSEL` 恰好使用三种互斥谓词载体之一。

| 形式 | 数据布局 | 绑定 |
| --- | --- | --- |
| 传统 | `RowMajor` | `B.IOT` Predicate、SrcTrue；然后 `B.IOT` SrcFalse 与新目标 |
| PredicateCell | `CUBE_M16` 或 `CUBE_M32` | 相同的两条 `B.IOT` 记录，以 PredicateCell 作为谓词 |
| GPR | `CUBE_M16` 或 `CUBE_M32` | 一条 `B.IOT` 含 SrcTrue、SrcFalse 与新目标，外加一条携带掩码的仅源 `B.IOR` |

传统谓词是每个元素一位的打包 Tile，其有效区域内的每个谓词位都必须已定义。PredicateCell 每个元素占一个字节，其基准类型必须等于操作 `DataType`。PredicateCell 字节在每个有效坐标处被检查和读取（存在 ExecutionMask 时仅在活动坐标处），每个这样的字节都必须已定义且为规范值：`0x00` 或 `0x01`。在 GPR 形式中，8 位操作类型使用两个掩码 GPR，16 位与 32 位类型使用一个。

每个数据源都可以使用位宽相同、非打包的其他后备类型。其位按原样拷贝到以操作 `DataType` 标记的目标中。

<!-- PTO-READER-BLOCK: tile-c-tsel-effects role=effects -->
## 已定义性、填充与发布

谓词与两个数据载荷都在第一次写目标之前被快照。两个数据源可以指向同一个 Tile，任一数据源也可以与目标互为别名；每次读取都看到旧值。

被选载荷、填充已定义性与目标描述符同时发布。被拒绝的 `TSEL` 不产生任何架构效果，且无论成败三个源都保留。

`ValidRow x ValidCol` 之外的元素接收所选 `PadValue`。`Zero`、`Max` 与 `Min` 为已定义值，而 `Null`（省略 `B.DATR` 时的选择）使其保持未定义。

在 CUBE 形式中，可以存在 ExecutionMask。此时非活动坐标接收该掩码规定的零值或合并值，而不是被选元素。`TSEL` 没有全局内存效果。

<!-- PTO-READER-BLOCK: tile-c-tsel-constraints role=constraints -->
## 合法性、故障与顺序边界

操作 `DataType` 集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。CUBE 形式进一步限制为 CUBE 谓词类型，其中不含 64 位类型。

源数据必须已定义（在 CUBE 形式中为每个活动坐标处），即使其编码不被校验。`PE_MASK=0000` 是严格无操作，发生在 GPR、谓词、源、分配或载荷检查之前。

载体模式格式错误或混用、维度缺失、`DataType` 不受支持、PredicateCell 基准与操作 `DataType` 不同、活动谓词字节非规范或未定义、活动源数据未定义、形状或布局不匹配、目标容量不足或分配失败时，会在任何效果之前被拒绝。

<!-- PTO-READER-BLOCK: tile-c-tsel-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

当 `DataType=S32` 时，谓词位 `[1, 0, 1]`、`SrcTrue` 行 `[10, 20, 30]` 与 `SrcFalse` 行 `[-1, -2, -3]` 产生 `[10, -2, 30]`。当 `DataType=FP32` 时，被选中的 NaN `0x7FC00001` 按 `0x7FC00001` 拷贝，且不记录任何状态。

宏形式 `TSEL <Row=8, Col=64, FP32>, U#1, T#1, T#2, ->T<2KB>` 使用打包 Predicate Tile `U#1`，为全部 8 x 64 个元素在 `T#1` 与 `T#2` 之间选择。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TSEL <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSEL | TEPL | 0x01A | 26 | 0 | ExecuteTileSelect |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new RowMajor or CUBE numeric destination |
| source0 | legacy packed Predicate, CUBE PredicateCell, or first GPR-mask role |
| source1 | persistent source selected by predicate one |
| source2 | persistent source selected by predicate zero |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TSEL.asl -->
```asl
readonly func InstructionContractOperation_TSEL() => TileOperation
begin
    return TileOperation_TSEL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TSEL, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT PredicateCell, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize> OR GPR predicate form without PredicateCell
B.IOT SrcFalse, <last>, ->DstTile<TSize> (CellReg form only)
B.IOR predicate-GPR source (GPR form only)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TSEL.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSEL(
    data_type: TileDataType) => boolean
begin
    return TileSelectDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TSEL(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    source_false: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileSelect(
        destination,
        predicate,
        source_true,
        source_false);
end;

readonly func InstructionContractHandler_TSEL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileSelect;
end;

func InstructionContractExecute_TSEL(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    source_false: TileIndex)
begin
    assert InstructionContractOperandsLegal_TSEL(
        destination,
        predicate,
        source_true,
        source_false);
    ExecuteTileSelect(
        destination,
        predicate,
        source_true,
        source_false);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- A zero predicate bit selects SrcFalse and a one predicate bit selects SrcTrue. TSEL is a raw-carrier operation: it copies the chosen source backing bits, publishes the destination with the selected operation DataType, does not require TileNumericEncodingValid for selected payloads, and performs no conversion or numeric-status update.

## Legality

- TSEL selects VEC Mode 0 Function 26. PE_MASK=0000 is a strict no-op before GPR, predicate, source, allocation, or payload checks.
- Legacy RowMajor form uses two ordered B.IOT records: packed Predicate plus SrcTrue, then SrcFalse plus one new destination; B.IOR is absent, each source backing is checked independently; exact backing/operation type identity is legal, while cross-type source/backing pairs require equal width and non-four-bit carriers, and selected bits are copied raw.
- CUBE_M16/M32 PredicateCell form uses the same two-record Tile structure with a descriptor-valid PredicateCell whose basis equals the operation DataType and whose ExecutionMask-active bytes are defined and canonical, while valid shape/layout and physical geometry match the numeric sources. Each source backing is checked independently; exact backing/operation type identity is legal, while cross-type source/backing pairs require equal width and non-four-bit carriers; B.IOR is absent.
- CUBE_M16/M32 GPR form uses one B.IOT with SrcTrue, SrcFalse, and one new CUBE destination plus one source-only B.IOR carrying the complete mask. The operation type is a 32-bit or 16-bit type from the closed CUBE domain, plus U8; each source backing is checked independently; exact backing/operation type identity is legal, while cross-type source/backing pairs require equal width and non-four-bit carriers; U8 consumes two mask GPRs and other accepted types consume one.
- Legacy, PredicateCell, and GPR forms are complete and mutually exclusive. PadValueOrByteId is the only applicable B.DATR field.

## State effects

- For each logical element, read the selected carrier predicate and copy the exact SrcTrue encoding when one or SrcFalse encoding when zero.
- Perform no rounding, saturation, canonicalization, arithmetic, or floating-status update.
- Publish selected payload, padding definedness, and destination descriptor atomically. Rejection has no architectural effect and all three sources persist.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, field, type, geometry, layout, definedness, predicate-kind, mask, and destination-capacity preflight precedes all source snapshots and allocation.
- Predicate bits and both data payloads are snapshotted before the first destination write, so equal sources and source/destination aliases observe read-old values.

## Exceptions

- Malformed or mixed carrier schemas, missing dimensions, unsupported DataType, wrong operation-type PredicateCell basis, noncanonical or undefined ExecutionMask-active predicate bytes, undefined active source data, shape/layout mismatch, insufficient destination capacity, or allocation failure rejects before effects.
- TSEL is a raw-carrier select and does not raise floating invalid solely because a selected source payload encodes NaN.

## Examples

- BSTART.VEC TSEL, U8; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT Predicate, SrcTrue, mask=PE_MASK; B.IOT SrcFalse, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
