<!-- GENERATED FROM: asl/tile/model/legality/expdif-operands.asl -->
# Expdif Operands

**Normative ASL source:** `asl/tile/model/legality/expdif-operands.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-EXPDIF-OPERANDS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-expdif-operands-purpose role=purpose-scope -->
## 用途与范围

本单元负责 `TEXPDIF` 的操作数合法性，该指令对每个有效坐标（存在 ExecutionMask 时为每个活动坐标）计算自然指数 `exp(source0 - source1)`。`source0` 是被减数，`source1` 是减数。

- `TileExpdifSourceOperationType` 确定源操作类型。
- `TileExpdifBundleGeometryMatches` 将一个 Tile 与指令束的 `B.DIM` 值比较。
- `TileExpdifLogicalShapeMatch` 比较两个 Tile 的有效区域与布局。
- `TileExpdifSourcesLegal` 检查两个源。
- `TileOperandsLegal_ExecuteTileExpdif` 检查包括目标在内的完整操作数集合。

<!-- PTO-READER-BLOCK: tile-model-legality-expdif-operands-concepts role=concepts-state -->
## 概念与可见状态

源操作类型是读取两个源时使用的类型。选中指令束 Tile 操作时，它来自 `BSTART` 的 DataType；若该 DataType 无效，谓词返回 FALSE。在指令束之外，它是 `source0` 的存储类型。

在指令束内，所选布局为 `CurrentBundleTileLayout`，否则为 `source0` 的布局。`TileElementwiseLayoutSupported` 只接受 RowMajor、CUBE_M16 与 CUBE_M32。

指令束几何来自 `B.DIM`：LB0 为 ValidCol，LB1 为 ValidRow（省略时为 1），LB2 为 Col（省略时为 ValidCol）。每个值都必须在 1 到 65535 之间。在指令束之外，几何匹配总是通过。

<!-- PTO-READER-BLOCK: tile-model-legality-expdif-operands-rules role=rules-interactions -->
## 规则与交互

`TileExpdifSourcesLegal` 要求以下全部成立：

- 源操作类型有效，且所选布局受支持。
- 两个源都是数值存储，且都使用所选布局。
- 两个源的有效行数、有效列数与布局相同。
- 每个源都满足 `TileElementwiseDescriptorLegal`。
- 每个源都与指令束几何一致。
- 每个源在操作类型下满足 `TileElementwiseSourceEncodingsValidAs`，这同时检查已定义性与 `TileCarrierWidthCompatible`。

`TileOperandsLegal_ExecuteTileExpdif` 进一步检查类型对与目标。`TileExpdifTypePairLegal` 恰好接受 (FP16, FP16)、(BF16, BF16)、(FP32, FP32)、(FP16, FP32) 与 (BF16, FP32)。目标必须是数值存储，使用所选布局，通过 `TileElementwiseDescriptorLegal`，与指令束几何一致，并与 `source0` 共享有效区域。

设计要点：对 CUBE 布局，期望的物理列数是对指令束 Col 求 `TileCubeStorageColumns`，并使用每个 Tile 自己的数据类型计算。因此对同一个逻辑 Col，FP16 源与 FP32 目标可以有不同的物理宽度，同时共享一个逻辑有效区域。

设计要点：只要载体位宽兼容，源的后备类型可以与操作类型不同。源描述符不会被重新标记类型。其位按操作类型校验和读取。

类型对接受的每个目标类型都是 FP16、BF16 或 FP32。EXP 步骤以目标类型运行，混合类型对则以 FP32 运行。没有特殊值适用时，它调用 `TileProfileUnary`，后者把 EXP 交给 `ReferenceTileUnaryFinite`；该函数断言类型为 FP32、FP16 或 BF16，因此被接受的类型对都在其范围之内。

指令束分派在分配目标之前检查类型对与 `TileExpdifSourcesLegal`。随后完整的 `TileOperandsLegal_ExecuteTileExpdif` 检查作为合法性处理函数运行，早于任何源快照或载荷写入；若失败，则引发 `Fault_TileLegality`，并回滚已分配的目标。`ExecuteTileExpdif` 也会断言同一谓词。

<!-- PTO-READER-BLOCK: tile-model-legality-expdif-operands-boundaries role=boundaries -->
## 架构边界

`TEXPDIF` 把 `TileOperandsLegal_ExecuteTileExpdif` 作为其操作数合法性处理函数。指令束 Tile schema在 `SelectedBundleExponentialDifferenceTypes` 检查类型对之后，直接调用 `TileExpdifSourcesLegal`。

`TileOperandsLegal_ExecuteTileBinary` 对 `TileBinary_EXPDIF` 返回 FALSE，因此 `TEXPDIF` 不能经过通用二元路径。

本单元不检查 B.DATR 字段 schema、PE_MASK 处理或目标容量。这些属于指令束分派。

<!-- PTO-READER-BLOCK: tile-model-legality-expdif-operands-example role=example-usage -->
## 非规范阅读示例

考虑一条 `TEXPDIF`：操作类型为 FP16，B.DATR 目标类型为 FP32，RowMajor 布局，`B.DIM LB0=16`，省略 LB1 与 LB2。

- 类型对 (FP16, FP32) 被接受。
- 指令束几何为 ValidCol 16、ValidRow 1、Col 16。
- 两个 FP16 源与 FP32 目标都必须具有 1 乘 16 的有效区域、RowMajor 布局和 16 个物理列。
- 以 U16 存储的源被接受，因为 U16 与 FP16 都是 16 位宽，其位按 FP16 读取。

类型对 (FP32, FP16) 会在任何效果之前被拒绝。

<!-- PTO-READER-BLOCK: tile-model-legality-expdif-operands-related role=related-owners-navigation -->
## 相关所有者

- [EXPDIF 执行](../execution/expdif.md) 在本检查之后计算结果。
- [数据类型与布局](dtype-layout.md) 负责 `TileExpdifTypePairLegal` 与 `TileElementwiseLayoutSupported`。
- [ExecutionMask 源 schema](execution-mask-source-schema.md) 负责源编码检查。
- [操作数 schema](operand-schema.md) 负责 `TileElementwiseDescriptorLegal`。
- [EXPDIF schema](../../../block/model/dispatch/expdif-schema.md) 解析指令束类型对。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/expdif-operands.asl -->
```asl
// PTO-UNIT: {"classification":["model","legality","expdif-operands"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"],"id":"PTO-TILE-MODEL-LEGALITY-EXPDIF-OPERANDS","surface":"tile"}
readonly func TileExpdifSourceOperationType(source0: TileIndex)
    => (boolean, TileDataType)
