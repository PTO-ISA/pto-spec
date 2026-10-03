<!-- GENERATED FROM: asl/block/model/dispatch/lea-schema.asl -->
# Lea Schema

**Normative ASL source:** `asl/block/model/dispatch/lea-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-LEA-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-lea-schema-purpose role=purpose-scope -->
## 目的与范围

本单元定义 `TLEA` 的封闭 bundle schema。`SelectedBundleClosedLEASchemaLegal` 只识别 `TileOperation_TLEA`，并在选择执行前校验源绑定、目标请求、必需的元素宽度 GPR 绑定、维度、源类型、源描述符、布局与源内容。

它是 dispatch 预检 owner，不计算字节偏移，也不发布目标。

<!-- PTO-READER-BLOCK: block-model-dispatch-lea-schema-concepts role=concepts-state -->
## 概念与可见状态

该函数读取所选操作、Tile 与 Shared 绑定表、标量绑定、bundle 维度、所选源 `DataType`、所选布局、ExecutionMask 载体以及已经绑定的源描述符，不写任何架构状态。

唯一一条 `B.IOT` 携带 `source0` 与目标请求，并且必须终止 Tile 绑定。`B.IOR.RegSrc0` 必须存在并提供逐 PE 的 `element_bits` 值。谓词 Tile 掩码占用 `source1`；GPR 掩码使用既有标量绑定扩展。

<!-- PTO-READER-BLOCK: block-model-dispatch-lea-schema-rules role=rules-interactions -->
## 规则与交互

对于 `TLEA`，该函数要求一条 Tile 绑定、零条 Shared 绑定、合法维度、一条有效标量绑定、有效 `source0`，以及尚未由 bundle 分配的目标。绑定必须为最后一条，且请求的目标大小必须合法。

没有 GPR ExecutionMask 时，未使用的标量选择器与标量目标保持为零。存在 GPR ExecutionMask 时，额外绑定形状由 `BundleExecutionMaskGPRBindingSchemaLegal` 管理。谓词 Tile 掩码必须作为源序号 1 出现。

`BSTART` 源类型必须恰为 `S32`、`U32`、`S64` 或 `U64`，并且必须等于源后备类型。源必须是 `RowMajor` 或 `CUBE_M32` 下合法的 Local 数值描述符，具有 bundle 的精确逻辑维度，并在执行将读取的每个坐标上已定义。由于 TLEA 目标始终为 64 位，`CUBE_M16` 会拒绝。最后，所选标量值必须恰为 8、16、32 或 64。

<!-- PTO-READER-BLOCK: block-model-dispatch-lea-schema-boundaries role=boundaries -->
## 架构边界

本单元检查输入 bundle 形状与面向源的契约。目标分配及独立目标几何由目标解析和 Tile 分配负责；handler 运行前，`TileOperandsLegal_TLEA` 会再次检查所得源目标对。

schema 不提供默认宽度：省略 `B.IOR`、选择零寄存器，或提供 8、16、32、64 之外的值，都会使活动 `TLEA` bundle 非法。`PE_MASK=0000` 由更早的严格无操作边界处理，因此不会发生这里的读取或故障。

<!-- PTO-READER-BLOCK: block-model-dispatch-lea-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL owner，不替代规范规则。

一个逻辑形状为 1 x 3 的 `S32` 源使用 `LB0=3`、省略 `LB1`、一条终止 `B.IOT`，并让 `B.IOR.RegSrc0` 选择值为 32 的 GPR。只有确认源后备类型同为 `S32`、其描述符使用所选布局，且将读取的三个逻辑源元素都已定义后，schema 才接受该标量为四字节元素宽度。

<!-- PTO-READER-BLOCK: block-model-dispatch-lea-schema-related role=related-owners-navigation -->
## 相关 owner

- [TLEA 操作数合法性](../../../tile/model/legality/lea-operands.md)检查已分配的源目标对。
- [TLEA 执行](../../../tile/model/execution/lea.md)负责扩展与字节缩放。
- [目标操作](destination-operation.md)推导新的 `S64` 或 `U64` 目标。
- [TLEA](../../../tile/tile-scalar-and-immediate/arithmetic/TLEA.md) 是指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/lea-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-LEA-SCHEMA","surface":"block","classification":["model","dispatch","lea-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","PTO-TILE-MODEL-LEGALITY-LEA-OPERANDS"]}
readonly func SelectedBundleClosedLEASchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if TileOperationOfIndex(operation) != TileOperation_TLEA then
        return TRUE;
    end;
    if BundleTileBindingCount() != 1 || BundleSharedBindingCount() != 0 ||
       !SelectedBundleComparisonDimensionsLegal() ||
       !_BundleScalarBindings[[0]].valid then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.source0_valid ||
       (binding.source1_valid != mask_tile) ||
       (mask_tile && _BundleExecutionMask.predicate_source_ordinal != 1) ||
       !binding.destination_valid || binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) || !binding.last then
        return FALSE;
    end;
    let mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    if mask_gpr then
        if !BundleExecutionMaskGPRBindingSchemaLegal(operation) then
            return FALSE;
        end;
    else
        if _BundleScalarBindings[[1]].valid ||
           _BundleScalarBindings[[0]].source1 != 0 ||
           _BundleScalarBindings[[0]].source2 != 0 ||
           _BundleScalarBindings[[0]].destination != 0 then
            return FALSE;
        end;
    end;
    let source = BundleTileSourceIndex(0, FALSE);
    let source_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !TileLEAIndexDataTypeLegal(source_type) ||
       _Tiles[[source]].data_type != source_type ||
       !TileElementwiseDescriptorLegal(source) ||
       _Tiles[[source]].storage_kind != TileStorage_Numeric ||
       _Tiles[[source]].layout != CurrentBundleTileLayout() ||
       (_Tiles[[source]].layout != TileLayout_RowMajor &&
        _Tiles[[source]].layout != TileLayout_CUBE_M32) ||
       !SelectedBundleComparisonSourceContentsDefined(source) ||
       _Tiles[[source]].valid_rows != UInt(_BundleDimensions[[1]]) ||
       _Tiles[[source]].valid_columns != UInt(_BundleDimensions[[0]]) then
        return FALSE;
    end;
    return TileLEAElementBitsLegal(SelectedBundleTileScalarRawValue());
end;
```
<!-- GENERATED-ASL-END: unit -->
