<!-- GENERATED FROM: asl/block/model/dispatch/weight-to-shared-execution.asl -->
# Weight To Shared Execution

**Normative ASL source:** `asl/block/model/dispatch/weight-to-shared-execution.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-WEIGHT-SHARED-EXEC}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-execution-purpose role=purpose-scope -->
## 用途与范围

本单元在权重模式 `TLOAD` 指令束提交时执行它。它校验完整的指令束，从全局内存（GM）读取权重裁剪区域，并把它作为行主序的 N 乘 K 矩阵写入一个 Shared Tile。可以由一个 PE 写入整个 Tile，也可以由多个 PE 各写一段连续的行。

入口是 `ExecuteBundleWeightTLOADOperation`。当 `BundleWeightTLOADSelected` 为真且指令束不是 TIMG2COL 指令束时，[Tile 执行](tile-execution.md)调用它。

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-execution-concepts role=concepts-state -->
## 输入与状态

- 一条 `B.IOS` 指定 Shared 目标。它要么携带尺寸代码（新目标），要么是尺寸代码为 0 的复用汇编目标。没有 `B.IOT`。
- 一条含三个源且目标为零的 `B.IOR` 记录携带 GMBase、ShapeGPR 和 StartGPR。ShapeGPR 打包 `Cin`、`Cout`、`KernelH` 和 `KernelW`；StartGPR 打包 NStart 和 KStart。
- `B.DIM` 给出 ValidCol、ValidRow 和 TotalCol。
- 数据类型来自 `BSTART` 描述符。`B.DATR` 只提供布局；它自身的 DataType 字段必须为空。

对单个写者，本单元写入 Shared Tile 记录；对协作写者，写入打开的 Shared 代际。它还为读取的每个 GM 元素记录一个加载事件。

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-execution-rules role=rules-interactions -->
## 校验、构建与发布

首先是严格的无操作路径。如果见到过零参与的绑定命令，且不存在 Tile 或 Shared 绑定，本单元不做其他检查直接返回成功。

随后 `BundleWeightTLOADStateLegal` 检查描述符类型、`B.DATR` 字段、绑定形态和 `B.IOR` 记录。零 Shared 掩码是合法的，且不做任何事。否则掩码必须包含当前 PE，并且每个被选 PE 必须持有相等的 GMBase、ShapeGPR 和 StartGPR 值。尺寸必须在 1 到 65535 之间，ShapeGPR 的位 48 到 63 必须为零，四个尺寸必须非零。必须满足 [schema](weight-to-shared-schema.md) 的形状规则，并且 ValidRow 行、每行 TotalCol 列必须能放入父 Tile 的容量。

单个被选 PE 不得使用 `B.ASSEMBLE`。有多个 PE 时必须使用 `B.ASSEMBLE`：第一个被选 PE 携带 INIT，最后一个携带 LAST，其余两者都不携带。编码的寄存器、立即数和偏移必须为零。本单元根据每个写者的行起点推导其偏移（以 32 字节为单位），并在行带非空时要求写者尺寸代码恰好等于其行带的字节数。随后它校验代际范围，包括 GMBase、两个参数字和一个元数据字。

设计要点：写者偏移是推导出来的而不是编码的，其尺寸必须与其行跨度完全一致。因此每个参与者的目标范围由 ValidRow、TotalCol、所选掩码和 PE 顺序固定；NStart 只移动 GM 源行。NDF 条款 `PTO-BSTART-TLOAD-WEIGHT-COOPERATIVE-001` 会拒绝不一致的尺寸代码。

`BundleWeightTLOADBuildAndPublish` 在第一次加载前，对全部 ValidRow 行（而不只是本 PE 的行带）调用 `BundleWeightTLOADPreflightGM`。

设计要点：每个参与者在任何参与者发出 GM 读取之前，都先证明全部被选 PE 的完整访问范围。因此任何一段行带中的故障都会在记录加载事件之前阻止所有写者。

随后本单元填充自己的行。Cin 填充位置变为原始零，不访问 GM。单个写者通过 `AtomicUpdateSharedTile` 发布；该更新失败时，故障为 `Fault_TileAllocation`。协作写者把其范围提交到打开的代际中，只有无缺口的 LAST 写者到达后，代际才发布父 Tile。

任何失败时，`BundleWeightTLOADAbortFailedAttempt` 都会中止打开的汇编代际。未记录故障的失败变为 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-execution-boundaries role=boundaries -->
## 架构边界

Tile 执行在通用第 2 阶段准备和 Local 续接复用之前路由此操作。它仍然先应用输出结构检查和 Shared 汇编策略检查，并且在本单元失败时中止该指令束的所有 Local 和 Shared 代际。

每个单元按 OHWI 或 OIHW 顺序的 GM 索引属于 [权重到 Shared 的 GM 访问](../memory/weight-to-shared-gm.md)。行划分和形状规则属于 [schema](weight-to-shared-schema.md) 单元。

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-execution-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

四个 PE 以 ValidRow 64、ValidCol 64、TotalCol 64 把 FP16 权重加载到尺寸代码为 7（即 8192 字节）的 Shared 父 Tile 中。每个 PE 写 16 行、每行 64 个元素，即 2048 字节，因此每个写者的尺寸代码必须为 5。

`C0` 为 16，因此偏移为 0、64、128 和 192 个 32 字节单位。父 Tile 有 256 个单位。PE 0 携带 INIT，PE 3 携带 LAST，父 Tile 在 PE 3 覆盖单位 192 到 256 之后发布。

如果只选中 PE 2，指令束必须省略 `B.ASSEMBLE`，由 PE 2 写入全部 64 行并直接发布。

<!-- PTO-READER-BLOCK: block-model-dispatch-weight-to-shared-execution-related role=related-owners-navigation -->
## 相关所有者

- [权重到 Shared schema](weight-to-shared-schema.md)定义选择条件、形状规则和行划分。
- [权重到 Shared 参数](../operands/weight-to-shared-parameters.md)解包各字并检查参与者值相等。
- [权重到 Shared 的 GM 访问](../memory/weight-to-shared-gm.md)定义单元映射和 GM 预检。
- [Shared 代际](../operands/shared-generation.md)校验并提交协作范围。
- [Tile 执行](tile-execution.md)派发此处理程序。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/weight-to-shared-execution.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-WEIGHT-SHARED-EXEC","surface":"block","classification":["model","dispatch","weight-to-shared-execution"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-WEIGHT-TO-SHARED-SCHEMA","PTO-BLOCK-MODEL-MEMORY-WEIGHT-TO-SHARED-GM","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-BLOCK-MODEL-FAULTS-ROLLBACK"]}
// NDF-BEGIN: PTO-BSTART-TLOAD-WEIGHT-COOPERATIVE-001
// ndf: kind=contract level=L1 layer=concurrency status=accepted
// A singleton nonzero Shared mask publishes without B.ASSEMBLE. Any
// multi-participant mask uses the existing Shared B.ASSEMBLE protocol, assigns
// contiguous physical N-row ranges in PE order, requires each nonempty encoded
// writer SizeCode to equal its complete-row span, and publishes only after a
// complete selected-PE GM preflight and matching gap-free LAST generation.
// NDF-END: PTO-BSTART-TLOAD-WEIGHT-COOPERATIVE-001
readonly func BundleWeightTLOADGenerationCoverage(
    offset_cells: integer {0..8192}, writer_cells: integer {0..8192})
    => (boolean, integer {0..8192})
begin
    let assemble = _BundleSharedBindings[[0]].destination_assemble;
    if !assemble.last then return (TRUE, writer_cells); end;
    let shared_tile_id = BundleSharedBindingId(0);
    let parent_cells = if assemble.init then BundleLocalGenerationCellCount(
        BundleSharedBindingSize(0) as integer {1..12}) * 4 else
        _SharedGenerations[[SharedTileArrayIndex(shared_tile_id)]].parent_cell_count;
    if offset_cells > parent_cells then return (FALSE, 0); end;
    return (TRUE, (parent_cells - offset_cells) as integer {0..8192});
end;

pure func BundleWeightTLOADWriterCells(size_code: integer {1..12})
    => integer {4..8192}
begin
    return (BundleLocalGenerationCellCount(size_code) * 4)
        as integer {4..8192};
end;

readonly func BundleWeightTLOADParentSizeCode(mask: bits(4)) => integer
begin
    if PEMaskPopulation(mask) == 1 then
        return BundleSharedBindingSize(0);
    end;
    let assemble = _BundleSharedBindings[[0]].destination_assemble;
    if assemble.init then return BundleSharedBindingSize(0); end;
    return BundleSharedGenerationCapacity(0);
end;

readonly func BundleWeightTLOADStateLegal() => boolean
begin
    if !BundleWeightTLOADSelected() ||
       !_BundleOperation.data_type_valid ||
       !BundleDataTypeConcrete(_BundleOperation.data_type) then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(
        _BundleOperation.data_type as TileDataTypeEncoding);
    if !BundleWeightTLOADDataTypeSupported(data_type) ||
       !InstructionContractB_DATR_TLOADWeightFieldsLegal(
           TileDataLayoutOfCode(_BundleDataAttributes.data_layout),
           _BundleDataAttributes.data_type,
           _BundleDataAttributes.pad_value,
           _BundleDataAttributes.comparison_mode,
           _BundleDataAttributes.rounding_mode,
           _BundleDataAttributes.saturating,
           _BundleDataAttributes.canonicalize) then
        return FALSE;
    end;
    if BundleSharedBindingPhysicalCount() != 1 || BundleTileBindingCount() != 0 ||
       ((!BundleSharedBindingIsReusedDestination(0) &&
         !BundleSharedBindingIsDestination(0)) ||
        (BundleSharedBindingIsReusedDestination(0) &&
         _BundleSharedBindings[[0]].size_code != 0)) ||
       (!BundleSharedBindingIsReusedDestination(0) &&
        !TileSizeCodeIsLegal(BundleSharedBindingSize(0))) ||
       !_BundleScalarBindings[[0]].valid ||
       _BundleScalarBindings[[1]].valid ||
       _BundleScalarBindings[[0]].source_count != 3 ||
       _BundleScalarBindings[[0]].destination != 0 then
        return FALSE;
    end;
    let mask = BundleSharedBindingMask(0);
    if mask == Zeros{4} then return TRUE; end;
    if (mask AND BundleWeightTLOADPEBit()) == Zeros{4} ||
       !BundleWeightTLOADParticipantValuesEqual(mask) then
        return FALSE;
    end;
    let valid_col_raw = UInt(_BundleDimensions[[0]]);
    let valid_row_raw = UInt(_BundleDimensions[[1]]);
    let total_col_raw = UInt(_BundleDimensions[[2]]);
    if valid_col_raw == 0 || valid_col_raw > 65535 ||
       valid_row_raw == 0 || valid_row_raw > 65535 ||
       total_col_raw == 0 || total_col_raw > 65535 then
        return FALSE;
    end;
    let shape_word = ReadScalarRegisterOperand(
        _BundleScalarBindings[[0]].source1);
    let start_word = ReadScalarRegisterOperand(
        _BundleScalarBindings[[0]].source2);
    if !BundleWeightTLOADShapeReservedBitsLegal(shape_word) then return FALSE; end;
    let parameters = BundleWeightTLOADParametersFromWords(
        shape_word, start_word);
    if parameters.cin == 0 || parameters.cout == 0 ||
       parameters.kernel_h == 0 || parameters.kernel_w == 0 then
        return FALSE;
    end;
    let shape = BundleWeightTLOADShape {
        valid_col = valid_col_raw as integer {1..65535},
        valid_row = valid_row_raw as integer {1..65535},
        total_col = total_col_raw as integer {1..65535},
        data_type = data_type,
        cin = parameters.cin as integer {1..65535},
        cout = parameters.cout as integer {1..65535},
        kernel_h = parameters.kernel_h as integer {1..255},
        kernel_w = parameters.kernel_w as integer {1..255},
        n_start = parameters.n_start,
        k_start = parameters.k_start
    };
    if !BundleWeightTLOADShapeLegal(shape) then return FALSE; end;
    let population = PEMaskPopulation(mask);
    let assemble = _BundleSharedBindings[[0]].destination_assemble;
    let parent_size_code = BundleWeightTLOADParentSizeCode(mask);
    if parent_size_code < 1 || parent_size_code > 12 then return FALSE; end;
    let capacity = TileSizeCodeBytes(
        parent_size_code as integer {1..12});
    let rows = DerivedTileRows(capacity, shape.total_col, data_type);
    if rows == 0 || shape.valid_row > rows ||
       shape.valid_row * shape.total_col >
           TileLogicalElementCapacity(capacity, data_type) then
        return FALSE;
    end;
    if population == 1 then return !assemble.valid; end;
    let current_pe = _CurrentMemoryAgent as integer {0..3};
    let first_pe = BundleWeightTLOADFirstPE(mask);
    let last_pe = BundleWeightTLOADLastPE(mask);
    let expected_phase = if current_pe == first_pe then
        assemble.init && !assemble.last
        else if current_pe == last_pe then !assemble.init && assemble.last
        else !assemble.init && !assemble.last;
    if !assemble.valid || !expected_phase || assemble.reg_src != 0 ||
       assemble.uimm11 != Zeros{11} || assemble.offset != Zeros{PTO_XLEN} ||
       (assemble.size_code < 1 || assemble.size_code > 12) then
        return FALSE;
    end;
    let rank = BundleWeightTLOADCurrentPERank(mask);
    let destination_row_start = BundleWeightTLOADRowStartForRank(
        0, shape.valid_row, mask, rank);
    let rows_to_write = BundleWeightTLOADRowsForRank(
        shape.valid_row, mask, rank);
    let c0 = BundleWeightTLOADC0Elements(data_type);
    let derived_offset_numerator = destination_row_start * shape.total_col;
    if (derived_offset_numerator MOD c0) != 0 then return FALSE; end;
    let derived_offset = derived_offset_numerator DIVRM c0;
    let intended_writer_bytes: integer = rows_to_write * shape.total_col *
        TileMemoryElementBytes(data_type);
    let encoded_writer_bytes = TileSizeCodeBytes(
        assemble.size_code as integer {1..12});
    if rows_to_write != 0 && intended_writer_bytes != encoded_writer_bytes then
        return FALSE;
    end;
    let encoded_writer_cells = BundleWeightTLOADWriterCells(
        assemble.size_code as integer {1..12});
    let payload_cells = if rows_to_write == 0 then 0 else encoded_writer_cells;
    if derived_offset > 8192 then return FALSE; end;
    let (coverage_legal, coverage_cells) = BundleWeightTLOADGenerationCoverage(
        derived_offset as integer {0..8192}, payload_cells);
    if !coverage_legal then return FALSE; end;
    let gm_base = ReadScalarRegisterOperand(
        _BundleScalarBindings[[0]].source0);
    let generation_metadata = BundleWeightTLOADGenerationMetadata(
        _BundleDataAttributes.data_layout, _BundleOperation.data_type,
        _BundleDimensions[[0]][15:0], _BundleDimensions[[1]][15:0],
        _BundleDimensions[[2]][15:0],
        Zeros{4} + (parent_size_code as integer {1..12}));
    return ValidateBundleSharedGenerationRange(0,
        derived_offset as integer {0..8192}, coverage_cells,
        BundleWeightTLOADPEBit(), TRUE, gm_base, shape_word, start_word,
        generation_metadata, Zeros{PTO_XLEN});
end;

func BundleWeightTLOADBuildAndPublish() => boolean
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    let data_type = TileDataTypeFromEncoding(
        _BundleOperation.data_type as TileDataTypeEncoding);
    let layout = TileDataLayoutOfCode(_BundleDataAttributes.data_layout);
    let valid_col = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_row = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let total_col = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    let mask = BundleSharedBindingMask(0);
    if mask == Zeros{4} then return TRUE; end;
    let shape_word = ReadScalarRegisterOperand(
        _BundleScalarBindings[[0]].source1);
    let start_word = ReadScalarRegisterOperand(
        _BundleScalarBindings[[0]].source2);
    let base_parameters = BundleWeightTLOADParametersFromWords(
        shape_word, start_word);
    let cooperative = PEMaskPopulation(mask) > 1;
    let rank = if cooperative then BundleWeightTLOADCurrentPERank(mask) else 0;
    let assemble = _BundleSharedBindings[[0]].destination_assemble;
    let rows_to_write = if cooperative then BundleWeightTLOADRowsForRank(
        valid_row, mask, rank) else valid_row;
    let destination_row_start = if cooperative then
        BundleWeightTLOADRowStartForRank(0, valid_row, mask, rank) else 0;
    var parameters = base_parameters;
    parameters.n_start = (base_parameters.n_start + destination_row_start)
        as integer {0..4294967295};
    let gm_base = ReadScalarRegisterOperand(
        _BundleScalarBindings[[0]].source0);
    let element_bytes = TileMemoryElementBytes(data_type);
    // Every participant proves the complete selected-PE footprint before any
    // participant may issue the first architectural GM read.
    if !BundleWeightTLOADPreflightGM(layout, data_type, base_parameters,
           valid_row, valid_col, gm_base, element_bytes) then
        return FALSE;
    end;
    let parent_size_code = BundleWeightTLOADParentSizeCode(mask);
    let capacity = TileSizeCodeBytes(
        parent_size_code as integer {1..12});
    let rows = DerivedTileRows(capacity, total_col, data_type);
    var candidate = SharedTileRecord(BundleSharedBindingId(0)).tile;
    candidate.allocated = TRUE;
    candidate.storage_kind = TileStorage_Numeric;
    candidate.capacity_bytes = capacity;
    candidate.rows = rows;
    candidate.columns = total_col;
    candidate.valid_rows = rows_to_write;
    candidate.valid_columns = valid_col;
    candidate.data_type = data_type;
    candidate.predicate_basis_type = data_type;
    candidate.layout = TileLayout_RowMajor;
    candidate.contents_defined = FALSE;
    candidate.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    candidate.packed_defined_elements = zero_packed_tile_elements;
    candidate.defined_valid_elements = 0;
    for row = 0 to rows_to_write - 1 looplimit 65535 do
        for col = 0 to valid_col - 1 looplimit 65535 do
            let cell = BundleWeightTLOADCell(layout, data_type, parameters,
                row as integer {0..65534}, col as integer {0..65534});
            var value = Zeros{PTO_XLEN};
            if cell.gm_access then
                let byte_offset = (cell.gm_index * element_bytes)
                    as integer {0..18446744073709551615};
                let address = gm_base + byte_offset;
                if UInt(address) < UInt(gm_base) then
                    SetFault(Fault_DataPage, address);
                    return FALSE;
                end;
                let probe = ProbeTileMemoryAccess(address, data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return FALSE; end;
                let raw = LoadTranslatedUnsigned(
                    probe.translated_address, element_bytes);
                RecordLoadEvent(probe.translated_address, element_bytes, raw,
                    CurrentBundleMemoryOrder());
                value = DecodeTileMemoryElementRaw(raw, data_type, FALSE);
            end;
            let element = TileLogicalLinearIndex(candidate,
                row as integer {0..65535}, col as integer {0..65535});
            candidate = TileInfoWithLogicalElement(candidate, element, value);
        end;
    end;
    candidate.contents_defined = TRUE;
    candidate.defined_valid_elements =
        (rows_to_write * valid_col) as integer {0..524288};
    if !cooperative then
        candidate.valid_rows = valid_row;
        if !AtomicUpdateSharedTile(BundleSharedBindingId(0), candidate, mask) then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    let c0 = BundleWeightTLOADC0Elements(data_type);
    let derived_offset = (destination_row_start * total_col) DIVRM c0;
    let encoded_writer_cells = BundleWeightTLOADWriterCells(
        assemble.size_code as integer {1..12});
    let payload_cells = if rows_to_write == 0 then 0 else encoded_writer_cells;
    let (coverage_legal, coverage_cells) = BundleWeightTLOADGenerationCoverage(
        derived_offset as integer {0..8192}, payload_cells);
    if !coverage_legal then return FALSE; end;
    _BundleSharedBindings[[0]].destination_assemble.offset =
        Zeros{PTO_XLEN} + derived_offset;
    let generation_metadata = BundleWeightTLOADGenerationMetadata(
        _BundleDataAttributes.data_layout, _BundleOperation.data_type,
        _BundleDimensions[[0]][15:0], _BundleDimensions[[1]][15:0],
        _BundleDimensions[[2]][15:0],
        Zeros{4} + (parent_size_code as integer {1..12}));
    if !CommitBundleSharedGenerationCandidateRange(0,
           SharedTileInfo {
               descriptor_valid = TRUE,
               allocation_mask = mask,
               initialized_mask = BundleWeightTLOADPEBit(),
               whole_parent_ready = FALSE,
               published = FALSE,
               tile = candidate },
           derived_offset as integer {0..8192}, coverage_cells,
           payload_cells, BundleWeightTLOADPEBit(), TRUE,
           gm_base, shape_word, start_word, generation_metadata,
           Zeros{PTO_XLEN}) then
        AbortBundleSharedGeneration(BundleSharedBindingId(0));
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    return TRUE;
end;

func BundleWeightTLOADAbortFailedAttempt()
begin
    if BundleWeightTLOADSelected() && BundleSharedBindingPhysicalCount() == 1 &&
       _BundleSharedBindings[[0]].destination_assemble.valid then
        AbortBundleSharedGeneration(BundleSharedBindingId(0));
    end;
end;

func ExecuteBundleWeightTLOADOperation() => boolean
begin
    // A zero-participation binder is discarded before it can create a Shared
    // binding. Preserve the ordinary strict no-op even for a selected weight
    // layout, before dimensions, scalar bindings, GPRs, or DATR fields matter.
    if _BundleZeroParticipationSeen && BundleTileBindingCount() == 0 &&
       BundleSharedBindingPhysicalCount() == 0 then
        return TRUE;
    end;
    if !BundleWeightTLOADStateLegal() then
        BundleWeightTLOADAbortFailedAttempt();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleWeightTLOADBuildAndPublish() then
        BundleWeightTLOADAbortFailedAttempt();
        if _LastFault == Fault_None then
            SetFault(Fault_TileLegality, ReadTPC());
        end;
        return FALSE;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
