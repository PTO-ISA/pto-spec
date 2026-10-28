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
- 对 M32 64 位片段，一个逻辑列组由两个相邻物理 CELL 组成。每个写者偏移、大小、已覆盖前缀和终止 extent 都必须包含完整 pair。
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

随后 `FinalizeBundleLocalGenerationCube` 把最终的行、列、有效区域、重复数、CELL 数和存储字节数同时安装到父 Tile 和槽位的父描述符中，并设置 `descriptor_finalized`。对 M32 64 位数据，它先把物理 CELL extent 除以二再推导逻辑列，同时在存储与容量计数中保留两个 CELL。

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
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE","surface":"block","classification":["model","operands","local-generation-cube"],"depends_on":["PTO-BLOCK-MODEL-STATE-TYPES","PTO-TILE-MODEL-SHAPE-CUBE-CELL","PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-LEGALITY-DESTINATION-VALUE-OPERATIONS"]}
// A resolved writer plan is an ordinary value passed along the current
// instruction path. It keeps the allocated parent descriptor and the exact
// operation-specific writer descriptor together without installing a view in
// architectural tile state.
type BundleLocalGenerationCubeWriterEffectEntry of record {
    active: boolean,
    destination: TileIndex,
    offset_cells: integer {0..2047},
    cell_count: integer {0..2048},
    size_code: integer {0..12},
    pe_mask: bits(4),
    parent: TileInfo,
    writer: TileInfo
};

type BundleLocalGenerationCubeWriterEffects of record {
    count: integer {0..PTO_BUNDLE_TILE_BINDING_COUNT},
    entries: array [[PTO_BUNDLE_TILE_BINDING_COUNT]]
        of BundleLocalGenerationCubeWriterEffectEntry
};

func EmptyBundleLocalGenerationCubeWriterEffects()
    => BundleLocalGenerationCubeWriterEffects
begin
    var effects: BundleLocalGenerationCubeWriterEffects;
    effects.count = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        effects.entries[[binding]].active = FALSE;
    end;
    return effects;
end;


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

readonly func BundleLocalGenerationCubeCurrentValidRows() => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(BundleDimension_LB1);
    let raw = UInt(_BundleDimensions[[index]]);
    return if raw <= 65535 then raw as integer {0..65535} else 0;
end;
readonly func BundleLocalGenerationCubeCurrentValidColumns() => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(BundleDimension_LB0);
    let raw = UInt(_BundleDimensions[[index]]);
    return if raw <= 65535 then raw as integer {0..65535} else 0;
end;
readonly func BundleLocalGenerationCubeWriterColumns(writer_size: integer {1..12}, layout: TileLayout, data_type: TileDataType) => integer {0..65535}
begin
    return TileCubePhysicalColumnsFromCapacity(
        TileSizeCodeBytes(writer_size), layout, data_type);
end;

readonly func BundleLocalGenerationDestinationReuseMatches(
    binding: BundleTileBindingIndex, slot: integer {0..63},
    destination: TileIndex) => boolean
begin
    return _BundleTileBindings[[binding]].destination_valid &&
           _BundleTileBindings[[binding]].destination_reused_by_generation &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle &&
           _BundleTileBindings[[binding]].destination == destination &&
           _BundleTileBindings[[binding]].destination_hand ==
               Zeros{2} + _LocalGenerations[[slot]].destination_hand &&
           _BundleTileBindings[[binding]].destination_size ==
               _LocalGenerations[[slot]].parent_size_code;
end;
readonly func BundleLocalGenerationDestinationReuseStateLegal(
    binding: BundleTileBindingIndex, slot: integer {0..63}) => boolean
begin
    return (!_BundleTileBindings[[binding]].destination_valid &&
            !_BundleTileBindings[[binding]].destination_reused_by_generation) ||
           BundleLocalGenerationDestinationReuseMatches(binding, slot,
               _LocalGenerations[[slot]].working_destination);
end;

pure func BundleLocalGenerationCubeValidColumnsAt(
    offset_cells: integer {0..2047}, cell_columns: integer {0,1,2,4,8,16},
    cells_per_group: integer {1..2},
    fragment_valid_columns: integer {0..65535}) => integer {0..65535}
