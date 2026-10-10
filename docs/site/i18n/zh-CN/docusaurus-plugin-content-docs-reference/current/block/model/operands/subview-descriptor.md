<!-- GENERATED FROM: asl/block/model/operands/subview-descriptor.asl -->
# Subview Descriptor

**Normative ASL source:** `asl/block/model/operands/subview-descriptor.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-subview-descriptor-purpose role=purpose-scope -->
## 用途与范围

本单元把一个已记录的 Local `B.SUBVIEW` 修饰符转换为可用的源。subview 从一个 CUBE 布局的父 Tile 中选择一段连续的 CELL。CELL 是 CUBE 布局中 128 字节的存储单元。本单元推导视图的描述符，把所选范围复制到一个临时 Tile 中，并在操作之后释放该 Tile。

它还拥有 `PrepareSelectedBundleStage2`，即在操作 schema 运行之前解析源并检查代次的准备步骤。

<!-- PTO-READER-BLOCK: block-model-operands-subview-descriptor-concepts role=concepts-state -->
## 概念与可见状态

`BundleSubviewDescriptor` 保存 `valid`、`parent`、`offset_cells`、`origin_row`、`origin_column`、`rows`、`columns`、`valid_rows`、`valid_columns`、`cell_count` 和 `capacity_bytes`。`EmptyBundleSubviewDescriptor` 返回一个 `valid` 为 FALSE 的描述符。

描述符保存在修饰符的 `derived` 字段中。临时副本由 `materialized` 和 `materialized_index` 记录。

<!-- PTO-READER-BLOCK: block-model-operands-subview-descriptor-rules role=rules-interactions -->
## 规则与交互

`PrepareSelectedBundleStage2` 按顺序执行以下步骤：解析相对源、解码操作、准备 subview 描述符、验证 Local 代次结构、验证 Shared 代次。

`PrepareBundleSubviewDescriptors` 首先调用 `PrepareBundleConsumerDependencies`。ASL 注释给出了原因：必须等待未完成代次的使用者是一种不产生故障、不产生效果的结果，并且它绝不能把未就绪的单元复制到临时视图中。

在以下情况下，`BundleCubeSubviewDescriptorOf(parent, offset, size)` 返回空描述符：

- 父 Tile 未分配、不是 CUBE，或有效区域或单元数为零；
- 偏移大于 65535，或不小于父 Tile 的 CELL 数；
- 视图原点位于父 Tile 有效区域之外、推导出的形状为空，或推导出的 CUBE 几何不可用（CELL 行数或列数为零、`CUBE_N8` 的 K 重复数为 0 或大于 16384，或推导出的 CELL 数超过视图允许的数量）。

否则视图覆盖 `min(requested, remaining)` 个 CELL。对 `CUBE_N8`，视图在当前 N 列单元末尾停止。对 M32 64 位父 Tile，偏移与数量都必须覆盖完整低/高 CELL pair，原点列为 `offset_cells / 2`；视图不能暴露半个逻辑列。其他 M 布局每个列组使用一个 CELL 组。有效区域裁剪到父 Tile 内。

空描述符引发 `Fault_TileLegality`。随后 `MaterializeBundleSubview` 在父 Tile 的 hand 中找到一个空闲寄存器，以父 Tile 的布局、数据类型和 PE 掩码分配一个 CUBE Tile，并复制视图内每个已定义的父元素。如果 `TileElementwiseSourceContentsDefined` 对父 Tile 成立，视图的有效区域被标记为已定义。绑定的源被重定向到该副本。

设计要点：副本保持父 Tile 的物理布局。ASL 注释说明，任何使用者引擎或操作数角色都不能请求隐式转换。因此 subview 是同一对象的一个范围，而不是重新布局。

设计要点：未定义的父元素在副本中仍然未定义。视图不能使父 Tile 未定义的值变得可读。

<!-- PTO-READER-BLOCK: block-model-operands-subview-descriptor-boundaries role=boundaries -->
## 架构边界

`DiscardBundleSubviewMaterializations` 释放每个临时副本，并把绑定重新指向父 Tile。Tile 执行在成功和失败路径上都会调用它。`BundleTileArchitecturalSourceIndex` 报告父 Tile，而不是副本。父 Tile 的生命周期和载荷不变。

`BundleSubviewOperationApplicabilityIsTotal` 接受每个解码的操作。所选操作保留对数据类型、布局、形状和已定义性合法性的所有权。Shared subview 由 Shared 代次单元拥有。

<!-- PTO-READER-BLOCK: block-model-operands-subview-descriptor-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个 `CUBE_M16` FP16 父 Tile 的有效形状为 16 乘 32。每个 CELL 为 16 行乘 4 列，因此父 Tile 有 8 个 CELL。偏移为 2、大小码为 2（256 字节）的 `B.SUBVIEW` 请求 2 个 CELL；剩余 6 个，因此视图有 2 个 CELL。其原点列为 2 x 4 = 8，有效形状为 16 乘 8，覆盖父 Tile 的第 8 到 15 列。偏移为 8 时等于 CELL 数，会引发故障。

<!-- PTO-READER-BLOCK: block-model-operands-subview-descriptor-related role=related-owners-navigation -->
## 相关所有者

- [范围修饰符](range-modifiers.md)记录 subview。
- [CUBE 单元几何](../../../tile/model/shape/cube-cell.md)拥有 CELL 的行、列和计数。
- [可移植载体](portable-carriers.md)拥有使用者就绪性。
- [B.SUBVIEW](../../operands/B.SUBVIEW.md) 是命令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/subview-descriptor.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","surface":"block","classification":["model","operands","subview-descriptor"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS","PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-TILE-MODEL-SHAPE-CUBE-CELL","PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL"]}

// NDF-BEGIN: PTO-B-SUBVIEW-DESCRIPTOR-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A legal Local CUBE B.SUBVIEW MUST derive a bounded descriptor from the
// parent descriptor, XLEN offset, and encoded view capacity in CELL order.
// Parent lifetime and payload remain unchanged; non-CUBE, zero-valid, and
// out-of-range geometry is rejected with Fault_TileLegality before effects.
// NDF-END: PTO-B-SUBVIEW-DESCRIPTOR-001

// NDF-BEGIN: PTO-BLOCK-TILE-OPERATION-APPLICABILITY-001
// ndf: kind=contract level=L1 layer=block status=accepted
// B.SUBVIEW applicability is total over accepted Tile operations; the
// selected operation handler retains ownership of dtype, layout, shape, and
// definedness legality.
// NDF-END: PTO-BLOCK-TILE-OPERATION-APPLICABILITY-001

pure func EmptyBundleSubviewDescriptor(parent: TileIndex)
    => BundleSubviewDescriptor
begin
    return BundleSubviewDescriptor {
        valid = FALSE,
        parent = parent,
        offset_cells = 0,
        origin_row = 0,
        origin_column = 0,
        rows = 0,
        columns = 0,
        valid_rows = 0,
        valid_columns = 0,
        cell_count = 0,
        capacity_bytes = 0
    };
end;

readonly func BundleCubeSubviewDescriptorOf(
    parent_index: TileIndex,
    offset: Word,
    size_code: integer {1..12}) => BundleSubviewDescriptor
begin
    let empty = EmptyBundleSubviewDescriptor(parent_index);
    let parent = _Tiles[[parent_index]];
    if !parent.allocated || !TileLayoutIsCube(parent.layout) ||
       parent.valid_rows == 0 ||
       parent.valid_columns == 0 || parent.cube_cell_count == 0 then
        return empty;
    end;
    let raw_offset = UInt(offset);
    if raw_offset > 65535 || raw_offset >= parent.cube_cell_count then
        return empty;
    end;
    let offset_cells = raw_offset as integer {0..65535};
    let requested_cells = (TileSizeCodeBytes(size_code) DIVRM PTO_TILE_CELL_BYTES)
        as integer {1..2048};
    if !TileCubePhysicalCellRangeComplete(
           parent.layout, parent.data_type, offset_cells,
           requested_cells) then return empty; end;
    let remaining = (parent.cube_cell_count - offset_cells)
        as integer {1..16384};
    let cell_count = if requested_cells < remaining then requested_cells
        else remaining;
    let cell_rows = TileCubeCellRows(parent.layout, parent.data_type);
    let cell_columns = TileCubeCellColumns(parent.layout, parent.data_type);
    if cell_rows == 0 || cell_columns == 0 then return empty; end;
    var origin_row: integer {0..65535} = 0;
    var origin_column: integer {0..65535} = 0;
    var view_cell_count: integer {1..16384} = cell_count;
    if parent.layout == TileLayout_CUBE_N8 then
        let k_repeat = parent.cube_k_repeat;
        if k_repeat == 0 || k_repeat > 16384 then return empty; end;
        let bounded_k_repeat = k_repeat as integer {1..16384};
        let cell_k = (offset_cells MOD bounded_k_repeat)
            as integer {0..16383};
        let cell_n = (offset_cells DIVRM bounded_k_repeat)
            as integer {0..8191};
        let cells_until_n_boundary = (bounded_k_repeat - cell_k)
            as integer {1..16384};
        if view_cell_count > cells_until_n_boundary then
            view_cell_count = cells_until_n_boundary;
        end;
        origin_row = (cell_k * cell_rows) as integer {0..65535};
        origin_column = (cell_n * cell_columns) as integer {0..65535};
    else
        let logical_offset = TileCubeLogicalGroupsForPhysicalCells(
            parent.layout, parent.data_type, offset_cells);
        origin_column = (logical_offset * cell_columns)
            as integer {0..65535};
    end;
    if origin_row >= parent.valid_rows || origin_column >= parent.valid_columns then
        return empty;
    end;
    var valid_rows: integer {0..65535} = parent.valid_rows;
    if origin_row < parent.valid_rows then
        valid_rows = (parent.valid_rows - origin_row) as integer {0..65535};
    end;
    if parent.layout == TileLayout_CUBE_N8 then
        let requested_rows = (view_cell_count * cell_rows)
            as integer {1..65535};
        if valid_rows > requested_rows then valid_rows = requested_rows; end;
    end;
    let view_groups = TileCubeLogicalGroupsForPhysicalCells(
        parent.layout, parent.data_type, view_cell_count);
    let requested_columns: integer {1..65535} =
        if parent.layout == TileLayout_CUBE_N8 then cell_columns as integer {1..65535}
        else (view_groups * cell_columns) as integer {1..65535};
    var valid_columns: integer {0..65535} = requested_columns;
    if origin_column < parent.valid_columns &&
       parent.valid_columns - origin_column < requested_columns then
        valid_columns = (parent.valid_columns - origin_column) as integer {0..65535};
    end;
    if valid_rows == 0 || valid_columns == 0 then return empty; end;
    let rows = TileCubeStorageRows(parent.layout, valid_rows, parent.data_type);
    let columns = TileCubeStorageColumns(parent.layout, valid_columns, parent.data_type);
    let derived_cells = TileCubeCellCount(parent.layout, valid_rows, valid_columns, parent.data_type);
    let derived_capacity = TileCubeRequiredBytes(parent.layout, valid_rows, valid_columns, parent.data_type);
    if rows == 0 || columns == 0 || derived_cells == 0 || derived_capacity == 0 ||
       derived_cells > view_cell_count then return empty; end;
    return BundleSubviewDescriptor {
        valid = TRUE,
        parent = parent_index,
        offset_cells = offset_cells,
        origin_row = origin_row,
        origin_column = origin_column,
        rows = rows,
        columns = columns,
        valid_rows = valid_rows,
        valid_columns = valid_columns,
        cell_count = derived_cells,
        capacity_bytes = derived_capacity
    };
end;

pure func BundleSubviewElementInBounds(
    descriptor: BundleSubviewDescriptor,
    row: integer {0..65535}, column: integer {0..65535}) => boolean
begin
    return descriptor.valid && row < descriptor.valid_rows && column < descriptor.valid_columns;
end;

readonly func BundleSubviewOperationApplicabilityIsTotal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    // Every accepted Tile operation is a legal dispatch candidate. The
    // selected operation's existing dtype/layout/shape/definedness checks
    // remain authoritative; this helper has no private family allowlist.
    return operation < PTO_TILE_OPERATION_COUNT;
end;

func PrepareSelectedBundleStage2() => boolean
begin
    if !_BundleOperation.valid then return TRUE; end;
    if !ResolveBundleRelativeTileSources() then return FALSE; end;
    let family = BundleTileDecodeFamily(_BundleOperation.operation_class);
    let code = BundleOperationDecodeCode(_BundleOperation);
    let decoded = DecodeTileOperation(family, code);
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if !PrepareBundleSubviewDescriptors(operation) then return FALSE; end;
    if !ValidateBundleLocalGenerationStructure() then return FALSE; end;
    if !ValidateBundleSharedGeneration() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    return TRUE;
end;

func PrepareBundleSubviewDescriptors(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !BundleSubviewOperationApplicabilityIsTotal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    // Bind readiness before materialization. A waiting consumer is a
    // non-faulting no-effect outcome and must never copy unready source cells
    // into a temporary view.
    if !PrepareBundleConsumerDependencies() then return FALSE; end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_subview.valid &&
               !_BundleTileBindings[[binding]].source0_subview.derived.valid then
                let encoded_size = _BundleTileBindings[[binding]]
                    .source0_subview.size_code;
                if encoded_size == 0 then
                    SetFault(Fault_TileLegality, ReadTPC());
                    return FALSE;
                end;
                let descriptor = BundleCubeSubviewDescriptorOf(
                    _BundleTileBindings[[binding]].source0,
                    _BundleTileBindings[[binding]].source0_subview.offset,
                    encoded_size as integer {1..12});
                if !descriptor.valid then
                    SetFault(Fault_TileLegality, ReadTPC());
                    return FALSE;
                end;
                _BundleTileBindings[[binding]].source0_subview.derived =
                    descriptor;
                if !MaterializeBundleSubview(
                        binding as BundleTileBindingIndex, FALSE,
                        descriptor, operation) then return FALSE; end;
            end;
            if _BundleTileBindings[[binding]].source1_subview.valid &&
               !_BundleTileBindings[[binding]].source1_subview.derived.valid then
                let encoded_size = _BundleTileBindings[[binding]]
                    .source1_subview.size_code;
                if encoded_size == 0 then
                    SetFault(Fault_TileLegality, ReadTPC());
                    return FALSE;
                end;
                let descriptor = BundleCubeSubviewDescriptorOf(
                    _BundleTileBindings[[binding]].source1,
                    _BundleTileBindings[[binding]].source1_subview.offset,
                    encoded_size as integer {1..12});
                if !descriptor.valid then
                    SetFault(Fault_TileLegality, ReadTPC());
                    return FALSE;
                end;
                _BundleTileBindings[[binding]].source1_subview.derived =
                    descriptor;
                if !MaterializeBundleSubview(
                        binding as BundleTileBindingIndex, TRUE,
                        descriptor, operation) then return FALSE; end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func BundleReadSubviewElement(
    binding: BundleTileBindingIndex,
    source_select: boolean,
    row: integer {0..65535},
    column: integer {0..65535}) => Word
begin
    let descriptor = if source_select then
        _BundleTileBindings[[binding]].source1_subview.derived
        else _BundleTileBindings[[binding]].source0_subview.derived;
    assert BundleSubviewElementInBounds(descriptor, row, column);
    return ReadTileElement(descriptor.parent,
        (descriptor.origin_row + row) as integer {0..65535},
        (descriptor.origin_column + column) as integer {0..65535});
end;

readonly func BundleTileSourceIndex(
    binding: BundleTileBindingIndex, source_select: boolean) => TileIndex
begin
    let modifier = if source_select then
        _BundleTileBindings[[binding]].source1_subview
        else _BundleTileBindings[[binding]].source0_subview;
    if modifier.materialized then return modifier.materialized_index; end;
    return if source_select then _BundleTileBindings[[binding]].source1
        else _BundleTileBindings[[binding]].source0;
end;

readonly func BundleTileArchitecturalSourceIndex(
    binding: BundleTileBindingIndex, source_select: boolean) => TileIndex
begin
    let modifier = if source_select then
        _BundleTileBindings[[binding]].source1_subview
        else _BundleTileBindings[[binding]].source0_subview;
    if modifier.valid && modifier.derived.valid then
        return modifier.derived.parent;
    end;
    return if source_select then _BundleTileBindings[[binding]].source1
        else _BundleTileBindings[[binding]].source0;
end;

func MaterializeBundleSubview(
    binding: BundleTileBindingIndex, source_select: boolean,
    descriptor: BundleSubviewDescriptor,
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let parent = descriptor.parent;
    let mask = _TileAllocationMasks[[parent]];
    if mask == Zeros{4} then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let parent_hand = (parent DIVRM 16) as integer {0..3};
    var materialized_index: TileIndex = 0;
    var found = FALSE;
    for offset = 0 to 15 do
        let candidate = (parent_hand * 16 + offset) as integer {0..63};
        if !found && !_Tiles[[candidate]].allocated then
            materialized_index = candidate as TileIndex;
            found = TRUE;
        end;
    end;
    if !found then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    // SUBVIEW preserves the parent's physical Local layout.  No consumer
    // engine or operand role may request an implicit conversion.
    if !ConfigureCubeTileForMask(materialized_index,
            descriptor.capacity_bytes, descriptor.valid_rows,
            descriptor.valid_columns, _Tiles[[parent]].data_type,
            _Tiles[[parent]].layout, mask) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    for row = 0 to descriptor.valid_rows - 1 looplimit 65536 do
        for column = 0 to descriptor.valid_columns - 1 looplimit 65536 do
            let source_row = (descriptor.origin_row + row)
                as integer {0..65535};
            let source_column = (descriptor.origin_column + column)
                as integer {0..65535};
            if TileElementDefined(parent, source_row, source_column) then
                WriteTileElement(materialized_index as TileIndex,
                    row as integer {0..65535}, column as integer {0..65535},
                    ReadTileElement(parent, source_row, source_column));
            end;
        end;
    end;
    // A materialized view is a derived temporary source, so its readiness
    // follows the parent validity proven by the descriptor preflight.  Keep
    // undefined parent regions undefined; a fully defined parent publishes
    // the copied valid view as a normal readable Tile source.
    if TileElementwiseSourceContentsDefined(parent) then
        MarkTileValidRegionDefined(materialized_index as TileIndex);
    end;
    if source_select then
        _BundleTileBindings[[binding]].source1_subview.materialized = TRUE;
        _BundleTileBindings[[binding]].source1_subview.materialized_index =
            materialized_index as TileIndex;
        _BundleTileBindings[[binding]].source1 =
            materialized_index as TileIndex;
    else
        _BundleTileBindings[[binding]].source0_subview.materialized = TRUE;
        _BundleTileBindings[[binding]].source0_subview.materialized_index =
            materialized_index as TileIndex;
        _BundleTileBindings[[binding]].source0 =
            materialized_index as TileIndex;
    end;
    return TRUE;
end;

func DiscardBundleSubviewMaterializations()
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_subview.materialized then
                _BundleTileBindings[[binding]].source0 =
                    _BundleTileBindings[[binding]].source0_subview
                        .derived.parent;
                ReleaseTile(_BundleTileBindings[[binding]].source0_subview
                    .materialized_index);
                _BundleTileBindings[[binding]].source0_subview.materialized =
                    FALSE;
            end;
            if _BundleTileBindings[[binding]].source1_subview.materialized then
                _BundleTileBindings[[binding]].source1 =
                    _BundleTileBindings[[binding]].source1_subview
                        .derived.parent;
                ReleaseTile(_BundleTileBindings[[binding]].source1_subview
                    .materialized_index);
                _BundleTileBindings[[binding]].source1_subview.materialized =
                    FALSE;
            end;
        end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
