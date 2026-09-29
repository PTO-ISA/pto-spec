<!-- GENERATED FROM: asl/block/model/dispatch/comparison-schema.asl -->
# Comparison Schema

**Normative ASL source:** `asl/block/model/dispatch/comparison-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-comparison-schema-purpose role=purpose-scope -->
## 用途与范围

本单元负责比较 `TCMP` 与选择 `TSEL` 的封闭指令束 schema，以及被 `TCMPS`、`TSELS`、归约和扩展复用的共享辅助函数。封闭 schema 列出某个操作唯一接受的 `B.IOT`、`B.IOR` 与 `B.DIM` 记录组合，并拒绝其他任何组合。

它的主要入口是：

- `SelectedBundleClosedTCMPSchemaLegal` 和 `SelectedBundleClosedTSELSchemaLegal`，两个 schema 检查。
- `SelectedBundleComparisonUsesGPRCarrier`、`SelectedBundleComparisonProducesGPR` 和 `SelectedBundleComparisonConsumesGPR`，判断谓词是否经由 GPR 传递。
- `BundleComparisonCodeAsTileComparison`，把 `CMode` 编码 0 到 5 映射为 EQ、NE、LT、GT、LE 和 GE。

<!-- PTO-READER-BLOCK: block-model-dispatch-comparison-schema-concepts role=concepts-state -->
## 概念与可见状态

比较结果或选择谓词使用以下三种载体之一：

| 载体 | 布局 | 表示 |
| --- | --- | --- |
| 旧式谓词 Tile | `RowMajor` | Local Tile 中每元素一位 |
| PredicateCell | `CUBE_M16` 或 `CUBE_M32` | Local Tile 中每元素一个 `U8` 字节 |
| 谓词 GPR | `CUBE_M16` 或 `CUBE_M32` | 1 或 2 个 GPR 字中的掩码位 |

8 位操作类型使用 2 个掩码字，覆盖 CUBE 低、高两半谓词。16 位和 32 位类型使用 1 个字。

这些检查是只读的。它们读取 `_BundleTileBindings`、`_BundleScalarBindings`、`_BundleDimensions`、`_BundleDataAttributes`、`_BundleExecutionMask` 以及 `_Tiles` 中的源描述符。

<!-- PTO-READER-BLOCK: block-model-dispatch-comparison-schema-rules role=rules-interactions -->
## 规则与交互

两个 schema 都先要求没有 Shared 绑定，并且 ValidCol、ValidRow 和 Col 的 `B.DIM` 值在 1 到 65535 之间。对 `TCMP` 以及除旧式谓词 Tile 形式以外的每种 `TSEL` 形式，第一个数值源还必须与 `B.DIM` 一致：其有效形状等于 ValidRow 乘 ValidCol，其物理列数等于 Col；对 CUBE 源则等于由 Col 推导的 CUBE 存储列数。

对 `TCMP`，源布局决定结果载体：

- `RowMajor` 源需要一个新的 Local 目标且没有 `B.IOR`，除非 ExecutionMask 位于 GPR 中。
- 带 Local 目标的 CUBE 源产生 PredicateCell。`Sat` 和 `Canonicalize` 必须为零，并且容量必须能容纳源有效行列数的 `U8` CUBE 形状。
- 没有 Tile 目标的 CUBE 源写入 GPR。它需要恰好一条 `B.IOR` 记录，其源字段为零（除非承载 GPR ExecutionMask 字），`Canonicalize` 为零，且只有 8 位类型允许 `Sat`。

对 `TSEL`，第一个源的种类决定形式。PredicateCell 第一个源使用两个绑定；旧式谓词 Tile 使用一个绑定，带 Tile ExecutionMask 时使用两个；没有谓词 Tile 的 CUBE 真源从 `B.IOR` 读取掩码。

设计要点：ASL 注释说明，在 CUBE GPR 形式中，编码的寄存器零仍是架构 GPR0，因此 `B.IOR` 目标为零并不表示“没有目标”。该 `B.IOR` 记录仍然必需，写入 GPR0 的结果会被 `WriteGPR` 丢弃。

设计要点：存在 ExecutionMask 时，CUBE 源只在掩码活动坐标上检查已定义性。ASL 注释说明，没有掩码时，这等价于要求源的全部内容已定义。

<!-- PTO-READER-BLOCK: block-model-dispatch-comparison-schema-boundaries role=boundaries -->
## 架构边界

这些检查返回布尔值。Tile 执行所有者在 PE 掩码为零的退出之后，从 `SelectedBundleClosedSchemasLegal` 调用它们，并在目标解析之前把假结果映射为 `Fault_TileLegality`。

产生 GPR 的 `TCMP` 和 `TCMPS` 形式随后经由 `ExecuteBundleComparisonGPRCarrier` 执行，不分配 Tile。消耗 GPR 的 `TSEL` 和 `TSELS` 形式先解析其 Tile 目标。谓词求值本身属于 Tile 比较与选择执行所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-comparison-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

```text
TCMP <Row=16, Col=4, FP16, LT>, T#1, T#2, ->a3
```

假设 `T#1` 和 `T#2` 是 Local `FP16` `CUBE_M16` Tile，有 16 个有效行和 4 个有效列。指令束有一条带两个源且无目标的 `B.IOT`，以及一条目标选择 `a3`、源字段为零的 `B.IOR`。schema 选择 GPR 形式。`CMode` 编码 2 映射为 LT。`FP16` 宽 16 位，因此结果使用 1 个掩码字，该字以 4 个 16 行位字段容纳 16 乘 4 的谓词。`Sat` 必须为零。

