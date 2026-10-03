<!-- GENERATED FROM: asl/tile/model/state/allocation.asl -->
# Allocation

**Normative ASL source:** `asl/tile/model/state/allocation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-ALLOCATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-state-allocation-purpose role=purpose-scope -->
## 用途与范围

本单元拥有把 Local Tile 寄存器变为已分配 Tile 以及再变回来的状态转换。Local Tile 寄存器是 `_Tiles` 的 64 个绝对条目之一，每个条目由一条 `TileInfo` 记录描述，并在 `_TileAllocationMasks` 中带有一个四位分配掩码。

它定义四个分配族和一个释放转换：

- `ConfigureTileForMask` 用于普通（非 CUBE）数值 Tile；它保存所提供的布局而不检查它。
- `ConfigurePredicateTileForMask` 用于按位打包的谓词 Tile。
- `ConfigureCubeTileForMaskWithPhysical` 及其包装函数用于 CUBE 布局。
- `ConfigurePredicateCellForMask` 用于 U8 CUBE 谓词单元。
- `ReleaseTile`，它把寄存器恢复为未分配状态。

单 PE 包装函数 `ConfigureTile`、`ConfigurePredicateTile`、`ConfigureCubeTile` 和 `ConfigurePredicateCell` 传入掩码 `0001`；前三个还会把该寄存器安装为相对源夹具（`ConfigureCubeTile` 仅在分配成功时安装）。

<!-- PTO-READER-BLOCK: tile-model-state-allocation-concepts role=concepts-state -->
## 概念与可见状态

每次分配都会写入 `TileInfo` 的完整描述符部分：

- `capacity_bytes` 是该对象的每 PE 字节预算。
- `rows` 和 `columns` 是物理形状；`valid_rows` 和 `valid_columns` 界定其中的有效区域。
- `data_type` 和 `layout` 选择元素宽度和元素顺序。
- `storage_kind` 是 `TileStorage_Numeric`、`TileStorage_Predicate` 或 `TileStorage_PredicateCell`。
- `predicate_basis_type` 为谓词单元记录比较类型，其他情况下等于 `data_type`。
- `cube_k_repeat`、`cube_n_repeat`、`cube_cell_count` 和 `cube_storage_bytes` 仅对 CUBE 布局为非零。

分配掩码指明持有该对象副本的 PE。PE0 是最高位，因此 `1000` 仅表示 PE0，`0001` 仅表示 PE3。

设计要点：分配定义 `TileInfo`，但不定义载荷。每次分配都把 `contents_defined` 设为 FALSE，清除 `defined_elements`，并把 `defined_valid_elements` 设为 0。数值路径和谓词路径还会清除 `packed_defined_elements`；CUBE Tile 从不使用该打包位图。生产者必须先写入 Tile，通用载荷读取才合法，因此通用读取不会返回同一寄存器先前分配遗留的值。

<!-- PTO-READER-BLOCK: tile-model-state-allocation-rules role=rules-interactions -->
## 规则与交互

`ConfigureTileForMask` 按以下顺序断言：容量合法（`TileCapacityIsLegal`）、掩码非零、`rows` 为正、`valid_rows <= rows`、在推导行数下描述符形状合法、`valid_rows` 不超过配置行数、在配置行数下物理形状合法，以及每个选中 PE 的 Local 池都有空间（`LocalTileAllocationFitsExcept`）。只有此后才写入状态。

配置行数取决于列数。列数为二的幂时，行数来自 `DerivedTileRows`；对于 E2M1X2 和 E1M2X2 以外的类型，Tile 随后恰好填满其容量。列数不是二的幂时，对于 FP32、FP16、BF16、E2M1X2 或 E1M2X2，保留调用者给出的 `rows`，它只需放得下即可。

谓词 Tile 使用 `PredicateTileStorageBytes`，即每个元素一位，向上取整到整字节。其 `data_type` 总是 U8，布局总是 RowMajor。

当掩码为零、几何不合法或池已满时，CUBE 分配返回 FALSE 而不是断言失败。它记录由 CUBE 辅助函数计算出的单元几何。

设计要点：每次分配和 `ReleaseTile` 都会调用 `InvalidateTileFeatureMapDescriptor`。特征图描述符在每次分配和释放时都会失效，即使新形状完全相同，因此使用前必须重新配置。

设计要点：容量用 `LocalTileAllocationFitsExcept` 检查，它排除正在配置的寄存器。重新配置寄存器会替换其旧的占用，而不是在其上累加。

<!-- PTO-READER-BLOCK: tile-model-state-allocation-boundaries role=boundaries -->
## 架构边界

这些辅助函数不是指令。指令束分派会调用它们，例如通过 destination-auxiliary 中的 `ConfigureBundleTileDestination`、谓词、CUBE 和 TCVT 目标解析器、单元重排、子视图物化，以及 TIMG2COL 和布局转换路径。故障回滚和 Local 代次中止会对指令束所分配的目标调用 `ReleaseTile`，子视图处理也会释放其临时物化结果。

`ReleaseTile` 还会调用 `RemoveRelativeTileMapping`，因此已释放的寄存器不再能通过相对 `#n` 选择子访问。

