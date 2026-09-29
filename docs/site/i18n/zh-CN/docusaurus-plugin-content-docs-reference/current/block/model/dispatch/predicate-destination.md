<!-- GENERATED FROM: asl/block/model/dispatch/predicate-destination.asl -->
# Predicate Destination

**Normative ASL source:** `asl/block/model/dispatch/predicate-destination.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-PREDICATE-DESTINATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-predicate-destination-purpose role=purpose-scope -->
## 用途与范围

本单元为比较操作和 CUBE 选择操作解析目标 Tile。它找到目标绑定，校验或分配 Tile，并把选定的寄存器记录在绑定中。

它定义了以下函数：

- `BundleFirstDestinationBinding` 返回带有目标的最低编号有效绑定。
- `BundleFreeDestinationIndex` 返回目标 hand 中第一个未分配的寄存器。hand 是 Local 寄存器的四个 16 寄存器分组之一：T 为 0 到 15，U 为 16 到 31，M 为 32 到 47，N 为 48 到 63。
- `ResolveBundlePredicateDestination` 解析 `TCMP` 和 `TCMPS` 的谓词结果。
- `BundleComparisonSelectTrueSource` 选出为 `TSEL` 或 `TSELS` 提供“真”值的 Tile。
- `ResolveBundleCUBESelectDestination` 解析 CUBE `TSEL` 或 `TSELS` 的数值结果。

<!-- PTO-READER-BLOCK: block-model-dispatch-predicate-destination-concepts role=concepts-state -->
## 概念与可见状态

比较操作写入两种谓词载体之一，由第一个源的布局决定：

- `RowMajor` 源产生一个打包谓词 Tile，其存储类型为 `TileStorage_Predicate`，每个元素一位，占用 `(rows * columns + 7) DIVRM 8` 字节。
- `CUBE_M16` 或 `CUBE_M32` 源产生一个 PredicateCell：一个存储类型为 `TileStorage_PredicateCell` 的 `U8` CUBE Tile，其 `predicate_basis_type` 记录比较类型。

本单元读取 `_BundleTileBindings`、`_Tiles` 中的源描述符、`_TileAllocationMasks` 以及 Local 容量。分配新 Tile 时，它写入所分配 Tile 的描述符，把绑定的 `destination` 设为选定的寄存器，并设置 `destination_allocated_by_bundle`；只校验已有目标时，它不写入任何内容。

<!-- PTO-READER-BLOCK: block-model-dispatch-predicate-destination-rules role=rules-interactions -->
## 规则与交互

`ResolveBundlePredicateDestination` 从绑定 0 的源 0 取得形状和布局，而不是从目标绑定取得。ASL 注释给出了原因：后面的绑定可能同时携带新目标和 PredicateCell ExecutionMask，因此它不负责源类型。

如果目标已为本指令束解析（由指令束分配，或通过 Local 代际复用），本单元只做校验。PredicateCell 必须是合法的 PredicateCell，其基础类型等于比较类型，其有效形状和布局与源相同。打包谓词 Tile 必须是谓词存储，具有相同的物理形状和有效形状，并且为 `RowMajor`。其分配掩码必须等于绑定的 `PE_MASK`。失败时引发 `Fault_TileLegality`。

否则它分配一个新 Tile：

- 对于 CUBE 源，比较类型必须是受支持的 CUBE 谓词类型并与源宽度兼容，且 `U8` CUBE 形状必须能放入目标大小。
- 对于 `RowMajor` 源，源必须是数值存储，其物理形状必须能放入自身容量，且谓词存储字节数必须能放入目标大小。
- 绑定掩码中每个 PE 上的 Local 容量都必须足够，且该 hand 中必须有空闲寄存器。

上述任一失败都会引发 `Fault_TileAllocation`。

`ResolveBundleCUBESelectDestination` 对数值 CUBE 结果采用相同模式。真值源必须持有合法的 CUBE 描述符。结果具有有效操作类型、源的有效形状以及源的布局。

设计要点：所有检查都在 `ConfigurePredicateTileForMask`、`ConfigurePredicateCellForMask` 或 `ConfigureCubeTileForMask` 修改描述符之前运行。调用方在封闭 schema 通过之后才运行此解析。如果后续步骤失败，`RollBackBundleTileDestinations` 会释放所有标记为 `destination_allocated_by_bundle` 且不是通过代际复用的 Tile。

<!-- PTO-READER-BLOCK: block-model-dispatch-predicate-destination-boundaries role=boundaries -->
## 架构边界

本单元不计算比较或选择结果。它通过[目标操作](destination-operation.md)中的 `ResolveBundleTileDestinationsForOperation` 进入：对 `TCMP` 和 `TCMPS`，在有效数据类型解析成功之后进入；对 `TSEL` 和 `TSELS`，仅当真值源为 CUBE 时进入。缺少目标绑定会引发 `Fault_BundleControl`。写入 GPR 载体的比较操作不会进入本单元。

<!-- PTO-READER-BLOCK: block-model-dispatch-predicate-destination-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

考虑 `TCMP <Row=8, Col=64, FP32, LT>, T#1, T#2, ->U<512B>`。左源 `T#1` 是一个 8 行 64 列的 `RowMajor` `FP32` Tile。谓词需要 (8 * 64 + 7) DIVRM 8 = 64 字节，可以放入 512 字节。如果寄存器 16 和 17 已分配而 18 空闲，`BundleFreeDestinationIndex` 返回 18。新的打包谓词 Tile 有 8 行 64 列，绑定把寄存器 18 记录为其目标。