<!-- PTO-READER-BLOCK: block-model-dispatch-comparison-schema-related role=related-owners-navigation -->
## 相关所有者

- [Tile 执行分派](tile-execution.md) 安排这些检查的顺序并运行 GPR 载体路径。
- [谓词目标](predicate-destination.md) 分配旧式结果和 PredicateCell 结果。
- [目标操作路由](destination-operation.md) 路由 `TCMP` 和 CUBE `TSEL` 的目标。
- [TCMP](../../../tile/elementwise-tile-tile/logical/TCMP.md) 和 [TSEL](../../../tile/elementwise-tile-tile/logical/TSEL.md) 是指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/comparison-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","surface":"block","classification":["model","dispatch","comparison-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA"]}
pure func TileOperationUsesClosedTCMPSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TCMP;
end;

pure func TileOperationUsesClosedTSELSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TSEL;
end;

pure func TileOperationUsesClosedComparisonSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationUsesClosedTCMPSchema(operation) ||
           TileOperationUsesClosedTSELSchema(operation);
end;

readonly func SelectedBundleComparisonDimensionsLegal() => boolean
begin
    if UInt(_BundleDimensions[[0]]) < 1 ||
       UInt(_BundleDimensions[[0]]) > 65535 then
        return FALSE;
    end;
    for dimension = 1 to 2 looplimit 2 do
        if UInt(_BundleDimensions[[dimension]]) < 1 ||
           UInt(_BundleDimensions[[dimension]]) > 65535 then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func SelectedBundleComparisonShapeMatches(
    source: TileIndex) => boolean
begin
    let tile = _Tiles[[source]];
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if tile.valid_rows != valid_rows ||
       tile.valid_columns != valid_columns then
        return FALSE;
    end;
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile) &&
               tile.valid_rows == valid_rows &&
               tile.valid_columns == valid_columns &&
               tile.columns == TileCubeStorageColumns(
                   tile.layout, columns, tile.data_type);
    end;
    return tile.columns == columns;
end;

readonly func SelectedBundleComparisonSourceContentsDefined(
    source: TileIndex) => boolean
begin
    let tile = _Tiles[[source]];
    if TileLayoutIsCube(tile.layout) then
        // Keep the CUBE descriptor check, but let the shared elementwise
        // definedness rule inspect only ExecutionMask-active coordinates.
        // With no ExecutionMask that rule remains equivalent to the original
        // full-source contents_defined requirement.
        return TileCubeDescriptorLegal(tile) &&
               TileElementwiseSourceContentsDefined(source);
    end;
    return TileSourceContentsDefined(source);
end;

readonly func SelectedBundleComparisonShapeMatch(
    left: TileIndex, right: TileIndex) => boolean
begin
    if TileLayoutIsCube(_Tiles[[left]].layout) ||
       TileLayoutIsCube(_Tiles[[right]].layout) then
        return TileCubeNumericShapeMatch(left, right);
    end;
    return TileLogicalShapeMatch(left, right) &&
           _Tiles[[left]].storage_kind == _Tiles[[right]].storage_kind;
end;

readonly func TileRowMajorOrCUBENumericCarrierLegal(
    source: TileIndex, operation_type: TileDataType) => boolean
begin
    let tile = _Tiles[[source]];
    if TileLayoutIsCube(tile.layout) then
        return TileCubePredicateDataTypeSupported(tile.data_type) &&
               TileCarrierWidthCompatible(tile.data_type, operation_type);
    end;
    return TileRowMajorNumericCarrierLegal(source, operation_type);
end;