`PTO_MODEL_TILE_ELEMENTS`（本模型中为 32768）决定可执行已定义性位图的大小，并限制谓词 Tile。它是模型界限，不是对所有实现的断言。

<!-- PTO-READER-BLOCK: tile-model-state-allocation-example role=example-usage -->
## 非规范阅读示例

考虑对寄存器 5 调用 `ConfigureTile`，容量 4096 字节，`rows` 参数为 64，16 列，有效区域 50 乘 10，FP32，RowMajor。

- 容量是 128 的倍数且不大于 64 KiB，因此合法。
- 16 是二的幂，因此行数由推导得出：4096 x 8 = 32768 位，除以每行 16 x 32 = 512 位，得到 64 行。
- 有效行数 50 和有效列数 10 落在 64 乘 16 之内。
- 掩码 `0001` 在 PE3 的 Local 池中计入 4096 字节。

调用之后，`rows` 为 64，`contents_defined` 为 FALSE。在生产者写入之前读取任何元素都会违反已定义性前置条件。

<!-- PTO-READER-BLOCK: tile-model-state-allocation-related role=related-owners-navigation -->
## 相关所有者

- [Tile 模型类型](types.md)定义 `TileInfo` 和 `TileStorageKind`。
- [行与列](../shape/rows-columns.md)和[有效区域](../shape/valid-region.md)拥有此处使用的形状检查。
- [CUBE 单元格几何](../shape/cube-cell.md)拥有 CUBE 重复次数、单元数和字节数。
- [Local 容量](../capacity/local.md)拥有每 PE 池检查。
- [目标辅助](../../../block/model/dispatch/destination-auxiliary.md)展示指令束分派如何到达这些转换。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/state/allocation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-ALLOCATION","surface":"tile","classification":["model","state","allocation"],"depends_on":["PTO-TILE-MODEL-SHAPE-VALID-REGION","PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS"]}
func ConfigureTileForMask(index: TileIndex,
                   capacity_bytes: integer {0..262144},
                   rows: integer {0..65535}, columns: integer {0..65535},
                   valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
                   data_type: TileDataType, layout: TileLayout,
                   allocation_mask: bits(4))
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert TileCapacityIsLegal(capacity_bytes);
    assert allocation_mask != Zeros{4};
    assert rows > 0;
    assert valid_rows <= rows;
    assert TileDescriptorShapeLegal(capacity_bytes, columns, valid_rows,
        valid_columns, data_type);
    let derived_rows = DerivedTileRows(capacity_bytes, columns, data_type);
    let configured_rows = if !IsNonzeroPowerOfTwo(columns) &&
        TileDataTypeAllowsOddPhysicalColumns(data_type) then rows
        else derived_rows;
    assert valid_rows <= configured_rows;
    assert TileDescriptorPhysicalShapeLegal(capacity_bytes, configured_rows, columns,
        valid_rows, valid_columns, data_type);
    assert LocalTileAllocationFitsExcept(
        index, allocation_mask, capacity_bytes);
    InvalidateTileFeatureMapDescriptor(index);
    _TileAllocationMasks[[index]] = allocation_mask;
    _Tiles[[index]].allocated = TRUE;
    _Tiles[[index]].storage_kind = TileStorage_Numeric;
    // Allocation defines TileInfo but not the payload. A producer must write
    // the tile before any generic payload read is legal.
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].packed_defined_elements =
        zero_packed_tile_elements;
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = configured_rows;
    _Tiles[[index]].columns = columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].data_type = data_type;
    _Tiles[[index]].predicate_basis_type = data_type;
    _Tiles[[index]].layout = layout;
    _Tiles[[index]].cube_k_repeat = 0;
    _Tiles[[index]].cube_n_repeat = 0;
    _Tiles[[index]].cube_cell_count = 0;
    _Tiles[[index]].cube_storage_bytes = 0;
