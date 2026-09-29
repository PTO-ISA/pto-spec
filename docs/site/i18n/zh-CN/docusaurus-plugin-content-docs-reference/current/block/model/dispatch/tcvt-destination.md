<!-- GENERATED FROM: asl/block/model/dispatch/tcvt-destination.asl -->
# Tcvt Destination

**Normative ASL source:** `asl/block/model/dispatch/tcvt-destination.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-destination-purpose role=purpose-scope -->
## 用途与范围

本单元为源使用 `CUBE_M16` 或 `CUBE_M32` 布局的 `TCVT` 分配目标 Tile。CUBE 布局以固定大小的单元而非普通行存储 Tile，因此目标几何取决于目标数据类型，而不只取决于源。

当操作为 `TCVT` 且源布局是这两种 CUBE 布局之一时，目标操作所有者调用 `ResolveBundleTCVTCubeDestination`。其他 `TCVT` 源使用通用目标路径。

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-destination-concepts role=concepts-state -->
## 概念与可见状态

- 目标类型来自 `ResolveBundleEffectiveDataType`。
- 目标布局就是源布局。
- 有效区域为维度 0（有效列）乘维度 1（有效行）。
- 容量是绑定 0 的 `BundleLocalDestinationAllocationBytes`，即其尺寸码对应的字节数。
- 目标 hand 是绑定中的 2 位字段。它选择一组 16 个 Tile 索引，即 `hand * 16` 到 `hand * 16 + 15`。

成功时，本单元通过 `ConfigureCubeTileForMask` 写入所选 Tile 的描述符，并设置绑定 0 的 `destination` 与 `destination_allocated_by_bundle`。

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-destination-rules role=rules-interactions -->
## 规则与交互

本单元先检查目标类型能够解析且源布局为 `CUBE_M16` 或 `CUBE_M32`，否则引发 `Fault_TileAllocation`，然后走两条路径之一。

当绑定复用已有的代际目标（`destination_reused_by_generation`）时，不进行分配。已有 Tile 必须是合法的 CUBE 描述符，其容量、有效行、有效列、目标类型和布局都相同，并且必须已在绑定 PE 掩码中的每个 PE 上分配。不匹配时引发 `Fault_TileLegality`。

否则本单元进行分配，每项失败都引发 `Fault_TileAllocation`：

1. 上述类型与布局检查已通过。
2. `TileCubeDescriptorShapeLegal` 必须接受该容量、有效区域、目标类型和布局。
3. `BundleTCVTCubeDestinationCapacityGroupFits` 必须确认：对掩码选中的每个 PE，已用容量加上新容量不超过 `TileCapacityLimitBytes`。
4. 选择 hand 所在 16 个索引组中第一个未分配的索引。若没有空闲索引，分配失败。
5. `ConfigureCubeTileForMask` 必须成功。

设计要点：ASL 注释指出，CUBE 的物理行数、列数和单元数由目标数据类型推导。因此较宽的目标类型可能需要比源更大的 2 的幂尺寸码。形状检查使用目标类型和请求的容量，而不是源容量。

设计要点：容量检查按 PE 进行，并且只计入绑定掩码中的 PE。掩码之外的 PE 不获得分配，因此其空闲容量不限制该转换。

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-destination-boundaries role=boundaries -->
## 架构边界

本单元在 TCVT schema 通过之后运行，不重复 schema 检查。它不转换数值，也不发布或回滚目标。如果后续步骤失败，Tile 执行所有者会回滚由指令束分配的目标；成功时则发布它们。非 CUBE 的 `TCVT` 目标不在此处理。

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-destination-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

某个 `TCVT` 把 `CUBE_M16` 的 FP16 源转换为 FP32，使用完整掩码 `1111`，目标 hand 为 2。本单元在请求的尺寸码下检查 FP32 形状，然后检查全部四个 PE 上的容量。接着它扫描 Tile 索引 32 到 47，取第一个未分配的索引，例如 34。Tile 34 在全部四个 PE 上成为 `CUBE_M16` FP32 描述符，绑定 0 把 34 记录为其目标。

<!-- PTO-READER-BLOCK: block-model-dispatch-tcvt-destination-related role=related-owners-navigation -->
## 相关所有者

- [TCVT schema](tcvt-schema.md) 在本单元运行之前校验指令束。
- [Destination operation](destination-operation.md) 把 CUBE `TCVT` 目标路由到这里。
- [Rollback](../faults/rollback.md) 在后续失败后释放由指令束分配的目标。
- [Tile allocation](../../../tile/model/state/allocation.md) 定义 `ConfigureCubeTileForMask`。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tcvt-destination.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION","surface":"block","classification":["model","dispatch","tcvt-destination"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION","PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","PTO-TILE-MODEL-STATE-ALLOCATION"]}
readonly func BundleTCVTCubeDestinationCapacityGroupFits() => boolean
begin
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        0 as BundleTileBindingIndex);
    let mask = _BundleTileBindings[[0]].pe_mask;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        if mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' &&
           TileCapacityInUseForPE(pe) + capacity_bytes >
               TileCapacityLimitBytes() then
            return FALSE;
        end;
    end;
    return TRUE;
end;

func ResolveBundleTCVTCubeDestination() => boolean
begin
    let binding = _BundleTileBindings[[0]];
    let source = BundleTileSourceIndex(0, FALSE);
    let source_layout = _Tiles[[source]].layout;
    let (destination_type_valid, destination_type) =
        ResolveBundleEffectiveDataType();
    if !destination_type_valid ||
       (source_layout != TileLayout_CUBE_M16 &&
        source_layout != TileLayout_CUBE_M32) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;

    let valid_columns = UInt(_BundleDimensions[[0]])
        as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let capacity_bytes = BundleLocalDestinationAllocationBytes(0);
    if binding.destination_reused_by_generation then
        let destination = _Tiles[[binding.destination]];
        if !TileCubeDescriptorLegal(destination) ||
           destination.capacity_bytes != capacity_bytes ||
           destination.valid_rows != valid_rows ||
           destination.valid_columns != valid_columns ||
           destination.data_type != destination_type ||
           destination.layout != source_layout ||
           (_TileAllocationMasks[[binding.destination]] AND binding.pe_mask) !=
               binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    // CUBE physical rows/columns and CELL count are derived from the
    // destination DataType.  In particular, a narrower source and wider
    // destination can require a different minimum power-of-two TSize.
    if !TileCubeDescriptorShapeLegal(
           capacity_bytes, valid_rows, valid_columns,
           destination_type, source_layout) ||
       !BundleTCVTCubeDestinationCapacityGroupFits() then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;

    let hand = UInt(binding.destination_hand);
    var resolved: TileIndex = 0;
    var found = FALSE;
    for offset = 0 to 15 do
        let raw_index: integer = hand * 16 + offset;
        if !found && !_Tiles[[raw_index]].allocated then
            resolved = raw_index as TileIndex;
            found = TRUE;
        end;
    end;
    if !found then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;

    if !ConfigureCubeTileForMask(
           resolved, capacity_bytes, valid_rows, valid_columns,
           destination_type, source_layout,
           binding.pe_mask) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    _BundleTileBindings[[0]].destination = resolved;
    _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
