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

`TSEL` 在打包谓词 Tile 控制下，从两个 Tile 源选择精确载体位。

<!-- PTO-READER-BLOCK: tile-c-tsel-mechanism role=mechanism -->
## 操作机制

谓词位为零时选择假输入，为一时选择真输入；选中的载体位会原样复制，不执行数值转换。

<!-- PTO-READER-BLOCK: tile-c-tsel-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `destination0` 标识新分配的目的 Tile。

- `source0` 提供打包谓词 Tile。

- `source1` 提供持久源 Tile。

- `source2` 提供持久源 Tile。

- 封闭的适用 DataType 集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。

- 除非该助记符显式选择其他允许布局，数据 Tile 使用行主序布局。

- `LB0`、`LB1`、`LB2` 按该助记符契约补全有效形状与物理形状；所有必需有效范围都必须非零。

<!-- PTO-READER-BLOCK: tile-c-tsel-effects role=effects -->
## 已定义性、填充与发布

所有源描述符与载荷都会在目标发布前完成验证和快照。

完整目标载荷、描述符、已定义性、填充状态与适用数值状态会原子发布；拒绝路径不发布任何部分。

Null 填充让有效矩形外的物理坐标保持未定义；显式非 Null 填充值会用选定带类型的值定义这些位置。

源 Tile 在成功执行后保持不变。

<!-- PTO-READER-BLOCK: tile-c-tsel-constraints role=constraints -->
## 合法性、故障与顺序边界

完整绑定模式、维度、DataType、布局、源已定义性、数值编码、目标容量与分配都会在效果前预检。

合法性或分配检查失败会引发相应 Tile 故障，不留下部分目标、状态或内存效果。

`PE_MASK=0000` 是严格无操作，发生在操作数读取、分配、故障、数值状态或载荷效果之前。

<!-- PTO-READER-BLOCK: tile-c-tsel-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

`TSEL <bundle operands>` 先完成完整预检与源快照，再原子发布助记符定义的结果与填充状态。
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
- A zero predicate bit selects SrcFalse and a one predicate bit selects SrcTrue. TSEL is a raw-carrier operation: it copies the chosen source carrier bits, preserves the concrete DataType, does not require TileNumericEncodingValid for selected payloads, and performs no conversion or numeric-status update.

## Legality

- TSEL selects VEC Mode 0 Function 26. PE_MASK=0000 is a strict no-op before GPR, predicate, source, allocation, or payload checks.
- Legacy RowMajor form uses two ordered B.IOT records: packed Predicate plus SrcTrue, then SrcFalse plus one new destination; B.IOR is absent.
- CUBE_M16/M32 PredicateCell form uses the same two-record Tile structure with a canonical PredicateCell whose basis DataType, valid shape, and layout match the numeric sources. The data type is exactly one of FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S32, S16, S8, U32, U16, or U8; B.IOR is absent.
- CUBE_M16/M32 GPR form uses one B.IOT with SrcTrue, SrcFalse, and one new CUBE destination plus one source-only B.IOR carrying the complete mask. The type is 32-bit or 16-bit types from the closed CUBE domain, plus U8; U8 consumes two mask GPRs and other accepted types consume one.
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

- Malformed or mixed carrier schemas, missing dimensions, unsupported DataType, wrong PredicateCell basis, noncanonical predicate bytes, undefined source data, shape/layout mismatch, insufficient destination capacity, or allocation failure rejects before effects.
- TSEL is a raw-carrier select and does not raise floating invalid solely because a selected source payload encodes NaN.

## Examples

- BSTART.VEC TSEL, E3M2; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT Predicate, SrcTrue, mask=PE_MASK; B.IOT SrcFalse, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
