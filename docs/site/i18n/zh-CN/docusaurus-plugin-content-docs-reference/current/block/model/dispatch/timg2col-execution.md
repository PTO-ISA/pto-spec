<!-- GENERATED FROM: asl/block/model/dispatch/timg2col-execution.asl -->
# Timg2col Execution

**Normative ASL source:** `asl/block/model/dispatch/timg2col-execution.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-EXECUTION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-timg2col-execution-purpose role=purpose-scope -->
## 用途与范围

本单元在 `BSTART.TIMG2COL` 指令束提交时执行它。它检查完整的指令束，从全局内存（GM）读取图像，并把 IMG2COL 矩阵写入一个 Shared Tile 或一个 Local CUBE Tile。

入口是 `ExecuteBundleTIMG2COLOperation`。当 `BundleDescriptorSelectsTIMG2COL` 为真（即形式标识 94 且 TLSU Function 28）时，[Tile 执行](tile-execution.md)在各专用处理程序中最先调用它。

<!-- PTO-READER-BLOCK: block-model-dispatch-timg2col-execution-concepts role=concepts-state -->
## 输出种类与输入

`B.DATR` 布局选择三种输出之一。`ND2M16` 和 `CUBE_M16` 选择 Local M16，`ND2M32` 和 `CUBE_M32` 选择 Local M32，其他所有布局（包括没有 `B.DATR`）选择 Shared ND。

- Shared ND 写入由一条 `B.IOS` 指定的一个 Shared Tile，不使用 `B.IOT`。
- Local M16 和 Local M32 写入由一条 PE 掩码为 `1111` 的 `B.IOT` 指定的一个 Local `CUBE_M16` 或 `CUBE_M32` Tile，不使用 `B.IOS`。

两条仅含源的 `B.IOR` 记录携带操作数。第一条保存 GM 基地址；第二条保存三个打包的参数字。`B.DIM` 值给出 ValidCol、ValidRow（1 到 128）和 TotalCol。

<!-- PTO-READER-BLOCK: block-model-dispatch-timg2col-execution-rules role=rules-interactions -->
## 校验、构建与发布

`BundleTIMG2COLStateLegal` 最先运行，且不读取内存。它按固定代码列表检查操作数据类型，检查 `B.DATR` 字段、该输出种类的绑定数量，以及 Local M16 的 ValidRow 不超过 64。随后它检查两条 `B.IOR` 记录，并要求每个参与 PE 持有相等的 GM 基地址和参数值。它拒绝非零扩展位和零尺寸，并应用 [TIMG2COL schema](timg2col-schema.md) 中的裁剪规则。

对于 Shared ND，Shared 掩码必须是单个 PE 或 `1111`，并且必须包含当前 PE。单 PE 掩码不得使用 `B.ASSEMBLE`。`1111` 掩码必须使用它：PE 0 携带 INIT，PE 3 携带 LAST，PE 1 和 PE 2 两者都不携带。本单元根据每个写者的行起点推导其偏移（以 32 字节为单位），并校验代际范围。对于 Local 输出，本单元检查本 PE 所分得行的 `CUBE` 描述符形状。

之后 `BundleTIMG2COLBuildAndPublish` 按 PE 工作。行数为零的 Local PE 立即返回，不分配也不读 GM。对于至少有一行的 PE，`BundleTIMG2COLPreflightGM` 在第一次加载前探测全部 ValidRow 行的每个 GM 地址。

设计要点：在任何分配、加载事件或 Shared 代际变化之前，先探测完整的访问范围。因此转换或权限故障不会留下部分载荷。

随后 Local PE 复用续接目标，或为自己的 PE 位分配一个新的 `CUBE` Tile。本单元填充每个单元，只对需要的单元读取 GM，并为每次读取记录加载事件。单 PE 的 Shared ND 通过 `AtomicUpdateSharedTile` 发布。`1111` 的 Shared ND 把候选范围提交到打开的代际中；只有无缺口的 LAST 写者到达时，父 Tile 才被发布。

如果校验或构建失败，`BundleTIMG2COLAbortFailedAttempt` 中止 Shared 代际或回滚 Local 目标。未记录故障的失败变为 `Fault_TileLegality`；内存故障保留其自身种类。

<!-- PTO-READER-BLOCK: block-model-dispatch-timg2col-execution-boundaries role=boundaries -->
## 架构边界

对于此操作，Tile 执行跳过通用的效果资格检查、第 2 阶段准备、Local 续接复用和 ExecutionMask 捕获。它仍然先应用输出结构检查和 Shared 汇编策略检查。成功后，它提交 Local 代际，退役消费者依赖，并完成 Tile 尝试。

本单元中单参数的 `BundleTIMG2COLScalarCommandCanBePlaced` 没有调用者；命令放置使用 [scalar schema](scalar-schema.md) 中同名的三参数函数。

<!-- PTO-READER-BLOCK: block-model-dispatch-timg2col-execution-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

ValidRow 为 40 的 Local M16 输出把行划分为 16、16、8 和 0。PE 3 没有行，因此它不分配也不读取，但指令束仍然完成。

掩码为 `1111`、FP16 数据、ValidRow 为 64、TotalCol 为 64 的 Shared ND 输出使每个 PE 得到 16 行。`C0` 为 16，因此每个写者覆盖 16 * 64 / 16 = 64 个单位。PE 1 从单位 64 开始。8192 字节的父 Tile 有 256 个单位，因此 LAST 写者 PE 3 从 192 开始，其覆盖范围延伸到 256。

<!-- PTO-READER-BLOCK: block-model-dispatch-timg2col-execution-related role=related-owners-navigation -->
## 相关所有者

- [TIMG2COL schema](timg2col-schema.md)定义裁剪、行划分和单元映射。
- [TIMG2COL 参数](../operands/timg2col-parameters.md)检查两条 `B.IOR` 记录并解包参数。
- [TIMG2COL GM 访问](../memory/timg2col-gm.md)定义 GM 索引公式和预检循环。
- [Shared 代际](../operands/shared-generation.md)校验并提交协作范围。
- [Tile 执行](tile-execution.md)派发此处理程序并提交结果。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/timg2col-execution.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-EXECUTION","surface":"block","classification":["model","dispatch","timg2col-execution"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-TIMG2COL-PARAMETERS","PTO-BLOCK-MODEL-MEMORY-TIMG2COL-GM"]}
readonly func BundleTIMG2COLDataTypeSupported(data_type: TileDataType)
    => boolean
begin
    let code = UInt(TileDataTypeToEncoding(data_type));
    return code == 1 || code == 2 || code == 3 || code == 4 || code == 5 ||
           code == 6 || code == 7 || code == 8 || code == 13 ||
           code == 17 || code == 18 || code == 19 || code == 25 ||
           code == 26 || code == 27;
end;

readonly func BundleTIMG2COLCurrentPE() => integer {0..3}
begin
    return _CurrentMemoryAgent as integer {0..3};
end;

readonly func BundleTIMG2COLPEValidRow(
    output: BundleTIMG2COLOutputKind, valid_row: integer {1..128})
    => integer {0..32}
begin
    return BundleTIMG2COLValidRowForOutput(
        output, valid_row, BundleTIMG2COLCurrentPE());
end;

readonly func BundleTIMG2COLPERowStart(
    output: BundleTIMG2COLOutputKind, valid_row: integer {1..128},
    row_start: integer)
    => integer
begin
    return BundleTIMG2COLRowStartForOutput(output, valid_row, row_start,
        BundleTIMG2COLCurrentPE());
end;

readonly func BundleTIMG2COLPEBit() => bits(4)
begin
    var result = Zeros{4};
    result[PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent)] = '1';
    return result;
end;

readonly func BundleTIMG2COLStateOutput() => BundleTIMG2COLOutputKind
begin
    let layout = TileDataLayoutOfCode(_BundleDataAttributes.data_layout);
    if layout == TileDataLayout_ND2M16 || layout == TileDataLayout_CUBE_M16 then
        return BundleTIMG2COLOutput_LocalM16;
    elsif layout == TileDataLayout_ND2M32 || layout == TileDataLayout_CUBE_M32 then
        return BundleTIMG2COLOutput_LocalM32;
    end;
    return BundleTIMG2COLOutput_SharedND;
end;

readonly func BundleTIMG2COLScalarCommandCanBePlaced(
    binding_index: integer {0..1}) => boolean
begin
    if !_BundleActive || _BundleBodyActive ||
       _BundleScalarBindings[[binding_index]].valid then
        return FALSE;
    end;
    if binding_index == 0 then return TRUE; end;
    return _BundleScalarBindings[[0]].valid &&
           BundleTIMG2COLIORSecondExpected();
end;

func BundleTIMG2COLStateLegal() => boolean
begin
    if !BundleTIMG2COLSelected() ||
       !_BundleOperation.data_type_valid ||
       !BundleDataTypeConcrete(_BundleOperation.data_type) then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(
        _BundleOperation.data_type as TileDataTypeEncoding);
    if !BundleTIMG2COLDataTypeSupported(data_type) then
        return FALSE;
    end;
    if _BundleDataAttributesPresent &&
       !InstructionContractB_DATR_TIMG2COLFieldsLegal(
           TileDataLayoutOfCode(_BundleDataAttributes.data_layout),
           _BundleDataAttributes.data_type,
           _BundleDataAttributes.pad_value,
           _BundleDataAttributes.comparison_mode,
           _BundleDataAttributes.rounding_mode,
           _BundleDataAttributes.saturating,
           _BundleDataAttributes.canonicalize) then
        return FALSE;
    end;
    let output = BundleTIMG2COLStateOutput();
    if output != BundleTIMG2COLOutput_SharedND then
        for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
            if _BundleTileBindings[[binding]].valid &&
               _BundleTileBindings[[binding]].destination_assemble.valid then
                return FALSE;
            end;
        end;
    end;
    let valid_col_raw = UInt(_BundleDimensions[[0]]);
    let valid_row_raw = UInt(_BundleDimensions[[1]]);
    let total_col_raw = UInt(_BundleDimensions[[2]]);
    if valid_col_raw == 0 || valid_col_raw > 65535 || valid_row_raw == 0 ||
       valid_row_raw > 128 || total_col_raw == 0 || total_col_raw > 65535 then
        return FALSE;
    end;
    let valid_col = valid_col_raw as integer {1..65535};
    let valid_row = valid_row_raw as integer {1..128};
    let total_col = total_col_raw as integer {1..65535};
    if output == BundleTIMG2COLOutput_LocalM16 && valid_row > 64 then
        return FALSE;
    end;
    if output == BundleTIMG2COLOutput_SharedND &&
       (BundleSharedBindingPhysicalCount() != 1 || BundleTileBindingCount() != 0) then
        return FALSE;
    end;
    if output != BundleTIMG2COLOutput_SharedND &&
       (BundleSharedBindingCount() != 0 || BundleTileBindingCount() != 1) then
        return FALSE;
    end;
    if !_BundleScalarBindings[[0]].valid ||
       !_BundleScalarBindings[[1]].valid ||
       _BundleScalarBindings[[0]].source_count != 3 ||
       _BundleScalarBindings[[1]].source_count != 3 ||
       _BundleScalarBindings[[0]].destination != 0 ||
       _BundleScalarBindings[[1]].destination != 0 then
        return FALSE;
    end;
    let participant_mask = if output == BundleTIMG2COLOutput_SharedND then
        BundleSharedBindingMask(0) else '1111';
    if !BundleTIMG2COLIORBindingsPreflight(participant_mask) then
        return FALSE;
    end;
    let param0 = ReadScalarRegisterOperand(_BundleScalarBindings[[1]].source0);
    let param1 = ReadScalarRegisterOperand(_BundleScalarBindings[[1]].source1);
    let param2 = ReadScalarRegisterOperand(_BundleScalarBindings[[1]].source2);
    let gm_base = ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source0);
    if !BundleTIMG2COLBaseParameterExtensionLegal(param1) then return FALSE; end;
    let parameters = BundleTIMG2COLParametersFromWords(param0, param1, param2);
    if !BundleTIMG2COLParametersLegal(parameters) then return FALSE; end;
    let shape = BundleTIMG2COLShape {
        valid_col = valid_col, valid_row = valid_row,
        total_col = total_col, data_type = data_type,
        input_h = parameters.input_h as integer {1..65535},
        input_w = parameters.input_w as integer {1..65535},
        cin = parameters.cin as integer {1..65535},
        kernel_h = parameters.kernel_h as integer {1..255},
        kernel_w = parameters.kernel_w as integer {1..255},
        pad_top = parameters.pad_top, pad_left = parameters.pad_left,
        pad_bottom = parameters.pad_bottom, pad_right = parameters.pad_right,
        dilation_h = parameters.dilation_h as integer {1..31},
        dilation_w = parameters.dilation_w as integer {1..31},
        conv_stride_h = parameters.conv_stride_h as integer {1..63},
        conv_stride_w = parameters.conv_stride_w as integer {1..63},
        row_start = parameters.row_start, col_start = parameters.col_start
    };
    if !BundleTIMG2COLShapeLegal(shape) then return FALSE; end;
    if output == BundleTIMG2COLOutput_SharedND then
        let shared_mask = BundleSharedBindingMask(0);
        if BundleSharedGenerationCapacity(0) == 0 ||
           (PEMaskPopulation(shared_mask) != 1 && shared_mask != '1111') ||
           (shared_mask AND BundleTIMG2COLPEBit()) == Zeros{4} then
            return FALSE;
        end;
        let shared_capacity = TileSizeCodeBytes(
            BundleSharedGenerationCapacity(0) as integer {1..12});
        if !BundleTIMG2COLDestinationShapeLegal(output, shared_capacity,
               valid_row, valid_col, total_col, data_type) then
            return FALSE;
        end;
        let generation_metadata = BundleTIMG2COLGenerationMetadata(
            _BundleDataAttributes.data_layout, _BundleOperation.data_type,
            _BundleDimensions[[0]][15:0], _BundleDimensions[[1]][7:0],
            _BundleDimensions[[2]][15:0],
            Zeros{4} + BundleSharedGenerationCapacity(0),
            BundleSharedBindingId(0));
        if shared_mask == '1111' then
            let assemble = _BundleSharedBindings[[0]].destination_assemble;
            let pe = BundleTIMG2COLCurrentPE();
            let expected_phase = if pe == 0 then assemble.init && !assemble.last
                else if pe == 3 then !assemble.init && assemble.last
                else !assemble.init && !assemble.last;
            if !assemble.valid || !expected_phase ||
               assemble.reg_src != 0 || assemble.uimm11 != Zeros{11} ||
               assemble.offset != Zeros{PTO_XLEN} ||
               (assemble.size_code < 1 || assemble.size_code > 12) then
                return FALSE;
            end;
            let c0 = BundleTIMG2COLC0Elements(data_type);
            let writer_cells =
                (BundleTIMG2COLPEValidRow(output, valid_row) *
                    (total_col DIVRM c0)) as integer {0..8192};
            let derived_offset =
                (BundleTIMG2COLPERowStart(output,
                    valid_row, 0) *
                    total_col) DIVRM c0;
            if derived_offset > 8192 then return FALSE; end;
            let (coverage_legal, coverage_cells) =
                BundleTIMG2COLGenerationCoverage(
                    derived_offset as integer {0..8192}, writer_cells);
            if !coverage_legal then return FALSE; end;
            _BundleSharedBindings[[0]].destination_assemble.offset =
                Zeros{PTO_XLEN} + derived_offset;
            if !ValidateBundleSharedGenerationRange(0,
                   derived_offset as integer {0..8192}, coverage_cells,
                   BundleTIMG2COLPEBit(), TRUE, gm_base,
                   param0, param1, param2, generation_metadata) then
                return FALSE;
            end;
        elsif _BundleSharedBindings[[0]].destination_assemble.valid then
            return FALSE;
        end;
    else
        let binding = _BundleTileBindings[[0]];
        let expected_layout = if output == BundleTIMG2COLOutput_LocalM16 then
            TileLayout_CUBE_M16 else TileLayout_CUBE_M32;
        if !binding.valid || !binding.destination_valid ||
           binding.source0_valid || binding.source1_valid || !binding.last ||
           binding.pe_mask != '1111' ||
           (BundleTIMG2COLPEValidRow(output, valid_row) != 0 &&
            !TileCubeDescriptorShapeLegal(
               BundleTileDestinationSizeBytes(0),
               BundleTIMG2COLPEValidRow(output, valid_row), valid_col,
               data_type, expected_layout)) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func BundleTIMG2COLGenerationCoverage(
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

func BundleTIMG2COLBuildAndPublish() => boolean
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    let output = BundleTIMG2COLStateOutput();
    let data_type = TileDataTypeFromEncoding(
        _BundleOperation.data_type as TileDataTypeEncoding);
    let valid_col = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_row = UInt(_BundleDimensions[[1]]) as integer {1..128};
    let total_col = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    var cooperative = TRUE;
    if output == BundleTIMG2COLOutput_SharedND then
        cooperative = BundleSharedBindingMask(0) == '1111';
    end;
    let pe_valid_row = if cooperative then
        BundleTIMG2COLPEValidRow(output, valid_row) else valid_row;
    let encoded_row_start = UInt(ReadScalarRegisterOperand(
        _BundleScalarBindings[[1]].source2)[31:0]);
    let pe_row_start = if cooperative then
        BundleTIMG2COLPERowStart(output, valid_row, encoded_row_start)
        else encoded_row_start;
    let param0 = ReadScalarRegisterOperand(_BundleScalarBindings[[1]].source0);
    let param1 = ReadScalarRegisterOperand(_BundleScalarBindings[[1]].source1);
    let param2 = ReadScalarRegisterOperand(_BundleScalarBindings[[1]].source2);
    let base_parameters = BundleTIMG2COLParametersFromWords(
        param0, param1, param2);
    var parameters = base_parameters;
    parameters.row_start = pe_row_start as integer {0..4294967295};
    let layout = TileDataLayoutOfCode(_BundleDataAttributes.data_layout);
    let gm_base = ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source0);
    let element_bytes = TileMemoryElementBytes(data_type);
    // Zero-row cooperative PEs complete the collective protocol but have no
    // Local allocation, GM read, payload write, or definedness effect.
    if pe_valid_row == 0 && output != BundleTIMG2COLOutput_SharedND then
        return TRUE;
    end;
    if pe_valid_row != 0 &&
       !BundleTIMG2COLPreflightGM(layout, data_type, base_parameters,
           valid_row, valid_col, gm_base, element_bytes) then
        return FALSE;
    end;
    let capacity = if output == BundleTIMG2COLOutput_SharedND then
        TileSizeCodeBytes(BundleSharedGenerationCapacity(0)
            as integer {1..12})
        else BundleTileDestinationSizeBytes(0);
    let rows_to_write = if output == BundleTIMG2COLOutput_SharedND &&
        BundleSharedBindingMask(0) != '1111' then valid_row else pe_valid_row;
    let rows = DerivedTileRows(capacity, total_col, data_type);
    var destination: TileIndex = 0;
    var candidate: TileInfo;
    var mask = '1111';
    if output == BundleTIMG2COLOutput_SharedND then
        destination = 0;
        candidate = SharedTileRecord(BundleSharedBindingId(0)).tile;
        mask = BundleSharedBindingMask(0);
    else
        let binding = _BundleTileBindings[[0]];
        let expected_layout =
            if output == BundleTIMG2COLOutput_LocalM16 then
                TileLayout_CUBE_M16
            else TileLayout_CUBE_M32;
        if binding.destination_reused_by_generation then
            destination = binding.destination;
            let reused = _Tiles[[destination]];
            if !TileCubeDescriptorLegal(reused) ||
               reused.capacity_bytes != capacity ||
               reused.valid_rows != pe_valid_row ||
               reused.valid_columns != valid_col ||
               reused.data_type != data_type ||
               reused.layout != expected_layout then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
        else
            let hand = UInt(binding.destination_hand);
            var found = FALSE;
            for offset = 0 to 15 do
                let raw_index = hand * 16 + offset;
                if !found && !_Tiles[[raw_index]].allocated then
                    destination = raw_index as TileIndex;
                    found = TRUE;
                end;
            end;
            if !found || !ConfigureCubeTileForMask(
                   destination, capacity, pe_valid_row, valid_col, data_type,
                   expected_layout, BundleTIMG2COLPEBit()) then
                SetFault(Fault_TileAllocation, ReadTPC());
                return FALSE;
            end;
            _BundleTileBindings[[0]].destination = destination;
            _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
        end;
        candidate = _Tiles[[destination]];
        // The destination now carries the exact current writer descriptor.
        // Reject malformed WriterSize/common metadata/tail/finalization before
        // the first GM event, payload update, coverage change, or publication.
        if !ValidateBundleLocalGenerationWriters() then return FALSE; end;
    end;
    candidate.allocated = TRUE;
    candidate.storage_kind = TileStorage_Numeric;
    candidate.contents_defined = FALSE;
    candidate.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    candidate.packed_defined_elements = zero_packed_tile_elements;
    candidate.defined_valid_elements = 0;
    if output == BundleTIMG2COLOutput_SharedND then
        candidate.capacity_bytes = capacity;
        candidate.rows = rows;
        candidate.columns = total_col;
        candidate.valid_rows = if mask == '1111' then pe_valid_row else valid_row;
        candidate.valid_columns = valid_col;
        candidate.data_type = data_type;
        candidate.predicate_basis_type = data_type;
        candidate.layout = TileLayout_RowMajor;
    end;
    for row = 0 to rows_to_write - 1 looplimit 128 do
        for col = 0 to valid_col - 1 looplimit 65535 do
            let cell = BundleTIMG2COLCell(layout, data_type, parameters,
                row as integer {0..127}, col as integer {0..65534});
            var value = Zeros{PTO_XLEN};
            if cell.gm_access then
                let byte_offset: integer = cell.gm_index * element_bytes;
                let address = gm_base + byte_offset;
                if UInt(address) < UInt(gm_base) then
                    SetFault(Fault_DataPage, address);
                    return FALSE;
                end;
                let probe = ProbeTileMemoryAccess(address, data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return FALSE; end;
                let raw = LoadTranslatedUnsigned(probe.translated_address,
                    element_bytes);
                RecordLoadEvent(probe.translated_address, element_bytes, raw,
                    CurrentBundleMemoryOrder());
                value = DecodeTileMemoryElementRaw(raw, data_type,
                    TileMemoryStridedByteHighNibble(col, data_type));
            end;
            let element = TileLogicalLinearIndex(candidate,
                row as integer {0..65535}, col as integer {0..65535});
            candidate = TileInfoWithLogicalElement(candidate, element, value);
        end;
    end;
    candidate.contents_defined = TRUE;
    candidate.defined_valid_elements =
        (rows_to_write * valid_col) as integer {0..524288};
    if output == BundleTIMG2COLOutput_SharedND then
        if mask == '1111' then
            let c0 = BundleTIMG2COLC0Elements(data_type);
            let destination_row_start = BundleTIMG2COLPERowStart(
                output, valid_row, 0);
            let derived_offset = (destination_row_start * total_col) DIVRM c0;
            let writer_cells = (pe_valid_row * (total_col DIVRM c0))
                as integer {0..8192};
            let generation_metadata = BundleTIMG2COLGenerationMetadata(
                _BundleDataAttributes.data_layout, _BundleOperation.data_type,
                _BundleDimensions[[0]][15:0], _BundleDimensions[[1]][7:0],
                _BundleDimensions[[2]][15:0],
                Zeros{4} + BundleSharedGenerationCapacity(0),
                BundleSharedBindingId(0));
            if derived_offset > 8192 then return FALSE; end;
            let (coverage_legal, coverage_cells) =
                BundleTIMG2COLGenerationCoverage(
                    derived_offset as integer {0..8192}, writer_cells);
            if !coverage_legal then return FALSE; end;
            _BundleSharedBindings[[0]].destination_assemble.offset =
                Zeros{PTO_XLEN} + derived_offset;
            if !CommitBundleSharedGenerationCandidateRange(
                   0, SharedTileInfo {
                       descriptor_valid = TRUE,
                       allocation_mask = mask,
                       initialized_mask = BundleTIMG2COLPEBit(),
                       whole_parent_ready = FALSE,
                       published = FALSE,
                       tile = candidate },
                   derived_offset as integer {0..8192}, coverage_cells,
                   writer_cells, BundleTIMG2COLPEBit(), TRUE, gm_base,
                   param0, param1, param2, generation_metadata) then
                AbortBundleSharedGeneration(
                    BundleSharedBindingId(0));
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
        elsif !AtomicUpdateSharedTile(
               BundleSharedBindingId(0), candidate, mask) then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
    else
        _Tiles[[destination]] = candidate;
    end;
    return TRUE;
end;

func BundleTIMG2COLAbortFailedAttempt()
begin
    if BundleTIMG2COLSelected() &&
       BundleSharedBindingPhysicalCount() == 1 &&
       _BundleSharedBindings[[0]].destination_assemble.valid then
        AbortBundleSharedGeneration(BundleSharedBindingId(0));
    elsif BundleTIMG2COLSelected() && BundleTileBindingCount() == 1 then
        RollBackBundleTileDestinations();
    end;
end;

func ExecuteBundleTIMG2COLOperation() => boolean
begin
    if !BundleTIMG2COLStateLegal() then
        BundleTIMG2COLAbortFailedAttempt();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleTIMG2COLBuildAndPublish() then
        BundleTIMG2COLAbortFailedAttempt();
        if _LastFault == Fault_None then SetFault(Fault_TileLegality, ReadTPC()); end;
        return FALSE;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
