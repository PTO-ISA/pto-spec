<!-- GENERATED FROM: asl/block/model/dispatch/tcvt-schema.asl -->
# Tcvt Schema

**Normative ASL source:** `asl/block/model/dispatch/tcvt-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-schema-purpose role=purpose-scope -->
## 用途与范围

本单元定义 `TCVT`（Tile 类型转换操作）的封闭指令束 schema。封闭 schema 是指令束为某个操作必须携带的完整绑定、维度、类型和属性清单。`SelectedBundleClosedTCVTSchemaLegal` 对其他任何操作都返回真；对 `TCVT`，只有整个指令束符合该 schema 时才返回真。

Tile 执行所有者中的通用 Tile 路径通过 `SelectedBundleClosedSchemasLegal` 调用它。在那里结果为假会在分配任何目标之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-schema-concepts role=concepts-state -->
## 概念与可见状态

`TCVT` 有两种数据类型。

- 源操作类型来自操作描述符，经由 `CurrentBundleTileOperationDataTypeCode`。
- 目标类型来自 `ResolveBundleEffectiveDataType`。存在具体的 `B.DATR` 数据类型时使用它，否则使用描述符的数据类型。

该 schema 读取 Tile 绑定（`B.IOT`）、标量绑定（`B.IOR`）、三个指令束维度、执行掩码、`B.DATR` 的舍入模式、规范化标志与数据布局，以及源 Tile 的描述符。它不写入任何状态。

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-schema-rules role=rules-interactions -->
## 规则与交互

绑定形状是一个 Tile 绑定且没有 Shared 绑定。该绑定必须指定一个尺寸码合法的目标，指定 `source0`，并且是最后一个绑定。只有当执行掩码是谓词 Tile 时才出现 `source1`，此时该掩码必须是源序号 1。只有当执行掩码由 GPR 携带时才出现标量绑定，此时它必须满足 GPR 掩码 schema。

三个维度都必须位于 `1..65535`。源必须保存源类型的有效编码。类型对必须通过 `HardwareTCVTTypePairSupported`，解析后的舍入模式必须通过 `HardwareTCVTRoundingModeSupported`。

设计要点：编码为零的舍入字段表示“使用操作默认值”。该 schema 在此处把默认值解析为 `NumericRound_RNE`。ASL 注释给出了原因：`E6M2` 和 `RCPE6M2` 只接受 RNE 与 RNA，在 schema 预检期间解析舍入模式，可以在目标分配或任何效果之前拦下不受支持的模式。

形状规则取决于源布局。

- 对于 `CUBE_M16` 或 `CUBE_M32` 源，请求的有效列数与有效行数必须等于源的对应值，维度 2 必须为 1，规范化必须关闭，数据布局必须为 `NORM`，并且目标类型必须支持 CUBE。目标保持相同的 CUBE 布局。
- 其他任何 CUBE 布局都被拒绝。
- 对于非 CUBE 源，请求的有效列数、有效行数和物理列数都必须等于源的对应值，规范化必须关闭，并且源布局必须等于指令束的源布局。目标物理形状也必须合适：通常其推导出的行数等于源的行数；但当两种类型都允许奇数物理列且列数不是 2 的幂时，源行数必须能装入目标容量。

设计要点：对于 CUBE 源，该 schema 不对照维度 2 检查目标几何。ASL 注释说明，目标物理几何稍后由目标类型和请求的尺寸码推导，这由 TCVT 目标单元完成。

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-schema-boundaries role=boundaries -->
## 架构边界

本单元只回答是或否。它自身不引发故障，不分配任何东西，也不转换数值。CUBE 源的目标分配属于 TCVT 目标单元。数值转换属于 Tile `TCVT` 执行。执行掩码捕获属于执行掩码 schema 所有者，GPR 掩码绑定规则 `BundleExecutionMaskGPRBindingSchemaLegal` 属于标量 schema 所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

某指令束把一个 RowMajor FP32 源 Tile（16 个有效行、32 个有效列、32 个物理列）转换为 FP16。描述符类型为 FP32，`B.DATR` 选择 FP16。`B.DIM` 把维度 0 设为 32，维度 1 设为 16，维度 2 设为 32。有一个带目标与 `source0` 且标记为最后的 `B.IOT`，没有 `B.IOR`。没有掩码且舍入字段为零时，模式解析为 RNE。如果所选尺寸码下的 FP16 目标对 32 列推导出 16 行，该 schema 通过。把维度 2 设为 64 会失败，因为它不再等于源的 32 个物理列。

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-schema-related role=related-owners-navigation -->
## 相关所有者

- [TCVT destination](tcvt-destination.md) 为 CUBE 源分配目标。
- [Tile execution](tile-execution.md) 在目标解析之前调用该 schema。
- [Execution-mask schema](execution-mask-schema.md) 负责掩码载体规则。
- [TCVT](../../../tile/elementwise-tile-tile/format-conversion/TCVT.md) 是指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tcvt-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA","surface":"block","classification":["model","dispatch","tcvt-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA"]}
pure func TileOperationUsesClosedTCVTSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TCVT;
end;

readonly func SelectedBundleClosedTCVTSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTCVTSchema(operation) then return TRUE; end;
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    if BundleTileBindingCount() != 1 ||
       BundleSharedBindingCount() != 0 ||
       (_BundleScalarBindings[[0]].valid != execution_mask_gpr) ||
       (execution_mask_gpr &&
        !BundleExecutionMaskGPRBindingSchemaLegal(operation)) then
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

    let source = BundleTileSourceIndex(0, FALSE);
    let source_operation_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !TileTCVTSourceEncodingsValidAs(source, source_operation_type) then
        return FALSE;
    end;
    let (destination_type_valid, destination_type) =
        ResolveBundleEffectiveDataType();
    if !destination_type_valid ||
       !HardwareTCVTTypePairSupported(
           source_operation_type, destination_type) then
        return FALSE;
    end;
    // E6M2 and RCPE6M2 have a closed RNE/RNA profile. Resolve the operation
    // default here, while the bundle is still in schema preflight, so an
    // unsupported mode cannot reach destination allocation or effects. The
    // operand legality check repeats this rule after decoded operands exist.
    let rounding_selection = DecodeBundleRoundingSelection(
        _BundleDataAttributes.rounding_mode);
    let resolved_rounding_mode = if
        rounding_selection.use_operation_default then NumericRound_RNE
        else rounding_selection.rounding_mode;
    if !HardwareTCVTRoundingModeSupported(
           source_operation_type, destination_type,
           resolved_rounding_mode) then
        return FALSE;
    end;

    let source_layout = _Tiles[[source]].layout;
    let requested_valid_columns = UInt(_BundleDimensions[[0]]);
    let requested_valid_rows = UInt(_BundleDimensions[[1]]);
    let source_cube_m_layout =
        source_layout == TileLayout_CUBE_M16 ||
        source_layout == TileLayout_CUBE_M32;
    if source_cube_m_layout then
        // CUBE_M16/M32 TCVT keeps the same CUBE layout and valid region.
        // Destination physical geometry is derived later from the selected
        // destination type and the requested TSize.
        return requested_valid_columns == _Tiles[[source]].valid_columns &&
               requested_valid_rows == _Tiles[[source]].valid_rows &&
               UInt(_BundleDimensions[[2]]) == 1 &&
               !CurrentBundleCanonicalize() &&
               CurrentBundleDataLayout() == TileDataLayout_NORM &&
               TileCubeDescriptorShapeLegal(
                   _Tiles[[source]].capacity_bytes,
                   _Tiles[[source]].valid_rows,
                   _Tiles[[source]].valid_columns,
                   source_operation_type, source_layout) &&
               TileCubeDataTypeSupported(destination_type);
    end;
    if TileLayoutIsCube(source_layout) then
        return FALSE;
    end;

    let requested_columns = UInt(_BundleDimensions[[2]]);
    let destination_capacity = BundleLocalDestinationAllocationBytes(0);
    let destination_rows = DerivedTileRows(
        destination_capacity,
        requested_columns as integer {1..65535},
        destination_type);
    let odd_physical_profile =
        !IsNonzeroPowerOfTwo(requested_columns as integer {1..65535}) &&
        TileDataTypeAllowsOddPhysicalColumns(source_operation_type) &&
        TileDataTypeAllowsOddPhysicalColumns(destination_type);
    let destination_physical_shape_legal = if odd_physical_profile then
        TileStorageFitsCapacity(
            _Tiles[[source]].rows,
            requested_columns as integer {1..65535},
            destination_type, destination_capacity)
    else destination_rows == _Tiles[[source]].rows;
    if requested_valid_columns != _Tiles[[source]].valid_columns ||
       requested_valid_rows != _Tiles[[source]].valid_rows ||
       requested_columns != _Tiles[[source]].columns ||
       !destination_physical_shape_legal then
        return FALSE;
    end;

    if CurrentBundleCanonicalize() then
        return FALSE;
    end;
    return source_layout == CurrentBundleTileSourceLayout();
end;
```
<!-- GENERATED-ASL-END: unit -->
