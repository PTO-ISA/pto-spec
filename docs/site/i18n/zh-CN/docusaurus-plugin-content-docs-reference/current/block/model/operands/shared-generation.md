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

本单元拥有 Shared 代次范围验证、低层候选合并与原子发布，以及 Shared subview 验证和物化。Shared 代次是通过 `B.ASSEMBLE` 构建的 Shared Tile；Shared subview 是已发布 Shared Tile 的一个范围，每个 PE 可以把它放在不同位置。

相邻的 per-PE 请求所有者处理编码请求身份、实际执行 PE 的源捕获、准入和保留完成状态。逻辑 `pe_mask` 仍描述操作参与者和形状；一次编码请求只贡献其实际执行的 PE。

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-concepts role=concepts-state -->
## 概念与可见状态

本单元的范围和聚合辅助操作会更新某个 Shared Tile ID 的 `_SharedGenerations` 记录，并在 LAST 时发布完整的 `_SharedTiles` 条目。编码 per-PE 请求身份和释放跟踪由相邻请求所有者维护。

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

`PTO-B-ASSEMBLE-SHARED-GENERATION-001` 契约区分逻辑参与者掩码与编码到达：每次编码提交只捕获其实际执行 PE，而独立的聚合验证仍保留整个掩码到达的语义。实际 PE 请求所有者负责这种编码准入。

`CommitBundleSharedGenerationCandidateRange` 会重复范围验证，并将候选 Tile 合并到工作 Tile 的写者偏移处。INIT 以父级容量和无已定义元素的状态开始工作 Tile；延续要求列数、数据类型和布局一致。低层操作更新覆盖、就绪和到达，并在 LAST 时于同一提交步骤发布完整工作 Tile。编码 per-PE 准入、一次性贡献和保留释放由相邻请求所有者处理。

设计要点：`CommitBundleSharedGenerationCandidateRange` 只在 LAST 时写入 `_SharedTiles`；更早的调用只改变代次记录。NDF `PTO-B-ASSEMBLE-SHARED-GENERATION-001` 要求发布原子地替换描述符和载荷，并要求每次拒绝都保留先前已发布的代次。

设计要点：参与者到达与覆盖分开跟踪。专用的协作生产者每个写者只传入一个 PE 的到达位，行数为零的 PE 可以在不写入任何单元的情况下到达，因此集体操作仍然可以关闭。

根据 Shared 代次契约，被 squash 的实际请求之后不能再向未完成候选贡献；已发布候选会保留其待处理释放。状态和 per-PE 请求所有者负责跨已保存 PE 与陷阱上下文使请求令牌失效。

per-PE 请求和 Shared TLSU 所有者说明 Shared `TLOAD`/`TMOV` 的临时候选探测及其首次故障行为；请参阅下方相关所有者。

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-boundaries role=boundaries -->
## 架构边界

`BundleSharedSubviewLegal` 要求一个大小码为 0 的源绑定指向一个已发布的非 CUBE Shared Tile。对每个选中的 PE，它在该 PE 自己的寄存器中计算 `GPR[RegSrc] + uimm11`，然后要求该范围位于父 Tile 内，并且要么在一行之内，要么是从第 0 列开始的整行。`MaterializeBundleSharedSubviewForPE` 构建该 PE 的视图。任何一个不合法的视图都会拒绝整个操作。

Tile 操作失败后，`AbortBundleSharedGenerationsForBundle` 会遍历该指令束中有效的 Shared 组装目标绑定，并中止这些目标代次。操作仅仅读取某个 Shared 源代次时，不会因此中止该源代次。

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

在编码见证 `PTO-AVS-BLOCK-SHARED-TLSU-ASSEMBLE-PE-009` 中，四个 PE 使用相同逻辑掩码 `1111`、Shared Tile 19 和 512 字节父 Tile，各自在偏移 0、1、2 或 3 写入一个 128 字节 CELL。每个请求携带匹配的 `INIT_LAST` 元数据，但只捕获该实际 PE 的私有源。前三个 stop 均无故障地保持挂起，TPC 不前进且不发布；第四个请求补齐覆盖并原子发布四个不同片段。重试较早的 stop 会各自消费一次保留的完成状态，不会重放片段。之后再次使用相同静态操作会获得新序号和新片段；在替换完成前，先前的父 Tile 仍然可见。