begin
    if offset_cells MOD cells_per_group != 0 then return 0; end;
    let derived = (offset_cells DIVRM cells_per_group) * cell_columns +
        fragment_valid_columns;
    if derived > 65535 then return 0; end;
    return derived as integer {0..65535};
end;

readonly func BundleLocalGenerationCubeWriterLegal(
    destination: TileIndex, writer_size: integer {1..12}) => boolean
begin
    let tile = _Tiles[[destination]];
    let writer_cells = (TileSizeCodeBytes(writer_size) DIVRM PTO_TILE_CELL_BYTES) as integer {1..2048};
    let expected_rows = if tile.layout == TileLayout_CUBE_M16 then 16 else 32;
    let writer_columns = BundleLocalGenerationCubeWriterColumns(
        writer_size, tile.layout, tile.data_type);
    let writer_valid_rows = BundleLocalGenerationCubeCurrentValidRows();
    let writer_valid_columns =
        BundleLocalGenerationCubeCurrentValidColumns();
    return tile.allocated &&
           BundleLocalGenerationCubeLayout(tile.layout) &&
           tile.rows == expected_rows && tile.valid_rows <= tile.rows &&
           tile.valid_rows != 0 && tile.valid_columns <= tile.columns &&
           tile.valid_columns != 0 &&
           TileCubeNumericOrPredicateCellDescriptorLegal(tile) &&
           tile.capacity_bytes >= TileSizeCodeBytes(writer_size) &&
           writer_columns != 0 &&
           TileCubeDescriptorShapeAndPhysicalLegal(
               TileSizeCodeBytes(writer_size), expected_rows,
               writer_columns, writer_valid_rows, writer_valid_columns,
               tile.data_type, tile.layout) &&
           TileCubePhysicalCellCount(tile.layout, expected_rows,
               writer_columns, tile.data_type) == writer_cells &&
           TileCubePhysicalRequiredBytes(tile.layout, expected_rows,
               writer_columns, tile.data_type) ==
                   TileSizeCodeBytes(writer_size);
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
    let cells_per_group = TileCubePhysicalCellsPerLogicalGroup(
        first.layout, first.data_type);
    if extent MOD cells_per_group != 0 then return 0; end;
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
                current.offset_cells, cell_columns, cells_per_group,
                current.valid_columns);
            if valid_columns == 0 then return 0; end;
        end;
    end;
    return if found then valid_columns else 0;
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
func ValidateBundleLocalGenerationWritersWithWriterEffects(
    writer_effects: BundleLocalGenerationCubeWriterEffects) => boolean
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
            var writer_effect_found = FALSE;
            var writer_effect: BundleLocalGenerationCubeWriterEffectEntry;
            for effect_index = 0 to writer_effects.count - 1 looplimit
                PTO_BUNDLE_TILE_BINDING_COUNT do
                let candidate = writer_effects.entries[[effect_index]];
                if candidate.active && candidate.destination == destination then
                    writer_effect = candidate;
                    writer_effect_found = TRUE;
                end;
            end;
            let slot = if assemble.init then 0
                else BundleLocalGenerationSlotForDestination(destination);
            if !assemble.init && slot == 64 then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            let generation_slot = slot as integer {0..63};
            if BundleLocalGenerationCubeLayout(
                   _Tiles[[destination]].layout) then
                if !writer_effect_found ||
                   writer_effect.size_code != writer_size ||
                   writer_effect.offset_cells != offset_cells ||
                   writer_effect.cell_count != writer_cells ||
                   writer_effect.pe_mask != writer_mask ||
                   !BundleLocalGenerationCubeWriterValueLegal(
                       writer_effect.parent, writer_effect.writer,
                       writer_size, offset_cells, writer_cells) then
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
                       first.valid_rows != writer_effect.writer.valid_rows then
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
                   !BundleLocalGenerationCubeFinalizationWithWriterLegal(
                       generation_slot, destination, offset_cells,
                       writer_cells, writer_size,
                       if replay then Zeros{4} else writer_mask,
                       assemble.init, replay, writer_effect.writer) then
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

func ValidateBundleLocalGenerationWriters() => boolean
begin
    return ValidateBundleLocalGenerationWritersWithWriterEffects(
        EmptyBundleLocalGenerationCubeWriterEffects());
end;
```
<!-- GENERATED-ASL-END: unit -->
