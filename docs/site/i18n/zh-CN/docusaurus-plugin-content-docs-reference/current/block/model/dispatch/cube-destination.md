<!-- GENERATED FROM: asl/block/model/dispatch/cube-destination.asl -->
# CUBE Destination

**Normative ASL source:** `asl/block/model/dispatch/cube-destination.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-CUBE-DESTINATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-cube-destination-purpose role=purpose-scope -->
## 用途与范围

本单元为 `TMATMUL` 等矩阵乘指令束分配目标组。目标组是一个矩阵指令束中 `B.IOT` 目标的有序集合：先是主结果 D，然后是由 `B.FPATR` 启用的可选 RowMax 和 GroupMax 辅助输出。

它定义了 `ResolveBundleTMATMULDestination` 的三个重载、CUBE 组分配器 `ResolveBundleTMATMULCubeDestinationGroup` 以及容量检查 `BundleTMATMULDestinationCapacityGroupFits`。它当前的调用者是 CUBE 矩阵所有者，该调用者传入的 `cube_primary` 为真。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-destination-concepts role=concepts-state -->
## 概念与可见状态

输出类型是 `BundleFPATREffectiveDataType(pre_quant_mode, accumulator_type)`：`pre_quant_mode` 为零时是累加器类型，否则是量化输出类型。

每个目标的形状取决于它的序号：

| 序号 | 角色 | 有效形状 |
| --- | --- | --- |
| 0 | 主结果 D | `m` 行乘 `n` 列 |
| 1 | 若 `row_max_en` 则为 RowMax，否则若 `group_max_en` 则为 GroupMax | `m` 乘 1，或 `m` 乘 `ceil(n / group_n)` |
| 2 | 两者都启用时的 GroupMax | `m` 乘 `ceil(n / group_n)` |

在 CUBE 路径中，每个目标都使用输出类型和主 CUBE 布局。成功的分配为每个新目标写入 CUBE Tile 描述符，把其绝对索引存入绑定，并设置 `destination_allocated_by_bundle`。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-destination-rules role=rules-interactions -->
## 规则与交互

CUBE 分配器分三遍工作。

1. 预留。对每个新目标，它在编码的 hand 中取第一个既未分配、也未在本遍中被预留的寄存器。hand 已满时引发 `Fault_TileAllocation`。
2. 检查。它累加所有新目标的容量，并对分配掩码中的每个 PE 检查当前用量加上该总和不超过上限。然后检查每个目标的形状。对主结果 D，它还要求 `m` 在 `CUBE_M16` 下至多为 16，在 `CUBE_M32` 下至多为 32。
3. 配置。只有在所有检查都通过之后，它才为每个新目标调用 `ConfigureCubeTileForMask`。

设计要点：在写入第一个描述符之前，整个组都已被检查。第 1 遍只在局部的预留数组中记录选择，第 3 遍只有在所有容量和形状检查都通过之后才运行。因此第二个目标放不下的组不会留下部分分配。

设计要点：第 1 遍中预留的寄存器会在同一遍的后续搜索中被排除。因此两个具有相同 hand 的目标即使都尚未分配，也会得到不同的寄存器。

被 assemble 生成复用的目标不会被分配。它现有的描述符必须是合法的 CUBE 描述符，与容量、有效形状、输出类型和布局一致，且其分配掩码必须包含分配掩码中的每个 PE；不一致时引发 `Fault_TileLegality`。对新目标，非法形状引发 `Fault_TileAllocation`。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-destination-boundaries role=boundaries -->
## 架构边界

CUBE 矩阵所有者在所有字段、命令流、描述符、形状和容量规则都已确定之后、在获取第一个载荷快照之前调用本单元。如果之后写者验证或矩阵操作失败，调用者运行 `RollBackBundleTileDestinations`，释放由本单元标记的目标。

没有目标绑定时，解析器引发 `Fault_BundleControl`。当 `cube_primary` 为假时，解析器检查行主序 D 形状，然后委托给通用的 `ResolveBundleTileDestinationsWithShape`。本单元不计算任何矩阵值。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-destination-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设一个 `TMATMUL` 指令束的 `m` 为 16，`n` 为 64，累加器为 `FP32`，`pre_quant_mode` 为 0，布局为 `CUBE_M16`，`row_max_en` 为假，`group_max_en` 为真，`group_n` 为 16。共有两个目标。

- 序号 0 是 D：`CUBE_M16` 中 16 乘 64 的 `FP32`。
- 序号 1 是 GroupMax：16 乘 `ceil(64 / 16)`，即 16 乘 4，同样是 `CUBE_M16` 中的 `FP32`。

如果两个容量之和超过某个所选 PE 的剩余容量，两者都不会被分配，并引发 `Fault_TileAllocation`。

<!-- PTO-READER-BLOCK: block-model-dispatch-cube-destination-related role=related-owners-navigation -->
## 相关所有者

- [CUBE TMATMUL 分派](cube-tmatmul.md) 验证矩阵指令束并调用本单元。
- [目标辅助函数](destination-auxiliary.md) 定义 `BundleGroupMaxColumns`。
- [目标形状](destination-shape.md) 拥有非 CUBE 路径使用的通用解析器。
- [回滚](../faults/rollback.md) 释放由指令束分配的目标。
- [Tile 分配](../../../tile/model/state/allocation.md) 定义 `ConfigureCubeTileForMask`。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/cube-destination.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-CUBE-DESTINATION","surface":"block","classification":["model","dispatch","cube-destination"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-TILE-MODEL-LEGALITY-MATRIX-CUBE-PRIMARY"]}

readonly func BundleTMATMULDestinationCapacityGroupFits(
    allocation_mask: bits(4)) => boolean
begin
    var additional: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle &&
           !_BundleTileBindings[[binding]].destination_reused_by_generation then
            additional = additional + BundleLocalDestinationAllocationBytes(
                binding as BundleTileBindingIndex);
        end;
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        if allocation_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' &&
           TileCapacityInUseForPE(pe) + additional >
               TileCapacityLimitBytes() then
            return FALSE;
        end;
    end;
    return TRUE;
end;

func ResolveBundleTMATMULCubeDestinationGroup(
    m: integer {1..65535}, n: integer {1..65535},
    accumulator_type: TileDataType,
    output_type: TileDataType,
    primary_layout: TileLayout,
    allocation_mask: bits(4)) => boolean
begin
    assert allocation_mask != Zeros{4};
    var reserved: array [[PTO_TILE_REGISTER_COUNT]] of boolean;
    var resolved: array [[PTO_BUNDLE_TILE_BINDING_COUNT]] of TileIndex;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        reserved[[index]] = FALSE;
    end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        resolved[[binding]] = 0;
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle &&
           !_BundleTileBindings[[binding]].destination_reused_by_generation then
            let capacity_bytes = BundleTileDestinationSizeBytes(
                binding as BundleTileBindingIndex);
            let hand = UInt(
                _BundleTileBindings[[binding]].destination_hand);
            var found = FALSE;
            for offset = 0 to 15 do
                let raw_index: integer = hand * 16 + offset;
                if !found && !_Tiles[[raw_index]].allocated &&
                   !reserved[[raw_index]] then
                    resolved[[binding]] = raw_index as TileIndex;
                    reserved[[raw_index]] = TRUE;
                    found = TRUE;
                end;
            end;
            if !found then
                SetFault(Fault_TileAllocation, ReadTPC());
                return FALSE;
            end;
        end;
    end;
    if !BundleTMATMULDestinationCapacityGroupFits(allocation_mask) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;

    var destination_ordinal: integer {0..3} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            let capacity_bytes = BundleTileDestinationSizeBytes(
                binding as BundleTileBindingIndex);
            let reused =
                _BundleTileBindings[[binding]].destination_reused_by_generation;
            if destination_ordinal == 0 then
                if !TileMatrixMLayoutLegal(primary_layout, m) ||
                   !TileCubeDescriptorShapeLegal(
                       capacity_bytes, m, n,
                       output_type, primary_layout) then
                    if reused then SetFault(Fault_TileLegality, ReadTPC());
                    else SetFault(Fault_TileAllocation, ReadTPC()); end;
                    return FALSE;
                end;
                if reused then
                    let destination =
                        _Tiles[[_BundleTileBindings[[binding]].destination]];
                    if !TileCubeDescriptorLegal(destination) ||
                       destination.capacity_bytes != capacity_bytes ||
                       destination.valid_rows != m ||
                       destination.valid_columns != n ||
                       destination.data_type != output_type ||
                       destination.layout != primary_layout ||
                       (_TileAllocationMasks[[_BundleTileBindings[[binding]]
                            .destination]] AND allocation_mask) !=
                           allocation_mask then
                        SetFault(Fault_TileLegality, ReadTPC());
                        return FALSE;
                    end;
                end;
            else
                let row_auxiliary =
                    _BundleFixedPointAttributes.row_max_en &&
                    destination_ordinal == 1;
                let group_auxiliary =
                    _BundleFixedPointAttributes.group_max_en &&
                    ((!_BundleFixedPointAttributes.row_max_en &&
                      destination_ordinal == 1) ||
                     (_BundleFixedPointAttributes.row_max_en &&
                      destination_ordinal == 2));
                let auxiliary_columns = if row_auxiliary then 1
                    else if group_auxiliary then
                        BundleGroupMaxColumns(n)
                    else n;
                if !TileCubeDescriptorShapeLegal(
                       capacity_bytes, m, auxiliary_columns,
                       output_type, primary_layout) then
                    if reused then SetFault(Fault_TileLegality, ReadTPC());
                    else SetFault(Fault_TileAllocation, ReadTPC()); end;
                    return FALSE;
                end;
                if reused then
                    let destination =
                        _Tiles[[_BundleTileBindings[[binding]].destination]];
                    if !TileCubeDescriptorLegal(destination) ||
                       destination.capacity_bytes != capacity_bytes ||
                       destination.valid_rows != m ||
                       destination.valid_columns != auxiliary_columns ||
                       destination.data_type != output_type ||
                       destination.layout != primary_layout ||
                       (_TileAllocationMasks[[_BundleTileBindings[[binding]]
                            .destination]] AND allocation_mask) !=
                           allocation_mask then
                        SetFault(Fault_TileLegality, ReadTPC());
                        return FALSE;
                    end;
                end;
            end;
            destination_ordinal =
                (destination_ordinal + 1) as integer {0..3};
        end;
    end;

    destination_ordinal = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            if !_BundleTileBindings[[binding]].destination_allocated_by_bundle &&
               !_BundleTileBindings[[binding]].destination_reused_by_generation then
                let capacity_bytes = BundleTileDestinationSizeBytes(
                    binding as BundleTileBindingIndex);
                if destination_ordinal == 0 then
                    let configured = ConfigureCubeTileForMask(
                        resolved[[binding]], capacity_bytes, m, n,
                        output_type, primary_layout, allocation_mask);
                    assert configured;
                else
                    let row_auxiliary =
                        _BundleFixedPointAttributes.row_max_en &&
                        destination_ordinal == 1;
                    let group_auxiliary =
                        _BundleFixedPointAttributes.group_max_en &&
                        ((!_BundleFixedPointAttributes.row_max_en &&
                          destination_ordinal == 1) ||
                         (_BundleFixedPointAttributes.row_max_en &&
                          destination_ordinal == 2));
                    let auxiliary_columns = if row_auxiliary then 1
                        else if group_auxiliary then
                            BundleGroupMaxColumns(n)
                        else n;
                    let configured = ConfigureCubeTileForMask(
                        resolved[[binding]], capacity_bytes, m,
                        auxiliary_columns, output_type, primary_layout,
                        allocation_mask);
                    assert configured;
                end;
                _BundleTileBindings[[binding]].destination =
                    resolved[[binding]];
                _BundleTileBindings[[binding]].destination_allocated_by_bundle =
                    TRUE;
            end;
            destination_ordinal =
                (destination_ordinal + 1) as integer {0..3};
        end;
    end;
    return TRUE;
end;

func ResolveBundleTMATMULDestination(
    m: integer {1..65535}, n: integer {1..65535},
    accumulator_type: TileDataType,
    cube_primary: boolean,
    primary_layout: TileLayout,
    allocation_mask: bits(4)) => boolean
begin
    var destination_binding: BundleTileBindingIndex = 0;
    var destination_seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if !destination_seen &&
           _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            destination_binding = binding as BundleTileBindingIndex;
            destination_seen = TRUE;
        end;
    end;
    if !destination_seen then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    let output_type = BundleFPATREffectiveDataType(
        _BundleFixedPointAttributes.pre_quant_mode, accumulator_type);
    let capacity_bytes = BundleTileDestinationSizeBytes(destination_binding);
    if cube_primary then
        return ResolveBundleTMATMULCubeDestinationGroup(
            m, n, accumulator_type, output_type, primary_layout,
            allocation_mask);
    else
        let rows = DerivedTileRows(capacity_bytes, n, output_type);
        if !TileDescriptorShapeLegal(
               capacity_bytes, n, m, n, output_type) ||
           !IsNonzeroPowerOfTwo(rows) ||
           rows * n > PTO_MODEL_TILE_ELEMENTS then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
    end;
    // Reserve the complete D/RowMax/GroupMax destination group first.  Only
    // the primary D descriptor is then converted to persistent CUBE state;
    // auxiliary outputs remain ordinary Local Tiles.
    if !ResolveBundleTileDestinationsWithShape(TRUE, m, n, n) then
        return FALSE;
    end;
    return TRUE;
end;

func ResolveBundleTMATMULDestination(
    m: integer {1..65535}, n: integer {1..65535},
    accumulator_type: TileDataType,
    cube_primary: boolean,
    primary_layout: TileLayout) => boolean
begin
    var allocation_mask = Zeros{4};
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if allocation_mask == Zeros{4} &&
           _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            allocation_mask = _BundleTileBindings[[binding]].pe_mask;
        end;
    end;
    return ResolveBundleTMATMULDestination(
        m, n, accumulator_type, cube_primary, primary_layout,
        allocation_mask);
end;

func ResolveBundleTMATMULDestination(
    m: integer {1..65535}, n: integer {1..65535},
    accumulator_type: TileDataType) => boolean
begin
    var allocation_mask = Zeros{4};
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if allocation_mask == Zeros{4} &&
           _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            allocation_mask = _BundleTileBindings[[binding]].pe_mask;
        end;
    end;
    return ResolveBundleTMATMULDestination(
        m, n, accumulator_type, FALSE, TileLayout_RowMajor,
        allocation_mask);
end;
```
<!-- GENERATED-ASL-END: unit -->
