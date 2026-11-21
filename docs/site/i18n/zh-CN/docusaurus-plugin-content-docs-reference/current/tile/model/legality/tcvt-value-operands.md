<!-- GENERATED FROM: asl/tile/model/legality/tcvt-value-operands.asl -->
# Tcvt Value Operands

**Normative ASL source:** `asl/tile/model/legality/tcvt-value-operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-TCVT-VALUE-OPERANDS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-tcvt-value-operands-purpose role=purpose-scope -->
## 用途与范围

本单元验证 `TCVT` 的分离目的形式。

<!-- PTO-READER-BLOCK: tile-model-legality-tcvt-value-operands-concepts role=concepts-state -->
## 概念与状态

源是已分配的数值 Tile。输出值提供目的类型和描述符，但不立即提交到架构 Tile。

<!-- PTO-READER-BLOCK: tile-model-legality-tcvt-value-operands-rules role=rules-interactions -->
## 规则与交互

`TileOperandsLegal_TCVTToValue` 始终要求有效行数和有效列数相等。对于普通布局，源和输出还必须具有相同的物理行数和列数，并分别匹配所选源布局和目的布局。对于 CUBE 布局，两个描述符分别按自己的数据类型和容量检查。它们共享同一个 CUBE 布局与有效区域，因此布局为两者固定相同的物理行数；容量和物理列数可以不同。

<!-- PTO-READER-BLOCK: tile-model-legality-tcvt-value-operands-boundaries role=boundaries -->
## 架构边界

该谓词不执行转换、不应用舍入、不更新标志，也不写入目的。这些效果仍由转换执行器和数值契约拥有。

<!-- PTO-READER-BLOCK: tile-model-legality-tcvt-value-operands-example role=example-usage -->
## 非规范阅读示例

从已定义源转换到分离 `FP32` 输出时，`CUBE_M16` 源和输出描述符都保持 16 个物理行。如果每个描述符对于自己的数据类型和容量都合法，则输出可以使用不同的容量和物理列数。源和输出仍需具有相同的有效行数和有效列数，并且必须支持源到 `FP32` 的转换。

<!-- PTO-READER-BLOCK: tile-model-legality-tcvt-value-operands-related role=related-owners-navigation -->
## 相关所有者

- [相关所有者](operand-schema.md) 定义分离 `TCVT` 检查所依赖的通用操作数规则。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/tcvt-value-operands.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-TCVT-VALUE-OPERANDS","surface":"tile","classification":["model","legality","tcvt-value-operands"],"depends_on":["PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA","PTO-TILE-MODEL-STATE-TYPES"]}

readonly func TileOperandsLegal_TCVTToValue(
    destination: TileOutputValueTarget, source: TileIndex,
    control: NumericExecutionControl) => boolean
begin
    let destination_tile = destination.value;
    let source_tile = _Tiles[[source]];
    let source_operation_type = if BundleTileOperationSelected() &&
        _BundleOperation.data_type_valid then TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding)
        else source_tile.data_type;
    if (if TileLayoutIsCube(destination_tile.layout) then
            !TileCubeDescriptorLegal(destination_tile)
        else !TileDescriptorPhysicalShapeLegal(
            destination_tile.capacity_bytes, destination_tile.rows,
            destination_tile.columns, destination_tile.valid_rows,
            destination_tile.valid_columns, destination_tile.data_type)) ||
       !TileTCVTSourceContentsDefined(source) ||
       !TileTCVTSourceEncodingsValidAs(source, source_operation_type) ||
       !TileCarrierWidthCompatible(source_tile.data_type,
           source_operation_type) ||
       !HardwareTCVTTypePairSupported(source_operation_type,
           destination_tile.data_type) ||
       !HardwareTCVTRoundingModeSupported(source_operation_type,
           destination_tile.data_type, control.rounding_mode) ||
       destination_tile.valid_rows != source_tile.valid_rows ||
       destination_tile.valid_columns != source_tile.valid_columns then
        return FALSE;
    end;
    let source_cube_m_layout =
        source_tile.layout == TileLayout_CUBE_M16 ||
        source_tile.layout == TileLayout_CUBE_M32;
    if source_cube_m_layout then
        return !CurrentBundleCanonicalize() &&
               CurrentBundleDataLayout() == TileDataLayout_NORM &&
               destination_tile.layout == source_tile.layout &&
               TileCubeDescriptorShapeLegal(
                   source_tile.capacity_bytes, source_tile.valid_rows,
                   source_tile.valid_columns, source_tile.data_type,
                   source_tile.layout) &&
               TileCubeDescriptorShapeAndPhysicalLegal(
                   destination_tile.capacity_bytes, destination_tile.rows,
                   destination_tile.columns, destination_tile.valid_rows,
                   destination_tile.valid_columns,
                   destination_tile.data_type, destination_tile.layout);
    end;
    if destination_tile.rows != source_tile.rows ||
       destination_tile.columns != source_tile.columns ||
       TileLayoutIsCube(destination_tile.layout) ||
       CurrentBundleCanonicalize() then
        return FALSE;
    end;
    return source_tile.layout == CurrentBundleTileSourceLayout() &&
           destination_tile.layout == CurrentBundleTileLayout();
end;
```
<!-- GENERATED-ASL-END: unit -->
