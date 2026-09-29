<!-- GENERATED FROM: asl/block/model/dispatch/tile-scalar-schema.asl -->
# Tile Scalar Schema

**Normative ASL source:** `asl/block/model/dispatch/tile-scalar-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tile-scalar-schema-purpose role=purpose-scope -->
## 用途与范围

本单元定义 TEPL Mode 1 中 Tile-标量操作的封闭指令束 schema。Tile-标量操作把一个 Tile 的每个元素与从寄存器读取的一个标量值组合。封闭 schema 是指令束为某个操作必须携带的确切绑定、维度和类型集合。

它覆盖四组：

- 二元组 `TADDS`、`TSUBS`、`TMULS`、`TDIVS`、`TREMS`、`TANDS`、`TORS`、`TXORS`、`TSHLS`、`TSHRS`、`TMAXS` 和 `TMINS`；
- 比较 `TCMPS`；
- 选择 `TSELS`；
- 填充 `TEXPANDS`。

每个 `SelectedBundleClosed...SchemaLegal` 函数对其组外的操作返回真。Tile 执行所有者通过 `SelectedBundleClosedSchemasLegal` 调用它们，结果为假会在目标分配之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-scalar-schema-concepts role=concepts-state -->
## 概念与可见状态

- 标量通过 `SelectedBundleTileScalarRawValue` 取自第一个标量绑定的 `source0` 寄存器。没有标量绑定时它为零。
- 原始载体操作把元素视为位模式。在二元组中，它们是 `TANDS`、`TORS`、`TXORS`、`TSHLS` 和 `TSHRS`。
- 活动坐标是执行掩码启用的元素位置。没有掩码时每个位置都是活动的。

这些 schema 读取 Tile 绑定、标量绑定、维度、数据属性、执行掩码、源 Tile 描述符和标量寄存器。它们不写入任何状态。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-scalar-schema-rules role=rules-interactions -->
## 规则与交互

二元 schema 要求一个 Tile 绑定、没有 Shared 绑定，且维度位于 `1..65535`。该绑定指定尺寸码合法的目标和 `source0`，并且是最后一个。`source1` 只作为源序号 1 处的谓词 Tile 执行掩码出现。数据类型必须受该二元操作支持，布局必须是逐元素布局，源必须与维度匹配且已定义。对于非原始操作，源元素和标量必须是该数据类型的有效编码。

设计要点：对于整数 `TDIVS` 和 `TREMS`，当至少有一个坐标活动时，schema 拒绝零标量。于是除法在分配任何目标之前就被拒绝。当执行掩码没有活动坐标时，零除数被接受，因为没有元素会被除。

`TCMPS` 要求一个绑定、合法维度且比较模式至多为 5。其余取决于源布局。

- RowMajor 源写入 Tile 目标。标量绑定可选；存在时其目标为 0 且只有一个源，或遵循 GPR 掩码 schema。
- 带目标的 CUBE 源写入 U8 谓词 Tile。饱和与规范化必须关闭。
- 不带目标的 CUBE 源写入 GPR。标量绑定是必需的，并指定目标寄存器。规范化必须关闭，饱和只对 8 位类型允许。

`TSELS` 取决于第一个源是否为 PredicateCell（存储在 CUBE 单元中的谓词），以及真值源是否使用 CUBE 布局。带谓词 Tile 掩码的 PredicateCell 选择使用两个绑定。第一个源不是 CUBE Tile 的选择要求存在 `source1`、没有执行掩码 Tile，并以旧式 Predicate Tile 作为 `source0`。不带 PredicateCell 的 CUBE 选择从 GPR 读取谓词：一个掩码字用两个源，两个字用三个源。

`TEXPANDS` 要求一个带目标且没有源的绑定，序号 0 处的掩码除外。它需要受支持的算术类型，以及受归约与扩展支持的布局。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-scalar-schema-boundaries role=boundaries -->
## 架构边界

这些 schema 返回布尔值，自身不引发故障。目标分配属于目标所有者，算术属于 Tile 模型。比较维度与形状辅助函数来自比较 schema 所有者。本单元定义的 `SelectedBundleTileScalarSourceLegal` 在当前 ASL 中没有调用者；二元 schema 使用逐元素变体。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-scalar-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

某 `TDIVS` 指令束使用 `S32`。源 Tile 有 8 个有效行和 16 个有效列，维度为 16、8 和 16。一个 `B.IOT` 指定目标和源并且是最后一个。一个 `B.IOR` 把 GPR 9 指定为 `source0`，GPR 9 的值为 0。没有执行掩码时每个元素都是活动的，因此 schema 失败，指令束在分配之前以 `Fault_TileLegality` 故障。如果 GPR 9 的值为 3，schema 会通过。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-scalar-schema-related role=related-owners-navigation -->
## 相关所有者

- [Comparison schema](comparison-schema.md) 定义共用的比较辅助函数。
- [Tile schema](tile-schema.md) 包含 Tile-Tile 封闭 schema。
- [Tile execution](tile-execution.md) 调用这些 schema。
- [TADDS](../../../tile/tile-scalar-and-immediate/arithmetic/TADDS.md) 是其中一个指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tile-scalar-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","surface":"block","classification":["model","dispatch","tile-scalar-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}
// Closed complete-bundle schemas for TEPL Mode 1 Tile-scalar operations.

pure func TileOperationUsesClosedTileScalarBinarySchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TADDS ||
           decoded == TileOperation_TSUBS ||
           decoded == TileOperation_TMULS ||
           decoded == TileOperation_TDIVS ||
           decoded == TileOperation_TREMS ||
           decoded == TileOperation_TANDS ||
           decoded == TileOperation_TORS ||
           decoded == TileOperation_TXORS ||
           decoded == TileOperation_TSHLS ||
           decoded == TileOperation_TSHRS ||
           decoded == TileOperation_TMAXS ||
           decoded == TileOperation_TMINS;
end;

pure func TileOperationUsesClosedTCMPSSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TCMPS;
end;

pure func TileOperationUsesClosedTSELSSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TSELS;
end;

pure func TileOperationUsesClosedTEXPANDSSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TEXPANDS;
end;

pure func TileOperationUsesClosedTileScalarSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationUsesClosedTileScalarBinarySchema(operation) ||
           TileOperationUsesClosedTCMPSSchema(operation) ||
           TileOperationUsesClosedTSELSSchema(operation) ||
           TileOperationUsesClosedTEXPANDSSchema(operation);
end;

pure func TileScalarBinaryOperation(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => TileBinaryOperation
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TADDS then return TileBinary_ADD;
    elsif decoded == TileOperation_TSUBS then return TileBinary_SUB;
    elsif decoded == TileOperation_TMULS then return TileBinary_MUL;
    elsif decoded == TileOperation_TDIVS then return TileBinary_DIV;
    elsif decoded == TileOperation_TREMS then return TileBinary_REM;
    elsif decoded == TileOperation_TANDS then return TileBinary_AND;
    elsif decoded == TileOperation_TORS then return TileBinary_OR;
    elsif decoded == TileOperation_TXORS then return TileBinary_XOR;
    elsif decoded == TileOperation_TSHLS then return TileBinary_SHL;
    elsif decoded == TileOperation_TSHRS then return TileBinary_SHR;
    elsif decoded == TileOperation_TMAXS then return TileBinary_MAX;
    elsif decoded == TileOperation_TMINS then return TileBinary_MIN;
    else unreachable;
    end;
end;

readonly func SelectedBundleTileScalarRawValue() => Word
begin
    if !_BundleScalarBindings[[0]].valid then
        return Zeros{PTO_XLEN};
    end;
    return ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source0);
end;

readonly func SelectedBundleTileScalarSourceLegal(
    source: TileIndex,
    data_type: TileDataType) => boolean
begin
    return TileDescriptorLegal(source) &&
           _Tiles[[source]].storage_kind == TileStorage_Numeric &&
           _Tiles[[source]].data_type == data_type &&
           _Tiles[[source]].layout == TileLayout_RowMajor &&
           SelectedBundleComparisonSourceContentsDefined(source) &&
           TileSourceEncodingsValid(source) &&
           SelectedBundleComparisonShapeMatches(source);
end;

readonly func SelectedBundleTileScalarElementwiseSourceLegal(
    source: TileIndex,
    data_type: TileDataType) => boolean
begin
    return TileElementwiseDescriptorLegal(source) &&
           _Tiles[[source]].storage_kind == TileStorage_Numeric &&
           TileCarrierWidthCompatible(_Tiles[[source]].data_type, data_type) &&
           TileElementwiseLayoutSupported(_Tiles[[source]].layout) &&
           SelectedBundleComparisonSourceContentsDefined(source) &&
           TileElementwiseSourceEncodingsValid(source) &&
           SelectedBundleComparisonShapeMatches(source);
end;

readonly func SelectedBundleClosedTileScalarBinarySchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTileScalarBinarySchema(operation) then
        return TRUE;
    end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       !binding.source0_valid ||
       (binding.source1_valid != execution_mask_tile) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal != 1) ||
       !binding.last then
        return FALSE;
    end;

    let binary = TileScalarBinaryOperation(operation);
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    let raw_carrier = binary == TileBinary_AND ||
                      binary == TileBinary_OR ||
                      binary == TileBinary_XOR ||
                      binary == TileBinary_SHL ||
                      binary == TileBinary_SHR;
    if !TileBinaryDataTypeSupported(binary, data_type) ||
       !TileElementwiseLayoutSupported(CurrentBundleTileLayout()) ||
       !SelectedBundleTileScalarElementwiseSourceLegal(
           binding.source0,
           data_type) then
        return FALSE;
    end;
    if !raw_carrier &&
       !TileElementwiseSourceEncodingsValidAs(binding.source0, data_type) then
        return FALSE;
    end;

    let scalar = TileRawElementValue(
        SelectedBundleTileScalarRawValue(),
        data_type);
    if !raw_carrier && !TileNumericEncodingValid(data_type, scalar) then
        return FALSE;
    end;
    if (binary == TileBinary_DIV || binary == TileBinary_REM) &&
       TileDataTypeIsInteger(data_type) &&
       BundleExecutionMaskHasActiveCoordinate() then
        return !IsZero(TileIntegerOperandValue(scalar, data_type));
    end;
    return TRUE;
end;

readonly func SelectedBundleClosedTCMPSSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTCMPSSchema(operation) then return TRUE; end;
    if BundleTileBindingCount() != 1 || BundleSharedBindingCount() != 0 ||
       !SelectedBundleComparisonDimensionsLegal() then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.source0_valid ||
       (binding.source1_valid != execution_mask_tile) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal != 1) ||
       !binding.last ||
       UInt(_BundleDataAttributes.comparison_mode) > 5 then return FALSE; end;
    let source = BundleTileSourceIndex(0, FALSE);
    let (operation_type_valid, data_type) = ResolveBundleEffectiveDataType();
    let scalar_present = _BundleScalarBindings[[0]].valid;
    let cube = SelectedBundleComparisonCUBE(source);
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    if !operation_type_valid ||
       !TileCompareDataTypeSupported(data_type) ||
       _Tiles[[source]].storage_kind != TileStorage_Numeric ||
       !TileRowMajorOrCUBENumericCarrierLegal(source, data_type) ||
       !SelectedBundleComparisonSourceContentsDefined(source) ||
       !SelectedBundleComparisonShapeMatches(source) then return FALSE; end;
    if cube && !TileCubePredicateDataTypeSupported(data_type) then
        return FALSE;
    end;
    if cube && !TileCubeNumericSourceLegalAs(source, data_type) then
        return FALSE;
    end;
    if !cube && !TileElementwiseSourceEncodingsValidAs(source, data_type) then
        return FALSE;
    end;
    if !cube then
        return binding.destination_valid &&
               !binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(0) &&
               !_BundleScalarBindings[[1]].valid &&
               (!scalar_present ||
                (_BundleScalarBindings[[0]].destination == 0 &&
                 (if execution_mask_gpr then
                      BundleExecutionMaskGPRBindingSchemaLegal(operation)
                  else
                      BundleComparisonBindingUsesOneSource(
                          _BundleScalarBindings[[0]]))));
    end;
    if binding.destination_valid then
        let capacity_bytes = BundleLocalDestinationAllocationBytes(0);
        return !binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(0) &&
               TileCubeDescriptorShapeLegal(
                   capacity_bytes, _Tiles[[source]].valid_rows,
                   _Tiles[[source]].valid_columns, TileDataType_U8,
                   _Tiles[[source]].layout) &&
               !_BundleDataAttributes.saturating &&
               !_BundleDataAttributes.canonicalize &&
               (!scalar_present ||
                (_BundleScalarBindings[[0]].destination == 0 &&
                 (if execution_mask_gpr then
                      BundleExecutionMaskGPRBindingSchemaLegal(operation)
                  else
                      BundleComparisonBindingUsesOneSource(
                          _BundleScalarBindings[[0]])))) &&
               !_BundleScalarBindings[[1]].valid;
    end;
    // GPR form consumes the scalar compare source and writes one B.IOR dst.
    return scalar_present &&
           (if execution_mask_gpr then
                BundleExecutionMaskGPRBindingSchemaLegal(operation)
            else
                BundleComparisonBindingUsesOneSource(
                    _BundleScalarBindings[[0]])) &&
           BundleComparisonGPRSelectorLegal(
               _BundleScalarBindings[[0]].destination) &&
           !_BundleDataAttributes.canonicalize &&
           (TileElementBits(data_type) == 8 ||
            !_BundleDataAttributes.saturating) &&
           TileOperandsLegal_ExecuteTileCompareCUBEScalarGPRAs(
               source, SelectedBundleTileScalarRawValue(), data_type) &&
           !_BundleScalarBindings[[1]].valid;
end;

readonly func SelectedBundleClosedTSELSSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTSELSSchema(operation) then return TRUE; end;
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
    let split_final_binding = cell_select && execution_mask_tile;
    if BundleTileBindingCount() != (if split_final_binding then 2 else 1) then
        return FALSE;
    end;
    let result = if split_final_binding then
        _BundleTileBindings[[1]] else inputs;
    if !inputs.source0_valid ||
       (if cell_select then
            !inputs.source1_valid
        else
            inputs.source1_valid != execution_mask_tile) ||
       (if split_final_binding then
            inputs.destination_valid || inputs.last ||
            !result.source0_valid || result.source1_valid || !result.last
        else
            !inputs.destination_valid || !inputs.last) ||
       !result.destination_valid || result.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(
           if split_final_binding then 1 else 0) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal !=
            (if cell_select then 2 else 1)) then
        return FALSE;
    end;
    let first = BundleTileSourceIndex(0, FALSE);
    let source_true = if cell_select then BundleTileSourceIndex(0, TRUE)
        else first;
    let cube = SelectedBundleComparisonCUBE(source_true);
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        if split_final_binding then 1 else 0);
    if cell_select then
        return cube && TileCubePredicateDataTypeSupported(data_type) &&
               (!execution_mask_gpr ||
                (_BundleScalarBindings[[0]].valid &&
                 _BundleScalarBindings[[0]].destination == 0 &&
                 BundleExecutionMaskGPRBindingSchemaLegal(operation))) &&
               (execution_mask_gpr ||
                (!_BundleScalarBindings[[1]].valid &&
                 (!_BundleScalarBindings[[0]].valid ||
                  (_BundleScalarBindings[[0]].destination == 0 &&
                   BundleComparisonBindingUsesOneSource(
                       _BundleScalarBindings[[0]]))))) &&
               TilePredicateCellOperationValuesLegal(first) &&
               TilePredicateCellShapeMatchesNumericAs(
                   first, source_true, data_type) &&
               _Tiles[[source_true]].storage_kind == TileStorage_Numeric &&
               TileRowMajorOrCUBENumericCarrierLegal(source_true, data_type) &&
               SelectedBundleComparisonSourceContentsDefined(source_true) &&
               TileCubeDescriptorShapeLegal(
                   capacity_bytes, _Tiles[[source_true]].valid_rows,
                   _Tiles[[source_true]].valid_columns, data_type,
                   _Tiles[[source_true]].layout);
    end;

    if !cube then
        return inputs.source1_valid && !execution_mask_tile &&
               (!_BundleScalarBindings[[1]].valid) &&
               (!_BundleScalarBindings[[0]].valid ||
                (_BundleScalarBindings[[0]].destination == 0 &&
                 BundleComparisonBindingUsesOneSource(
                     _BundleScalarBindings[[0]]))) &&
               TilePredicateValuesLegal(first) &&
               TileRowMajorNumericCarrierLegal(source_true, data_type) &&
               TileElementwiseSourceContentsDefined(source_true) &&
               TileLogicalShapeMatch(first, source_true);
    end;

    // The GPR selection predicate stays operation-owned; any ExecutionMask
    // GPR words follow it, while a PredicateCell ExecutionMask is the final
    // B.IOT source and is filtered from the arithmetic operand list.
    let mask_words = if TileCubePredicateGPRDataTypeSupported(data_type) then
        SelectedBundleComparisonGPRMaskWordCount(data_type) else 1;
    return TileCubePredicateGPRDataTypeSupported(data_type) &&
           _BundleScalarBindings[[0]].valid &&
           _BundleScalarBindings[[0]].destination == 0 &&
           (if execution_mask_gpr then
                BundleExecutionMaskGPRBindingSchemaLegal(operation)
            else if mask_words == 2 then
                BundleComparisonBindingUsesThreeSources(
                    _BundleScalarBindings[[0]])
            else
                BundleComparisonBindingUsesTwoSources(
                    _BundleScalarBindings[[0]])) &&
           _Tiles[[source_true]].storage_kind == TileStorage_Numeric &&
           TileRowMajorOrCUBENumericCarrierLegal(source_true, data_type) &&
           TileCubePredicateGPRShapeLegalAs(source_true, data_type) &&
           SelectedBundleComparisonSourceContentsDefined(source_true) &&
           TileCubeDescriptorShapeLegal(
               capacity_bytes, _Tiles[[source_true]].valid_rows,
               _Tiles[[source_true]].valid_columns, data_type,
               _Tiles[[source_true]].layout) &&
           (execution_mask_gpr || !_BundleScalarBindings[[1]].valid);
end;

readonly func SelectedBundleClosedTEXPANDSSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTEXPANDSSchema(operation) then return TRUE; end;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       !SelectedBundleComparisonDimensionsLegal() then
        return FALSE;
    end;

    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.destination_valid ||
       binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       (binding.source0_valid != execution_mask_tile) ||
       binding.source1_valid ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal != 0) ||
       !binding.last then
        return FALSE;
    end;

    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode()
            as TileDataTypeEncoding);
    return TileVecArithmeticDataTypeSupported(data_type) &&
           TileReductionAndExpansionLayoutSupported(
               CurrentBundleTileLayout());
end;
```
<!-- GENERATED-ASL-END: unit -->
