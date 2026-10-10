<!-- GENERATED FROM: asl/tile/model/legality/reduction-and-expansion.asl -->
# Reduction And Expansion

**Normative ASL source:** `asl/tile/model/legality/reduction-and-expansion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-reduction-and-expansion-purpose role=purpose-scope -->
## 用途与范围

本单元包含三个指令族的操作数合法性谓词：

- `TileOperandsLegal_ExecuteTileReduction` 用于行归约与列归约，例如 `TROWSUM`、`TCOLMAX` 与 `TROWARGMIN`。
- `TileOperandsLegal_ExecuteTileExpand` 用于行扩展与列扩展，例如 `TROWEXPAND`、`TROWEXPANDADD` 与 `TCOLEXPANDEXPDIF`。
- `TileOperandsLegal_ExecuteTileFillScalar` 用于 `TEXPANDS`。

每条指令的 `InstructionContractOperandsLegal_*` 返回其中一个谓词。`ExecuteTileReduction`、`ExecuteTileExpand` 与 `ExecuteTileFillScalar` 在构造结果之前断言同一谓词。谓词以返回 FALSE 代替修改状态，因此非法操作数组合不会写入任何目标元素。

<!-- PTO-READER-BLOCK: tile-model-legality-reduction-and-expansion-concepts role=concepts-state -->
## 概念与可见状态

支持的布局为 `RowMajor`、`CUBE_M16` 与 `CUBE_M32`（`TileReductionAndExpansionLayoutSupported`）。RowMajor Tile 必须通过 `TileDescriptorLegal`；CUBE Tile 必须通过 `TileCubeDescriptorLegal`。

当源是 Numeric Tile、其存储类型与操作类型具有相同载体位宽（`TileCarrierWidthCompatible`）、内容已定义、且每个被消费的元素在操作类型下编码有效时，该源对该操作类型合法。存在 ExecutionMask 时，源必须与掩码的布局和有效形状一致，并且只检查活动元素。

广播 Tile 为每个目标行或列提供一个值。行轴对 RowMajor 使用列槽位 0。对 CUBE 布局，槽位等于 `B.DATR.RMode` 中的字节偏移除以元素大小。列轴始终使用广播 Tile 的第 0 行。

<!-- PTO-READER-BLOCK: tile-model-legality-reduction-and-expansion-rules role=rules-interactions -->
## 规则与交互

归约要求目标与源不同、两者布局相同、且源有效形状非零。`ARGMIN` 与 `ARGMAX` 要求源类型属于 `TileArgReductionSourceDataTypeSupported`，目标为 U32。其他归约要求类型属于 `TileVecArithmeticDataTypeSupported`，目标类型与之相同。行归约产生有效形状为行数乘 1 的结果；列归约产生 1 乘列数的结果。物理目标形状也要检查：RowMajor 下由容量经 `DerivedTileRows` 推导，CUBE 下为按单元对齐的存储范围。

设计要点：`TileReductionSourceLegalAs` 拒绝任何带有有效 ExecutionMask 的指令束，以及任何类型为 RCPE6M2 的源。ASL 注释说明归约扫描每个有效坐标，且不支持 ExecutionMask 校验状态。分派侧的归约 schema也施加同样的掩码拒绝，因此归约不能在 ExecutionMask 下运行。

扩展要求目标、源与广播 Tile 共享同一布局且均为 Numeric。目标类型必须属于 `TileVecArithmeticDataTypeSupported` 并等于操作类型。非 EXPDIF 操作的源与目标使用同一类型；EXPDIF 使用类型对规则 `TileExpdifTypePairLegal`。广播 Tile 在行轴上必须与目标有效行数一致，在列轴上必须与目标有效列数一致。非复制操作还要求源有效形状等于目标有效形状。

设计要点：对整数 `DIV` 扩展，`TileExpansionBroadcastNonzero` 要求被活动输出消费的每个广播值都已定义且非零。除以零在预检阶段被拒绝，非活动输出不做检查。

设计要点：复制形式（`TROWEXPAND`、`TCOLEXPAND`）把广播 Tile 作为自己的源，并且只检查被消费广播元素的已定义性，不检查编码。被复制的位不会被任何数值辅助函数解释。

`TEXPANDS` 只要求受支持布局下的合法描述符、Numeric 目标以及属于 `TileFillPadDataTypeSupported` 的类型；它对标量值不施加规则。

<!-- PTO-READER-BLOCK: tile-model-legality-reduction-and-expansion-boundaries role=boundaries -->
## 架构边界

`TileVecArithmeticDataTypeSupported` 在浮点类型中接受 FP64、FP32、TF32、HF32、FP16、BF16、E4M3 与 E5M2。浮点 `SUM` 与 `PRODUCT` 归约以及浮点 `ADD`、`SUB`、`MUL`、`DIV` 扩展会到达 `ScalarFPBinaryProfile`，它断言类型为 FP64、FP32、FP16 或 BF16。对 TF32、HF32、E4M3 与 E5M2，这些操作能通过合法性检查，但数值辅助函数会对该类型断言失败。`MIN`、`MAX`、`ARGMIN` 与 `ARGMAX` 使用浮点排序键，它接受全部八种类型。

CUBE 行广播选择由 `TileExpansionBroadcastSelectorLegal` 检查：RowMajor 要求偏移为 0；CUBE 要求偏移按元素大小对齐、对 `CUBE_M16` 小于 8 或对 `CUBE_M32` 小于 4，并且槽位同时位于单元列数与广播有效列数之内。

`TileReductionAndExpansionSourceLegal` 定义于此，但在 `asl/` 中搜索找不到调用者。

<!-- PTO-READER-BLOCK: tile-model-legality-reduction-and-expansion-example role=example-usage -->
## 非规范阅读示例

考虑对有效形状为 8 乘 64、没有 ExecutionMask 的 FP32 RowMajor 源执行 `TROWSUM`。目标容量为 128 字节。

- 目标有效形状必须为 8 乘 1。
- `DerivedTileRows(128, 1, FP32)` 为 128 x 8 / 32 = 32，因此目标必须有 32 行 1 列。
- 源内容必须已定义，且 512 个源元素中的每一个都必须具有有效的 FP32 编码。

若同一指令束携带 ExecutionMask，谓词会返回 FALSE，且不写入任何目标元素。

<!-- PTO-READER-BLOCK: tile-model-legality-reduction-and-expansion-related role=related-owners-navigation -->
## 相关所有者

- [归约执行](../execution/reduction.md) 与 [扩展执行](../execution/expansion.md) 在这些检查之后运行操作。
- [数据类型与布局合法性](dtype-layout.md) 拥有类型集合与 `TileExpdifTypePairLegal`。
- [归约 schema](../../../block/model/dispatch/reduction-schema.md) 与 [扩展 schema](../../../block/model/dispatch/expansion-schema.md) 在指令束分派中应用这些规则。
- [CUBE 单元几何](../shape/cube-cell.md) 拥有 CUBE 存储范围。
- [TROWSUM](../../reduce-and-expand/row-reduction/TROWSUM.md)、[TROWEXPANDDIV](../../reduce-and-expand/row-expansion/TROWEXPANDDIV.md) 与 [TEXPANDS](../../tile-scalar-and-immediate/initialization/TEXPANDS.md) 是代表性的指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/reduction-and-expansion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION","surface":"tile","classification":["model","legality","reduction-and-expansion"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}

pure func TileReductionAndExpansionLayoutSupported(layout: TileLayout)
    => boolean
begin
    return layout == TileLayout_RowMajor ||
           layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32;
end;

readonly func TileReductionAndExpansionDescriptorLegal(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionLayoutSupported(tile.layout) then
        return FALSE;
    end;
    if tile.layout == TileLayout_RowMajor then
        return TileDescriptorLegal(index);
    end;
    return TileCubeDescriptorLegal(tile);
end;

readonly func TileReductionAndExpansionSourceContentsDefined(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionDescriptorLegal(index) ||
       tile.storage_kind != TileStorage_Numeric then
        return FALSE;
    end;
    if !_BundleExecutionMask.valid then return tile.contents_defined; end;
    if tile.layout != _BundleExecutionMask.layout ||
       tile.valid_rows != _BundleExecutionMask.valid_rows ||
       tile.valid_columns != _BundleExecutionMask.valid_columns then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) &&
               !TileElementDefined(index, row as integer {0..65535},
                   column as integer {0..65535}) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileReductionAndExpansionSourceLegal(index: TileIndex)
    => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionSourceContentsDefined(index) then
        return FALSE;
    end;
    if tile.layout == TileLayout_RowMajor then
        return TileSourceEncodingsValid(index);
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(
                    tile, row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(
                       tile.data_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileReductionAndExpansionSourceLegalAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionSourceContentsDefined(index) ||
       !TileCarrierWidthCompatible(tile.data_type, operation_type) then
        return FALSE;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(
                    tile, row as integer {0..65535},
                    column as integer {0..65535});
                if !TileNumericEncodingValid(
                       operation_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileReductionSourceLegalAs(
    index: TileIndex, operation_type: TileDataType) => boolean
begin
    // Reductions scan every valid coordinate and do not support the shared
    // Local CUBE ExecutionMask validation state. Keep this rejection in the
    // reduction-only entry point so expansion retains its mask behavior.
    return !_BundleExecutionMask.valid &&
           _Tiles[[index]].data_type != TileDataType_RCPE6M2 &&
           TileReductionAndExpansionSourceLegalAs(index, operation_type);
end;

readonly func TileExpansionBroadcastElementsLegalAs(
    index: TileIndex, axis: TileAxis,
    operation_type: TileDataType, validate_encoding: boolean) => boolean
begin
    let tile = _Tiles[[index]];
    if !TileReductionAndExpansionDescriptorLegal(index) ||
       tile.storage_kind != TileStorage_Numeric ||
       !TileCarrierWidthCompatible(tile.data_type, operation_type) then
        return FALSE;
    end;
    if !_BundleExecutionMask.valid && !tile.contents_defined then
        return FALSE;
    end;
    if _BundleExecutionMask.valid &&
       tile.layout != _BundleExecutionMask.layout then
        return FALSE;
    end;
    if axis == TileAxis_Row then
        if !TileExpansionBroadcastSelectorLegal(
               index, axis, operation_type) then
            return FALSE;
        end;
        let broadcast_column = TileExpansionBroadcastSlot(
            axis, tile.layout, operation_type);
        if _BundleExecutionMask.valid &&
           tile.valid_rows != _BundleExecutionMask.valid_rows then
            return FALSE;
        end;
        for row = 0 to tile.valid_rows - 1 looplimit 65536 do
            var consumed = !_BundleExecutionMask.valid;
            if _BundleExecutionMask.valid then
                for column = 0 to _BundleExecutionMask.valid_columns - 1
                    looplimit 65536 do
                    if BundleExecutionMaskActiveAt(
                           tile.layout, row as integer {0..65535},
                           column as integer {0..65535}) then
                        consumed = TRUE;
                    end;
                end;
            end;
            if consumed then
                if !TileElementDefined(index,
                       row as integer {0..65535}, broadcast_column) then
                    return FALSE;
                end;
                let element = TileLogicalLinearIndex(
                    tile, row as integer {0..65535}, broadcast_column);
                if validate_encoding &&
                   !TileNumericEncodingValid(
                       operation_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    else
        if _BundleExecutionMask.valid &&
           tile.valid_columns != _BundleExecutionMask.valid_columns then
            return FALSE;
        end;
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            var consumed = !_BundleExecutionMask.valid;
            if _BundleExecutionMask.valid then
                for row = 0 to _BundleExecutionMask.valid_rows - 1
                    looplimit 65536 do
                    if BundleExecutionMaskActiveAt(
                           tile.layout, row as integer {0..65535},
                           column as integer {0..65535}) then
                        consumed = TRUE;
                    end;
                end;
            end;
            if consumed then
                if !TileElementDefined(index, 0,
                       column as integer {0..65535}) then
                    return FALSE;
                end;
                let element = TileLogicalLinearIndex(
                    tile, 0, column as integer {0..65535});
                if validate_encoding &&
                   !TileNumericEncodingValid(
                       operation_type,
                       TileReadLogicalElement(tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileExpansionBroadcastLegalAs(
    index: TileIndex, axis: TileAxis,
    operation_type: TileDataType) => boolean
begin
    return TileExpansionBroadcastElementsLegalAs(
        index, axis, operation_type, TRUE);
end;

readonly func TileExpansionBroadcastByteOffset(axis: TileAxis)
    => integer {0..7}
begin
    if axis == TileAxis_Row && BundleTileOperationSelected() then
        return UInt(_BundleDataAttributes.rounding_mode)
            as integer {0..7};
    end;
    return 0;
end;

readonly func TileExpansionBroadcastSlot(
    axis: TileAxis, layout: TileLayout,
    operation_type: TileDataType) => integer {0..7}
begin
    if axis != TileAxis_Row || layout == TileLayout_RowMajor then
        return 0;
    end;
    let byte_offset = TileExpansionBroadcastByteOffset(axis);
    let element_bytes = TileElementBytes(operation_type);
    assert element_bytes == 1 || element_bytes == 2 ||
           element_bytes == 4 ||
           (layout == TileLayout_CUBE_M32 && element_bytes == 8);
    return (byte_offset DIV element_bytes) as integer {0..7};
end;

readonly func TileExpansionBroadcastSelectorLegal(
    index: TileIndex, axis: TileAxis,
    operation_type: TileDataType) => boolean
begin
    if axis != TileAxis_Row then return TRUE; end;
    let tile = _Tiles[[index]];
    let byte_offset = TileExpansionBroadcastByteOffset(axis);
    if tile.layout == TileLayout_RowMajor then
        return byte_offset == 0;
    end;
    if tile.layout != TileLayout_CUBE_M16 &&
       tile.layout != TileLayout_CUBE_M32 then
        return FALSE;
    end;
    let element_bytes = TileElementBytes(operation_type);
    if (element_bytes != 1 && element_bytes != 2 && element_bytes != 4 &&
        !(tile.layout == TileLayout_CUBE_M32 && element_bytes == 8)) ||
       byte_offset >= (if tile.layout == TileLayout_CUBE_M32 && element_bytes != 8 then 4 else 8) ||
       byte_offset MOD element_bytes != 0 then
        return FALSE;
    end;
    let slot = (byte_offset DIV element_bytes) as integer {0..7};
    return slot < TileCubeCellColumns(tile.layout, operation_type) &&
           slot < tile.valid_columns;
end;

readonly func TileExpansionBroadcastNonzero(
    axis: TileAxis, source: TileIndex, broadcast: TileIndex,
    operation_type: TileDataType) => boolean
begin
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast]];
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let broadcast_row = if axis == TileAxis_Row then row else 0;
                let broadcast_column = if axis == TileAxis_Row then
                    TileExpansionBroadcastSlot(
                        axis, broadcast_tile.layout, operation_type)
                    else column;
                let element = TileLogicalLinearIndex(broadcast_tile,
                    broadcast_row as integer {0..65535},
                    broadcast_column as integer {0..65535});
                if !TileElementDefined(broadcast,
                       broadcast_row as integer {0..65535},
                       broadcast_column as integer {0..65535}) ||
                   IsZero(TileReadLogicalElement(broadcast_tile, element)) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileReductionAndExpansionLogicalShapeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    if !TileReductionAndExpansionDescriptorLegal(left) ||
       !TileReductionAndExpansionDescriptorLegal(right) then
        return FALSE;
    end;
    let left_tile = _Tiles[[left]];
    let right_tile = _Tiles[[right]];
    return left_tile.valid_rows == right_tile.valid_rows &&
           left_tile.valid_columns == right_tile.valid_columns &&
           left_tile.layout == right_tile.layout;
end;

readonly func TileOperandsLegal_ExecuteTileFillScalar(
    destination: TileIndex, scalar: Word) => boolean
begin
    return TileReductionAndExpansionDescriptorLegal(destination) &&
           _Tiles[[destination]].storage_kind == TileStorage_Numeric &&
           TileFillPadDataTypeSupported(
               _Tiles[[destination]].data_type);
end;

readonly func TileOperandsLegal_ExecuteTileReduction(
    operation: TileReductionOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    if destination == source ||
       !TileReductionAndExpansionDescriptorLegal(destination) ||
       !TileReductionAndExpansionDescriptorLegal(source) then
        return FALSE;
    end;

    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let (operation_type_valid, operation_type) =
        ResolveTileSelectedOperationType(source_tile.data_type);
    if !operation_type_valid ||
       !TileReductionSourceLegalAs(source, operation_type) then
        return FALSE;
    end;
    let index_reduction =
        operation == TileReduction_ARGMIN ||
        operation == TileReduction_ARGMAX;
    let source_type_legal =
        if index_reduction then
            TileArgReductionSourceDataTypeSupported(operation_type)
        else
            TileVecArithmeticDataTypeSupported(operation_type);
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.layout != source_tile.layout ||
       source_tile.valid_rows == 0 ||
       source_tile.valid_columns == 0 ||
           !source_type_legal then
        return FALSE;
    end;

    if index_reduction then
        if destination_tile.data_type != TileDataType_U32 then
            return FALSE;
        end;
    elsif destination_tile.data_type != operation_type then
        return FALSE;
    end;

    if axis == TileAxis_Row then
        if destination_tile.valid_rows != source_tile.valid_rows ||
           destination_tile.valid_columns != 1 then
            return FALSE;
        end;
        if source_tile.layout == TileLayout_RowMajor then
            return destination_tile.rows == DerivedTileRows(
                       destination_tile.capacity_bytes, 1,
                       destination_tile.data_type) &&
                   destination_tile.columns == 1;
        end;
        return destination_tile.rows == TileCubeStorageRows(
                   destination_tile.layout, source_tile.valid_rows,
                   destination_tile.data_type) &&
               destination_tile.columns == source_tile.columns;
    end;
    if destination_tile.valid_rows != 1 ||
       destination_tile.valid_columns != source_tile.valid_columns then
        return FALSE;
    end;
    if source_tile.layout == TileLayout_RowMajor then
        return destination_tile.rows == DerivedTileRows(
                   destination_tile.capacity_bytes, source_tile.columns,
                   destination_tile.data_type) &&
               destination_tile.columns == source_tile.columns;
    end;
    return destination_tile.rows == source_tile.rows &&
           destination_tile.columns == TileCubeStorageColumns(
               destination_tile.layout, source_tile.valid_columns,
               destination_tile.data_type);
end;

readonly func TileOperandsLegal_ExecuteTileExpandAs(
    operation: TileExpandOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex,
    broadcast_source: TileIndex,
    source_operation_type: TileDataType,
    destination_operation_type: TileDataType) => boolean
begin
    let copy = operation == TileExpand_COPY;
    let expdif = operation == TileExpand_EXPDIF;
    if !TileReductionAndExpansionDescriptorLegal(destination) ||
       !TileReductionAndExpansionDescriptorLegal(source) ||
       !TileReductionAndExpansionDescriptorLegal(broadcast_source) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast_source]];
    if destination_tile.storage_kind != TileStorage_Numeric ||
       destination_tile.valid_rows == 0 ||
       destination_tile.valid_columns == 0 ||
       !TileVecArithmeticDataTypeSupported(destination_operation_type) ||
       destination_tile.data_type != destination_operation_type ||
       source_tile.storage_kind != TileStorage_Numeric ||
       broadcast_tile.storage_kind != TileStorage_Numeric ||
       broadcast_tile.layout != destination_tile.layout ||
       source_tile.layout != destination_tile.layout then
        return FALSE;
    end;

    if copy then
        if source != broadcast_source ||
           !TileExpansionBroadcastElementsLegalAs(
               broadcast_source, axis, destination_operation_type, FALSE) then
            return FALSE;
        end;
    else
        if !TileReductionAndExpansionSourceLegalAs(
               source, source_operation_type) ||
           !TileExpansionBroadcastLegalAs(
               broadcast_source, axis, source_operation_type) then
            return FALSE;
        end;
    end;

    if (expdif && !TileExpdifTypePairLegal(
                      source_operation_type, destination_operation_type)) ||
       (!expdif && source_operation_type != destination_operation_type) then
        return FALSE;
    end;

    let broadcast_shape_legal = if axis == TileAxis_Row then
        broadcast_tile.valid_rows == destination_tile.valid_rows &&
        broadcast_tile.valid_columns >= 1
    else
        broadcast_tile.valid_rows >= 1 &&
        broadcast_tile.valid_columns == destination_tile.valid_columns;
    if !broadcast_shape_legal then return FALSE; end;

    if !copy &&
       !TileReductionAndExpansionLogicalShapeMatch(destination, source) then
        return FALSE;
    end;

    if operation == TileExpand_DIV &&
       TileDataTypeIsInteger(destination_operation_type) then
        return TileExpansionBroadcastNonzero(
            axis, source, broadcast_source, source_operation_type);
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_ExecuteTileExpand(
    operation: TileExpandOperation,
    axis: TileAxis,
    destination: TileIndex,
    source: TileIndex,
    broadcast_source: TileIndex) => boolean
begin
    let expdif = operation == TileExpand_EXPDIF;
    let (operation_type_valid, selected_type) =
        ResolveTileSelectedOperationType(_Tiles[[destination]].data_type);
    if !operation_type_valid then return FALSE; end;
    let source_operation_type = if expdif && !BundleTileOperationSelected() then
        _Tiles[[source]].data_type else selected_type;
    let destination_operation_type = if expdif then
        _Tiles[[destination]].data_type else selected_type;
    return TileOperandsLegal_ExecuteTileExpandAs(
        operation, axis, destination, source, broadcast_source,
        source_operation_type, destination_operation_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
