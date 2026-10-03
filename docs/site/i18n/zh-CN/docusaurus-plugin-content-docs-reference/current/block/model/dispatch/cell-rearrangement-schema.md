<!-- GENERATED FROM: asl/block/model/dispatch/cell-rearrangement-schema.asl -->
# Cell Rearrangement Schema

**Normative ASL source:** `asl/block/model/dispatch/cell-rearrangement-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-cell-rearrangement-schema-purpose role=purpose-scope -->
## 用途与范围

本单元负责四个 CUBE 单元重排操作的指令束操作数 schema 与目标分配：`TPERMUTE`、`TSHUF`、`TPACK` 和 `TUNPACK`。这些操作在 Local CUBE Tile 内移动字节或字，不做数值转换。

它定义三个函数：

- `TileOperationUsesCellRearrangementSchema` 识别这四个操作。
- `SelectedBundleCellRearrangementSchemaLegal` 检查收集到的 `B.IOT` 与 `B.IOR` 记录是否恰好具有所选操作要求的形态。
- `ResolveBundleCellRearrangementDestination` 从源 Tile 推导目标描述符，并分配或检查目标寄存器。

<!-- PTO-READER-BLOCK: block-model-dispatch-cell-rearrangement-schema-concepts role=concepts-state -->
## 概念与可见状态

schema 检查读取头部状态，例如 `_BundleTileBindings`（`B.IOT` 记录）、`_BundleScalarBindings`（`B.IOR` 记录）、`_BundleExecutionMask` 以及 Shared 绑定数量。

目标解析器读取 `_Tiles` 中的源描述符，成功时写入三项：

- 通过 `ConfigureCubeTileForMask` 写入一个新的 CUBE Tile 描述符；
- 把解析得到的绝对索引写入目标绑定的 `destination` 字段；
- 把该绑定的 `destination_allocated_by_bundle` 置为真。

对 `TPACK` 和 `TUNPACK`，目标数据类型是指令束操作 `DataType` 选定的 `U8`、`U16`、`U32` 或 `U64`。U64 形式要求 `CUBE_M32`，并把每个完整偶数/奇数 raw-word pair 合成一个逻辑目标元素。对 `TPERMUTE` 与 `TSHUF`，目标保留源类型和有效列数。

<!-- PTO-READER-BLOCK: block-model-dispatch-cell-rearrangement-schema-rules role=rules-interactions -->
## 规则与交互

当 `SelectedBundleTileMaskIsZero` 成立时（例如每个有效 Tile 绑定的 PE 掩码都是 `0000`），schema 检查立即返回真。否则它按以下两种形态之一检查。

- `TPERMUTE` 需要恰好两个 Tile 绑定。第一个携带两个源且没有目标。第二个携带第三个源和新目标，并结束序列。它的源必须与第一个绑定的两个源都不同。只有当 ExecutionMask 由 GPR 携带时才存在 `B.IOR` 记录。
- `TSHUF`、`TPACK` 和 `TUNPACK` 需要一条承载控制字的 `B.IOR` 记录和一个 Tile 绑定；当双源操作额外带有 Tile 载体的 ExecutionMask 时需要两个绑定。`TSHUF` 和 `TPACK` 使用两个源；`TUNPACK` 使用一个。

设计要点：Tile 执行所有者在通用封闭 schema 检查之前调用本 schema 检查，并把其失败映射为 `Fault_BundleControl`。ASL 注释说明了原因：缺失或多余的 `B.IOR` 或 `B.IOT` 控制属于指令束结构。因此格式错误的指令束报告为指令束控制故障，而不是 Tile 合法性故障。

对 `TPACK` 和 `TUNPACK`，较窄目标的列数仍为源每行 word 数乘以 `U8`、`U16`、`U32` 对应的 4、2、1。对 `U64`，raw-word 数必须为偶数，目标逻辑列数为其一半。`TPACK` 还要求第二个源与第一个源具有相同布局、有效行数和每行 word 数。

设计要点：目标形状由源描述符推导，而不是来自 `B.DIM`。宏汇编参考记录了其后果：`TPACK` 和 `TUNPACK` 没有编码的形状，因此其 Row 和 Col 取决于运行时描述符状态。

缺失角色、非法的源描述符或类型，或复用目标不匹配，会引发 `Fault_TileLegality`。目标超过 65535 列、CUBE 形状非法、没有空闲寄存器或容量不足，会引发 `Fault_TileAllocation`。

<!-- PTO-READER-BLOCK: block-model-dispatch-cell-rearrangement-schema-boundaries role=boundaries -->
## 架构边界

本单元不执行任何数据移动。字节与字语义、控制字检查以及源的已定义性属于 Tile 合法性和执行所有者。

当目标绑定被 assemble 生成复用时，解析器不分配任何寄存器。它只检查现有描述符与推导出的容量、形状、类型、布局和 PE 掩码一致。

设计要点：解析器用 `destination_allocated_by_bundle` 标记新分配的目标。`RollBackBundleTileDestinations` 恰好释放这些被标记的寄存器，因此当之后的写者验证或操作本身失败时，Tile 执行所有者会释放新分配的 Tile。

<!-- PTO-READER-BLOCK: block-model-dispatch-cell-rearrangement-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

```text
TPACK <U32>, T#1, T#2, a0, ->T<2KB>
```

假设 `T#1` 和 `T#2` 是 Local `U32` `CUBE_M16` Tile，有 8 个有效行和 8 个有效列。每个源行有 32 个有效字节，即 8 个字。`U32` 每个字放 1 个元素，因此目标是 8 个有效行、8 个有效列的 `U32` `CUBE_M16`。只要该 CUBE 形状可容纳，解析器就在编码的目标 hand 的 16 个寄存器中取第一个空闲寄存器，并以 2048 字节分配它。

