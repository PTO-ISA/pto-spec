<!-- GENERATED FROM: asl/tile/model/state/shared-registers.asl -->
# Shared Registers

**Normative ASL source:** `asl/tile/model/state/shared-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-SHARED-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-state-shared-registers-purpose role=purpose-scope -->
## 用途与范围

本单元拥有 Core 私有 Shared Tile 寄存器 S0 到 S63 的行为。一个 Shared 寄存器保存一条 Tile 记录，由一个 Core 的全部四个 PE 共同寻址。

它定义就绪与合法性谓词、消费者的读取路径，以及唯一的提交转换 `AtomicUpdateSharedTileWithPublication`。它带有已接受的要求 `PTO-B-SHARED-WHOLE-PARENT-READY-001`。

<!-- PTO-READER-BLOCK: tile-model-state-shared-registers-concepts role=concepts-state -->
## 概念与可见状态

每个 `SharedTileInfo` 在 `TileInfo` 外包装描述符、生产者覆盖、就绪及发布字段。载荷生命周期增加 `payload_live`、单调的 `payload_generation`，以及开放组装的 `reserved_capacity_bytes`。描述符仍有效时，其载荷也可能已经失去存活状态。

- `descriptor_valid`：该寄存器保存有描述符。
- `allocation_mask`：参与该父级的 PE，由首次更新固定。
- `initialized_mask`：已写入其部分的生产者 PE。
- `whole_parent_ready`：完整父级已就绪。
- `published`：父级对消费者可见。

“父级”指整个 Shared Tile，与单个 PE 写入的部分相对。

`SharedTileFullyInitialized` 要求存在描述符、`initialized_mask` 等于 `allocation_mask`，且内容已定义。`SharedTilePublished` 还额外要求 `whole_parent_ready` 和 `published`。

<!-- PTO-READER-BLOCK: tile-model-state-shared-registers-rules role=rules-interactions -->
## 规则与交互

`AtomicUpdateSharedTileWithPublication` 有三条路径：

1. 空寄存器接收候选描述符与生产者覆盖；就绪取决于完整已定义数据及所选发布路径。
2. 已有寄存器可原子接收完整的单 PE 发布。
3. 内部聚合 helper 还支持已分类的生产者区域复制。该表示不会使 PE 参与掩码在架构上分配载荷四分区：编码的多 PE 写者通过显式 `B.ASSEMBLE` 范围确定放置位置。

在这些路径之前，`SharedTileUpdateCompatible` 会拒绝 CUBE 布局、非法 Shared 容量以及与容量不匹配的形状。对于已有描述符，它要求掩码保持在 `allocation_mask` 之内，且描述符在容量、物理形状、有效区域、数据类型、布局和 CUBE 几何字段上都一致。对于新描述符，它要求 Shared 池中有空间。

设计要点：一次完整的记录赋值就是提交点。源注释说明了这一点，该转换先在局部副本中构建新记录，再对 `_SharedTiles` 进行一次写入。消费者永远看不到更新到一半的描述符。

设计要点：零 PE 掩码是真正的空操作。更新返回 TRUE，不读取也不写入状态。

设计要点：生产者覆盖、就绪和可见性保持彼此独立。`PTO-B-SHARED-WHOLE-PARENT-READY-001` 要求每个 Shared 消费者在访问载荷之前等待或空操作，直到 `whole_parent_ready` 和 `published` 都为真，并说明生产者掩码与消费者掩码相互独立。

<!-- PTO-READER-BLOCK: tile-model-state-shared-registers-boundaries role=boundaries -->
## 架构边界

`MaterializeSharedTile` 为每个消费者提供同一个完整父级快照。PE 掩码选择的是消费者，而不是载荷的四分之一部分，且物化从不改变 Shared 状态。

通过 `MaterializeSharedTileForReadSchema` 读取未定义 Shared 寄存器时使用临时只读描述符。描述符不存在、`payload_live` 为假、父对象未就绪或元素未定义时，`ReadSharedTileWord` 提供确定性模型值；该回退不允许普通指令读取已消费载荷。即便描述符及 `published` 身份保留，普通源预检仍在访问载荷前诊断已消费代次。

<!-- PTO-READER-BLOCK: tile-model-state-shared-registers-example role=example-usage -->
## 非规范阅读示例

S5 为空。PE0 以掩码 `1000` 并请求发布，向其写入一个已定义的 64 KiB RowMajor Tile。

- 第一条路径安装该记录，`allocation_mask` 和 `initialized_mask` 均为 `1000`。
- 掩码指明一个 PE 且内容已定义，因此 `whole_parent_ready` 和 `published` 变为 TRUE。

之后 PE1 以掩码 `0100` 进行的写入会被拒绝：`0100` 不在已固定的 `allocation_mask` `1000` 之内。

如果首次写入改用掩码 `1100`，记录会以两个掩码均为 `1100` 的形式安装，但不会变为就绪。第一条路径上的直接就绪要求掩码恰好指明一个 PE 或全部四个 PE。

<!-- PTO-READER-BLOCK: tile-model-state-shared-registers-related role=related-owners-navigation -->
## 相关所有者

- [类型](types.md)定义 `SharedTileInfo`。
- [Shared 容量](../capacity/shared.md)提供池上限。
- [Shared 搬运](../memory/shared-movement.md)在 Local 到 Shared 的搬运中调用该更新转换。
- [Shared TLSU](../../../block/model/dispatch/shared-tlsu.md) 和 [Shared CUBE 矩阵](../../../block/model/dispatch/shared-cube-matrix.md)消费 Shared 寄存器。
- [Shared Tile 状态](../../../arch/features/shared-tile-state.md)给出架构模型。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/state/shared-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-SHARED-REGISTERS","surface":"tile","classification":["model","state","shared-registers"],"depends_on":["PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","PTO-TILE-MODEL-LEGALITY-PE-MASK","PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY"]}

// NDF-BEGIN: PTO-B-SHARED-WHOLE-PARENT-READY-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Shared producer participation, logical coverage, whole_parent_ready, and
// published visibility MUST remain distinct. Every Shared source consumer MUST
// wait/no-op before payload access until whole_parent_ready and published are
// both true; producer and consumer masks are independent.
// Independently executed direct producers MUST capture actual PE-owned
// fragments under an operation identity and MUST publish only through the
// existing atomic update. A completed Shared initialized_mask MUST NOT be
// reused as contribution state for a later dynamic operation.
// NDF-END: PTO-B-SHARED-WHOLE-PARENT-READY-001

pure func SharedTileArrayIndex(shared_tile_id: SharedTileID) => SharedTileIndex
begin
    return UInt(shared_tile_id) as SharedTileIndex;
end;

readonly func SharedTileRecord(shared_tile_id: SharedTileID) => SharedTileInfo
begin
    return _SharedTiles[[SharedTileArrayIndex(shared_tile_id)]];
end;

readonly func SharedTilePayloadIntact(shared_tile_id: SharedTileID) => boolean
begin
    let shared = SharedTileRecord(shared_tile_id);
    return !shared.descriptor_valid || shared.payload_live;
end;

func ConsumeSharedTilePayload(shared_tile_id: SharedTileID)
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    if _SharedTiles[[index]].descriptor_valid then
        _SharedTiles[[index]].payload_live = FALSE;
    end;
end;

func ReserveSharedTileGenerationCapacity(
    shared_tile_id: SharedTileID, capacity_bytes: integer {0..262144})
    => boolean
begin
    let old_charge = SharedTileCapacityCharge(shared_tile_id);
    let proposed_charge = if old_charge > capacity_bytes then
        old_charge else capacity_bytes;
    if (SharedTileCapacityInUse() - old_charge) + proposed_charge >
       SharedTileCapacityLimitBytes() then return FALSE; end;
    _SharedTiles[[SharedTileArrayIndex(shared_tile_id)]]
        .reserved_capacity_bytes = capacity_bytes;
    return TRUE;
end;

func ReleaseSharedTileGenerationCapacity(shared_tile_id: SharedTileID)
begin
    _SharedTiles[[SharedTileArrayIndex(shared_tile_id)]]
        .reserved_capacity_bytes = 0;
end;

readonly func SharedTileFullyInitialized(shared_tile_id: SharedTileID) => boolean
begin
    let shared = SharedTileRecord(shared_tile_id);
    return shared.descriptor_valid &&
           shared.initialized_mask == shared.allocation_mask &&
           shared.tile.contents_defined;
end;

readonly func SharedTilePublished(shared_tile_id: SharedTileID) => boolean
begin
    let shared = SharedTileRecord(shared_tile_id);
    return SharedTileFullyInitialized(shared_tile_id) &&
           shared.whole_parent_ready && shared.published;
end;

readonly func SharedTileCooperativeMatrixReady(
    shared_tile_id: SharedTileID) => boolean
begin
    let shared = SharedTileRecord(shared_tile_id);
    return SharedTileDescriptorLegal(shared_tile_id) &&
           shared.whole_parent_ready && shared.published &&
           shared.tile.contents_defined;
end;

readonly func SharedTileDescriptorLegal(shared_tile_id: SharedTileID) => boolean
begin
    let shared = SharedTileRecord(shared_tile_id);
    return shared.descriptor_valid && shared.tile.allocated &&
           shared.allocation_mask != Zeros{4} &&
           (shared.initialized_mask AND NOT shared.allocation_mask) == Zeros{4} &&
           SharedTileCapacityIsLegal(shared.tile.capacity_bytes) &&
           TileShapeMatchesCapacity(shared.tile.capacity_bytes,
               shared.tile.rows, shared.tile.columns,
               shared.tile.data_type) &&
           shared.tile.valid_rows <= shared.tile.rows &&
           shared.tile.valid_columns <= shared.tile.columns &&
           shared.tile.rows * shared.tile.columns <=
               TileLogicalElementCapacity(shared.tile.capacity_bytes,
                                          shared.tile.data_type) &&
           TileGenericIndexingPermitted(shared.tile);
end;

readonly func SharedTileDescriptorsCompatible(left: TileInfo,
                                               right: TileInfo) => boolean
begin
    return left.allocated && right.allocated &&
           !TileLayoutIsCube(left.layout) &&
           !TileLayoutIsCube(right.layout) &&
           left.capacity_bytes == right.capacity_bytes &&
           left.rows == right.rows && left.columns == right.columns &&
           left.valid_rows == right.valid_rows &&
           left.valid_columns == right.valid_columns &&
           left.data_type == right.data_type &&
           left.layout == right.layout &&
           left.cube_k_repeat == right.cube_k_repeat &&
           left.cube_n_repeat == right.cube_n_repeat &&
           left.cube_cell_count == right.cube_cell_count &&
           left.cube_storage_bytes == right.cube_storage_bytes;
end;

readonly func SharedTileUpdateCompatible(shared_tile_id: SharedTileID, tile: TileInfo,
                                          pe_mask: bits(4)) => boolean
begin
    if pe_mask == Zeros{4} then return TRUE; end;
    if TileLayoutIsCube(tile.layout) ||
       !SharedTileCapacityIsLegal(tile.capacity_bytes) ||
       !TileShapeMatchesCapacity(tile.capacity_bytes, tile.rows,
                                 tile.columns, tile.data_type) ||
       tile.valid_rows > tile.rows ||
       tile.valid_columns > tile.columns ||
       tile.rows * tile.columns >
           TileLogicalElementCapacity(tile.capacity_bytes, tile.data_type) then
        return FALSE;
    end;
    let old = SharedTileRecord(shared_tile_id);
    if old.descriptor_valid then
        if (pe_mask AND NOT old.allocation_mask) != Zeros{4} ||
           !SharedTileDescriptorsCompatible(old.tile, tile) then
            return FALSE;
        end;
    end;
    let old_charge = SharedTileCapacityCharge(shared_tile_id);
    let new_charge = if tile.capacity_bytes > old.reserved_capacity_bytes then
        tile.capacity_bytes else old.reserved_capacity_bytes;
    return (SharedTileCapacityInUse() - old_charge) + new_charge <=
        SharedTileCapacityLimitBytes();
end;

// Architectural undefined-register behavior is represented deterministically
// by pto-v0. The returned word is not a portable value and reading it never
// allocates the register or raises a fault.
readonly func UndefinedSharedTileWord(shared_tile_id: SharedTileID,
                                      element: PackedTileElementIndex) => Word
begin
    return ZeroExtend{PTO_XLEN}(shared_tile_id) XOR
        (Zeros{PTO_XLEN} + element);
end;

readonly func ReadSharedTileWord(shared_tile_id: SharedTileID,
                                 element: PackedTileElementIndex) => Word
begin
    let shared = SharedTileRecord(shared_tile_id);
    if !shared.descriptor_valid || !shared.payload_live ||
       !shared.whole_parent_ready ||
       !TileLogicalElementDefined(shared.tile, element) then
        return UndefinedSharedTileWord(shared_tile_id, element);
    end;
    return TileReadLogicalElement(shared.tile, element);
end;

// PE_MASK selects consumers, not payload quarters. Materialization returns the
// same complete parent snapshot to every participating consumer and never
// changes Shared state.
readonly func MaterializeSharedTile(shared_tile_id: SharedTileID,
                                    pe_mask: bits(4)) => TileInfo
begin
    let shared = SharedTileRecord(shared_tile_id);
    assert SharedTilePublished(shared_tile_id);
    var tile = shared.tile;
    assert tile.contents_defined;
    return tile;
end;

readonly func SharedTileReadSchemaLegalAtCapacity(
    shared_tile_id: SharedTileID, valid_rows: integer {0..65535},
    valid_columns: integer {0..65535}, columns: integer {0..65535},
    data_type: TileDataType, layout: TileLayout,
    capacity_bytes: integer {0..262144}) => boolean
begin
    if TileLayoutIsCube(layout) then return FALSE; end;
    let shared = SharedTileRecord(shared_tile_id);
    if shared.descriptor_valid then
        return SharedTileDescriptorLegal(shared_tile_id) &&
               shared.tile.capacity_bytes == capacity_bytes &&
               shared.tile.columns == columns &&
               valid_rows <= shared.tile.valid_rows &&
               valid_columns <= shared.tile.valid_columns &&
               shared.tile.data_type == data_type &&
               shared.tile.layout == layout;
    end;
    return SharedTileCapacityIsLegal(capacity_bytes) &&
           TileDescriptorShapeLegal(capacity_bytes, columns, valid_rows,
               valid_columns, data_type) &&
           DerivedTileRows(capacity_bytes, columns, data_type) * columns <=
               TileLogicalElementCapacity(capacity_bytes, data_type);
end;

readonly func SharedTileReadSchemaLegal(
    shared_tile_id: SharedTileID, valid_rows: integer {0..65535},
    valid_columns: integer {0..65535}, columns: integer {0..65535},
    data_type: TileDataType, layout: TileLayout) => boolean
begin
    let shared = SharedTileRecord(shared_tile_id);
    let capacity_bytes = if shared.descriptor_valid then
        shared.tile.capacity_bytes
    else
        MinimumTileCapacityBytesForShape(columns, valid_rows,
            valid_columns, data_type);
    return capacity_bytes != 0 && SharedTileReadSchemaLegalAtCapacity(
        shared_tile_id, valid_rows, valid_columns, columns, data_type, layout,
        capacity_bytes);
end;

readonly func MaterializeSharedTileReadValues(
    shared_tile_id: SharedTileID, tile: TileInfo) => TileInfo
begin
    var result = tile;
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(
                result, row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, element,
                ReadSharedTileWord(shared_tile_id, element));
        end;
    end;
    return result;
end;

// Reading an unallocated Sx is the Tile analogue of reading an undefined
// scalar register.  The operation receives a temporary read-only descriptor,
// while ReadSharedTileWord supplies deterministic model values without
// allocating or changing the architectural Shared register.
readonly func MaterializeSharedTileForReadSchema(
    shared_tile_id: SharedTileID, valid_rows: integer {0..65535},
    valid_columns: integer {0..65535}, columns: integer {0..65535},
    data_type: TileDataType, layout: TileLayout) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert SharedTileReadSchemaLegal(shared_tile_id, valid_rows, valid_columns,
        columns, data_type, layout);
    let shared = SharedTileRecord(shared_tile_id);
    let capacity_bytes = if shared.descriptor_valid then
        shared.tile.capacity_bytes
    else
        MinimumTileCapacityBytesForShape(columns, valid_rows,
            valid_columns, data_type);
    var tile = shared.tile;
    tile.allocated = TRUE;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.defined_valid_elements = 0;
    tile.packed_defined_elements = zero_packed_tile_elements;
    tile.capacity_bytes = capacity_bytes;
    tile.rows = DerivedTileRows(capacity_bytes, columns, data_type);
    tile.columns = columns;
    tile.valid_rows = valid_rows;
    tile.valid_columns = valid_columns;
    tile.data_type = data_type;
    tile.predicate_basis_type = data_type;
    tile.layout = layout;
    tile.cube_k_repeat = 0;
    tile.cube_n_repeat = 0;
    tile.cube_cell_count = 0;
    tile.cube_storage_bytes = 0;
    return MaterializeSharedTileReadValues(shared_tile_id, tile);
end;

readonly func MaterializeSharedTileForReadSchemaAtCapacity(
    shared_tile_id: SharedTileID, valid_rows: integer {0..65535},
    valid_columns: integer {0..65535}, columns: integer {0..65535},
    data_type: TileDataType, layout: TileLayout,
    capacity_bytes: integer {0..262144}) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert SharedTileReadSchemaLegalAtCapacity(shared_tile_id, valid_rows,
        valid_columns, columns, data_type, layout, capacity_bytes);
    var tile = SharedTileRecord(shared_tile_id).tile;
    tile.allocated = TRUE;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.defined_valid_elements = 0;
    tile.packed_defined_elements = zero_packed_tile_elements;
    tile.capacity_bytes = capacity_bytes;
    tile.rows = DerivedTileRows(capacity_bytes, columns, data_type);
    tile.columns = columns;
    tile.valid_rows = valid_rows;
    tile.valid_columns = valid_columns;
    tile.data_type = data_type;
    tile.predicate_basis_type = data_type;
    tile.layout = layout;
    tile.cube_k_repeat = 0;
    tile.cube_n_repeat = 0;
    tile.cube_cell_count = 0;
    tile.cube_storage_bytes = 0;
    return MaterializeSharedTileReadValues(shared_tile_id, tile);
end;

readonly func SharedTileProspectiveFullyInitialized(
    shared_tile_id: SharedTileID, tile: TileInfo, pe_mask: bits(4)) => boolean
begin
    if pe_mask == Zeros{4} ||
       !SharedTileUpdateCompatible(shared_tile_id, tile, pe_mask) then
        return FALSE;
    end;
    let old = SharedTileRecord(shared_tile_id);
    if !old.descriptor_valid then return TRUE; end;
    return (old.initialized_mask OR pe_mask) == old.allocation_mask;
end;

// One complete record assignment is the architectural commit point. A
// singleton producer publishes the complete parent; multi-PE candidates copy
// their internal writer fragments only for B.ASSEMBLE generation handling.
// A zero mask is a true NOP.
func AtomicUpdateSharedTileWithPublication(
    shared_tile_id: SharedTileID, tile: TileInfo, pe_mask: bits(4),
    publish: boolean) => boolean
begin
    if pe_mask == Zeros{4} then return TRUE; end;
    assert tile.allocated;
    let index = SharedTileArrayIndex(shared_tile_id);
    let old = _SharedTiles[[index]];
    if !SharedTileUpdateCompatible(shared_tile_id, tile, pe_mask) then
        return FALSE;
    end;
    var updated = old;
    if !old.descriptor_valid then
        let direct_complete = PEMaskPopulation(pe_mask) == 1 ||
            pe_mask == '1111';
        updated.descriptor_valid = TRUE;
        updated.payload_live = TRUE;
        updated.payload_generation = old.payload_generation + 1;
        updated.allocation_mask = pe_mask;
        updated.tile = tile;
        updated.initialized_mask = pe_mask;
        updated.whole_parent_ready = publish && direct_complete &&
            tile.contents_defined;
        updated.published = updated.whole_parent_ready;
    elsif publish && PEMaskPopulation(pe_mask) == 1 then
        updated.tile = tile;
        updated.tile.contents_defined = TRUE;
        updated.tile.defined_valid_elements =
            (updated.tile.valid_rows * updated.tile.valid_columns)
                as integer {0..524288};
        updated.whole_parent_ready = TRUE;
        updated.published = TRUE;
        updated.payload_live = TRUE;
        updated.payload_generation = old.payload_generation + 1;
    else
        for element = 0 to tile.rows * tile.columns - 1
            looplimit 524288 do
            let region = SharedTileElementRegion(tile,
                element as PackedTileElementIndex);
            if pe_mask[PTOPEMaskBitOfPEIdentity(region)] == '1' then
                if TileLogicalElementDefined(tile,
                    element as PackedTileElementIndex) then
                    updated.tile = TileInfoWithLogicalElement(updated.tile,
                        element as PackedTileElementIndex,
                        TileReadLogicalElement(tile,
                            element as PackedTileElementIndex));
                end;
            end;
        end;
        updated.initialized_mask = old.initialized_mask OR pe_mask;
        // Internal multi-PE B.ASSEMBLE candidates use disjoint writer regions.
        // Once their declared participant set has supplied all regions, the
        // candidate descriptor/payload snapshot is complete for LAST.
        updated.tile.contents_defined =
            updated.initialized_mask == updated.allocation_mask;
        if updated.tile.contents_defined then
            updated.tile.defined_valid_elements =
                (updated.tile.valid_rows * updated.tile.valid_columns)
                    as integer {0..524288};
        end;
        let direct_complete = pe_mask == '1111';
        updated.whole_parent_ready = old.whole_parent_ready ||
            (publish && direct_complete && updated.tile.contents_defined);
        updated.published = old.published ||
            (publish && direct_complete && updated.tile.contents_defined);
        if publish && direct_complete && updated.tile.contents_defined then
            updated.payload_live = TRUE;
            updated.payload_generation = old.payload_generation + 1;
        end;
    end;
    _SharedTiles[[index]] = updated;
    return TRUE;
end;

func AtomicUpdateSharedTile(shared_tile_id: SharedTileID, tile: TileInfo,
                            pe_mask: bits(4)) => boolean
begin
    return AtomicUpdateSharedTileWithPublication(
        shared_tile_id, tile, pe_mask, TRUE);
end;

func InstallSharedTile(shared_tile_id: SharedTileID, tile: TileInfo, pe_mask: bits(4))
begin
    let updated = AtomicUpdateSharedTile(shared_tile_id, tile, pe_mask);
    assert updated;
end;
```
<!-- GENERATED-ASL-END: unit -->
