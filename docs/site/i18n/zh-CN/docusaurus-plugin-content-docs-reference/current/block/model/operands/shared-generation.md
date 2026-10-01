<!-- GENERATED FROM: asl/block/model/operands/shared-generation.asl -->
# Shared Generation

**Normative ASL source:** `asl/block/model/operands/shared-generation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-purpose role=purpose-scope -->
## 用途与范围

本单元拥有 Shared 代次和 Shared subview。Shared 代次是由一个或多个写者通过 `B.ASSEMBLE` 构建的 Shared Tile。Shared subview 是已发布 Shared Tile 的一个 `B.SUBVIEW` 范围，每个 PE 可以把它放在不同位置。

本单元验证写者范围，把每个写者的载荷合并到一个工作副本中，并在 LAST 时发布完整的对象。

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-concepts role=concepts-state -->
## 概念与可见状态

本单元更新一个 Shared Tile ID 的 `_SharedGenerations` 记录，并在 LAST 时更新已发布的 `_SharedTiles` 条目。

覆盖以 32 字节为单位跟踪，一个位图有 8192 个单位。普通 `B.ASSEMBLE` 的偏移和大小码以 128 字节的 CELL 为单位，包装函数将其乘以 4。ASL 注释说明了原因：更细的单位让专用的整行生产者能够表达 TIMG2COL 的行范围，而无需部分 CELL 规则。权重 `TLOAD` 也通过同一个范围入口提交。

`BundleSharedGenerationCapacity` 返回绑定的大小码；对重用目标，返回该代次的 `parent_size_code`。

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-rules role=rules-interactions -->
## 规则与交互

只有在以下条件都满足时，`ValidateBundleSharedGenerationRange` 才接受一个写者：

- INIT 指名一个大小码为 1..12 的目标，且该 ID 尚无打开的代次；
- 延续指名一个打开且未关闭代次的重用目标，参与者掩码相同，对专用生产者还要求输入和元数据相同；
- 到达的 PE 是掩码的一个非空子集；
- 范围位于父 Tile 内，对延续还要求不与任何已覆盖单位重叠；
- 在 LAST 时，每个父单位都已覆盖，且每个参与者都已到达。

`ValidateBundleSharedGeneration` 在第 2 阶段准备中对普通写者应用此检查，以整个绑定掩码作为到达集合。

`CommitBundleSharedGenerationCandidateRange` 重复该验证。INIT 复位记录，并以父级容量、无已定义元素的方式从候选 Tile 开始一个工作 Tile。延续要求列数、数据类型和布局一致。候选 Tile 的已定义元素被复制到工作 Tile 中写者偏移处，有效区域扩展以覆盖它们。覆盖、就绪和到达被更新。在 LAST 时，工作 Tile 在同一提交步骤中成为已发布的 Shared Tile。

设计要点：`CommitBundleSharedGenerationCandidateRange` 只在 LAST 时写入 `_SharedTiles`；更早的调用只改变代次记录。NDF `PTO-B-ASSEMBLE-SHARED-GENERATION-001` 要求发布原子地替换描述符和载荷，并要求每次拒绝都保留先前已发布的代次。

设计要点：参与者到达与覆盖分开跟踪。专用的协作生产者每个写者只传入一个 PE 的到达位，行数为零的 PE 可以在不写入任何单元的情况下到达，因此集体操作仍然可以关闭。

`BeginBundleSharedGenerationProbe` 在 Shared `TLOAD` 或 Local 到 Shared 的 `TMOV` 构建候选 Tile 时保存并隐藏已发布的记录。在 `TLOAD` 的无故障路径上，以及对 `TMOV` 总是，`RestoreBundleSharedGenerationProbe` 在提交之前把它放回。Shared TLSU 的注释说明，发生第一个故障后，候选记录保留在原处，既不就绪也不发布。

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-boundaries role=boundaries -->
## 架构边界

`BundleSharedSubviewLegal` 要求一个大小码为 0 的源绑定指向一个已发布的非 CUBE Shared Tile。对每个选中的 PE，它在该 PE 自己的寄存器中计算 `GPR[RegSrc] + uimm11`，然后要求该范围位于父 Tile 内，并且要么在一行之内，要么是从第 0 列开始的整行。`MaterializeBundleSharedSubviewForPE` 构建该 PE 的视图。任何一个不合法的视图都会拒绝整个操作。

当 Tile 操作失败时，`AbortBundleSharedGenerationsForBundle` 中止该指令束涉及的每个代次。

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

Shared Tile 3 由两个掩码为 `1111` 的普通写者指令束构建，父级大小码为 7（8192 字节，64 个 CELL，256 个单位）。指令束 A 带 INIT，写者大小码为 6（32 个 CELL），偏移为 0。A 之后，单位 0..127 已覆盖，四个 PE 都已到达，因为普通写者以其整个掩码到达。指令束 B 带 LAST，写者大小码为 6，偏移为 32，覆盖单位 128..255。此时覆盖完整，工作 Tile 替换 Shared Tile 3。如果 B 改用偏移 16，其范围会与已覆盖单位重叠，B 会以 `Fault_TileLegality` 故障，打开的代次会被中止，任何先前已发布的 Shared Tile 3 会保持已发布状态。

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-related role=related-owners-navigation -->
## 相关所有者

- [Shared 代次状态](../state/shared-generation-state.md)清除、复位和中止记录。
- [Shared 绑定](shared-bindings.md)定义重用目标。
- [Shared TLSU](../dispatch/shared-tlsu.md)、[TIMG2COL 执行](../dispatch/timg2col-execution.md)和[权重到 Shared 执行](../dispatch/weight-to-shared-execution.md)提交候选 Tile。
- [B.ASSEMBLE](../../operands/B.ASSEMBLE.md) 是命令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/shared-generation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","surface":"block","classification":["model","operands","shared-generation"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS","PTO-BLOCK-MODEL-STATE-SHARED-GENERATION"]}
// NDF-BEGIN: PTO-B-ASSEMBLE-SHARED-GENERATION-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A Shared B.ASSEMBLE generation MUST retain the previously published Sx
// object until the matching collective LAST has complete non-overlapping CELL
// coverage, all declared writer data is ready, every participating PE reaches
// the same generation ordinal with matching metadata, and no participant has
// faulted or been squashed.  Publication MUST replace the complete Shared
// descriptor and payload atomically; every rejection MUST preserve the prior
// published generation.
// NDF-END: PTO-B-ASSEMBLE-SHARED-GENERATION-001
// NDF-BEGIN: PTO-B-SUBVIEW-SHARED-PER-PE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A Shared B.SUBVIEW source MUST evaluate GPR[RegSrc]+uimm11 in each
// participating PE's private GPR context. The encoded size is common, but
// selected PEs may materialize distinct ranges of one published parent.
// Matrix consumers derive/validate each selected view's metadata before any
// payload snapshot or destination allocation; one bad view rejects the whole operation.
// NDF-END: PTO-B-SUBVIEW-SHARED-PER-PE-001
readonly func BundleSharedGenerationCapacity(binding: BundleSharedBindingIndex) => integer {0..12}
begin
    if !BundleSharedBindingIsReusedDestination(binding) then return _BundleSharedBindings[[binding]].size_code; end;
    return _SharedGenerations[[SharedTileArrayIndex(_BundleSharedBindings[[binding]].shared_tile_id)]].parent_size_code;
end;
func AbortBundleSharedGenerationsForBundle()
begin
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid then
            AbortBundleSharedGeneration(
                _BundleSharedBindings[[binding]].shared_tile_id);
        end;
    end;
end;
// Shared generation coverage is tracked internally in 32-byte units. Ordinary
// B.ASSEMBLE offsets and SizeCodes remain 128-byte Tile CELL quantities and
// the compatibility wrappers below expand each such CELL to four units. The
// finer internal granularity lets specialized complete-row producers express
// the frozen TIMG2COL row ranges without inventing partial generic CELL rules.
readonly func BundleSharedGenerationCoverageWithCurrent(
    shared_tile_id: SharedTileID,
    offset_cells: integer {0..8192},
    coverage_cells: integer {0..8192},
    init: boolean) => bits(8192)
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    var covered = if init then Zeros{8192}
        else _SharedGenerations[[index]].covered_cells;
    for cell = 0 to 8191 do
        if cell < coverage_cells then
            covered[offset_cells + cell] = '1';
        end;
    end;
    return covered;
end;
// A specialized collective may contribute fewer physical cells than the
// size-coded carrier and may contribute no cells at all.  Participant arrival
// remains independent of CELL coverage so a zero-row PE can complete the
// collective without writing payload or definedness.
readonly func ValidateBundleSharedGenerationRange(
    binding: BundleSharedBindingIndex,
    offset_cells: integer {0..8192},
    coverage_cells: integer {0..8192},
    participant_arrival: bits(4),
    specialized_inputs_valid: boolean,
    specialized_input0: Word, specialized_input1: Word, specialized_input2: Word,
    specialized_input3: Word, specialized_metadata: Word) => boolean
begin
    if !_BundleSharedBindings[[binding]].valid ||
       !_BundleSharedBindings[[binding]].destination_assemble.valid then
        return FALSE;
    end;
    let shared_tile_id = _BundleSharedBindings[[binding]].shared_tile_id;
    let index = SharedTileArrayIndex(shared_tile_id);
    let assemble = _BundleSharedBindings[[binding]].destination_assemble;
    let participant_mask = _BundleSharedBindings[[binding]].pe_mask;
    if assemble.init && _BundleSharedBindings[[binding]].size_code == 0 then return FALSE; end;
    if !assemble.init && !BundleSharedBindingIsReusedDestination(binding) then return FALSE; end;
    if participant_arrival == Zeros{4} ||
       (participant_arrival AND participant_mask) != participant_arrival then
        return FALSE;
    end;
    if assemble.init && _SharedGenerations[[index]].open then
        return FALSE;
    end;
    if !assemble.init &&
       (!_SharedGenerations[[index]].open ||
        _SharedGenerations[[index]].closed) then
        return FALSE;
    end;
    if !assemble.init &&
       _SharedGenerations[[index]].participant_mask != participant_mask then
        return FALSE;
    end;
    if !assemble.init &&
       (_SharedGenerations[[index]].specialized_inputs_valid !=
            specialized_inputs_valid ||
        (specialized_inputs_valid &&
         (_SharedGenerations[[index]].specialized_input0 != specialized_input0 ||
          _SharedGenerations[[index]].specialized_input1 != specialized_input1 ||
          _SharedGenerations[[index]].specialized_input2 != specialized_input2 ||
          _SharedGenerations[[index]].specialized_input3 != specialized_input3 ||
          _SharedGenerations[[index]].specialized_metadata != specialized_metadata))) then
        return FALSE;
    end;
    if assemble.init &&
       (_BundleSharedBindings[[binding]].size_code < 1 ||
        _BundleSharedBindings[[binding]].size_code > 12) then
        return FALSE;
    end;
    let parent_cells = if assemble.init then
        BundleLocalGenerationCellCount(
            _BundleSharedBindings[[binding]].size_code as integer {1..12}) * 4
        else _SharedGenerations[[index]].parent_cell_count;
    if offset_cells + coverage_cells > parent_cells then return FALSE; end;
    if !assemble.init then
        for cell = 0 to 8191 do
            if cell < coverage_cells &&
               _SharedGenerations[[index]].covered_cells[
                   offset_cells + cell] == '1' then
                return FALSE;
            end;
        end;
    end;
    if assemble.last then
        let covered = BundleSharedGenerationCoverageWithCurrent(
            shared_tile_id, offset_cells, coverage_cells, assemble.init);
        for cell = 0 to 8191 do
            if cell < parent_cells && covered[cell] == '0' then
                return FALSE;
            end;
        end;
        let arrived = (if assemble.init then Zeros{4}
            else _SharedGenerations[[index]].arrived_participants) OR
            participant_arrival;
        if arrived != participant_mask then return FALSE; end;
    end;
    return TRUE;
end;
readonly func ValidateBundleSharedGeneration() => boolean
begin
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid then
            let shared_tile_id =
                _BundleSharedBindings[[binding]].shared_tile_id;
            let index = SharedTileArrayIndex(shared_tile_id);
            let assemble =
                _BundleSharedBindings[[binding]].destination_assemble;
            let writer_size = assemble.size_code;
            let participant_mask = _BundleSharedBindings[[binding]].pe_mask;
            if writer_size < 1 || writer_size > 12 then return FALSE; end;
            if assemble.init && _BundleSharedBindings[[binding]].size_code == 0 then return FALSE; end;
            if !assemble.init && !BundleSharedBindingIsReusedDestination(binding) then return FALSE; end;
            if assemble.init && _SharedGenerations[[index]].open then
                return FALSE;
            end;
            if !assemble.init &&
               (!_SharedGenerations[[index]].open ||
                _SharedGenerations[[index]].closed) then
                return FALSE;
            end;
            if !assemble.init &&
               _SharedGenerations[[index]].participant_mask !=
                   participant_mask then
                return FALSE;
            end;
            let raw_offset = UInt(assemble.offset);
            if raw_offset > 2047 then return FALSE; end;
            let offset_cells = (raw_offset * 4) as integer {0..8188};
            let writer_cells = (BundleLocalGenerationCellCount(
                writer_size as integer {1..12}) * 4) as integer {4..8192};
            if !ValidateBundleSharedGenerationRange(binding, offset_cells,
                   writer_cells, participant_mask, FALSE,
                   Zeros{PTO_XLEN}, Zeros{PTO_XLEN},
                   Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, Zeros{PTO_XLEN}) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;
func CommitBundleSharedGenerationCandidateRange(
    binding: BundleSharedBindingIndex, candidate: SharedTileInfo,
    offset_cells: integer {0..8192},
    coverage_cells: integer {0..8192},
    payload_cells: integer {0..8192},
    participant_arrival: bits(4),
    specialized_inputs_valid: boolean,
    specialized_input0: Word, specialized_input1: Word, specialized_input2: Word,
    specialized_input3: Word, specialized_metadata: Word) => boolean
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid;
    let shared_tile_id = _BundleSharedBindings[[binding]].shared_tile_id;
    let index = SharedTileArrayIndex(shared_tile_id);
    let assemble = _BundleSharedBindings[[binding]].destination_assemble;
    let participant_mask = _BundleSharedBindings[[binding]].pe_mask;
    if !candidate.descriptor_valid ||
       candidate.allocation_mask != participant_mask ||
       payload_cells > coverage_cells ||
       !ValidateBundleSharedGenerationRange(binding, offset_cells,
           coverage_cells, participant_arrival, specialized_inputs_valid,
           specialized_input0, specialized_input1,
           specialized_input2, specialized_input3, specialized_metadata) then
        return FALSE;
    end;
    if assemble.init then
        let parent_size = _BundleSharedBindings[[binding]].size_code as integer {1..12};
        let parent_bytes = TileSizeCodeBytes(parent_size);
        let parent_rows = DerivedTileRows(
            parent_bytes, candidate.tile.columns, candidate.tile.data_type);
        if parent_rows == 0 then return FALSE; end;
        _SharedGenerations[[index]].open = TRUE;
        _SharedGenerations[[index]].closed = FALSE;
        _SharedGenerations[[index]].published = FALSE;
        _SharedGenerations[[index]].shared_tile_id = shared_tile_id;
        _SharedGenerations[[index]].participant_mask = participant_mask;
        _SharedGenerations[[index]].parent_size_code = parent_size;
        _SharedGenerations[[index]].parent_cell_count =
            BundleLocalGenerationCellCount(parent_size) * 4;
        _SharedGenerations[[index]].covered_cells = Zeros{8192};
        _SharedGenerations[[index]].ready_cells = Zeros{8192};
        _SharedGenerations[[index]].arrived_participants = Zeros{4};
        _SharedGenerations[[index]].specialized_inputs_valid =
            specialized_inputs_valid;
        _SharedGenerations[[index]].specialized_input0 = specialized_input0;
        _SharedGenerations[[index]].specialized_input1 = specialized_input1;
        _SharedGenerations[[index]].specialized_input2 = specialized_input2;
        _SharedGenerations[[index]].specialized_input3 = specialized_input3;
        _SharedGenerations[[index]].specialized_metadata = specialized_metadata;
        _SharedGenerations[[index]].last_seen = FALSE;
        _SharedGenerations[[index]].working_valid = TRUE;
        _SharedGenerations[[index]].working_tile = candidate.tile;
        _SharedGenerations[[index]].working_tile.capacity_bytes = parent_bytes;
        _SharedGenerations[[index]].working_tile.rows = parent_rows;
        _SharedGenerations[[index]].working_tile.contents_defined = FALSE;
        _SharedGenerations[[index]].working_tile.defined_elements =
            Zeros{PTO_MODEL_TILE_ELEMENTS};
        _SharedGenerations[[index]].working_tile.packed_defined_elements =
            zero_packed_tile_elements;
        _SharedGenerations[[index]].working_tile.defined_valid_elements = 0;
        _SharedGenerations[[index]].working_initialized_mask = Zeros{4};
    else
        if !_SharedGenerations[[index]].working_valid ||
           _SharedGenerations[[index]].working_tile.columns !=
               candidate.tile.columns ||
           _SharedGenerations[[index]].working_tile.data_type !=
               candidate.tile.data_type ||
           _SharedGenerations[[index]].working_tile.layout !=
               candidate.tile.layout then
            return FALSE;
        end;
    end;
    if payload_cells != 0 then
        let element_bits = TileElementBits(candidate.tile.data_type);
        let destination_offset = ((offset_cells * 32 * 8) DIVRM element_bits)
            as integer {0..524287};
        let source_elements = ((payload_cells * 32 * 8) DIVRM element_bits)
            as integer {1..524288};
        let parent_elements = TileLogicalElementCapacity(
            _SharedGenerations[[index]].working_tile.capacity_bytes,
            candidate.tile.data_type);
        if destination_offset + source_elements > parent_elements then
            return FALSE;
        end;
        if candidate.tile.valid_rows == 0 ||
           candidate.tile.valid_columns == 0 then
            return FALSE;
        end;
        var working = _SharedGenerations[[index]].working_tile;
        for element = 0 to source_elements - 1 looplimit 524288 do
            let source_index = element as PackedTileElementIndex;
            let destination_index = (destination_offset + element)
                as PackedTileElementIndex;
            if TileLogicalElementDefined(candidate.tile, source_index) then
                working = TileInfoWithLogicalElement(
                    working, destination_index,
                    TileReadLogicalElement(candidate.tile, source_index));
            end;
        end;
        _SharedGenerations[[index]].working_tile = working;
        let working_columns = working.columns as integer {1..65535};
        let last_valid_row = (candidate.tile.valid_rows - 1)
            as integer {0..65534};
        let last_valid_column = (candidate.tile.valid_columns - 1)
            as integer {0..65534};
        let candidate_valid_extent =
            (TileLogicalLinearIndex(candidate.tile, last_valid_row,
                 last_valid_column) + 1) as integer {1..524288};
        let required_end = destination_offset + candidate_valid_extent;
        if required_end > parent_elements then return FALSE; end;
        let required_rows = ((required_end +
            (working_columns - 1)) DIVRM working_columns)
            as integer {1..65535};
        if _SharedGenerations[[index]].working_tile.valid_rows < required_rows then
            _SharedGenerations[[index]].working_tile.valid_rows = required_rows;
        end;
        if _SharedGenerations[[index]].working_tile.valid_columns <
           candidate.tile.valid_columns then
            _SharedGenerations[[index]].working_tile.valid_columns =
                candidate.tile.valid_columns;
        end;
    end;
    let covered = BundleSharedGenerationCoverageWithCurrent(
        shared_tile_id, offset_cells, coverage_cells, assemble.init);
    _SharedGenerations[[index]].covered_cells = covered;
    _SharedGenerations[[index]].ready_cells = covered;
    _SharedGenerations[[index]].arrived_participants =
        _SharedGenerations[[index]].arrived_participants OR
        participant_arrival;
    _SharedGenerations[[index]].working_initialized_mask =
        _SharedGenerations[[index]].working_initialized_mask OR
        candidate.initialized_mask;
    if assemble.last then
        _SharedGenerations[[index]].last_seen = TRUE;
        _SharedGenerations[[index]].closed = TRUE;
        _SharedGenerations[[index]].open = FALSE;
        _SharedGenerations[[index]].published = TRUE;
        _SharedGenerations[[index]].working_tile.contents_defined = TRUE;
        _SharedTiles[[index]].descriptor_valid = TRUE;
        _SharedTiles[[index]].allocation_mask = participant_mask;
        _SharedTiles[[index]].initialized_mask = participant_mask;
        _SharedTiles[[index]].whole_parent_ready = TRUE;
        _SharedTiles[[index]].published = TRUE;
        _SharedTiles[[index]].tile =
            _SharedGenerations[[index]].working_tile;
    end;
    return TRUE;
end;
// Ordinary B.ASSEMBLE retains its size-coded range and represents arrival of
// the complete decoded PE mask.  Specialized collectives use the explicit
// range entry point above.
func CommitBundleSharedGenerationCandidate(
    binding: BundleSharedBindingIndex,
    candidate: SharedTileInfo) => boolean
begin
    let assemble = _BundleSharedBindings[[binding]].destination_assemble;
    let offset_cells = (UInt(assemble.offset) * 4) as integer {0..8188};
    let writer_cells = (BundleLocalGenerationCellCount(assemble.size_code as integer {1..12}) * 4) as integer {4..8192};
    return CommitBundleSharedGenerationCandidateRange(binding, candidate,
        offset_cells, writer_cells, writer_cells,
        _BundleSharedBindings[[binding]].pe_mask, FALSE,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN},
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
end;
func BeginBundleSharedGenerationProbe(shared_tile_id: SharedTileID)
    => SharedTileInfo
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    let prior = _SharedTiles[[index]];
    _SharedTiles[[index]].descriptor_valid = FALSE;
    _SharedTiles[[index]].allocation_mask = Zeros{4};
    _SharedTiles[[index]].initialized_mask = Zeros{4};
    _SharedTiles[[index]].whole_parent_ready = FALSE;
    _SharedTiles[[index]].published = FALSE;
    return prior;
end;
func RestoreBundleSharedGenerationProbe(
    shared_tile_id: SharedTileID, prior: SharedTileInfo)
begin
    _SharedTiles[[SharedTileArrayIndex(shared_tile_id)]] = prior;
end;
readonly func BundleSharedSubviewOffsetRawForPE(
    binding: BundleSharedBindingIndex, pe_identity: MemoryAgentId) => Word
begin
    let modifier = _BundleSharedBindings[[binding]].source0_subview;
    return ReadPEAbsoluteGPROperand(pe_identity, modifier.reg_src) +
        ZeroExtend{PTO_XLEN}(modifier.uimm11);
end;
readonly func BundleSharedSubviewOffsetCellsForPE(
    binding: BundleSharedBindingIndex, pe_identity: MemoryAgentId)
    => integer {0..2047}
begin
    let raw_offset = UInt(BundleSharedSubviewOffsetRawForPE(
        binding, pe_identity));
    assert raw_offset <= 2047;
    return raw_offset as integer {0..2047};
end;
readonly func BundleSharedSubviewLegal(
    binding: BundleSharedBindingIndex) => boolean
begin
    if !_BundleSharedBindings[[binding]].valid ||
       !_BundleSharedBindings[[binding]].source0_subview.valid ||
       _BundleSharedBindings[[binding]].size_code != 0 then
        return FALSE;
    end;
    let shared_tile_id = _BundleSharedBindings[[binding]].shared_tile_id;
    if !SharedTilePublished(shared_tile_id) then return FALSE; end;
    let parent = SharedTileRecord(shared_tile_id).tile;
    if TileLayoutIsCube(parent.layout) || parent.columns == 0 then
        return FALSE;
    end;
    let modifier = _BundleSharedBindings[[binding]].source0_subview;
    if modifier.size_code == 0 then return FALSE; end;
    let selected_bytes = TileSizeCodeBytes(
        modifier.size_code as integer {1..12});
    let element_bits = TileElementBits(parent.data_type);
    let bounded_columns = parent.columns as integer {1..65535};
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe_identity = pe as MemoryAgentId;
        if _BundleSharedBindings[[binding]].pe_mask[
               PTOPEMaskBitOfPEIdentity(pe_identity)] == '1' then
            let raw_offset = UInt(BundleSharedSubviewOffsetRawForPE(
                binding, pe_identity));
            if raw_offset > 2047 then return FALSE; end;
            let offset_cells = raw_offset as integer {0..2047};
            if offset_cells * PTO_TILE_CELL_BYTES + selected_bytes >
                   parent.capacity_bytes then
                return FALSE;
            end;
            let offset_elements =
                ((offset_cells * PTO_TILE_CELL_BYTES * 8) DIVRM element_bits)
                as integer {0..524287};
            let selected_elements = ((selected_bytes * 8) DIVRM element_bits)
                as integer {1..524288};
            let origin_column = (offset_elements MOD bounded_columns)
                as integer {0..65535};
            if selected_elements > bounded_columns - origin_column &&
               (origin_column != 0 || selected_elements MOD bounded_columns != 0) then
                return FALSE;
            end;
            if selected_elements > bounded_columns - origin_column &&
               selected_elements DIVRM bounded_columns > 65535 then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;
readonly func MaterializeBundleSharedSubviewForPE(
    binding: BundleSharedBindingIndex, pe_identity: MemoryAgentId) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert BundleSharedSubviewLegal(binding);
    let shared_tile_id = _BundleSharedBindings[[binding]].shared_tile_id;
    let parent = SharedTileRecord(shared_tile_id).tile;
    let modifier = _BundleSharedBindings[[binding]].source0_subview;
    let offset_cells = BundleSharedSubviewOffsetCellsForPE(
        binding, pe_identity);
    let selected_bytes = TileSizeCodeBytes(
        modifier.size_code as integer {1..12});
    let element_bits = TileElementBits(parent.data_type);
    let bounded_columns = parent.columns as integer {1..65535};
    let offset_elements =
        ((offset_cells * PTO_TILE_CELL_BYTES * 8) DIVRM element_bits)
        as integer {0..524287};
    let selected_elements = ((selected_bytes * 8) DIVRM element_bits)
        as integer {1..524288};
    let origin_row = (offset_elements DIVRM bounded_columns)
        as integer {0..65535};
    let origin_column = (offset_elements MOD bounded_columns)
        as integer {0..65535};
    let selected_columns = (if selected_elements <=
        bounded_columns - origin_column then selected_elements
        else bounded_columns) as integer {1..65535};
    let selected_rows = (if selected_elements <=
        bounded_columns - origin_column then 1
        else selected_elements DIVRM bounded_columns)
        as integer {1..65535};
    var tile = parent;
    tile.capacity_bytes = selected_bytes;
    tile.rows = DerivedTileRows(
        selected_bytes, selected_columns, parent.data_type);
    tile.columns = selected_columns;
    tile.valid_rows = selected_rows;
    tile.valid_columns = selected_columns;
    if origin_row + tile.valid_rows > parent.valid_rows then
        tile.valid_rows = if origin_row < parent.valid_rows then
            (parent.valid_rows - origin_row) as integer {0..65535}
            else 0;
    end;
    if origin_column + tile.valid_columns > parent.valid_columns then
        tile.valid_columns = if origin_column < parent.valid_columns then
            (parent.valid_columns - origin_column) as integer {0..65535}
            else 0;
    end;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.packed_defined_elements = zero_packed_tile_elements;
    tile.defined_valid_elements = 0;
    tile.contents_defined = FALSE;
    for element = 0 to selected_elements - 1 looplimit 524288 do
        let source_index = (offset_elements + element)
            as PackedTileElementIndex;
        let destination_index = element as PackedTileElementIndex;
        tile = TileInfoWithLogicalElement(tile, destination_index,
            ReadSharedTileWord(shared_tile_id, source_index));
    end;
    tile.contents_defined = TRUE;
    tile.defined_valid_elements =
        (tile.valid_rows * tile.valid_columns) as integer {0..524288};
    return tile;
end;
readonly func MaterializeBundleSharedSubview(
    binding: BundleSharedBindingIndex) => TileInfo
begin
    return MaterializeBundleSharedSubviewForPE(binding, _CurrentMemoryAgent);
end;
```
<!-- GENERATED-ASL-END: unit -->