<!-- PTO-READER-BLOCK: block-model-dispatch-cell-rearrangement-schema-related role=related-owners-navigation -->
## 相关所有者

- [Tile 执行分派](tile-execution.md) 把本 schema 检查排在通用 schema 和目标解析之前。
- [目标操作路由](destination-operation.md) 把这四个操作交给本解析器。
- [布局重排合法性](../../../tile/model/legality/layout-rearrangement.md) 定义描述符、类型和每行字数辅助函数。
- [回滚](../faults/rollback.md) 释放被标记为由指令束分配的目标。
- [TPACK](../../../tile/layout-and-rearrangement/layout/TPACK.md) 是这四个操作之一的指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/cell-rearrangement-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA","surface":"block","classification":["model","dispatch","cell-rearrangement-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"]}

func ResolveBundleCellRearrangementDestination(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    var destination_binding: BundleTileBindingIndex = 0;
    var destination_seen = FALSE;
    var source: TileIndex = 0;
    var source1: TileIndex = 0;
    var source_seen = FALSE;
    var source1_seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid then
            if !destination_seen &&
               _BundleTileBindings[[binding]].destination_valid then
                destination_binding = binding as BundleTileBindingIndex;
                destination_seen = TRUE;
            end;
            if !source_seen && _BundleTileBindings[[binding]].source0_valid then
                source = BundleTileSourceIndex(
                    binding as BundleTileBindingIndex, FALSE);
                source_seen = TRUE;
            end;
            if !source1_seen && _BundleTileBindings[[binding]].source1_valid then
                source1 = BundleTileSourceIndex(
                    binding as BundleTileBindingIndex, TRUE);
                source1_seen = TRUE;
            end;
        end;
    end;
    let decoded = TileOperationOfIndex(operation);
    let pack_unpack = decoded == TileOperation_TPACK ||
                      decoded == TileOperation_TUNPACK;
    if !destination_seen || !source_seen ||
       !TileCellRearrangementDescriptorLegal(source) ||
       (decoded == TileOperation_TPACK && !source1_seen) ||
       (source1_seen &&
        !TileCellRearrangementDescriptorLegal(source1)) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let binding = _BundleTileBindings[[destination_binding]];
    let source_tile = _Tiles[[source]];
    let source_semantics_legal = !pack_unpack ||
        (source_tile.storage_kind == TileStorage_Numeric &&
         TileCellRearrangementDataTypeLegal(source_tile.data_type));
    if !source_semantics_legal then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if decoded == TileOperation_TPACK then
        let source1_tile = _Tiles[[source1]];
        if source1_tile.storage_kind != TileStorage_Numeric ||
           !TileCellRearrangementDataTypeLegal(source1_tile.data_type) ||
           source1_tile.layout != source_tile.layout ||
           source1_tile.valid_rows != source_tile.valid_rows then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        if TileCellRearrangementWordsPerRow(source1_tile) !=
           TileCellRearrangementWordsPerRow(source_tile) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    end;
    let selected_type_valid = !pack_unpack ||
        (BundleTileOperationSelected() &&
         _BundleOperation.data_type_valid &&
         BundleDataTypeConcrete(_BundleOperation.data_type));
    let selected_type = if pack_unpack && selected_type_valid then
        TileDataTypeFromEncoding(
            CurrentBundleTileOperationDataTypeCode()
                as TileDataTypeEncoding)
    else source_tile.data_type;
    let destination_elements_per_word =
        if selected_type == TileDataType_U8 then 4
        else if selected_type == TileDataType_U16 then 2
        else if selected_type == TileDataType_U32 then 1
        else if selected_type == TileDataType_U64 then 0
        else 0;
    if !selected_type_valid ||
       (pack_unpack && destination_elements_per_word == 0 &&
        selected_type != TileDataType_U64) ||
       (pack_unpack && selected_type == TileDataType_U64 &&
        (source_tile.layout != TileLayout_CUBE_M32 ||
         TileCellRearrangementWordsPerRow(source_tile) MOD 2 != 0)) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let destination_columns_unbounded = if pack_unpack then
        (if selected_type == TileDataType_U64 then
             TileCellRearrangementWordsPerRow(source_tile) DIVRM 2
         else TileCellRearrangementWordsPerRow(source_tile) *
             destination_elements_per_word) as integer {0..262144}
    else source_tile.valid_columns as integer {0..262144};
    let destination_type = if pack_unpack then selected_type
                           else source_tile.data_type;
    if destination_columns_unbounded > 65535 then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let destination_columns = destination_columns_unbounded
        as integer {0..65535};
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        destination_binding);
    if binding.destination_reused_by_generation then
        let destination = _Tiles[[binding.destination]];
        if !TileCubeDescriptorLegal(destination) ||
           destination.capacity_bytes != capacity_bytes ||
           destination.valid_rows != source_tile.valid_rows ||
           destination.valid_columns != destination_columns ||
           destination.data_type != destination_type ||
           destination.layout != source_tile.layout ||
           (_TileAllocationMasks[[binding.destination]] AND binding.pe_mask) !=
               binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    if !TileCubeDescriptorShapeLegal(capacity_bytes,
           source_tile.valid_rows, destination_columns,
           destination_type, source_tile.layout) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let hand = UInt(binding.destination_hand);
    var resolved: TileIndex = 0;
    var found = FALSE;
    for offset = 0 to 15 looplimit 16 do
        let raw_index = hand * 16 + offset;
        if !found && !_Tiles[[raw_index]].allocated then
            resolved = raw_index as TileIndex;
            found = TRUE;
        end;
    end;
    if !found || !LocalTileAllocationFitsExcept(
           resolved, binding.pe_mask, capacity_bytes) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let configured = ConfigureCubeTileForMask(
        resolved, capacity_bytes, source_tile.valid_rows,
        destination_columns, destination_type,
        source_tile.layout, binding.pe_mask);
    if !configured then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    _BundleTileBindings[[destination_binding]].destination = resolved;
    _BundleTileBindings[[destination_binding]].destination_allocated_by_bundle =
        TRUE;
    return TRUE;
