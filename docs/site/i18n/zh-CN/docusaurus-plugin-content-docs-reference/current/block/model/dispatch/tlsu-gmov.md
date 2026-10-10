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

处理程序读取已收集的指令束状态，只写目标 Tile。

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

设计要点：`BundleGMOVCore4SourceReady` 要求源内容已定义，且其分配掩码为 `1111`。ASL 注释说明，单层模型把四个对等源片段表示为一个 Core4 快照，因此完整分配加完整已定义性就是形式化的就绪证据。

设计要点：对等范围检查遍历全部四个 PE，即使 PE 掩码会抑制某个 PE 的写入。ASL 注释指出每个 PE 都参与对等选择和就绪预检。重复的对等标识是合法的；只约束范围 `0..3`。

检查之后，处理程序以源的形状和类型解析目标，校验 Local 生成写者，并检查 `TileOperandsLegal_GMOV`。后两步任一失败都会调用 `RollBackBundleTileDestinations`，释放本指令束分配的目标。成功时执行 `GMOV` 和 `FinalizeBundleTileAttempt`，后者发布由指令束分配的目标。

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
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV","surface":"block","classification":["model","dispatch","tlsu-gmov"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH","PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT"]}

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

readonly func BundleGMOVPESourceTileReady(tile: TileInfo) => boolean
begin
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile) && tile.contents_defined;
    end;
    return TileInfoDescriptorLegal(tile);
end;

readonly func BundleGMOVSourceDescriptorsMatch(left: TileInfo,
                                                right: TileInfo) => boolean
begin
    return left.capacity_bytes == right.capacity_bytes &&
           left.rows == right.rows && left.columns == right.columns &&
           left.valid_rows == right.valid_rows &&
           left.valid_columns == right.valid_columns &&
           left.data_type == right.data_type &&
           left.layout == right.layout &&
           left.storage_kind == right.storage_kind &&
           left.cube_k_repeat == right.cube_k_repeat &&
           left.cube_n_repeat == right.cube_n_repeat &&
           left.cube_cell_count == right.cube_cell_count &&
           left.cube_storage_bytes == right.cube_storage_bytes;
end;

readonly func BundleGMOVCore4SourceReady(source: TileIndex) => boolean
begin
    // Standalone aggregate callers retain the established Core4 batch view.
    // Encoded PE streams instead resolve each destination's private peer_tid
    // against that peer's actual Local bank before any destination effect.
    if !_CurrentPEContextValid then
        return TileElementwiseSourceContentsDefined(source) &&
               _TileAllocationMasks[[source]] == '1111';
    end;
    if !_BundleScalarBindings[[0]].valid then return FALSE; end;
    var reference_valid = FALSE;
    var reference: TileInfo;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let destination_pe = pe as MemoryAgentId;
        let peer_word = ReadPEAbsoluteGPROperand(destination_pe,
            _BundleScalarBindings[[0]].source0);
        if UInt(peer_word) >= PTO_MODEL_MEMORY_AGENTS then return FALSE; end;
        let source_pe = UInt(peer_word) as MemoryAgentId;
        if source_pe != _CurrentMemoryAgent &&
           _PEContextBankValid[[_CurrentModelCore]][source_pe] != '1' then
            return FALSE;
        end;
        let source_tile = BundleGMOVPESourceTile(source, source_pe);
        if !BundleGMOVPESourceTileReady(source_tile) then return FALSE; end;
        if !reference_valid then
            reference = source_tile;
            reference_valid = TRUE;
        elsif !BundleGMOVSourceDescriptorsMatch(reference, source_tile) then
            return FALSE;
        end;
    end;
    return reference_valid;
end;

func ExecuteBundleGMOVOperation() => boolean
begin
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if BundleSharedBindingCount() != 0 ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       BundleTileBindingCount() != 1 then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let current_peer_word = if _CurrentPEContextValid &&
        _BundleScalarBindings[[0]].valid then
        ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
            _BundleScalarBindings[[0]].source0)
        else Zeros{PTO_XLEN};
    if UInt(current_peer_word) >= PTO_MODEL_MEMORY_AGENTS then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let current_source_tile = if _CurrentPEContextValid then
        BundleGMOVPESourceTile(binding.source0,
            UInt(current_peer_word) as MemoryAgentId)
        else _Tiles[[binding.source0]];
    if !binding.destination_valid || !binding.source0_valid ||
       binding.source1_valid || !binding.last ||
       !BundleGMOVCore4SourceReady(binding.source0) ||
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
        return FALSE;
    end;
    for dimension = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        if UInt(_BundleDimensions[[dimension]]) != 1 then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    end;
    // Every PE participates in peer selection and readiness preflight even
    // when PE_MASK suppresses that PE's destination request/write.  Repeated
    // peer identifiers are legal; only the absolute 0..3 range is constrained.
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        let peer_tid = if _BundleScalarBindings[[0]].valid then
            ReadPEAbsoluteGPROperand(agent,
                _BundleScalarBindings[[0]].source0)
            else Zeros{PTO_XLEN};
        if UInt(peer_tid) >= PTO_MODEL_MEMORY_AGENTS then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    end;
    // GMOV has no dimensions that describe a new shape: the destination
    // carries the resolved peer source shape while B.DATR.Layout selects its
    // physical representation.
    if !ResolveBundleTileDestinationsWithShapeAndType(
           TRUE, current_source_tile.valid_rows,
           current_source_tile.valid_columns,
           current_source_tile.columns, TRUE,
           current_source_tile.data_type) then return FALSE; end;
    if !ValidateBundleLocalGenerationWriters() then
        RollBackBundleTileDestinations(); return FALSE;
    end;
    let destination = _BundleTileBindings[[0]].destination;
    let source = binding.source0;
    let selected_source = if _CurrentPEContextValid then
        current_source_tile else _Tiles[[source]];
    if !BundleGMOVPESourceTileReady(selected_source) ||
       !TileElementwiseDescriptorLegal(destination) ||
       _Tiles[[destination]].rows != selected_source.rows ||
       _Tiles[[destination]].columns != selected_source.columns ||
       _Tiles[[destination]].valid_rows != selected_source.valid_rows ||
       _Tiles[[destination]].valid_columns != selected_source.valid_columns ||
       _Tiles[[destination]].data_type != selected_source.data_type ||
       _Tiles[[destination]].layout != selected_source.layout ||
       !TileElementwiseLayoutSupported(selected_source.layout) ||
       !TileCarrierOrPackedBaselineDataTypeSupported(
           selected_source.data_type) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if _CurrentPEContextValid then
        GMOVFromSourceTile(destination, selected_source);
    else
        GMOV(destination, source, Zeros{PTO_XLEN});
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
