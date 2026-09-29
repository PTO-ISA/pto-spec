<!-- GENERATED FROM: asl/block/model/operands/local-generation-cube.asl -->
# Local Generation CUBE

**Normative ASL source:** `asl/block/model/operands/local-generation-cube.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-local-generation-cube-purpose role=purpose-scope -->
## 用途与范围

本单元拥有 Local `B.ASSEMBLE` 代次中 CUBE 特有的规则，以及每个 Local 代次都会使用的若干辅助函数。代次由多个写者指令束构建一个父 Tile。对 `CUBE_M16` 和 `CUBE_M32` 布局，最终的父形状在 INIT 时并不知道。它在 LAST 时根据写者实际覆盖的内容推导。

<!-- PTO-READER-BLOCK: block-model-operands-local-generation-cube-concepts role=concepts-state -->
## 概念与可见状态

本单元不声明状态。它读取并更新代次的 `_LocalGenerations` 槽位以及父 Tile 的描述符。

- CELL 是 CUBE 布局中 128 字节的存储单元。对 `CUBE_M16` 和 `CUBE_M32`，它跨越 16 或 32 行以及与类型相关的列数。
- 写者片段是一个写者指令束的目标 Tile。每个写者保留自己的片段描述符。
- 一个 PE 的范围长度是其无间隙的已覆盖 CELL 前缀的长度，由 `BundleLocalGenerationPrefixExtent` 给出。
- 一个 PE 的终止写者是其范围恰好结束于该长度的写者。

<!-- PTO-READER-BLOCK: block-model-operands-local-generation-cube-rules role=rules-interactions -->
## 规则与交互

只有当片段是已分配的数值型 `CUBE_M16` 或 `CUBE_M32` Tile、物理行数为 16 或 32、有效区域非零且位于其存储内、CUBE 描述符合法，且 CELL 数和存储大小都等于写者大小码时，`BundleLocalGenerationCubeWriterLegal` 才接受它。

`BundleLocalGenerationCubeFinalizationLegal` 在任何效果之前为 LAST 写者运行。它要求：

- 每个较早的写者在布局、数据类型、基础类型、物理行数和有效行数上与第一个写者一致；
- 每个参与 PE 达到相同的非零范围长度，且没有写者超出该长度；
- 每个 PE 恰好有一个终止写者，其他每个写者的片段都具有完整的有效列；
- 每个 PE 上的最终有效列数相同，其计算方式为终止写者的偏移乘以 CELL 宽度再加上其有效列数；
- 在父 Tile 的容量下，最终描述符合法。

随后 `FinalizeBundleLocalGenerationCube` 把最终的行、列、有效区域、重复数、CELL 数和存储字节数同时安装到父 Tile 和槽位的父描述符中，并设置 `descriptor_finalized`。

设计要点：最终确定只写描述符字段。ASL 注释说明，载荷和已定义性属于写者效果，必须在聚合几何发布之后保留。

设计要点：父级容量只是分配元数据。契约 `PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001` 规定，容量余量永远不会产生父级的行、列、重复数或 CELL。最终形状只来自已覆盖的 CELL。

`ValidateBundleLocalGenerationWriters` 应用这些检查；对于非 CUBE 代次，`BundleLocalGenerationCoverageComplete` 要求在 LAST 时每个参与 PE 上的每个父 CELL 都已覆盖。它在目标形状、分配或重用之后运行。ASL 注释给出了原因：这样写者合法性检查看到的正是生产者将要更新的那个 Tile，同时仍然先于生产者效果、覆盖更新、LAST 关闭和最终确定。

<!-- PTO-READER-BLOCK: block-model-operands-local-generation-cube-boundaries role=boundaries -->
## 架构边界

`SetBundleLocalGenerationInitFault` 为失败的 INIT 引发故障，并把陷阱上下文的重启地址指向 `BPC`，即 INIT 指令束。`BundleLocalGenerationDescriptorMatches` 在延续重用父 Tile 之前检查父 Tile 仍是同一个已分配对象，且参与者掩码和容量相同。它还要求写者掩码是该代次掩码的子集，并要求描述符未变；对 CUBE 而言即第一个写者的片段描述符。`BundleLocalGenerationRangeOverlaps` 和 `BundleLocalGenerationMaskSubset` 是共用的范围和掩码辅助函数。

<!-- PTO-READER-BLOCK: block-model-operands-local-generation-cube-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个 FP16 `CUBE_M16` 父 Tile 以大小码 6 分配，即 4096 字节或 32 个 CELL。每个 CELL 为 16 行乘 4 列。写者 A 的大小码为 3（4 个 CELL），偏移为 0；写者 B 的大小码为 3，偏移为 4，带 LAST。两个片段都是 16 乘 16，有效列完整。范围长度为 8 个 CELL，因此最终父 Tile 为 16 行乘 8 x 4 = 32 列、8 个 CELL、1024 字节存储。容量中未使用的 24 个 CELL 不产生任何列。如果 B 改用偏移 5，CELL 4 会成为间隙，LAST 会引发故障。

<!-- PTO-READER-BLOCK: block-model-operands-local-generation-cube-related role=related-owners-navigation -->
## 相关所有者

- [Local 代次](local-generation.md)打开、提交和中止代次。
- [CUBE 单元几何](../../../tile/model/shape/cube-cell.md)拥有 CELL 的行、列和计数。
- [可移植载体](portable-carriers.md)拥有就绪性和发布。
- [B.ASSEMBLE](../../operands/B.ASSEMBLE.md) 是命令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/local-generation-cube.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE","surface":"block","classification":["model","operands","local-generation-cube"],"depends_on":["PTO-BLOCK-MODEL-STATE-TYPES","PTO-TILE-MODEL-SHAPE-CUBE-CELL","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE"]}
pure func BundleLocalGenerationCubeLayout(layout: TileLayout) => boolean
begin
    return layout == TileLayout_CUBE_M16 || layout == TileLayout_CUBE_M32;
end;

readonly func BundleLocalGenerationPrefixExtent(
    covered: bits(2048)) => integer {0..2048}
begin
    var extent: integer {0..2048} = 0;
    var gap = FALSE;
    for cell = 0 to 2047 do
        if covered[cell] == '1' then
            if gap then return 0; end;
            extent = (extent + 1) as integer {0..2048};
        elsif extent != 0 then
            gap = TRUE;
        end;
    end;
    return extent;
end;

readonly func BundleLocalGenerationCubeCandidateExtent(
    slot: integer {0..63}, offset_cells: integer {0..2047},
    writer_cells: integer {1..2048}, writer_mask: bits(4),
    pe: integer {0..3}, init: boolean) => integer {0..2048}
begin
    if offset_cells + writer_cells > 2048 then return 0; end;
    var covered: bits(2048) = if init then Zeros{2048}
        else _LocalGenerations[[slot]].per_pe_covered_cells[[pe]];
    if writer_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
        for cell = 0 to 2047 do
            if cell < writer_cells then
                covered[offset_cells + cell] = '1';
            end;
        end;
    end;
    return BundleLocalGenerationPrefixExtent(covered);
end;

pure func BundleLocalGenerationCubeValidColumnsAt(
    offset_cells: integer {0..2047}, cell_columns: integer {0,1,2,4,8,16},
    fragment_valid_columns: integer {0..65535}) => integer {0..65535}
begin
    let derived = offset_cells * cell_columns + fragment_valid_columns;
    if derived > 65535 then return 0; end;
    return derived as integer {0..65535};
end;

readonly func BundleLocalGenerationCubeWriterLegal(
    destination: TileIndex, writer_size: integer {1..12}) => boolean
begin
    let tile = _Tiles[[destination]];
    let writer_cells = (TileSizeCodeBytes(writer_size) DIVRM PTO_TILE_CELL_BYTES) as integer {1..2048};
    let expected_rows = if tile.layout == TileLayout_CUBE_M16 then 16 else 32;
    return tile.allocated && tile.storage_kind == TileStorage_Numeric &&
           BundleLocalGenerationCubeLayout(tile.layout) &&
           tile.rows == expected_rows && tile.valid_rows <= tile.rows &&
           tile.valid_rows != 0 && tile.valid_columns <= tile.columns &&
           tile.valid_columns != 0 &&
           TileCubeDescriptorLegal(tile) &&
           tile.cube_cell_count == writer_cells &&
           tile.cube_storage_bytes == TileSizeCodeBytes(writer_size) &&
           tile.cube_storage_bytes ==
               TileCubePhysicalRequiredBytes(tile.layout, tile.rows,
                   tile.columns, tile.data_type);
end;

readonly func BundleLocalGenerationCubeFinalizationLegal(
    slot: integer {0..63}, destination: TileIndex,
    offset_cells: integer {0..2047}, writer_cells: integer {1..2048},
    writer_size: integer {1..12}, writer_mask: bits(4), init: boolean,
    replay: boolean) => boolean
begin
    let candidate = _Tiles[[destination]];
    if !BundleLocalGenerationCubeWriterLegal(destination, writer_size) then
        return FALSE;
    end;
    let participant_mask = if init then writer_mask
        else _LocalGenerations[[slot]].participant_mask;
    if participant_mask == Zeros{4} ||
       (writer_mask AND participant_mask) != writer_mask then return FALSE; end;
    if !init && _LocalGenerations[[slot]].writer_count != 0 then
        let first = _LocalGenerations[[slot]].writers[[0]];
        if first.layout != candidate.layout ||
           first.data_type != candidate.data_type ||
           first.predicate_basis_type != candidate.predicate_basis_type ||
           first.physical_rows != candidate.rows ||
           first.valid_rows != candidate.valid_rows then return FALSE; end;
        for prior_index = 0 to _LocalGenerations[[slot]].writer_count - 1
            looplimit 16 do
            let prior = _LocalGenerations[[slot]].writers[[prior_index]];
            if prior.valid then
                let expected_rows = if prior.layout == TileLayout_CUBE_M16 then
                    16 else 32;
                if prior.physical_rows != expected_rows ||
                   prior.valid_rows == 0 ||
                   prior.valid_rows > prior.physical_rows ||
                   prior.valid_columns == 0 ||
                   prior.valid_columns > prior.physical_columns ||
                   TileCubePhysicalCellCount(prior.layout,
                       prior.physical_rows, prior.physical_columns,
                       prior.data_type) != prior.cell_count ||
                   TileCubePhysicalRequiredBytes(prior.layout,
                       prior.physical_rows, prior.physical_columns,
                       prior.data_type) != prior.cell_count * PTO_TILE_CELL_BYTES then
                    return FALSE;
                end;
                if prior.layout != first.layout ||
                   prior.data_type != first.data_type ||
                   prior.predicate_basis_type != first.predicate_basis_type ||
                   prior.physical_rows != first.physical_rows ||
                   prior.valid_rows != first.valid_rows then
                    return FALSE;
                end;
            end;
        end;
    end;
    var common_extent: integer {0..2048} = 0;
    var common_valid_columns: integer {0..65535} = 0;
    var common_set = FALSE;
    let cell_columns = TileCubeCellColumns(candidate.layout,
        candidate.data_type);
    if cell_columns == 0 then return FALSE; end;
    for pe = 0 to 3 do
        if participant_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
            let extent = BundleLocalGenerationCubeCandidateExtent(
                slot, offset_cells, writer_cells, writer_mask, pe, init);
            if extent == 0 then return FALSE; end;
            if !common_set then
                common_extent = extent;
            elsif extent != common_extent then
                return FALSE;
            end;
            var terminal_found = FALSE;
            var pe_valid_columns: integer {0..65535} = 0;
            if !init then
                for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
                    looplimit 16 do
                    let prior = _LocalGenerations[[slot]].writers[[writer]];
                    if prior.valid && prior.pe_mask[
                           PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                        let end_cell = prior.offset_cells + prior.cell_count;
                        if end_cell > extent then return FALSE; end;
                        if end_cell == extent then
                            if terminal_found || prior.valid_columns == 0 ||
                               prior.valid_columns > prior.physical_columns then
                                return FALSE;
                            end;
                            terminal_found = TRUE;
                            pe_valid_columns =
                                BundleLocalGenerationCubeValidColumnsAt(
                                    prior.offset_cells, cell_columns,
                                    prior.valid_columns);
                        elsif prior.valid_columns != prior.physical_columns then
                            return FALSE;
                        end;
                    end;
                end;
            end;
            if writer_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                let end_cell = offset_cells + writer_cells;
                if end_cell > extent then return FALSE; end;
                if end_cell == extent then
                    if terminal_found || candidate.valid_columns == 0 ||
                       candidate.valid_columns > candidate.columns then
                        return FALSE;
                    end;
                    terminal_found = TRUE;
                    pe_valid_columns =
                        BundleLocalGenerationCubeValidColumnsAt(
                            offset_cells, cell_columns,
                            candidate.valid_columns);
                elsif candidate.valid_columns != candidate.columns then
                    return FALSE;
                end;
            end;
            if !terminal_found || pe_valid_columns == 0 ||
               pe_valid_columns > extent * cell_columns then return FALSE; end;
            if !common_set then
                common_valid_columns = pe_valid_columns;
                common_set = TRUE;
            elsif pe_valid_columns != common_valid_columns then
                return FALSE;
            end;
        end;
    end;
    if !common_set || common_extent == 0 || common_valid_columns == 0 then
        return FALSE;
    end;
    let final_columns = common_extent * cell_columns;
    return TileCubeDescriptorShapeAndPhysicalLegal(
        candidate.capacity_bytes, candidate.rows, final_columns,
        candidate.valid_rows, common_valid_columns, candidate.data_type,
        candidate.layout);
end;
readonly func BundleLocalGenerationCubeFinalExtent(
    slot: integer {0..63}) => integer {0..2048}
begin
    var common_extent: integer {0..2048} = 0;
    var set = FALSE;
    for pe = 0 to 3 do
        if _LocalGenerations[[slot]].participant_mask[
               PTOPEMaskBitOfPEIdentity(pe)] == '1' then
            let extent = BundleLocalGenerationPrefixExtent(
                _LocalGenerations[[slot]].per_pe_covered_cells[[pe]]);
            if !set then
                common_extent = extent;
                set = TRUE;
            elsif extent != common_extent then
                return 0;
            end;
        end;
    end;
    return if set then common_extent else 0;
end;

readonly func BundleLocalGenerationCubeFinalValidColumns(
    slot: integer {0..63}, extent: integer {1..2048}) => integer {0..65535}
begin
    let first = _LocalGenerations[[slot]].writers[[0]];
    let cell_columns = TileCubeCellColumns(first.layout, first.data_type);
    var selected_pe: integer {0..3} = 0;
    var pe_found = FALSE;
    for pe = 0 to 3 do
        if !pe_found && _LocalGenerations[[slot]].participant_mask[
               PTOPEMaskBitOfPEIdentity(pe)] == '1' then
            selected_pe = pe as integer {0..3};
            pe_found = TRUE;
        end;
    end;
    if !pe_found then return 0; end;
    var valid_columns: integer {0..65535} = 0;
    var found = FALSE;
    for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
        looplimit 16 do
        let current = _LocalGenerations[[slot]].writers[[writer]];
        if current.valid && current.pe_mask[
               PTOPEMaskBitOfPEIdentity(selected_pe)] == '1' &&
           current.offset_cells + current.cell_count == extent then
            if found then return 0; end;
            found = TRUE;
            valid_columns = BundleLocalGenerationCubeValidColumnsAt(
                current.offset_cells, cell_columns, current.valid_columns);
            if valid_columns == 0 then return 0; end;
        end;
    end;
    return if found then valid_columns else 0;
end;

func FinalizeBundleLocalGenerationCube(slot: integer {0..63})
begin
    let destination = _LocalGenerations[[slot]].working_destination;
    let first = _LocalGenerations[[slot]].writers[[0]];
    let extent = BundleLocalGenerationCubeFinalExtent(slot);
    let valid_columns = BundleLocalGenerationCubeFinalValidColumns(slot,
        extent as integer {1..2048});
    let cell_columns = TileCubeCellColumns(first.layout, first.data_type);
    let physical_columns = extent * cell_columns;
    let k_repeat = TileCubePhysicalKRepeat(first.layout, first.physical_rows,
        physical_columns, first.data_type);
    let n_repeat = TileCubePhysicalNRepeat(first.layout, first.physical_rows,
        physical_columns, first.data_type);
    let cell_count = TileCubePhysicalCellCount(first.layout, first.physical_rows,
        physical_columns, first.data_type);
    let storage_bytes = TileCubePhysicalRequiredBytes(first.layout,
        first.physical_rows, physical_columns, first.data_type);
    assert extent != 0 && valid_columns != 0 &&
           TileCubeDescriptorShapeAndPhysicalLegal(
               _Tiles[[destination]].capacity_bytes, first.physical_rows,
               physical_columns, first.valid_rows, valid_columns,
               first.data_type, first.layout);
    // Install only descriptor state. Payload and definedness belong to the
    // writer effects and must survive the aggregate geometry publication.
    _Tiles[[destination]].rows = first.physical_rows;
    _Tiles[[destination]].columns = physical_columns;
    _Tiles[[destination]].valid_rows = first.valid_rows;
    _Tiles[[destination]].valid_columns = valid_columns;
    _Tiles[[destination]].cube_k_repeat = k_repeat;
    _Tiles[[destination]].cube_n_repeat = n_repeat;
    _Tiles[[destination]].cube_cell_count = cell_count;
    _Tiles[[destination]].cube_storage_bytes = storage_bytes;
    _LocalGenerations[[slot]].parent_descriptor.rows = first.physical_rows;
    _LocalGenerations[[slot]].parent_descriptor.columns = physical_columns;
    _LocalGenerations[[slot]].parent_descriptor.valid_rows = first.valid_rows;
    _LocalGenerations[[slot]].parent_descriptor.valid_columns = valid_columns;
    _LocalGenerations[[slot]].parent_descriptor.data_type = first.data_type;
    _LocalGenerations[[slot]].parent_descriptor.predicate_basis_type =
        first.predicate_basis_type;
    _LocalGenerations[[slot]].parent_descriptor.layout = first.layout;
    _LocalGenerations[[slot]].parent_descriptor.cube_k_repeat = k_repeat;
    _LocalGenerations[[slot]].parent_descriptor.cube_n_repeat = n_repeat;
    _LocalGenerations[[slot]].parent_descriptor.cube_cell_count = cell_count;
    _LocalGenerations[[slot]].parent_descriptor.cube_storage_bytes =
        storage_bytes;
    _LocalGenerations[[slot]].parent_descriptor.valid = TRUE;
    _LocalGenerations[[slot]].descriptor_finalized = TRUE;
end;


readonly func BundleLocalGenerationCoverageComplete(
    slot: integer {0..63}, offset: Word, writer_size: integer {1..12},
    writer_mask: bits(4), init: boolean,
    parent_size: integer {0..12}) => boolean
begin
    let raw_offset = UInt(offset);
    if raw_offset > 2047 then return FALSE; end;
    let offset_cells = raw_offset as integer {0..2047};
    let writer_cells = (TileSizeCodeBytes(writer_size) DIVRM PTO_TILE_CELL_BYTES) as integer {1..2048};
    let required_cells = if init then
        (TileSizeCodeBytes(parent_size as integer {1..12}) DIVRM PTO_TILE_CELL_BYTES) as integer {1..2048}
        else _LocalGenerations[[slot]].parent_cell_count;
    let participant_mask = if init then writer_mask
        else _LocalGenerations[[slot]].participant_mask;
    for pe = 0 to 3 do
        if participant_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
            var covered: bits(2048) = if init then Zeros{2048}
                else _LocalGenerations[[slot]].per_pe_covered_cells[[pe]];
            if writer_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                for cell = 0 to 2047 do
                    if cell < writer_cells then
                        covered[offset_cells + cell] = '1';
                    end;
                end;
            end;
            for required = 0 to 2047 do
                if required < required_cells && covered[required] == '0' then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;
readonly func BundleLocalGenerationMaskSubset(writer_mask: bits(4), init_mask: bits(4)) => boolean
begin
    for pe = 0 to 3 do if writer_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1' && init_mask[PTOPEMaskBitOfPEIdentity(pe)] == '0' then return FALSE; end; end;
    return TRUE;
end;
readonly func BundleLocalGenerationDescriptorMatches(
    slot: integer {0..63}, destination: TileIndex,
    participant_mask: bits(4)) => boolean
begin
    let expected = _LocalGenerations[[slot]].parent_descriptor;
    let actual = _Tiles[[destination]];
    if !_LocalGenerations[[slot]].generation_identity_valid ||
       !actual.allocated || expected.object_name != destination ||
       expected.object_kind != actual.storage_kind ||
       expected.participant_mask != _TileAllocationMasks[[destination]] ||
       !BundleLocalGenerationMaskSubset(participant_mask,
           expected.participant_mask) ||
       actual.capacity_bytes != expected.capacity_bytes then
        return FALSE;
    end;
    if BundleLocalGenerationCubeLayout(actual.layout) then
        if _LocalGenerations[[slot]].writer_count == 0 then return FALSE; end;
        let first = _LocalGenerations[[slot]].writers[[0]];
        return first.valid && actual.rows == first.physical_rows &&
               actual.columns == first.physical_columns &&
               actual.valid_rows == first.valid_rows &&
               actual.valid_columns == first.valid_columns &&
               actual.data_type == first.data_type &&
               actual.predicate_basis_type == first.predicate_basis_type &&
               actual.layout == first.layout &&
               actual.cube_cell_count == first.cell_count &&
               actual.cube_storage_bytes ==
                   TileCubePhysicalRequiredBytes(actual.layout,
                       actual.rows, actual.columns, actual.data_type);
    end;
    return actual.rows == expected.rows && actual.columns == expected.columns &&
           actual.valid_rows == expected.valid_rows &&
           actual.valid_columns == expected.valid_columns &&
           actual.data_type == expected.data_type &&
           actual.predicate_basis_type == expected.predicate_basis_type &&
           actual.layout == expected.layout &&
           actual.cube_k_repeat == expected.cube_k_repeat &&
           actual.cube_n_repeat == expected.cube_n_repeat &&
           actual.cube_cell_count == expected.cube_cell_count &&
           actual.cube_storage_bytes == expected.cube_storage_bytes;
end;

pure func BundleLocalGenerationRangeOverlaps(
    left_offset: integer {0..2047}, left_count: integer {1..2048},
    right_offset: integer {0..2047}, right_count: integer {1..2048}) => boolean
begin
    return left_offset < right_offset + right_count &&
           right_offset < left_offset + left_count;
end;


func SetBundleLocalGenerationInitFault(fault: FaultCode)
begin
    SetFault(fault, ReadTPC()); let ring = CurrentACR();
    if _TrapContexts[[ring]].valid then _TrapContexts[[ring]].tpc = ReadBPC(); end;
end;

// Destination shape, allocation, and generation reuse are resolved before
// this check. Writer descriptor legality therefore observes the exact Tile
// that the producer would update, while still preceding producer effects,
// coverage updates, LAST closure, and parent-descriptor finalization.
func ValidateBundleLocalGenerationWriters() => boolean
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_assemble.valid then
            let assemble = _BundleTileBindings[[binding]].destination_assemble;
            let destination = _BundleTileBindings[[binding]].destination;
            let writer_mask = _BundleTileBindings[[binding]].pe_mask;
            let writer_size = assemble.size_code as integer {1..12};
            let offset_cells = UInt(assemble.offset) as integer {0..2047};
            let writer_cells = BundleLocalGenerationCellCount(writer_size)
                as integer {1..2048};
            let slot = if assemble.init then 0
                else BundleLocalGenerationSlotForDestination(destination);
            if !assemble.init && slot == 64 then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            let generation_slot = slot as integer {0..63};
            if BundleLocalGenerationCubeLayout(
                   _Tiles[[destination]].layout) then
                if !BundleLocalGenerationCubeWriterLegal(
                       destination, writer_size) then
                    if assemble.init then
                        SetBundleLocalGenerationInitFault(Fault_TileLegality);
                    else
                        SetBundleLocalGenerationFault(generation_slot,
                            Fault_TileLegality);
                    end;
                    return FALSE;
                end;
                if !assemble.init &&
                   _LocalGenerations[[generation_slot]].writer_count != 0 then
                    let first = _LocalGenerations[[generation_slot]].writers[[0]];
                    let actual = _Tiles[[destination]];
                    if first.layout != actual.layout ||
                       first.data_type != actual.data_type ||
                       first.predicate_basis_type != actual.predicate_basis_type ||
                       first.physical_rows != actual.rows ||
                       first.valid_rows != actual.valid_rows then
                        SetBundleLocalGenerationFault(generation_slot,
                            Fault_TileLegality);
                        return FALSE;
                    end;
                end;
                let replay = if assemble.init then FALSE
                    else BundleLocalGenerationReplay(
                        generation_slot, offset_cells, writer_cells, ReadBPC(),
                        _BundleExecutionDomainToken);
                if assemble.last &&
                   !BundleLocalGenerationCubeFinalizationLegal(
                       generation_slot, destination, offset_cells,
                       writer_cells, writer_size,
                       if replay then Zeros{4} else writer_mask,
                       assemble.init, replay) then
                    if assemble.init then
                        SetBundleLocalGenerationInitFault(Fault_TileLegality);
                    else
                        SetBundleLocalGenerationFault(generation_slot,
                            Fault_TileLegality);
                    end;
                    return FALSE;
                end;
            elsif assemble.last &&
                  !BundleLocalGenerationCoverageComplete(
                      generation_slot, assemble.offset, writer_size,
                      writer_mask, assemble.init,
                      if assemble.init then
                          _BundleTileBindings[[binding]].destination_size
                              as integer {1..12}
                      else 0) then
                if assemble.init then
                    SetBundleLocalGenerationInitFault(Fault_TileLegality);
                else
                    SetBundleLocalGenerationFault(generation_slot,
                        Fault_TileLegality);
                end;
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