end;

pure func PredicateTileStorageBytes(
    rows: integer {0..65535},
    columns: integer {0..65535}) => integer
begin
    return ((rows * columns) + 7) DIVRM 8;
end;

func ConfigurePredicateTileForMask(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    rows: integer {0..65535},
    columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    allocation_mask: bits(4))
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert TileCapacityIsLegal(capacity_bytes);
    assert allocation_mask != Zeros{4};
    assert rows > 0 && columns > 0;
    assert valid_rows <= rows && valid_columns <= columns;
    assert rows * columns <= PTO_MODEL_TILE_ELEMENTS;
    assert PredicateTileStorageBytes(rows, columns) <= capacity_bytes;
    assert LocalTileAllocationFitsExcept(
        index, allocation_mask, capacity_bytes);
    InvalidateTileFeatureMapDescriptor(index);
    _TileAllocationMasks[[index]] = allocation_mask;
    _Tiles[[index]].allocated = TRUE;
    _Tiles[[index]].storage_kind = TileStorage_Predicate;
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].packed_defined_elements =
        zero_packed_tile_elements;
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = rows;
    _Tiles[[index]].columns = columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].data_type = TileDataType_U8;
    _Tiles[[index]].predicate_basis_type = TileDataType_U8;
    _Tiles[[index]].layout = TileLayout_RowMajor;
    _Tiles[[index]].cube_k_repeat = 0;
    _Tiles[[index]].cube_n_repeat = 0;
    _Tiles[[index]].cube_cell_count = 0;
    _Tiles[[index]].cube_storage_bytes = 0;
end;

func ConfigurePredicateTile(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    rows: integer {0..65535},
    columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535})
begin
    ConfigurePredicateTileForMask(
        index,
        capacity_bytes,
        rows,
        columns,
        valid_rows,
        valid_columns,
        '0001');
    InstallRelativeTileFixture(index, index);
end;

func ConfigureTile(index: TileIndex, capacity_bytes: integer {0..262144},
                   rows: integer {0..65535}, columns: integer {0..65535},
                   valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
                   data_type: TileDataType, layout: TileLayout)
begin
    // Direct one-level operations model the already-resolved current-PE
    // fragment and therefore charge one PE of capacity.
    ConfigureTileForMask(index, capacity_bytes, rows, columns,
        valid_rows, valid_columns, data_type, layout, '0001');
    InstallRelativeTileFixture(index, index);
end;

func ConfigureCubeTileForMaskWithPhysical(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout,
    allocation_mask: bits(4)) => boolean
begin
    if allocation_mask == Zeros{4} ||
       !TileCubeDescriptorShapeAndPhysicalLegal(capacity_bytes,
           physical_rows, physical_columns, valid_rows, valid_columns,
           data_type, layout) then
        return FALSE;
    end;
    if !LocalTileAllocationFitsExcept(
           index, allocation_mask, capacity_bytes) then
        return FALSE;
    end;
    let rows = physical_rows;
    let columns = physical_columns;
    let k_repeat = TileCubePhysicalKRepeat(
        layout, physical_rows, physical_columns, data_type);
    let n_repeat = TileCubePhysicalNRepeat(
        layout, physical_rows, physical_columns, data_type);
    let cell_count = TileCubePhysicalCellCount(
        layout, physical_rows, physical_columns, data_type);
    let storage_bytes = TileCubePhysicalRequiredBytes(
        layout, physical_rows, physical_columns, data_type);
    assert rows != 0 && columns != 0 && k_repeat != 0 &&
           n_repeat != 0 && cell_count != 0 && storage_bytes != 0;
    InvalidateTileFeatureMapDescriptor(index);
    _TileAllocationMasks[[index]] = allocation_mask;
    _Tiles[[index]].allocated = TRUE;
    _Tiles[[index]].storage_kind = TileStorage_Numeric;
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = rows;
    _Tiles[[index]].columns = columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].data_type = data_type;
    _Tiles[[index]].predicate_basis_type = data_type;
    _Tiles[[index]].layout = layout;
    _Tiles[[index]].cube_k_repeat = k_repeat;
    _Tiles[[index]].cube_n_repeat = n_repeat;
    _Tiles[[index]].cube_cell_count = cell_count;
    _Tiles[[index]].cube_storage_bytes = storage_bytes;
    return TRUE;
