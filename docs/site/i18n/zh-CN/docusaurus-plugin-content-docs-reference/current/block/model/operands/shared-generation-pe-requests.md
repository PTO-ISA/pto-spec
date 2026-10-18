<!-- GENERATED FROM: asl/block/model/operands/shared-generation-pe-requests.asl -->
# Shared Generation PE Requests

**Normative ASL source:** `asl/block/model/operands/shared-generation-pe-requests.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION-PE-REQUESTS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-shared-pe-requests-purpose role=purpose-scope -->
## 目的和范围

本单元将每个 PE 的 Shared `B.ASSEMBLE` stop 转换为携带标识的 request。它验证 request 如何加入 Core-wide candidate、提交一次 contribution，并在之后让同一 PE 消费其 publication release，而不重放 contribution。

request layer 之所以存在，是因为各 PE 可以在不同时间抵达 stop。当慢 PE 完成同一 Shared generation 时，快 PE 必须始终与其确切 Core、invocation、execution domain、TPC、BPC 和 operand 相关联。

<!-- PTO-READER-BLOCK: block-shared-pe-requests-concepts role=concepts-state -->
## Request 和 completion 状态

活跃 Block 状态记录当前 PE 是否已提交 Shared-generation request、是否在等待，以及它加入了哪个 candidate ordinal。Core-wide Shared-generation owner 保存 candidate 和 per-PE release record；已发布 Shared parent 是单独的 committed object。

nonparticipant 仍会通过 structural validation，随后消费自己的 Block binding 并 retire，而不改变 fragment、candidate、parent、ordinal、arrival 或 release record。participant request 仅在记录的 Core、invocation、PE、execution-domain token、instruction site、destination、assembly attribute、participant mask、fragment descriptor 和 source binding 全部匹配时才匹配。

<!-- PTO-READER-BLOCK: block-shared-pe-requests-rules role=rules-interactions -->
## Submission 和 release 规则

validation 拒绝不匹配 open candidate 的 request，也拒绝与同一 participating PE set 的更早 contribution 重叠的 request。成功 submission 提交一个 candidate fragment，然后停驻直到 publication。completed generation 为每个声明 PE 提供 release record，消费该 release 会恰好一次清除该 PE 的 request。

readiness 按最终 candidate descriptor 检查。若后续 contribution 扩大 valid row 或 column，较早 fragment 仍必须定义后来成为 valid 的每个 element。unready request 保持停驻，并使之前发布的 parent 和 candidate ordinal 不变。

<!-- PTO-READER-BLOCK: block-shared-pe-requests-boundaries role=boundaries -->
## 边界

incomplete candidate 不是 published Shared Tile。fault、abort 或 matching domain squash 可以丢弃 candidate metadata，同时保留之前发布的 parent。成功 kernel retirement 移除 invocation-owned candidate 和 release metadata，但也保留该 parent 和 monotonic operation ordinal。

本单元不会创造 fallback fragment、合并无关的 Core candidate，或允许恢复的 stale context 复活 squashed request。Shared-generation owner 定义 candidate assembly；operation-specific dispatch 定义每个 source fragment 的产生方式。

<!-- PTO-READER-BLOCK: block-shared-pe-requests-example role=example-usage -->
## 阅读示例

在完整四 PE participant mask 下，PE0 可以提交 generation-12 INIT contribution，并在 PE1 到 PE3 抵达期间等待。第四个 valid contribution 发布 generation 12 后，PE0 可以立即消费其 release 并抵达下一次 INIT。若 PE2 仍持有 generation-12 release，PE0 的下一 request 保持完整，但不能替换旧 publication 或复用 PE2 的 token；只有在之前的 release state 允许后，它才能加入下一个 candidate。

<!-- PTO-READER-BLOCK: block-shared-pe-requests-related role=related-owners-navigation -->
## 相关所有者

- [Shared generation](shared-generation.md) 拥有 candidate construction、publication 和 release record。
- [Shared-generation state](../state/shared-generation-state.md) 声明 Core-wide candidate 和 ordinal storage。
- [Local generation squash](local-generation-squash.md) 移除 matching speculative domain 的 request state。
- [Kernel lifecycle](../../../arch/state/kernel-lifecycle.md) 退役 invocation-owned candidate 和 release metadata。
- [PE execution context](../../../arch/state/pe-execution-context.md) 在选择切换期间保存每个 PE 的 waiting request。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/shared-generation-pe-requests.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION-PE-REQUESTS","surface":"block","classification":["model","operands","shared-generation-pe-requests"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION"]}
readonly func BundleSharedGenerationRequestWaiting(
    binding: BundleSharedBindingIndex) => boolean
begin
    return _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid &&
           _BundleSharedBindings[[binding]].destination_assemble
               .shared_request_waiting;
end;

readonly func BundleCurrentPEIsNonparticipantSharedAssembly() => boolean
begin
    if !_CurrentPEContextValid then return FALSE; end;
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid &&
           _BundleSharedBindings[[binding]].destination_assemble.init then
            let mask = _BundleSharedBindings[[binding]].pe_mask;
            let pe = _CurrentMemoryAgent as integer {0..3};
            if mask != Zeros{4} &&
               mask[PTOPEMaskBitOfPEIdentity(pe)] != '1' then
                return TRUE;
            end;
        end;
    end;
    return FALSE;
end;

readonly func BundleSharedGenerationCompletionAvailableForCurrentPE()
    => boolean
begin
    if !_CurrentPEContextValid ||
       !_KernelInvocationActiveByCore[[_CurrentModelCore]] ||
       _CurrentKernelInvocation == 0 ||
       _CurrentMemoryOrigin != MemoryEventOrigin_Kernel ||
       !BundleSharedTLSUSelected() then return FALSE; end;
    let pe = _CurrentMemoryAgent as integer {0..3};
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid then
            let request = _BundleSharedBindings[[binding]].destination_assemble;
            let index = SharedTileArrayIndex(
                _BundleSharedBindings[[binding]].shared_tile_id);
            if request.shared_request_identity_valid &&
               !request.shared_request_squashed &&
               !_BundleSharedBindings[[binding]].consumed &&
               request.shared_request_execution_domain ==
                   _BundleExecutionDomainToken &&
               request.shared_request_operation_ordinal ==
                   _SharedGenerations[[index]].operation_ordinal &&
               _SharedGenerations[[index]].actual_pe_owned &&
               _SharedGenerations[[index]].core_identity == _CurrentModelCore &&
               _SharedGenerations[[index]].invocation_identity ==
                   _CurrentKernelInvocation &&
               _SharedGenerations[[index]].origin == _CurrentMemoryOrigin &&
               _SharedGenerations[[index]].source_acr == _CurrentACR &&
               _SharedGenerations[[index]].producer_site == ReadBPC() &&
               _SharedGenerations[[index]].start_instruction ==
                   _BundleStartEncodedInstruction &&
               _SharedGenerations[[index]].operation_form ==
                   _BundleOperation.form_identity &&
               _SharedGenerations[[index]].operation_selector ==
                   _BundleOperation.selector &&
               _SharedGenerations[[index]].participant_mask ==
                   _BundleSharedBindings[[binding]].pe_mask &&
               _SharedGenerations[[index]].published &&
               _SharedGenerations[[index]].arrival_request_tokens[[pe]] ==
                   _BundleExecutionDomainToken &&
               _SharedGenerations[[index]].released_participants[
                   PTOPEMaskBitOfPEIdentity(pe)] != '1' then
                return TRUE;
            end;
        end;
    end;
    return FALSE;
end;

func ConsumeBundleSharedGenerationCompletionForCurrentPE() => boolean
begin
    if !BundleSharedGenerationCompletionAvailableForCurrentPE() then
        return FALSE;
    end;
    let pe = _CurrentMemoryAgent as integer {0..3};
    let participant = SharedGenerationPEBit(_CurrentMemoryAgent);
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid then
            let index = SharedTileArrayIndex(
                _BundleSharedBindings[[binding]].shared_tile_id);
            if _SharedGenerations[[index]].arrival_request_tokens[[pe]] ==
                   _BundleExecutionDomainToken &&
               _SharedGenerations[[index]].published &&
               _SharedGenerations[[index]].operation_ordinal ==
                   _BundleSharedBindings[[binding]].destination_assemble
                       .shared_request_operation_ordinal then
                _SharedGenerations[[index]].released_participants =
                    _SharedGenerations[[index]].released_participants OR
                    participant;
                _BundleSharedBindings[[binding]].destination_assemble
                    .shared_request_waiting = FALSE;
                ConsumeBundleSharedBindings(1);
                return TRUE;
            end;
        end;
    end;
    return FALSE;
end;

readonly func SharedGenerationCoreIdentityMatches(
    index: SharedTileIndex,
    binding: BundleSharedBindingIndex) => boolean
begin
    return _SharedGenerations[[index]].actual_pe_owned &&
           _SharedGenerations[[index]].core_identity == _CurrentModelCore &&
           _SharedGenerations[[index]].invocation_identity ==
               _CurrentKernelInvocation &&
           _SharedGenerations[[index]].origin == _CurrentMemoryOrigin &&
           _SharedGenerations[[index]].source_acr == _CurrentACR &&
           _SharedGenerations[[index]].producer_site == ReadBPC() &&
           _SharedGenerations[[index]].start_instruction ==
               _BundleStartEncodedInstruction &&
           _SharedGenerations[[index]].operation_form ==
               _BundleOperation.form_identity &&
           _SharedGenerations[[index]].operation_selector ==
               _BundleOperation.selector &&
           _SharedGenerations[[index]].participant_mask ==
               _BundleSharedBindings[[binding]].pe_mask &&
           _SharedGenerations[[index]].parent_size_code ==
               BundleSharedGenerationCapacity(binding);
end;

readonly func ValidateCurrentPESharedGenerationSubmission(
    binding: BundleSharedBindingIndex) => boolean
begin
    if !_CurrentPEContextValid ||
       !_BundleSharedBindings[[binding]].destination_assemble.init then
        return FALSE;
    end;
    let shared_tile_id = _BundleSharedBindings[[binding]].shared_tile_id;
    let index = SharedTileArrayIndex(shared_tile_id);
    let assemble = _BundleSharedBindings[[binding]].destination_assemble;
    let participant_mask = _BundleSharedBindings[[binding]].pe_mask;
    let pe_index = _CurrentMemoryAgent as integer {0..3};
    if participant_mask == Zeros{4} ||
       _BundleSharedBindings[[binding]].size_code == 0 then
        return FALSE;
    end;
    let raw_offset = UInt(assemble.offset);
    if raw_offset > 2047 then return FALSE; end;
    let parent_cells = (BundleLocalGenerationCellCount(
        BundleSharedGenerationCapacity(binding) as integer {1..12}) * 4)
            as integer {4..8192};
    let offset_cells = (raw_offset * 4) as integer {0..8188};
    let writer_cells = (BundleLocalGenerationCellCount(
        assemble.size_code as integer {1..12}) * 4) as integer {4..8192};
    if offset_cells + writer_cells > parent_cells then return FALSE; end;
    let selected = participant_mask[
        PTOPEMaskBitOfPEIdentity(pe_index)] == '1';
    // A structurally legal stream from a nonparticipant has no producer
    // state to validate or mutate. It cannot abort a candidate belonging to
    // actual participants.
    if !selected then return TRUE; end;
    if _SharedGenerations[[index]].open &&
       !SharedGenerationCoreIdentityMatches(index, binding) then
        return FALSE;
    end;
    // A published actual-PE candidate may still have parked requests that
    // have not consumed completion. Let the request reach the production
    // owner, which parks it until release; it cannot join the old ordinal.
    let waiting_for_release = _SharedGenerations[[index]].actual_pe_owned &&
        _SharedGenerations[[index]].published &&
        _SharedGenerations[[index]].released_participants !=
            _SharedGenerations[[index]].participant_mask;
    if _SharedGenerations[[index]].published &&
       _SharedGenerations[[index]].actual_pe_owned &&
       !waiting_for_release &&
       !SharedGenerationCoreIdentityMatches(index, binding) then
        // A different invocation/site is a new INIT and will allocate the
        // next operation ordinal after the old requests have released.
        return TRUE;
    end;
    return TRUE;
end;

readonly func SharedGenerationCoreRequestMatches(
    index: SharedTileIndex,
    binding: BundleSharedBindingIndex,
    candidate: SharedTileInfo) => boolean
begin
    return SharedGenerationCoreIdentityMatches(index, binding) &&
           _SharedGenerations[[index]].working_tile.columns ==
               candidate.tile.columns &&
           _SharedGenerations[[index]].working_tile.data_type ==
               candidate.tile.data_type &&
           _SharedGenerations[[index]].working_tile.layout ==
               candidate.tile.layout;
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
            if assemble.init && _CurrentPEContextValid then
                if !ValidateCurrentPESharedGenerationSubmission(binding) then
                    return FALSE;
                end;
            else
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
    end;
    return TRUE;
end;

func CommitBundleSharedGenerationCandidateForCurrentPE(
    binding: BundleSharedBindingIndex, candidate: SharedTileInfo) => boolean
begin
    assert _CurrentPEContextValid &&
           _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid;
    let shared_tile_id = _BundleSharedBindings[[binding]].shared_tile_id;
    let index = SharedTileArrayIndex(shared_tile_id);
    let participant_mask = _BundleSharedBindings[[binding]].pe_mask;
    let participant = SharedGenerationPEBit(_CurrentMemoryAgent);
    let pe_index = _CurrentMemoryAgent as integer {0..3};
    let assemble = _BundleSharedBindings[[binding]].destination_assemble;
    let request_token = _BundleExecutionDomainToken;
    if assemble.shared_request_squashed then
        // The replay owner must install a fresh BSTART/domain before this
        // request can execute again. Retain the stale completion as parked;
        // it must never rejoin a new candidate or turn squash into a fault.
        _BundleSharedBindings[[binding]].destination_assemble
            .shared_request_waiting = TRUE;
        return FALSE;
    end;
    let parent_size = BundleSharedGenerationCapacity(binding);
    let parent_cells = (BundleLocalGenerationCellCount(
        parent_size as integer {1..12}) * 4) as integer {4..8192};
    let offset_cells = (UInt(assemble.offset) * 4) as integer {0..8188};
    let writer_cells = (BundleLocalGenerationCellCount(
        assemble.size_code as integer {1..12}) * 4) as integer {4..8192};
    if participant_mask == Zeros{4} ||
       participant_mask[PTOPEMaskBitOfPEIdentity(pe_index)] != '1' ||
       candidate.allocation_mask != participant_mask ||
       !candidate.descriptor_valid || writer_cells > parent_cells ||
       offset_cells + writer_cells > parent_cells then
        return FALSE;
    end;
    if !_BundleSharedBindings[[binding]].destination_assemble
           .shared_request_identity_valid then
        _BundleSharedBindings[[binding]].destination_assemble
            .shared_request_identity_valid = TRUE;
        _BundleSharedBindings[[binding]].destination_assemble
            .shared_request_execution_domain = request_token;
        _BundleSharedBindings[[binding]].destination_assemble
            .shared_request_operation_ordinal = 0;
        _BundleSharedBindings[[binding]].destination_assemble
            .shared_request_waiting = FALSE;
    elsif _BundleSharedBindings[[binding]].destination_assemble
              .shared_request_execution_domain != request_token then
        return FALSE;
    end;
    _BundleSharedBindings[[binding]].destination_assemble
        .shared_request_waiting = FALSE;

    // An accepted request that retries after the matching collective LAST
    // consumes its original completion token without replaying its payload.
    if _SharedGenerations[[index]].actual_pe_owned &&
       _SharedGenerations[[index]].arrival_request_tokens[[pe_index]] ==
           request_token &&
       _BundleSharedBindings[[binding]].destination_assemble
           .shared_request_operation_ordinal ==
               _SharedGenerations[[index]].operation_ordinal then
        if _SharedGenerations[[index]].published then
            _SharedGenerations[[index]].released_participants =
                _SharedGenerations[[index]].released_participants OR
                participant;
            _BundleSharedBindings[[binding]].destination_assemble
                .shared_request_waiting = FALSE;
            return TRUE;
        elsif _SharedGenerations[[index]].released_participants[
                  PTOPEMaskBitOfPEIdentity(pe_index)] == '1' then
            return TRUE;
        else
            _BundleSharedBindings[[binding]].destination_assemble
                .shared_request_waiting = TRUE;
            return FALSE;
        end;
    end;

    if _SharedGenerations[[index]].published then
        if !_SharedGenerations[[index]].actual_pe_owned then
            if !assemble.init then return FALSE; end;
            ClearBundleSharedGenerationState(shared_tile_id);
        elsif _SharedGenerations[[index]].released_participants !=
                  _SharedGenerations[[index]].participant_mask then
            _BundleSharedBindings[[binding]].destination_assemble
                .shared_request_waiting = TRUE;
            return FALSE;
        else
            if !assemble.init then return FALSE; end;
            // Retire only lifecycle metadata. The already-published Shared
            // parent remains visible until a complete replacement commits.
            ClearBundleSharedGenerationState(shared_tile_id);
        end;
    elsif _SharedGenerations[[index]].open then
        if !_SharedGenerations[[index]].actual_pe_owned then
            return FALSE;
        end;
        if _SharedGenerations[[index]].arrived_participants[
               PTOPEMaskBitOfPEIdentity(pe_index)] == '1' then
            _BundleSharedBindings[[binding]].destination_assemble
                .shared_request_waiting = TRUE;
            return FALSE;
        end;
        if !SharedGenerationCoreRequestMatches(index, binding, candidate) then
            return FALSE;
        end;
    else
        if !assemble.init then return FALSE; end;
    end;

    let starts_generation = !_SharedGenerations[[index]].open;
    if starts_generation then
        let next_ordinal =
            _SharedGenerations[[index]].next_operation_ordinal + 1;
        _SharedGenerations[[index]].next_operation_ordinal = next_ordinal;
        _SharedGenerations[[index]].operation_ordinal = next_ordinal;
        _SharedGenerations[[index]].core_identity = _CurrentModelCore;
        _SharedGenerations[[index]].invocation_identity =
            _CurrentKernelInvocation;
        _SharedGenerations[[index]].origin = _CurrentMemoryOrigin;
        _SharedGenerations[[index]].source_acr = _CurrentACR;
        _SharedGenerations[[index]].producer_site = ReadBPC();
        _SharedGenerations[[index]].start_instruction =
            _BundleStartEncodedInstruction;
        _SharedGenerations[[index]].operation_form =
            _BundleOperation.form_identity;
        _SharedGenerations[[index]].operation_selector =
            _BundleOperation.selector;
        _SharedGenerations[[index]].actual_pe_owned = TRUE;
    end;

    // Reuse the existing Shared-generation range validator and writer. INIT
    // joins are normalized to an internal continuation after common identity
    // matching; LAST is staged until all actual arrivals and ranges exist.
    _BundleSharedBindings[[binding]].destination_assemble.init =
        starts_generation;
    _BundleSharedBindings[[binding]].destination_assemble.last = FALSE;
    let original_shared_size = _BundleSharedBindings[[binding]].size_code;
    if !starts_generation then
        _BundleSharedBindings[[binding]].size_code = 0;
    end;
    let prior_initialized =
        _SharedGenerations[[index]].working_initialized_mask;
    let element_bits = TileElementBits(candidate.tile.data_type)
        as integer {1..64};
    let writer_payload_elements = ((writer_cells * 32 * 8) DIVRM
        element_bits) as integer {1..524288};
    let whole_parent_tload = _BundleOperation.valid &&
        _BundleOperation.operation_class == BundleOperation_TileMemory &&
        _BundleOperation.selector_valid && _BundleOperation.selector[4:0] == Zeros{5};
    // Physical writer padding is covered; only defined valid coordinates copy.
    let preserve_source_geometry = BundleTMOVSelected();
    let committed =
        CommitBundleSharedGenerationCandidateRangeWithPayloadElements(
            binding, candidate, offset_cells, writer_cells,
            writer_cells, writer_payload_elements,
            !whole_parent_tload, preserve_source_geometry, participant,
            FALSE, Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, Zeros{PTO_XLEN},
            Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    _BundleSharedBindings[[binding]].destination_assemble.init = assemble.init;
    _BundleSharedBindings[[binding]].destination_assemble.last = assemble.last;
    _BundleSharedBindings[[binding]].size_code = original_shared_size;
    if !committed then return FALSE; end;

    _SharedGenerations[[index]].actual_pe_owned = TRUE;
    _SharedGenerations[[index]].arrival_request_tokens[[pe_index]] =
        request_token;
    _SharedGenerations[[index]].arrival_program_orders[[pe_index]] =
        _CurrentProgramOrder;
    _SharedGenerations[[index]].working_initialized_mask =
        prior_initialized OR participant;
    _SharedGenerations[[index]].last_seen =
        _SharedGenerations[[index]].last_seen || assemble.last;
    _BundleSharedBindings[[binding]].destination_assemble
        .shared_request_operation_ordinal =
            _SharedGenerations[[index]].operation_ordinal;

    var all_coverage_present = TRUE;
    var all_data_ready = TRUE;
    for cell = 0 to 8191 do
        if cell < _SharedGenerations[[index]].parent_cell_count then
            if _SharedGenerations[[index]].covered_cells[cell] == '0' then
                all_coverage_present = FALSE;
            end;
            if _SharedGenerations[[index]].ready_cells[cell] == '0' then
                all_data_ready = FALSE;
            end;
        end;
    end;
    let all_participants_arrived =
        _SharedGenerations[[index]].arrived_participants == participant_mask;
    if _SharedGenerations[[index]].last_seen &&
       all_participants_arrived && all_coverage_present && all_data_ready then
        _SharedGenerations[[index]].last_seen = TRUE;
        _SharedGenerations[[index]].closed = TRUE;
        _SharedGenerations[[index]].open = FALSE;
        _SharedGenerations[[index]].published = TRUE;
        _SharedGenerations[[index]].working_tile.contents_defined = TRUE;
        _SharedGenerations[[index]].working_tile.defined_valid_elements =
            (_SharedGenerations[[index]].working_tile.valid_rows *
             _SharedGenerations[[index]].working_tile.valid_columns)
                as integer {0..524288};
        PublishPEOwnedSharedGeneration(shared_tile_id, participant_mask);
        _SharedGenerations[[index]].released_participants =
            _SharedGenerations[[index]].released_participants OR participant;
        _BundleSharedBindings[[binding]].destination_assemble
            .shared_request_waiting = FALSE;
        return TRUE;
    end;
    if assemble.last && !all_participants_arrived then
        _BundleSharedBindings[[binding]].destination_assemble
            .shared_request_waiting = TRUE;
        return FALSE;
    end;
    if assemble.last && all_participants_arrived &&
       !all_coverage_present then
        return FALSE;
    end;
    if assemble.last && all_participants_arrived &&
       all_coverage_present && !all_data_ready then
        _BundleSharedBindings[[binding]].destination_assemble
            .shared_request_waiting = TRUE;
        return FALSE;
    end;
    _SharedGenerations[[index]].released_participants =
        _SharedGenerations[[index]].released_participants OR participant;
    _BundleSharedBindings[[binding]].destination_assemble
        .shared_request_waiting = FALSE;
    return TRUE;
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
```
<!-- GENERATED-ASL-END: unit -->
