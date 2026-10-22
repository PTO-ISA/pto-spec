<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-gmov.asl -->
# TLSU Gmov

**Normative ASL source:** `asl/block/model/dispatch/tlsu-gmov.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-purpose role=purpose-scope -->
## 用途与范围

本单元是 `GMOV` 的指令束级处理程序。`GMOV` 在同一核的四个 PE 的 Local Tile 之间做对等搬移。指令束是一组从 `BSTART` 开始的头部命令，在 `BSTOP` 或下一个 `BSTART` 处提交时执行。

`BundleGMOVSelected` 识别该指令束：有效的 `TileMemory` 操作描述符，其选择器功能号（位 `4:0`）为 `13`。随后 `ExecuteBundleGMOVOperation` 校验完整指令束，解析一个 Local 目标，并调用 Tile 级 `GMOV` 效果。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-concepts role=concepts-state -->
## 概念与可见状态

处理器读取已收集的 bundle 状态，将实际选中的源 PE 数据复制到当前执行的目标 PE。源回收是单独的成功完成效果，作用于源 bank 而非目标 bank。

- 恰好一个 `B.IOT` 绑定，带目标、`source0`、无 `source1`，并带 `last` 标志。不允许 `B.IOS` Shared 绑定。
- 每个 `B.DIM` 维度的值必须为 `1`。省略的维度默认为 `1`，因此通常形式不编码任何维度。
- 可选的 `B.IOR` `source0` 指定保存对等标识的 GPR。每个 PE 用 `ReadPEAbsoluteGPROperand` 从自己的寄存器堆读取该选择器。没有 `B.IOR` 时对等值为零。
- 操作数据类型和 `B.DATR` 布局必须与源 Tile 一致，且数据类型必须通过 `TileCarrierOrPackedBaselineDataTypeSupported`。
- 目标大小必须等于源 Tile 的字节容量。

目标沿用源的有效行数、有效列数、物理列数和数据类型。`GMOV` 从源复制载荷和已定义性。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-rules role=rules-interactions -->
## 规则与交互

未知的 TLSU 操作码引发 `Fault_IllegalInstruction`。每种 schema 失败都引发 `Fault_TileLegality`，且这些检查都在解析目标之前进行。

处理程序依次检查：无 Shared 绑定且 `B.IOR` 完整合法；各绑定 PE 掩码一致；恰好一个 Tile 绑定；数据属性；绑定形状与源就绪；字节大小、类型与布局匹配；维度等于 `1`；每个 PE 的对等标识小于 `4`。

独立 PE 执行在每个实际 peer bank 中解析原始相对源。捕获的选择在目标发布新相对代次期间保持物理索引和代次身份稳定。聚合验证调用者保留已有 Core 范围视图；该表示不能替代 PE 私有归属。

设计要点：对等范围检查遍历全部四个 PE，即使 PE 掩码会抑制某个 PE 的写入。ASL 注释指出每个 PE 都参与对等选择和就绪预检。重复的对等标识是合法的；只约束范围 `0..3`。

预检之后，目标按捕获的源形状和类型分配，移动操作先复制载荷与定义信息再发布。重复选择同一 peer 是同一源代次的多个消费者：最后使用记账保留该载荷直到其选中消费者完成，`.reuse` 则保留载荷。重试、恢复和旧完成事件使用捕获的请求身份，而非复用的表槽。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-boundaries role=boundaries -->
## 架构边界

本单元并不在提交时判定指令束是否为 GMOV 指令束。`ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` 按固定顺序测试各专用选择器，只有当 TIMG2COL、权重加载、矩阵和 CUBE 布局转换选择器都未先匹配时才调用本处理程序。该调用者也在本处理程序返回后提交或中止 Local 生成。

本单元自身不检测零 PE 掩码。PE 模式得到掩码 `0000` 的 `B.IOT` 从不创建绑定，而调用者会对只见到零参与的指令束提前返回。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设源 Tile `t3` 在全部四个 PE 上分配（掩码 `1111`），持有已定义的 FP16 RowMajor 载荷，16 个有效行乘 64 列，容量为 2048 字节。指令束有一个 `B.IOT`，其目标大小码对应 2048 字节，源为 `t3`；没有 `B.DIM`；有一个 `B.IOR`，其 `source0` 为 `a0`。若 PE 0 到 PE 3 的 `a0` 值为 `1`、`2`、`3` 和 `0`，均小于 `4`，检查通过。目标得到 16 个有效行、64 列和 FP16。

如果 PE 2 的 `a0` 改为 `4`，指令束会在分配任何目标之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-related role=related-owners-navigation -->
## 相关所有者

- [Tile 执行分派](tile-execution.md) 排定各专用选择器的顺序并提交 Local 生成。
- [Shared 搬移](../../../tile/model/memory/shared-movement.md) 定义 Tile 级 `GMOV` 效果。
- [回滚](../faults/rollback.md) 定义如何释放由指令束分配的目标。
- [BSTART.GMOV](../../execution/BSTART.GMOV.md) 是该起始形式的指令页。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-gmov.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","tlsu-gmov"],"depends_on":["PTO-ARCH-STATE-LOCAL-PAYLOAD-GENERATION","PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV-HELPERS","PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-VALIDATION","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-WRITER-EFFECTS","PTO-BLOCK-MODEL-STATE-ATOMIC-TSTORE-SOURCE-LIFETIME","PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT","PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-VALUES"],"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV","surface":"block"}

readonly func BundleGMOVSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 13;
end;

readonly func BundleGMOVPESourceTile(source: TileIndex,
                                     pe: MemoryAgentId) => TileInfo
begin
    if _CurrentPEContextValid && pe == _CurrentMemoryAgent then
        return _Tiles[[source]];
    end;
    return _PEExecutionContexts[[_CurrentModelCore]][[pe]].tiles[[source]];
end;

readonly func BundleGMOVPESourceAvailable(selector: TileIndex,
                                          relative: boolean,
                                          pe: MemoryAgentId) => boolean
begin
    if !relative then
        return BundleGMOVPESourceTile(selector, pe).allocated;
    end;
    let hand = RelativeTileHandIndex(selector);
    let distance = RelativeTileDistance(selector);
    if _CurrentPEContextValid && pe == _CurrentMemoryAgent then
        if _TileRelativeValid[[hand]][distance] == '0' then return FALSE; end;
        return _Tiles[[_TileRelativeOrder[[hand]][[distance]]]].allocated;
    end;
    let context = _PEExecutionContexts[[_CurrentModelCore]][[pe]];
    if context.tile_relative_valid[[hand]][distance] == '0' then
        return FALSE;
    end;
    return context.tiles[[context.tile_relative_order[[hand]][[distance]]]]
        .allocated;
end;

readonly func BundleGMOVPESourceIndex(selector: TileIndex,
                                      relative: boolean,
                                      pe: MemoryAgentId) => TileIndex
begin
    assert BundleGMOVPESourceAvailable(selector, relative, pe);
    if !relative then return selector; end;
    let hand = RelativeTileHandIndex(selector);
    let distance = RelativeTileDistance(selector);
    if _CurrentPEContextValid && pe == _CurrentMemoryAgent then
        return _TileRelativeOrder[[hand]][[distance]];
    end;
    return _PEExecutionContexts[[_CurrentModelCore]][[pe]]
        .tile_relative_order[[hand]][[distance]];
end;

readonly func BundleGMOVPESourcePayloadLive(source: TileIndex,
                                            pe: MemoryAgentId) => boolean
begin
    let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
    if _CurrentPEContextValid && pe == _CurrentMemoryAgent then
        return _Tiles[[source]].allocated &&
               _TilePayloadLiveMasks[[source]][mask_bit] == '1';
    end;
    let context = _PEExecutionContexts[[_CurrentModelCore]][[pe]];
    return context.tiles[[source]].allocated &&
           context.tile_payload_live_masks[[source]][mask_bit] == '1';
end;

readonly func BundleGMOVSourceSelectionIdentityMatches(
    selection: BundleGMOVSourceSelection, selector: TileIndex,
    relative: boolean, participant_mask: bits(4)) => boolean
begin
    return selection.valid && selection.core == _CurrentModelCore &&
           selection.invocation == _CurrentKernelInvocation &&
           selection.origin == _CurrentMemoryOrigin &&
           selection.source_acr == CurrentACR() &&
           selection.producer_site == ReadBPC() &&
           selection.start_instruction == _BundleStartEncodedInstruction &&
           selection.operation_form == _BundleOperation.form_identity &&
           selection.operation_selector == _BundleOperation.selector &&
           selection.raw_selector == selector &&
           selection.relative == relative &&
           selection.participant_mask == participant_mask;
end;

readonly func FindBundleGMOVSourceSelectionOrdinal(ordinal: integer)
    => integer {-1..63}
begin
    for slot = 0 to 63 do
        if _BundleGMOVSourceSelections[[slot]].valid &&
           _BundleGMOVSourceSelections[[slot]].ordinal == ordinal then
            return slot;
        end;
    end;
    return -1;
end;

func CaptureBundleGMOVSourceSelection(selector: TileIndex,
                                      relative: boolean,
                                      participant_mask: bits(4),
                                      prior_ordinal: integer) => integer
begin
    let current_pe = _CurrentMemoryAgent as integer {0..3};
    let current_mask_bit = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    if prior_ordinal > 0 then
        for slot = 0 to 63 do
            if _BundleGMOVSourceSelections[[slot]].valid &&
               _BundleGMOVSourceSelections[[slot]].ordinal == prior_ordinal &&
               BundleGMOVSourceSelectionIdentityMatches(
                   _BundleGMOVSourceSelections[[slot]], selector, relative,
                   participant_mask) &&
               _BundleGMOVSourceSelections[[slot]].captured_mask[
                   current_mask_bit] == '1' &&
               _BundleGMOVSourceSelections[[slot]].domain_tokens[[current_pe]] ==
                   _BundleExecutionDomainToken then return prior_ordinal; end;
        end;
        return 0;
    end;
    var candidate: integer {-1..63} = -1;
    for slot = 0 to 63 do
        if BundleGMOVSourceSelectionIdentityMatches(
               _BundleGMOVSourceSelections[[slot]], selector, relative,
               participant_mask) then
            if _BundleGMOVSourceSelections[[slot]].captured_mask[
                   current_mask_bit] == '1' &&
               _BundleGMOVSourceSelections[[slot]].domain_tokens[[current_pe]] ==
                   _BundleExecutionDomainToken then
                return _BundleGMOVSourceSelections[[slot]].ordinal;
            elsif _BundleGMOVSourceSelections[[slot]].captured_mask[
                      current_mask_bit] == '0' then
                if candidate < 0 ||
                   _BundleGMOVSourceSelections[[slot]].ordinal <
                       _BundleGMOVSourceSelections[[candidate]].ordinal then
                    candidate = slot;
                end;
            end;
        end;
    end;
    if candidate >= 0 then
        _BundleGMOVSourceSelections[[candidate]].captured_mask[
            current_mask_bit] = '1';
        _BundleGMOVSourceSelections[[candidate]].domain_tokens[[current_pe]] =
            _BundleExecutionDomainToken;
        return _BundleGMOVSourceSelections[[candidate]].ordinal;
    end;
    for slot = 0 to 63 do
        if !_BundleGMOVSourceSelections[[slot]].valid then
            _BundleGMOVSourceSelections[[slot]].valid = TRUE;
            _BundleGMOVSourceSelections[[slot]].ordinal =
                _NextBundleGMOVSourceSelectionOrdinal;
            _NextBundleGMOVSourceSelectionOrdinal =
                _NextBundleGMOVSourceSelectionOrdinal + 1;
            _BundleGMOVSourceSelections[[slot]].core = _CurrentModelCore;
            _BundleGMOVSourceSelections[[slot]].invocation =
                _CurrentKernelInvocation;
            _BundleGMOVSourceSelections[[slot]].origin = _CurrentMemoryOrigin;
            _BundleGMOVSourceSelections[[slot]].source_acr = CurrentACR();
            _BundleGMOVSourceSelections[[slot]].producer_site = ReadBPC();
            _BundleGMOVSourceSelections[[slot]].start_instruction =
                _BundleStartEncodedInstruction;
            _BundleGMOVSourceSelections[[slot]].operation_form =
                _BundleOperation.form_identity;
            _BundleGMOVSourceSelections[[slot]].operation_selector =
                _BundleOperation.selector;
            _BundleGMOVSourceSelections[[slot]].raw_selector = selector;
            _BundleGMOVSourceSelections[[slot]].relative = relative;
            _BundleGMOVSourceSelections[[slot]].participant_mask =
                participant_mask;
            _BundleGMOVSourceSelections[[slot]].completed_mask = Zeros{4};
            _BundleGMOVSourceSelections[[slot]].captured_mask = Zeros{4};
            for agent = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                _BundleGMOVSourceSelections[[slot]].domain_tokens[[agent]] = 0;
            end;
            for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                let destination_pe = pe as MemoryAgentId;
                let peer_word = ReadPEAbsoluteGPROperand(destination_pe,
                    _BundleScalarBindings[[0]].source0);
                if UInt(peer_word) >= PTO_MODEL_MEMORY_AGENTS then
                    _BundleGMOVSourceSelections[[slot]].valid = FALSE;
                    return 0;
                end;
                let source_pe = UInt(peer_word) as MemoryAgentId;
                if (source_pe != _CurrentMemoryAgent &&
                    _PEContextBankValid[[_CurrentModelCore]][source_pe] !=
                        '1') ||
                   !BundleGMOVPESourceAvailable(
                       selector, relative, source_pe) then
                    _BundleGMOVSourceSelections[[slot]].valid = FALSE;
                    return 0;
                end;
                let source = BundleGMOVPESourceIndex(
                    selector, relative, source_pe);
                _BundleGMOVSourceSelections[[slot]].source_pes[[pe]] =
                    source_pe;
                _BundleGMOVSourceSelections[[slot]].sources[[pe]] = source;
                _BundleGMOVSourceSelections[[slot]].source_epochs[[pe]] =
                    LocalTilePayloadGeneration(source_pe, source);
            end;
            _BundleGMOVSourceSelections[[slot]].captured_mask[
                current_mask_bit] = '1';
            _BundleGMOVSourceSelections[[slot]].domain_tokens[[current_pe]] =
                _BundleExecutionDomainToken;
            return _BundleGMOVSourceSelections[[slot]].ordinal;
        end;
    end;
    return 0;
end;

func CompleteBundleGMOVSourceSelection(ordinal: integer)
begin
    var selected: integer {-1..63} = -1;
    for slot = 0 to 63 do
        if _BundleGMOVSourceSelections[[slot]].valid &&
           _BundleGMOVSourceSelections[[slot]].ordinal == ordinal then
            selected = slot;
        end;
    end;
    if selected < 0 then return; end;
    let current_pe = _CurrentMemoryAgent as integer {0..3};
    let mask_bit = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    if !BundleGMOVSourceSelectionIdentityMatches(
           _BundleGMOVSourceSelections[[selected]],
           _BundleGMOVSourceSelections[[selected]].raw_selector,
           _BundleGMOVSourceSelections[[selected]].relative,
           _BundleGMOVSourceSelections[[selected]].participant_mask) ||
       _BundleGMOVSourceSelections[[selected]].captured_mask[mask_bit] != '1' ||
       _BundleGMOVSourceSelections[[selected]].domain_tokens[[current_pe]] !=
           _BundleExecutionDomainToken then return; end;
    if _BundleGMOVSourceSelections[[selected]].participant_mask[mask_bit] ==
       '1' then
        _BundleGMOVSourceSelections[[selected]].completed_mask[mask_bit] = '1';
    end;
    if _BundleGMOVSourceSelections[[selected]].completed_mask ==
       _BundleGMOVSourceSelections[[selected]].participant_mask then
        _BundleGMOVSourceSelections[[selected]].valid = FALSE;
    end;
end;

readonly func BundleGMOVCore4SourceReady(selector: TileIndex,
                                         relative: boolean,
                                         selection_ordinal: integer) => boolean
begin
    // Standalone aggregate callers retain the established Core4 batch view.
    // Encoded PE streams instead resolve each destination's private peer_tid
    // against that peer's actual Local bank before any destination effect.
    if !_CurrentPEContextValid then
        return TileElementwiseSourceContentsDefined(selector) &&
               _TileAllocationMasks[[selector]] == '1111';
    end;
    if !_BundleScalarBindings[[0]].valid || selection_ordinal <= 0 then
        return FALSE;
    end;
    let selection_slot = FindBundleGMOVSourceSelectionOrdinal(
        selection_ordinal);
    if selection_slot < 0 then return FALSE; end;
    let selection = _BundleGMOVSourceSelections[[selection_slot]];
    if !BundleGMOVSourceSelectionIdentityMatches(selection, selector,
           relative, _BundleTileBindings[[0]].pe_mask) then return FALSE; end;
    var reference_valid = FALSE;
    var reference: TileInfo;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let destination_pe = pe as MemoryAgentId;
        let source_pe = selection.source_pes[[pe]];
        if source_pe != _CurrentMemoryAgent &&
           _PEContextBankValid[[_CurrentModelCore]][source_pe] != '1' then
            return FALSE;
        end;
        let source = selection.sources[[pe]];
        let source_tile = BundleGMOVPESourceTile(source, source_pe);
        if !BundleGMOVPESourceTileReady(source_tile) ||
           LocalTilePayloadGeneration(source_pe, source) !=
               selection.source_epochs[[pe]] then
            return FALSE;
        end;
        let destination_mask_bit = PTOPEMaskBitOfPEIdentity(destination_pe);
        if selection.participant_mask[destination_mask_bit] == '1' &&
           selection.completed_mask[destination_mask_bit] == '0' &&
           !BundleGMOVPESourcePayloadLive(source, source_pe) then
            return FALSE;
        end;
        if !reference_valid then
            reference = source_tile;
            reference_valid = TRUE;
        elsif !BundleGMOVSourceDescriptorsMatch(reference, source_tile) then
            return FALSE;
        end;
    end;
    return reference_valid;
end;

readonly func BundleGMOVSourceParticipantMask(
    selection_ordinal: integer, source_pe: MemoryAgentId,
    source: TileIndex, source_epoch: integer) => bits(4)
begin
    var participants = Zeros{4};
    assert selection_ordinal > 0;
    let selection_slot = FindBundleGMOVSourceSelectionOrdinal(
        selection_ordinal);
    assert selection_slot >= 0;
    let selection = _BundleGMOVSourceSelections[[selection_slot]];
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let destination_pe = pe as MemoryAgentId;
        let mask_bit = PTOPEMaskBitOfPEIdentity(destination_pe);
        if selection.participant_mask[mask_bit] == '1' &&
           selection.source_pes[[pe]] == source_pe &&
           selection.sources[[pe]] == source &&
           selection.source_epochs[[pe]] == source_epoch then
            participants[mask_bit] = '1';
        end;
    end;
    return participants;
end;

func ExecuteBundleGMOVOperation() => (boolean, BundleLocalGenerationCubeWriterEffects)
begin
    var result_writer_effects = EmptyBundleLocalGenerationCubeWriterEffects();
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if BundleSharedBindingCount() != 0 ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       BundleTileBindingCount() != 1 then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return (FALSE, result_writer_effects); end;
    let binding = _BundleTileBindings[[0]];
    if _CurrentPEContextValid then
        // Capture every destination's peer-selected physical generation before
        // any destination allocation can push a new relative hand entry.
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            let peer_tid = if _BundleScalarBindings[[0]].valid then
                ReadPEAbsoluteGPROperand(agent,
                    _BundleScalarBindings[[0]].source0)
                else Zeros{PTO_XLEN};
            if UInt(peer_tid) >= PTO_MODEL_MEMORY_AGENTS then
                SetFault(Fault_TileLegality, ReadTPC());
                return (FALSE, result_writer_effects);
            end;
        end;
    end;
    let selection_ordinal = if _CurrentPEContextValid then
        CaptureBundleGMOVSourceSelection(binding.source0,
            binding.source0_relative, binding.pe_mask,
            binding.gmov_selection_ordinal)
        else 0;
    if _CurrentPEContextValid && selection_ordinal == 0 then return (FALSE, result_writer_effects); end;
    if _CurrentPEContextValid then
        _BundleTileBindings[[0]].gmov_selection_captured = TRUE;
        _BundleTileBindings[[0]].gmov_selection_ordinal = selection_ordinal;
    end;
    let selection_slot = if selection_ordinal > 0 then
        FindBundleGMOVSourceSelectionOrdinal(selection_ordinal) else 0;
    if _CurrentPEContextValid && selection_slot < 0 then return (FALSE, result_writer_effects); end;
    let current_destination = _CurrentMemoryAgent as integer {0..3};
    let current_source_pe = if _CurrentPEContextValid then
        _BundleGMOVSourceSelections[[selection_slot]]
            .source_pes[[current_destination]]
        else 0 as MemoryAgentId;
    let current_source = if _CurrentPEContextValid then
        _BundleGMOVSourceSelections[[selection_slot]]
            .sources[[current_destination]]
        else binding.source0;
    let current_source_tile = if _CurrentPEContextValid then
        BundleGMOVPESourceTile(current_source, current_source_pe)
        else _Tiles[[current_source]];
    if !binding.destination_valid || !binding.source0_valid ||
       binding.source1_valid || !binding.last ||
       !BundleGMOVCore4SourceReady(binding.source0,
           binding.source0_relative, selection_ordinal) ||
       BundleTileDestinationSizeBytes(0) !=
           current_source_tile.capacity_bytes ||
       !TileCarrierOrPackedBaselineDataTypeSupported(
           TileDataTypeFromEncoding(
               CurrentBundleTileOperationDataTypeCode()
                   as TileDataTypeEncoding)) ||
       current_source_tile.data_type != TileDataTypeFromEncoding(
           CurrentBundleTileOperationDataTypeCode()
               as TileDataTypeEncoding) ||
       current_source_tile.layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    for dimension = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        if UInt(_BundleDimensions[[dimension]]) != 1 then
            SetFault(Fault_TileLegality, ReadTPC());
            return (FALSE, result_writer_effects);
        end;
    end;
    let current_mask_bit = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    // A nonparticipant still performs the immutable Core4 peer, descriptor,
    // generation and readiness preflight above, but has no destination,
    // publication or source-lifetime effect in its private bank.
    if _CurrentPEContextValid &&
       binding.pe_mask[current_mask_bit] == '0' then return (TRUE, result_writer_effects); end;
    if _CurrentPEContextValid && _CurrentKernelInvocation != 0 &&
       binding.pe_mask[current_mask_bit] == '1' &&
       !binding.source0_reuse then
        let source_epoch = _BundleGMOVSourceSelections[[selection_slot]]
            .source_epochs[[current_destination]];
        let participants = BundleGMOVSourceParticipantMask(
            selection_ordinal, current_source_pe, current_source,
            source_epoch);
        let ordinal = CaptureBundleSourceLifetime(FALSE,
            current_source_pe, current_source, source_epoch, 0,
            participants, binding.source0_lifetime_ordinal);
        if ordinal == 0 then return (FALSE, result_writer_effects); end;
        _BundleTileBindings[[0]].source0_lifetime_captured = TRUE;
        _BundleTileBindings[[0]].source0_lifetime_ordinal = ordinal;
    end;
    // GMOV has no dimensions that describe a new shape: the destination
    // carries the resolved peer source shape while B.DATR.Layout selects its
    // physical representation.
    let (destinations_resolved, resolved_writer_effects) =
        ResolveBundleTileDestinationsWithShapeAndTypeAndWriterEffects(
            TRUE, current_source_tile.valid_rows,
            current_source_tile.valid_columns,
            current_source_tile.columns, TRUE,
            current_source_tile.data_type);
    if !destinations_resolved then return (FALSE, result_writer_effects); end;
    var writer_effects = resolved_writer_effects;
    if !ValidateBundleLocalGenerationWritersWithWriterEffects(
           writer_effects) then
        RollBackBundleTileDestinations(); return (FALSE, result_writer_effects);
    end;
    let destination = _BundleTileBindings[[0]].destination;
    let source = current_source;
    let selected_source = if _CurrentPEContextValid then
        current_source_tile else _Tiles[[source]];
    let (writer_found, writer_value) =
        BundleLocalGenerationCubeWriterValueForDestination(
            writer_effects, destination, _Tiles[[destination]]);
    let destination_value = if writer_found then writer_value
        else _Tiles[[destination]];
    if !BundleGMOVPESourceTileReady(selected_source) ||
       !(if writer_found then BundleGMOVDestinationValueMatches(
                 destination_value, selected_source)
          else TileElementwiseDescriptorLegal(destination) &&
               _Tiles[[destination]].rows == selected_source.rows &&
               _Tiles[[destination]].columns == selected_source.columns &&
               _Tiles[[destination]].valid_rows == selected_source.valid_rows &&
               _Tiles[[destination]].valid_columns == selected_source.valid_columns &&
               _Tiles[[destination]].data_type == selected_source.data_type &&
               _Tiles[[destination]].layout == selected_source.layout) ||
       !TileElementwiseLayoutSupported(selected_source.layout) ||
       !TileCarrierOrPackedBaselineDataTypeSupported(
           selected_source.data_type) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return (FALSE, result_writer_effects);
    end;
    if writer_found then
        let target = TileOutputValueTarget {
            destination = destination,
            value = writer_value
        };
        let result = GMOVFromSourceTileToValue(target, selected_source);
        writer_effects = BundleLocalGenerationCubeWriterEffectWithOutput(
            writer_effects, destination, result);
    else
        if _CurrentPEContextValid then
            GMOVFromSourceTile(destination, selected_source);
        else
            GMOV(destination, source, Zeros{PTO_XLEN});
        end;
    end;
    result_writer_effects = writer_effects;
        FinishBundleLocalGenerationCubeWriterEffects(writer_effects);
    if _BundleTileBindings[[0]].source0_lifetime_captured then
        CompleteBundleSourceLifetime(
            _BundleTileBindings[[0]].source0_lifetime_ordinal);
    elsif !_CurrentPEContextValid && !binding.source0_reuse then
        ConsumeTilePayloadForMask(source, binding.pe_mask);
    end;
    if _CurrentPEContextValid then
        CompleteBundleGMOVSourceSelection(selection_ordinal);
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return (TRUE, result_writer_effects);
end;
```
<!-- GENERATED-ASL-END: unit -->
