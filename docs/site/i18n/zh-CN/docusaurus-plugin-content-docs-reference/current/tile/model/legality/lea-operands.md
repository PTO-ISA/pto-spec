<!-- GENERATED FROM: asl/tile/model/legality/lea-operands.asl -->
# Lea Operands

**Normative ASL source:** `asl/tile/model/legality/lea-operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-LEA-OPERANDS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-lea-operands-purpose role=purpose-scope -->
## 目的与范围

本单元负责 `TLEA` 可复用的类型、宽度、逻辑形状、描述符与源已定义性谓词。主谓词 `TileOperandsLegal_TLEA` 在执行前立即检查已经解析的源与目标。

<!-- PTO-READER-BLOCK: tile-model-legality-lea-operands-concepts role=concepts-state -->
## 概念与可见状态

`TileLEAIndexDataTypeLegal` 只接受 `S32`、`U32`、`S64` 与 `U64`。`TileLEADestinationDataType` 把两个有符号类型映射为 `S64`，把两个无符号类型映射为 `U64`。`TileLEAElementBitsLegal` 只接受 8、16、32 与 64。

所选源操作类型来自当前 bundle 视图。bundle 执行活动时，`TileLEABundleLogicalShapeMatches` 还会把每个操作数的有效行、有效列与布局同 `LB1`、`LB0` 和当前 bundle 布局比较。

<!-- PTO-READER-BLOCK: tile-model-legality-lea-operands-rules role=rules-interactions -->
## 规则与交互

`TileOperandsLegal_TLEA` 要求所选操作类型能够解析、等于源后备类型且属于四种可接受索引类型。它要求元素宽度合法、源与目标均为数值存储、布局相同且为支持的 elementwise 布局，并具有相同逻辑有效形状。

源与目标描述符分别通过 `TileElementwiseDescriptorLegal` 独立检查；它们的物理行、列与容量无需相同。目标类型必须是对应的 `S64` 或 `U64`，执行可能读取的源坐标必须已定义，并且两个操作数都必须匹配 bundle 逻辑形状。

<!-- PTO-READER-BLOCK: tile-model-legality-lea-operands-boundaries role=boundaries -->
## 架构边界

本单元不绑定命令、不校验未使用的 `B.IOR` 字段、不分配目标，也不计算字节偏移乘积。这些职责分别属于 bundle schema、目标分配与执行。

这些谓词只允许 `RowMajor` 或 `CUBE_M32` 的 Local 数值描述符。Shared、打包四位、浮点、更窄整数、`CUBE_M16` 与 `CUBE_N8` 形式会失败。由于每个结果都是 `S64` 或 `U64`，`CUBE_M16` 被排除。

<!-- PTO-READER-BLOCK: tile-model-legality-lea-operands-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL owner，不替代规范规则。

一个 `S32` 源与 `S64` 目标可以在 `CUBE_M32` 中都具有 7 x 60 的逻辑形状，同时使用不同物理存储。源使用普通 32 位 CELL 几何；目标为每个逻辑列计入完整低/高 CELL pair。当各描述符分别满足该几何与容量、都匹配 bundle 的 7 x 60 逻辑形状，且活动源坐标已定义时，该操作数对合法。

<!-- PTO-READER-BLOCK: tile-model-legality-lea-operands-related role=related-owners-navigation -->
## 相关 owner

- [TLEA bundle schema](../../../block/model/dispatch/lea-schema.md)在分配前检查命令绑定。
- [TLEA 执行](../execution/lea.md)消费这些前置条件。
- [数据类型与布局合法性](dtype-layout.md)负责 elementwise 描述符与布局检查。
- [TLEA](../../tile-scalar-and-immediate/arithmetic/TLEA.md) 是指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/lea-operands.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-LEA-OPERANDS","surface":"tile","classification":["model","legality","lea-operands"],"depends_on":["PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"]}

pure func TileLEAIndexDataTypeLegal(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S32 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
end;

pure func TileLEADestinationDataType(data_type: TileDataType) => TileDataType
begin
    assert TileLEAIndexDataTypeLegal(data_type);
    if data_type == TileDataType_S32 || data_type == TileDataType_S64 then
        return TileDataType_S64;
    end;
    return TileDataType_U64;
end;

pure func TileLEAElementBitsLegal(element_bits: Word) => boolean
begin
    return element_bits == Zeros{PTO_XLEN} + 8 ||
           element_bits == Zeros{PTO_XLEN} + 16 ||
           element_bits == Zeros{PTO_XLEN} + 32 ||
           element_bits == Zeros{PTO_XLEN} + 64;
end;

readonly func TileLEASourceOperationType(source: TileIndex)
    => (boolean, TileDataType)
begin
    return ResolveTileSelectedOperationType(_Tiles[[source]].data_type);
end;

readonly func TileLEABundleLogicalShapeMatches(index: TileIndex) => boolean
begin
    if !BundleTileOperationSelected() then return TRUE; end;
    let valid_columns_raw = UInt(_BundleDimensions[[0]]);
    let valid_rows_raw = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) else 1;
    if valid_columns_raw < 1 || valid_columns_raw > 65535 ||
       valid_rows_raw < 1 || valid_rows_raw > 65535 then
        return FALSE;
    end;
    let tile = _Tiles[[index]];
    return tile.valid_columns == valid_columns_raw &&
           tile.valid_rows == valid_rows_raw &&
           tile.layout == CurrentBundleTileLayout();
end;

readonly func TileOperandsLegal_TLEA(
    destination: TileIndex, source: TileIndex, element_bits: Word) => boolean
begin
    let (operation_type_valid, operation_type) =
        TileLEASourceOperationType(source);
    let source_tile = _Tiles[[source]];
    let destination_tile = _Tiles[[destination]];
    if !operation_type_valid ||
       operation_type != source_tile.data_type ||
       !TileLEAIndexDataTypeLegal(operation_type) ||
       !TileLEAElementBitsLegal(element_bits) ||
       !TileElementwiseLayoutSupported(source_tile.layout) ||
       source_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.layout != destination_tile.layout ||
       source_tile.valid_rows != destination_tile.valid_rows ||
       source_tile.valid_columns != destination_tile.valid_columns ||
       destination_tile.data_type != TileLEADestinationDataType(operation_type) ||
       !TileElementwiseDescriptorLegal(source) ||
       !TileElementwiseDescriptorLegal(destination) ||
       !TileElementwiseSourceContentsDefined(source) ||
       !TileLEABundleLogicalShapeMatches(source) ||
       !TileLEABundleLogicalShapeMatches(destination) then
        return FALSE;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