readonly func SelectedBundleComparisonCUBE(source: TileIndex) => boolean
begin
    return _Tiles[[source]].layout == TileLayout_CUBE_M16 ||
           _Tiles[[source]].layout == TileLayout_CUBE_M32;
end;

readonly func SelectedBundleComparisonGPRMaskWordCount(
    operation_type: TileDataType) => integer {1..2}
begin
    // 8-bit operation types consume the two complete 64-bit words covering
    // the CUBE Low/High predicate halves. Wider 16/32-bit types use one word.
    return if TileElementBits(operation_type) == 8 then 2 else 1;
end;

pure func BundleComparisonGPRSelectorLegal(selector: Reg5Selector) => boolean
begin
    return selector < PTO_ABSOLUTE_GPR_COUNT;
end;

pure func BundleComparisonBindingUsesNoSources(
    binding: BundleScalarBinding) => boolean
begin
    return binding.source0 == 0 &&
           binding.source1 == 0 &&
           binding.source2 == 0;
end;

pure func BundleComparisonBindingUsesOneSource(
    binding: BundleScalarBinding) => boolean
begin
    return BundleComparisonGPRSelectorLegal(binding.source0) &&
           binding.source1 == 0 &&
           binding.source2 == 0;
end;

pure func BundleComparisonBindingUsesTwoSources(
    binding: BundleScalarBinding) => boolean
begin
    return BundleComparisonGPRSelectorLegal(binding.source0) &&
           BundleComparisonGPRSelectorLegal(binding.source1) &&
           binding.source2 == 0;
end;

pure func BundleComparisonBindingUsesThreeSources(
    binding: BundleScalarBinding) => boolean
begin
    return BundleComparisonGPRSelectorLegal(binding.source0) &&
           BundleComparisonGPRSelectorLegal(binding.source1) &&
           BundleComparisonGPRSelectorLegal(binding.source2);
end;

readonly func BundleComparisonCodeAsTileComparison() => TileComparison
begin
    case UInt(_BundleDataAttributes.comparison_mode) of
        when 0 => return TileComparison_EQ;
        when 1 => return TileComparison_NE;
        when 2 => return TileComparison_LT;
        when 3 => return TileComparison_GT;
        when 4 => return TileComparison_LE;
        when 5 => return TileComparison_GE;
        otherwise => return TileComparison_EQ;
    end;
end;

