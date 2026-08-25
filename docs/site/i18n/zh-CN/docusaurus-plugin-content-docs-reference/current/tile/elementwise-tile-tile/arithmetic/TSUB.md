<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl -->
# TSUB

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl`

Subtract corresponding right-source elements from left-source elements.

## Normative identity {#PTO-INST-TILE-TSUB}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tsub-purpose role=purpose -->
## TSUB 的作用

`TSUB` 让左源元素减去对应右源元素，并发布一个新的 Local 目标。

<!-- PTO-READER-BLOCK: tile-c-tsub-mechanism role=mechanism -->
## 操作机制

该操作只在有效矩形内按助记符选定的带类型的元素规则求值。

<!-- PTO-READER-BLOCK: tile-c-tsub-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `destination0` 标识新分配的目的 Tile。

- `source0` 携带该助记符定义的操作数。

- `source1` 携带该助记符定义的操作数。

- 封闭的适用 DataType 集合为 `FP32`、`FP16`、`BF16`、`S32`、`S16`、`S8`、`U32`、`U16`、`U8`。

- 除非该助记符显式选择其他允许布局，数据 Tile 使用行主序布局。

- `LB0`、`LB1`、`LB2` 按该助记符契约补全有效形状与物理形状；所有必需有效范围都必须非零。

<!-- PTO-READER-BLOCK: tile-c-tsub-effects role=effects -->
## 已定义性、填充与发布

所有源描述符与载荷都会在目标发布前完成验证和快照。

完整目标载荷、描述符、已定义性、填充状态与适用数值状态会原子发布；拒绝路径不发布任何部分。

Null 填充让有效矩形外的物理坐标保持未定义；显式非 Null 填充值会用选定带类型的值定义这些位置。

源 Tile 在成功执行后保持不变。

<!-- PTO-READER-BLOCK: tile-c-tsub-constraints role=constraints -->
## 合法性、故障与顺序边界

完整绑定模式、维度、DataType、布局、源已定义性、数值编码、目标容量与分配都会在效果前预检。

合法性或分配检查失败会引发相应 Tile 故障，不留下部分目标、状态或内存效果。

<!-- PTO-READER-BLOCK: tile-c-tsub-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

`TSUB <bundle operands>` 先完成完整预检与源快照，再原子发布助记符定义的结果与填充状态。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TSUB <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSUB | TEPL | 0x001 | 1 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | minuend |
| source1 | subtrahend |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl -->
```asl
readonly func InstructionContractOperation_TSUB() => TileOperation
begin
    return TileOperation_TSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TSUB, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSUB(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TSUB(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_SUB,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TSUB() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TSUB(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_SUB,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.

## Legality

- TSUB is BSTART.VEC Mode 0 Function 1 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S32, U32, FP32, S16, U16, FP16, BF16, S8, or U8.
- Sources are fully defined and all three Tiles match physical shape, valid shape, row-major layout, DataType, and PE_MASK.
- Only B.DATR PadValueOrByteId is applicable.

## State effects

- Publish source-left minus source-right for each valid coordinate after complete preflight.
- Pad the remaining physical region using the selected PadValue; Null padding is undefined.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both sources are snapshotted before destination writes.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects.

## Examples

- BSTART.VEC TSUB, U64; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
