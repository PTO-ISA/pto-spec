<!-- GENERATED FROM: asl/block/model/state/shared-generation-state.asl -->
# Shared Generation State

**Normative ASL source:** `asl/block/model/state/shared-generation-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-SHARED-GENERATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-purpose role=purpose-scope -->
## 用途与范围

本单元拥有清除、复位、查询和中止 Shared 代次记录的状态操作，并负责按 Core 与 invocation 清理实际 PE 请求元数据。Shared 代次是一个进行中的 `B.ASSEMBLE` 构建，可在发布前接收若干贡献。

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-concepts role=concepts-state -->
## 概念与可见状态

`_SharedGenerations` 为每个 Shared Tile ID 保存一条记录，共 `PTO_SHARED_TILE_COUNT` 条记录。每条记录跟踪：

- 生命周期标志 `open`、`closed` 和 `published`；
- Shared Tile ID、逻辑参与者掩码、父级大小码和单元数，以及实际 PE 所有权、Core/invocation 身份、操作序号和请求来源；
- `covered_cells` 和 `ready_cells` 位图、`arrived_participants`、每 PE 请求令牌与程序顺序，以及 `released_participants`；
- 专用的生产者输入和元数据，以及一个有效标志；
- `last_seen`；
- Tile 的一个工作副本（`working_tile`），以及 `working_valid` 和 `working_initialized_mask`。

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-rules role=rules-interactions -->
## 规则与交互

`ClearBundleSharedGenerationState(id)` 清除一个 ID 的活动记录，但保留其 `next_operation_ordinal`；它保留 Shared Tile ID，将其他活动标志、掩码、位图、身份和输入复位，并从当前已发布的 Shared Tile 重新加载 `working_tile`。

`ResetBundleSharedGenerationState` 清除每条记录，并将每个 `next_operation_ordinal` 初始化为零。`BundleSharedGenerationOpen(id)` 报告 `open` 标志。`AbortBundleSharedGeneration(id)` 清除一条活动代次记录并保留其下一个序号。

设计要点：中止会丢弃该记录的活动候选、身份、覆盖和释放记账，但不改变已发布的 Shared Tile，也不回退下一个序号。工作副本从已发布的 Tile 重新加载，因此被拒绝或故障的未完成组装会保留原有 Shared 对象，符合 `PTO-B-ASSEMBLE-SHARED-GENERATION-001`。

设计要点：挂起的 Shared 代次在完整的集体发布之前始终位于架构 `S` 寄存器堆之外。其他读者看到的要么是旧对象，要么是完整的新对象，永远不会看到部分组装的 Tile。

请求 squash 所有者在中止未完成的实际 PE 候选前，会匹配 Core、invocation 和真实到达令牌。清除候选前，它会标记相应的活动及已保存 PE/陷阱绑定，因此上下文恢复无法复活该请求。Squash 会保留已发布代次及其待处理释放。另一个所有者 `RetirePEOwnedSharedGenerationsForInvocation` 会清理目标 Core 与 invocation 的实际 PE 记录，包括未消费的释放元数据，同时保留已发布 Shared Tile、下一个序号及其他 Core、invocation 和聚合记录；内核 End 和 Abort 会调用该清理所有者。

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-boundaries role=boundaries -->
## 架构边界

本单元不执行范围准入或候选发布。Shared 代次操作数单元拥有低层范围验证和聚合辅助操作；相邻的 per-PE 请求单元拥有编码请求身份、实际 PE 贡献和保留释放。相关所有者链接分别指向这两条路径。

Shared 代次记录不会被 `ClearBundleHeaderState` 清除。未完成记录由各自的操作级中止或发布路径关闭；实际 PE 请求元数据还会在 invocation End/Abort 时清理，而聚合记录和已发布 Shared Tile 仍由原有所有者管理。

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

对 Shared Tile 19 的四 PE 编码组装只有在第四个实际请求提供范围后才发布。如果中止未完成候选，其活动覆盖和请求/释放元数据会被清除，下一个操作序号会保留，先前发布的 Shared Tile 仍可读取。Invocation End 或 Abort 会清理该 Core 与 invocation 的实际 PE 释放记账，而不会清除已发布 Tile 或其他 invocation 的记录。

<!-- PTO-READER-BLOCK: block-model-state-shared-generation-state-related role=related-owners-navigation -->
## 相关所有者

- [Shared 代次](../operands/shared-generation.md)拥有低层范围和聚合操作；[per-PE Shared 代次请求](../operands/shared-generation-pe-requests.md)拥有编码捕获、贡献和释放。
- [Shared 寄存器](../../../tile/model/state/shared-registers.md)拥有已发布的 Shared Tile。
- [Tile 执行](../dispatch/tile-execution.md)在操作失败后中止目标代次；[内核生命周期](../../../arch/state/kernel-lifecycle.md)在 invocation End/Abort 时清理实际 PE 请求元数据。
- [B.ASSEMBLE](../../operands/B.ASSEMBLE.md) 是命令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/shared-generation-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-SHARED-GENERATION","surface":"block","classification":["model","state","shared-generation-state"],"depends_on":["PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-STATE-SHARED-REGISTERS","PTO-TILE-MODEL-STATE-DESCRIPTORS","PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY"]}
readonly func BundleSharedGenerationStorageRow(
    tile: TileInfo, element: integer {0..524287})
    => integer {0..524287}
begin
    if tile.layout == TileLayout_RowMajor then
        let row_local_pairs = PackedTileDataTypeUsesRowLocalPairs(
            tile.data_type) && tile.columns MOD 2 == 1;
        let row_pitch = if row_local_pairs then
            ((PackedTileRowPairColumns(
                tile.columns as integer {1..65535}) * 2)
                as integer {1..65536})
            else tile.columns as integer {1..65535};
        return (element DIVRM row_pitch) as integer {0..524287};
    elsif tile.layout == TileLayout_ColumnMajor then
        let rows = tile.rows as integer {1..65535};
        return (element MOD rows) as integer {0..524287};
    else
        let inner_elements = TileFractalInnerElements(tile.data_type)
            as integer {4..64};
        let block_rows = (tile.rows DIVRM 16) as integer {1..4096};
        let block_columns = (tile.columns DIVRM inner_elements)
            as integer {1..16384};
        let block_elements = (16 * inner_elements)
            as integer {64..1024};
        let block = (element DIVRM block_elements)
            as integer {0..8191};
        let within_block = (element MOD block_elements)
            as integer {0..1023};
        if tile.layout == TileLayout_ZN then
            let block_row = (block DIVRM block_columns)
                as integer {0..8191};
            let inner_row = (within_block MOD 16)
                as integer {0..15};
            return (block_row * 16 + inner_row)
                as integer {0..524287};
        end;
        assert tile.layout == TileLayout_NZ;
        let block_row = (block MOD block_rows) as integer {0..8191};
        let inner_row = (within_block DIVRM inner_elements)
            as integer {0..255};
        return (block_row * 16 + inner_row) as integer {0..524287};
    end;
end;

readonly func BundleSharedGenerationStorageColumn(
    tile: TileInfo, element: integer {0..524287})
    => integer {0..524287}
begin
    if tile.layout == TileLayout_RowMajor then
        let row_local_pairs = PackedTileDataTypeUsesRowLocalPairs(
            tile.data_type) && tile.columns MOD 2 == 1;
        let row_pitch = if row_local_pairs then
            ((PackedTileRowPairColumns(
                tile.columns as integer {1..65535}) * 2)
                as integer {1..65536})
            else tile.columns as integer {1..65535};
        return (element MOD row_pitch) as integer {0..524287};
    elsif tile.layout == TileLayout_ColumnMajor then
        let rows = tile.rows as integer {1..65535};
        return (element DIVRM rows) as integer {0..524287};
    else
        let inner_elements = TileFractalInnerElements(tile.data_type)
            as integer {4..64};
        let block_rows = (tile.rows DIVRM 16) as integer {1..4096};
        let block_columns = (tile.columns DIVRM inner_elements)
            as integer {1..16384};
        let block_elements = (16 * inner_elements)
            as integer {64..1024};
        let block = (element DIVRM block_elements)
            as integer {0..8191};
        let within_block = (element MOD block_elements)
            as integer {0..1023};
        if tile.layout == TileLayout_ZN then
            let block_column = (block MOD block_columns)
                as integer {0..16383};
            let inner_column = (within_block DIVRM 16)
                as integer {0..63};
            return (block_column * inner_elements + inner_column)
                as integer {0..524287};
        end;
        assert tile.layout == TileLayout_NZ;
        let block_column = (block DIVRM block_rows)
            as integer {0..8191};
        let inner_column = (within_block MOD inner_elements)
            as integer {0..63};
        return (block_column * inner_elements + inner_column)
            as integer {0..524287};
    end;
end;

readonly func BundleSharedGenerationStorageCoordinateIsLogical(
    tile: TileInfo, element: integer {0..524287}) => boolean
begin
    return BundleSharedGenerationStorageRow(tile, element) < tile.rows &&
           BundleSharedGenerationStorageColumn(tile, element) < tile.columns;
end;

readonly func BundleSharedGenerationPlacedExtent(
    source: TileInfo, destination: TileInfo,
    copied_elements: integer {0..524288},
    destination_offset: integer {0..524287},
    previous_extent: integer {0..65535},
    by_column: boolean) => integer {0..65535}
begin
    var extent = previous_extent;
    for row = 0 to source.valid_rows - 1 looplimit 65536 do
        for column = 0 to source.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(source,
                row as integer {0..65535},
                column as integer {0..65535})
                as integer {0..524287};
            if source_element < copied_elements then
                let destination_element = (destination_offset + source_element)
                    as integer {0..524287};
                if BundleSharedGenerationStorageCoordinateIsLogical(
                    destination, destination_element) then
                    let coordinate = if by_column then
                        BundleSharedGenerationStorageColumn(
                            destination, destination_element)
                        else BundleSharedGenerationStorageRow(
                            destination, destination_element);
                    if coordinate + 1 > extent then
                        extent = (coordinate + 1) as integer {0..65535};
                    end;
                end;
            end;
        end;
    end;
    return extent;
end;

readonly func SharedGenerationPEBit(pe: MemoryAgentId) => bits(4)
begin
    var participant = Zeros{4};
    participant[PTOPEMaskBitOfPEIdentity(
        pe as integer {0..PTO_MODEL_MEMORY_AGENTS-1})] = '1';
    return participant;
end;

readonly func BundleSharedGenerationReadyCellsWithRange(
    tile: TileInfo, prior_ready: bits(8192),
    offset_cells: integer {0..8192},
    coverage_cells: integer {0..8192}) => bits(8192)
begin
    let element_bits = TileElementBits(tile.data_type)
        as integer {1..64};
    let elements_per_cell = ((32 * 8) DIVRM element_bits)
        as integer {1..256};
    let capacity_elements = TileLogicalElementCapacity(
        tile.capacity_bytes, tile.data_type);
    var ready = prior_ready;
    for cell = 0 to 8191 do
        if cell < coverage_cells then
            let target_cell = (offset_cells + cell) as integer {0..8191};
            let first_element = (target_cell * elements_per_cell)
                as integer {0..524287};
            var cell_ready = TRUE;
            for lane = 0 to 255 do
                if lane < elements_per_cell then
                    let element = (first_element + lane)
                        as integer {0..524287};
                    if element < capacity_elements then
                        let row = BundleSharedGenerationStorageRow(
                            tile, element);
                        let column = BundleSharedGenerationStorageColumn(
                            tile, element);
                        if row < tile.valid_rows &&
                           column < tile.valid_columns &&
                           !TileLogicalElementDefined(tile,
                               element as PackedTileElementIndex) then
                            cell_ready = FALSE;
                        end;
                    end;
                end;
            end;
            ready[target_cell] = if cell_ready then '1' else '0';
        end;
    end;
    return ready;
end;

func ClearBundleSharedGenerationState(shared_tile_id: SharedTileID)
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    let next_operation_ordinal =
        _SharedGenerations[[index]].next_operation_ordinal;
    ReleaseSharedTileGenerationCapacity(shared_tile_id);
    _SharedGenerations[[index]].open = FALSE;
    _SharedGenerations[[index]].closed = FALSE;
    _SharedGenerations[[index]].published = FALSE;
    _SharedGenerations[[index]].shared_tile_id = shared_tile_id;
    _SharedGenerations[[index]].participant_mask = Zeros{4};
    _SharedGenerations[[index]].core_identity = 0 as PTOModelCoreIdentity;
    _SharedGenerations[[index]].invocation_identity = 0;
    _SharedGenerations[[index]].origin = MemoryEventOrigin_NonKernel;
    _SharedGenerations[[index]].source_acr = 0 as AccessControlRing;
    _SharedGenerations[[index]].producer_site = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].start_instruction = Zeros{64};
    _SharedGenerations[[index]].operation_form = Zeros{7};
    _SharedGenerations[[index]].operation_selector = Zeros{10};
    _SharedGenerations[[index]].operation_ordinal = 0;
    _SharedGenerations[[index]].next_operation_ordinal =
        next_operation_ordinal;
    _SharedGenerations[[index]].actual_pe_owned = FALSE;
    _SharedGenerations[[index]].parent_size_code = 0;
    _SharedGenerations[[index]].parent_cell_count = 0;
    _SharedGenerations[[index]].covered_cells = Zeros{8192};
    _SharedGenerations[[index]].ready_cells = Zeros{8192};
    _SharedGenerations[[index]].arrived_participants = Zeros{4};
    _SharedGenerations[[index]].released_participants = Zeros{4};
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        _SharedGenerations[[index]].arrival_request_tokens[[pe]] = 0;
        _SharedGenerations[[index]].arrival_program_orders[[pe]] = 0;
    end;
    _SharedGenerations[[index]].specialized_inputs_valid = FALSE;
    _SharedGenerations[[index]].specialized_input0 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_input1 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_input2 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_input3 = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].specialized_metadata = Zeros{PTO_XLEN};
    _SharedGenerations[[index]].last_seen = FALSE;
    _SharedGenerations[[index]].working_valid = FALSE;
    _SharedGenerations[[index]].working_tile =
        _SharedTiles[[index]].tile;
    _SharedGenerations[[index]].working_initialized_mask = Zeros{4};
end;

func ResetBundleSharedGenerationState()
begin
    for raw_id = 0 to PTO_SHARED_TILE_COUNT - 1 do
        let shared_tile_id = (Zeros{6} + raw_id) as SharedTileID;
        ClearBundleSharedGenerationState(shared_tile_id);
        _SharedGenerations[[SharedTileArrayIndex(shared_tile_id)]]
            .next_operation_ordinal = 0;
    end;
end;

readonly func BundleSharedGenerationOpen(shared_tile_id: SharedTileID)
    => boolean
begin
    return _SharedGenerations[[SharedTileArrayIndex(shared_tile_id)]].open;
end;

func AbortBundleSharedGeneration(shared_tile_id: SharedTileID)
begin
    ClearBundleSharedGenerationState(shared_tile_id);
end;

func PublishPEOwnedSharedGeneration(shared_tile_id: SharedTileID,
                                    participant_mask: bits(4))
begin
    let index = SharedTileArrayIndex(shared_tile_id);
    _SharedTiles[[index]].descriptor_valid = TRUE;
    _SharedTiles[[index]].payload_live = TRUE;
    _SharedTiles[[index]].payload_generation =
        _SharedTiles[[index]].payload_generation + 1;
    _SharedTiles[[index]].allocation_mask = participant_mask;
    _SharedTiles[[index]].initialized_mask = participant_mask;
    _SharedTiles[[index]].whole_parent_ready = TRUE;
    _SharedTiles[[index]].published = TRUE;
    _SharedTiles[[index]].tile = _SharedGenerations[[index]].working_tile;
    ReleaseSharedTileGenerationCapacity(shared_tile_id);
end;

// Invocation lifecycle retirement discards only the active-PE Shared
// operation metadata owned by the retiring Core and invocation. Clearing the
// candidate leaves its published Shared parent and monotonically increasing
// operation ordinal intact. Legacy aggregate records have no invocation
// identity and remain under their existing operation-specific owner.
func RetirePEOwnedSharedGenerationsForInvocation(
    core: PTOModelCoreIdentity, invocation: integer)
begin
    if invocation == 0 then return; end;
    let original_core = _CurrentModelCore;
    let original_pe = _CurrentMemoryAgent;
    if core != original_core then
        // Shared-generation storage is in the Core context bank. Select the
        // target bank explicitly; selection saves the caller's live PE/Core
        // context and the restore below leaves it unchanged.
        SelectExecutionContext(core, original_pe);
    end;
    for raw_id = 0 to PTO_SHARED_TILE_COUNT - 1 do
        let shared_tile_id = (Zeros{6} + raw_id) as SharedTileID;
        let index = SharedTileArrayIndex(shared_tile_id);
        if _SharedGenerations[[index]].actual_pe_owned &&
           _SharedGenerations[[index]].core_identity == core &&
           _SharedGenerations[[index]].invocation_identity == invocation then
            ClearBundleSharedGenerationState(shared_tile_id);
        end;
    end;
    SaveSelectedCoreExecutionContext();
    if core != original_core then
        SelectExecutionContext(original_core, original_pe);
    end;
end;

// A squashed Shared request may also be present in a saved PE image or in a
// nested ACR trap image. Mark every retained copy by its globally unique
// execution-domain token so recovery cannot resurrect the canceled request.
func MarkBundleSharedRequestDomainSquashed(domain: integer)
begin
    if domain == 0 then return; end;
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid &&
           _BundleSharedBindings[[binding]].destination_assemble
               .shared_request_identity_valid &&
           _BundleSharedBindings[[binding]].destination_assemble
               .shared_request_execution_domain == domain then
            _BundleSharedBindings[[binding]].destination_assemble
                .shared_request_squashed = TRUE;
            _BundleSharedBindings[[binding]].destination_assemble
                .shared_request_waiting = TRUE;
        end;
    end;
    for acr = 0 to PTO_ACR_COUNT - 1 do
        for binding = 0 to 3 do
            if _TrapContexts[[acr]].bundle_shared_bindings[[binding]].valid &&
               _TrapContexts[[acr]].bundle_shared_bindings[[binding]]
                   .destination_assemble.valid &&
               _TrapContexts[[acr]].bundle_shared_bindings[[binding]]
                   .destination_assemble.shared_request_identity_valid &&
               _TrapContexts[[acr]].bundle_shared_bindings[[binding]]
                   .destination_assemble.shared_request_execution_domain ==
                       domain then
                _TrapContexts[[acr]].bundle_shared_bindings[[binding]]
                    .destination_assemble.shared_request_squashed = TRUE;
                _TrapContexts[[acr]].bundle_shared_bindings[[binding]]
                    .destination_assemble.shared_request_waiting = TRUE;
            end;
        end;
    end;
    for core = 0 to PTO_MODEL_CORE_INSTANCES - 1 do
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            if _PEContextBankValid[[core]][pe] == '1' then
                for binding = 0 to 3 do
                    if _PEExecutionContexts[[core]][[pe]]
                           .bundle_shared_bindings[[binding]].valid &&
                       _PEExecutionContexts[[core]][[pe]]
                           .bundle_shared_bindings[[binding]]
                           .destination_assemble.valid &&
                       _PEExecutionContexts[[core]][[pe]]
                           .bundle_shared_bindings[[binding]]
                           .destination_assemble.shared_request_identity_valid &&
                       _PEExecutionContexts[[core]][[pe]]
                           .bundle_shared_bindings[[binding]]
                           .destination_assemble.shared_request_execution_domain ==
                               domain then
                        _PEExecutionContexts[[core]][[pe]]
                            .bundle_shared_bindings[[binding]]
                            .destination_assemble.shared_request_squashed = TRUE;
                        _PEExecutionContexts[[core]][[pe]]
                            .bundle_shared_bindings[[binding]]
                            .destination_assemble.shared_request_waiting = TRUE;
                    end;
                end;
                for acr = 0 to PTO_ACR_COUNT - 1 do
                    for binding = 0 to 3 do
                        if _PEExecutionContexts[[core]][[pe]].trap_contexts[[acr]]
                               .bundle_shared_bindings[[binding]].valid &&
                           _PEExecutionContexts[[core]][[pe]]
                               .trap_contexts[[acr]]
                               .bundle_shared_bindings[[binding]]
                               .destination_assemble.valid &&
                           _PEExecutionContexts[[core]][[pe]]
                               .trap_contexts[[acr]]
                               .bundle_shared_bindings[[binding]]
                               .destination_assemble.shared_request_identity_valid &&
                           _PEExecutionContexts[[core]][[pe]]
                               .trap_contexts[[acr]]
                               .bundle_shared_bindings[[binding]]
                               .destination_assemble.shared_request_execution_domain ==
                                   domain then
                            _PEExecutionContexts[[core]][[pe]]
                                .trap_contexts[[acr]]
                                .bundle_shared_bindings[[binding]]
                                .destination_assemble.shared_request_squashed = TRUE;
                            _PEExecutionContexts[[core]][[pe]]
                                .trap_contexts[[acr]]
                                .bundle_shared_bindings[[binding]]
                                .destination_assemble.shared_request_waiting = TRUE;
                        end;
                    end;
                end;
            end;
        end;
    end;
    for binding = 0 to 3 do
        if _DefaultPEExecutionContext.bundle_shared_bindings[[binding]].valid &&
           _DefaultPEExecutionContext.bundle_shared_bindings[[binding]]
               .destination_assemble.valid &&
           _DefaultPEExecutionContext.bundle_shared_bindings[[binding]]
               .destination_assemble.shared_request_identity_valid &&
           _DefaultPEExecutionContext.bundle_shared_bindings[[binding]]
               .destination_assemble.shared_request_execution_domain == domain then
            _DefaultPEExecutionContext.bundle_shared_bindings[[binding]]
                .destination_assemble.shared_request_squashed = TRUE;
            _DefaultPEExecutionContext.bundle_shared_bindings[[binding]]
                .destination_assemble.shared_request_waiting = TRUE;
        end;
    end;
    for acr = 0 to PTO_ACR_COUNT - 1 do
        for binding = 0 to 3 do
            if _DefaultPEExecutionContext.trap_contexts[[acr]]
                   .bundle_shared_bindings[[binding]].valid &&
               _DefaultPEExecutionContext.trap_contexts[[acr]]
                   .bundle_shared_bindings[[binding]].destination_assemble.valid &&
               _DefaultPEExecutionContext.trap_contexts[[acr]]
                   .bundle_shared_bindings[[binding]]
                   .destination_assemble.shared_request_identity_valid &&
               _DefaultPEExecutionContext.trap_contexts[[acr]]
                   .bundle_shared_bindings[[binding]]
                   .destination_assemble.shared_request_execution_domain == domain then
                _DefaultPEExecutionContext.trap_contexts[[acr]]
                    .bundle_shared_bindings[[binding]]
                    .destination_assemble.shared_request_squashed = TRUE;
                _DefaultPEExecutionContext.trap_contexts[[acr]]
                    .bundle_shared_bindings[[binding]]
                    .destination_assemble.shared_request_waiting = TRUE;
            end;
        end;
    end;
end;

// Squash invalidates a request identity everywhere it is retained before it
// aborts the matching incomplete candidate. Published generations remain
// irrevocable, including their outstanding per-PE completion tokens.
func SquashPEOwnedSharedGenerationRequest(
    core: PTOModelCoreIdentity, invocation: integer, domain: integer)
begin
    if domain == 0 || invocation == 0 then return; end;
    for raw_id = 0 to PTO_SHARED_TILE_COUNT - 1 do
        let shared_tile_id = (Zeros{6} + raw_id) as SharedTileID;
        let index = SharedTileArrayIndex(shared_tile_id);
        if _SharedGenerations[[index]].actual_pe_owned &&
           !_SharedGenerations[[index]].published &&
           _SharedGenerations[[index]].core_identity == core &&
           _SharedGenerations[[index]].invocation_identity == invocation then
            var matching_arrival = FALSE;
            for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                if _SharedGenerations[[index]].arrived_participants[
                       PTOPEMaskBitOfPEIdentity(pe)] == '1' &&
                   _SharedGenerations[[index]].arrival_request_tokens[[pe]] ==
                       domain then
                    matching_arrival = TRUE;
                end;
            end;
            if matching_arrival then
                MarkBundleSharedRequestDomainSquashed(domain);
                AbortBundleSharedGeneration(shared_tile_id);
            end;
        end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