begin
    if BundleTileOperationSelected() then
        if !_BundleOperation.data_type_valid then
            return (FALSE, TileDataType_FP64);
        end;
        return (
            TRUE,
            TileDataTypeFromEncoding(
                CurrentBundleTileOperationDataTypeCode()
                    as TileDataTypeEncoding));
    end;
    return (TRUE, _Tiles[[source0]].data_type);
end;

readonly func TileExpdifBundleGeometryMatches(index: TileIndex)
    => boolean
begin
    if !BundleTileOperationSelected() then return TRUE; end;
    let valid_columns_raw = UInt(_BundleDimensions[[0]]);
    let valid_rows_raw = if _BundleDimensionPresent[[1]] then
        UInt(_BundleDimensions[[1]]) else 1;
    let columns_raw = if _BundleDimensionPresent[[2]] then
        UInt(_BundleDimensions[[2]]) else valid_columns_raw;
    if valid_columns_raw < 1 || valid_columns_raw > 65535 ||
       valid_rows_raw < 1 || valid_rows_raw > 65535 ||
       columns_raw < 1 || columns_raw > 65535 then
        return FALSE;
    end;
    let valid_columns = valid_columns_raw as integer {1..65535};
    let valid_rows = valid_rows_raw as integer {1..65535};
    let columns = columns_raw as integer {1..65535};
    let tile = _Tiles[[index]];
    let selected_layout = CurrentBundleTileLayout();
    let expected_columns = if TileLayoutIsCube(selected_layout) then
        TileCubeStorageColumns(selected_layout, columns, tile.data_type)
    else
        columns;
    return tile.layout == selected_layout &&
           tile.valid_rows == valid_rows &&
           tile.valid_columns == valid_columns &&
           tile.columns == expected_columns;
end;

readonly func TileExpdifLogicalShapeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    return _Tiles[[left]].valid_rows == _Tiles[[right]].valid_rows &&
           _Tiles[[left]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[left]].layout == _Tiles[[right]].layout;
end;

readonly func TileExpdifSourcesLegal(
    source0: TileIndex, source1: TileIndex) => boolean
begin
    let (operation_type_valid, operation_type) =
        TileExpdifSourceOperationType(source0);
    if !operation_type_valid then return FALSE; end;
    let selected_layout = if BundleTileOperationSelected() then
        CurrentBundleTileLayout()
    else
        _Tiles[[source0]].layout;
    if !TileElementwiseLayoutSupported(selected_layout) ||
       _Tiles[[source0]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source1]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source0]].layout != selected_layout ||
       _Tiles[[source1]].layout != selected_layout ||
       !TileExpdifLogicalShapeMatch(source0, source1) ||
       !TileElementwiseDescriptorLegal(source0) ||
       !TileElementwiseDescriptorLegal(source1) ||
       !TileExpdifBundleGeometryMatches(source0) ||
       !TileExpdifBundleGeometryMatches(source1) ||
       !TileElementwiseSourceEncodingsValidAs(source0, operation_type) ||
       !TileElementwiseSourceEncodingsValidAs(source1, operation_type) then
        return FALSE;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileExpdif(
    destination: TileIndex,
    source0: TileIndex,
    source1: TileIndex) => boolean
begin
    let (operation_type_valid, operation_type) =
        TileExpdifSourceOperationType(source0);
    let destination_tile = _Tiles[[destination]];
    let selected_layout = if BundleTileOperationSelected() then
        CurrentBundleTileLayout()
    else
        _Tiles[[source0]].layout;
    if !operation_type_valid ||
       !TileExpdifTypePairLegal(operation_type,
           destination_tile.data_type) ||
       !TileExpdifSourcesLegal(source0, source1) ||
       destination_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.layout != selected_layout ||
       !TileElementwiseDescriptorLegal(destination) ||
       !TileExpdifBundleGeometryMatches(destination) ||
       !TileExpdifLogicalShapeMatch(destination, source0) then
        return FALSE;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