readonly func SelectedBundleComparisonUsesGPRCarrier(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TCMP || decoded == TileOperation_TCMPS then
        return _BundleScalarBindings[[0]].valid &&
               !_BundleTileBindings[[0]].destination_valid;
    end;
    if decoded == TileOperation_TSEL then
        return _BundleTileBindings[[0]].source0_valid &&
               _Tiles[[BundleTileSourceIndex(0, FALSE)]].storage_kind !=
                   TileStorage_PredicateCell &&
               _BundleScalarBindings[[0]].valid;
    end;
    if decoded == TileOperation_TSELS then
        return _BundleTileBindings[[0]].source0_valid &&
               _Tiles[[BundleTileSourceIndex(0, FALSE)]].storage_kind !=
                   TileStorage_PredicateCell &&
               _BundleScalarBindings[[0]].valid;
    end;
    return FALSE;
end;

readonly func SelectedBundleComparisonProducesGPR(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return SelectedBundleComparisonUsesGPRCarrier(operation) &&
           (decoded == TileOperation_TCMP ||
            decoded == TileOperation_TCMPS);
end;

readonly func SelectedBundleComparisonConsumesGPR(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return SelectedBundleComparisonUsesGPRCarrier(operation) &&
           (decoded == TileOperation_TSEL ||
            decoded == TileOperation_TSELS);
end;

readonly func SelectedBundleClosedTCMPSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTCMPSchema(operation) then return TRUE; end;
    if BundleSharedBindingCount() != 0 || !SelectedBundleComparisonDimensionsLegal() ||
       BundleTileBindingCount() != (if _BundleExecutionMask.valid &&
           _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile
           then 2 else 1) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    let output_binding = if execution_mask_tile then
        _BundleTileBindings[[1]] else binding;
    if !binding.source0_valid || !binding.source1_valid ||
       (if execution_mask_tile then
            binding.destination_valid || binding.last ||
            !output_binding.source0_valid || output_binding.source1_valid ||
            !output_binding.last ||
            _BundleExecutionMask.predicate_source_ordinal != 2
        else
            !binding.last) then
        return FALSE;
    end;
    let source_left = BundleTileSourceIndex(0, FALSE);
    let source_right = BundleTileSourceIndex(0, TRUE);
    let (operation_type_valid, data_type) = ResolveBundleEffectiveDataType();
    if UInt(_BundleDataAttributes.comparison_mode) > 5 ||
       !operation_type_valid ||
       !TileCompareDataTypeSupported(data_type) ||
       !SelectedBundleComparisonShapeMatch(source_left, source_right) ||
       _Tiles[[source_left]].storage_kind != TileStorage_Numeric ||
       !TileRowMajorOrCUBENumericCarrierLegal(source_left, data_type) ||
       !TileRowMajorOrCUBENumericCarrierLegal(source_right, data_type) ||
       !SelectedBundleComparisonSourceContentsDefined(source_left) ||
       !SelectedBundleComparisonSourceContentsDefined(source_right) ||
       !SelectedBundleComparisonShapeMatches(source_left) then return FALSE; end;
    let cube = SelectedBundleComparisonCUBE(source_left);
    if cube && !TileCubePredicateDataTypeSupported(data_type) then
        return FALSE;
    end;
    if cube && (!TileCubeNumericSourceLegalAs(source_left, data_type) ||
                !TileCubeNumericSourceLegalAs(source_right, data_type)) then
        return FALSE;
    end;
    if !cube && (!TileElementwiseSourceEncodingsValidAs(source_left, data_type) ||
                 !TileElementwiseSourceEncodingsValidAs(source_right, data_type)) then
        return FALSE;
    end;
    if !cube then
        return output_binding.destination_valid &&
               !output_binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(
                   if execution_mask_tile then 1 else 0) &&
               (!execution_mask_gpr ||
                (_BundleScalarBindings[[0]].valid &&
                 _BundleScalarBindings[[0]].destination == 0)) &&
               (execution_mask_gpr || !_BundleScalarBindings[[0]].valid) &&
               _Tiles[[source_left]].layout == TileLayout_RowMajor;
    end;
    // CUBE CellReg form has a Local PredicateCell destination and no B.IOR.
    if output_binding.destination_valid then
        let capacity_bytes = BundleLocalDestinationAllocationBytes(
            if execution_mask_tile then 1 else 0);
        return (!execution_mask_gpr ||
                (_BundleScalarBindings[[0]].valid &&
                 _BundleScalarBindings[[0]].destination == 0)) &&
               (execution_mask_gpr || !_BundleScalarBindings[[0]].valid) &&
               !_BundleDataAttributes.saturating &&
               !_BundleDataAttributes.canonicalize &&
               !output_binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(
                   if execution_mask_tile then 1 else 0) &&
               TileCubeDescriptorShapeLegal(
                   capacity_bytes, _Tiles[[source_left]].valid_rows,
                   _Tiles[[source_left]].valid_columns, TileDataType_U8,
                   _Tiles[[source_left]].layout);
    end;
    // CUBE GPR form has no tile destination and exactly one destination-only
    // B.IOR record.  Encoded zero is still architectural GPR0.
    return _BundleScalarBindings[[0]].valid &&
           (if execution_mask_gpr then
                BundleExecutionMaskGPRBindingSchemaLegal(operation)
            else
                BundleComparisonBindingUsesNoSources(
                    _BundleScalarBindings[[0]])) &&
           BundleComparisonGPRSelectorLegal(
               _BundleScalarBindings[[0]].destination) &&
           !output_binding.destination_valid &&
           (!_BundleDataAttributes.canonicalize) &&
           (TileElementBits(data_type) == 8 ||
            !_BundleDataAttributes.saturating) &&
           TileOperandsLegal_ExecuteTileCompareGPRAs(
               source_left, source_right,
               _BundleDataAttributes.saturating, data_type) &&
           !_BundleScalarBindings[[1]].valid;
end;

readonly func SelectedBundleClosedTSELSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTSELSchema(operation) then return TRUE; end;
    if BundleSharedBindingCount() != 0 || !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;
    let (operation_type_valid, data_type) = ResolveBundleEffectiveDataType();
    if !operation_type_valid || !TileSelectDataTypeSupported(data_type) then
        return FALSE;
    end;
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    let inputs = _BundleTileBindings[[0]];
    let cell_select = inputs.source0_valid &&
        _Tiles[[BundleTileSourceIndex(0, FALSE)]].storage_kind ==
            TileStorage_PredicateCell;
    if BundleTileBindingCount() !=
       (if cell_select || execution_mask_tile then 2 else 1) then
        return FALSE;
    end;
    let result = if BundleTileBindingCount() == 2 then
        _BundleTileBindings[[1]] else inputs;
    let split_gpr_select = !cell_select && execution_mask_tile;
    let binding_shape_invalid = if cell_select then
        inputs.destination_valid || !inputs.source0_valid ||
        !inputs.source1_valid || inputs.last ||
        !result.destination_valid || !result.source0_valid ||
        (result.source1_valid != execution_mask_tile) || !result.last
    else if split_gpr_select then
        inputs.destination_valid || !inputs.source0_valid ||
        !inputs.source1_valid || inputs.last ||
        !result.destination_valid || !result.source0_valid ||
        result.source1_valid || !result.last
    else
        !inputs.destination_valid || !inputs.source0_valid ||
        !inputs.source1_valid || !inputs.last;
    if binding_shape_invalid ||
       result.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(
           if BundleTileBindingCount() == 2 then 1 else 0) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal !=
            (if cell_select then 3 else 2)) then
        return FALSE;
    end;
    let source_true = if cell_select then
        BundleTileSourceIndex(0, TRUE) else BundleTileSourceIndex(0, FALSE);
    let source_false = if cell_select then
        BundleTileSourceIndex(1, FALSE) else BundleTileSourceIndex(0, TRUE);
    if cell_select then
        let mask = BundleTileSourceIndex(0, FALSE);
        return (!execution_mask_gpr ||
                (_BundleScalarBindings[[0]].valid &&
                 _BundleScalarBindings[[0]].destination == 0 &&
                 BundleExecutionMaskGPRBindingSchemaLegal(operation))) &&
               (execution_mask_gpr || !_BundleScalarBindings[[0]].valid) &&
               (!SelectedBundleComparisonCUBE(source_true) ||
                TileCubePredicateDataTypeSupported(data_type)) &&
               (if SelectedBundleComparisonCUBE(source_true) then
                   TilePredicateCellOperationValuesLegal(mask) &&
                   TilePredicateCellShapeMatchesNumericAs(
                       mask, source_true, data_type)
                else
                   TilePredicateValuesLegal(mask)) &&
               SelectedBundleComparisonShapeMatch(source_true, source_false) &&
               _Tiles[[source_true]].storage_kind == TileStorage_Numeric &&
               TileRowMajorOrCUBENumericCarrierLegal(source_true, data_type) &&
               TileRowMajorOrCUBENumericCarrierLegal(source_false, data_type) &&
               SelectedBundleComparisonSourceContentsDefined(source_true) &&
               SelectedBundleComparisonSourceContentsDefined(source_false) &&
               SelectedBundleComparisonShapeMatches(source_true);
    end;
    if !SelectedBundleComparisonCUBE(source_true) then
        return !_BundleScalarBindings[[1]].valid &&
               (!_BundleScalarBindings[[0]].valid ||
                (_BundleScalarBindings[[0]].destination == 0 &&
                 BundleComparisonBindingUsesOneSource(
                     _BundleScalarBindings[[0]]))) &&
               TilePredicateValuesLegal(source_true) &&
               SelectedBundleComparisonShapeMatch(source_true, source_false) &&
               TileRowMajorNumericCarrierLegal(source_false, data_type) &&
               TileElementwiseSourceContentsDefined(source_false) &&
               TileLogicalShapeMatch(source_true, source_false);
    end;
    let mask_words = SelectedBundleComparisonGPRMaskWordCount(data_type);
    return TileCubePredicateGPRDataTypeSupported(data_type) &&
           TileCubePredicateGPRShapeLegalAs(source_true, data_type) &&
           SelectedBundleComparisonShapeMatch(source_true, source_false) &&
           _Tiles[[source_true]].storage_kind == TileStorage_Numeric &&
           TileRowMajorOrCUBENumericCarrierLegal(source_true, data_type) &&
           TileRowMajorOrCUBENumericCarrierLegal(source_false, data_type) &&
           SelectedBundleComparisonSourceContentsDefined(source_true) &&
           SelectedBundleComparisonSourceContentsDefined(source_false) &&
           SelectedBundleComparisonShapeMatches(source_true) &&
           _BundleScalarBindings[[0]].valid &&
           _BundleScalarBindings[[0]].destination == 0 &&
           (if execution_mask_gpr then
                BundleExecutionMaskGPRBindingSchemaLegal(operation)
            else if mask_words == 2 then
                BundleComparisonBindingUsesTwoSources(
                    _BundleScalarBindings[[0]])
            else
                BundleComparisonBindingUsesOneSource(
                    _BundleScalarBindings[[0]])) &&
           (execution_mask_gpr || !_BundleScalarBindings[[1]].valid);
end;
```
<!-- GENERATED-ASL-END: unit -->