<!-- PTO-READER-BLOCK: block-model-dispatch-predicate-destination-related role=related-owners-navigation -->
## 相关所有者

- [目标操作](destination-operation.md)把比较操作和 CUBE 选择操作路由到本单元。
- [比较 schema](comparison-schema.md)在解析之前校验比较指令束。
- [Tile 分配](../../../tile/model/state/allocation.md)定义配置函数和谓词存储大小。
- [谓词载体合法性](../../../tile/model/legality/predicate-carriers.md)定义 PredicateCell 的合法性。
- [TCMP](../../../tile/elementwise-tile-tile/logical/TCMP.md) 是使用本单元的一个指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/predicate-destination.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-PREDICATE-DESTINATION","surface":"block","classification":["model","dispatch","predicate-destination"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","PTO-TILE-MODEL-STATE-ALLOCATION"]}

readonly func BundleFirstDestinationBinding()
    => (boolean, BundleTileBindingIndex)
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            return (TRUE, binding as BundleTileBindingIndex);
        end;
    end;
    return (FALSE, 0);
end;

readonly func BundleFreeDestinationIndex(
    binding: BundleTileBindingIndex) => (boolean, TileIndex)
begin
    let hand = UInt(_BundleTileBindings[[binding]].destination_hand);
    for offset = 0 to 15 do
        let raw_index: integer = hand * 16 + offset;
        if !_Tiles[[raw_index]].allocated then
            return (TRUE, raw_index as TileIndex);
        end;
    end;
    return (FALSE, 0);
end;

