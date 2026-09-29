<!-- GENERATED FROM: asl/block/model/dispatch/shared-tlsu.asl -->
# Shared TLSU

**Normative ASL source:** `asl/block/model/dispatch/shared-tlsu.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-shared-tlsu-purpose role=purpose-scope -->
## 用途与范围

本单元是通过 `B.IOS` 指定 Shared Tile 的 TLSU 指令束的指令束级处理程序。Shared Tile 是对一个核的全部四个 PE 可见的 Tile 寄存器。本单元涵盖三个功能：加载到 Shared Tile 的 `TLOAD`（功能号 `0`）、从 Shared Tile 存储的 `TSTORE`（功能号 `1`），以及在 Local Tile 与 Shared Tile 之间搬移的 `TMOV`（功能号 `2`）。

对于有效的 `TileMemory` 描述符，当选择器有效且至少存在一个物理 Shared 绑定时，`BundleSharedTLSUSelected` 成立。随后 `ExecuteBundleSharedTLSUOperation` 校验并执行所选功能。

<!-- PTO-READER-BLOCK: block-model-dispatch-shared-tlsu-concepts role=concepts-state -->
## 概念与可见状态

处理程序读取唯一的 Shared 绑定：其 Shared Tile ID、大小码、PE 掩码，以及它是目标、复用生成目标、源子视图还是组装写者。

- `TLOAD`（`0`）需要 Shared 目标或复用目标，不带 `B.IOT`，并由 `LB0`、`LB1`、`LB2` 给出有效列数、有效行数和物理列数。
- `TSTORE`（`1`）需要 Shared 源，不带 `B.IOT`，且 PE 掩码被 `SharedStorePEMaskLegal` 接受。
- `TMOV`（`2`）需要一个 `B.IOT`。Shared 为目标时，`B.IOT` 指定 Local 源。Shared 为源时，`B.IOT` 指定 Local 目标。

对于 `TLOAD` 和 `TSTORE`，每个 PE 从自己的 GPR 读取 `B.IOR` 基地址和以字节计的行步长。没有 `B.IOR` 时，基址为零，步长为稠密行大小。

<!-- PTO-READER-BLOCK: block-model-dispatch-shared-tlsu-rules role=rules-interactions -->
## 规则与交互

处理程序依次检查：恰好一个物理 Shared 绑定，否则 `Fault_TileLegality`；零 Shared PE 掩码无效果地返回成功；未知的 TLSU 代码引发 `Fault_IllegalInstruction`；对于功能号 `0` 和 `1`，数据类型必须通过 `TileRegularTLSUDataTypeSupported`；非法的 `B.IOR` schema 引发 `Fault_BundleControl`；然后是数据属性。`0`、`1`、`2` 以外的功能号引发 `Fault_TileLegality`。

设计要点：`TSTORE` 或 Shared 到 Local 的 `TMOV` 首先测试 `SharedTilePublished`。若 Shared Tile 尚未发布，处理程序返回失败但不引发故障。ASL 注释称之为父级就绪闸门：块保持活动，以便在发布后重试提交，且没有载荷读取、绑定消耗或全局内存效果。

设计要点：当 Shared 目标由多个写者组装时，`TLOAD` 和 `TMOV` 先写候选记录，再用 `CommitBundleSharedGenerationCandidate` 提交。对于 `TLOAD`，注释指出在首次故障时部分候选保留在原处，因此较早的读取仍可观察，但它既未就绪也未发布。

Shared 到 Local 的 `TMOV` 解析 Local 目标，然后要求其行数、列数、有效形状、数据类型和布局等于 Shared 视图。不匹配时回滚目标并引发 `Fault_TileLegality`。

最后，任何故障都会回滚由指令束分配的 Local 目标。成功时处理程序用 `ConsumeBundleSharedBindings` 消耗 Shared 绑定，并调用 `FinalizeBundleTileAttempt`。

<!-- PTO-READER-BLOCK: block-model-dispatch-shared-tlsu-boundaries role=boundaries -->
## 架构边界

`ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` 在各专用选择器中最后测试本选择器，位于 `TPREFETCH` 之后。若没有选择器匹配但仍有未消耗的 Shared 绑定，该调用者引发 `Fault_TileLegality`。

Shared 记录格式、发布以及组装协议属于 Shared 生成和 Shared 搬移所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-shared-tlsu-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设一个 `TSTORE` 指令束以 PE 掩码 `1111` 绑定 Shared Tile `s2`，对 FP32 把 `LB0` 设为 32、`LB1` 设为 8、`LB2` 设为 32，且没有 `B.IOR`。每个 PE 使用基址零和步长 32 乘 4，即 128 字节。若 `s2` 仍在由另一个指令束组装，`SharedTilePublished` 为假，提交返回但不引发故障；指令束保持活动。`s2` 发布后，重试的提交存储 8 行。

<!-- PTO-READER-BLOCK: block-model-dispatch-shared-tlsu-related role=related-owners-navigation -->
## 相关所有者

- [Shared 绑定](../operands/shared-bindings.md) 定义绑定消耗。
- [Shared 生成](../operands/shared-generation.md) 定义组装的提交与中止。
- [Shared 搬移](../../../tile/model/memory/shared-movement.md) 定义 `TLOADShared`、`TSTOREShared` 以及 `TMOV` 效果。
- [Tile 执行分派](tile-execution.md) 排定各专用选择器的顺序。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/shared-tlsu.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU","surface":"block","classification":["model","dispatch","shared-tlsu"],"depends_on":["PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS"]}
readonly func BundleSharedTLSUSelected() => boolean
begin
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       !_BundleOperation.selector_valid then return FALSE; end;
    let function = UInt(_BundleOperation.selector[4:0]);
    return BundleSharedBindingPhysicalCount() > 0;
end;

readonly func BundleSharedStoreValidColumns(shared_tile_id: SharedTileID)
    => integer {0..65535}
begin
    if UInt(_BundleDimensions[[0]]) <= 65535 then
        return UInt(_BundleDimensions[[0]]) as integer {0..65535};
    end;
    return 0;
end;

readonly func BundleSharedStoreValidRows(shared_tile_id: SharedTileID)
    => integer {0..65535}
begin
    if UInt(_BundleDimensions[[1]]) <= 65535 then
        return UInt(_BundleDimensions[[1]]) as integer {0..65535};
    end;
    return 0;
end;

readonly func BundleSharedStoreColumns(shared_tile_id: SharedTileID,
                                        valid_columns: integer {0..65535})
    => integer {0..65535}
begin
    if UInt(_BundleDimensions[[2]]) <= 65535 then
        return UInt(_BundleDimensions[[2]]) as integer {0..65535};
    end;
    return 0;
end;

readonly func BundleSharedTMOVLocalSchemaLegal() => boolean
begin
    if BundleSharedBindingPhysicalCount() != 1 ||
       BundleTileBindingCount() != 1 then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let shared_size = if BundleSharedBindingIsReusedDestination(0) then
        BundleSharedGenerationCapacity(0)
        else BundleSharedBindingSize(0);
    let shared_mask = BundleSharedBindingMask(0);
    if !binding.valid || binding.destination_valid ||
       !binding.source0_valid || binding.source1_valid || !binding.last ||
       binding.destination_size != 0 ||
       (!TileSizeCodeIsLegal(shared_size) &&
        !BundleSharedBindingIsReusedDestination(0)) ||
       binding.pe_mask != shared_mask then return FALSE; end;
    if shared_mask == Zeros{4} then return TRUE; end;
    if !TileSourceContentsDefined(binding.source0) ||
       _Tiles[[binding.source0]].capacity_bytes !=
           TileSizeCodeBytes(shared_size as integer {1..12}) then
        return FALSE;
    end;
    var candidate = _Tiles[[binding.source0]];
    return SharedTileUpdateCompatible(
        BundleSharedBindingId(0), candidate, shared_mask);
end;

readonly func BundleSharedTMOVDestinationSchemaLegal(
    shared_tile_id: SharedTileID, function: integer {0..31}) => boolean
begin
    if BundleSharedBindingCount() != 1 ||
       BundleTileBindingCount() != 1 then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let shared_mask = BundleSharedBindingMask(0);
    if !binding.valid || !binding.destination_valid ||
       binding.source0_valid || binding.source1_valid || !binding.last ||
       !LocalTileSizeCodeIsLegal(binding.destination_size) ||
       BundleSharedBindingIsDestination(0) ||
       binding.pe_mask != shared_mask then return FALSE; end;
    if shared_mask == Zeros{4} then return TRUE; end;
    let capacity_bytes = TileSizeCodeBytes(
        binding.destination_size as integer {1..12});
    let valid_rows = BundleDestinationValidRows(FALSE, 0);
    let valid_columns = BundleDestinationValidColumns(FALSE, 0);
    let columns = BundleDestinationPhysicalColumns(FALSE, 0);
    if valid_rows < 1 || valid_columns < 1 || columns < 1 ||
       valid_columns > columns then return FALSE; end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let layout = CurrentBundleTileLayout();
    if _BundleSharedBindings[[0]].source0_subview.valid then
        if !BundleSharedSubviewLegal(0) then return FALSE; end;
        let view = MaterializeBundleSharedSubview(0);
        if view.capacity_bytes != capacity_bytes ||
           view.valid_rows != valid_rows ||
           view.valid_columns != valid_columns ||
           view.columns != columns || view.data_type != data_type ||
           view.layout != layout then
            return FALSE;
        end;
        return function == 2;
    end;
    if !SharedTileReadSchemaLegalAtCapacity(shared_tile_id, valid_rows,
           valid_columns, columns, data_type, layout, capacity_bytes) then
        return FALSE;
    end;
    return function == 2;
end;

func ExecuteBundleSharedTLSUOperation() => boolean
begin
    let function = UInt(_BundleOperation.selector[4:0]);
    if BundleSharedBindingPhysicalCount() != 1 then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let shared_tile_id = BundleSharedBindingId(0);
    let shared_size = if BundleSharedBindingIsReusedDestination(0) then
        BundleSharedGenerationCapacity(0)
        else BundleSharedBindingSize(0);
    let shared_mask = BundleSharedBindingMask(0);
    if shared_mask == Zeros{4} then return TRUE; end;
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let transfer_data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if (function == 0 || function == 1) &&
       !TileRegularTLSUDataTypeSupported(transfer_data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleOperationScalarBindingSchemaLegal(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then
        return FALSE;
    end;
    if function == 0 then
        if (!BundleSharedBindingIsDestination(0) &&
            !BundleSharedBindingIsReusedDestination(0)) ||
           !TileSizeCodeIsLegal(shared_size) ||
           BundleTileBindingCount() != 0 then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let valid_columns = UInt(_BundleDimensions[[0]]);
        let valid_rows = UInt(_BundleDimensions[[1]]);
        let columns = UInt(_BundleDimensions[[2]]);
        if valid_columns < 1 || valid_columns > 65535 ||
           valid_rows < 1 || valid_rows > 65535 ||
           columns < 1 || columns > 65535 || valid_columns > columns then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        var load_base_addresses: CorePEWords;
        var load_row_stride_bytes: CorePEWords;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            load_base_addresses[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source0)
                else Zeros{PTO_XLEN};
            load_row_stride_bytes[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source1)
                else TileDenseRowStrideBytes(
                    columns as integer {0..65535}, transfer_data_type);
        end;
        let assembling =
            _BundleSharedBindings[[0]].destination_assemble.valid;
        var prior_shared = SharedTileRecord(shared_tile_id);
        if assembling then
            prior_shared = BeginBundleSharedGenerationProbe(shared_tile_id);
        end;
        TLOADShared(shared_tile_id, load_base_addresses, load_row_stride_bytes,
            shared_size as integer {1..12}, valid_rows as integer {1..65535},
            columns as integer {1..65535},
            valid_rows as integer {1..65535},
            valid_columns as integer {1..65535},
            transfer_data_type,
            CurrentBundleTileLayout(), shared_mask);
        if assembling then
            let candidate = SharedTileRecord(shared_tile_id);
            // On a first fault, leave the candidate record in place: prior
            // reads remain observable but the partial generation is not ready
            // or published. Successful candidates still commit atomically.
            if _LastFault == Fault_None then
                RestoreBundleSharedGenerationProbe(shared_tile_id, prior_shared);
                if !CommitBundleSharedGenerationCandidate(0, candidate) then
                    SetFault(Fault_TileLegality, ReadTPC());
                end;
            end;
        end;
    elsif function == 1 then
        if !SharedStorePEMaskLegal(function, shared_mask) ||
           BundleSharedBindingIsDestination(0) ||
           BundleTileBindingCount() != 0 then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        // Shared source readiness is a parent-level hardware gate. Pending or
        // incomplete generations keep the block active for retry with no
        // payload read, binding consumption, or GM effect.
        if !SharedTilePublished(shared_tile_id) then
            return FALSE;
        end;
        let store_valid_columns = BundleSharedStoreValidColumns(shared_tile_id);
        let store_valid_rows = BundleSharedStoreValidRows(shared_tile_id);
        let store_columns = BundleSharedStoreColumns(
            shared_tile_id, store_valid_columns);
        let store_data_type = transfer_data_type;
        let store_layout = CurrentBundleTileLayout();
        let has_subview =
            _BundleSharedBindings[[0]].source0_subview.valid;
        if has_subview && !BundleSharedSubviewLegal(0) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        if !has_subview && (store_valid_columns < 1 || store_valid_rows < 1 ||
           store_columns < 1 || store_valid_columns > store_columns ||
           !SharedTileReadSchemaLegal(shared_tile_id, store_valid_rows,
               store_valid_columns, store_columns, store_data_type,
               store_layout)) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        var store_base_addresses: CorePEWords;
        var store_row_stride_bytes: CorePEWords;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            store_base_addresses[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source0)
                else Zeros{PTO_XLEN};
            store_row_stride_bytes[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source1)
                else TileDenseRowStrideBytes(
                    store_columns as integer {0..65535}, store_data_type);
        end;
        if has_subview then
            var per_pe_store_tiles: CorePETileInfos;
            for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                let agent = pe as MemoryAgentId;
                per_pe_store_tiles[[agent]] =
                    MaterializeBundleSharedSubviewForPE(0, agent);
            end;
            TSTORESharedPerPE(store_base_addresses, store_row_stride_bytes,
                per_pe_store_tiles, shared_mask);
        else
            let store_tile = MaterializeSharedTileForReadSchema(
                shared_tile_id, store_valid_rows, store_valid_columns,
                store_columns, store_data_type, store_layout);
            TSTOREShared(store_base_addresses, store_row_stride_bytes,
                shared_tile_id, store_tile, shared_mask);
        end;
    elsif function == 2 then
        let shared_is_destination = BundleSharedBindingIsDestination(0) ||
            BundleSharedBindingIsReusedDestination(0);
        if shared_is_destination then
            if !BundleSharedTMOVLocalSchemaLegal() then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            let binding = _BundleTileBindings[[0]];
            let assembling =
                _BundleSharedBindings[[0]].destination_assemble.valid;
            var prior_shared = SharedTileRecord(shared_tile_id);
            if assembling then
                prior_shared = BeginBundleSharedGenerationProbe(shared_tile_id);
            end;
            TMOVLocalToShared(shared_tile_id, binding.source0,
                shared_size as integer {1..12}, shared_mask, !assembling);
            if assembling then
                let candidate = SharedTileRecord(shared_tile_id);
                RestoreBundleSharedGenerationProbe(shared_tile_id, prior_shared);
                if _LastFault == Fault_None &&
                   !CommitBundleSharedGenerationCandidate(0, candidate) then
                    SetFault(Fault_TileLegality, ReadTPC());
                end;
            end;
        else
            // The same parent-level readiness gate applies before any Local
            // destination allocation or Shared payload materialization. The
            // block remains active so completion can retry after publication.
            if !SharedTilePublished(shared_tile_id) then
                return FALSE;
            end;
            if !BundleSharedTMOVDestinationSchemaLegal(shared_tile_id, function) ||
               !SelectedBundleTileMasksLegal() then
                if _LastFault == Fault_None then
                    SetFault(Fault_TileLegality, ReadTPC());
                end;
                return FALSE;
            end;
            let binding = _BundleTileBindings[[0]];
            let capacity_bytes = TileSizeCodeBytes(
                binding.destination_size as integer {1..12});
            let valid_rows = BundleDestinationValidRows(FALSE, 0);
            let valid_columns = BundleDestinationValidColumns(FALSE, 0);
            let columns = BundleDestinationPhysicalColumns(FALSE, 0);
            let data_type = TileDataTypeFromEncoding(
                CurrentBundleTileOperationDataTypeCode()
                    as TileDataTypeEncoding);
            let has_subview =
                _BundleSharedBindings[[0]].source0_subview.valid;
            let shared_tile = if has_subview then
                MaterializeBundleSharedSubview(0)
            else MaterializeSharedTileForReadSchemaAtCapacity(
                shared_tile_id, valid_rows, valid_columns, columns, data_type,
                CurrentBundleTileLayout(), capacity_bytes);
            if !ResolveBundleTileDestinations() then return FALSE; end;
            if !ValidateBundleLocalGenerationWriters() then
                RollBackBundleTileDestinations(); return FALSE;
            end;
            let destination = _BundleTileBindings[[0]].destination;
            if _Tiles[[destination]].rows != shared_tile.rows ||
               _Tiles[[destination]].columns != shared_tile.columns ||
               _Tiles[[destination]].valid_rows != shared_tile.valid_rows ||
               _Tiles[[destination]].valid_columns != shared_tile.valid_columns ||
               _Tiles[[destination]].data_type != shared_tile.data_type ||
               _Tiles[[destination]].layout != shared_tile.layout then
                RollBackBundleTileDestinations();
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            if has_subview then
                var per_pe_shared_tiles: CorePETileInfos;
                for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                    let agent = pe as MemoryAgentId;
                    per_pe_shared_tiles[[agent]] =
                        MaterializeBundleSharedSubviewForPE(0, agent);
                end;
                TMOVSharedToLocalPerPE(destination, per_pe_shared_tiles,
                    shared_mask);
            else
                TMOVSharedToLocal(destination, shared_tile_id, shared_tile,
                    shared_mask);
            end;
        end;
    else
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    ConsumeBundleSharedBindings(1);
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
