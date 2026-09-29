<!-- GENERATED FROM: asl/tile/model/memory/shared-movement.asl -->
# Shared Movement

**Normative ASL source:** `asl/tile/model/memory/shared-movement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-purpose role=purpose-scope -->
## 作用与范围

本单元拥有涉及 Shared Tile 寄存器或多个 PE 的数据移动，以及 Local 复制辅助函数 `TMOV` 与 `GMOV`。

- `TLOADShared` 以每 PE 的基地址与步长把 GM 加载到 Shared Tile 记录中。
- `TSTOREShared` 与 `TSTORESharedPerPE` 从每个被选中的 PE 把 Shared Tile 存储到 GM。
- `TMOVLocalToShared` 把 Local Tile 复制到 Shared 记录中。
- `TMOVSharedToLocal` 与 `TMOVSharedToLocalPerPE` 把 Shared 数据复制到 Local Tile。
- `TMOV` 把一个 Local Tile 复制到另一个；`GMOV` 把对等快照复制到 Local Tile。

它还定义 `ScatterLaneOrder` 与 `CorePETileInfos`，这两个类型由索引执行体与每 PE 执行体使用。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-concepts role=concepts-state -->
## 概念与可见状态

一个 Core 有四个 PE。`PE_MASK` 为四位，PE `p` 对应位 `3 - p`（`PTOPEMaskBitOfPEIdentity`），因此 `1000` 表示 PE0。

Shared Tile 被划分为四个字节四分区。`SharedTileElementRegion` 返回元素所在的四分区：其字节偏移乘以 4，除以容量，向下取整。在多 PE 加载中，四分区 `q` 由 PE `q` 使用该 PE 的基地址与步长加载。

单发起者加载恰好置位一个掩码位。该 PE 加载每个有效元素。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-rules role=rules-interactions -->
## 规则与交互

在每个 Shared 辅助函数中，`PE_MASK=0000` 都在任何检查之前立即返回。

`TLOADShared` 构建一个新的描述符；如果形状不适合尺寸码，或与现有记录不兼容，则产生 `Fault_TileLegality`。然后它以字节步长寻址加载每个被选中的有效元素，并为执行加载的 PE 记录加载事件。只有单发起者或掩码 `1111` 时它才把内容标记为完整，并通过 `AtomicUpdateSharedTile` 安装记录。

设计要点：`AtomicUpdateSharedTileWithPublication` 以一次完整的记录赋值改变 Shared 记录，ASL 将其称为架构提交点。`TLOADShared` 在本地副本中构建候选记录，并以一次这样的更新安装它，因此不会看到赋值到一半的记录。

在逐元素加载循环中发生探测故障时，`TLOADShared` 安装到目前为止构建的记录并返回；故障之前完成的加载保留在该记录中。

`TSTOREShared` 按 0 到 3 的顺序访问被选中的 PE，并从每个 PE 自己的基地址与步长存储完整有效区域。第一次故障停止整个请求；已完成的存储保持可见。

设置了 `publish` 的 `TMOVLocalToShared` 要求预期记录已完全初始化，否则产生 `Fault_TileLegality`。

`TMOVSharedToLocal` 要求描述符完全匹配，并复制每个物理元素。每个参与的消费者看到同一个完整父对象；掩码选择消费者，而不是四分区。

`TMOV` 把载荷与已定义性从源复制到目标。在 ExecutionMask 下，非活动的有效坐标得到掩码的零值或合并值。

`GMOV` 断言 `peer_tid < 4`，并从快照复制载荷与已定义性；它不进行 Shared 或 GM 访问。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-boundaries role=boundaries -->
## 架构边界

在调用这些辅助函数之前，Shared-TLSU 块分派器解析每 PE 的 GPR、子视图与 Shared 就绪状态，并在 `TLOADShared` 前后处理 `B.ASSEMBLE` 生成候选。shared-registers 单元拥有记录字段、兼容性与发布规则。

这些辅助函数采用首故障即停行为。它们不会先探测整个访问范围。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-example role=example-usage -->
## 非规范阅读示例

某 Shared FP32 Tile 容量为 4096 字节。元素 700 的位偏移为 700 x 32 = 22400，即字节 2800。

- 它的四分区为 2800 x 4 / 4096 = 2（向下取整），因此由 PE2 拥有。
- PE2 对应掩码位 3 - 2 = 1，因此多 PE 掩码 `PE_MASK=0011` 选中该元素，而 `0101` 不选中。
- 当 `PE_MASK=1111` 时，PE2 从 PE2 的基地址加上行号乘以 PE2 的步长、再加上列号乘以 4 处加载它。

只有 `PE_MASK=0010` 时，加载是单发起者，因此 PE2 加载全部有效元素，包括元素 700。

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-related role=related-owners-navigation -->
## 相关归属

- [Shared registers](../state/shared-registers.md) 拥有 Shared 记录及其发布。
- [Stride](stride.md) 拥有字节步长地址。
- [Load and store](load-store.md) 拥有 Local 形式与探测。
- [Shared TLSU dispatch](../../../block/model/dispatch/shared-tlsu.md) 调用这些辅助函数。
- [Global memory access](../../../arch/memory-model/global-memory-access.md) 拥有 GM 访问规则。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/shared-movement.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT","surface":"tile","classification":["model","memory","shared-movement"],"depends_on":["PTO-TILE-MODEL-STATE-SHARED-REGISTERS","PTO-SCALAR-MODEL-AGU-MEMORY","PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA"]}
// PTO-REQ-TLSU-001, PTO-REQ-MEMORY-COMPLETION-001,
// PTO-REQ-MEMORY-RC-001: precise, restartable direct
// TLOAD/TSTORE/MGATHER/MSCATTER and destination-free TPREFETCH.

type ScatterLaneOrder of array [[PTO_MODEL_TILE_ELEMENTS]] of Word;
type CorePETileInfos of array [[PTO_MODEL_MEMORY_AGENTS]] of TileInfo;

readonly func SharedTileElementRegion(tile: TileInfo,
                                  element: PackedTileElementIndex)
                                  => integer {0..3}
begin
    let bit_offset: integer = element * TileElementBits(tile.data_type);
    let byte_offset: integer = bit_offset DIVRM 8;
    assert byte_offset < tile.capacity_bytes;
    return ((byte_offset * 4) DIVRM tile.capacity_bytes)
        as integer {0..3};
end;

func SharedTileFromLocal(source: TileIndex,
                         capacity_bytes: integer {128,256,512,1024,2048,4096,8192,
                                                  16384,32768,65536,131072,
                                                  262144})
                         => TileInfo
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated && source_tile.contents_defined;
    assert source_tile.capacity_bytes == capacity_bytes;
    var result = source_tile;
    return result;
end;

func TMOVLocalToShared(shared_tile_id: SharedTileID, source: TileIndex,
                       size_code: integer {1..12}, pe_mask: bits(4),
                       publish: boolean)
begin
    if pe_mask == Zeros{4} then return; end;
    let capacity_bytes = TileSizeCodeBytes(size_code);
    let shared_tile = SharedTileFromLocal(source, capacity_bytes);
    if publish && !SharedTileProspectiveFullyInitialized(
            shared_tile_id, shared_tile, pe_mask) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    let updated = AtomicUpdateSharedTileWithPublication(
        shared_tile_id, shared_tile, pe_mask, publish);
    if !updated then SetFault(Fault_TileLegality, ReadTPC()); end;
end;

func TMOVSharedToLocal(destination: TileIndex, shared_tile_id: SharedTileID,
                       shared_tile: TileInfo, pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    let destination_tile = _Tiles[[destination]];
    assert destination_tile.capacity_bytes == shared_tile.capacity_bytes;
    assert destination_tile.rows == shared_tile.rows &&
           destination_tile.columns == shared_tile.columns &&
           destination_tile.valid_rows == shared_tile.valid_rows &&
           destination_tile.valid_columns == shared_tile.valid_columns &&
           destination_tile.data_type == shared_tile.data_type &&
           destination_tile.layout == shared_tile.layout;
    // PE_MASK selects consumer PEs, not payload quarters. Every participating
    // consumer observes the same complete published parent when no B.SUBVIEW
    // narrows the source range.
    for element = 0 to shared_tile.rows * shared_tile.columns - 1
        looplimit 524288 do
        _Tiles[[destination]] = TileInfoWithLogicalElement(
            _Tiles[[destination]], element as PackedTileElementIndex,
            ReadSharedTileWord(shared_tile_id,
                element as PackedTileElementIndex));
    end;
    _Tiles[[destination]].contents_defined = TRUE;
    MarkTileValidRegionDefined(destination);
end;

func TLOADShared(shared_tile_id: SharedTileID, base_addresses: CorePEWords,
                 row_stride_bytes: CorePEWords,
                 size_code: integer {1..12},
                 rows: integer {1..65535}, columns: integer {1..65535},
                 valid_rows: integer {1..65535},
                 valid_columns: integer {1..65535},
                 data_type: TileDataType, layout: TileLayout,
                 pe_mask: bits(4))
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    if pe_mask == Zeros{4} then return; end;
    let capacity_bytes = TileSizeCodeBytes(size_code);
    if rows < valid_rows || rows >
           DerivedTileRows(capacity_bytes, columns, data_type) ||
       !TileDescriptorShapeLegal(capacity_bytes, columns, valid_rows,
           valid_columns, data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    let derived_rows = DerivedTileRows(capacity_bytes, columns, data_type);
    if derived_rows * columns >
           TileLogicalElementCapacity(capacity_bytes, data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    var tile: TileInfo;
    tile.allocated = TRUE;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.defined_valid_elements = 0;
    tile.packed_defined_elements = zero_packed_tile_elements;
    tile.capacity_bytes = capacity_bytes;
    tile.rows = derived_rows;
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
    if !SharedTileUpdateCompatible(shared_tile_id, tile, pe_mask) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    let single_issuer = PEMaskPopulation(pe_mask) == 1;
    var single_agent: MemoryAgentId = 0;
    if single_issuer then
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
                single_agent = agent;
            end;
        end;
    end;
    // The maximum packed witness uses zero byte stride and a fresh Shared
    // record. Check every participating issuer through the ordinary
    // translated probe before publishing the complete carrier state.
    var packed_zero_fast = PackedTileDataTypeIsFourBit(tile.data_type) &&
        !_MemoryEventCaptureEnabled &&
        !SharedTileRecord(shared_tile_id).descriptor_valid &&
        tile.valid_rows == tile.rows &&
        tile.valid_columns == tile.columns &&
        tile.rows * tile.columns ==
            PackedTileLogicalCapacity(tile.capacity_bytes, tile.data_type) &&
        tile.capacity_bytes == 262144;
    if packed_zero_fast then
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' &&
               (base_addresses[[agent]] != Zeros{PTO_XLEN} ||
                row_stride_bytes[[agent]] != Zeros{PTO_XLEN}) then
                packed_zero_fast = FALSE;
            end;
        end;
    end;
    if packed_zero_fast then
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
                for column = 0 to tile.valid_columns - 1 looplimit 65536 do
                    let address = TileMemoryStridedByteAddress(
                        base_addresses[[agent]], 0,
                        column as integer {0..65535},
                        row_stride_bytes[[agent]], tile.data_type);
                    let probe = ProbeTileMemoryAccess(address,
                        tile.data_type, FALSE);
                    if RaiseDataAccessFault(probe, address) then return; end;
                    if LoadTranslatedUnsigned(probe.translated_address,
                           TileMemoryElementBytes(tile.data_type)) !=
                           Zeros{PTO_XLEN} then
                        packed_zero_fast = FALSE;
                    end;
                end;
            end;
        end;
    end;
    if packed_zero_fast then
        let payload_mask = if single_issuer then '1111' else pe_mask;
        tile = TileWithPackedZeroSelectedMaxRegionDefined(tile, payload_mask);
        let updated = AtomicUpdateSharedTile(shared_tile_id, tile, pe_mask);
        assert updated;
        return;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let region = SharedTileElementRegion(tile, element);
            let selected = single_issuer ||
                pe_mask[PTOPEMaskBitOfPEIdentity(region)] == '1';
            if selected then
                let agent = if single_issuer then single_agent
                    else region as MemoryAgentId;
                let high_nibble = TileMemoryStridedByteHighNibble(
                    column as integer {0..65535}, tile.data_type);
                let address = TileMemoryStridedByteAddress(
                    base_addresses[[agent]], row as integer {0..65535},
                    column as integer {0..65535},
                    row_stride_bytes[[agent]], tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    tile.data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then
                    let updated = AtomicUpdateSharedTile(shared_tile_id,
                        tile, pe_mask);
                    assert updated;
                    return;
                end;
                let translated = probe.translated_address;
                let raw = LoadTranslatedUnsigned(translated,
                    TileMemoryElementBytes(tile.data_type));
                RecordLoadEventForAgent(agent, translated,
                    TileMemoryElementBytes(tile.data_type), raw,
                    CurrentBundleMemoryOrder());
                tile = TileInfoWithLogicalElement(tile, element,
                    LoadTileMemoryElement(translated, tile.data_type,
                        high_nibble));
                tile.defined_valid_elements =
                    (tile.defined_valid_elements + 1)
                        as integer {0..524288};
            end;
        end;
    end;
    if single_issuer || pe_mask == '1111' then
        tile.defined_valid_elements =
            (tile.valid_rows * tile.valid_columns) as integer {0..524288};
        tile.contents_defined = TRUE;
    end;
    let updated = AtomicUpdateSharedTile(shared_tile_id, tile, pe_mask);
    assert updated;
end;

func TSTOREShared(base_addresses: CorePEWords,
                  row_stride_bytes: CorePEWords,
                  shared_tile_id: SharedTileID,
                  tile: TileInfo,
                  pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    assert tile.allocated;
    // PE_MASK selects consumer PEs. The first fault stops the request and
    // stores completed before it remain visible.
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
            for row = 0 to tile.valid_rows - 1 looplimit 65536 do
                for column = 0 to tile.valid_columns - 1 looplimit 65536 do
                    let element = TileLogicalLinearIndex(tile,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    let address = TileMemoryStridedByteAddress(
                        base_addresses[[agent]], row as integer {0..65535},
                        column as integer {0..65535},
                        row_stride_bytes[[agent]], tile.data_type);
                    let probe = ProbeTileMemoryAccess(address,
                        tile.data_type, TRUE);
                    if RaiseDataAccessFault(probe, address) then return; end;
                    let translated = probe.translated_address;
                    let stored_value = StoreTileMemoryElement(
                        address, translated, tile.data_type,
                        TileMemoryStridedByteHighNibble(
                            column as integer {0..65535}, tile.data_type),
                        TileReadLogicalElement(tile, element));
                    RecordStoreEventForAgent(agent, translated,
                        TileMemoryElementBytes(tile.data_type), stored_value,
                        CurrentBundleMemoryOrder());
                end;
            end;
        end;
    end;
end;


func TMOVSharedToLocalPerPE(destination: TileIndex,
                           per_pe_tiles: CorePETileInfos,
                           pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
            let source_tile = per_pe_tiles[[agent]];
            let destination_tile = _Tiles[[destination]];
            assert source_tile.allocated && source_tile.contents_defined;
            assert destination_tile.capacity_bytes == source_tile.capacity_bytes;
            assert destination_tile.rows == source_tile.rows &&
                   destination_tile.columns == source_tile.columns &&
                   destination_tile.valid_rows == source_tile.valid_rows &&
                   destination_tile.valid_columns == source_tile.valid_columns &&
                   destination_tile.data_type == source_tile.data_type &&
                   destination_tile.layout == source_tile.layout;
            for element = 0 to source_tile.rows * source_tile.columns - 1
                looplimit 524288 do
                let value = TileReadLogicalElement(source_tile,
                    element as PackedTileElementIndex);
                _Tiles[[destination]] = TileInfoWithLogicalElement(
                    _Tiles[[destination]],
                    element as PackedTileElementIndex, value);
            end;
        end;
    end;
    _Tiles[[destination]].contents_defined = pe_mask == '1111';
    if pe_mask == '1111' then MarkTileValidRegionDefined(destination); end;
end;

func TSTORESharedPerPE(base_addresses: CorePEWords,
                       row_stride_bytes: CorePEWords,
                       per_pe_tiles: CorePETileInfos,
                       pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
            let tile = per_pe_tiles[[agent]];
            assert tile.allocated && tile.contents_defined;
            for row = 0 to tile.valid_rows - 1 looplimit 65536 do
                for column = 0 to tile.valid_columns - 1 looplimit 65536 do
                    let address = TileMemoryStridedByteAddress(
                        base_addresses[[agent]], row as integer {0..65535},
                        column as integer {0..65535},
                        row_stride_bytes[[agent]], tile.data_type);
                    let probe = ProbeTileMemoryAccess(address,
                        tile.data_type, TRUE);
                    if RaiseDataAccessFault(probe, address) then return; end;
                    let translated = probe.translated_address;
                    let stored_value = StoreTileMemoryElement(
                        address, translated, tile.data_type,
                        TileMemoryStridedByteHighNibble(
                            column as integer {0..65535}, tile.data_type),
                        TileReadLogicalElement(tile,
                            TileLogicalLinearIndex(tile,
                                row as integer {0..65535},
                                column as integer {0..65535})));
                    RecordStoreEventForAgent(agent, translated,
                        TileMemoryElementBytes(tile.data_type), stored_value,
                        CurrentBundleMemoryOrder());
                end;
            end;
        end;
    end;
end;

func TMOV(destination: TileIndex, source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated;
    assert TileShapesMatch(_Tiles[[destination]], source_tile);
    if _BundleExecutionMask.valid then
        assert TileElementwiseSourceContentsDefined(source);
    end;
    _Tiles[[destination]].payload = source_tile.payload;
    _Tiles[[destination]].defined_elements = source_tile.defined_elements;
    _Tiles[[destination]].packed_defined_elements =
        source_tile.packed_defined_elements;
    _Tiles[[destination]].defined_valid_elements =
        source_tile.defined_valid_elements;
    _Tiles[[destination]].contents_defined = source_tile.contents_defined;
    if _BundleExecutionMask.valid then
        var result = _Tiles[[destination]];
        for row = 0 to result.valid_rows - 1 looplimit 65536 do
            for column = 0 to result.valid_columns - 1 looplimit 65536 do
                if !BundleExecutionMaskActiveAt(
                       result.layout, row as integer {0..65535},
                       column as integer {0..65535}) then
                    let element = TileLogicalLinearIndex(result,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    result = TileInfoWithLogicalElementAndDefined(
                        result, element,
                        BundleExecutionMaskDestinationValue(
                            result.layout, row as integer {0..65535},
                            column as integer {0..65535}, Zeros{PTO_XLEN}),
                        TRUE);
                end;
            end;
        end;
        result = TileWithValidRegionDefined(result);
        _Tiles[[destination]] = result;
    end;
end;

// The direct-operation carrier binds source to the Core4 snapshot already
// resolved from the four PE-private peer_tid values.  The bundle dispatcher
// performs collective readiness and peer-range preflight before this read-old,
// write-new local copy.  No Shared register or global-memory event is involved.
func GMOV(destination: TileIndex, source: TileIndex, peer_tid: Word)
begin
    assert UInt(peer_tid) < 4;
    let source_tile = _Tiles[[source]];
    let source_payload = source_tile.payload;
    _Tiles[[destination]].payload = source_payload;
    _Tiles[[destination]].defined_elements = source_tile.defined_elements;
    _Tiles[[destination]].packed_defined_elements =
        source_tile.packed_defined_elements;
    _Tiles[[destination]].defined_valid_elements =
        source_tile.defined_valid_elements;
    _Tiles[[destination]].contents_defined = source_tile.contents_defined;
end;
```
<!-- GENERATED-ASL-END: unit -->