end;

func ConfigureCubeTileForMaskWithColumns(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535},
    columns: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout,
    allocation_mask: bits(4)) => boolean
begin
    return ConfigureCubeTileForMaskWithPhysical(index, capacity_bytes,
        TileCubeStorageRows(layout, valid_rows, data_type), columns,
        valid_rows, valid_columns, data_type, layout, allocation_mask);
end;

func ConfigureCubeTileForMask(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout,
    allocation_mask: bits(4)) => boolean
begin
    return ConfigureCubeTileForMaskWithPhysical(index, capacity_bytes,
        TileCubeStorageRows(layout, valid_rows, data_type),
        TileCubeStorageColumns(layout, valid_columns, data_type), valid_rows,
        valid_columns, data_type, layout, allocation_mask);
end;

func ConfigureCubeTile(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout) => boolean
begin
    let configured = ConfigureCubeTileForMask(index, capacity_bytes, valid_rows,
        valid_columns, data_type, layout, '0001');
    if configured then InstallRelativeTileFixture(index, index); end;
    return configured;
end;

func ReleaseTile(index: TileIndex)
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    RemoveRelativeTileMapping(index);
    InvalidateTileFeatureMapDescriptor(index);
    _TileAllocationMasks[[index]] = Zeros{4};
    _Tiles[[index]].allocated = FALSE;
    _Tiles[[index]].storage_kind = TileStorage_Numeric;
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].packed_defined_elements =
        zero_packed_tile_elements;
    _Tiles[[index]].capacity_bytes = 0;
    _Tiles[[index]].rows = 0;
    _Tiles[[index]].columns = 0;
    _Tiles[[index]].valid_rows = 0;
    _Tiles[[index]].valid_columns = 0;
    _Tiles[[index]].data_type = TileDataType_U8;
    _Tiles[[index]].predicate_basis_type = TileDataType_U8;
    _Tiles[[index]].layout = TileLayout_RowMajor;
    _Tiles[[index]].cube_k_repeat = 0;
    _Tiles[[index]].cube_n_repeat = 0;
    _Tiles[[index]].cube_cell_count = 0;
    _Tiles[[index]].cube_storage_bytes = 0;
end;

func ConfigurePredicateCellForMask(
    index: TileIndex, capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
    basis_type: TileDataType, layout: TileLayout,
    allocation_mask: bits(4)) => boolean
begin
    if (layout != TileLayout_CUBE_M16 && layout != TileLayout_CUBE_M32) ||
       !TileCubePredicateDataTypeSupported(basis_type) ||
       !TileCubeLayoutDataTypeSupported(layout, basis_type) then
        return FALSE;
    end;
    if !ConfigureCubeTileForMask(
           index, capacity_bytes, valid_rows, valid_columns,
           TileDataType_U8, layout, allocation_mask) then
        return FALSE;
    end;
    _Tiles[[index]].storage_kind = TileStorage_PredicateCell;
    _Tiles[[index]].predicate_basis_type = basis_type;
    return TRUE;
end;

func ConfigurePredicateCell(
    index: TileIndex, capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
    basis_type: TileDataType, layout: TileLayout) => boolean
begin
    return ConfigurePredicateCellForMask(
        index, capacity_bytes, valid_rows, valid_columns,
        basis_type, layout, '0001');
end;
```
<!-- GENERATED-ASL-END: unit -->