<!-- PTO-READER-BLOCK: block-model-operands-shared-generation-related role=related-owners-navigation -->
## 相关所有者

- [Shared 代次状态](../state/shared-generation-state.md)清除、复位和中止记录。
- [Shared 绑定](shared-bindings.md)定义重用目标。
- [per-PE Shared 代次请求](shared-generation-pe-requests.md)拥有编码源捕获、准入、发布和保留释放；[Shared TLSU](../dispatch/shared-tlsu.md)、[TIMG2COL 执行](../dispatch/timg2col-execution.md)和[权重到 Shared 执行](../dispatch/weight-to-shared-execution.md)调用适用的提交路径。
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
// published generation. Encoded per-PE submissions MUST capture only the
// executing participant's real source and arrival. A matching participant
// may join one open Core-owned candidate once; an incomplete collective LAST
// remains parked without a fault or PC advance until every declared range and
// participant is present. A later request from an already-arrived PE MUST NOT
// be merged into that earlier candidate. Completed candidates remain retained
// until every parked request has consumed its completion, and a new INIT MUST
// use a new operation ordinal rather than reusing the old candidate. Squashing
// an execution domain whose actual arrival token belongs to an incomplete
// PE-owned candidate MUST abort that candidate and invalidate the retained
// request identity across saved PE and trap contexts. A published candidate
// is irrevocable: squash MUST preserve its payload and outstanding release
// state.
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
            let index = SharedTileArrayIndex(
                _BundleSharedBindings[[binding]].shared_tile_id);
            // Publication is irrevocable. A later unrelated or malformed
            // request cannot erase a published parent's outstanding releases;
            // explicit invocation retirement owns their metadata cleanup.
            if !_SharedGenerations[[index]].actual_pe_owned ||
               !_SharedGenerations[[index]].published then
                AbortBundleSharedGeneration(
                    _BundleSharedBindings[[binding]].shared_tile_id);
            end;
        end;
    end;