func ResolveBundlePredicateDestination(operation_type: TileDataType) => boolean
begin
    let (destination_seen, destination_binding) =
        BundleFirstDestinationBinding();
    if !destination_seen then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    let binding = _BundleTileBindings[[destination_binding]];
    // Comparison input binding 0 owns the numeric shape and basis.  A later
    // binding may carry both the fresh destination and a PredicateCell
    // ExecutionMask, so the destination binding is not a source-type owner.
    let source = BundleTileSourceIndex(0, FALSE);
    let source_tile = _Tiles[[source]];
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        destination_binding);
    let cube = source_tile.layout == TileLayout_CUBE_M16 ||
        source_tile.layout == TileLayout_CUBE_M32;
    if binding.destination_allocated_by_bundle ||
       binding.destination_reused_by_generation then
        let destination = binding.destination;
        let destination_tile = _Tiles[[destination]];
        let descriptor_legal = if cube then
            TilePredicateCellDescriptorLegal(destination) &&
            destination_tile.predicate_basis_type == operation_type &&
            destination_tile.valid_rows == source_tile.valid_rows &&
            destination_tile.valid_columns == source_tile.valid_columns &&
            destination_tile.layout == source_tile.layout
        else
            TileDescriptorLegal(destination) &&
            destination_tile.storage_kind == TileStorage_Predicate &&
            destination_tile.rows == source_tile.rows &&
            destination_tile.columns == source_tile.columns &&
            destination_tile.valid_rows == source_tile.valid_rows &&
            destination_tile.valid_columns == source_tile.valid_columns &&
            destination_tile.layout == TileLayout_RowMajor;
        if !descriptor_legal ||
           _TileAllocationMasks[[destination]] != binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    if cube then
        if !TileCubePredicateDataTypeSupported(operation_type) ||
           !TileCarrierWidthCompatible(
               source_tile.data_type, operation_type) ||
           !TileCubeDescriptorShapeLegal(
               capacity_bytes, source_tile.valid_rows,
               source_tile.valid_columns, TileDataType_U8,
               source_tile.layout) then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
    elsif source_tile.storage_kind != TileStorage_Numeric ||
          source_tile.rows * source_tile.columns >
              TileLogicalElementCapacity(
                  source_tile.capacity_bytes, source_tile.data_type) ||
          PredicateTileStorageBytes(
              source_tile.rows, source_tile.columns) > capacity_bytes then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    if !LocalTileAllocationFits(binding.pe_mask, capacity_bytes) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let (found, resolved) = BundleFreeDestinationIndex(destination_binding);
    if !found then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    if cube then
        if !ConfigurePredicateCellForMask(
               resolved, capacity_bytes, source_tile.valid_rows,
               source_tile.valid_columns, operation_type,
               source_tile.layout, binding.pe_mask) then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
    else
        ConfigurePredicateTileForMask(
            resolved, capacity_bytes, source_tile.rows, source_tile.columns,
            source_tile.valid_rows, source_tile.valid_columns,
            binding.pe_mask);
    end;
    _BundleTileBindings[[destination_binding]].destination = resolved;
    _BundleTileBindings[[destination_binding]].destination_allocated_by_bundle =
        TRUE;
    return TRUE;
end;

readonly func BundleComparisonSelectTrueSource(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => TileIndex
begin
    let decoded = TileOperationOfIndex(operation);
    let first = BundleTileSourceIndex(0, FALSE);
    let cell_select = _BundleTileBindings[[0]].source0_valid &&
        _Tiles[[first]].storage_kind == TileStorage_PredicateCell;
    if (decoded == TileOperation_TSEL || decoded == TileOperation_TSELS) &&
       cell_select then
        return BundleTileSourceIndex(0, TRUE);
    end;
    return first;
end;

func ResolveBundleCUBESelectDestination(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let (destination_seen, destination_binding) =
        BundleFirstDestinationBinding();
    if !destination_seen then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    let source = BundleComparisonSelectTrueSource(operation);
    let source_tile = _Tiles[[source]];
    let binding = _BundleTileBindings[[destination_binding]];
    let capacity_bytes = BundleLocalDestinationAllocationBytes(
        destination_binding);
    let (operation_type_valid, operation_type) =
        ResolveBundleEffectiveDataType();
    if !operation_type_valid then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !TileCubeDescriptorLegal(source_tile) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    if binding.destination_allocated_by_bundle ||
       binding.destination_reused_by_generation then
        let destination_tile = _Tiles[[binding.destination]];
        if !TileCubeDescriptorLegal(destination_tile) ||
           destination_tile.storage_kind != TileStorage_Numeric ||
           destination_tile.valid_rows != source_tile.valid_rows ||
           destination_tile.valid_columns != source_tile.valid_columns ||
           destination_tile.data_type != operation_type ||
           destination_tile.layout != source_tile.layout ||
           _TileAllocationMasks[[binding.destination]] != binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    if !TileCubeDescriptorShapeLegal(
           capacity_bytes, source_tile.valid_rows,
           source_tile.valid_columns, operation_type,
           source_tile.layout) ||
       !LocalTileAllocationFits(binding.pe_mask, capacity_bytes) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let (found, resolved) = BundleFreeDestinationIndex(destination_binding);
    if !found || !ConfigureCubeTileForMask(
           resolved, capacity_bytes, source_tile.valid_rows,
           source_tile.valid_columns, operation_type,
           source_tile.layout,
           binding.pe_mask) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    _BundleTileBindings[[destination_binding]].destination = resolved;
    _BundleTileBindings[[destination_binding]].destination_allocated_by_bundle =
        TRUE;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