end;

pure func TileOperationUsesCellRearrangementSchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TPERMUTE ||
           decoded == TileOperation_TSHUF ||
           decoded == TileOperation_TPACK ||
           decoded == TileOperation_TUNPACK;
end;

readonly func SelectedBundleCellRearrangementSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesCellRearrangementSchema(operation) then return TRUE; end;
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    let decoded = TileOperationOfIndex(operation);
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR;
    if decoded == TileOperation_TPERMUTE then
        if BundleTileBindingCount() != 2 || BundleSharedBindingCount() != 0 ||
           (_BundleScalarBindings[[0]].valid != execution_mask_gpr) ||
           (execution_mask_gpr &&
            !BundleExecutionMaskGPRBindingSchemaLegal(operation)) then
            return FALSE;
        end;
        let first = _BundleTileBindings[[0]];
        let second = _BundleTileBindings[[1]];
        return !first.destination_valid && first.source0_valid &&
               first.source1_valid && !first.last && second.destination_valid &&
               !second.destination_allocated_by_bundle && second.source0_valid &&
               (second.source1_valid == execution_mask_tile) && second.last &&
               (!execution_mask_tile ||
                _BundleExecutionMask.predicate_source_ordinal == 3) &&
               second.source0 != first.source0 &&
               second.source0 != first.source1 &&
               BundleTileDestinationSizeLegal(1);
    end;
    let operation_uses_source1 = decoded == TileOperation_TSHUF ||
        decoded == TileOperation_TPACK;
    let split_final_binding = execution_mask_tile &&
        operation_uses_source1;
    let expected_binding_count = if split_final_binding then 2 else 1;
    if BundleTileBindingCount() != expected_binding_count ||
       BundleSharedBindingCount() != 0 ||
       !_BundleScalarBindings[[0]].valid ||
       (!execution_mask_gpr &&
        (_BundleScalarBindings[[0]].source1 != 0 ||
         _BundleScalarBindings[[0]].source2 != 0)) ||
       (execution_mask_gpr &&
        !BundleExecutionMaskGPRBindingSchemaLegal(operation)) ||
       _BundleScalarBindings[[0]].destination != 0 then
        return FALSE;
    end;
    let binding = _BundleTileBindings[[0]];
    let final_binding = if split_final_binding then
        _BundleTileBindings[[1]] else binding;
    if !final_binding.destination_valid ||
       final_binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(
           if split_final_binding then 1 else 0) ||
       (if split_final_binding then
            binding.destination_valid || !binding.source0_valid ||
            !binding.source1_valid || binding.last ||
            !final_binding.source0_valid || final_binding.source1_valid ||
            !final_binding.last
        else
            !binding.source0_valid ||
            (binding.source1_valid !=
                (operation_uses_source1 || execution_mask_tile)) ||
            !binding.last) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal !=
            (if operation_uses_source1 then 2 else 1)) then
        return FALSE;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