end;
// Coverage uses 32-byte units; wrappers expand existing 128-byte CELL
// quantities to four units for specialized complete-row producers.
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
// Specialized collectives may contribute fewer cells (including zero);
// arrival remains independent of coverage and payload definedness.
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
func CommitBundleSharedGenerationCandidateRangeWithPayloadElements(
    binding: BundleSharedBindingIndex, candidate: SharedTileInfo,
    offset_cells: integer {0..8192},
    coverage_cells: integer {0..8192},
    payload_cells: integer {0..8192},
    payload_elements: integer {0..524288},
    placed_fragment: boolean,
    preserve_source_geometry: boolean,
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
       payload_elements > ((payload_cells * 32 * 8) DIVRM
           TileElementBits(candidate.tile.data_type)) ||
       !ValidateBundleSharedGenerationRange(binding, offset_cells,
           coverage_cells, participant_arrival, specialized_inputs_valid,
           specialized_input0, specialized_input1,
           specialized_input2, specialized_input3, specialized_metadata) then
        return FALSE;
    end;
    if assemble.init then
        let parent_size = _BundleSharedBindings[[binding]].size_code as integer {1..12};
        let parent_bytes = TileSizeCodeBytes(parent_size);
        let parent_rows = DerivedTileRows(parent_bytes, candidate.tile.columns, candidate.tile.data_type);
        if parent_rows == 0 then return FALSE; end;
        let complete_source_view = preserve_source_geometry && placed_fragment &&
            offset_cells == 0 && candidate.tile.capacity_bytes == parent_bytes &&
            coverage_cells == BundleLocalGenerationCellCount(parent_size) * 4 &&
            payload_cells == coverage_cells && payload_elements == TileLogicalElementCapacity(parent_bytes, candidate.tile.data_type);
        _SharedGenerations[[index]].open = TRUE;
        _SharedGenerations[[index]].closed = FALSE;
        _SharedGenerations[[index]].published = FALSE;
        _SharedGenerations[[index]].shared_tile_id = shared_tile_id;
        _SharedGenerations[[index]].participant_mask = participant_mask;
        _SharedGenerations[[index]].parent_size_code = parent_size;
        _SharedGenerations[[index]].parent_cell_count = BundleLocalGenerationCellCount(parent_size) * 4;
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
        _SharedGenerations[[index]].working_tile.rows = if complete_source_view then
            candidate.tile.rows else parent_rows;
        // Rebuild placed-fragment validity in the destination geometry.
        if placed_fragment then _SharedGenerations[[index]].working_tile.valid_rows = 0;
            _SharedGenerations[[index]].working_tile.valid_columns = 0; end;
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
    var descriptor_expanded = FALSE;
    if payload_elements != 0 then
        let element_bits = TileElementBits(candidate.tile.data_type);
        let destination_offset = ((offset_cells * 32 * 8) DIVRM element_bits) as integer {0..524287};
        let source_elements = payload_elements;
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
        // Actual PE fragments compose validity; TLOAD retains whole-parent shape.
        let previous_valid_rows = _SharedGenerations[[index]].working_tile.valid_rows;
        let previous_valid_columns = _SharedGenerations[[index]].working_tile.valid_columns;
        let candidate_rows = if placed_fragment then
            BundleSharedGenerationPlacedExtent(candidate.tile, _SharedGenerations[[index]].working_tile,
                source_elements, destination_offset, previous_valid_rows, FALSE)
            else candidate.tile.valid_rows;
        let candidate_columns = if placed_fragment then
            BundleSharedGenerationPlacedExtent(candidate.tile, _SharedGenerations[[index]].working_tile,
                source_elements, destination_offset, previous_valid_columns, TRUE)
            else candidate.tile.valid_columns;
        descriptor_expanded = candidate_rows > previous_valid_rows ||
            candidate_columns > previous_valid_columns;
        if _SharedGenerations[[index]].working_tile.valid_rows <
           candidate_rows then
            _SharedGenerations[[index]].working_tile.valid_rows = candidate_rows;
        end;
        if _SharedGenerations[[index]].working_tile.valid_columns <
           candidate_columns then
            _SharedGenerations[[index]].working_tile.valid_columns = candidate_columns;
        end;
    end;
    let covered = BundleSharedGenerationCoverageWithCurrent(
        shared_tile_id, offset_cells, coverage_cells, assemble.init);
    _SharedGenerations[[index]].covered_cells = covered;
    let prior_ready = if assemble.init then Zeros{8192}
        else _SharedGenerations[[index]].ready_cells;
    let range_ready = BundleSharedGenerationReadyCellsWithRange(
        _SharedGenerations[[index]].working_tile, prior_ready,
        offset_cells, coverage_cells);
    _SharedGenerations[[index]].ready_cells = if payload_elements != 0 &&
        descriptor_expanded then
            BundleSharedGenerationReadyCellsWithRange(
                _SharedGenerations[[index]].working_tile, range_ready,
                0, _SharedGenerations[[index]].parent_cell_count)
        else range_ready;
    _SharedGenerations[[index]].arrived_participants =
        _SharedGenerations[[index]].arrived_participants OR
        participant_arrival;
    _SharedGenerations[[index]].working_initialized_mask =
        _SharedGenerations[[index]].working_initialized_mask OR
        candidate.initialized_mask;
    if assemble.last then
        var all_data_ready = TRUE;
        for cell = 0 to 8191 do
            if cell < _SharedGenerations[[index]].parent_cell_count &&
               _SharedGenerations[[index]].ready_cells[cell] == '0' then
                all_data_ready = FALSE;
            end;
        end;
        if !all_data_ready then return FALSE; end;
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
    let payload_elements = ((payload_cells * 32 * 8) DIVRM
        TileElementBits(candidate.tile.data_type)) as integer {0..524288};
    return CommitBundleSharedGenerationCandidateRangeWithPayloadElements(
        binding, candidate, offset_cells, coverage_cells, payload_cells,
        payload_elements, FALSE, FALSE, participant_arrival, specialized_inputs_valid,
        specialized_input0, specialized_input1, specialized_input2,
        specialized_input3, specialized_metadata);
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
